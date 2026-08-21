import 'package:flutter/material.dart';
import '../datos_en_memoria.dart';
import '../modelos/modelo_producto.dart';
import '../tema_app.dart';

class TarjetaProducto extends StatelessWidget {
  final ModeloProducto producto;
  final VoidCallback onTap;

  const TarjetaProducto({super.key, required this.producto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final productor = DatosEnMemoria.obtenerProductorPorId(producto.productorId);
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
                    child: Icon(producto.icono, color: ColoresApp.verdePrincipal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '${productor?.nombre ?? 'Productor'} · ${productor?.comunidad ?? ''}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (producto.esTratoDirecto)
                    const Icon(Icons.verified, color: ColoresApp.verdePrincipal, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'C\$${producto.precioPorUnidad.toStringAsFixed(0)} / ${producto.tipoUnidad}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
