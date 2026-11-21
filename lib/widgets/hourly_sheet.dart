import 'package:material_ui/material_ui.dart';

import '../models/weather.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/weather_codes.dart';

/// Folha inferior com a tabela hora a hora (temperatura, chuva e vento).
class HourlyForecastSheet extends StatelessWidget {
  const HourlyForecastSheet({super.key, required this.hours, required this.cityName});

  final List<HourPoint> hours;
  final String cityName;

  static Future<void> show(
    BuildContext context, {
    required List<HourPoint> hours,
    required String cityName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HourlyForecastSheet(hours: hours, cityName: cityName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = hours.take(24).toList();
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.cl.sheet,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          border: Border(top: BorderSide(color: context.cl.hairline)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: context.cl.handle,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Próximas horas',
                    style: TextStyle(
                      color: context.cl.textPrimary,
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '· $cityName',
                    style: TextStyle(
                        color: context.cl.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  SizedBox(width: 52, child: _Head('HORA')),
                  Expanded(child: _Head('CONDIÇÃO')),
                  SizedBox(width: 44, child: _Head('TEMP', align: TextAlign.right)),
                  SizedBox(width: 52, child: _Head('CHUVA', align: TextAlign.right)),
                  SizedBox(width: 58, child: _Head('VENTO', align: TextAlign.right)),
                ],
              ),
            ),
            Divider(height: 14, color: context.cl.dividerFaint),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                itemCount: visible.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 12, color: context.cl.dividerFaint),
                itemBuilder: (context, i) {
                  final h = visible[i];
                  final isDay = h.time.hour >= 6 && h.time.hour < 19;
                  final info = weatherInfo(h.weatherCode, isDay: isDay);
                  final isNow = i == 0;
                  return Row(
                    children: [
                      SizedBox(
                        width: 52,
                        child: Text(
                          isNow ? 'Agora' : formatHour(h.time),
                          style: TextStyle(
                            color: isNow ? AppColors.sun : context.cl.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(info.icon,
                                size: 19,
                                color: weatherIconColor(h.weatherCode)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                info.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.cl.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(
                          '${h.temperature.round()}°',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: context.cl.textPrimary,
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 52,
                        child: Text(
                          h.precipProbability >= 10
                              ? '${h.precipProbability.round()}%'
                              : '—',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: h.precipProbability >= 40
                                ? AppColors.sky
                                : context.cl.textTertiary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 58,
                        child: Text(
                          '${h.windSpeed.round()} km/h',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: context.cl.textSecondary, fontSize: 11.5),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Head extends StatelessWidget {
  const _Head(this.text, {this.align = TextAlign.left});
  final String text;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        color: context.cl.textTertiary,
        fontSize: 8.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
}
