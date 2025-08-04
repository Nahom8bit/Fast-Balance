import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  
  static ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.teal,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cardTheme: CardTheme(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        labelStyle: const TextStyle(color: Colors.black87),
        hintStyle: const TextStyle(color: Colors.black54),
        floatingLabelStyle: const TextStyle(color: Colors.teal),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black87),
        bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.0, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black87),
        labelLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
        labelMedium: TextStyle(fontSize: 14.0, color: Colors.black87),
        labelSmall: TextStyle(fontSize: 12.0, color: Colors.black54),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: Colors.black87,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: Colors.black87,
        iconColor: Colors.black87,
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 16),
        subtitleTextStyle: TextStyle(color: Colors.black54, fontSize: 14),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.teal,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      cardTheme: CardTheme(
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        color: const Color(0xFF2D2D2D),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3A3A3A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
        floatingLabelStyle: const TextStyle(color: Colors.teal),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.0, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white),
        labelLarge: TextStyle(fontSize: 16.0, color: Colors.white),
        labelMedium: TextStyle(fontSize: 14.0, color: Colors.white),
        labelSmall: TextStyle(fontSize: 12.0, color: Colors.white70),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        iconColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
        subtitleTextStyle: TextStyle(color: Colors.white70, fontSize: 14),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        contentTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        dataTextStyle: const TextStyle(color: Colors.white),
        dividerThickness: 1,
        columnSpacing: 16,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF3A3A3A),
        labelStyle: const TextStyle(color: Colors.white),
        selectedColor: Colors.teal,
        disabledColor: const Color(0xFF2A2A2A),
        secondarySelectedColor: Colors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? 'system';
    
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeString;
    
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    
    await prefs.setString(_themeKey, themeString);
  }

  static String getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
} 