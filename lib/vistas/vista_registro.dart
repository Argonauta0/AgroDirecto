import 'package:flutter/material.dart';
import '../datos_en_memoria.dart';
import '../modelos/modelo_comprador.dart';
import '../modelos/modelo_productor.dart';
import '../tema_app.dart';
import 'vista_catalogo.dart';
import 'vista_panel_productor.dart';

enum _RolRegistro { productor, comprador }

class VistaRegistro extends StatefulWidget {
  const VistaRegistro({super.key});

  @override
  State<VistaRegistro> createState() => _VistaRegistroState();
}

class _VistaRegistroState extends State<VistaRegistro> {
  _RolRegistro? _rolSeleccionado;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _controladorNombre = TextEditingController();
  final TextEditingController _controladorDepartamento = TextEditingController();
  final TextEditingController _controladorComunidad = TextEditingController();
  final TextEditingController _controladorTelefono = TextEditingController();

  final TextEditingController _controladorNombreNegocio = TextEditingController();
  final TextEditingController _controladorUbicacion = TextEditingController();
  final List<String> _tiposDeNegocio = const [
    'Supermercado',
    'Restaurante',
    'Hotel',
    'Pulpería',
    'Otro',
  ];
  String _tipoNegocioSeleccionado = 'Supermercado';

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorDepartamento.dispose();
    _controladorComunidad.dispose();
    _controladorTelefono.dispose();
    _controladorNombreNegocio.dispose();
    _controladorUbicacion.dispose();
    super.dispose();
  }

  void _elegirRol(_RolRegistro rol) {
    setState(() => _rolSeleccionado = rol);
  }

  void _registrar() {
    if (!_formKey.currentState!.validate()) return;

    if (_rolSeleccionado == _RolRegistro.productor) {
      final productor = Productor(
        id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
        nombre: _controladorNombre.text.trim(),
        departamento: _controladorDepartamento.text.trim(),
        comunidad: _controladorComunidad.text.trim(),
        telefono: _controladorTelefono.text.trim(),
      );
      DatosEnMemoria.agregarProductor(productor);
      DatosEnMemoria.iniciarSesionComoProductor(productor.id);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const VistaPanelProductor()),
      );
    } else {
      final comprador = Comprador(
        id: 'comp_${DateTime.now().millisecondsSinceEpoch}',
        nombreNegocio: _controladorNombreNegocio.text.trim(),
        tipoNegocio: _tipoNegocioSeleccionado,
        ubicacion: _controladorUbicacion.text.trim(),
        telefono: _controladorTelefono.text.trim(),
      );
      DatosEnMemoria.agregarComprador(comprador);
      DatosEnMemoria.iniciarSesionComoComprador(comprador.id);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const VistaCatalogo()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.blancoFondo,
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_rolSeleccionado != null) {
              setState(() => _rolSeleccionado = null);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _rolSeleccionado == null ? _selectorDeRol() : _formularioDeRegistro(),
        ),
      ),
    );
  }

  Widget _selectorDeRol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '¿Cómo quieres usar AgroDirecto?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ColoresApp.verdeOscuro),
        ),
        const SizedBox(height: 4),
        const Text(
          'Elige tu tipo de cuenta para continuar',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 24),
        _TarjetaRol(
          icono: Icons.agriculture,
          titulo: 'Soy Productor Agrícola',
          subtitulo: 'Publica y gestiona tus cosechas',
          color: ColoresApp.verdePrincipal,
          onTap: () => _elegirRol(_RolRegistro.productor),
        ),
        const SizedBox(height: 12),
        _TarjetaRol(
          icono: Icons.storefront,
          titulo: 'Soy Comprador / Restaurante',
          subtitulo: 'Explora el catálogo y reserva cosechas',
          color: ColoresApp.naranjaAviso,
          onTap: () => _elegirRol(_RolRegistro.comprador),
        ),
      ],
    );
  }

  Widget _formularioDeRegistro() {
    final esProductor = _rolSeleccionado == _RolRegistro.productor;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: (esProductor ? ColoresApp.verdePrincipal : ColoresApp.naranjaAviso)
                    .withValues(alpha: 0.15),
                child: Icon(
                  esProductor ? Icons.agriculture : Icons.storefront,
                  color: esProductor ? ColoresApp.verdePrincipal : ColoresApp.naranjaAviso,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  esProductor ? 'Registro de Productor Agrícola' : 'Registro de Comprador / Restaurante',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (esProductor) ..._camposProductor() else ..._camposComprador(),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _registrar,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Crear cuenta'),
          ),
        ],
      ),
    );
  }

  List<Widget> _camposProductor() {
    return [
      TextFormField(
        controller: _controladorNombre,
        decoration: InputDecoration(
          labelText: 'Nombre completo',
          prefixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _controladorDepartamento,
        decoration: InputDecoration(
          labelText: 'Departamento',
          prefixIcon: const Icon(Icons.map),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu departamento' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _controladorComunidad,
        decoration: InputDecoration(
          labelText: 'Comunidad',
          prefixIcon: const Icon(Icons.location_on),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu comunidad' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _controladorTelefono,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: 'Teléfono',
          prefixIcon: const Icon(Icons.phone),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu teléfono' : null,
      ),
    ];
  }

  List<Widget> _camposComprador() {
    return [
      TextFormField(
        controller: _controladorNombreNegocio,
        decoration: InputDecoration(
          labelText: 'Nombre del negocio',
          prefixIcon: const Icon(Icons.storefront),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre del negocio' : null,
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: _tipoNegocioSeleccionado,
        decoration: InputDecoration(
          labelText: 'Tipo de negocio',
          prefixIcon: const Icon(Icons.category),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: _tiposDeNegocio.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (v) => setState(() => _tipoNegocioSeleccionado = v ?? _tipoNegocioSeleccionado),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _controladorUbicacion,
        decoration: InputDecoration(
          labelText: 'Ubicación',
          prefixIcon: const Icon(Icons.location_on),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa la ubicación' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _controladorTelefono,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: 'Teléfono',
          prefixIcon: const Icon(Icons.phone),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu teléfono' : null,
      ),
    ];
  }
}

class _TarjetaRol extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;

  const _TarjetaRol({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icono, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      subtitulo,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
