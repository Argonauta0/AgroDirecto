import 'package:flutter/material.dart';
import 'modelos/modelo_producto.dart';
import 'modelos/modelo_pedido.dart';
import 'modelos/modelo_usuario.dart';

class DatosEnMemoria {
  DatosEnMemoria._();

  static final List<Usuario> usuarios = [
    Usuario(
      id: 'prod1',
      nombreCompleto: 'Don José García',
      telefono: '8888-1111',
      tipoPerfil: TipoPerfil.productor,
      departamento: 'Masaya',
      municipio: 'Ticuantepe',
      direccionExacta: 'Finca El Roble, Ticuantepe',
    ),
    Usuario(
      id: 'prod2',
      nombreCompleto: 'Doña Reyna Blandón',
      telefono: '8888-2222',
      tipoPerfil: TipoPerfil.productor,
      departamento: 'Rivas',
      municipio: 'Nandaime',
      direccionExacta: 'Comunidad El Limonal, Nandaime',
    ),
    Usuario(
      id: 'prod3',
      nombreCompleto: 'Carlos Membreño',
      telefono: '8888-3333',
      tipoPerfil: TipoPerfil.productor,
      departamento: 'Rivas',
      municipio: 'Belén',
      direccionExacta: 'Finca Santa Rosa, Belén',
    ),
    Usuario(
      id: 'prod4',
      nombreCompleto: 'Doña Marta Suárez',
      telefono: '8888-4444',
      tipoPerfil: TipoPerfil.productor,
      departamento: 'Masaya',
      municipio: 'Masatepe',
      direccionExacta: 'Comunidad San Juan, Masatepe',
    ),
    Usuario(
      id: 'comp1',
      nombreCompleto: 'Supermercado La Colonia',
      telefono: '2222-5555',
      tipoPerfil: TipoPerfil.comprador,
      departamento: 'Managua',
      municipio: 'Managua',
      direccionExacta: 'Bodega Central, Km 7 Carretera Masaya',
    ),
  ];

  static List<Usuario> get productores =>
      usuarios.where((u) => u.tipoPerfil == TipoPerfil.productor).toList();

  static List<Usuario> get compradores =>
      usuarios.where((u) => u.tipoPerfil == TipoPerfil.comprador).toList();

  static final List<Producto> productos = [
    Producto(
      id: 'p1',
      nombre: 'Piña Monte Lirio',
      productorId: 'prod1',
      precioPorUnidad: 350.0,
      tipoUnidad: 'Cien',
      cantidadDisponible: 8,
      icono: Icons.eco,
      esTratoDirecto: true,
      fechaCosecha: DateTime(2026, 8, 18),
    ),
    Producto(
      id: 'p2',
      nombre: 'Limón Tahití',
      productorId: 'prod2',
      precioPorUnidad: 900.0,
      tipoUnidad: 'Quintales',
      cantidadDisponible: 15,
      icono: Icons.spa,
      esTratoDirecto: true,
      fechaCosecha: DateTime(2026, 8, 19),
    ),
    Producto(
      id: 'p3',
      nombre: 'Naranja de Jugo',
      productorId: 'prod3',
      precioPorUnidad: 420.0,
      tipoUnidad: 'Docenas',
      cantidadDisponible: 30,
      icono: Icons.eco,
      esTratoDirecto: true,
      fechaCosecha: DateTime(2026, 8, 15),
    ),
    Producto(
      id: 'p4',
      nombre: 'Chiltoma Fresca',
      productorId: 'prod4',
      precioPorUnidad: 25.0,
      tipoUnidad: 'Docenas',
      cantidadDisponible: 60,
      icono: Icons.eco,
      esTratoDirecto: false,
      fechaCosecha: DateTime(2026, 8, 20),
    ),
  ];

  static final List<Pedido> pedidos = [];

  static void agregarProducto(Producto producto) {
    productos.insert(0, producto);
  }

  static void eliminarProducto(String id) {
    productos.removeWhere((p) => p.id == id);
  }

  static void agregarUsuario(Usuario usuario) {
    usuarios.insert(0, usuario);
  }

  static void agregarPedido(Pedido pedido) {
    pedidos.insert(0, pedido);
  }

  static Producto? buscarProductoPorId(String id) {
    try {
      return productos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static Usuario? obtenerUsuarioPorId(String id) {
    try {
      return usuarios.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  static Usuario? usuarioActual;

  static void iniciarSesion(String id) {
    final usuario = obtenerUsuarioPorId(id);
    if (usuario == null) return;
    usuarioActual = usuario;
  }

  static void cerrarSesion() {
    usuarioActual = null;
  }
}
