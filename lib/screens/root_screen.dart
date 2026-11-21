import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../theme/app_theme.dart';
import 'alerts_screen.dart';
import 'cities_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'radar_screen.dart';

/// Shell do app: fundo azul profundo + navegação inferior de 5 destinos
/// (Início · Radar · Alertas · Cidades · Mais).
class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(tabIndexProvider);
    final alertCount = ref.watch(activeAlertCountProvider);

    return SkyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: tab,
            children: const [
              HomeScreen(),
              RadarScreen(),
              AlertsScreen(),
              CitiesScreen(),
              MoreScreen(),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          height: 66,
          selectedIndex: tab,
          onDestinationSelected: (i) =>
              ref.read(tabIndexProvider.notifier).state = i,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Início',
            ),
            const NavigationDestination(
              icon: Icon(Icons.radar_outlined),
              selectedIcon: Icon(Icons.radar),
              label: 'Radar',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: alertCount > 0,
                label: Text('${alertCount > 9 ? '9+' : alertCount}'),
                child: const Icon(Icons.gpp_maybe_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: alertCount > 0,
                label: Text('${alertCount > 9 ? '9+' : alertCount}'),
                child: const Icon(Icons.gpp_maybe),
              ),
              label: 'Alertas',
            ),
            const NavigationDestination(
              icon: Icon(Icons.location_city_outlined),
              selectedIcon: Icon(Icons.location_city),
              label: 'Cidades',
            ),
            const NavigationDestination(
              icon: Icon(Icons.apps_outlined),
              selectedIcon: Icon(Icons.apps),
              label: 'Mais',
            ),
          ],
        ),
      ),
    );
  }
}
