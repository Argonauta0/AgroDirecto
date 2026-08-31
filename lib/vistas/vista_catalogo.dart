import 'package:flutter/material.dart';
import '../datos_en_memoria.dart';
import '../modelos/modelo_oferta_lote.dart';
import '../tema_app.dart';
import '../utilidades/formato_fecha.dart';
import '../widgets/indicador_modo_rural.dart';
import '../widgets/tarjeta_producto.dart';
import 'vista_login.dart';
import 'vista_pedido.dart';

class VistaCatalogo extends StatefulWidget {
  const VistaCatalogo({super.key});

  @override
  State<VistaCatalogo> createState() => _VistaCatalogoState();
}

class _VistaCatalogoState extends State<VistaCatalogo> {
  final TextEditingController _controladorBusqueda = TextEditingController();
  String _textoBusqueda = '';
  String _zonaSeleccionada = 'Todas';

  final List<String> _zonas = const ['Todas', 'Ticuantepe', 'Rivas', 'Masaya'];

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  List<OfertaLote> get _ofertasFiltradas {
    return DatosEnMemoria.ofertasDisponibles.where((oferta) {
      final producto = DatosEnMemoria.obtenerProductoPorId(oferta.productoId);
      final productor = DatosEnMemoria.obtenerUsuarioPorId(oferta.productorId);
      final coincideTexto = _textoBusqueda.isEmpty ||
          (producto?.nombre.toLowerCase().contains(_textoBusqueda.toLowerCase()) ?? false) ||
          (productor?.nombreCompleto.toLowerCase().contains(_textoBusqueda.toLowerCase()) ?? false);
      final coincideZona = _zonaSeleccionada == 'Todas' ||
          (productor?.municipio.toLowerCase().contains(_zonaSeleccionada.toLowerCase()) ?? false) ||
          (productor?.departamento.toLowerCase().contains(_zonaSeleccionada.toLowerCase()) ?? false);
      return coincideTexto && coincideZona;
    }).toList();
  }

  void _abrirCanasta() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tu canasta está vacía. ¡Reserva una cosecha!')),
    );
  }

  void _cerrarSesion() {
    DatosEnMemoria.cerrarSesion();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const VistaLogin()),
      (route) => false,
    );
  }

  void _abrirFichaTrazabilidad(OfertaLote oferta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FichaTrazabilidad(oferta: oferta),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgroDirecto'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Center(child: IndicadorModoRural()),
          ),
          IconButton(
            onPressed: _abrirCanasta,
            icon: const Icon(Icons.shopping_basket),
            tooltip: 'Canasta',
          ),
          IconButton(
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controladorBusqueda,
              onChanged: (v) => setState(() => _textoBusqueda = v),
              decoration: InputDecoration(
                hintText: 'Buscar cultivo o productor...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _zonas.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final zona = _zonas[i];
                final seleccionada = zona == _zonaSeleccionada;
                return ChoiceChip(
                  label: Text(zona),
                  selected: seleccionada,
                  selectedColor: ColoresApp.verdeClaro,
                  labelStyle: TextStyle(
                    color: seleccionada ? ColoresApp.verdeOscuro : Colors.black87,
                    fontWeight: seleccionada ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => setState(() => _zonaSeleccionada = zona),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _ofertasFiltradas.isEmpty
                ? const Center(child: Text('No hay lotes disponibles en esta zona.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: _ofertasFiltradas.length,
                    itemBuilder: (context, i) {
                      final oferta = _ofertasFiltradas[i];
                      return TarjetaProducto(
                        oferta: oferta,
                        onTap: () => _abrirFichaTrazabilidad(oferta),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FichaTrazabilidad extends StatelessWidget {
  final OfertaLote oferta;

  const _FichaTrazabilidad({required this.oferta});

  @override
  Widget build(BuildContext context) {
    final producto = DatosEnMemoria.obtenerProductoPorId(oferta.productoId);
    final productor = DatosEnMemoria.obtenerUsuarioPorId(oferta.productorId);
    return Container(
      decoration: const BoxDecoration(
        color: ColoresApp.blancoFondo,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: ColoresApp.verdeClaro.withValues(alpha: 0.3),
                child: const Icon(Icons.eco, color: ColoresApp.verdePrincipal, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(producto?.nombre ?? 'Producto', style: Theme.of(context).textTheme.titleLarge),
                    Text(
                      productor?.nombreCompleto ?? 'Productor',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ColoresApp.verdePrincipal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_shipping, size: 14, color: ColoresApp.verdePrincipal),
                    const SizedBox(width: 4),
                    Text(
                      oferta.modalidadLogistica.etiqueta,
                      style: const TextStyle(
                        color: ColoresApp.verdePrincipal,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _filaFicha(
            Icons.location_on,
            'Municipio',
            '${productor?.municipio ?? '-'}, ${productor?.departamento ?? '-'}',
          ),
          _filaFicha(
            Icons.calendar_today,
            'Fecha de corte',
            oferta.fechaCosecha != null ? formatearFecha(oferta.fechaCosecha!) : 'No especificada',
          ),
          _filaFicha(
            Icons.inventory_2,
            'Disponible',
            '${oferta.cantidadDisponible} ${oferta.unidadMedida.etiqueta}',
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColoresApp.amarilloDestacado.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco, color: ColoresApp.naranjaAviso),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Trato directo con ${productor?.nombreCompleto ?? 'el productor'}: mejores ingresos para su comunidad.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VistaPedido(
                      oferta: oferta,
                      cantidadInicial: 1,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.eco),
              label: const Text('Reservar Cosecha'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaFicha(IconData icono, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icono, size: 18, color: ColoresApp.verdeOscuro),
          const SizedBox(width: 10),
          Text('$etiqueta: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
