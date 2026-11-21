import 'package:material_ui/material_ui.dart';

import '../services/alerts_engine.dart';
import '../services/inmet_official_service.dart';
import '../theme/app_theme.dart';

/// Cartão de aviso **oficial do INMET** — banner sólido no padrão amarelo/laranja/vermelho,
/// texto escuro no amarelo, para não ser confundido com a previsão automática.
class OfficialAlertCard extends StatelessWidget {
  const OfficialAlertCard({super.key, required this.alert, this.onCityTap});

  final OfficialInmetAlert alert;
  final ValueChanged<String>? onCityTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (alert.nivel) {
      1 => AppColors.sun,
      2 => AppColors.orange,
      _ => AppColors.red,
    };
    final onColor = alert.nivel == 1 ? const Color(0xFF332100) : Colors.white;
    final matched = alert.matchedCityIds.length;
    final total = 33;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration:
                      BoxDecoration(color: onColor.withValues(alpha: 0.18), shape: BoxShape.circle),
                  child: Icon(Icons.warning_amber_rounded, color: onColor, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'INMET · OFICIAL',
                            style: TextStyle(
                              color: onColor.withValues(alpha: 0.85),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: onColor.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              alert.futuro ? 'PREVISTO' : 'EM VIGOR',
                              style: TextStyle(
                                color: onColor,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${alert.evento} — ${alert.nivelLabel}',
                        style: TextStyle(
                          color: onColor,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: onColor.withValues(alpha: 0.25)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 13, color: onColor.withValues(alpha: 0.9)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _validityLabel(alert.inicio, alert.fim),
                    style: TextStyle(
                      color: onColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 13, color: onColor.withValues(alpha: 0.9)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    matched == 0
                        ? 'Aviso estadual para o RS (${alert.municipiosAfetados} municípios no país)'
                        : matched >= total
                            ? 'Atinge todas as $total cidades da cobertura ClimaSul'
                            : 'Atinge $matched ${matched == 1 ? 'cidade' : 'cidades'} da cobertura',
                    style: TextStyle(color: onColor, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.verified_rounded, size: 13, color: onColor.withValues(alpha: 0.9)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Fonte oficial: INMET · dados via radarmeteorologico.com.br',
                    style: TextStyle(
                      color: onColor.withValues(alpha: 0.9),
                      fontSize: 9.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _validityLabel(DateTime? start, DateTime? end) {
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    if (start != null && end != null) return 'Válido de ${fmt(start)} até ${fmt(end)}';
    if (end != null) return 'Válido até ${fmt(end)}';
    if (start != null) return 'Em vigor desde ${fmt(start)}';
    return 'Vigência conforme INMET';
  }
}

Color severityColor(AlertSeverity s) => switch (s) {
      AlertSeverity.atencao => AppColors.warn,
      AlertSeverity.alerta => AppColors.orange,
      AlertSeverity.perigo => AppColors.danger,
    };

IconData alertTypeIcon(AlertType t) => switch (t) {
      AlertType.thunderstorm => Icons.thunderstorm,
      AlertType.hail => Icons.grain,
      AlertType.freezingRain => Icons.ac_unit,
      AlertType.heavyRain => Icons.water_drop,
      AlertType.windGusts => Icons.air,
      AlertType.heat => Icons.device_thermostat,
      AlertType.cold => Icons.device_thermostat,
      AlertType.lowHumidity => Icons.opacity,
      AlertType.uvHigh => Icons.wb_sunny,
      AlertType.fog => Icons.foggy,
      AlertType.snow => Icons.ac_unit,
    };

/// Cartão de alerta individual (cidade selecionada).
class AlertCard extends StatelessWidget {
  const AlertCard({super.key, required this.alert});

  final WeatherAlert alert;

  @override
  Widget build(BuildContext context) {
    final color = severityColor(alert.severity);
    final hour = alert.hour;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.cl.cardFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.cl.hairline),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(18)),
              child: Container(width: 4, color: color),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(alertTypeIcon(alert.type),
                              size: 19, color: color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alert.title,
                                style: TextStyle(
                                  color: context.cl.textPrimary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                hour == null
                                    ? _dayLabel(alert.date)
                                    : '${_dayLabel(alert.date)} · por volta das ${hour.hour.toString().padLeft(2, '0')}h',
                                style: TextStyle(
                                    color: context.cl.textTertiary,
                                    fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                        _SeverityPill(label: alert.severity.label, color: color),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      alert.description,
                      style: TextStyle(
                        color: context.cl.textSecondary,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...alert.actions.map((a) => _ActionBullet(text: a, color: color)),
                    const SizedBox(height: 8),
                    _SourceLine(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartão agregado de alerta regional (N cidades no mesmo dia).
class RegionGroupCard extends StatelessWidget {
  const RegionGroupCard({
    super.key,
    required this.group,
    required this.onCityTap,
  });

  final RegionAlertGroup group;
  final ValueChanged<String> onCityTap;

  @override
  Widget build(BuildContext context) {
    final color = severityColor(group.severity);
    final shown = group.cities.take(9).toList();
    final remaining = group.cities.length - shown.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.cl.cardFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.cl.hairline),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(18)),
              child: Container(width: 4, color: color),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(alertTypeIcon(group.type),
                              size: 19, color: color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.title,
                                style: TextStyle(
                                  color: context.cl.textPrimary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${_dayLabel(group.date)} · ${group.cities.length} ${group.cities.length == 1 ? 'cidade' : 'cidades'}',
                                style: TextStyle(
                                    color: context.cl.textTertiary,
                                    fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                        _SeverityPill(label: group.severity.label, color: color),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      group.description,
                      style: TextStyle(
                        color: context.cl.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final city in shown)
                          ActionChip(
                            label: Text(city.name,
                                style: const TextStyle(fontSize: 10.5)),
                            labelStyle:
                                TextStyle(color: context.cl.textPrimary),
                            backgroundColor: context.cl.fillFaint,
                            side: BorderSide(color: context.cl.hairline),
                            padding: EdgeInsets.zero,
                            onPressed: () => onCityTap(city.id),
                          ),
                        if (remaining > 0)
                          Chip(
                            label: Text('+$remaining',
                                style: const TextStyle(fontSize: 10.5)),
                            labelStyle: TextStyle(
                                color: context.cl.textSecondary),
                            backgroundColor: Colors.transparent,
                            side: const BorderSide(color: Colors.transparent),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...group.actions
                        .take(2)
                        .map((a) => _ActionBullet(text: a, color: color)),
                    const SizedBox(height: 8),
                    _SourceLine(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeverityPill extends StatelessWidget {
  const _SeverityPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.computeLuminance() > 0.45 ? const Color(0xFF2B1A00) : Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ActionBullet extends StatelessWidget {
  const _ActionBullet({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 4,
              height: 4,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.cl.textSecondary,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.info_outline, size: 11, color: context.cl.textTertiary),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            'Previsão automática Open-Meteo — confirme no INMET / Defesa Civil (199) em emergência',
            style: TextStyle(color: context.cl.textTertiary, fontSize: 9.5),
          ),
        ),
      ],
    );
  }
}

String _dayLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diff = DateTime(d.year, d.month, d.day).difference(today).inDays;
  final dd =
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  if (diff == 0) return 'Hoje ($dd)';
  if (diff == 1) return 'Amanhã ($dd)';
  return dd;
}
