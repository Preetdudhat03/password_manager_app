import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🌑 DARK THEME (Primary)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0E1116), // Background
    
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B82F6),       // Primary Blue
      onPrimary: Colors.white,
      secondary: Color(0xFF1E3A8A),     // Primary Soft
      onSecondary: Colors.white,
      surface: Color(0xFF161B22),       // Surface
      onSurface: Color(0xFFE6EDF3),     // Text Primary
      onSurfaceVariant: Color(0xFF9AA4B2), // Text Secondary
      outline: Color(0xFF2A3140),       // Divider
      outlineVariant: Color(0xFF6B7280), // Hint
      error: Color(0xFFEF4444),         // Error Red
      onError: Colors.white,
      background: Color(0xFF0E1116),    // Background
    ),

    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: const Color(0xFFE6EDF3),
      displayColor: const Color(0xFFE6EDF3),
    ),
    
    cardTheme: CardThemeData(
      color: const Color(0xFF161B22), // Surface
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF2A3140), width: 1), // Divider
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0E1116), // Input Background (using Main Background for contrast against Surface Card)
      // Or user said Surface is input containers? User said "Card / Surface: #161B22 cards, input containers".
      // Let's use #161B22 if inputs are on background, but if inputs are in cards..
      // Standard practice: Inputs on Surface should be Slightly Lighter or Darker.
      // Let's stick to the prompt "Surface #161B22 Cards, input containers". 
      // If Scaffold is #0E1116, Card is #161B22. Inputs inside cards might blend.
      // I'll make inputs #0E1116 (Darker) for depth.
      hintStyle: const TextStyle(color: Color(0xFF6B7280)), // Text Hint
      labelStyle: const TextStyle(color: Color(0xFF9AA4B2)), // Text Secondary
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A3140)), // Divider
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A3140)), // Divider
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF60A5FA), width: 1.5), // Focus Blue
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF3B82F6), // Primary Blue
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF60A5FA), // Focus Blue (Lighter for text links)
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF3B82F6), // Primary Blue
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0E1116), // Background
      foregroundColor: Color(0xFFE6EDF3), // Text Primary
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFE6EDF3)),
    ),
    
    // Modals
    // dialogTheme: ... (Removed to fix type mismatch, will rely on colorScheme.surface)
    
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF1C2330), // Surface Elevated
      contentTextStyle: TextStyle(color: Color(0xFFE6EDF3)),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A3140), // Divider
      thickness: 1,
    ),
  );
  
  // ☀️ LIGHT THEME (Accessibility)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Light Background
    
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2563EB),       // Light Primary Blue
      onPrimary: Colors.white,
      surface: Color(0xFFFFFFFF),       // Light Surface
      onSurface: Color(0xFF0F172A),     // Light Text Primary
      onSurfaceVariant: Color(0xFF475569), // Light Text Secondary
      outline: Color(0xFFE2E8F0),       // Light Divider
      outlineVariant: Color(0xFF94A3B8), // Light Text Hint
      error: Color(0xFFEF4444),         // Error Red
      background: Color(0xFFF8FAFC),    // Light Background
    ),

    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: const Color(0xFF0F172A),
      displayColor: const Color(0xFF0F172A),
    ),
    
    cardTheme: CardThemeData(
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1), // Light Divider
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)), // Light Hint
      labelStyle: const TextStyle(color: Color(0xFF475569)), // Light Secondary
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Light Divider
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5), // Light Focus Blue
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF2563EB), // Light Primary Blue
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF2563EB), 
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8FAFC),
      foregroundColor: Color(0xFF0F172A),
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF0F172A)),
    ),
    
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E8F0),
      thickness: 1,
    ),
  );
}
