/// Motor de alertas derivados da previsão do Open-Meteo.
///
/// Open-Meteo não fornece um feed oficial de avisos CAP/INMET; os alertas
/// aqui são gerados por regras determinísticas sobre limiares meteorológicos
/// (ver constantes no fim do arquivo). A camada de UI identifica a fonte
/// como "previsão automática", e este arquivo é o ponto único para plugar
/// um feed oficial (INMET/CPTEC) no futuro.
library;

import '../data/cities.dart';
import '../models/weather.dart';
import '../services/open_meteo_service.dart';
import '../utils/weather_codes.dart';

enum AlertSeverity { atencao, alerta, perigo }

extension AlertSeverityInfo on AlertSeverity {
  String get label => switch (this) {
        AlertSeverity.atencao => 'ATENÇÃO',
        AlertSeverity.alerta => 'ALERTA',
        AlertSeverity.perigo => 'PERIGO',
      };

  /// Ordenação: perigo > alerta > atenção.
  int get rank => index;
}

enum AlertType {
  thunderstorm,
  hail,
  freezingRain,
  heavyRain,
  windGusts,
  heat,
  cold,
  lowHumidity,
  uvHigh,
  fog,
  snow,
}

class WeatherAlert {
  const WeatherAlert({
    required this.type,
    required this.severity,
    required this.date,
    required this.title,
    required this.description,
    required this.actions,
    this.hour,
    this.cityName,
  });

  final AlertType type;
  final AlertSeverity severity;

  /// Dia de vigência (meia-noite local).
  final DateTime date;

  /// Hora provável (quando derivado de dados horários).
  final DateTime? hour;

  final String title;
  final String description;
  final List<String> actions;
  final String? cityName;
}

/// Grupo agregado para a aba regional: mesmo tipo no mesmo dia em N cidades.
class RegionAlertGroup {
  const RegionAlertGroup({
    required this.type,
    required this.date,
    required this.severity,
    required this.title,
    required this.description,
    required this.actions,
    required this.cities,
  });

  final AlertType type;
  final DateTime date;
  final AlertSeverity severity;
  final String title;
  final String description;
  final List<String> actions;
  final List<City> cities;
}

// ── Avaliação da cidade selecionada (diário + horário) ─────────────

List<WeatherAlert> evaluateBundle(City city, WeatherBundle bundle) {
  final alerts = <WeatherAlert>[];
  final now = DateTime.now();
  final days = bundle.daily.take(3).toList();

  for (final day in days) {
    final date = day.date;

    // Trovoada / granizo: prioriza detalhe horário; cai para o código diário.
    final stormHours = bundle.hourly.where((h) =>
        _sameDay(h.time, date) && h.time.isAfter(now.subtract(const Duration(hours: 2))) && isThunderstorm(h.weatherCode));
    if (stormHours.isNotEmpty) {
      final worst = stormHours.map((h) => h.weatherCode).reduce((a, b) => a > b ? a : b);
      final hail = isHail(worst);
      final hours = stormHours.map((h) => h.time.hour).toList()..sort();
      alerts.add(WeatherAlert(
        type: hail ? AlertType.hail : AlertType.thunderstorm,
        severity: isHail(worst) ? AlertSeverity.perigo : AlertSeverity.alerta,
        date: date,
        hour: stormHours.first.time,
        cityName: city.name,
        title: hail ? 'Trovoada com granizo prevista' : 'Trovoada prevista',
        description:
            '${_dayLabel(date)}: instabilidade com trovoada${hail ? ' e granizo' : ''} na faixa das ${hours.first.toString().padLeft(2, '0')}h às ${(hours.last + 1).toString().padLeft(2, '0')}h em ${city.name}. Rajadas de até ${bundle.hourly.where((h) => _sameDay(h.time, date)).map((h) => h.windGusts).fold<double>(0, (a, b) => b > a ? b : a).round()} km/h.',
        actions: _actions[hail ? AlertType.hail : AlertType.thunderstorm]!,
      ));
    } else if (isThunderstorm(day.weatherCode)) {
      final hail = isHail(day.weatherCode);
      alerts.add(WeatherAlert(
        type: hail ? AlertType.hail : AlertType.thunderstorm,
        severity: hail ? AlertSeverity.perigo : AlertSeverity.alerta,
        date: date,
        cityName: city.name,
        title: hail ? 'Trovoada com granizo prevista' : 'Trovoada prevista',
        description: '${_dayLabel(date)}: código WMO ${day.weatherCode} indica trovoada${hail ? ' com granizo' : ''} em ${city.name}.',
        actions: _actions[hail ? AlertType.hail : AlertType.thunderstorm]!,
      ));
    }

    if (isFreezingRain(day.weatherCode)) {
      alerts.add(_simple(AlertType.freezingRain, AlertSeverity.alerta, date, city.name,
          'Chuva congelante prevista',
          '${_dayLabel(date)}: precipitação congelada (código ${day.weatherCode}). Risco de pista escorregadia e danos à vegetação em ${city.name}.'));
    }
    if (isSnow(day.weatherCode)) {
      alerts.add(_simple(AlertType.snow, AlertSeverity.alerta, date, city.name,
          'Neve prevista',
          '${_dayLabel(date)}: precipitação de neve indicada pelo modelo para ${city.name} (raro na região — acompanhe os canais oficiais).'));
    }

    // Chuva intensa: máximo entre volume diário e pico horário.
    final dayHours = bundle.hourly.where((h) => _sameDay(h.time, date));
    final hourlyPeak = dayHours.fold<double>(0, (a, h) => h.precipitation > a ? h.precipitation : a);
    final rainSeverity = _threshold(day.precipSum, _kRainDay) ??
        _threshold(hourlyPeak, _kRainHour);
    if (rainSeverity != null) {
      alerts.add(WeatherAlert(
        type: AlertType.heavyRain,
        severity: rainSeverity,
        date: date,
        cityName: city.name,
        title: 'Chuva intensa',
        description:
            '${_dayLabel(date)}: acumulado previsto de ${day.precipSum.toStringAsFixed(1)} mm em ${city.name} (pico horário ~${hourlyPeak.toStringAsFixed(1)} mm/h). Probabilidade de chuva chega a ${day.precipProbMax.round()}%.',
        actions: _actions[AlertType.heavyRain]!,
      ));
    }

    // Rajadas de vento.
    final gustSeverity = _threshold(day.gustMax, _kGust);
    if (gustSeverity != null) {
      alerts.add(_simple(AlertType.windGusts, gustSeverity, date, city.name,
          'Rajadas de vento',
          '${_dayLabel(date)}: rajadas de até ${day.gustMax.round()} km/h previstas para ${city.name}.'));
    }

    // Calor (com reforço pela sensação térmica).
    var heatSeverity = _thresholdLow(day.tMax, _kHeatMax);
    if (heatSeverity != null && day.apparentMax >= 38) {
      heatSeverity = AlertSeverity.values[heatSeverity.rank + 1];
    }
    if (heatSeverity != null) {
      alerts.add(WeatherAlert(
        type: AlertType.heat,
        severity: heatSeverity,
        date: date,
        cityName: city.name,
        title: 'Calor intenso',
        description:
            '${_dayLabel(date)}: máxima de ${day.tMax.round()}°C (sensação de ${day.apparentMax.round()}°C) em ${city.name}.',
        actions: _actions[AlertType.heat]!,
      ));
    }

    // Frio / geada.
    final coldSeverity = _thresholdLow(day.tMin, _kColdMin, reverse: true);
    if (coldSeverity != null) {
      alerts.add(_simple(AlertType.cold, coldSeverity, date, city.name,
          day.tMin <= 0 ? 'Frio intenso / geada' : 'Frio intenso',
          '${_dayLabel(date)}: mínima de ${day.tMin.round()}°C prevista para ${city.name}.'));
    }

    // UV muito alto.
    if (day.uvMax >= 8) {
      alerts.add(_simple(AlertType.uvHigh,
          day.uvMax >= 11 ? AlertSeverity.perigo : AlertSeverity.alerta,
          date, city.name,
          'Índice UV ${day.uvMax >= 11 ? 'extremo' : 'muito alto'}',
          '${_dayLabel(date)}: UV máximo de ${day.uvMax.round()} em ${city.name}. Evite exposição entre 10h e 16h.'));
    }
  }

  // Baixa umidade (próximas 48h).
  final humidityLows = bundle.upcomingHours
      .take(48)
      .where((h) => h.humidity > 0)
      .map((h) => h.humidity);
  if (humidityLows.isNotEmpty) {
    final minHumidity = humidityLows.reduce((a, b) => a < b ? a : b);
    final severity = _thresholdLow(minHumidity, _kHumidity, reverse: true);
    if (severity != null) {
      alerts.add(WeatherAlert(
        type: AlertType.lowHumidity,
        severity: severity,
        date: DateTime(now.year, now.month, now.day),
        cityName: city.name,
        title: 'Umidade muito baixa',
        description:
            'Próximas 48h: umidade mínima de ${minHumidity.round()}% em ${city.name}. Risco elevado de desidratação e incêndios.',
        actions: _actions[AlertType.lowHumidity]!,
      ));
    }
  }

  // Nevoeiro com visibilidade < 1 km entre 04h e 10h.
  final fogHours = bundle.upcomingHours.take(48).where((h) =>
      h.time.hour >= 4 &&
      h.time.hour <= 10 &&
      h.visibility < 1000 &&
      isFog(h.weatherCode));
  if (fogHours.isNotEmpty) {
    final first = fogHours.first;
    alerts.add(WeatherAlert(
      type: AlertType.fog,
      severity: AlertSeverity.atencao,
      date: DateTime(first.time.year, first.time.month, first.time.day),
      hour: first.time,
      cityName: city.name,
      title: 'Nevoeiro na madrugada/manhã',
      description:
          'Visibilidade abaixo de 1 km prevista por volta das ${first.time.hour.toString().padLeft(2, '0')}h. Atenção no trânsito e à navegação no Vale.',
      actions: _actions[AlertType.fog]!,
    ));
  }

  alerts.sort(_bySeverityThenDate);
  return _dedupe(alerts);
}

// ── Varredura regional (agregado por tipo + dia) ───────────────────

List<RegionAlertGroup> evaluateRegion(RegionSnapshot snapshot) {
  final perCity = <WeatherAlert>[];
  for (final rc in snapshot.cities) {
    for (final day in rc.days.take(3)) {
      final date = day.date;
      if (isThunderstorm(day.weatherCode)) {
        final hail = isHail(day.weatherCode);
        perCity.add(_region(hail ? AlertType.hail : AlertType.thunderstorm,
            hail ? AlertSeverity.perigo : AlertSeverity.alerta,
            date, rc.city,
            hail ? 'Trovoada com granizo prevista' : 'Trovoada prevista',
            'Código WMO ${day.weatherCode} no modelo.'));
      }
      if (isFreezingRain(day.weatherCode)) {
        perCity.add(_region(AlertType.freezingRain, AlertSeverity.alerta, date, rc.city,
            'Chuva congelante prevista', 'Precipitação congelada no modelo.'));
      }
      if (isSnow(day.weatherCode)) {
        perCity.add(_region(AlertType.snow, AlertSeverity.alerta, date, rc.city,
            'Neve prevista', 'Neve indicada no modelo (raro na região).'));
      }
      final rainSeverity = _threshold(day.precipSum, _kRainDay);
      if (rainSeverity != null) {
        perCity.add(_region(AlertType.heavyRain, rainSeverity, date, rc.city,
            'Chuva intensa',
            'Acumulado previsto de ${day.precipSum.toStringAsFixed(0)} mm.'));
      }
      final gustSeverity = _threshold(day.gustMax, _kGust);
      if (gustSeverity != null) {
        perCity.add(_region(AlertType.windGusts, gustSeverity, date, rc.city,
            'Rajadas de vento',
            'Rajadas de até ${day.gustMax.round()} km/h.'));
      }
      var heatSeverity = _thresholdLow(day.tMax, _kHeatMax);
      if (heatSeverity != null && day.apparentMax >= 38) {
        heatSeverity = AlertSeverity.values[heatSeverity.rank + 1];
      }
      if (heatSeverity != null) {
        perCity.add(_region(AlertType.heat, heatSeverity, date, rc.city,
            'Calor intenso', 'Máxima de ${day.tMax.round()}°C.'));
      }
      final coldSeverity = _thresholdLow(day.tMin, _kColdMin, reverse: true);
      if (coldSeverity != null) {
        perCity.add(_region(AlertType.cold, coldSeverity, date, rc.city,
            day.tMin <= 0 ? 'Frio intenso / geada' : 'Frio intenso',
            'Mínima de ${day.tMin.round()}°C.'));
      }
      if (day.uvMax >= 8) {
        perCity.add(_region(AlertType.uvHigh,
            day.uvMax >= 11 ? AlertSeverity.perigo : AlertSeverity.alerta,
            date, rc.city, 'Índice UV muito alto',
            'UV máximo de ${day.uvMax.round()}.'));
      }
    }
  }

  final buckets = <String, List<WeatherAlert>>{};
  for (final a in perCity) {
    final key = '${a.type.name}|${a.date.year}-${a.date.month}-${a.date.day}';
    buckets.putIfAbsent(key, () => []).add(a);
  }

  final groups = <RegionAlertGroup>[];
  for (final bucket in buckets.values) {
    final first = bucket.first;
    final severity = bucket
        .map((a) => a.severity)
        .reduce((a, b) => a.rank >= b.rank ? a : b);
    final cities = bucket
        .map((a) =>
            allCities.firstWhere((c) => c.name == a.cityName, orElse: () => allCities.first))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    groups.add(RegionAlertGroup(
      type: first.type,
      date: first.date,
      severity: severity,
      title: first.title,
      description:
          '${_dayLabel(first.date)}: condição prevista em ${cities.length} ${cities.length == 1 ? 'cidade' : 'cidades'} da cobertura (${first.description.replaceFirst(RegExp(r'^.*?:\s*'), '')})',
      actions: _actions[first.type]!,
      cities: cities,
    ));
  }

  groups.sort((a, b) {
    final r = b.severity.rank.compareTo(a.severity.rank);
    if (r != 0) return r;
    final c = b.cities.length.compareTo(a.cities.length);
    if (c != 0) return c;
    return a.date.compareTo(b.date);
  });
  return groups;
}

// ── Regras e utilidades internas ────────────────────────────────────

// Limites [atenção, alerta, perigo] para limiares "quanto maior, pior".
const List<double> _kRainDay = [20, 45, 70]; // mm/dia
const List<double> _kRainHour = [5, 15, 30]; // mm/h
const List<double> _kGust = [50, 70, 90]; // km/h
const List<double> _kHeatMax = [33, 36, 39]; // °C (tMax)
// Limiares reversos (quanto menor, pior) em [perigo, alerta, atenção]:
const List<double> _kColdMin = [0, 2, 5]; // °C (tMin)
const List<double> _kHumidity = [12, 15, 20]; // % (min)

AlertSeverity? _threshold(double value, List<double> t) {
  if (value >= t[2]) return AlertSeverity.perigo;
  if (value >= t[1]) return AlertSeverity.alerta;
  if (value >= t[0]) return AlertSeverity.atencao;
  return null;
}

AlertSeverity? _thresholdLow(double value, List<double> t,
    {bool reverse = false}) {
  if (!reverse) return _threshold(value, t);
  // t = [perigo, alerta, atencao]
  if (value <= t[0]) return AlertSeverity.perigo;
  if (value <= t[1]) return AlertSeverity.alerta;
  if (value <= t[2]) return AlertSeverity.atencao;
  return null;
}

WeatherAlert _simple(AlertType type, AlertSeverity severity, DateTime date,
    String cityName, String title, String description) =>
    WeatherAlert(
      type: type,
      severity: severity,
      date: date,
      cityName: cityName,
      title: title,
      description: description,
      actions: _actions[type]!,
    );

WeatherAlert _region(AlertType type, AlertSeverity severity, DateTime date,
    City city, String title, String description) =>
    WeatherAlert(
      type: type,
      severity: severity,
      date: date,
      cityName: city.name,
      title: title,
      description: description,
      actions: _actions[type]!,
    );

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

int _bySeverityThenDate(WeatherAlert a, WeatherAlert b) {
  final r = b.severity.rank.compareTo(a.severity.rank);
  if (r != 0) return r;
  return a.date.compareTo(b.date);
}

List<WeatherAlert> _dedupe(List<WeatherAlert> alerts) {
  final seen = <String>{};
  final out = <WeatherAlert>[];
  for (final a in alerts) {
    final key = '${a.type.name}|${a.date.year}-${a.date.month}-${a.date.day}';
    if (seen.add(key)) out.add(a);
  }
  return out;
}

const _weekdays = [
  'segunda-feira', 'terça-feira', 'quarta-feira', 'quinta-feira',
  'sexta-feira', 'sábado', 'domingo',
];

String _dayLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(d.year, d.month, d.day);
  final diff = target.difference(today).inDays;
  final dd = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  if (diff == 0) return 'Hoje ($dd)';
  if (diff == 1) return 'Amanhã ($dd)';
  final weekday = _weekdays[d.weekday - 1];
  return '${weekday[0].toUpperCase()}${weekday.substring(1)} ($dd)';
}

const Map<AlertType, List<String>> _actions = {
  AlertType.thunderstorm: [
    'Evite áreas abertas, árvores e estruturas metálicas durante a tempestade',
    'Desligue aparelhos eletrônicos da tomada ao ouvir trovões',
    'Acompanhe o radar no app e os avisos da Defesa Civil e do INMET',
  ],
  AlertType.hail: [
    'Proteja veículos e animais; granizo pode causar danos em minutos',
    'Não saia de casa durante o temporal; espere a célula passar',
    'Risco de destelhamento e queda de galhos — redobre a atenção',
  ],
  AlertType.freezingRain: [
    'Piso escorregadio: dirija devagar e aumente a distância de segurança',
    'Cubra plantas sensíveis à geada na madrugada',
  ],
  AlertType.heavyRain: [
    'Risco de alagamentos: evite áreas baixas e passagens sob pontes',
    'Não atravesse ruas ou pontilhões com água corrente',
    'Verifique calhas e ralos; sinalize pontos de alagamento recorrentes',
  ],
  AlertType.windGusts: [
    'Prenda objetos soltos em sacadas, varandas e telhados',
    'Cuidado com queda de árvores e fiação — evite estacionar sob árvores',
    'Obras e andaimes devem ser verificados antes das rajadas',
  ],
  AlertType.heat: [
    'Beba água com frequência; evite exercícios entre 10h e 16h',
    'Atenção redobrada com crianças, idosos e animais de estimação',
    'Use roupas leves e protetor solar',
  ],
  AlertType.cold: [
    'Proteja plantas e tubulações expostas; geada danifica hortaliças',
    'Verifique cobertores de animais e pessoas em situação de rua',
    'Ar frio e seco: mantenha hidratação mesmo sem sede',
  ],
  AlertType.lowHumidity: [
    'Hidrate-se com frequência e evite esforço físico ao sol',
    'Umedeça ambientes e não deixe fósforos ao alcance de crianças',
    'Risco de queimadas: não faça fogueiras nem descarte bitucas',
  ],
  AlertType.uvHigh: [
    'Use FPS 30+, chapéu e óculos escuros das 10h às 16h',
    'Prefira sombra e roupas de proteção neste período',
    'Reaplique o protetor a cada 2 horas se estiver ao ar livre',
  ],
  AlertType.fog: [
    'Dirija com faróis baixos acesos e velocidade reduzida',
    'Aumente a distância do veículo à frente',
    'Evite ultrapassagens até a visibilidade melhorar',
  ],
  AlertType.snow: [
    'Condição raríssima na região: acompanhe os canais oficiais',
    'Vias podem congelar na madrugada — evite viagens desnecessárias',
  ],
};
