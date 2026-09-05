import 'package:flutter/material.dart';
import '../datos_en_memoria.dart';
import '../modelos/modelo_oferta_agricola.dart';
import '../tema_app.dart';
import '../widgets/indicador_inventario.dart';
import '../widgets/resumen_liquidacion.dart';

class VistaEditarOferta extends StatefulWidget {
  final String ofertaId;

  const VistaEditarOferta({super.key, required this.ofertaId});

  @override
  State<VistaEditarOferta> createState() => _VistaEditarOfertaState();
}

class _VistaEditarOfertaState extends State<VistaEditarOferta> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controladorPrecio;

  OfertaAgricola? get _oferta => DatosEnMemoria.obtenerOfertaPorId(widget.ofertaId);

  double get _precioEnEdicion =>
      double.tryParse(_controladorPrecio.text) ?? _oferta?.precioUnitario ?? 0;

  @override
  void initState() {
    super.initState();
    _controladorPrecio = TextEditingController(
      text: _oferta?.precioUnitario.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _controladorPrecio.dispose();
    super.dispose();
  }

  Color _fondoEstado(OfertaAgricola oferta) {
    if (oferta.estado == EstadoOferta.pausada) return ColoresApp.naranjaAviso;
    if (oferta.estado == EstadoOferta.agotado) return Colors.grey.shade300;
    if (oferta.cantidadDisponible < oferta.cantidadTotal) return ColoresApp.amarilloDestacado;
    return ColoresApp.verdeClaro.withValues(alpha: 0.25);
  }

  Color _textoEstado(OfertaAgricola oferta) {
    if (oferta.estado == EstadoOferta.agotado) return Colors.black54;
    if (oferta.estado == EstadoOferta.disponible &&
        oferta.cantidadDisponible >= oferta.cantidadTotal) {
      return ColoresApp.verdeOscuro;
    }
    return ColoresApp.colorTextoSobre(_fondoEstado(oferta));
  }

  void _guardarPrecio() {
    if (!_formKey.currentState!.validate()) return;
    final oferta = _oferta;
    if (oferta == null) return;

    final nuevoPrecio = double.parse(_controladorPrecio.text);
    if (nuevoPrecio != oferta.precioUnitario) {
      DatosEnMemoria.actualizarPrecioOferta(oferta.id, nuevoPrecio);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Precio actualizado'),
        backgroundColor: ColoresApp.verdePrincipal,
      ),
    );
    setState(() {});
  }

  Future<void> _alternarPausa() async {
    final oferta = _oferta;
    if (oferta == null) return;

    final pausando = oferta.estado != EstadoOferta.pausada;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pausando ? '¿Pausar esta oferta?' : '¿Reanudar esta oferta?'),
        content: Text(
          pausando
              ? 'Mientras esté pausada, los compradores no la verán en el catálogo.'
              : 'La oferta volverá a estar visible en el catálogo para los compradores.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(pausando ? 'Pausar' : 'Reanudar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    DatosEnMemoria.alternarPausaOferta(oferta.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final oferta = _oferta;

    if (oferta == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar oferta')),
        body: const Center(child: Text('Esta oferta ya no existe.')),
      );
    }

    final producto = DatosEnMemoria.obtenerProductoPorId(oferta.productoId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar oferta'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
            padding: const EdgeInsets.all(16),
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
                            child: Text(
                              producto?.nombre ?? 'Producto',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _fondoEstado(oferta),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              oferta.estadoVisualTexto,
                              style: TextStyle(
                                color: _textoEstado(oferta),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Control de inventario',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      IndicadorInventario(
                        cantidadDisponible: oferta.cantidadDisponible,
                        cantidadTotal: oferta.cantidadTotal,
                        unidadEtiqueta: oferta.unidadMedida.etiqueta.toLowerCase(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Precio de venta', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _controladorPrecio,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Precio por ${oferta.unidadMedida.etiqueta} (C\$)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Ingresa un precio válido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              if (oferta.cantidadDisponible > 0 && _precioEnEdicion > 0)
                ResumenLiquidacion(
                  cantidad: oferta.cantidadDisponible,
                  precioUnitario: _precioEnEdicion,
                  unidadEtiqueta: oferta.unidadMedida.etiqueta.toLowerCase(),
                  titulo: 'Liquidación estimada del inventario restante',
                ),
              if (oferta.cantidadDisponible > 0 && _precioEnEdicion > 0) const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardarPrecio,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar precio'),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              Text('Visibilidad en el catálogo', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (oferta.estado == EstadoOferta.agotado)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Este lote está agotado, por lo que no se puede pausar ni reanudar.',
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _alternarPausa,
                    icon: Icon(
                      oferta.estado == EstadoOferta.pausada ? Icons.play_arrow : Icons.pause,
                    ),
                    label: Text(
                      oferta.estado == EstadoOferta.pausada
                          ? 'Reanudar oferta'
                          : 'Pausar oferta',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: ColoresApp.naranjaAviso, width: 1.5),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
  }
}

