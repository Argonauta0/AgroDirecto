import 'package:flutter/material.dart';
import '../tema_app.dart';

class IndicadorModoRural extends StatefulWidget {
  const IndicadorModoRural({super.key});

  @override
  State<IndicadorModoRural> createState() => _IndicadorModoRuralState();
}

class _IndicadorModoRuralState extends State<IndicadorModoRural> {
  bool _sincronizado = true;

  void _alternar() {
    setState(() {
      _sincronizado = !_sincronizado;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Estado "sin conexión" usa relleno sólido en vez de un tinte diluido:
    // naranja de marca a esta opacidad no alcanza el contraste 3:1 que
    // exige WCAG para texto/íconos, así que se resuelve con
    // ColoresApp.colorTextoSobre para garantizar accesibilidad.
    final Color colorFondo =
        _sincronizado ? ColoresApp.verdeClaro.withValues(alpha: 0.2) : ColoresApp.naranjaAviso;
    final Color colorTexto =
        _sincronizado ? ColoresApp.verdeOscuro : ColoresApp.colorTextoSobre(ColoresApp.naranjaAviso);
    final IconData icono = _sincronizado ? Icons.cloud_done : Icons.cloud_off;
    final String texto = _sincronizado ? 'Sincronizado' : 'Modo Campo (Sin Conexión)';

    return GestureDetector(
      onTap: _alternar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(20),
          border: _sincronizado ? Border.all(color: colorTexto, width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 16, color: colorTexto),
            const SizedBox(width: 6),
            Text(
              texto,
              style: TextStyle(color: colorTexto, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
