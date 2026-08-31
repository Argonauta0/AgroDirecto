import 'package:flutter/material.dart';
import '../datos_en_memoria.dart';
import '../modelos/modelo_oferta_lote.dart';
import '../tema_app.dart';

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
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '${productor?.nombreCompleto ?? 'Productor'} · ${productor?.municipio ?? ''}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColoresApp.naranjaAviso,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'C\$${oferta.precioUnitario.toStringAsFixed(0)} / ${oferta.unidadMedida.etiqueta}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Spacer(),
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
