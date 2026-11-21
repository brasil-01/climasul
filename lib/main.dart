import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/root_screen.dart';
import 'state/providers.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  runApp(const ProviderScope(child: ClimaSulApp()));
}

class ClimaSulApp extends ConsumerWidget {
  const ClimaSulApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ClimaSul — O tempo da nossa região',
      debugShowCheckedModeBanner: false,
      themeMode: ref.watch(themeModeProvider),
      theme: buildClimaSulTheme(brightness: Brightness.light),
      darkTheme: buildClimaSulTheme(brightness: Brightness.dark),
      home: const RootScreen(),
    );
  }
}
