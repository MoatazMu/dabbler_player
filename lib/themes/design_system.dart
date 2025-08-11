import 'package:flutter/material.dart';

class DS {
  // Spacing
  static const double gap2 = 2;
  static const double gap4 = 4;
  static const double gap6 = 6;
  static const double gap8 = 8;
  static const double gap12 = 12;
  static const double gap16 = 16;
  static const double cardPadding = 16;

  // Border radius
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(20));

  // Colors (replace with your theme if needed)
  static Color get primary => Colors.blue;
  static Color get background => Colors.white;
  static Color get border => Colors.grey.shade200;
  static Color get surface => Colors.white;
  static Color get onSurface => Colors.black87;
  static Color get onSurfaceVariant => const Color.fromARGB(255, 190, 190, 190);
  static Color get success => Colors.green;
  static Color get warning => Colors.orange;
  static Color get error => Colors.red;

  // Text styles
  static TextStyle get headline => const TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static TextStyle get subtitle => const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static TextStyle get body => const TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  static TextStyle get caption => TextStyle(fontSize: 12, color: Colors.grey.shade600);

  // Icon sizes
  static const double iconSmall = 16;
  static const double iconMedium = 24;
  static const double iconLarge = 32;

  // Button style
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: primary,
    shape: RoundedRectangleBorder(borderRadius: cardRadius),
    minimumSize: const Size.fromHeight(48),
    textStyle: subtitle.copyWith(color: Colors.white),
  );

  // Chip style
  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: border,
    selectedColor: primary.withOpacity(0.15),
    shape: RoundedRectangleBorder(borderRadius: chipRadius),
    labelStyle: body,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  );

  // Card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: background,
    borderRadius: cardRadius,
    border: Border.all(color: border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Skeleton loader
  static Widget skeleton({double height = 16, double width = double.infinity, BorderRadius? radius}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: radius ?? BorderRadius.circular(8),
      ),
    );
  }

  // Empty state
  static Widget emptyState({required String message, IconData icon = Icons.search}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 48, color: primary),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: headline.copyWith(fontWeight: FontWeight.w700, color: onSurface),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 