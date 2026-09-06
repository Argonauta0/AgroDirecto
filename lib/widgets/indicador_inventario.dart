import 'package:flutter/material.dart';
import '../tema_app.dart';

/// Control visual de inventario: barra de progreso + texto que muestra
/// cuánto queda disponible de un lote frente al total publicado. Se usa en
/// el catálogo, la ficha de trazabilidad, el pedido y el panel del
/// productor para reflejar el manejo automático de stock (compras
/// parciales que descuentan cantidad hasta llegar a cero).
class IndicadorInventario extends StatelessWidget {
  final int cantidadDisponible;
  final int cantidadTotal;
  final String unidadEtiqueta;
  final bool compacto;

  const IndicadorInventario({
    super.key,
    required this.cantidadDisponible,
    required this.cantidadTotal,
    required this.unidadEtiqueta,
    this.compacto = false,
  });

  double get _proporcion {
    if (cantidadTotal <= 0) return 0;
    return (cantidadDisponible / cantidadTotal).clamp(0, 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final int vendido = cantidadTotal - cantidadDisponible;
    final Color colorBarra =
        cantidadDisponible <= 0 ? Colors.grey.shade400 : ColoresApp.verdePrincipal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _proporcion,
            minHeight: compacto ? 6 : 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(colorBarra),
          ),
        ),
        SizedBox(height: compacto ? 4 : 6),
        Text(
          cantidadDisponible > 0
              ? '$cantidadDisponible de $cantidadTotal ${unidadEtiqueta}s disponibles'
                  '${vendido > 0 ? ' · $vendido vendido${vendido == 1 ? '' : 's'}' : ''}'
              : 'Sin unidades disponibles · $cantidadTotal ${unidadEtiqueta}s vendidos',
          style: TextStyle(
            fontSize: compacto ? 11 : 13,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
