/// Modelos de domínio do ClimaSul (puro Dart, sem Flutter).
library;

class CurrentWeather {
  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.weatherCode,
    required this.isDay,
    required this.pressureMsl,
    required this.cloudCover,
    required this.windSpeed,
    required this.windDirection,
    required this.windGusts,
    required this.precipitation,
  });

  final DateTime time;
  final double temperature;
  final double apparentTemperature;
  final double humidity;
  final int weatherCode;
  final bool isDay;
  final double pressureMsl;
  final double cloudCover;
  final double windSpeed;
  final double windDirection;
  final double windGusts;
  final double precipitation;

  factory CurrentWeather.fromJson(Map<String, dynamic> j) => CurrentWeather(
        time: DateTime.parse(j['time'] as String),
        temperature: (j['temperature_2m'] as num).toDouble(),
        apparentTemperature: (j['apparent_temperature'] as num?)?.toDouble() ??
            (j['temperature_2m'] as num).toDouble(),
        humidity: (j['relative_humidity_2m'] as num?)?.toDouble() ?? 0,
        weatherCode: (j['weather_code'] as num).toInt(),
        isDay: ((j['is_day'] as num?) ?? 1).toInt() == 1,
        pressureMsl: (j['pressure_msl'] as num?)?.toDouble() ?? 1013,
        cloudCover: (j['cloud_cover'] as num?)?.toDouble() ?? 0,
        windSpeed: (j['wind_speed_10m'] as num?)?.toDouble() ?? 0,
        windDirection: (j['wind_direction_10m'] as num?)?.toDouble() ?? 0,
        windGusts: (j['wind_gusts_10m'] as num?)?.toDouble() ?? 0,
        precipitation: (j['precipitation'] as num?)?.toDouble() ?? 0,
      );
}

class HourPoint {
  const HourPoint({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipProbability,
    required this.precipitation,
    required this.weatherCode,
    required this.pressureMsl,
    required this.visibility,
    required this.uvIndex,
    required this.windSpeed,
    required this.windGusts,
    required this.windDirection,
    required this.cloudCover,
  });

  final DateTime time;
  final double temperature;
  final double apparentTemperature;
  final double humidity;
  final double precipProbability; // %
  final double precipitation; // mm na hora
  final int weatherCode;
  final double pressureMsl;
  final double visibility; // m
  final double uvIndex;
  final double windSpeed; // km/h
  final double windGusts; // km/h
  final double windDirection; // graus
  final double cloudCover; // %

  factory HourPoint.at(Map<String, dynamic> h, int i) => HourPoint(
        time: DateTime.parse((h['time'] as List)[i] as String),
        temperature: _atNum(h['temperature_2m'], i)?.toDouble() ?? 0,
        apparentTemperature:
            _atNum(h['apparent_temperature'], i)?.toDouble() ?? 0,
        humidity: _atNum(h['relative_humidity_2m'], i)?.toDouble() ?? 0,
        precipProbability: _atNum(h['precipitation_probability'], i)?.toDouble() ?? 0,
        precipitation: _atNum(h['precipitation'], i)?.toDouble() ?? 0,
        weatherCode: _atNum(h['weather_code'], i)?.toInt() ?? 0,
        pressureMsl: _atNum(h['pressure_msl'], i)?.toDouble() ?? 1013,
        visibility: _atNum(h['visibility'], i)?.toDouble() ?? 10000,
        uvIndex: _atNum(h['uv_index'], i)?.toDouble() ?? 0,
        windSpeed: _atNum(h['wind_speed_10m'], i)?.toDouble() ?? 0,
        windGusts: _atNum(h['wind_gusts_10m'], i)?.toDouble() ?? 0,
        windDirection: _atNum(h['wind_direction_10m'], i)?.toDouble() ?? 0,
        cloudCover: _atNum(h['cloud_cover'], i)?.toDouble() ?? 0,
      );
}

class DailyBrief {
  const DailyBrief({
    required this.date,
    required this.weatherCode,
    required this.tMax,
    required this.tMin,
    required this.apparentMax,
    required this.apparentMin,
    required this.sunrise,
    required this.sunset,
    required this.uvMax,
    required this.precipSum,
    required this.precipProbMax,
    required this.windMax,
    required this.gustMax,
  });

  final DateTime date;
  final int weatherCode;
  final double tMax;
  final double tMin;
  final double apparentMax;
  final double apparentMin;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double uvMax;
  final double precipSum; // mm
  final double precipProbMax; // %
  final double windMax; // km/h
  final double gustMax; // km/h

  factory DailyBrief.at(Map<String, dynamic> d, int i) => DailyBrief(
        date: DateTime.parse((d['time'] as List)[i] as String),
        weatherCode: _atNum(d['weather_code'], i)?.toInt() ?? 0,
        tMax: _atNum(d['temperature_2m_max'], i)?.toDouble() ?? 0,
        tMin: _atNum(d['temperature_2m_min'], i)?.toDouble() ?? 0,
        apparentMax: _atNum(d['apparent_temperature_max'], i)?.toDouble() ?? 0,
        apparentMin: _atNum(d['apparent_temperature_min'], i)?.toDouble() ?? 0,
        sunrise: _atDate(d['sunrise'], i),
        sunset: _atDate(d['sunset'], i),
        uvMax: _atNum(d['uv_index_max'], i)?.toDouble() ?? 0,
        precipSum: _atNum(d['precipitation_sum'], i)?.toDouble() ?? 0,
        precipProbMax:
            _atNum(d['precipitation_probability_max'], i)?.toDouble() ?? 0,
        windMax: _atNum(d['wind_speed_10m_max'], i)?.toDouble() ?? 0,
        gustMax: _atNum(d['wind_gusts_10m_max'], i)?.toDouble() ?? 0,
      );
}

class AirQuality {
  const AirQuality({
    required this.usAqi,
    required this.pm25,
    required this.pm10,
    required this.ozone,
    required this.nitrogenDioxide,
    required this.sulphurDioxide,
    required this.carbonMonoxide,
  });

  final double usAqi;
  final double pm25; // µg/m³
  final double pm10; // µg/m³
  final double ozone; // µg/m³
  final double nitrogenDioxide; // µg/m³
  final double sulphurDioxide; // µg/m³
  final double carbonMonoxide; // µg/m³

  factory AirQuality.fromJson(Map<String, dynamic> j) {
    final c = (j['current'] as Map<String, dynamic>?) ?? const {};
    double v(String k) => (c[k] as num?)?.toDouble() ?? 0;
    return AirQuality(
      usAqi: v('us_aqi'),
      pm25: v('pm2_5'),
      pm10: v('pm10'),
      ozone: v('ozone'),
      nitrogenDioxide: v('nitrogen_dioxide'),
      sulphurDioxide: v('sulphur_dioxide'),
      carbonMonoxide: v('carbon_monoxide'),
    );
  }
}

/// Pacote completo para a tela principal.
class WeatherBundle {
  const WeatherBundle({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.airQuality,
    required this.fetchedAt,
    this.fromCache = false,
  });

  final CurrentWeather current;

  /// Série horária completa retornada pela API (começando 00:00 de hoje).
  final List<HourPoint> hourly;
  final List<DailyBrief> daily;
  final AirQuality? airQuality;
  final DateTime fetchedAt;
  final bool fromCache;

  /// Índice do primeiro ponto horário com horário >= agora - 1h.
  int get currentHourIndex {
    final now = DateTime.now().subtract(const Duration(hours: 1));
    final idx = hourly.indexWhere((h) => !h.time.isBefore(now));
    return idx < 0 ? 0 : idx;
  }

  List<HourPoint> get upcomingHours =>
      hourly.skip(currentHourIndex).toList(growable: false);
}

num? _atNum(dynamic list, int i) {
  if (list is! List || i >= list.length) return null;
  final v = list[i];
  return v is num ? v : null;
}

DateTime? _atDate(dynamic list, int i) {
  if (list is! List || i >= list.length) return null;
  final v = list[i];
  if (v is! String) return null;
  try {
    return DateTime.parse(v);
  } catch (_) {
    return null;
  }
}
