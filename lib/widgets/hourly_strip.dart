import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import '../models/weather.dart';
import '../utils/weather_codes.dart';

/// Faixa horizontal com a previsão hora a hora (24h).
class HourlyStrip extends StatelessWidget {
  const HourlyStrip({super.key, required this.hours});

  final List<HourPoint> hours;

  @override
  Widget build(BuildContext context) {
    final visible = hours.take(24).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Próximas 24 horas'),
        const SizedBox(height: 10),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visible.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final h = visible[i];
              final info = weatherInfo(h.weatherCode, isDay: h.time.hour >= 6 && h.time.hour < 19);
              final isNow = i == 0;
              return Container(
                width: 62,
                decoration: BoxDecoration(
                  color: isNow
                      ? AppColors.amber.withValues(alpha: 0.12)
                      : context.cl.fillFaint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isNow
                        ? AppColors.amber.withValues(alpha: 0.5)
                        : context.cl.hairline,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isNow ? 'Agora' : '${h.time.hour.toString().padLeft(2, '0')}h',
                      style: TextStyle(
                        color: isNow ? context.cl.sunInk : context.cl.textSecondary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(info.icon, size: 20, color: weatherIconColor(h.weatherCode)),
                    Text(
                      '${h.temperature.round()}°',
                      style: TextStyle(
                        color: context.cl.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(
                      height: 14,
                      child: h.precipProbability >= 15
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.water_drop,
                                    size: 9, color: AppColors.cyan),
                                const SizedBox(width: 2),
                                Text(
                                  '${h.precipProbability.round()}%',
                                  style: const TextStyle(
                                    color: AppColors.cyan,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
