/// Mapeamento dos códigos WMO (Open-Meteo) para texto e ícone, em pt-BR.
library;

import 'package:material_ui/material_ui.dart';

class WeatherInfo {
  const WeatherInfo(this.description, this.icon);
  final String description;
  final IconData icon;
}

/// Descrição e ícone para um código WMO. [isDay] troca ícones de céu limpo/nublado
/// por variantes noturnas.
WeatherInfo weatherInfo(int code, {bool isDay = true}) {
  switch (code) {
    case 0:
      return WeatherInfo('Céu limpo', isDay ? Icons.wb_sunny : Icons.nights_stay);
    case 1:
      return WeatherInfo('Predominantemente limpo', isDay ? Icons.wb_sunny : Icons.nights_stay);
    case 2:
      return WeatherInfo('Parcialmente nublado', isDay ? Icons.wb_cloudy : Icons.nights_stay);
    case 3:
      return const WeatherInfo('Encoberto', Icons.cloud);
    case 45:
    case 48:
      return const WeatherInfo('Nevoeiro', Icons.foggy);
    case 51:
      return const WeatherInfo('Chuvisco fraco', Icons.grain);
    case 53:
      return const WeatherInfo('Chuvisco', Icons.grain);
    case 55:
      return const WeatherInfo('Chuvisco forte', Icons.grain);
    case 56:
    case 57:
      return const WeatherInfo('Chuvisco congelante', Icons.ac_unit);
    case 61:
      return const WeatherInfo('Chuva fraca', Icons.water_drop);
    case 63:
      return const WeatherInfo('Chuva moderada', Icons.water_drop);
    case 65:
      return const WeatherInfo('Chuva forte', Icons.water_drop);
    case 66:
    case 67:
      return const WeatherInfo('Chuva congelante', Icons.ac_unit);
    case 71:
      return const WeatherInfo('Neve fraca', Icons.ac_unit);
    case 73:
      return const WeatherInfo('Neve moderada', Icons.ac_unit);
    case 75:
      return const WeatherInfo('Neve forte', Icons.ac_unit);
    case 77:
      return const WeatherInfo('Grãos de neve', Icons.ac_unit);
    case 80:
      return const WeatherInfo('Pancadas de chuva fracas', Icons.water_drop);
    case 81:
      return const WeatherInfo('Pancadas de chuva', Icons.water_drop);
    case 82:
      return const WeatherInfo('Pancadas de chuva fortes', Icons.water_drop);
    case 85:
    case 86:
      return const WeatherInfo('Pancadas de neve', Icons.ac_unit);
    case 95:
      return const WeatherInfo('Trovoada', Icons.thunderstorm);
    case 96:
      return const WeatherInfo('Trovoada com granizo', Icons.thunderstorm);
    case 99:
      return const WeatherInfo('Trovoada forte com granizo', Icons.thunderstorm);
    default:
      return const WeatherInfo('Condição desconhecida', Icons.help_outline);
  }
}

/// Cor do ícone por família de código.
Color weatherIconColor(int code) {
  if (code <= 1) return const Color(0xFFFFC24B); // sol
  if (code == 2) return const Color(0xFFFFD98A);
  if (code == 3) return const Color(0xFFB9C6E4); // nublado
  if (code == 45 || code == 48) return const Color(0xFFB9C6E4); // nevoeiro
  if (code >= 95) return const Color(0xFFFF8A3D); // trovoada
  if (code >= 71 && code <= 86) return const Color(0xFFBEE3FF); // neve
  return const Color(0xFF5BC8FF); // chuva
}

bool isThunderstorm(int code) => code == 95 || code == 96 || code == 99;
bool isHail(int code) => code == 96 || code == 99;
bool isFreezingRain(int code) => code == 56 || code == 57 || code == 66 || code == 67;
bool isSnow(int code) =>
    (code >= 71 && code <= 77) || code == 85 || code == 86;
bool isFog(int code) => code == 45 || code == 48;
bool isRain(int code) =>
    (code >= 51 && code <= 67) || (code >= 80 && code <= 82);
