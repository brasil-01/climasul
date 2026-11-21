import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'cities_screen.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';

/// Aba "Mais": sobre a marca, opções, fontes de dados e compartilhar.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        // ── Cartão da marca ─────────────────────────────────────
        const SizedBox(height: 8),
        const Center(child: ClimaSulLogo(iconSize: 92, wordmarkSize: 38)),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Previsão do tempo com olhar regional para o Vale dos Sinos\ne a Grande Porto Alegre.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.cl.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ── Linhas de opções ─────────────────────────────────────
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _MoreRow(
                icon: Icons.location_city_rounded,
                tint: AppColors.sky,
                title: 'Todas as 33 cidades',
                subtitle: 'Buscar, favoritar e acompanhar',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      backgroundColor: context.cl.scaffold,
                      body: SkyBackground(child: CitiesScreen()),
                    ),
                  ),
                ),
              ),
              _divider(context),
              const _ThemeRow(),
              _divider(context),
              _MoreRow(
                icon: Icons.thermostat_rounded,
                tint: AppColors.orange,
                title: 'Unidades',
                subtitle: 'Sistema internacional',
                trailing: Text('°C · km/h',
                    style: TextStyle(
                        color: context.cl.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5)),
              ),
              _divider(context),
              _MoreRow(
                icon: Icons.ios_share_rounded,
                tint: AppColors.green,
                title: 'Compartilhar o ClimaSul',
                subtitle: 'Indique para quem vive no Vale e em POA',
                onTap: () => Share.share(
                  'Estou usando o ClimaSul — previsão do tempo, radar de chuva e '
                  'alertas do INMET para o Vale dos Sinos e a Grande Porto Alegre. '
                  'O tempo da nossa região! #ClimaSul',
                  subject: 'ClimaSul — o tempo da nossa região',
                ),
              ),
              _divider(context),
              _MoreRow(
                icon: Icons.dataset_rounded,
                tint: AppColors.sky,
                title: 'Fontes de dados e licenças',
                subtitle: 'Open-Meteo, INMET, RainViewer, Esri, IBGE',
                onTap: () => _SourcesSheet.show(context),
              ),
              _divider(context),
              _MoreRow(
                icon: Icons.info_outline_rounded,
                tint: context.cl.textSecondary,
                title: 'Sobre o ClimaSul',
                subtitle: 'Marca, cobertura e créditos',
                onTap: () => _AboutSheet.show(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Aviso de emergência ───────────────────────────────────
        GlassCard(
          radius: 16,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emergency_rounded,
                    color: AppColors.red, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Em emergência climática: ligue 199 (Defesa Civil) ou 190. '
                  'Siga sempre os avisos oficiais do INMET e da Defesa Civil.',
                  style: TextStyle(
                    color: context.cl.textSecondary,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: ClimaSulWordmark(fontSize: 18),
        ),
        const SizedBox(height: 2),
        const Center(
          child: Text(
            'ClimaSul · sempre com você!',
            style: TextStyle(
              color: AppColors.sun,
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            'Versão 1.0.0 · Feito no Rio Grande do Sul',
            style: TextStyle(color: context.cl.textTertiary, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) => Divider(
        height: 1,
        indent: 66,
        color: context.cl.dividerFaint,
      );
}

class _ThemeRow extends ConsumerWidget {
  const _ThemeRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cl = context.cl;
    final mode = ref.watch(themeModeProvider);
    final isLight = mode == ThemeMode.light;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.sun.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLight ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 21,
              color: AppColors.sun,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema',
                  style: TextStyle(
                    color: cl.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  isLight ? 'ClimaSul Claro' : 'ClimaSul Escuro',
                  style: TextStyle(color: cl.textTertiary, fontSize: 10.5),
                ),
              ],
            ),
          ),
          _ThemeSegment(
            isLight: isLight,
            onChanged: (light) => ref
                .read(themeModeProvider.notifier)
                .set(light ? ThemeMode.light : ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeSegment extends StatelessWidget {
  const _ThemeSegment({required this.isLight, required this.onChanged});

  final bool isLight;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cl = context.cl;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cl.fillFaint,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cl.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segmentButton(
            context: context,
            selected: !isLight,
            icon: Icons.dark_mode_rounded,
            label: 'Escuro',
            onTap: () => onChanged(false),
          ),
          _segmentButton(
            context: context,
            selected: isLight,
            icon: Icons.light_mode_rounded,
            label: 'Claro',
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }

  Widget _segmentButton({
    required BuildContext context,
    required bool selected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final cl = context.cl;
    return Material(
      color: selected ? AppColors.sun : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? const Color(0xFF332100) : cl.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: selected ? const Color(0xFF332100) : cl.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 21, color: tint),
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
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                        color: context.cl.textTertiary, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    color: context.cl.textTertiary, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Folhas: fontes e sobre ──────────────────────────────────────────

class _SourcesSheet extends StatelessWidget {
  const _SourcesSheet();

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _SourcesSheet(),
      );

  static const _sources = [
    ('Open-Meteo', 'Previsão do tempo e qualidade do ar (CC BY 4.0) · modelos ECMWF/GFS/ICON'),
    ('INMET — Instituto Nacional de Meteorologia', 'Avisos oficiais de perigo (amarelo, laranja, vermelho) para o RS · dados via radarmeteorologico.com.br'),
    ('RainViewer', 'Radar de precipitação global · uso livre com atribuição (rainviewer.com)'),
    ('Esri · Maxar · Earthstar Geographics', 'Mapa-base de satélite e inventário de tiles'),
    ('© OpenStreetMap contributors', 'Coordenadas e limites dos municípios'),
    ('IBGE — Serviços de Dados', 'Códigos IBGE dos 33 municípios (alertas cruzados)'),
  ];

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Fontes de dados',
      children: [
        for (final (name, detail) in _sources) _SourceTile(name: name, detail: detail),
        const SizedBox(height: 8),
        Text(
          'ClimaSul não é serviço oficial dos órgãos citados e não garante precisão absoluta das previsões. '
          'Em emergência, siga sempre os canais oficiais e a Defesa Civil.',
          style: TextStyle(
              color: context.cl.textTertiary, fontSize: 10.5, height: 1.5),
        ),
      ],
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.name, required this.detail});
  final String name;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.check_circle_rounded,
                size: 16, color: AppColors.green),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        color: context.cl.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(detail,
                    style: TextStyle(
                        color: context.cl.textSecondary,
                        fontSize: 10.5,
                        height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSheet extends StatelessWidget {
  const _AboutSheet();

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _AboutSheet(),
      );

  static const _swatches = [
    ('Azul Profundo', '#082D5B', Color(0xFF082D5B)),
    ('Azul Confiança', '#1976D2', Color(0xFF1976D2)),
    ('Azul Céu', '#4FC3F7', Color(0xFF4FC3F7)),
    ('Amarelo Solar', '#FFC107', Color(0xFFFFC107)),
    ('Verde Meteo', '#20B486', Color(0xFF20B486)),
    ('Vermelho Alerta', '#E64B4B', Color(0xFFE64B4B)),
  ];

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Sobre o ClimaSul',
      children: [
        const Center(child: ClimaSulLogo(iconSize: 84, wordmarkSize: 34)),
        const SizedBox(height: 16),
        Text(
          'ClimaSul é o aplicativo de referência meteorológica regional para '
          'quem vive no Vale dos Sinos e na Grande Porto Alegre — previsão '
          'precisa por cidade, radar de chuva em tempo real, alertas oficiais '
          'do INMET e estatísticas locais.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: context.cl.textSecondary, fontSize: 12, height: 1.55),
        ),
        const SizedBox(height: 18),
        Text(
          'PALETA OFICIAL',
          style: TextStyle(
            color: context.cl.textTertiary,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (name, hex, color) in _swatches)
              Column(
                children: [
                  Container(
                    width: 82,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.cl.hairline),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(name,
                      style: TextStyle(
                          color: context.cl.textSecondary, fontSize: 9)),
                  Text(hex,
                      style: TextStyle(
                          color: context.cl.textTertiary, fontSize: 8.5)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'TIPOGRAFIA  ·  Poppins ExtraBold (wordmark e títulos)  ·  Inter (textos)',
          style: TextStyle(
            color: context.cl.textTertiary,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '33 cidades monitoradas · 2 regiões · dados abertos.',
          style: TextStyle(
              color: context.cl.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.cl.sheet,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          border: Border(top: BorderSide(color: context.cl.hairline)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: context.cl.handle,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.cl.textPrimary,
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20 + 48,
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: context.cl.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 30),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
