import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../models/weather.dart';
import '../theme/app_theme.dart';

/// Gráfico de linha (área) com temperatura e sensação térmica nas próximas 24h.
class TemperatureChart extends StatelessWidget {
  const TemperatureChart({super.key, required this.hours});

  final List<HourPoint> hours;

  @override
  Widget build(BuildContext context) {
    final visible = hours.take(24).toList();
    if (visible.isEmpty) {
      return const SizedBox(height: 130, child: Center(child: Text('Sem dados')));
    }
    final temps = visible.map((h) => h.temperature).toList();
    final minT = temps.reduce(math.min);
    final maxT = temps.reduce(math.max);
    final minY = (minT - 2).floorToDouble();
    final maxY = (maxT + 2).ceilToDouble();

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: math.max(2, ((maxY - minY) / 3).roundToDouble()),
            getDrawingHorizontalLine: (_) => FlLine(
              color: context.cl.fillFaint,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, _) => Text(
                  '${value.round()}°',
                  style: TextStyle(
                    color: context.cl.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 6,
                reservedSize: 20,
                getTitlesWidget: (value, _) {
                  final i = value.round();
                  if (i < 0 || i >= visible.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${visible[i].time.hour.toString().padLeft(2, '0')}h',
                      style: TextStyle(
                        color: context.cl.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < visible.length; i++)
                  FlSpot(i.toDouble(), visible[i].temperature),
              ],
              isCurved: true,
              curveSmoothness: 0.35,
              gradient: const LinearGradient(
                colors: [AppColors.orange, AppColors.amber],
              ),
              barWidth: 2.6,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.amber.withValues(alpha: 0.30),
                    AppColors.amber.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            LineChartBarData(
              spots: [
                for (var i = 0; i < visible.length; i++)
                  FlSpot(i.toDouble(), visible[i].apparentTemperature),
              ],
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.cyan,
              barWidth: 1.6,
              dashArray: const [5, 4],
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => context.cl.tooltipBg,
              getTooltipItems: (touched) => touched
                  .map(
                    (s) => LineTooltipItem(
                      s.barIndex == 0
                          ? '${s.y.toStringAsFixed(0)}°C'
                          : 'Sensação ${s.y.toStringAsFixed(0)}°C',
                      TextStyle(
                        color:
                            s.barIndex == 0 ? AppColors.amber : AppColors.cyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Barras de precipitação (mm) por hora.
class PrecipChart extends StatelessWidget {
  const PrecipChart({super.key, required this.hours});

  final List<HourPoint> hours;

  @override
  Widget build(BuildContext context) {
    final visible = hours.take(24).toList();
    final maxMm = visible.fold<double>(0, (a, h) => math.max(a, h.precipitation));
    final maxY = math.max(2.0, (maxMm * 1.3)).ceilToDouble();

    return SizedBox(
      height: 110,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 6,
                reservedSize: 20,
                getTitlesWidget: (value, _) {
                  final i = value.round();
                  if (i < 0 || i >= visible.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${visible[i].time.hour.toString().padLeft(2, '0')}h',
                      style: TextStyle(
                        color: context.cl.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => context.cl.tooltipBg,
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)} mm',
                const TextStyle(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < visible.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: math.max(0.15, visible[i].precipitation),
                    width: 7,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0x665BC8FF),
                        AppColors.cyan,
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
