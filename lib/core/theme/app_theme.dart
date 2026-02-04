import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Nano Banana Color Palette
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color accentColor = Color(0xFF00E5FF);
  static const Color backgroundColor = Color(0xFF121212);
  static const Color surfaceColor = Color(0x1FFFFFFF); // Transparent white for glass

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      background: backgroundColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    extensions: const [
      GlassmorphismTheme(
        blur: 10.0,
        opacity: 0.1,
        borderColor: Colors.white10,
      ),
    ],
  );
}

class GlassmorphismTheme extends ThemeExtension<GlassmorphismTheme> {
  final double blur;
  final double opacity;
  final Color borderColor;

  const GlassmorphismTheme({
    required this.blur,
    required this.opacity,
    required this.borderColor,
  });

  @override
  GlassmorphismTheme copyWith({
    double? blur,
    double? opacity,
    Color? borderColor,
  }) {
    return GlassmorphismTheme(
      blur: blur ?? this.blur,
      opacity: opacity ?? this.opacity,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  GlassmorphismTheme lerp(ThemeExtension<GlassmorphismTheme>? other, double t) {
    if (other is! GlassmorphismTheme) return this;
    return GlassmorphismTheme(
      blur: ui.lerpDouble(blur, other.blur, t)!,
      opacity: ui.lerpDouble(opacity, other.opacity, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
    );
  }
}
