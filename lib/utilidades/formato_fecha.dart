const List<String> _mesesEnEspanol = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

String formatearFecha(DateTime fecha) {
  return '${fecha.day} de ${_mesesEnEspanol[fecha.month - 1]}, ${fecha.year}';
}
