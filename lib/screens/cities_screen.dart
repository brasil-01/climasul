import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cities.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../utils/weather_codes.dart';

/// Lista das 33 cidades, com busca, favoritas e situação atual (batch API).
class CitiesScreen extends ConsumerStatefulWidget {
  const CitiesScreen({super.key});

  @override
  ConsumerState<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends ConsumerState<CitiesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final regionAsync = ref.watch(regionSnapshotProvider);
    final selectedId = ref.watch(selectedCityIdProvider);
    final favorites = ref.watch(favoritesProvider);

    final temps = <String, (double?, int?)>{};
    regionAsync.whenData((snapshot) {
      for (final rc in snapshot.cities) {
        temps[rc.city.id] = (rc.currentTemp, rc.currentCode);
      }
    });

    final matches = _filtered(_query);
    final showGrouped = _query.trim().isEmpty;

    final favoriteCities =
        allCities.where((c) => favorites.contains(c.id)).toList();

    return RefreshIndicator(
      color: AppColors.amber,
      backgroundColor: context.cl.sheet,
      onRefresh: () async {
        ref.invalidate(regionSnapshotProvider);
        try {
          await ref.read(regionSnapshotProvider.future);
        } catch (_) {}
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
        children: [
          Text(
            'Cidades',
            style: TextStyle(
              color: context.cl.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '33 cidades monitoradas · toque para acompanhar',
            style: TextStyle(color: context.cl.textSecondary, fontSize: 11.5),
          ),
          const SizedBox(height: 12),

          // ── Busca ──────────────────────────────────────────────
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            inputFormatters: [LengthLimitingTextInputFormatter(60)],
            textInputAction: TextInputAction.search,
            style: TextStyle(color: context.cl.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buscar cidade… (ex.: Novo Hamburgo)',
              hintStyle: TextStyle(color: context.cl.textTertiary),
              prefixIcon: Icon(Icons.search, color: context.cl.textSecondary),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.close, color: context.cl.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: context.cl.fillFaint,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.cl.hairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.cl.hairline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.amber, width: 1.4),
              ),
            ),
          ),
          if (regionAsync.isLoading) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              color: AppColors.amber,
            ),
          ],
          const SizedBox(height: 16),

          // ── Conteúdo ───────────────────────────────────────────
          if (!showGrouped) ...[
            if (matches.isEmpty)
              _EmptyResult(query: _query)
            else
              ...matches.map((c) => _CityTile(
                    city: c,
                    temp: temps[c.id]?.$1,
                    code: temps[c.id]?.$2,
                    isFavorite: favorites.contains(c.id),
                    isSelected: c.id == selectedId,
                  )),
          ] else ...[
            if (favoriteCities.isNotEmpty) ...[
              _GroupHeader(
                label: 'Favoritas',
                count: favoriteCities.length,
                icon: Icons.star_rounded,
                tint: AppColors.amber,
              ),
              ...favoriteCities.map((c) => _CityTile(
                    city: c,
                    temp: temps[c.id]?.$1,
                    code: temps[c.id]?.$2,
                    isFavorite: true,
                    isSelected: c.id == selectedId,
                  )),
              const SizedBox(height: 14),
            ],
            for (final region in Region.values) ...[
              _GroupHeader(
                label: region.label,
                count: citiesOf(region).length,
                icon: region == Region.valeDosSinos
                    ? Icons.terrain_rounded
                    : Icons.location_city_rounded,
                tint: region == Region.valeDosSinos
                    ? AppColors.ok
                    : AppColors.cyan,
              ),
              ...citiesOf(region).map((c) => _CityTile(
                    city: c,
                    temp: temps[c.id]?.$1,
                    code: temps[c.id]?.$2,
                    isFavorite: favorites.contains(c.id),
                    isSelected: c.id == selectedId,
                  )),
              const SizedBox(height: 14),
            ],
          ],
          const SizedBox(height: 4),
          Text(
            regionAsync.maybeWhen(
              data: (s) =>
                  'Atualizado ${TimeOfDay.fromDateTime(s.fetchedAt).format(context)} · Open-Meteo',
              orElse: () => 'Coordenadas © OpenStreetMap · Open-Meteo',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: context.cl.textTertiary, fontSize: 9.5),
          ),
        ],
      ),
    );
  }

  List<City> _filtered(String query) {
    final q = _stripAccents(query.trim().toLowerCase());
    if (q.isEmpty) return allCities;
    return allCities
        .where((c) => _stripAccents(c.name.toLowerCase()).contains(q))
        .toList();
  }

  static String _stripAccents(String input) {
    const map = {
      'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
      'é': 'e', 'ê': 'e', 'è': 'e', 'ë': 'e',
      'í': 'i', 'î': 'i', 'ì': 'i', 'ï': 'i',
      'ó': 'o', 'ô': 'o', 'õ': 'o', 'ò': 'o', 'ö': 'o',
      'ú': 'u', 'û': 'u', 'ù': 'u', 'ü': 'u',
      'ç': 'c', 'ñ': 'n',
    };
    final buffer = StringBuffer();
    for (final ch in input.split('')) {
      buffer.write(map[ch] ?? ch);
    }
    return buffer.toString();
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.label,
    required this.count,
    required this.icon,
    required this.tint,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: tint),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: context.cl.textSecondary.withValues(alpha: 0.9),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: context.cl.fillFaint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                  color: context.cl.textTertiary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityTile extends ConsumerWidget {
  const _CityTile({
    required this.city,
    required this.temp,
    required this.code,
    required this.isFavorite,
    required this.isSelected,
  });

  final City city;
  final double? temp;
  final int? code;
  final bool isFavorite;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = code == null ? null : weatherInfo(code!);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.amber.withValues(alpha: 0.08)
            : context.cl.fillFaint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.amber.withValues(alpha: 0.55)
              : context.cl.hairline,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ref.read(selectedCityIdProvider.notifier).select(city.id);
          ref.read(tabIndexProvider.notifier).state = 0;
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: TextStyle(
                        color: isSelected
                            ? context.cl.sunInk
                            : context.cl.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      city.region.label,
                      style: TextStyle(
                          color: context.cl.textTertiary, fontSize: 9.5),
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const Icon(Icons.check_circle,
                    size: 16, color: AppColors.amber),
                const SizedBox(width: 10),
              ],
              if (info != null) ...[
                Icon(info.icon, size: 21, color: weatherIconColor(code!)),
                const SizedBox(width: 8),
              ],
              SizedBox(
                width: 42,
                child: Text(
                  temp == null ? '—°' : '${temp!.round()}°',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: context.cl.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: isFavorite ? 'Remover dos favoritos' : 'Favoritar',
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFavorite ? AppColors.amber : context.cl.textTertiary,
                ),
                onPressed: () =>
                    ref.read(favoritesProvider.notifier).toggle(city.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 46),
      child: Column(
        children: [
          Icon(Icons.location_off_outlined,
              size: 42, color: context.cl.textTertiary),
          const SizedBox(height: 12),
          Text(
            'Nenhuma cidade encontrada para “$query”',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: context.cl.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'A cobertura atual: Vale dos Sinos e Grande Porto Alegre.',
            style: TextStyle(color: context.cl.textTertiary, fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}
