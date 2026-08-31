import 'package:flutter/material.dart';
import '../datos_en_memoria.dart';
import '../modelos/modelo_oferta_lote.dart';
import '../modelos/modelo_producto.dart';
import '../tema_app.dart';
import '../utilidades/formato_fecha.dart';
import '../widgets/indicador_modo_rural.dart';
import '../widgets/tarjeta_producto.dart';
import 'vista_login.dart';
import 'vista_pedido.dart';

const List<ModalidadLogisticaOferta> _modalidadesFiltrables = [
  ModalidadLogisticaOferta.retiro,
  ModalidadLogisticaOferta.envioProductor,
  ModalidadLogisticaOferta.transportista,
];

class _FiltrosCatalogo {
  final Producto? cultivo;
  final RangeValues rangoPrecio;
  final String? departamento;
  final String? municipio;
  final Set<ModalidadLogisticaOferta> modalidades;

  const _FiltrosCatalogo({
    required this.cultivo,
    required this.rangoPrecio,
    required this.departamento,
    required this.municipio,
    required this.modalidades,
  });
}

class VistaCatalogo extends StatefulWidget {
  const VistaCatalogo({super.key});

  @override
  State<VistaCatalogo> createState() => _VistaCatalogoState();
}

class _VistaCatalogoState extends State<VistaCatalogo> {
  final TextEditingController _controladorBusqueda = TextEditingController();
  String _textoBusqueda = '';

  late final double _precioMinimo;
  late final double _precioMaximo;

  Producto? _cultivoSeleccionado;
  late RangeValues _rangoPrecio;
  String? _departamentoSeleccionado;
  String? _municipioSeleccionado;
  Set<ModalidadLogisticaOferta> _modalidadesSeleccionadas = {};

  @override
  void initState() {
    super.initState();
    final precios = DatosEnMemoria.ofertasLote.map((o) => o.precioUnitario).toList();
    _precioMinimo = precios.isEmpty ? 0 : precios.reduce((a, b) => a < b ? a : b);
    _precioMaximo = precios.isEmpty ? 1000 : precios.reduce((a, b) => a > b ? a : b);
    if (_precioMaximo <= _precioMinimo) {
      _rangoPrecio = RangeValues(_precioMinimo, _precioMinimo + 1);
    } else {
      _rangoPrecio = RangeValues(_precioMinimo, _precioMaximo);
    }
  }

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  bool get _hayFiltrosActivos =>
      _cultivoSeleccionado != null ||
      _rangoPrecio.start > _precioMinimo ||
      _rangoPrecio.end < _precioMaximo ||
      _departamentoSeleccionado != null ||
      _municipioSeleccionado != null ||
      _modalidadesSeleccionadas.isNotEmpty;

  List<OfertaLote> get _ofertasFiltradas {
    return DatosEnMemoria.ofertasDisponibles.where((oferta) {
      final producto = DatosEnMemoria.obtenerProductoPorId(oferta.productoId);
      final productor = DatosEnMemoria.obtenerUsuarioPorId(oferta.productorId);

      final coincideTexto = _textoBusqueda.isEmpty ||
          (producto?.nombre.toLowerCase().contains(_textoBusqueda.toLowerCase()) ?? false) ||
          (productor?.nombreCompleto.toLowerCase().contains(_textoBusqueda.toLowerCase()) ?? false);

      final coincideCultivo =
          _cultivoSeleccionado == null || oferta.productoId == _cultivoSeleccionado!.id;

      final coincidePrecio =
          oferta.precioUnitario >= _rangoPrecio.start && oferta.precioUnitario <= _rangoPrecio.end;

      final coincideDepartamento =
          _departamentoSeleccionado == null || productor?.departamento == _departamentoSeleccionado;

      final coincideMunicipio =
          _municipioSeleccionado == null || productor?.municipio == _municipioSeleccionado;

      final coincideModalidad = _modalidadesSeleccionadas.isEmpty ||
          _modalidadesSeleccionadas.contains(oferta.modalidadLogistica) ||
          oferta.modalidadLogistica == ModalidadLogisticaOferta.todas;

      return coincideTexto &&
          coincideCultivo &&
          coincidePrecio &&
          coincideDepartamento &&
          coincideMunicipio &&
          coincideModalidad;
    }).toList();
  }

  void _limpiarFiltros() {
    setState(() {
      _cultivoSeleccionado = null;
      _rangoPrecio = RangeValues(_precioMinimo, _precioMaximo <= _precioMinimo ? _precioMinimo + 1 : _precioMaximo);
      _departamentoSeleccionado = null;
      _municipioSeleccionado = null;
      _modalidadesSeleccionadas = {};
    });
  }

  Future<void> _abrirFiltros() async {
    final resultado = await showModalBottomSheet<_FiltrosCatalogo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HojaFiltros(
        cultivoSeleccionado: _cultivoSeleccionado,
        rangoPrecio: _rangoPrecio,
        precioMinimo: _precioMinimo,
        precioMaximo: _precioMaximo <= _precioMinimo ? _precioMinimo + 1 : _precioMaximo,
        departamentoSeleccionado: _departamentoSeleccionado,
        municipioSeleccionado: _municipioSeleccionado,
        modalidadesSeleccionadas: _modalidadesSeleccionadas,
      ),
    );
    if (resultado == null) return;
    setState(() {
      _cultivoSeleccionado = resultado.cultivo;
      _rangoPrecio = resultado.rangoPrecio;
      _departamentoSeleccionado = resultado.departamento;
      _municipioSeleccionado = resultado.municipio;
      _modalidadesSeleccionadas = resultado.modalidades;
    });
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
            child: Row(
              children: [
                Expanded(
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
                const SizedBox(width: 8),
                Badge(
                  isLabelVisible: _hayFiltrosActivos,
                  child: IconButton.filledTonal(
                    onPressed: _abrirFiltros,
                    icon: const Icon(Icons.tune),
                    tooltip: 'Filtros',
                  ),
                ),
              ],
            ),
          ),
          if (_hayFiltrosActivos)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _limpiarFiltros,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Limpiar filtros'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          Expanded(
            child: _ofertasFiltradas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No hay lotes disponibles con estos filtros.'),
                        if (_hayFiltrosActivos) ...[
                          const SizedBox(height: 8),
                          TextButton(onPressed: _limpiarFiltros, child: const Text('Limpiar filtros')),
                        ],
                      ],
                    ),
                  )
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

class _HojaFiltros extends StatefulWidget {
  final Producto? cultivoSeleccionado;
  final RangeValues rangoPrecio;
  final double precioMinimo;
  final double precioMaximo;
  final String? departamentoSeleccionado;
  final String? municipioSeleccionado;
  final Set<ModalidadLogisticaOferta> modalidadesSeleccionadas;

  const _HojaFiltros({
    required this.cultivoSeleccionado,
    required this.rangoPrecio,
    required this.precioMinimo,
    required this.precioMaximo,
    required this.departamentoSeleccionado,
    required this.municipioSeleccionado,
    required this.modalidadesSeleccionadas,
  });

  @override
  State<_HojaFiltros> createState() => _HojaFiltrosState();
}

class _HojaFiltrosState extends State<_HojaFiltros> {
  late Producto? _cultivo;
  late RangeValues _rango;
  late String? _departamento;
  late String? _municipio;
  late Set<ModalidadLogisticaOferta> _modalidades;

  @override
  void initState() {
    super.initState();
    _cultivo = widget.cultivoSeleccionado;
    _rango = widget.rangoPrecio;
    _departamento = widget.departamentoSeleccionado;
    _municipio = widget.municipioSeleccionado;
    _modalidades = {...widget.modalidadesSeleccionadas};
  }

  List<String> get _departamentosDisponibles {
    final valores = DatosEnMemoria.productores.map((p) => p.departamento).toSet().toList();
    valores.sort();
    return valores;
  }

  List<String> get _municipiosDisponibles {
    final productores = _departamento == null
        ? DatosEnMemoria.productores
        : DatosEnMemoria.productores.where((p) => p.departamento == _departamento);
    final valores = productores.map((p) => p.municipio).toSet().toList();
    valores.sort();
    return valores;
  }

  void _cambiarDepartamento(String? valor) {
    setState(() {
      _departamento = valor;
      if (_municipio != null && !_municipiosDisponibles.contains(_municipio)) {
        _municipio = null;
      }
    });
  }

  void _limpiar() {
    setState(() {
      _cultivo = null;
      _rango = RangeValues(widget.precioMinimo, widget.precioMaximo);
      _departamento = null;
      _municipio = null;
      _modalidades = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final municipioActual = _municipiosDisponibles.contains(_municipio) ? _municipio : null;

    return Container(
      decoration: const BoxDecoration(
        color: ColoresApp.blancoFondo,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filtros de búsqueda', style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: _limpiar, child: const Text('Limpiar')),
              ],
            ),
            const SizedBox(height: 12),
            Text('Cultivo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<Producto?>(
              initialValue: _cultivo,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.eco),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                const DropdownMenuItem<Producto?>(value: null, child: Text('Todos los cultivos')),
                ...DatosEnMemoria.catalogoProductos.map(
                  (p) => DropdownMenuItem<Producto?>(value: p, child: Text(p.nombre)),
                ),
              ],
              onChanged: (v) => setState(() => _cultivo = v),
            ),
            const SizedBox(height: 20),
            Text(
              'Precio por unidad: C\$${_rango.start.toStringAsFixed(0)} - C\$${_rango.end.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            RangeSlider(
              values: _rango,
              min: widget.precioMinimo,
              max: widget.precioMaximo,
              divisions: 20,
              labels: RangeLabels(
                'C\$${_rango.start.toStringAsFixed(0)}',
                'C\$${_rango.end.toStringAsFixed(0)}',
              ),
              onChanged: (v) => setState(() => _rango = v),
            ),
            const SizedBox(height: 12),
            Text('Departamento', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _departamento,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.map),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Todos los departamentos')),
                ..._departamentosDisponibles.map(
                  (d) => DropdownMenuItem<String?>(value: d, child: Text(d)),
                ),
              ],
              onChanged: _cambiarDepartamento,
            ),
            const SizedBox(height: 12),
            Text('Municipio', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: municipioActual,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Todos los municipios')),
                ..._municipiosDisponibles.map(
                  (m) => DropdownMenuItem<String?>(value: m, child: Text(m)),
                ),
              ],
              onChanged: (v) => setState(() => _municipio = v),
            ),
            const SizedBox(height: 20),
            Text('Modalidad de entrega', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _modalidadesFiltrables.map((modalidad) {
                final seleccionada = _modalidades.contains(modalidad);
                return FilterChip(
                  label: Text(modalidad.etiqueta),
                  selected: seleccionada,
                  selectedColor: ColoresApp.verdeClaro,
                  labelStyle: TextStyle(
                    color: seleccionada ? ColoresApp.verdeOscuro : Colors.black87,
                    fontWeight: seleccionada ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (marcado) => setState(() {
                    if (marcado) {
                      _modalidades.add(modalidad);
                    } else {
                      _modalidades.remove(modalidad);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(
                  _FiltrosCatalogo(
                    cultivo: _cultivo,
                    rangoPrecio: _rango,
                    departamento: _departamento,
                    municipio: municipioActual,
                    modalidades: _modalidades,
                  ),
                ),
                icon: const Icon(Icons.check),
                label: const Text('Aplicar filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
