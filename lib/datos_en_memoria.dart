import 'package:flutter/material.dart';
import 'modelos/modelo_producto.dart';
import 'modelos/modelo_pedido.dart';
import 'modelos/modelo_productor.dart';
import 'modelos/modelo_comprador.dart';

class DatosEnMemoria {
  DatosEnMemoria._();

  static final List<Productor> productores = [
    Productor(
      id: 'prod1',
      nombre: 'Don José García',
      departamento: 'Masaya',
      comunidad: 'Ticuantepe',
      telefono: '8888-1111',
    ),
    Productor(
      id: 'prod2',
      nombre: 'Doña Reyna Blandón',
      departamento: 'Rivas',
      comunidad: 'Nandaime',
      telefono: '8888-2222',
    ),
    Productor(
      id: 'prod3',
      nombre: 'Carlos Membreño',
      departamento: 'Rivas',
      comunidad: 'Belén',
      telefono: '8888-3333',
    ),
    Productor(
      id: 'prod4',
      nombre: 'Doña Marta Suárez',
      departamento: 'Masaya',
      comunidad: 'Masatepe',
      telefono: '8888-4444',
    ),
  ];

  static final List<Comprador> compradores = [
    Comprador(
      id: 'comp1',
      nombreNegocio: 'Supermercado La Colonia',
      tipoNegocio: 'Supermercado',
      ubicacion: 'Managua',
      telefono: '2222-5555',
    ),
  ];

  static final List<ModeloProducto> productos = [
    ModeloProducto(
      id: 'p1',
      nombre: 'Piña Monte Lirio',
      productorId: 'prod1',
      precioPorUnidad: 350.0,
      tipoUnidad: 'Cien',
      cantidadDisponible: 8,
      icono: Icons.eco,
      esTratoDirecto: true,
      fechaCosecha: '18 de agosto, 2026',
    ),
    ModeloProducto(
      id: 'p2',
      nombre: 'Limón Tahití',
      productorId: 'prod2',
      precioPorUnidad: 900.0,
      tipoUnidad: 'Quintales',
      cantidadDisponible: 15,
      icono: Icons.spa,
      esTratoDirecto: true,
      fechaCosecha: '19 de agosto, 2026',
    ),
    ModeloProducto(
      id: 'p3',
      nombre: 'Naranja de Jugo',
      productorId: 'prod3',
      precioPorUnidad: 420.0,
      tipoUnidad: 'Docenas',
      cantidadDisponible: 30,
      icono: Icons.eco,
      esTratoDirecto: true,
      fechaCosecha: '15 de agosto, 2026',
    ),
    ModeloProducto(
      id: 'p4',
      nombre: 'Chiltoma Fresca',
      productorId: 'prod4',
      precioPorUnidad: 25.0,
      tipoUnidad: 'Docenas',
      cantidadDisponible: 60,
      icono: Icons.eco,
      esTratoDirecto: false,
      fechaCosecha: '20 de agosto, 2026',
    ),
  ];

  static final List<ModeloPedido> pedidos = [];

  static void agregarProducto(ModeloProducto producto) {
    productos.insert(0, producto);
  }

  static void agregarProductor(Productor productor) {
    productores.insert(0, productor);
  }

  static void agregarPedido(ModeloPedido pedido) {
    pedidos.insert(0, pedido);
  }

  static ModeloProducto? buscarProductoPorId(String id) {
    try {
      return productos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static Productor? obtenerProductorPorId(String id) {
    try {
      return productores.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static Comprador? obtenerCompradorPorId(String id) {
    try {
      return compradores.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static Productor? productorActual;
  static Comprador? compradorActual;
  static String rolActual = 'ninguno';

  static void iniciarSesionComoProductor(String id) {
    final productor = obtenerProductorPorId(id);
    if (productor == null) return;
    productorActual = productor;
    compradorActual = null;
    rolActual = 'productor';
  }

  static void iniciarSesionComoComprador(String id) {
    final comprador = obtenerCompradorPorId(id);
    if (comprador == null) return;
    compradorActual = comprador;
    productorActual = null;
    rolActual = 'comprador';
  }

  static void cerrarSesion() {
    productorActual = null;
    compradorActual = null;
    rolActual = 'ninguno';
  }
}
