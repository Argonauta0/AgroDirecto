import 'package:flutter/material.dart';

class ColoresApp {
  static const Color verdePrincipal = Color(0xFF2E7D32);
  static const Color verdeClaro = Color(0xFF81C784);
  static const Color verdeOscuro = Color(0xFF1B5E20);
  static const Color naranjaAviso = Color(0xFFF57C00);
  static const Color amarilloDestacado = Color(0xFFFFB300);
  static const Color blancoFondo = Color(0xFFFFFFFF);
}

class TemaApp {
  static ThemeData get temaClaro {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ColoresApp.blancoFondo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColoresApp.verdePrincipal,
        primary: ColoresApp.verdePrincipal,
        secondary: ColoresApp.verdeClaro,
        error: ColoresApp.naranjaAviso,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ColoresApp.verdePrincipal,
        foregroundColor: ColoresApp.blancoFondo,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.verdePrincipal,
          foregroundColor: ColoresApp.blancoFondo,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: ColoresApp.verdeOscuro, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: ColoresApp.verdeOscuro, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: ColoresApp.blancoFondo,
      ),
    );
  }
}
