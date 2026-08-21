import 'package:flutter/material.dart';
import '../datos_en_memoria.dart';
import '../modelos/modelo_producto.dart';
import '../modelos/modelo_productor.dart';
import '../tema_app.dart';
import '../widgets/indicador_modo_rural.dart';

class VistaPublicar extends StatefulWidget {
  const VistaPublicar({super.key});

  @override
  State<VistaPublicar> createState() => _VistaPublicarState();
}

class _VistaPublicarState extends State<VistaPublicar> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _cultivos = const [
    'Piña Monte Lirio',
    'Limón Tahití',
    'Naranja de Jugo',
    'Chiltoma Fresca',
    'Plátano',
    'Frijol Rojo',
  ];
  final List<String> _unidades = const ['Docenas', 'Quintales', 'Cien'];

  String _cultivoSeleccionado = 'Piña Monte Lirio';
  String _unidadSeleccionada = 'Docenas';

  final TextEditingController _controladorProductor = TextEditingController();
  final TextEditingController _controladorComunidad = TextEditingController();
  final TextEditingController _controladorCantidad = TextEditingController();
  final TextEditingController _controladorPrecio = TextEditingController();

  double get _precioIngresado => double.tryParse(_controladorPrecio.text) ?? 0;
  double get _precioIntermediarioEstimado => _precioIngresado / 1.35;
  double get _gananciaExtra => _precioIngresado - _precioIntermediarioEstimado;

  @override
  void dispose() {
    _controladorProductor.dispose();
    _controladorComunidad.dispose();
    _controladorCantidad.dispose();
    _controladorPrecio.dispose();
    super.dispose();
  }

  void _publicarLote() {
    if (!_formKey.currentState!.validate()) return;

    final partesComunidad = _controladorComunidad.text.trim().split(',');
    final comunidad = partesComunidad.first.trim();
    final departamento = partesComunidad.length > 1 ? partesComunidad[1].trim() : '';

    final productor = Productor(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      nombre: _controladorProductor.text.trim(),
      departamento: departamento,
      comunidad: comunidad,
      telefono: '',
    );
    DatosEnMemoria.agregarProductor(productor);

    final producto = ModeloProducto(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      nombre: _cultivoSeleccionado,
      productorId: productor.id,
      precioPorUnidad: _precioIngresado,
      tipoUnidad: _unidadSeleccionada,
      cantidadDisponible: int.tryParse(_controladorCantidad.text) ?? 0,
      icono: Icons.eco,
      esTratoDirecto: true,
      fechaCosecha: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
    );

    DatosEnMemoria.agregarProducto(producto);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lote de $_cultivoSeleccionado publicado con éxito'),
        backgroundColor: ColoresApp.verdePrincipal,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Cosecha'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: IndicadorModoRural()),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('¿Quién publica?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controladorProductor,
              decoration: InputDecoration(
                labelText: 'Nombre del productor',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controladorComunidad,
              decoration: InputDecoration(
                labelText: 'Comunidad (Ej. Ticuantepe, Masaya)',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu comunidad' : null,
            ),
            const SizedBox(height: 24),
            Text('¿Qué vas a vender?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _cultivoSeleccionado,
              decoration: InputDecoration(
                labelText: 'Cultivo',
                prefixIcon: const Icon(Icons.eco),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _cultivos
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _cultivoSeleccionado = v ?? _cultivoSeleccionado),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _unidadSeleccionada,
              decoration: InputDecoration(
                labelText: 'Unidad de medida',
                prefixIcon: const Icon(Icons.scale),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _unidades
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (v) => setState(() => _unidadSeleccionada = v ?? _unidadSeleccionada),
            ),
            const SizedBox(height: 24),
            Text('Cantidad y precio', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controladorCantidad,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad disponible',
                prefixIcon: const Icon(Icons.inventory_2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controladorPrecio,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Precio por $_unidadSeleccionada (C\$)',
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColoresApp.amarilloDestacado.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColoresApp.amarilloDestacado),
              ),
              child: Row(
                children: [
                  const Icon(Icons.handshake, color: ColoresApp.naranjaAviso, size: 32),
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
              onPressed: _publicarLote,
              icon: const Icon(Icons.upload),
              label: const Text('Publicar Lote'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
