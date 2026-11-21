import 'package:material_ui/material_ui.dart';

/// Paleta oficial ClimaSul (manual de marca) — constante nas duas aparências.
abstract final class AppColors {
  // ── Marca ─────────────────────────────────────────────
  static const deep = Color(0xFF082D5B); // Azul Profundo — fundos escuros
  static const navy = Color(0xFF102F55);
  static const navyLight = Color(0xFF173F68); // cartões escuros elevados
  static const blue = Color(0xFF1976D2); // Azul Confiança — botões/links
  static const sky = Color(0xFF4FC3F7); // Azul Céu — detalhes/gráficos
  static const sun = Color(0xFFFFC107); // Amarelo Solar — destaques/sol
  static const grayLight = Color(0xFFF5F7FA); // Cinza Claro — fundo claro
  static const green = Color(0xFF20B486); // Verde meteorológico
  static const red = Color(0xFFE64B4B); // Vermelho alerta
  static const orange = Color(0xFFFF8A3D); // INMET — Perigo (laranja)

  // ── Aliases semânticos (iguais nas duas aparências) ───
  static const amber = sun;
  static const amberSoft = Color(0xFFFFD54F);
  static const cyan = sky;
  static const ok = green;
  static const warn = sun;
  static const danger = red;
  static const violet = Color(0xFF9CCBFF);
}

/// Tokens que variam entre o ClimaSul Escuro e o ClimaSul Claro.
class ClimaSulTokens extends ThemeExtension<ClimaSulTokens> {
  const ClimaSulTokens({
    required this.scaffold,
    required this.scaffoldTop,
    required this.scaffoldBottom,
    required this.sunGlow,
    required this.blueGlow,
    required this.skyGlow,
    required this.glassTop,
    required this.glassBottom,
    required this.glassBorder,
    required this.glassShadow,
    required this.hairline,
    required this.dividerFaint,
    required this.fillFaint,
    required this.handle,
    required this.surfaceAlt,
    required this.sheet,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.navBg,
    required this.navIndicator,
    required this.navSelected,
    required this.navUnselected,
    required this.tooltipBg,
    required this.accent,
    required this.sunInk,
    required this.orangeInk,
    required this.cardFill,
  });

  final Color scaffold;
  final Color scaffoldTop;
  final Color scaffoldBottom;
  final Color sunGlow;
  final Color blueGlow;
  final Color skyGlow;
  final Color glassTop;
  final Color glassBottom;
  final Color glassBorder;
  final Color glassShadow;
  final Color hairline;
  final Color dividerFaint;
  final Color fillFaint;
  final Color handle;
  final Color surfaceAlt;
  final Color sheet;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color navBg;
  final Color navIndicator;
  final Color navSelected;
  final Color navUnselected;
  final Color tooltipBg;
  final Color accent;
  final Color sunInk;
  final Color orangeInk;
  final Color cardFill;

  @override
  ClimaSulTokens copyWith({
    Color? scaffold,
    Color? scaffoldTop,
    Color? scaffoldBottom,
    Color? sunGlow,
    Color? blueGlow,
    Color? skyGlow,
    Color? glassTop,
    Color? glassBottom,
    Color? glassBorder,
    Color? glassShadow,
    Color? hairline,
    Color? dividerFaint,
    Color? fillFaint,
    Color? handle,
    Color? surfaceAlt,
    Color? sheet,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? navBg,
    Color? navIndicator,
    Color? navSelected,
    Color? navUnselected,
    Color? tooltipBg,
    Color? accent,
    Color? sunInk,
    Color? orangeInk,
    Color? cardFill,
  }) {
    return ClimaSulTokens(
      scaffold: scaffold ?? this.scaffold,
      scaffoldTop: scaffoldTop ?? this.scaffoldTop,
      scaffoldBottom: scaffoldBottom ?? this.scaffoldBottom,
      sunGlow: sunGlow ?? this.sunGlow,
      blueGlow: blueGlow ?? this.blueGlow,
      skyGlow: skyGlow ?? this.skyGlow,
      glassTop: glassTop ?? this.glassTop,
      glassBottom: glassBottom ?? this.glassBottom,
      glassBorder: glassBorder ?? this.glassBorder,
      glassShadow: glassShadow ?? this.glassShadow,
      hairline: hairline ?? this.hairline,
      dividerFaint: dividerFaint ?? this.dividerFaint,
      fillFaint: fillFaint ?? this.fillFaint,
      handle: handle ?? this.handle,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      sheet: sheet ?? this.sheet,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      navBg: navBg ?? this.navBg,
      navIndicator: navIndicator ?? this.navIndicator,
      navSelected: navSelected ?? this.navSelected,
      navUnselected: navUnselected ?? this.navUnselected,
      tooltipBg: tooltipBg ?? this.tooltipBg,
      accent: accent ?? this.accent,
      sunInk: sunInk ?? this.sunInk,
      orangeInk: orangeInk ?? this.orangeInk,
      cardFill: cardFill ?? this.cardFill,
    );
  }

  @override
  ClimaSulTokens lerp(ThemeExtension<ClimaSulTokens>? other, double t) {
    if (other is! ClimaSulTokens) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return ClimaSulTokens(
      scaffold: c(scaffold, other.scaffold),
      scaffoldTop: c(scaffoldTop, other.scaffoldTop),
      scaffoldBottom: c(scaffoldBottom, other.scaffoldBottom),
      sunGlow: c(sunGlow, other.sunGlow),
      blueGlow: c(blueGlow, other.blueGlow),
      skyGlow: c(skyGlow, other.skyGlow),
      glassTop: c(glassTop, other.glassTop),
      glassBottom: c(glassBottom, other.glassBottom),
      glassBorder: c(glassBorder, other.glassBorder),
      glassShadow: c(glassShadow, other.glassShadow),
      hairline: c(hairline, other.hairline),
      dividerFaint: c(dividerFaint, other.dividerFaint),
      fillFaint: c(fillFaint, other.fillFaint),
      handle: c(handle, other.handle),
      surfaceAlt: c(surfaceAlt, other.surfaceAlt),
      sheet: c(sheet, other.sheet),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textTertiary: c(textTertiary, other.textTertiary),
      navBg: c(navBg, other.navBg),
      navIndicator: c(navIndicator, other.navIndicator),
      navSelected: c(navSelected, other.navSelected),
      navUnselected: c(navUnselected, other.navUnselected),
      tooltipBg: c(tooltipBg, other.tooltipBg),
      accent: c(accent, other.accent),
      sunInk: c(sunInk, other.sunInk),
      orangeInk: c(orangeInk, other.orangeInk),
      cardFill: c(cardFill, other.cardFill),
    );
  }
}

/// Acesso curto: `context.cl` → tokens da aparência ativa.
extension ClimaSulContext on BuildContext {
  ClimaSulTokens get cl => Theme.of(this).extension<ClimaSulTokens>()!;
}

// ── Tokens escuros (ClimaSul Escuro) ─────────────────────
const _darkTokens = ClimaSulTokens(
  scaffold: Color(0xFF051F38),
  scaffoldTop: Color(0xFF10386A),
  scaffoldBottom: Color(0xFF051F38),
  sunGlow: Color(0x2EFFC107),
  blueGlow: Color(0x291976D2),
  skyGlow: Color(0x1A4FC3F7),
  glassTop: Color(0xEE173F68),
  glassBottom: Color(0xE60E2C52),
  glassBorder: Color(0x1FFFFFFF),
  glassShadow: Color(0x55000000),
  hairline: Color(0x1FFFFFFF),
  dividerFaint: Color(0x14FFFFFF),
  fillFaint: Color(0x0DFFFFFF),
  handle: Color(0x2EFFFFFF),
  surfaceAlt: Color(0xFF173F68),
  sheet: Color(0xFF082D5B),
  textPrimary: Color(0xFFF5F7FA),
  textSecondary: Color(0xFFA9BEDA),
  textTertiary: Color(0xFF6E88A6),
  navBg: Color(0xF0071F38),
  navIndicator: Color(0x38FFC107),
  navSelected: Color(0xFFFFC107),
  navUnselected: Color(0xFFA9BEDA),
  tooltipBg: Color(0xFF16294A),
  accent: Color(0xFF4FC3F7),
  sunInk: Color(0xFFFFC107),
  orangeInk: Color(0xFFFF8A3D),
  cardFill: Color(0xFF10233E),
);

// ── Tokens claros (ClimaSul Claro) ───────────────────────
const _lightTokens = ClimaSulTokens(
  scaffold: Color(0xFFF5F7FA),
  scaffoldTop: Color(0xFFE9EEF6),
  scaffoldBottom: Color(0xFFF5F7FA),
  sunGlow: Color(0x33FFC107),
  blueGlow: Color(0x1A1976D2),
  skyGlow: Color(0x264FC3F7),
  glassTop: Color(0xFFFFFFFF),
  glassBottom: Color(0xFFFFFFFF),
  glassBorder: Color(0x1A082D5B),
  glassShadow: Color(0x14082D5B),
  hairline: Color(0x1F082D5B),
  dividerFaint: Color(0x14082D5B),
  fillFaint: Color(0x0D082D5B),
  handle: Color(0x2E082D5B),
  surfaceAlt: Color(0xFFFFFFFF),
  sheet: Color(0xFFFFFFFF),
  textPrimary: Color(0xFF082D5B),
  textSecondary: Color(0xFF38506E),
  textTertiary: Color(0xFF6E829C),
  navBg: Color(0xFFFFFFFF),
  navIndicator: Color(0x241976D2),
  navSelected: Color(0xFF1976D2),
  navUnselected: Color(0xFF5B6E85),
  tooltipBg: Color(0xFF082D5B),
  accent: Color(0xFF1976D2),
  sunInk: Color(0xFF997404),
  orangeInk: Color(0xFFC2410C),
  cardFill: Color(0xFFFFFFFF),
);

ThemeData buildClimaSulTheme({required Brightness brightness}) {
  final isDark = brightness == Brightness.dark;
  final tokens = isDark ? _darkTokens : _lightTokens;

  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    brightness: brightness,
    surface: tokens.sheet,
  ).copyWith(
    primary: AppColors.blue,
    secondary: AppColors.sky,
    tertiary: AppColors.sun,
    onPrimary: isDark ? AppColors.grayLight : Colors.white,
  );

  const display = 'Poppins';
  const body = 'Inter';

  final baseText = Typography.material2021(platform: TargetPlatform.android);
  final textTheme = (isDark ? baseText.white : baseText.black).apply(
    bodyColor: tokens.textPrimary,
    displayColor: tokens.textPrimary,
    fontFamily: body,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: tokens.scaffold,
    colorScheme: scheme,
    fontFamily: body,
    extensions: [tokens],
    textTheme: textTheme.copyWith(
      displayLarge: TextStyle(
          fontFamily: display,
          fontWeight: FontWeight.w800,
          color: tokens.textPrimary),
      displayMedium: TextStyle(
          fontFamily: display,
          fontWeight: FontWeight.w800,
          color: tokens.textPrimary),
      headlineLarge: TextStyle(
          fontFamily: display,
          fontWeight: FontWeight.w800,
          color: tokens.textPrimary),
      headlineMedium: TextStyle(
          fontFamily: display,
          fontWeight: FontWeight.w700,
          color: tokens.textPrimary),
      headlineSmall: TextStyle(
          fontFamily: display,
          fontWeight: FontWeight.w700,
          color: tokens.textPrimary),
      titleLarge: TextStyle(
          fontFamily: display,
          fontWeight: FontWeight.w700,
          color: tokens.textPrimary),
      titleMedium: TextStyle(
          fontFamily: body,
          fontWeight: FontWeight.w600,
          color: tokens.textPrimary),
    ),
    dividerColor: tokens.dividerFaint,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: tokens.textPrimary,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: tokens.navBg,
      indicatorColor: tokens.navIndicator,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: body,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? tokens.navSelected
              : tokens.navUnselected,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? tokens.navSelected
              : tokens.navUnselected,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
            fontFamily: body, fontWeight: FontWeight.w700, fontSize: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: tokens.surfaceAlt,
      contentTextStyle:
          TextStyle(color: tokens.textPrimary, fontFamily: body),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Fundo com gradiente da marca + brilhos suaves do sol e do céu.
class SkyBackground extends StatelessWidget {
  const SkyBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cl = context.cl;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cl.scaffoldTop, cl.scaffoldBottom],
              stops: const [0.0, 0.58],
            ),
          ),
        ),
        Positioned(
          top: -150,
          right: -120,
          child: _glow(cl.sunGlow, 330),
        ),
        Positioned(
          top: 120,
          left: -150,
          child: _glow(cl.blueGlow, 300),
        ),
        Positioned(
          bottom: -170,
          right: -140,
          child: _glow(cl.skyGlow, 330),
        ),
        child,
      ],
    );
  }

  static Widget _glow(Color color, double size) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      );
}

/// Cartão "vidro" no padrão da marca (claro/escuro conforme o tema).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.onTap,
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final cl = context.cl;
    final decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [cl.glassTop, cl.glassBottom],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: cl.glassBorder),
      boxShadow: [
        BoxShadow(
          color: cl.glassShadow,
          blurRadius: 26,
          offset: const Offset(0, 12),
        ),
      ],
    );

    final content = Padding(padding: padding, child: child);
    return Container(
      margin: margin,
      decoration: decoration,
      child: onTap == null
          ? content
          : ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: InkWell(onTap: onTap, child: content),
            ),
    );
  }
}

/// Título de seção em versalete.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: context.cl.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            letterSpacing: 1.6,
          ),
        ),
        ?trailing,
      ],
    );
  }
}
