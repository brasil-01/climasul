/// Utilitários de formatação pt-BR.
library;

import 'package:intl/intl.dart';

final NumberFormat _oneDecimal = NumberFormat('0.0', 'pt_BR');
final NumberFormat _noDecimal = NumberFormat('0', 'pt_BR');
final DateFormat _hourFormat = DateFormat('HH:mm');
final DateFormat _dayMonth = DateFormat('dd/MM');
final DateFormat _weekdayShort = DateFormat('EEE', 'pt_BR');

String formatTemp(double? v) => v == null ? '—' : '${v.round()}°';

String formatKmh(double? v) => v == null ? '—' : '${_noDecimal.format(v)} km/h';

String formatMm(double? v) =>
    v == null ? '—' : '${_oneDecimal.format(v)} mm';

String formatPercent(double? v) =>
    v == null ? '—' : '${_noDecimal.format(v)}%';

String formatHour(DateTime t) => _hourFormat.format(t);

String formatDayMonth(DateTime t) => _dayMonth.format(t);

/// 'SÁB', 'SEG'... sem ponto final, maiúsculo.
String weekdayAbbrev(DateTime t) {
  final s = _weekdayShort.format(t).replaceAll('.', '').trim().toUpperCase();
  return s.length > 3 ? s.substring(0, 3) : s;
}

/// Dia da semana por extenso capitalizado: 'Sábado'.
String weekdayLong(DateTime t) {
  final s = DateFormat('EEEE', 'pt_BR').format(t);
  return s[0].toUpperCase() + s.substring(1);
}

/// Horas atrás / em instantes, pt-BR.
String timeAgo(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return 'agora mesmo';
  if (diff.inMinutes == 1) return 'há 1 min';
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours == 1) return 'há 1 h';
  return 'há ${diff.inHours} h';
}

/// Direção cardinal em pt (16 pontos): 135° → 'SE'.
String compass(double? degrees) {
  if (degrees == null) return '—';
  const points = [
    'N', 'NNE', 'NE', 'ENE', 'L', 'ESE', 'SE', 'SSE',
    'S', 'SSO', 'SO', 'OSO', 'O', 'ONO', 'NO', 'NNO',
  ];
  final index = ((degrees + 11.25) / 22.5).floor() % 16;
  return points[index];
}

/// Categoria e cor do índice UV (escala OMS).
class UvCategory {
  const UvCategory(this.label, this.colorValue);
  final String label;
  final int colorValue;
}

UvCategory uvCategory(double? uv) {
  if (uv == null) return const UvCategory('—', 0xFF93A7CC);
  if (uv < 3) return const UvCategory('Baixo', 0xFF3DDC97);
  if (uv < 6) return const UvCategory('Moderado', 0xFFFFE066);
  if (uv < 8) return const UvCategory('Alto', 0xFFFF8A3D);
  if (uv < 11) return const UvCategory('Muito alto', 0xFFFF5A5A);
  return const UvCategory('Extremo', 0xFFB388FF);
}

/// Categoria US AQI (EPA), rótulos pt-BR.
class AqiCategory {
  const AqiCategory(this.label, this.colorValue);
  final String label;
  final int colorValue;
}

AqiCategory aqiCategory(double? aqi) {
  if (aqi == null) return const AqiCategory('—', 0xFF93A7CC);
  if (aqi <= 50) return const AqiCategory('Boa', 0xFF3DDC97);
  if (aqi <= 100) return const AqiCategory('Moderada', 0xFFFFE066);
  if (aqi <= 150) return const AqiCategory('Ruim p/ grupos sensíveis', 0xFFFFB545);
  if (aqi <= 200) return const AqiCategory('Insalubre', 0xFFFF5A5A);
  if (aqi <= 300) return const AqiCategory('Muito insalubre', 0xFFB388FF);
  return const AqiCategory('Perigosa', 0xFFFF7BAC);
}

/// Duração legível: '13h 42min'.
String formatDayLength(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  return '${h}h ${m.toString().padLeft(2, '0')}min';
}
