import 'package:material_ui/material_ui.dart';

import '../models/weather.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Arco do sol do dia: horário de nascer/pôr e fração do dia decorrida.
class SunArcCard extends StatelessWidget {
  const SunArcCard({super.key, required this.today});

  final DailyBrief? today;

  @override
  Widget build(BuildContext context) {
    final cl = context.cl;
    final brief = today;
    final sunrise = brief?.sunrise;
    final sunset = brief?.sunset;
    final now = DateTime.now();

    final double progress;
    final bool isDay;
    if (sunrise != null && sunset != null) {
      final total = sunset.difference(sunrise).inMinutes;
      final elapsed = now.difference(sunrise).inMinutes;
      progress = total <= 0 ? 0.0 : (elapsed / total).clamp(0.0, 1.0);
      isDay = now.isAfter(sunrise) && now.isBefore(sunset);
    } else {
      progress = 0.0;
      isDay = false;
    }

    final dayLength = (sunrise != null && sunset != null)
        ? formatDayLength(sunset.difference(sunrise))
        : '—';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader('Sol · hoje',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sun.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.sun.withValues(alpha: 0.45)),
                ),
                child: Text(
                  '$dayLength de sol',
                  style: const TextStyle(
                    color: AppColors.amber,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )),
          const SizedBox(height: 8),
          SizedBox(
            height: 96,
            child: CustomPaint(
              painter: _SunArcPainter(
                trackColor: cl.handle,
                progress: progress,
                isDay: isDay,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sunPoint(context, Icons.wb_sunny, 'Nascer',
                  sunrise == null ? '—' : formatHour(sunrise), AppColors.amber),
              Column(
                children: [
                  Icon(
                    isDay ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                    color: isDay ? AppColors.sun : cl.textSecondary,
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDay ? 'Sol acima do horizonte' : 'Sol abaixo do horizonte',
                    style: TextStyle(color: cl.textSecondary, fontSize: 9.5),
                  ),
                ],
              ),
              _sunPoint(context, Icons.nights_stay, 'Pôr',
                  sunset == null ? '—' : formatHour(sunset), AppColors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sunPoint(BuildContext context, IconData icon, String label, String time, Color tint) {
    return Column(
      children: [
        Icon(icon, size: 17, color: tint),
        const SizedBox(height: 3),
        Text(label.toUpperCase(),
            style: TextStyle(
                color: context.cl.textTertiary, fontSize: 8.5,
                fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        Text(time,
            style: TextStyle(
                color: context.cl.textPrimary, fontSize: 13,
                fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _SunArcPainter extends CustomPainter {
  const _SunArcPainter({
    required this.progress,
    required this.isDay,
    required this.trackColor,
  });

  final double progress;
  final bool isDay;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final padX = 14.0;
    final baseline = size.height - 6;
    final start = Offset(padX, baseline);
    final end = Offset(size.width - padX, baseline);
    final control = Offset(size.width / 2, -size.height * 0.85);

    final arc = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    // Arco completo (trilha).
    canvas.drawPath(
      arc,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Progresso âmbar até a posição atual do sol.
    final metric = arc.computeMetrics().first;
    final partial = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(
      partial,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.orange, AppColors.amber],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round,
    );

    // Sol na posição atual.
    if (progress > 0.001 && progress < 0.999) {
      final tangent = metric.getTangentForOffset(metric.length * progress);
      if (tangent != null) {
        final pos = tangent.position;
        canvas.drawCircle(
          pos,
          8,
          Paint()..color = AppColors.sun.withValues(alpha: 0.35),
        );
        canvas.drawCircle(
          pos,
          5,
          Paint()..color = AppColors.sun,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.isDay != isDay ||
      oldDelegate.trackColor != trackColor;
}
