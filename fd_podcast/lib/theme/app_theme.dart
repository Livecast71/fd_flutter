import 'package:flutter/material.dart';

class AppTheme {
  // FD Design System Colors & Typography (from https://design-system.fd.nl/tokens)
  
  // Font Families
  static const String fontFamilyRegular = 'ProximaNovaRegular';
  static const String fontFamilyBold = 'ProximaNovaBold';
  static const String fontFamilySerifRegular = 'ArnhemProBlond';
  static const String fontFamilySerifBold = 'ArnhemProBold';
  
  // Base font size (1rem = 16px)
  static const double baseFontSize = 16.0;
  
  // Primary Colors
  static const Color primary100 = Color(0xFF0B646B); // Primary 100
  static const Color primary75 = Color(0xFF379596);  // Primary 75
  static const Color primary50 = Color(0xFF41AFB0);  // Primary 50
  static const Color primary25 = Color(0xFFB0C6C1);  // Primary 25
  
  // Secondary Colors
  static const Color secondary100 = Color(0xFFE66C10); // Secondary 100
  static const Color secondary75 = Color(0xFFF27211);  // Secondary 75
  static const Color secondary50 = Color(0xFFFF7812);  // Secondary 50
  static const Color secondary25 = Color(0xFFFF9A4E);  // Secondary 25
  
  // Neutral Colors
  static const Color neutral0 = Color(0xFF000000);     // Black
  static const Color neutral10 = Color(0xFF191919);   // Dark text
  static const Color neutral20 = Color(0xFF332F2C);
  static const Color neutral30 = Color(0xFF4C4642);
  static const Color neutral40 = Color(0xFF73655F);
  static const Color neutral50 = Color(0xFFA6988F);
  static const Color neutral60 = Color(0xFFCDBEB4);   // Muted brown/accent
  static const Color neutral70 = Color(0xFFE5D1C6);
  static const Color neutral80 = Color(0xFFF1DED2);
  static const Color neutral90 = Color(0xFFFFEADB);   // Cream/beige background
  static const Color neutral100 = Color(0xFFFFFFFF);  // White
  
  // Legacy aliases for compatibility
  static const Color primaryColor = neutral10;        // Dark text
  static const Color secondaryColor = neutral90;     // Cream/beige background
  static const Color accentColor = neutral60;        // Muted brown
  static const Color cardBackground = neutral100;    // White
  static const Color dividerColor = neutral70;       // Light divider
  static const Color textSecondary = neutral40;      // Secondary text

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary100,
        primary: primary100,
        secondary: secondary100,
        surface: cardBackground,
        onPrimary: neutral100,
        onSecondary: neutral100,
        onSurface: neutral10,
      ),
      scaffoldBackgroundColor: secondaryColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary100,
        foregroundColor: neutral100,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: neutral100,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      textTheme: TextTheme(
        // Headings - using ProximaNovaBold, line-height 1.2
        // Heading M (1.44rem = 23.04px)
        headlineLarge: TextStyle(
          fontSize: baseFontSize * 1.44, // 1.44rem
          fontWeight: FontWeight.bold,
          fontFamily: fontFamilyBold,
          height: 1.2,
          color: neutral10,
        ),
        // Heading S (1.2rem = 19.2px)
        headlineMedium: TextStyle(
          fontSize: baseFontSize * 1.2, // 1.2rem
          fontWeight: FontWeight.bold,
          fontFamily: fontFamilyBold,
          height: 1.2,
          color: neutral10,
        ),
        // Heading XS (1rem = 16px)
        titleLarge: TextStyle(
          fontSize: baseFontSize * 1.0, // 1rem
          fontWeight: FontWeight.bold,
          fontFamily: fontFamilyBold,
          height: 1.2,
          color: neutral10,
        ),
        // Body M (1.2rem = 19.2px)
        titleMedium: TextStyle(
          fontSize: baseFontSize * 1.2, // 1.2rem
          fontWeight: FontWeight.normal,
          fontFamily: fontFamilyRegular,
          height: 1.4,
          color: neutral10,
        ),
        // Body M (1.2rem = 19.2px)
        bodyLarge: TextStyle(
          fontSize: baseFontSize * 1.2, // 1.2rem
          fontWeight: FontWeight.normal,
          fontFamily: fontFamilyRegular,
          height: 1.4,
          color: neutral10,
        ),
        // Body S (1rem = 16px)
        bodyMedium: TextStyle(
          fontSize: baseFontSize * 1.0, // 1rem
          fontWeight: FontWeight.normal,
          fontFamily: fontFamilyRegular,
          height: 1.4,
          color: neutral10,
        ),
        // Body XS (0.875rem = 14px)
        bodySmall: TextStyle(
          fontSize: baseFontSize * 0.875, // 0.875rem
          fontWeight: FontWeight.normal,
          fontFamily: fontFamilyRegular,
          height: 1.4,
          color: neutral40,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: neutral70,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary50,              // Use primary 50 for dark mode
        secondary: secondary50,          // Use secondary 50 for dark mode
        surface: neutral20,              // Use neutral 20 for cards/surface
        background: neutral10,           // Use neutral 10 for background
        onPrimary: neutral100,
        onSecondary: neutral100,
        onSurface: neutral90,
      ),
      scaffoldBackgroundColor: neutral10,
      appBarTheme: const AppBarTheme(
        backgroundColor: neutral20,
        foregroundColor: neutral90,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: neutral90,
        ),
      ),
      cardTheme: CardThemeData(
        color: neutral20,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      textTheme: TextTheme(
        // Headings - using ProximaNovaBold, line-height 1.2
        headlineLarge: TextStyle(
          fontSize: baseFontSize * 1.44, // 1.44rem
          fontWeight: FontWeight.bold,
          fontFamily: fontFamilyBold,
          height: 1.2,
          color: neutral90,
        ),
        headlineMedium: TextStyle(
          fontSize: baseFontSize * 1.2, // 1.2rem
          fontWeight: FontWeight.bold,
          fontFamily: fontFamilyBold,
          height: 1.2,
          color: neutral90,
        ),
        titleLarge: TextStyle(
          fontSize: baseFontSize * 1.0, // 1rem
          fontWeight: FontWeight.bold,
          fontFamily: fontFamilyBold,
          height: 1.2,
          color: neutral90,
        ),
        titleMedium: TextStyle(
          fontSize: baseFontSize * 1.2, // 1.2rem
          fontWeight: FontWeight.normal,
          fontFamily: fontFamilyRegular,
          height: 1.4,
          color: neutral90,
        ),
        bodyLarge: TextStyle(
          fontSize: baseFontSize * 1.2, // 1.2rem
          fontWeight: FontWeight.normal,
          fontFamily: fontFamilyRegular,
          height: 1.4,
          color: neutral90,
        ),
        bodyMedium: TextStyle(
          fontSize: baseFontSize * 1.0, // 1rem
          fontWeight: FontWeight.normal,
          fontFamily: fontFamilyRegular,
          height: 1.4,
          color: neutral70,
        ),
        bodySmall: TextStyle(
          fontSize: baseFontSize * 0.875, // 0.875rem
          fontWeight: FontWeight.normal,
          fontFamily: fontFamilyRegular,
          height: 1.4,
          color: neutral60,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: neutral30,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

