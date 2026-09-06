import 'package:flutter/material.dart';
import '../modelos/modelo_oferta_agricola.dart';
import '../modelos/modelo_producto.dart';
import '../modelos/modelo_usuario.dart';
import '../servicios/servicio_supabase.dart';
import '../tema_app.dart';
import '../widgets/tarjeta_producto.dart';
import 'vista_editar_oferta.dart';
import 'vista_login.dart';
import 'vista_publicar.dart';

class VistaPanelProductor extends StatefulWidget {
  const VistaPanelProductor({super.key});

  @override
  State<VistaPanelProductor> createState() => _VistaPanelProductorState();
}

class _VistaPanelProductorState extends State<VistaPanelProductor> {
  bool _cargando = true;
  String? _error;

  List<OfertaAgricola> _misOfertas = [];
  List<OfertaAgricola> _otrasOfertas = [];
  Map<String, Producto> _productosPorId = {};
  Map<String, Usuario> _productoresPorId = {};

  Usuario? get _productorActual => ServicioSupabase.usuarioActual;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final idProductor = _productorActual?.id;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final resultados = await Future.wait([
        idProductor != null
            ? ServicioSupabase.obtenerOfertasPorProductor(idProductor)
            : Future.value(<OfertaAgricola>[]),
        ServicioSupabase.obtenerOfertasDisponibles(),
        ServicioSupabase.obtenerCatalogo(),
        ServicioSupabase.obtenerUsuariosPorPerfil(TipoPerfil.productor),
      ]);
      final misOfertas = resultados[0] as List<OfertaAgricola>;
      final disponibles = resultados[1] as List<OfertaAgricola>;
      final productos = resultados[2] as List<Producto>;
      final productores = resultados[3] as List<Usuario>;

      if (!mounted) return;
      setState(() {
        _misOfertas = misOfertas;
        _otrasOfertas = disponibles.where((o) => o.productorId != idProductor).toList();
        _productosPorId = {for (final p in productos) p.id: p};
        _productoresPorId = {for (final u in productores) u.id: u};
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar tus cosechas: $e';
        _cargando = false;
      });
    }
  }

  void _cerrarSesion(BuildContext context) {
    ServicioSupabase.usuarioActual = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const VistaLogin()),
      (route) => false,
    );
  }

  Future<void> _publicarCosecha(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const VistaPublicar()),
    );
    _cargarDatos();
  }

  void _verDetalle(BuildContext context, OfertaAgricola oferta, String etiqueta) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(etiqueta)));
  }

  Future<void> _editarOferta(BuildContext context, OfertaAgricola oferta) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => VistaEditarOferta(ofertaId: oferta.id)),
    );
    _cargarDatos();
  }

  Future<void> _confirmarEliminar(BuildContext context, OfertaAgricola oferta) async {
    final producto = _productosPorId[oferta.productoId];
    final nombre = producto?.nombre ?? 'este lote';

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await ServicioSupabase.eliminarOferta(oferta.id);
      if (!context.mounted) return;
      await _cargarDatos();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$nombre" fue eliminado.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productorActual = _productorActual;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          productorActual != null ? 'Hola, ${productorActual.nombreCompleto}' : 'Panel del Productor',
        ),
        actions: [
          IconButton(
            onPressed: () => _cerrarSesion(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _cargarDatos,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarDatos,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColoresApp.verdeClaro.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ColoresApp.verdeClaro),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.eco, color: ColoresApp.verdePrincipal),
                                const SizedBox(width: 8),
                                Text(
                                  'Mi Cosecha',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: ColoresApp.verdeOscuro,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _misOfertas.isEmpty
                                  ? 'Aún no has publicado ninguna cosecha.'
                                  : 'Tienes ${_misOfertas.length} lote(s) publicado(s).',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            ..._misOfertas.map(
                              (oferta) => TarjetaProducto(
                                oferta: oferta,
                                producto: _productosPorId[oferta.productoId],
                                productor: productorActual,
                                onTap: () => _editarOferta(context, oferta),
                                onEliminar: () => _confirmarEliminar(context, oferta),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _publicarCosecha(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Publicar nueva cosecha'),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Ofertas de otros productores',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_otrasOfertas.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No hay lotes de otros productores todavía.'),
                        )
                      else
                        ..._otrasOfertas.map((oferta) {
                          final productor = _productoresPorId[oferta.productorId];
                          return TarjetaProducto(
                            oferta: oferta,
                            producto: _productosPorId[oferta.productoId],
                            productor: productor,
                            onTap: () => _verDetalle(
                              context,
                              oferta,
                              'Publicado por ${productor?.nombreCompleto ?? 'un productor'}',
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}
