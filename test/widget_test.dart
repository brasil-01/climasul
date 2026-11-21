// Testes de fumaça de widgets puros (sem rede, sem providers).
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:clima_sul/theme/app_theme.dart';
import 'package:clima_sul/widgets/stat_tile.dart';

void main() {
  testWidgets('GlassCard renderiza o filho', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildClimaSulTheme(brightness: Brightness.dark),
        home: Scaffold(
          backgroundColor: const Color(0xFF051F38),
          body: GlassCard(child: Text('Conteúdo de teste')),
        ),
      ),
    );
    expect(find.text('Conteúdo de teste'), findsOneWidget);
  });

  testWidgets('GlassCard renderiza no tema claro', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildClimaSulTheme(brightness: Brightness.light),
        home: Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: GlassCard(child: Text('Card claro')),
        ),
      ),
    );
    expect(find.text('Card claro'), findsOneWidget);
  });

  testWidgets('StatTile exibe rótulo, valor e subtítulo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildClimaSulTheme(brightness: Brightness.dark),
        home: Scaffold(
          backgroundColor: const Color(0xFF051F38),
          body: StatTile(
            icon: Icons.thermostat,
            label: 'Sensação',
            value: '31°',
            sub: 'sensação térmica',
          ),
        ),
      ),
    );
    expect(find.text('SENSAÇÃO'), findsOneWidget);
    expect(find.text('31°'), findsOneWidget);
    expect(find.text('sensação térmica'), findsOneWidget);
  });

  testWidgets('SectionHeader aplica versalete', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildClimaSulTheme(brightness: Brightness.dark),
        home: Scaffold(body: SectionHeader('Próximos 8 dias')),
      ),
    );
    expect(find.text('PRÓXIMOS 8 DIAS'), findsOneWidget);
  });
}
