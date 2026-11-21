import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/cities.dart';
import '../models/weather.dart';
import 'cache_store.dart';

/// Cliente para as APIs públicas e gratuitas do Open-Meteo.
///
/// - https://api.open-meteo.com/v1/forecast        (previsão + atual)
/// - https://air-quality-api.open-meteo.com/v1/air-quality (qualidade do ar)
///
/// Sem chave de API. Licença dos dados: CC BY 4.0 (atribuição "Open-Meteo").
class OpenMeteoService {
  OpenMeteoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _forecastHost = 'api.open-meteo.com';
  static const _airHost = 'air-quality-api.open-meteo.com';
  static const _timezone = 'America/Sao_Paulo';

  static const _currentParams =
      'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,'
      'weather_code,pressure_msl,cloud_cover,wind_speed_10m,'
      'wind_direction_10m,wind_gusts_10m,precipitation';

  static const _hourlyParams =
      'temperature_2m,apparent_temperature,relative_humidity_2m,'
      'precipitation_probability,precipitation,weather_code,pressure_msl,'
      'visibility,uv_index,wind_speed_10m,wind_gusts_10m,wind_direction_10m,'
      'cloud_cover';

  static const _dailyParams =
      'weather_code,temperature_2m_max,temperature_2m_min,'
      'apparent_temperature_max,apparent_temperature_min,sunrise,sunset,'
      'uv_index_max,precipitation_sum,precipitation_probability_max,'
      'wind_speed_10m_max,wind_gusts_10m_max';

  /// Parâmetros diários enxutos para a varredura regional (alertas + tiles).
  static const _regionDailyParams =
      'weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_sum,precipitation_probability_max,'
      'wind_gusts_10m_max,uv_index_max';

  static const _regionCurrentParams =
      'temperature_2m,relative_humidity_2m,weather_code';

  /// Previsão completa (atual + horário + 9 dias + qualidade do ar).
  ///
  /// Em caso de falha de rede, cai de volta para o cache local (última
  /// resposta salva, mesmo que antiga) com `fromCache: true`.
  Future<WeatherBundle> fetchBundle(City city) async {
    final cache = await CacheStore.load();
    final cacheKey = 'wx_bundle_${city.id}';
    try {
      final forecastUri = Uri.https(_forecastHost, '/v1/forecast', {
        'latitude': '${city.latitude}',
        'longitude': '${city.longitude}',
        'current': _currentParams,
        'hourly': _hourlyParams,
        'daily': _dailyParams,
        'timezone': _timezone,
        'forecast_days': '9',
      });
      final forecastResp =
          await _client.get(forecastUri).timeout(const Duration(seconds: 12));
      if (forecastResp.statusCode != 200) {
        throw OpenMeteoException('HTTP ${forecastResp.statusCode}');
      }
      final forecastJson =
          jsonDecode(forecastResp.body) as Map<String, dynamic>;

      // Qualidade do ar é complementar: se falhar, o app continua sem ela.
      Map<String, dynamic>? aqJson;
      try {
        final aqUri = Uri.https(_airHost, '/v1/air-quality', {
          'latitude': '${city.latitude}',
          'longitude': '${city.longitude}',
          'current':
              'us_aqi,pm2_5,pm10,ozone,nitrogen_dioxide,sulphur_dioxide,carbon_monoxide',
        });
        final aqResp =
            await _client.get(aqUri).timeout(const Duration(seconds: 8));
        if (aqResp.statusCode == 200) {
          aqJson = jsonDecode(aqResp.body) as Map<String, dynamic>;
        }
      } catch (_) {
        aqJson = null;
      }

      await cache.write(cacheKey, {'forecast': forecastJson, 'aq': aqJson});
      return _buildBundle(forecastJson, aqJson,
          fetchedAt: DateTime.now(), fromCache: false);
    } catch (error) {
      final cached = await cache.read(cacheKey, maxAge: const Duration(days: 7));
      if (cached != null) {
        final forecast = cached.body['forecast'] as Map<String, dynamic>;
        final aq = cached.body['aq'] as Map<String, dynamic>?;
        return _buildBundle(forecast, aq,
            fetchedAt: cached.savedAt, fromCache: true);
      }
      throw OpenMeteoException(
          'Não foi possível obter a previsão (${error.toString()}). Verifique a conexão.');
    }
  }

  /// Uma única chamada em lote (latitudes/longitudes separadas por vírgula)
  /// com a situação atual e a prévia diária das 4 dias para todas as cidades.
  Future<RegionSnapshot> fetchRegion(List<City> cities) async {
    final cache = await CacheStore.load();
    const cacheKey = 'wx_region_v1';
    try {
      final lats = cities.map((c) => c.latitude).join(',');
      final lngs = cities.map((c) => c.longitude).join(',');
      final query =
          'latitude=$lats&longitude=$lngs&current=$_regionCurrentParams'
          '&daily=$_regionDailyParams&timezone=America/Sao_Paulo&forecast_days=4';
      final uri = Uri(scheme: 'https', host: _forecastHost, path: '/v1/forecast', query: query);
      final resp =
          await _client.get(uri).timeout(const Duration(seconds: 15));
      if (resp.statusCode != 200) {
        throw OpenMeteoException('HTTP ${resp.statusCode}');
      }
      final decoded = jsonDecode(resp.body);
      final list = decoded is List ? decoded.cast<Map<String, dynamic>>() : [decoded as Map<String, dynamic>];
      await cache.write(cacheKey, {'list': list, 'ids': cities.map((c) => c.id).toList()});
      return RegionSnapshot.fromList(cities, list);
    } catch (error) {
      final cached = await cache.read(cacheKey, maxAge: const Duration(days: 2));
      if (cached != null) {
        final list = (cached.body['list'] as List).cast<Map<String, dynamic>>();
        return RegionSnapshot.fromList(cities, list, fromCache: true, cachedAt: cached.savedAt);
      }
      throw OpenMeteoException('Falha ao carregar o panorama regional: $error');
    }
  }

  WeatherBundle _buildBundle(
    Map<String, dynamic> forecast,
    Map<String, dynamic>? aq, {
    required DateTime fetchedAt,
    required bool fromCache,
  }) {
    final current =
        CurrentWeather.fromJson(forecast['current'] as Map<String, dynamic>);

    final h = (forecast['hourly'] as Map?)?.cast<String, dynamic>() ?? const {};
    final hourlyTimes = (h['time'] as List?) ?? const [];
    final hourly = [
      for (var i = 0; i < hourlyTimes.length; i++) HourPoint.at(h, i),
    ];

    final d = (forecast['daily'] as Map?)?.cast<String, dynamic>() ?? const {};
    final dailyTimes = (d['time'] as List?) ?? const [];
    final daily = [
      for (var i = 0; i < dailyTimes.length; i++) DailyBrief.at(d, i),
    ];

    return WeatherBundle(
      current: current,
      hourly: hourly,
      daily: daily,
      airQuality: aq == null ? null : AirQuality.fromJson(aq),
      fetchedAt: fetchedAt,
      fromCache: fromCache,
    );
  }
}

/// Situação resumida de uma cidade (para tiles e varredura de alertas).
class RegionCity {
  const RegionCity({
    required this.city,
    required this.currentTemp,
    required this.currentCode,
    required this.days,
  });

  final City city;
  final double? currentTemp;
  final int? currentCode;

  /// Hoje + próximos 3 dias.
  final List<DailyBrief> days;
}

class RegionSnapshot {
  const RegionSnapshot({
    required this.cities,
    required this.fetchedAt,
    this.fromCache = false,
  });

  final List<RegionCity> cities;
  final DateTime fetchedAt;
  final bool fromCache;

  RegionCity? of(String cityId) {
    for (final c in cities) {
      if (c.city.id == cityId) return c;
    }
    return null;
  }

  factory RegionSnapshot.fromList(
    List<City> cities,
    List<Map<String, dynamic>> list, {
    bool fromCache = false,
    DateTime? cachedAt,
  }) {
    final parsed = <RegionCity>[];
    for (var i = 0; i < cities.length && i < list.length; i++) {
      final item = list[i];
      final current = (item['current'] as Map?)?.cast<String, dynamic>() ?? const {};
      final d = (item['daily'] as Map?)?.cast<String, dynamic>() ?? const {};
      final times = (d['time'] as List?) ?? const [];
      parsed.add(RegionCity(
        city: cities[i],
        currentTemp: (current['temperature_2m'] as num?)?.toDouble(),
        currentCode: (current['weather_code'] as num?)?.toInt(),
        days: [
          for (var j = 0; j < times.length; j++) DailyBrief.at(d, j),
        ],
      ));
    }
    return RegionSnapshot(
      cities: parsed,
      fetchedAt: cachedAt ?? DateTime.now(),
      fromCache: fromCache,
    );
  }
}

class OpenMeteoException implements Exception {
  const OpenMeteoException(this.message);
  final String message;
  @override
  String toString() => message;
}
