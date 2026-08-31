import 'package:flutter/material.dart';
import '../datos_en_memoria.dart';
import '../modelos/modelo_oferta_lote.dart';
import '../tema_app.dart';
import 'indicador_inventario.dart';

class TarjetaProducto extends StatelessWidget {
  final OfertaLote oferta;
  final VoidCallback onTap;
  final VoidCallback? onEliminar;

  const TarjetaProducto({
    super.key,
    required this.oferta,
    required this.onTap,
    this.onEliminar,
  });

  /// Fondo del chip de estado. "Activa" usa un tinte suave (estado normal);
  /// "Parcialmente Vendida" y "Pausada" usan relleno sólido para llamar la
  /// atención; "Agotada" usa gris neutro. El texto se resuelve con
  /// [ColoresApp.colorTextoSobre] para garantizar contraste WCAG AA.
  Color _fondoEstado(OfertaLote oferta) {
    if (oferta.estado == EstadoOferta.pausada) return ColoresApp.naranjaAviso;
    if (oferta.estado == EstadoOferta.agotado) return Colors.grey.shade300;
    if (oferta.cantidadDisponible < oferta.cantidadTotal) return ColoresApp.amarilloDestacado;
    return ColoresApp.verdeClaro.withValues(alpha: 0.25);
  }

  Color _textoEstado(OfertaLote oferta) {
    if (oferta.estado == EstadoOferta.agotado) return Colors.black54;
    if (oferta.estado == EstadoOferta.disponible &&
        oferta.cantidadDisponible >= oferta.cantidadTotal) {
      return ColoresApp.verdeOscuro;
    }
    return ColoresApp.colorTextoSobre(_fondoEstado(oferta));
  }

  @override
  Widget build(BuildContext context) {
    final producto = DatosEnMemoria.obtenerProductoPorId(oferta.productoId);
    final productor = DatosEnMemoria.obtenerUsuarioPorId(oferta.productorId);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: ColoresApp.verdeClaro.withValues(alpha: 0.3),
                    child: const Icon(Icons.eco, color: ColoresApp.verdePrincipal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto?.nombre ?? 'Producto',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (producto?.categoria != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            producto!.categoria,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _fondoEstado(oferta),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      oferta.estadoVisualTexto,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _textoEstado(oferta),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Origen del lote: quién lo produce y de dónde viene.
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      productor?.nombreCompleto ?? 'Productor',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: ColoresApp.verdeOscuro),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      productor != null
                          ? '${productor.municipio}, ${productor.departamento}'
                          : 'Ubicación no disponible',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.verdeOscuro,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              IndicadorInventario(
                cantidadDisponible: oferta.cantidadDisponible,
                cantidadTotal: oferta.cantidadTotal,
                unidadEtiqueta: oferta.unidadMedida.etiqueta.toLowerCase(),
                compacto: true,
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: ColoresApp.naranjaAviso,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sell, size: 14, color: Colors.black87),
                        const SizedBox(width: 4),
                        Text(
                          'C\$${oferta.precioUnitario.toStringAsFixed(0)} / ${oferta.unidadMedida.etiqueta}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.local_shipping_outlined, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      oferta.modalidadLogistica.etiqueta,
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onEliminar != null)
                    TextButton.icon(
                      onPressed: onEliminar,
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      label: const Text('Borrar', style: TextStyle(color: Colors.red, fontSize: 13)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
