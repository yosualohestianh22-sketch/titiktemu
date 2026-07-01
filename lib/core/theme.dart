import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Warna Utama Light Theme (Vibrant Indigo)
  static const Color primaryColor = Color(0xFF6366F1);
  
  // Warna Utama Dark Theme (Glowing Indigo)
  static const Color darkPrimaryColor = Color(0xFF818CF8);

  // Warna Latar Light Theme
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF1E293B); // Slate 800
  static const Color secondaryTextColor = Color(0xFF64748B); // Slate 500

  // Warna Latar Dark Theme (Deep Midnight Indigo-Slate)
  static const Color darkBackgroundColor = Color(0xFF0A0A14);
  static const Color darkSurfaceColor = Color(0xFF16162A);
  static const Color darkTextColor = Color(0xFFF8FAFC); // Slate 50
  static const Color darkSecondaryTextColor = Color(0xFF94A3B8); // Slate 400

  // Konfigurasi ThemeData Material 3 - Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: backgroundColor,
        onSurface: textColor,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme.apply(
          bodyColor: textColor,
          displayColor: textColor,
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFFF9FAFB), // Background abu-abu muda bersih
      cardColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white, // Kontras tinggi teks putih di atas tombol biru/indigo
          elevation: 2,
          shadowColor: primaryColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: secondaryTextColor),
        prefixIconColor: secondaryTextColor,
        suffixIconColor: secondaryTextColor,
      ),
    );
  }

  // Konfigurasi ThemeData Material 3 - Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimaryColor,
        primary: darkPrimaryColor,
        surface: darkSurfaceColor,
        onSurface: darkTextColor,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: darkTextColor,
          displayColor: darkTextColor,
        ),
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      cardColor: darkSurfaceColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkTextColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkTextColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: const Color(0xFF0F172A), // Teks gelap tajam di atas tombol terang glow
          elevation: 4,
          shadowColor: darkPrimaryColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F1F35),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: darkSecondaryTextColor),
        prefixIconColor: darkSecondaryTextColor,
        suffixIconColor: darkSecondaryTextColor,
      ),
    );
  }
}
