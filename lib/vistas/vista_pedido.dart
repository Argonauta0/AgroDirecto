import 'package:flutter/material.dart';
import '../datos_en_memoria.dart';
import '../modelos/modelo_oferta_agricola.dart';
import '../modelos/modelo_solicitud_compra.dart';
import '../tema_app.dart';
import '../utilidades/formato_fecha.dart';
import '../widgets/indicador_inventario.dart';

class VistaPedido extends StatefulWidget {
  final OfertaAgricola oferta;
  final int cantidadInicial;

  const VistaPedido({super.key, required this.oferta, required this.cantidadInicial});

  @override
  State<VistaPedido> createState() => _VistaPedidoState();
}

class _VistaPedidoState extends State<VistaPedido> {
  late int _cantidad;
  late ModalidadLogistica _modalidadSeleccionada;

  List<ModalidadLogistica> get _opcionesModalidad {
    switch (widget.oferta.modalidadLogistica) {
      case ModalidadLogistica.retiro:
        return const [ModalidadLogistica.retiro];
      case ModalidadLogistica.envioProductor:
        return const [ModalidadLogistica.envioProductor];
      case ModalidadLogistica.transportista:
        return const [ModalidadLogistica.transportista];
      case ModalidadLogistica.todas:
        return const [
          ModalidadLogistica.retiro,
          ModalidadLogistica.envioProductor,
          ModalidadLogistica.transportista,
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

    final solicitud = SolicitudCompra(
      id: 'sol_${DateTime.now().millisecondsSinceEpoch}',
      ofertaId: oferta.id,
      compradorId: compradorActual?.id ?? '',
      productorId: oferta.productorId,
      cantidadSolicitada: _cantidad,
      precioUnitario: oferta.precioUnitario,
      modalidadLogistica: _modalidadSeleccionada,
      estado: EstadoSolicitud.confirmado,
    );
    DatosEnMemoria.registrarSolicitud(solicitud);

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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                productor?.nombreCompleto ?? 'Productor',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 13, color: ColoresApp.verdeOscuro),
                                  const SizedBox(width: 3),
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: ColoresApp.naranjaAviso,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'C\$${oferta.precioUnitario.toStringAsFixed(0)}\n/ ${oferta.unidadMedida.etiqueta}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              height: 1.2,
                              color: Colors.black87,
                            ),
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
                              'Impacto directo: este trato beneficia a ${productor?.nombreCompleto ?? 'el productor'} y a la comunidad de ${productor != null ? '${productor.municipio}, ${productor.departamento}' : '-'}.',
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
            DropdownButtonFormField<ModalidadLogistica>(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_cantidad ${oferta.unidadMedida.etiqueta} × '
                      'C\$${oferta.precioUnitario.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total a pagar',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
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
