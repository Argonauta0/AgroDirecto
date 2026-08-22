import 'package:flutter/material.dart';

class Producto {
  final String id;
  final String nombre;
  final String productorId;
  final double precioPorUnidad;
  final String tipoUnidad;
  final int cantidadDisponible;
  final IconData icono;
  final bool esTratoDirecto;
  final DateTime fechaCosecha;

  const Producto({
    required this.id,
    required this.nombre,
    required this.productorId,
    required this.precioPorUnidad,
    required this.tipoUnidad,
    required this.cantidadDisponible,
    required this.icono,
    required this.esTratoDirecto,
    required this.fechaCosecha,
  });
}
