import 'package:flutter/material.dart';
import '../datos_en_memoria.dart';
import '../modelos/modelo_producto.dart';
import '../tema_app.dart';
import '../widgets/indicador_modo_rural.dart';
import 'vista_login.dart';

class VistaPublicar extends StatefulWidget {
  const VistaPublicar({super.key});

  @override
  State<VistaPublicar> createState() => _VistaPublicarState();
}

class _VistaPublicarState extends State<VistaPublicar> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _cultivosSugeridos = const [
    'Piña Monte Lirio',
    'Limón Tahití',
    'Naranja de Jugo',
    'Chiltoma Fresca',
    'Plátano',
    'Frijol Rojo',
  ];
  final List<String> _unidades = const ['Docenas', 'Quintales', 'Cien'];

  String _unidadSeleccionada = 'Docenas';
  late TextEditingController _controladorCultivo;

  final TextEditingController _controladorCantidad = TextEditingController();
  final TextEditingController _controladorPrecio = TextEditingController();

  double get _precioIngresado => double.tryParse(_controladorPrecio.text) ?? 0;
  double get _precioIntermediarioEstimado => _precioIngresado / 1.35;
  double get _gananciaExtra => _precioIngresado - _precioIntermediarioEstimado;

  @override
  void dispose() {
    _controladorCantidad.dispose();
    _controladorPrecio.dispose();
    super.dispose();
  }

  void _publicarLote() {
    if (!_formKey.currentState!.validate()) return;

    final productorActual = DatosEnMemoria.usuarioActual;
    if (productorActual == null) return;

    final cultivo = _controladorCultivo.text.trim();

    final producto = Producto(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      nombre: cultivo,
      productorId: productorActual.id,
      precioPorUnidad: double.parse(_controladorPrecio.text),
      tipoUnidad: _unidadSeleccionada,
      cantidadDisponible: int.parse(_controladorCantidad.text),
      icono: Icons.eco,
      esTratoDirecto: true,
      fechaCosecha: DateTime.now(),
    );

    DatosEnMemoria.agregarProducto(producto);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lote de $cultivo publicado con éxito'),
        backgroundColor: ColoresApp.verdePrincipal,
      ),
    );
    Navigator.of(context).pop();
  }

  void _cerrarSesion() {
    DatosEnMemoria.cerrarSesion();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const VistaLogin()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final productorActual = DatosEnMemoria.usuarioActual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Cosecha'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: IndicadorModoRural()),
          ),
          IconButton(
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Form(
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
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return _cultivosSugeridos;
                return _cultivosSugeridos.where(
                  (c) => c.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                );
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                _controladorCultivo = controller;
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Cultivo',
                    hintText: 'Ej. Piña Monte Lirio',
                    prefixIcon: const Icon(Icons.eco),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el cultivo' : null,
                );
              },
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
