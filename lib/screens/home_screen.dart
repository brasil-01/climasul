import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cities.dart';
import '../models/weather.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/weather_codes.dart';
import '../widgets/aqi_card.dart';
import '../widgets/brand.dart';
import '../widgets/charts.dart';
import '../widgets/city_picker_sheet.dart';
import '../widgets/daily_list.dart';
import '../widgets/hourly_sheet.dart';
import '../widgets/hourly_strip.dart';
import '../widgets/stat_tile.dart';
import '../widgets/sun_arc_card.dart';

/// Início: condição atual da cidade, próxima hora a hora,
/// estatísticas, arco do sol, qualidade do ar e 8 dias.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(selectedCityProvider);
    final bundleAsync = ref.watch(weatherBundleProvider(city.id));

    Future<void> refresh() async {
      ref.invalidate(weatherBundleProvider(city.id));
      ref.invalidate(regionSnapshotProvider);
      try {
        await ref.read(weatherBundleProvider(city.id).future);
      } catch (_) {/* erro já tratado na UI */}
    }

    return RefreshIndicator(
      onRefresh: refresh,
      color: AppColors.sun,
      backgroundColor: context.cl.surfaceAlt,
      child: bundleAsync.when(
        loading: () => _LoadingView(cityName: city.name),
        error: (error, _) => _ErrorView(
          cityName: city.name,
          message: error.toString(),
          onRetry: () => ref.invalidate(weatherBundleProvider(city.id)),
        ),
        data: (bundle) => _HomeBody(city: city, bundle: bundle),
      ),
    );
  }
}

// ── Corpo com dados ──────────────────────────────────────────────────

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.city, required this.bundle});

  final City city;
  final WeatherBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = bundle.upcomingHours;
    final next24 = upcoming.take(24).toList();
    final today = bundle.daily.isNotEmpty ? bundle.daily.first : null;
    final currentHour =
        bundle.hourly.isNotEmpty ? bundle.hourly[bundle.currentHourIndex] : null;
    final uvNow = currentHour?.uvIndex ?? 0;
    final uvCat = uvCategory(uvNow);
    final todayPrecip = today?.precipSum ?? 0;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 26),
      children: [
        // ── Barra superior: menu · wordmark · localização ─────────
        Row(
          children: [
            IconButton(
              tooltip: 'Mais opções',
              icon: Icon(Icons.menu_rounded,
                  color: context.cl.textPrimary, size: 26),
              onPressed: () => ref.read(tabIndexProvider.notifier).state = 3,
            ),
            const Expanded(child: Center(child: ClimaSulWordmark(fontSize: 24))),
            IconButton(
              tooltip: 'Trocar de cidade',
              icon: const Icon(Icons.location_on_rounded,
                  color: AppColors.sky, size: 26),
              onPressed: () => CityPickerSheet.show(context),
            ),
          ],
        ),
        // Selector de cidade (centralizado, como no app oficial)
        Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => CityPickerSheet.show(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.place_rounded,
                      size: 17, color: AppColors.sky),
                  const SizedBox(width: 4),
                  Text(
                    city.name,
                    style: TextStyle(
                      color: context.cl.textPrimary,
                      fontFamily: 'Inter',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 22, color: AppColors.sun),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        _Hero(city: city, bundle: bundle, today: today),
        const SizedBox(height: 14),
        _GlassStatBar(bundle: bundle),
        const SizedBox(height: 12),
        // Chips rápidos (UV, AQI, chuva, atualização)
        _QuickChips(bundle: bundle, uvNow: uvNow, uvCat: uvCat),
        const SizedBox(height: 16),
        // ── Cartão do Vale/Guaíba com a tagline ───────────────────
        _SkylineCard(),
        const SizedBox(height: 20),
        // ── Próximas horas ────────────────────────────────────────
        SectionHeader(
          'Previsão nas próximas horas',
          trailing: InkWell(
            onTap: () => HourlyForecastSheet.show(context,
                hours: upcoming, cityName: city.name),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.chevron_right_rounded,
                  color: AppColors.sky, size: 26),
            ),
          ),
        ),
        const SizedBox(height: 10),
        HourlyStrip(hours: upcoming),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader('Temperatura · 24h',
                  trailing: Row(
                    children: const [
                      _LegendDot(color: AppColors.sun, label: 'Agora'),
                      SizedBox(width: 10),
                      _LegendDot(color: AppColors.sky, label: 'Sensação'),
                    ],
                  )),
              const SizedBox(height: 14),
              TemperatureChart(hours: next24),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader('Precipitação por hora',
                  trailing: Text(
                    'Hoje: ${todayPrecip.toStringAsFixed(1)} mm',
                    style: const TextStyle(
                        color: AppColors.sky,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  )),
              const SizedBox(height: 12),
              PrecipChart(hours: next24),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader('Detalhes agora'),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.72,
          children: [
            StatTile(
              icon: Icons.thermostat,
              label: 'Sensação',
              value: '${bundle.current.apparentTemperature.round()}°',
              sub: 'sensação térmica',
              tint: const Color(0xFFFF8A3D),
            ),
            StatTile(
              icon: Icons.air,
              label: 'Rajadas',
              value: '${bundle.current.windGusts.round()} km/h',
              sub: 'pico no momento',
              tint: AppColors.warn,
            ),
            StatTile(
              icon: Icons.visibility,
              label: 'Visibilidade',
              value: _visibility(currentHour?.visibility),
              sub: 'alcance visual',
              tint: AppColors.ok,
            ),
            StatTile(
              icon: Icons.cloud,
              label: 'Nuvens',
              value: '${bundle.current.cloudCover.round()}%',
              sub: 'cobertura do céu',
              tint: context.cl.textSecondary,
            ),
            StatTile(
              icon: Icons.wb_sunny,
              label: 'Índice UV',
              value: '${uvNow.round()} · ${uvCat.label}',
              sub: uvNow >= 8 ? 'evite o sol 10h–16h' : 'radiação solar',
              tint: Color(uvCat.colorValue),
            ),
            StatTile(
              icon: Icons.navigation,
              label: 'Vento',
              value:
                  '${compass(bundle.current.windDirection)} · ${bundle.current.windDirection.round()}°',
              sub: '${bundle.current.windSpeed.round()} km/h',
              tint: AppColors.ok,
              iconTurns: bundle.current.windDirection / 360,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SunArcCard(today: today),
        const SizedBox(height: 16),
        AirQualityCard(airQuality: bundle.airQuality),
        const SizedBox(height: 16),
        const SectionHeader('Próximos 8 dias'),
        const SizedBox(height: 10),
        GlassCard(child: DailyForecastList(days: bundle.daily.take(8).toList())),
        const SizedBox(height: 18),
        Text(
          'Dados: Open-Meteo (CC BY 4.0) · Alertas oficiais: INMET · Radar: RainViewer\nPrevisão com modelo automático — confirme na Defesa Civil (199) em emergência.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: context.cl.textTertiary, fontSize: 9.5, height: 1.5),
        ),
      ],
    );
  }

  static String _visibility(double? meters) {
    if (meters == null) return '—';
    if (meters >= 10000) return '${(meters / 1000).round()} km';
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.round()} m';
  }
}

// ── Hero: ícone + temperatura gigante + Máx/Mín ─────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.city, required this.bundle, required this.today});

  final City city;
  final WeatherBundle bundle;
  final DailyBrief? today;

  @override
  Widget build(BuildContext context) {
    final current = bundle.current;
    final info = weatherInfo(current.weatherCode, isDay: current.isDay);
    final iconColor = weatherIconColor(current.weatherCode);

    return Column(
      children: [
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(info.icon, size: 92, color: iconColor),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${current.temperature.round()}',
                    style: TextStyle(
                      color: context.cl.textPrimary,
                      fontFamily: 'Poppins',
                      fontSize: 96,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      letterSpacing: -5,
                    ),
                  ),
                  TextSpan(
                    text: '°',
                    style: TextStyle(
                      color: context.cl.accent,
                      fontFamily: 'Poppins',
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _maxMinRow(context, Icons.device_thermostat, const Color(0xFFFF8A3D),
                    'Máxima', today?.tMax.round()),
                const SizedBox(height: 2),
                Container(
                    width: 74, height: 1, color: context.cl.hairline),
                const SizedBox(height: 2),
                _maxMinRow(context, Icons.ac_unit_rounded, AppColors.sky, 'Mínima',
                    today?.tMin.round()),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          info.description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.cl.textPrimary,
            fontFamily: 'Inter',
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Sensação de ${current.apparentTemperature.round()}° · '
          '${current.isDay ? 'dia' : 'noite'} em ${city.name}',
          style: TextStyle(
            color: context.cl.textSecondary,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  Widget _maxMinRow(BuildContext context, IconData icon, Color tint, String label, int? value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: tint),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: context.cl.textTertiary,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              value == null ? '—' : '$value°',
              style: TextStyle(
                color: context.cl.textPrimary,
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Barra de vidro com Umidade / Vento / Pressão (mockup oficial) ────

class _GlassStatBar extends StatelessWidget {
  const _GlassStatBar({required this.bundle});

  final WeatherBundle bundle;

  @override
  Widget build(BuildContext context) {
    final c = bundle.current;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
      decoration: BoxDecoration(
        color: context.cl.surfaceAlt.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cl.hairline),
      ),
      child: Row(
        children: [
          Expanded(
            child: _cell(context, Icons.water_drop_rounded, AppColors.sky,
                '${c.humidity.round()}%', 'Umidade'),
          ),
          _divider(context),
          Expanded(
            child: _cell(context, Icons.air_rounded, AppColors.sky,
                '${c.windSpeed.round()} km/h', 'Vento'),
          ),
          _divider(context),
          Expanded(
            child: _cell(context, Icons.speed_rounded, AppColors.sky,
                '${c.pressureMsl.round()} hPa', 'Pressão'),
          ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, IconData icon, Color tint, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: tint),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: context.cl.textPrimary,
            fontFamily: 'Poppins',
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: context.cl.textSecondary,
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) => Container(
        width: 1,
        height: 40,
        color: context.cl.hairline,
      );
}

// ── Chips rápidos ────────────────────────────────────────────────────

class _QuickChips extends StatelessWidget {
  const _QuickChips({
    required this.bundle,
    required this.uvNow,
    required this.uvCat,
  });

  final WeatherBundle bundle;
  final double uvNow;
  final UvCategory uvCat;

  @override
  Widget build(BuildContext context) {
    final aqi = bundle.airQuality?.usAqi;
    final aqiCat = aqiCategory(aqi);
    final today = bundle.daily.isNotEmpty ? bundle.daily.first : null;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (aqi != null)
          _chip(context,
            dot: Color(aqiCat.colorValue),
            text: 'AQI ${aqi.round()} · ${aqiCat.label}',
          ),
        if (today != null)
          _chip(context,
            icon: Icons.umbrella_rounded,
            iconColor: AppColors.sky,
            text: 'Chuva hoje: ${today.precipSum.toStringAsFixed(1)} mm',
          ),
        _chip(
          context,
          icon: Icons.wb_sunny_rounded,
          iconColor: Color(uvCat.colorValue),
          text: 'UV ${uvNow.round()} · ${uvCat.label}',
        ),
        _chip(
          context,
          icon: bundle.fromCache ? Icons.cloud_off_rounded : Icons.check_circle_outline_rounded,
          iconColor: bundle.fromCache ? AppColors.warn : AppColors.green,
          text: bundle.fromCache
              ? 'Dados salvos · ${timeAgo(bundle.fetchedAt)}'
              : 'Atualizado ${timeAgo(bundle.fetchedAt)}',
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, {IconData? icon, Color? iconColor, Color? dot, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: context.cl.surfaceAlt.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.cl.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            )
          else if (icon != null)
            Icon(icon, size: 13, color: iconColor ?? context.cl.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: context.cl.textPrimary,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cartão do skyline com a tagline oficial ──────────────────────────

class _SkylineCard extends StatelessWidget {
  const _SkylineCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Image.asset(
            'assets/brand/porto_alegre_sunset.png',
            height: 168,
            width: double.infinity,
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.35),
          ),
          Container(
            height: 168,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  context.cl.scaffold.withValues(alpha: 0.92),
                  context.cl.scaffold.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 0.85],
              ),
            ),
          ),
          Container(
            height: 168,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  context.cl.scaffold.withValues(alpha: 0.35),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Clima',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        color: AppColors.grayLight,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sul',
                          style: TextStyle(color: AppColors.sun),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Sempre com você!',
                    style: TextStyle(
                      color: AppColors.sun,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: context.cl.textSecondary, fontSize: 10)),
      ],
    );
  }
}

// ── Estados de carregamento e erro ───────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.cityName});
  final String cityName;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        SizedBox(height: 220),
        Center(
          child: Column(
            children: [
              Icon(Icons.cloud_sync_rounded,
                  size: 46, color: AppColors.sky),
              SizedBox(height: 14),
              Text(
                'Carregando o tempo…',
                style: TextStyle(
                  color: context.cl.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.cityName,
    required this.message,
    required this.onRetry,
  });

  final String cityName;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 160),
        Icon(Icons.cloud_off_rounded,
            size: 52, color: context.cl.textTertiary.withValues(alpha: 0.8)),
        const SizedBox(height: 16),
        Text(
          'Não conseguimos carregar $cityName',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.cl.textPrimary,
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: context.cl.textSecondary, fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 18),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ),
      ],
    );
  }
}
