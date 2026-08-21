class ModeloPedido {
  final String id;
  final String productoId;
  final String nombreComprador;
  final int cantidadSolicitada;
  final double totalPagar;
  final String fecha;

  const ModeloPedido({
    required this.id,
    required this.productoId,
    required this.nombreComprador,
    required this.cantidadSolicitada,
    required this.totalPagar,
    required this.fecha,
  });
}
