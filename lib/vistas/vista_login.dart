import 'package:flutter/material.dart';
import '../modelos/modelo_usuario.dart';
import '../servicios/servicio_supabase.dart';
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
  bool _cargando = false;

  @override
  void dispose() {
    _controladorTelefono.dispose();
    _controladorClave.dispose();
    super.dispose();
  }

  void _irAVistaSegunPerfil(Usuario usuario) {
    if (usuario.esProductor) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const VistaPanelProductor()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const VistaCatalogo()),
      );
    }
  }

  Future<void> _iniciarSesionManual() async {
    if (_cargando) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    try {
      final usuario = await ServicioSupabase.login(
        _controladorTelefono.text.trim(),
        _controladorClave.text,
      );
      if (!mounted) return;

      if (usuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Teléfono o contraseña incorrectos.',
              style: TextStyle(color: Colors.black87),
            ),
            backgroundColor: ColoresApp.naranjaAviso,
          ),
        );
        return;
      }

      ServicioSupabase.usuarioActual = usuario;
      _irAVistaSegunPerfil(usuario);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _irARegistro() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const VistaRegistro()),
    );
  }

  Future<void> _entrarComoDemo(TipoPerfil perfil) async {
    if (_cargando) return;

    setState(() => _cargando = true);
    try {
      final usuarios = await ServicioSupabase.obtenerUsuariosPorPerfil(perfil);
      if (!mounted) return;

      if (usuarios.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay usuarios de demo registrados para este perfil.')),
        );
        return;
      }

      final usuario = usuarios.first;
      ServicioSupabase.usuarioActual = usuario;
      _irAVistaSegunPerfil(usuario);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión con Supabase: $e')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
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
                      onPressed: _cargando ? null : _iniciarSesionManual,
                      icon: _cargando
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
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
                onTap: () => _entrarComoDemo(TipoPerfil.productor),
              ),
              const SizedBox(height: 12),
              _TarjetaAccesoDemo(
                icono: Icons.storefront,
                titulo: 'Soy Comprador / Restaurante',
                subtitulo: 'Explora el catálogo y reserva cosechas',
                color: ColoresApp.naranjaAviso,
                onTap: () => _entrarComoDemo(TipoPerfil.comprador),
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
