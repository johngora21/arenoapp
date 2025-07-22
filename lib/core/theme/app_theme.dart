import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors from Areno Logistics
  static const Color primaryOrange = Color(0xFFF97316); // #f97316
  static const Color primaryBlue = Color(0xFF3B82F6); // #3b82f6
  static const Color primaryDarkBlue = Color(0xFF1E293B); // #1e293b
  static const Color slate900 = Color(0xFF0F172A); // #0f172a
  static const Color slate800 = Color(0xFF1E293B); // #1e293b
  static const Color slate700 = Color(0xFF334155); // #334155
  static const Color slate600 = Color(0xFF475569); // #475569
  static const Color slate500 = Color(0xFF64748B); // #64748b
  static const Color slate400 = Color(0xFF94A3B8); // #94a3b8
  static const Color slate300 = Color(0xFFCBD5E1); // #cbd5e1
  static const Color slate200 = Color(0xFFE2E8F0); // #e2e8f0
  static const Color slate100 = Color(0xFFF1F5F9); // #f1f5f9
  static const Color slate50 = Color(0xFFF8FAFC); // #f8fafc
  
  static const Color successGreen = Color(0xFF22C55E); // #22c55e
  static const Color warningYellow = Color(0xFFEAB308); // #eab308
  static const Color errorRed = Color(0xFFEF4444); // #ef4444
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrange, Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient slateGradient = LinearGradient(
    colors: [slate50, slate100, slate200],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [slate900, slate800],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Text Styles
  static TextStyle get heading1 => GoogleFonts.poppins(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: slate900,
    height: 1.2,
  );
  
  static TextStyle get heading2 => GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: slate900,
    height: 1.3,
  );
  
  static TextStyle get heading3 => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: slate900,
    height: 1.4,
  );
  
  static TextStyle get heading4 => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: slate900,
    height: 1.4,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: slate700,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: slate600,
    height: 1.5,
  );
  
  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: slate500,
    height: 1.5,
  );
  
  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: slate500,
    height: 1.4,
  );
  
  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  // Theme Data
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: primaryOrange,
      secondary: primaryBlue,
      surface: Colors.white,
      background: slate50,
      error: errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: slate900,
      onBackground: slate900,
      onError: Colors.white,
    ),
    textTheme: TextTheme(
      displayLarge: heading1,
      displayMedium: heading2,
      displaySmall: heading3,
      headlineLarge: heading3,
      headlineMedium: heading4,
      headlineSmall: heading4,
      titleLarge: bodyLarge.copyWith(fontWeight: FontWeight.w600),
      titleMedium: bodyMedium.copyWith(fontWeight: FontWeight.w600),
      titleSmall: bodySmall.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: button,
      labelMedium: caption,
      labelSmall: caption.copyWith(fontSize: 10),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: primaryOrange.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryOrange,
        side: const BorderSide(color: primaryOrange, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: button.copyWith(color: primaryOrange),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: slate300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: slate300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: bodyMedium.copyWith(color: slate400),
    ),
    cardTheme: CardTheme(
      elevation: 8,
      shadowColor: slate900.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: slate900,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: heading4.copyWith(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryOrange,
      unselectedItemColor: slate500,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
