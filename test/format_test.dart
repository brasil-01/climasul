import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:clima_sul/utils/format.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  test('direção cardinal: 0° → N, 135° → SE, 270° → O', () {
    expect(compass(0), 'N');
    expect(compass(135), 'SE');
    expect(compass(270), 'O');
    expect(compass(null), '—');
  });

  test('categorias de UV seguem a escala da OMS', () {
    expect(uvCategory(1).label, 'Baixo');
    expect(uvCategory(4).label, 'Moderado');
    expect(uvCategory(10).label, 'Muito alto');
    expect(uvCategory(11).label, 'Extremo');
  });

  test('categorias de AQI seguem a EPA (US AQI)', () {
    expect(aqiCategory(30).label, 'Boa');
    expect(aqiCategory(75).label, 'Moderada');
    expect(aqiCategory(130).label, 'Ruim p/ grupos sensíveis');
    expect(aqiCategory(500).label, 'Perigosa');
  });

  test('sigla de dia da semana tem 3 letras em pt-BR', () {
    final d = DateTime(2026, 11, 21); // sábado
    expect(weekdayAbbrev(d), 'SÁB');
    expect(weekdayAbbrev(d).length, 3);
  });

  test('duração do dia formata como Nh MMmin', () {
    expect(formatDayLength(const Duration(hours: 13, minutes: 42)), '13h 42min');
  });

  test('formatação de temperatura usa ° simples', () {
    expect(formatTemp(28.4), '28°');
    expect(formatTemp(null), '—');
  });
}
