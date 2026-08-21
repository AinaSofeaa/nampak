import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const nampakBackground = Color(0xFFF8F7F3);
const nampakPrimary = Color(0xFFF27D26);
const nampakGold = Color(0xFFFFD966);
const nampakText = Color(0xFF2D2D2D);
const nampakMutedText = Color(0xFF737373);

ThemeData buildNampakTheme() {
  final textTheme = GoogleFonts.interTextTheme().apply(
    bodyColor: nampakText,
    displayColor: nampakText,
  );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: nampakBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: nampakPrimary,
      brightness: Brightness.light,
    ),
    textTheme: textTheme,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: nampakText,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: nampakText,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );
}

class CenteredAppCanvas extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CenteredAppCanvas({
    super.key,
    required this.child,
    this.maxWidth = 520,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < maxWidth
            ? constraints.maxWidth
            : maxWidth;

        return Center(
          child: SizedBox(width: width, child: child),
        );
      },
    );
  }
}

class CenteredSheetCanvas extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CenteredSheetCanvas({
    super.key,
    required this.child,
    this.maxWidth = 520,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < maxWidth
            ? constraints.maxWidth
            : maxWidth;

        return Center(
          heightFactor: 1,
          child: SizedBox(width: width, child: child),
        );
      },
    );
  }
}

class StickyColor {
  final String name;
  final String label;
  final Color background;
  final Color border;

  const StickyColor({
    required this.name,
    required this.label,
    required this.background,
    required this.border,
  });
}

const stickyColors = [
  StickyColor(
    name: 'butter',
    label: 'Butter',
    background: Color(0xFFFEF9C3),
    border: Color(0xFFFEF08A),
  ),
  StickyColor(
    name: 'peach',
    label: 'Peach',
    background: Color(0xFFFFEDD5),
    border: Color(0xFFFED7AA),
  ),
  StickyColor(
    name: 'sky',
    label: 'Sky',
    background: Color(0xFFE0F2FE),
    border: Color(0xFFBAE6FD),
  ),
  StickyColor(
    name: 'mint',
    label: 'Mint',
    background: Color(0xFFDCFCE7),
    border: Color(0xFFBBF7D0),
  ),
  StickyColor(
    name: 'lavender',
    label: 'Lavender',
    background: Color(0xFFEDE9FE),
    border: Color(0xFFDDD6FE),
  ),
  StickyColor(
    name: 'rose',
    label: 'Rose',
    background: Color(0xFFFFE4E6),
    border: Color(0xFFFECDD3),
  ),
];

StickyColor stickyColorFor(String name) {
  return stickyColors.firstWhere(
    (color) => color.name == name,
    orElse: () => stickyColors.first,
  );
}
