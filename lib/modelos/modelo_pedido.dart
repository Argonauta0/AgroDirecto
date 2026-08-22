class Pedido {
  final String id;
  final String productoId;
  final String compradorId;
  final int cantidadSolicitada;
  final double totalPagar;
  final DateTime fecha;

  const Pedido({
    required this.id,
    required this.productoId,
    required this.compradorId,
    required this.cantidadSolicitada,
    required this.totalPagar,
    required this.fecha,
  });
}
