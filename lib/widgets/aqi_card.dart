import 'package:material_ui/material_ui.dart';

import '../models/weather.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Cartão de qualidade do ar (US AQI/EPA + poluentes PM2.5, PM10 e O₃).
class AirQualityCard extends StatelessWidget {
  const AirQualityCard({super.key, required this.airQuality});

  final AirQuality? airQuality;

  @override
  Widget build(BuildContext context) {
    final cl = context.cl;
    final aq = airQuality;

    if (aq == null) {
      return GlassCard(
        child: Row(
          children: [
            Icon(Icons.air_rounded, color: cl.textTertiary, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Qualidade do ar indisponível para esta cidade no momento.',
                style: TextStyle(color: cl.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    final category = aqiCategory(aq.usAqi);
    final categoryColor = Color(category.colorValue);
    final position = (aq.usAqi / 500).clamp(0.0, 1.0);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.air_rounded, color: AppColors.sky, size: 20),
              const SizedBox(width: 8),
              Text(
                'Qualidade do ar',
                style: TextStyle(
                  color: cl.textPrimary,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  category.label.toUpperCase(),
                  style: TextStyle(
                    color: categoryColor.computeLuminance() > 0.45
                        ? const Color(0xFF2B1A00)
                        : Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${aq.usAqi.round()}',
                style: TextStyle(
                  color: cl.textPrimary,
                  fontFamily: 'Poppins',
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'US AQI\nEPA',
                style: TextStyle(
                  color: cl.textTertiary,
                  fontSize: 10,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF3DDC97),
                      Color(0xFFFFE066),
                      Color(0xFFFFB545),
                      Color(0xFFFF5A5A),
                      Color(0xFFB388FF),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: position * 260,
                top: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: cl.textPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(color: cl.sheet, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Color(0x40000000), blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Boa',
                  style: TextStyle(color: cl.textTertiary, fontSize: 9.5)),
              Text('Perigosa',
                  style: TextStyle(color: cl.textTertiary, fontSize: 9.5)),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: cl.dividerFaint),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _pollutant(context, 'PM2.5', aq.pm25),
              _pollutant(context, 'PM10', aq.pm10),
              _pollutant(context, 'O₃', aq.ozone),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pollutant(BuildContext context, String label, double ug) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(label,
              style: TextStyle(
                  color: context.cl.textSecondary, fontSize: 11)),
        ),
        Text(
          ug.toStringAsFixed(1),
          style: TextStyle(
            color: context.cl.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 3),
        Text('µg/m³',
            style: TextStyle(color: context.cl.textTertiary, fontSize: 9.5)),
      ],
    );
  }
}
