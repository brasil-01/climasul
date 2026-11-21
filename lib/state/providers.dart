import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/cities.dart';
import '../models/weather.dart';
import '../services/alerts_engine.dart';
import '../services/inmet_official_service.dart';
import '../services/open_meteo_service.dart';
import '../services/rainviewer_service.dart';

// ── Serviços ─────────────────────────────────────────────────────────
final openMeteoServiceProvider =
    Provider<OpenMeteoService>((ref) => OpenMeteoService());

final rainViewerServiceProvider =
    Provider<RainViewerService>((ref) => RainViewerService());

// ── Navegação inferior ───────────────────────────────────────────────
final tabIndexProvider = StateProvider<int>((ref) => 0);

// ── Tema (persistido) ─────────────────────────────────────────────────
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('theme_mode');
      if (saved == 'light') {
        state = ThemeMode.light;
      } else if (saved == 'dark') {
        state = ThemeMode.dark;
      } else if (saved == 'system') {
        state = ThemeMode.system;
      }
    } catch (_) {/* mantém escuro */}
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'theme_mode',
        mode == ThemeMode.light
            ? 'light'
            : mode == ThemeMode.system
                ? 'system'
                : 'dark',
      );
    } catch (_) {}
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
    (ref) => ThemeModeNotifier());

// ── Cidade selecionada (persistida) ──────────────────────────────────
class SelectedCityNotifier extends StateNotifier<String> {
  SelectedCityNotifier() : super('novo_hamburgo') {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('selected_city');
      if (saved != null && allCities.any((c) => c.id == saved)) {
        state = saved;
      }
    } catch (_) {/* mantém o padrão */}
  }

  Future<void> select(String id) async {
    if (!allCities.any((c) => c.id == id)) return;
    state = id;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_city', id);
    } catch (_) {}
  }
}

final selectedCityIdProvider =
    StateNotifierProvider<SelectedCityNotifier, String>(
        (ref) => SelectedCityNotifier());

final selectedCityProvider = Provider<City>((ref) {
  return cityById(ref.watch(selectedCityIdProvider));
});

// ── Cidades favoritas (persistidas) ──────────────────────────────────
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super(const {'novo_hamburgo'}) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('favorites');
      if (saved != null && saved.isNotEmpty) {
        state = saved.toSet();
      }
    } catch (_) {}
  }

  Future<void> toggle(String id) async {
    final next = {...state};
    if (!next.remove(id)) next.add(id);
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', next.toList());
    } catch (_) {}
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>(
        (ref) => FavoritesNotifier());

// ── Dados de clima ───────────────────────────────────────────────────
final weatherBundleProvider =
    FutureProvider.family<WeatherBundle, String>((ref, cityId) async {
  final service = ref.watch(openMeteoServiceProvider);
  return service.fetchBundle(cityById(cityId));
});

/// Panorama das 33 cidades (atual + 4 dias), em uma única chamada em lote.
final regionSnapshotProvider =
    FutureProvider<RegionSnapshot>((ref) async {
  final service = ref.watch(openMeteoServiceProvider);
  return service.fetchRegion(allCities);
});

// ── Alertas (derivados da previsão) ──────────────────────────────────
final cityAlertsProvider =
    Provider.family<List<WeatherAlert>, String>((ref, cityId) {
  final async = ref.watch(weatherBundleProvider(cityId));
  return async.maybeWhen(
    data: (bundle) => evaluateBundle(cityById(cityId), bundle),
    orElse: () => const <WeatherAlert>[],
  );
});

final regionAlertsProvider = Provider<List<RegionAlertGroup>>((ref) {
  final async = ref.watch(regionSnapshotProvider);
  return async.maybeWhen(
    data: evaluateRegion,
    orElse: () => const <RegionAlertGroup>[],
  );
});

// ── Alertas oficiais do INMET ────────────────────────────────────────
final inmetOfficialServiceProvider =
    Provider<InmetOfficialService>((ref) => InmetOfficialService());

/// Feed oficial do INMET para RS (atualizado a cada ~10 min na fonte).
/// Falha → AsyncError; a UI cai graciosamente para a previsão automática.
final inmetOfficialProvider = FutureProvider<InmetOfficialFeed>((ref) async {
  final svc = ref.watch(inmetOfficialServiceProvider);
  return svc.fetchRsAlerts();
});

/// Total exibido no badge da aba Alertas (INMET oficiais + derivados).
final activeAlertCountProvider = Provider<int>((ref) {
  final selected = ref.watch(selectedCityIdProvider);
  final official = ref.watch(inmetOfficialProvider).maybeWhen(
        data: (feed) => feed.alerts.length,
        orElse: () => 0,
      );
  return official +
      ref.watch(cityAlertsProvider(selected)).length +
      ref.watch(regionAlertsProvider).length;
});

// ── Radar RainViewer ─────────────────────────────────────────────────
final radarFramesProvider = FutureProvider<RadarFrames>((ref) {
  return ref.watch(rainViewerServiceProvider).fetchFrames();
});
