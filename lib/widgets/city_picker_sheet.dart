import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cities.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../utils/text.dart';
import '../utils/weather_codes.dart';

/// Folha inferior para trocar a cidade monitorada
/// (favoritas + busca sem acentos + lista por região).
class CityPickerSheet extends ConsumerStatefulWidget {
  const CityPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CityPickerSheet(),
    );
  }

  @override
  ConsumerState<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends ConsumerState<CityPickerSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedCityIdProvider);
    final favorites = ref.watch(favoritesProvider);
    final regionAsync = ref.watch(regionSnapshotProvider);
    final temps = <String, (double?, int?)>{};
    regionAsync.whenData((snapshot) {
      for (final rc in snapshot.cities) {
        temps[rc.city.id] = (rc.currentTemp, rc.currentCode);
      }
    });

    final q = stripAccents(_query.trim().toLowerCase());
    final matches = q.isEmpty
        ? allCities
        : allCities
            .where((c) => stripAccents(c.name.toLowerCase()).contains(q))
            .toList();
    final favoriteCities =
        allCities.where((c) => favorites.contains(c.id)).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.55,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Trocar de cidade',
                    style: TextStyle(
                      color: context.cl.textPrimary,
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.sky.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '33 cidades',
                      style: TextStyle(
                        color: AppColors.sky,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _search,
                autofocus: false,
                onChanged: (v) => setState(() => _query = v),
                inputFormatters: [LengthLimitingTextInputFormatter(60)],
                style: TextStyle(color: context.cl.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Buscar cidade… (ex.: Novo Hamburgo)',
                  hintStyle: TextStyle(color: context.cl.textTertiary),
                  prefixIcon:
                      Icon(Icons.search, color: context.cl.textSecondary),
                  filled: true,
                  fillColor: context.cl.fillFaint,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.cl.hairline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.cl.hairline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.sky, width: 1.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 26),
                children: [
                  if (_query.trim().isEmpty && favoriteCities.isNotEmpty) ...[
                    _groupLabel('Favoritas', Icons.star_rounded,
                        AppColors.sun),
                    ...favoriteCities.map((c) => _tile(
                          c,
                          selectedId,
                          favorites.contains(c.id),
                          temps[c.id],
                        )),
                    const SizedBox(height: 8),
                  ],
                  if (_query.trim().isNotEmpty) ...[
                    if (matches.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 44),
                        child: Column(
                          children: [
                            Icon(Icons.location_off_outlined,
                                size: 38, color: context.cl.textTertiary),
                            SizedBox(height: 10),
                            Text(
                              'Nenhuma cidade encontrada',
                              style: TextStyle(
                                  color: context.cl.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    else
                      ...matches.map((c) => _tile(
                            c,
                            selectedId,
                            favorites.contains(c.id),
                            temps[c.id],
                          )),
                  ] else
                    for (final region in Region.values) ...[
                      _groupLabel(
                        region.label,
                        region == Region.valeDosSinos
                            ? Icons.terrain_rounded
                            : Icons.location_city_rounded,
                        region == Region.valeDosSinos
                            ? AppColors.green
                            : AppColors.sky,
                      ),
                      ...citiesOf(region).map((c) => _tile(
                            c,
                            selectedId,
                            favorites.contains(c.id),
                            temps[c.id],
                          )),
                      const SizedBox(height: 8),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupLabel(String label, IconData icon, Color tint) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6, top: 2),
        child: Row(
          children: [
            Icon(icon, size: 13, color: tint),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: context.cl.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
      );

  Widget _tile(
    City city,
    String selectedId,
    bool isFavorite,
    (double?, int?)? snapshot,
  ) {
    final selected = city.id == selectedId;
    final temp = snapshot?.$1;
    final code = snapshot?.$2;
    final info = code == null ? null : weatherInfo(code);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        ref.read(selectedCityIdProvider.notifier).select(city.id);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.sun.withValues(alpha: 0.09)
              : context.cl.fillFaint,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.sun.withValues(alpha: 0.5)
                : context.cl.hairline,
          ),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () =>
                  ref.read(favoritesProvider.notifier).toggle(city.id),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 20,
                  color: isFavorite ? AppColors.sun : context.cl.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                city.name,
                style: TextStyle(
                  color: selected ? AppColors.sun : context.cl.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (info != null) ...[
              Icon(info.icon, size: 18, color: weatherIconColor(code!)),
              const SizedBox(width: 8),
            ],
            Text(
              temp == null ? '—°' : '${temp.round()}°',
              style: TextStyle(
                color: context.cl.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
