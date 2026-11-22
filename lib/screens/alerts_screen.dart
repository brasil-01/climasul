import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/alert_card.dart';

/// Central de alertas: avisos OFICIAIS do INMET (prevalecem) e a previsão
/// AUTOMÁTICA do ClimaSul (regras sobre o modelo Open-Meteo).
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(selectedCityProvider);
    final cityAlerts = ref.watch(cityAlertsProvider(city.id));
    final regionGroups = ref.watch(regionAlertsProvider);
    final regionAsync = ref.watch(regionSnapshotProvider);
    final officialAsync = ref.watch(inmetOfficialProvider);
    final hasOfficial = officialAsync.maybeWhen(
      data: (feed) => feed.alerts.isNotEmpty,
      orElse: () => false,
    );

    return RefreshIndicator(
      color: AppColors.sun,
      backgroundColor: context.cl.surfaceAlt,
      onRefresh: () async {
        ref.invalidate(weatherBundleProvider(city.id));
        ref.invalidate(regionSnapshotProvider);
        ref.invalidate(inmetOfficialProvider);
        try {
          await ref.read(inmetOfficialProvider.future);
        } catch (_) {}
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
        children: [
          // ── Cabeçalho ─────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.sun.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded,
                    color: AppColors.sun, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alertas',
                      style: TextStyle(
                        color: context.cl.textPrimary,
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'INMET (oficial) + previsão automática · 72h',
                      style: TextStyle(
                          color: context.cl.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Selo de fonte ───────────────────────────────────────
          GlassCard(
            radius: 14,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded,
                    size: 17, color: AppColors.sky),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Avisos oficiais do INMET prevalecem e aparecem destacados. '
                    'A previsão automática é gerada por regras sobre o modelo '
                    'Open-Meteo e nunca substitui os boletins oficiais.',
                    style: TextStyle(
                      color: context.cl.textSecondary.withValues(alpha: 0.95),
                      fontSize: 10.5,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── OFICIAL · INMET ──────────────────────────────────────
          SectionHeader('Oficial · INMET',
              trailing: officialAsync.maybeWhen(
                data: (feed) => Text(
                  '${feed.alerts.length} ${feed.alerts.length == 1 ? 'aviso' : 'avisos'}',
                  style: TextStyle(
                      color: context.cl.textTertiary, fontSize: 10.5),
                ),
                orElse: () => const SizedBox.shrink(),
              )),
          const SizedBox(height: 10),
          ..._officialSection(context, officialAsync),
          const SizedBox(height: 20),

          // ── PREVISÃO AUTOMÁTICA · sua cidade ────────────────────
          SectionHeader('Automático · ${city.name}'),
          const SizedBox(height: 10),
          if (!hasOfficial && cityAlerts.isEmpty)
            _AllClearCard(
              title: 'Sem alertas em ${city.name}',
              subtitle:
                  'Nenhum aviso do INMET em vigor e nenhuma condição severa prevista nos próximos 3 dias.',
            )
          else if (cityAlerts.isEmpty)
            _AllClearCard(
              title: 'Tranquilo em ${city.name}',
              subtitle:
                  'Nenhum alerta automático para os próximos 3 dias. Os avisos oficiais do INMET aparecem acima.',
            )
          else
            ...cityAlerts.map((a) => AlertCard(alert: a)),
          const SizedBox(height: 18),

          // ── PREVISÃO AUTOMÁTICA · região ────────────────────────
          SectionHeader(
            'Automático · Região · 72h',
            trailing: regionAsync.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.sky),
                  )
                : Text(
                    '${regionGroups.length} ${regionGroups.length == 1 ? 'tipo' : 'tipos'}',
                    style: TextStyle(
                        color: context.cl.textTertiary, fontSize: 10.5),
                  ),
          ),
          const SizedBox(height: 10),
          if (regionAsync.hasError && regionGroups.isEmpty)
            _AllClearCard(
              title: 'Varredura indisponível',
              subtitle:
                  'A varredura das 33 cidades falhou após 3 tentativas. Verifique a conexão e puxe para atualizar.',
              positive: false,
            )
          else if (regionGroups.isEmpty)
            _AllClearCard(
              title: 'Panorama regional tranquilo',
              subtitle:
                  'Nenhuma condição severa agregada nas 33 cidades monitoradas nos próximos 3 dias.',
            )
          else
            ...regionGroups.map(
              (g) => RegionGroupCard(
                group: g,
                onCityTap: (cityId) {
                  ref.read(selectedCityIdProvider.notifier).select(cityId);
                  ref.read(tabIndexProvider.notifier).state = 0;
                },
              ),
            ),
          const SizedBox(height: 18),

          // ── Como funciona ───────────────────────────────────────
          Theme(
            data: Theme.of(context)
                .copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 4),
              childrenPadding:
                  const EdgeInsets.only(left: 4, right: 4, bottom: 8),
              leading: Icon(Icons.science_outlined,
                  color: context.cl.textSecondary, size: 20),
              collapsedIconColor: context.cl.textSecondary,
              iconColor: AppColors.sun,
              title: Text(
                'Como funcionam os dois tipos de alerta',
                style: TextStyle(
                  color: context.cl.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              children: [
                Text(
                  'OFICIAL · INMET — avisos emitidos pelo Instituto Nacional de '
                  'Meteorologia para o RS, com níveis amarelo (Perigo Potencial), '
                  'laranja (Perigo) e vermelho (Grande Perigo). Válidos para municípios '
                  'específicos (geocodes IBGE). Sempre verifique inmet.gov.br.\n\n'
                  'AUTOMÁTICO · ClimaSul — regras determinísticas sobre o modelo do '
                  'Open-Meteo para as 33 cidades da cobertura:\n'
                  '• Trovoada e granizo — códigos WMO 95/96/99\n'
                  '• Chuva intensa — ≥ 20/45/70 mm por dia ou ≥ 5/15/30 mm por hora\n'
                  '• Rajadas de vento — ≥ 50/70/90 km/h\n'
                  '• Calor — máxima ≥ 33/36/39 °C · Frio/geada — mínima ≤ 5/2/0 °C\n'
                  '• Umidade ≤ 20/15/12% · UV ≥ 8 ou 11\n\n'
                  'Níveis: ATENÇÃO < ALERTA < PERIGO. Em emergência, ligue 199 '
                  '(Defesa Civil) ou 190 (Brigada Militar).',
                  style: TextStyle(
                    color: context.cl.textSecondary,
                    fontSize: 11,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Seção INMET: loading / erro / vazio / cards oficiais.
  List<Widget> _officialSection(BuildContext context, AsyncValue<dynamic> officialAsync) {
    return officialAsync.when(
      loading: () => [
        Padding(
          padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.sun),
              ),
              SizedBox(width: 12),
              Text(
                'Consultando avisos do INMET…',
                style: TextStyle(
                    color: context.cl.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
      error: (_, _) => [
        GlassCard(
          radius: 14,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.cloud_off_rounded, color: context.cl.textTertiary, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Feed oficial do INMET indisponível agora — exibindo apenas a previsão automática.',
                  style: TextStyle(
                      color: context.cl.textSecondary, fontSize: 11, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
      data: (feed) {
        if (feed.alerts.isEmpty) {
          return const [
            _AllClearCard(
              title: 'Nenhum aviso do INMET para o RS',
              subtitle: 'O INMET não emitiu avisos de perigo/potencial para o Rio Grande do Sul neste momento.',
            ),
          ];
        }
        return [
          for (final alert in feed.alerts) OfficialAlertCard(alert: alert),
        ];
      },
    );
  }
}

class _AllClearCard extends StatelessWidget {
  const _AllClearCard({
    required this.title,
    required this.subtitle,
    this.positive = true,
  });

  final String title;
  final String subtitle;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.green : AppColors.sky;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              positive ? Icons.verified_rounded : Icons.cloud_off_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.cl.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.cl.textSecondary,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
