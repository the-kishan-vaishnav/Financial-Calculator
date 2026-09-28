import 'package:flutter/material.dart';

class AppTheme {
  // --- 1. BRAND COLOR PALETTE ---
  static const Color growwGreen = Color(0xFF00D09C);
  static const Color growwBg = Colors.white;
  static const Color growwText = Color(0xFF44474b);
  static const Color growwSubText = Color(0xFF7c7e8c);
  static const Color growwBorder = Color(0xFFedf2f7);
  static const Color growwInputFill = Color(0xFFF9FAFB);

  // Chart Colors
  static const Color chartPrincipal = Color(0xFF5367FF); // Soft Blue
  static const Color chartInterest = growwGreen;
  static const Color chartFees = Color(0xFFFF9F43); // Soft Orange

  // --- 2. DIMENSIONS & SPACING ---
  static const double screenPadding = 20.0;
  static const double cardPadding = 20.0;
  static const double borderRadius = 12.0;
  static const double elementSpacing = 16.0;

  // --- 3. TEXT STYLES ---
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: growwText,
  );

  static const TextStyle subHeadlineStyle = TextStyle(
    fontSize: 14,
    color: growwSubText,
  );

  static const TextStyle cardTitleStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: growwSubText,
  );

  static const TextStyle resultMainStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: growwGreen,
  );

  static const TextStyle labelStyle = TextStyle(
    color: growwSubText,
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  static const TextStyle valueStyle = TextStyle(
    color: growwText,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  // --- 4. DECORATIONS ---
  static BoxDecoration premiumCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: growwBorder, width: 1.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // --- 5. REUSABLE UI COMPONENTS (Static Methods) ---

  // Standard Input Field Decoration
  static InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: growwText, size: 20),
      hintText: label,
      filled: true,
      fillColor: growwInputFill,
      contentPadding: const EdgeInsets.all(16),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: growwBorder),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: growwGreen, width: 1.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  // Common Headline Widget
  static Widget buildHeadline(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: headlineStyle),
          Text(subtitle, style: subHeadlineStyle),
        ],
      ),
    );
  }

  // Common Result Row Widget
  static Widget buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }

  // Breakdown Item Decoration (For the Schedule list)
  static BoxDecoration breakdownDecoration = const BoxDecoration(
    border: Border(bottom: BorderSide(color: growwBorder, width: 1)),
  );
}
