import 'package:flutter/material.dart';
import '../modelos/modelo_oferta_agricola.dart';
import '../modelos/modelo_producto.dart';
import '../servicios/servicio_supabase.dart';
import '../tema_app.dart';
import '../widgets/resumen_liquidacion.dart';
import 'vista_login.dart';

class VistaPublicar extends StatefulWidget {
  const VistaPublicar({super.key});

  @override
  State<VistaPublicar> createState() => _VistaPublicarState();
}

class _VistaPublicarState extends State<VistaPublicar> {
  final _formKey = GlobalKey<FormState>();

  bool _cargandoCatalogo = true;
  String? _errorCatalogo;
  List<Producto> _productos = [];

  Producto? _productoSeleccionado;
  UnidadMedida _unidadSeleccionada = UnidadMedida.quintal;
  ModalidadLogistica _modalidadSeleccionada = ModalidadLogistica.todas;
  bool _publicando = false;

  final TextEditingController _controladorCantidad = TextEditingController();
  final TextEditingController _controladorPrecio = TextEditingController();

  double get _precioIngresado => double.tryParse(_controladorPrecio.text) ?? 0;
  int get _cantidadIngresada => int.tryParse(_controladorCantidad.text) ?? 0;
  double get _precioIntermediarioEstimado => _precioIngresado / 1.35;
  double get _gananciaExtra => _precioIngresado - _precioIntermediarioEstimado;

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  Future<void> _cargarCatalogo() async {
    setState(() {
      _cargandoCatalogo = true;
      _errorCatalogo = null;
    });
    try {
      final productos = await ServicioSupabase.obtenerCatalogo();
      if (!mounted) return;
      setState(() {
        _productos = productos;
        _productoSeleccionado = productos.isNotEmpty ? productos.first : null;
        _cargandoCatalogo = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorCatalogo = 'No se pudo cargar el catálogo: $e';
        _cargandoCatalogo = false;
      });
    }
  }

  @override
  void dispose() {
    _controladorCantidad.dispose();
    _controladorPrecio.dispose();
    super.dispose();
  }

  Future<void> _publicarLote() async {
    if (_publicando) return;
    if (!_formKey.currentState!.validate()) return;

    final productorActual = ServicioSupabase.usuarioActual;
    final producto = _productoSeleccionado;
    if (productorActual == null || producto == null) return;

    final cantidad = int.parse(_controladorCantidad.text);

    final oferta = OfertaAgricola(
      id: 'of_${DateTime.now().millisecondsSinceEpoch}',
      productorId: productorActual.id,
      productoId: producto.id,
      precioUnitario: double.parse(_controladorPrecio.text),
      unidadMedida: _unidadSeleccionada,
      cantidadTotal: cantidad,
      cantidadDisponible: cantidad,
      modalidadLogistica: _modalidadSeleccionada,
      fechaCosecha: DateTime.now(),
    );

    setState(() => _publicando = true);
    try {
      await ServicioSupabase.agregarOferta(oferta);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lote de ${producto.nombre} publicado con éxito'),
          backgroundColor: ColoresApp.verdePrincipal,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo publicar el lote: $e')),
      );
    } finally {
      if (mounted) setState(() => _publicando = false);
    }
  }

  void _cerrarSesion() {
    ServicioSupabase.usuarioActual = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const VistaLogin()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final productorActual = ServicioSupabase.usuarioActual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Cosecha'),
        actions: [
          IconButton(
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _cargandoCatalogo
          ? const Center(child: CircularProgressIndicator())
          : _errorCatalogo != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(_errorCatalogo!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _cargarCatalogo,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
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
                            const Icon(Icons.person, color: ColoresApp.verdePrincipal),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                productorActual != null
                                    ? '${productorActual.nombreCompleto} • ${productorActual.municipio}, ${productorActual.departamento}'
                                    : 'Sesión de productor no encontrada',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('¿Qué vas a vender?', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Producto>(
                        initialValue: _productoSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Cultivo del catálogo',
                          prefixIcon: const Icon(Icons.eco),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _productos
                            .map((p) => DropdownMenuItem(value: p, child: Text(p.nombre)))
                            .toList(),
                        onChanged: (v) => setState(() => _productoSeleccionado = v),
                        validator: (v) => v == null ? 'Selecciona un cultivo' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<UnidadMedida>(
                        initialValue: _unidadSeleccionada,
                        decoration: InputDecoration(
                          labelText: 'Unidad de medida',
                          prefixIcon: const Icon(Icons.scale),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: UnidadMedida.values
                            .map((u) => DropdownMenuItem(value: u, child: Text(u.etiqueta)))
                            .toList(),
                        onChanged: (v) => setState(() => _unidadSeleccionada = v ?? _unidadSeleccionada),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<ModalidadLogistica>(
                        initialValue: _modalidadSeleccionada,
                        decoration: InputDecoration(
                          labelText: 'Modalidad de entrega',
                          prefixIcon: const Icon(Icons.local_shipping),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ModalidadLogistica.values
                            .map((m) => DropdownMenuItem(value: m, child: Text(m.etiqueta)))
                            .toList(),
                        onChanged: (v) => setState(() => _modalidadSeleccionada = v ?? _modalidadSeleccionada),
                      ),
                      const SizedBox(height: 24),
                      Text('Cantidad y precio', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _controladorCantidad,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cantidad total',
                          prefixIcon: const Icon(Icons.inventory_2),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n <= 0) return 'Ingresa una cantidad válida';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _controladorPrecio,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Precio por ${_unidadSeleccionada.etiqueta} (C\$)',
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
                      const SizedBox(height: 20),
                      if (_cantidadIngresada > 0 && _precioIngresado > 0)
                        ResumenLiquidacion(
                          cantidad: _cantidadIngresada,
                          precioUnitario: _precioIngresado,
                          unidadEtiqueta: _unidadSeleccionada.etiqueta.toLowerCase(),
                        ),
                      if (_cantidadIngresada > 0 && _precioIngresado > 0) const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColoresApp.amarilloDestacado.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ColoresApp.amarilloDestacado),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.handshake, color: ColoresApp.verdeOscuro, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _precioIngresado > 0
                                    ? 'Con este precio ganas un 35% más que vendiendo al intermediario '
                                        '(aprox. C\$${_precioIntermediarioEstimado.toStringAsFixed(0)} → '
                                        'ganancia extra de C\$${_gananciaExtra.toStringAsFixed(0)}).'
                                    : 'Con este precio ganas un 35% más que vendiendo al intermediario.',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _publicando ? null : _publicarLote,
                        icon: _publicando
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload),
                        label: const Text('Publicar Lote'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }
}
