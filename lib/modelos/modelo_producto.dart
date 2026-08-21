import 'package:flutter/material.dart';

class ModeloProducto {
  final String id;
  final String nombre;
  final String nombreProductor;
  final String comunidad;
  final double precioPorUnidad;
  final String tipoUnidad;
  final int pedidoMinimo;
  final int cantidadDisponible;
  final IconData icono;
  final bool esTratoDirecto;
  final String fechaCosecha;
  final String beneficioProductor;

  const ModeloProducto({
    required this.id,
    required this.nombre,
    required this.nombreProductor,
    required this.comunidad,
    required this.precioPorUnidad,
    required this.tipoUnidad,
    required this.pedidoMinimo,
    required this.cantidadDisponible,
    required this.icono,
    required this.esTratoDirecto,
    required this.fechaCosecha,
    required this.beneficioProductor,
  });
}
