import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Wordmark "ClimaSul" — "Clima" em branco/quase-branco + "Sul" em Amarelo Solar.
/// Poppins ExtraBold (marca oficial).
class ClimaSulWordmark extends StatelessWidget {
  const ClimaSulWordmark({super.key, this.fontSize = 24});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Clima',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              color: context.cl.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: 'Sul',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              color: AppColors.sun,
              letterSpacing: -0.5,
            ),
          ),
        ],
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }
}

/// Logo completo (símbolo + wordmark + tagline opcional).
class ClimaSulLogo extends StatelessWidget {
  const ClimaSulLogo({super.key, this.iconSize = 96, this.wordmarkSize = 40});

  final double iconSize;
  final double wordmarkSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(iconSize * 0.24),
          child: Image.asset(
            'assets/brand/climasul_icon.png',
            width: iconSize,
            height: iconSize,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 14),
        ClimaSulWordmark(fontSize: wordmarkSize),
        const SizedBox(height: 2),
        Text(
          'O tempo da nossa região.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: wordmarkSize * 0.32,
            color: context.cl.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
