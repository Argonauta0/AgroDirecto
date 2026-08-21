import 'package:flutter/material.dart';
import 'modelos/modelo_producto.dart';
import 'modelos/modelo_pedido.dart';

class DatosFalsos {
  DatosFalsos._();

  static final List<ModeloProducto> productos = [
    ModeloProducto(
      id: 'p1',
      nombre: 'Piña Monte Lirio',
      nombreProductor: 'Don José García',
      comunidad: 'Ticuantepe, Masaya',
      precioPorUnidad: 350.0,
      tipoUnidad: 'Cien',
      pedidoMinimo: 1,
      cantidadDisponible: 8,
      icono: Icons.eco,
      esTratoDirecto: true,
      fechaCosecha: '18 de agosto, 2026',
      beneficioProductor: '+35% directo al productor',
    ),
    ModeloProducto(
      id: 'p2',
      nombre: 'Limón Tahití',
      nombreProductor: 'Doña Reyna Blandón',
      comunidad: 'Nandaime, Rivas',
      precioPorUnidad: 900.0,
      tipoUnidad: 'Quintales',
      pedidoMinimo: 2,
      cantidadDisponible: 15,
      icono: Icons.spa,
      esTratoDirecto: true,
      fechaCosecha: '19 de agosto, 2026',
      beneficioProductor: '+40% directo al productor',
    ),
    ModeloProducto(
      id: 'p3',
      nombre: 'Naranja de Jugo',
      nombreProductor: 'Carlos Membreño',
      comunidad: 'Belén, Rivas',
      precioPorUnidad: 420.0,
      tipoUnidad: 'Cajas',
      pedidoMinimo: 5,
      cantidadDisponible: 30,
      icono: Icons.eco,
      esTratoDirecto: true,
      fechaCosecha: '15 de agosto, 2026',
      beneficioProductor: '+30% directo al productor',
    ),
    ModeloProducto(
      id: 'p4',
      nombre: 'Chiltoma Fresca',
      nombreProductor: 'Doña Marta Suárez',
      comunidad: 'Masatepe, Masaya',
      precioPorUnidad: 25.0,
      tipoUnidad: 'Cajas',
      pedidoMinimo: 10,
      cantidadDisponible: 60,
      icono: Icons.eco,
      esTratoDirecto: false,
      fechaCosecha: '20 de agosto, 2026',
      beneficioProductor: '+20% directo al productor',
    ),
  ];

  static final List<ModeloPedido> pedidos = [];

  static void agregarProducto(ModeloProducto producto) {
    productos.insert(0, producto);
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
}
