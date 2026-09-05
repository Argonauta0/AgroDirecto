import 'package:flutter/material.dart';
import '../datos_en_memoria.dart';
import '../modelos/modelo_oferta_agricola.dart';
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
  void _cerrarSesion(BuildContext context) {
    DatosEnMemoria.cerrarSesion();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const VistaLogin()),
      (route) => false,
    );
  }

  void _publicarCosecha(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const VistaPublicar()),
    );
    setState(() {});
  }

  void _verDetalle(BuildContext context, OfertaAgricola oferta, String etiqueta) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(etiqueta)));
  }

  Future<void> _editarOferta(BuildContext context, OfertaAgricola oferta) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => VistaEditarOferta(ofertaId: oferta.id)),
    );
    setState(() {});
  }

  Future<void> _confirmarEliminar(BuildContext context, OfertaAgricola oferta) async {
    final producto = DatosEnMemoria.obtenerProductoPorId(oferta.productoId);
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

    DatosEnMemoria.eliminarOferta(oferta.id);
    setState(() {});

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$nombre" fue eliminado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productorActual = DatosEnMemoria.usuarioActual;
    final idProductor = productorActual?.id;
    final List<OfertaAgricola> misOfertas = DatosEnMemoria.ofertas
        .where((o) => o.productorId == idProductor)
        .toList();
    final List<OfertaAgricola> otrasOfertas = DatosEnMemoria.ofertas
        .where((o) => o.productorId != idProductor)
        .toList();

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
      body: ListView(
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
                  misOfertas.isEmpty
                      ? 'Aún no has publicado ninguna cosecha.'
                      : 'Tienes ${misOfertas.length} lote(s) publicado(s).',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ...misOfertas.map(
                  (oferta) => TarjetaProducto(
                    oferta: oferta,
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
          if (otrasOfertas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay lotes de otros productores todavía.'),
            )
          else
            ...otrasOfertas.map((oferta) {
              final productor = DatosEnMemoria.obtenerUsuarioPorId(oferta.productorId);
              return TarjetaProducto(
                oferta: oferta,
                onTap: () => _verDetalle(
                  context,
                  oferta,
                  'Publicado por ${productor?.nombreCompleto ?? 'un productor'}',
                ),
              );
            }),
        ],
      ),
    );
  }
}
