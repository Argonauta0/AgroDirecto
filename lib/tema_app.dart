import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de marca de AgroDirecto. Cada color tiene un rol semántico fijo;
/// no deben usarse fuera del uso documentado para mantener la coherencia visual.
class ColoresApp {
  ColoresApp._();

  /// Marca / CTA primario, AppBars, bordes activos.
  static const Color verdePrincipal = Color(0xFF2E7D32);

  /// Máxima jerarquía tipográfica, estados hover/pressed, iconos activos.
  static const Color verdeOscuro = Color(0xFF1B5E20);

  /// Fondos de tarjetas secundarias, chips "Disponible", divisores suaves.
  static const Color verdeClaro = Color(0xFF81C784);

  /// Acción comercial (WhatsApp/contacto), precios, ofertas destacadas.
  static const Color naranjaAviso = Color(0xFFF57C00);

  /// Estados pendientes/negociación, calificaciones, avisos y comisiones.
  static const Color amarilloDestacado = Color(0xFFFFB300);

  /// Fondos de pantalla, tarjetas y modales.
  static const Color blancoFondo = Color(0xFFFFFFFF);

  /// Texto/ícono accesible (WCAG AA) para colocar sobre un fondo sólido de marca.
  /// Verde principal y verde oscuro son suficientemente oscuros para texto blanco;
  /// el resto de la paleta (verde claro, naranja, dorado) exige texto oscuro:
  /// p.ej. blanco sobre `naranjaAviso` da un contraste de ~2.7:1 (no cumple AA),
  /// mientras que negro/87% sobre `naranjaAviso` da ~7.8:1.
  static Color colorTextoSobre(Color fondo) {
    if (fondo == verdePrincipal || fondo == verdeOscuro) return Colors.white;
    return Colors.black87;
  }

  /// Variante de un color de marca segura para usarse como ícono o texto
  /// pequeño directamente sobre fondos claros (blanco o tintes muy diluidos).
  /// Los colores con luminancia relativa alta (naranja, dorado, verde claro)
  /// no alcanzan el mínimo de contraste 3:1 exigido por WCAG para estos usos.
  static Color colorAcentoAccesible(Color colorMarca) {
    return colorMarca.computeLuminance() > 0.3 ? Colors.black87 : colorMarca;
  }
}

class TemaApp {
  TemaApp._();

  static TextTheme get _textoBase {
    return TextTheme(
      // Poppins Bold: títulos, encabezados, precios destacados, diálogos.
      displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: ColoresApp.verdeOscuro),
      displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: ColoresApp.verdeOscuro),
      displaySmall: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: ColoresApp.verdeOscuro),
      headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: ColoresApp.verdeOscuro),
      headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: ColoresApp.verdeOscuro),
      headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: ColoresApp.verdeOscuro),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: ColoresApp.verdeOscuro,
      ),
      titleMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: ColoresApp.verdeOscuro,
      ),
      titleSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: ColoresApp.verdeOscuro,
      ),
      // Montserrat Regular/Medium: cuerpo, formularios, chips informativos.
      bodyLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: Colors.black87,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: Colors.black54,
      ),
      labelLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: Colors.black87,
      ),
      labelMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: Colors.black87,
      ),
      labelSmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.w500,
        fontSize: 11,
        color: Colors.black54,
      ),
    );
  }

  /// Botón de acción comercial (ej. "Contactar por WhatsApp", "Confirmar pedido").
  /// Usa negro/87% en vez de blanco sobre naranja para cumplir contraste WCAG AA.
  static ButtonStyle get botonNaranja => ElevatedButton.styleFrom(
        backgroundColor: ColoresApp.naranjaAviso,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  static ThemeData get temaClaro {
    final ColorScheme esquemaColores = ColorScheme.fromSeed(
      seedColor: ColoresApp.verdePrincipal,
      brightness: Brightness.light,
    ).copyWith(
      primary: ColoresApp.verdePrincipal,
      onPrimary: Colors.white,
      // Nota: verdeClaro es demasiado claro para que verdeOscuro cumpla 4.5:1
      // como texto sobre un contenedor sólido, así que estos "on*" usan negro/87%.
      primaryContainer: ColoresApp.verdeClaro,
      onPrimaryContainer: Colors.black87,
      secondary: ColoresApp.naranjaAviso,
      onSecondary: Colors.black87,
      secondaryContainer: ColoresApp.verdeClaro,
      onSecondaryContainer: Colors.black87,
      tertiary: ColoresApp.amarilloDestacado,
      onTertiary: Colors.black87,
      surface: ColoresApp.blancoFondo,
      onSurface: Colors.black87,
      error: const Color(0xFFC62828),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ColoresApp.blancoFondo,
      colorScheme: esquemaColores,
      textTheme: _textoBase,
      fontFamily: GoogleFonts.montserrat().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: ColoresApp.verdePrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.verdePrincipal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: ColoresApp.verdePrincipal.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColoresApp.verdePrincipal,
          side: const BorderSide(color: ColoresApp.verdePrincipal),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColoresApp.verdePrincipal,
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColoresApp.blancoFondo,
        labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500, color: Colors.black54),
        hintStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: Colors.black45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColoresApp.verdePrincipal, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: ColoresApp.blancoFondo,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ColoresApp.verdeClaro.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500, color: ColoresApp.verdeOscuro),
        selectedColor: ColoresApp.verdeClaro.withValues(alpha: 0.35),
        secondarySelectedColor: ColoresApp.verdeClaro.withValues(alpha: 0.35),
        checkmarkColor: ColoresApp.verdeOscuro,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey.shade300, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColoresApp.verdeOscuro,
        contentTextStyle: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ColoresApp.blancoFondo,
        titleTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: ColoresApp.verdeOscuro,
        ),
        contentTextStyle: GoogleFonts.montserrat(fontSize: 14, color: Colors.black87),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
