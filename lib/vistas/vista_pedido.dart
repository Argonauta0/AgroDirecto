import 'package:flutter/material.dart';
import '../datos_en_memoria.dart';
import '../modelos/modelo_oferta_lote.dart';
import '../modelos/modelo_pedido.dart';
import '../tema_app.dart';
import '../utilidades/formato_fecha.dart';
import '../widgets/indicador_inventario.dart';

class VistaPedido extends StatefulWidget {
  final OfertaLote oferta;
  final int cantidadInicial;

  const VistaPedido({super.key, required this.oferta, required this.cantidadInicial});

  @override
  State<VistaPedido> createState() => _VistaPedidoState();
}

class _VistaPedidoState extends State<VistaPedido> {
  late int _cantidad;
  late ModalidadLogisticaPedido _modalidadSeleccionada;

  List<ModalidadLogisticaPedido> get _opcionesModalidad {
    switch (widget.oferta.modalidadLogistica) {
      case ModalidadLogisticaOferta.retiro:
        return const [ModalidadLogisticaPedido.retiro];
      case ModalidadLogisticaOferta.envioProductor:
        return const [ModalidadLogisticaPedido.envioProductor];
      case ModalidadLogisticaOferta.transportista:
        return const [ModalidadLogisticaPedido.transportista];
      case ModalidadLogisticaOferta.todas:
        return const [
          ModalidadLogisticaPedido.retiro,
          ModalidadLogisticaPedido.envioProductor,
          ModalidadLogisticaPedido.transportista,
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    _cantidad = widget.cantidadInicial;
    _modalidadSeleccionada = _opcionesModalidad.first;
  }

  double get _total => _cantidad * widget.oferta.precioUnitario;

  void _cambiarCantidad(int delta) {
    final int nueva = _cantidad + delta;
    if (nueva < 1) return;
    if (nueva > widget.oferta.cantidadDisponible) return;
    setState(() => _cantidad = nueva);
  }

  void _confirmarPedido() {
    final oferta = widget.oferta;
    final producto = DatosEnMemoria.obtenerProductoPorId(oferta.productoId);
    final productor = DatosEnMemoria.obtenerUsuarioPorId(oferta.productorId);
    final compradorActual = DatosEnMemoria.usuarioActual;

    final pedido = Pedido(
      id: 'ped_${DateTime.now().millisecondsSinceEpoch}',
      ofertaId: oferta.id,
      compradorId: compradorActual?.id ?? '',
      productorId: oferta.productorId,
      cantidadSolicitada: _cantidad,
      precioUnitario: oferta.precioUnitario,
      modalidadLogistica: _modalidadSeleccionada,
    );
    DatosEnMemoria.registrarPedido(pedido);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle, color: ColoresApp.verdePrincipal, size: 48),
        title: const Text('¡Pedido Coordinado!'),
        content: Text(
          'Tu reserva de $_cantidad ${oferta.unidadMedida.etiqueta.toLowerCase()} de '
          '${producto?.nombre ?? 'este cultivo'} fue enviada a ${productor?.nombreCompleto ?? 'el productor'}. '
          'Modalidad: ${_modalidadSeleccionada.etiqueta}.',
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
    final oferta = widget.oferta;
    final producto = DatosEnMemoria.obtenerProductoPorId(oferta.productoId);
    final productor = DatosEnMemoria.obtenerUsuarioPorId(oferta.productorId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Pedido'),
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
                        const Icon(Icons.eco, color: ColoresApp.verdePrincipal, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto?.nombre ?? 'Producto',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                '${productor?.nombreCompleto ?? 'Productor'} · ${productor?.municipio ?? ''}',
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
                            oferta.fechaCosecha != null
                                ? 'Sello de Trazabilidad · Cosecha: ${formatearFecha(oferta.fechaCosecha!)}'
                                : 'Sello de Trazabilidad',
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
                          const Icon(Icons.eco, color: ColoresApp.verdeOscuro, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Impacto directo: este trato beneficia a ${productor?.nombreCompleto ?? 'el productor'} y a la comunidad de ${productor?.municipio ?? '-'}.',
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
                      DatosEnMemoria.usuarioActual?.nombreCompleto ??
                          'Sesión de comprador no encontrada',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Modalidad de entrega', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<ModalidadLogisticaPedido>(
              initialValue: _modalidadSeleccionada,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.local_shipping),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _opcionesModalidad
                  .map((m) => DropdownMenuItem(value: m, child: Text(m.etiqueta)))
                  .toList(),
              onChanged: (v) => setState(() => _modalidadSeleccionada = v ?? _modalidadSeleccionada),
            ),
            const SizedBox(height: 20),
            Text('Volumen a reservar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            IndicadorInventario(
              cantidadDisponible: oferta.cantidadDisponible,
              cantidadTotal: oferta.cantidadTotal,
              unidadEtiqueta: oferta.unidadMedida.etiqueta.toLowerCase(),
              compacto: true,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  onPressed: () => _cambiarCantidad(-1),
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$_cantidad ${oferta.unidadMedida.etiqueta}',
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
                        color: Colors.white,
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
                style: TemaApp.botonNaranja,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
