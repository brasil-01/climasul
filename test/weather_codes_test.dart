import 'package:flutter_test/flutter_test.dart';
import 'package:clima_sul/utils/weather_codes.dart';

void main() {
  test('código 0 é céu limpo com ícone diurno', () {
    final info = weatherInfo(0, isDay: true);
    expect(info.description, 'Céu limpo');
  });

  test('trovoadas são detectadas corretamente', () {
    expect(isThunderstorm(95), isTrue);
    expect(isThunderstorm(96), isTrue);
    expect(isThunderstorm(99), isTrue);
    expect(isThunderstorm(61), isFalse);
  });

  test('granizo apenas em 96 e 99', () {
    expect(isHail(96), isTrue);
    expect(isHail(99), isTrue);
    expect(isHail(95), isFalse);
  });

  test('neve cobre 71-77 e 85-86', () {
    expect(isSnow(71), isTrue);
    expect(isSnow(75), isTrue);
    expect(isSnow(85), isTrue);
    expect(isSnow(82), isFalse);
  });

  test('chuva congelante cobre 56-57 e 66-67', () {
    expect(isFreezingRain(56), isTrue);
    expect(isFreezingRain(66), isTrue);
    expect(isFreezingRain(67), isTrue);
    expect(isFreezingRain(61), isFalse);
  });

  test('nevoeiro é 45 e 48', () {
    expect(isFog(45), isTrue);
    expect(isFog(48), isTrue);
    expect(isFog(3), isFalse);
  });

  test('código desconhecido tem descrição de fallback', () {
    expect(weatherInfo(1234).description, 'Condição desconhecida');
  });
}
