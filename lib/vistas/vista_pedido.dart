import 'package:flutter/material.dart';
import '../datos_en_memoria.dart';
import '../modelos/modelo_pedido.dart';
import '../modelos/modelo_producto.dart';
import '../tema_app.dart';
import '../utilidades/formato_fecha.dart';
import '../widgets/indicador_modo_rural.dart';

class VistaPedido extends StatefulWidget {
  final Producto producto;
  final int cantidadInicial;

  const VistaPedido({super.key, required this.producto, required this.cantidadInicial});

  @override
  State<VistaPedido> createState() => _VistaPedidoState();
}

class _VistaPedidoState extends State<VistaPedido> {
  late int _cantidad;

  @override
  void initState() {
    super.initState();
    _cantidad = widget.cantidadInicial;
  }

  double get _total => _cantidad * widget.producto.precioPorUnidad;

  void _cambiarCantidad(int delta) {
    final int nueva = _cantidad + delta;
    if (nueva < 1) return;
    if (nueva > widget.producto.cantidadDisponible) return;
    setState(() => _cantidad = nueva);
  }

  void _confirmarPedido() {
    final productor = DatosEnMemoria.obtenerProductorPorId(widget.producto.productorId);
    final compradorActual = DatosEnMemoria.compradorActual;

    final pedido = Pedido(
      id: 'ped_${DateTime.now().millisecondsSinceEpoch}',
      productoId: widget.producto.id,
      compradorId: compradorActual?.id ?? '',
      cantidadSolicitada: _cantidad,
      totalPagar: _total,
      fecha: DateTime.now(),
    );
    DatosEnMemoria.agregarPedido(pedido);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle, color: ColoresApp.verdePrincipal, size: 48),
        title: const Text('¡Pedido Coordinado!'),
        content: Text(
          'Tu reserva de $_cantidad ${widget.producto.tipoUnidad.toLowerCase()} de '
          '${widget.producto.nombre} fue enviada a ${productor?.nombre ?? 'el productor'}. '
          'Se coordinará la entrega directamente contigo.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Volver al Catálogo'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final productor = DatosEnMemoria.obtenerProductorPorId(producto.productorId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Pedido'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: IndicadorModoRural()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(producto.icono, color: ColoresApp.verdePrincipal, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(producto.nombre, style: Theme.of(context).textTheme.titleLarge),
                              Text(
                                '${productor?.nombre ?? 'Productor'} · ${productor?.comunidad ?? ''}',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.verified, color: ColoresApp.verdePrincipal),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sello de Trazabilidad · Cosecha: ${formatearFecha(producto.fechaCosecha)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColoresApp.amarilloDestacado.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.eco, color: ColoresApp.naranjaAviso, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Impacto directo: este trato beneficia a ${productor?.nombre ?? 'el productor'} y a la comunidad de ${productor?.comunidad ?? '-'}.',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Datos del comprador', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColoresApp.verdeClaro.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColoresApp.verdeClaro),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront, color: ColoresApp.verdePrincipal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      DatosEnMemoria.compradorActual?.nombreNegocio ??
                          'Sesión de comprador no encontrada',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Volumen a reservar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  onPressed: () => _cambiarCantidad(-1),
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$_cantidad ${producto.tipoUnidad}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton.filledTonal(
                  onPressed: () => _cambiarCantidad(1),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              color: ColoresApp.verdeOscuro,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total a pagar', style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text(
                      'C\$${_total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: ColoresApp.amarilloDestacado,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmarPedido,
                icon: const Icon(Icons.support_agent),
                label: const Text('Confirmar y Coordinar Entrega'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
