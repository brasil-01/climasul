import 'package:flutter_test/flutter_test.dart';
import 'package:clima_sul/data/cities.dart';
import 'package:clima_sul/models/weather.dart';
import 'package:clima_sul/services/alerts_engine.dart';
import 'package:clima_sul/services/open_meteo_service.dart';

DailyBrief _day(
  DateTime date, {
  int code = 0,
  double tMax = 25,
  double tMin = 15,
  double appMax = 25,
  double precip = 0,
  double gust = 10,
  double uv = 5,
}) =>
    DailyBrief(
      date: date,
      weatherCode: code,
      tMax: tMax,
      tMin: tMin,
      apparentMax: appMax,
      apparentMin: tMin,
      sunrise: null,
      sunset: null,
      uvMax: uv,
      precipSum: precip,
      precipProbMax: 0,
      windMax: 10,
      gustMax: gust,
    );

HourPoint _hour(
  DateTime time, {
  double humidity = 60,
  double mm = 0,
  int code = 0,
  double visibility = 10000,
}) =>
    HourPoint(
      time: time,
      temperature: 22,
      apparentTemperature: 22,
      humidity: humidity,
      precipProbability: 0,
      precipitation: mm,
      weatherCode: code,
      pressureMsl: 1015,
      visibility: visibility,
      uvIndex: 4,
      windSpeed: 8,
      windGusts: 14,
      windDirection: 130,
      cloudCover: 30,
    );

CurrentWeather _current() => CurrentWeather(
      time: DateTime.now(),
      temperature: 25,
      apparentTemperature: 26,
      humidity: 55,
      weatherCode: 1,
      isDay: true,
      pressureMsl: 1015,
      cloudCover: 10,
      windSpeed: 10,
      windDirection: 130,
      windGusts: 18,
      precipitation: 0,
    );

WeatherBundle _bundle({
  List<DailyBrief>? daily,
  List<HourPoint>? hourly,
}) =>
    WeatherBundle(
      current: _current(),
      hourly: hourly ?? const [],
      daily: daily ?? const [],
      airQuality: null,
      fetchedAt: DateTime.now(),
    );

void main() {
  final city = cityById('novo_hamburgo');
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final after = today.add(const Duration(days: 2));

  test('dia tranquilo não gera alertas', () {
    final bundle = _bundle(daily: [_day(today), _day(tomorrow), _day(after)]);
    expect(evaluateBundle(city, bundle), isEmpty);
  });

  test('chuva de 50 mm no dia dispara ALERTA de chuva intensa', () {
    final bundle = _bundle(daily: [
      _day(today, precip: 50, gust: 12),
      _day(tomorrow),
      _day(after),
    ]);
    final alerts = evaluateBundle(city, bundle);
    expect(
      alerts.any((a) =>
          a.type == AlertType.heavyRain && a.severity == AlertSeverity.alerta),
      isTrue,
    );
  });

  test('chuva de 75 mm no dia dispara PERIGO', () {
    final bundle = _bundle(daily: [
      _day(today, precip: 75),
      _day(tomorrow),
      _day(after),
    ]);
    expect(
      evaluateBundle(city, bundle).any((a) =>
          a.type == AlertType.heavyRain && a.severity == AlertSeverity.perigo),
      isTrue,
    );
  });

  test('código 96 (trovoada com granizo) gera PERIGO', () {
    final bundle = _bundle(daily: [
      _day(today, code: 96),
      _day(tomorrow),
      _day(after),
    ]);
    expect(
      evaluateBundle(city, bundle).any((a) =>
          a.type == AlertType.hail && a.severity == AlertSeverity.perigo),
      isTrue,
    );
  });

  test('trovoada horária 95 gera ALERTA com hora de referência', () {
    final bundle = _bundle(
      daily: [_day(today), _day(tomorrow), _day(after)],
      hourly: [
        for (var i = 0; i < 72; i++)
          _hour(now.add(Duration(hours: i)),
              code: i == 6 ? 95 : 1),
      ],
    );
    final alerts = evaluateBundle(city, bundle);
    final storm = alerts.firstWhere((a) => a.type == AlertType.thunderstorm);
    expect(storm.severity, AlertSeverity.alerta);
    expect(storm.hour, isNotNull);
  });

  test('rajadas de 75 km/h geram ALERTA; 95 km/h geram PERIGO', () {
    final warnBundle = _bundle(daily: [
      _day(today, gust: 75),
      _day(tomorrow),
      _day(after),
    ]);
    expect(
      evaluateBundle(city, warnBundle).any((a) =>
          a.type == AlertType.windGusts && a.severity == AlertSeverity.alerta),
      isTrue,
    );

    final dangerBundle = _bundle(daily: [
      _day(today, gust: 95),
      _day(tomorrow),
      _day(after),
    ]);
    expect(
      evaluateBundle(city, dangerBundle).any((a) =>
          a.type == AlertType.windGusts && a.severity == AlertSeverity.perigo),
      isTrue,
    );
  });

  test('calor com sensação acima de 38°C eleva a severidade', () {
    final bundle = _bundle(daily: [
      _day(today, tMax: 37, appMax: 39),
      _day(tomorrow),
      _day(after),
    ]);
    expect(
      evaluateBundle(city, bundle).any((a) =>
          a.type == AlertType.heat && a.severity == AlertSeverity.perigo),
      isTrue,
    );
  });

  test('umidade mínima de 10% nas próximas 48h gera PERIGO', () {
    final bundle = _bundle(
      daily: [_day(today), _day(tomorrow), _day(after)],
      hourly: [
        for (var i = 0; i < 48; i++)
          _hour(now.add(Duration(hours: i)), humidity: i == 5 ? 10 : 55),
      ],
    );
    expect(
      evaluateBundle(city, bundle).any((a) =>
          a.type == AlertType.lowHumidity &&
          a.severity == AlertSeverity.perigo),
      isTrue,
    );
  });

  test('UV 11 dispara PERIGO', () {
    final bundle = _bundle(daily: [
      _day(today, uv: 11),
      _day(tomorrow),
      _day(after),
    ]);
    expect(
      evaluateBundle(city, bundle).any((a) =>
          a.type == AlertType.uvHigh && a.severity == AlertSeverity.perigo),
      isTrue,
    );
  });

  test('varredura regional agrupa cidades no mesmo tipo e dia', () {
    final snapshot = RegionSnapshot(
      cities: [
        RegionCity(
          city: allCities[0],
          currentTemp: 30,
          currentCode: 95,
          days: [_day(today, code: 95)],
        ),
        RegionCity(
          city: allCities[1],
          currentTemp: 30,
          currentCode: 95,
          days: [_day(today, code: 96)],
        ),
        RegionCity(
          city: allCities[2],
          currentTemp: 22,
          currentCode: 1,
          days: [_day(today)],
        ),
      ],
      fetchedAt: DateTime.now(),
    );

    final groups = evaluateRegion(snapshot);
    final storms =
        groups.where((g) => g.type == AlertType.thunderstorm).first;
    expect(storms.cities, hasLength(1));
    final hail = groups.where((g) => g.type == AlertType.hail).first;
    expect(hail.cities, hasLength(1));
    expect(hail.severity, AlertSeverity.perigo);
  });
}
