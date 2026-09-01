import 'package:flutter/material.dart';
import '../datos_en_memoria.dart';
import '../tema_app.dart';
import 'vista_catalogo.dart';
import 'vista_panel_productor.dart';
import 'vista_registro.dart';

class VistaLogin extends StatefulWidget {
  const VistaLogin({super.key});

  @override
  State<VistaLogin> createState() => _VistaLoginState();
}

class _VistaLoginState extends State<VistaLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controladorTelefono = TextEditingController();
  final TextEditingController _controladorClave = TextEditingController();
  bool _claveVisible = false;

  @override
  void dispose() {
    _controladorTelefono.dispose();
    _controladorClave.dispose();
    super.dispose();
  }

  void _iniciarSesionManual() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Usa el acceso rápido para demo mientras habilitamos el inicio con teléfono.',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: ColoresApp.naranjaAviso,
      ),
    );
  }

  void _irARegistro() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const VistaRegistro()),
    );
  }

  void _entrarComoProductor() {
    final primerProductor = DatosEnMemoria.usuarios.firstWhere((u) => u.esProductor);
    DatosEnMemoria.iniciarSesion(primerProductor.id);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const VistaPanelProductor()),
    );
  }

  void _entrarComoComprador() {
    final primerComprador = DatosEnMemoria.usuarios.firstWhere((u) => u.esComprador);
    DatosEnMemoria.iniciarSesion(primerComprador.id);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const VistaCatalogo()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.blancoFondo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Image.asset(
                'assets/branding/logo_full.png',
                height: 96,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 4),
              const Text(
                'Del campo a tu negocio, sin intermediarios',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _controladorTelefono,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Ingresa tu teléfono' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controladorClave,
                      obscureText: !_claveVisible,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_claveVisible ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _claveVisible = !_claveVisible),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Ingresa tu contraseña' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _iniciarSesionManual,
                      icon: const Icon(Icons.login),
                      label: const Text('Iniciar Sesión'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿No tienes una cuenta?',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        TextButton(
                          onPressed: _irARegistro,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Regístrate aquí',
                            style: TextStyle(
                              color: ColoresApp.verdePrincipal,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Acceso Rápido para Demo',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 16),
              _TarjetaAccesoDemo(
                icono: Icons.agriculture,
                titulo: 'Soy Productor Agrícola',
                subtitulo: 'Publica y gestiona tus cosechas',
                color: ColoresApp.verdePrincipal,
                onTap: _entrarComoProductor,
              ),
              const SizedBox(height: 12),
              _TarjetaAccesoDemo(
                icono: Icons.storefront,
                titulo: 'Soy Comprador / Restaurante',
                subtitulo: 'Explora el catálogo y reserva cosechas',
                color: ColoresApp.naranjaAviso,
                onTap: _entrarComoComprador,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaAccesoDemo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;

  const _TarjetaAccesoDemo({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Naranja tiene demasiada luminancia para servir como color de ícono
    // sobre el tinte casi blanco del CircleAvatar (no cumple el 3:1 de WCAG);
    // se resuelve con una variante oscura accesible solo para ese caso.
    final Color colorIcono = ColoresApp.colorAcentoAccesible(color);
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
                child: Icon(icono, color: colorIcono),
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
              Icon(Icons.arrow_forward_ios, size: 16, color: colorIcono),
            ],
          ),
        ),
      ),
    );
  }
}
