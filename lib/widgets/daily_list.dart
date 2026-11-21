import 'package:material_ui/material_ui.dart';

import '../models/weather.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/weather_codes.dart';

/// Lista de 8 dias com barra de amplitude térmica proporcional.
class DailyForecastList extends StatelessWidget {
  const DailyForecastList({super.key, required this.days});

  final List<DailyBrief> days;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    final weekMin = days.map((d) => d.tMin).reduce((a, b) => a < b ? a : b);
    final weekMax = days.map((d) => d.tMax).reduce((a, b) => a > b ? a : b);
    final span = (weekMax - weekMin).abs().clamp(1.0, double.infinity);

    return Column(
      children: [
        for (var i = 0; i < days.length; i++) ...[
          _DayRow(
            day: days[i],
            isToday: i == 0,
            weekMin: weekMin,
            span: span,
          ),
          if (i != days.length - 1)
            Divider(height: 18, color: context.cl.fillFaint),
        ],
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.isToday,
    required this.weekMin,
    required this.span,
  });

  final DailyBrief day;
  final bool isToday;
  final double weekMin;
  final double span;

  @override
  Widget build(BuildContext context) {
    final info = weatherInfo(day.weatherCode);
    final left = (day.tMin - weekMin) / span;
    final width = ((day.tMax - day.tMin) / span).clamp(0.06, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isToday ? 'HOJE' : weekdayAbbrev(day.date),
                style: TextStyle(
                  color: isToday ? context.cl.sunInk : context.cl.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                formatDayMonth(day.date),
                style: TextStyle(
                  color: context.cl.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Icon(info.icon, size: 22, color: weatherIconColor(day.weatherCode)),
        SizedBox(
          width: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (day.precipProbMax >= 15) ...[
                const Icon(Icons.water_drop, size: 9, color: AppColors.cyan),
                const SizedBox(width: 2),
                Text(
                  '${day.precipProbMax.round()}',
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(
          width: 30,
          child: Text(
            '${day.tMin.round()}°',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: context.cl.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 6,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final track = constraints.maxWidth;
                return Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.cl.fillFaint,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Positioned(
                      left: left * track,
                      width: (width * track).clamp(6.0, track),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF5BC8FF),
                              Color(0xFFFFCF7A),
                              Color(0xFFFF8A3D),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            '${day.tMax.round()}°',
            style: TextStyle(
              color: context.cl.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
