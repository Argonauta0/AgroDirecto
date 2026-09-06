import 'package:flutter/material.dart';
import '../modelos/modelo_oferta_agricola.dart';
import '../modelos/modelo_producto.dart';
import '../servicios/servicio_supabase.dart';
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
  final TextEditingController _controladorPrecio = TextEditingController();

  bool _cargando = true;
  String? _error;
  OfertaAgricola? _oferta;
  Producto? _producto;
  bool _guardandoPrecio = false;
  bool _alternandoPausa = false;

  double get _precioEnEdicion =>
      double.tryParse(_controladorPrecio.text) ?? _oferta?.precioUnitario ?? 0;

  @override
  void initState() {
    super.initState();
    _cargarOferta();
  }

  @override
  void dispose() {
    _controladorPrecio.dispose();
    super.dispose();
  }

  Future<void> _cargarOferta() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final oferta = await ServicioSupabase.obtenerOfertaPorId(widget.ofertaId);
      final producto =
          oferta != null ? await ServicioSupabase.obtenerProductoPorId(oferta.productoId) : null;
      if (!mounted) return;
      setState(() {
        _oferta = oferta;
        _producto = producto;
        _controladorPrecio.text = oferta?.precioUnitario.toStringAsFixed(0) ?? '';
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar la oferta: $e';
        _cargando = false;
      });
    }
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

  Future<void> _guardarPrecio() async {
    if (_guardandoPrecio) return;
    if (!_formKey.currentState!.validate()) return;
    final oferta = _oferta;
    if (oferta == null) return;

    final nuevoPrecio = double.parse(_controladorPrecio.text);
    setState(() => _guardandoPrecio = true);
    try {
      if (nuevoPrecio != oferta.precioUnitario) {
        await ServicioSupabase.actualizarPrecioOferta(oferta.id, nuevoPrecio);
      }
      if (!mounted) return;
      await _cargarOferta();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Precio actualizado'),
          backgroundColor: ColoresApp.verdePrincipal,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el precio: $e')),
      );
    } finally {
      if (mounted) setState(() => _guardandoPrecio = false);
    }
  }

  Future<void> _alternarPausa() async {
    if (_alternandoPausa) return;
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

    final nuevoEstado = pausando ? EstadoOferta.pausada : EstadoOferta.disponible;
    setState(() => _alternandoPausa = true);
    try {
      await ServicioSupabase.alternarPausaOferta(oferta.id, nuevoEstado);
      if (!mounted) return;
      await _cargarOferta();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el estado: $e')),
      );
    } finally {
      if (mounted) setState(() => _alternandoPausa = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar oferta')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar oferta')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _cargarOferta,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final oferta = _oferta;

    if (oferta == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar oferta')),
        body: const Center(child: Text('Esta oferta ya no existe.')),
      );
    }

    final producto = _producto;

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
                  onPressed: _guardandoPrecio ? null : _guardarPrecio,
                  icon: _guardandoPrecio
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
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
                    onPressed: _alternandoPausa ? null : _alternarPausa,
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
