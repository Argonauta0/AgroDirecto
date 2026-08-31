enum ModalidadLogisticaPedido {
  retiro,
  envioProductor,
  transportista;

  static const Map<ModalidadLogisticaPedido, String> _valoresDb = {
    ModalidadLogisticaPedido.retiro: 'RETIRO',
    ModalidadLogisticaPedido.envioProductor: 'ENVIO_PRODUCTOR',
    ModalidadLogisticaPedido.transportista: 'TRANSPORTISTA',
  };

  String toJson() => _valoresDb[this]!;

  static ModalidadLogisticaPedido fromJson(String valor) {
    final valorNormalizado = valor.toUpperCase();
    return _valoresDb.entries
        .firstWhere(
          (entrada) => entrada.value == valorNormalizado,
          orElse: () => const MapEntry(ModalidadLogisticaPedido.retiro, 'RETIRO'),
        )
        .key;
  }
}

extension ModalidadLogisticaPedidoEtiqueta on ModalidadLogisticaPedido {
  String get etiqueta {
    switch (this) {
      case ModalidadLogisticaPedido.retiro:
        return 'Retiro en finca';
      case ModalidadLogisticaPedido.envioProductor:
        return 'Envío del productor';
      case ModalidadLogisticaPedido.transportista:
        return 'Transportista';
    }
  }
}

enum EstadoPedido {
  enNegociacion,
  vendido,
  cancelado;

  static const Map<EstadoPedido, String> _valoresDb = {
    EstadoPedido.enNegociacion: 'EN_NEGOCIACION',
    EstadoPedido.vendido: 'VENDIDO',
    EstadoPedido.cancelado: 'CANCELADO',
  };

  String toJson() => _valoresDb[this]!;

  static EstadoPedido fromJson(String valor) {
    final valorNormalizado = valor.toUpperCase();
    return _valoresDb.entries
        .firstWhere(
          (entrada) => entrada.value == valorNormalizado,
          orElse: () => const MapEntry(EstadoPedido.enNegociacion, 'EN_NEGOCIACION'),
        )
        .key;
  }
}

extension EstadoPedidoEtiqueta on EstadoPedido {
  String get etiqueta {
    switch (this) {
      case EstadoPedido.enNegociacion:
        return 'En negociación';
      case EstadoPedido.vendido:
        return 'Vendido';
      case EstadoPedido.cancelado:
        return 'Cancelado';
    }
  }
}

class Pedido {
  static const double comisionPlataformaPorcentaje = 0.06;

  final String id;
  final String ofertaId;
  final String compradorId;
  final String productorId;
  final int cantidadSolicitada;
  final double precioUnitario;
  final double totalBruto;
  final double comisionPlataforma;
  final double ingresoNetoProductor;
  final ModalidadLogisticaPedido modalidadLogistica;
  final EstadoPedido estado;
  final DateTime creadoEn;

  Pedido({
    required this.id,
    required this.ofertaId,
    required this.compradorId,
    required this.productorId,
    required this.cantidadSolicitada,
    required this.precioUnitario,
    required this.modalidadLogistica,
    this.estado = EstadoPedido.enNegociacion,
    DateTime? creadoEn,
  })  : totalBruto = cantidadSolicitada * precioUnitario,
        comisionPlataforma = cantidadSolicitada * precioUnitario * comisionPlataformaPorcentaje,
        ingresoNetoProductor =
            cantidadSolicitada * precioUnitario * (1 - comisionPlataformaPorcentaje),
        creadoEn = creadoEn ?? DateTime.now();

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'] as String,
      ofertaId: json['ofertaId'] as String,
      compradorId: json['compradorId'] as String,
      productorId: json['productorId'] as String,
      cantidadSolicitada: json['cantidadSolicitada'] as int,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      modalidadLogistica: ModalidadLogisticaPedido.fromJson(json['modalidadLogistica'] as String),
      estado: EstadoPedido.fromJson(json['estado'] as String? ?? 'EN_NEGOCIACION'),
      creadoEn: json['creadoEn'] != null ? DateTime.parse(json['creadoEn'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ofertaId': ofertaId,
      'compradorId': compradorId,
      'productorId': productorId,
      'cantidadSolicitada': cantidadSolicitada,
      'precioUnitario': precioUnitario,
      'totalBruto': totalBruto,
      'comisionPlataforma': comisionPlataforma,
      'ingresoNetoProductor': ingresoNetoProductor,
      'modalidadLogistica': modalidadLogistica.toJson(),
      'estado': estado.toJson(),
      'creadoEn': creadoEn.toIso8601String(),
    };
  }

  Pedido copyWith({
    String? id,
    String? ofertaId,
    String? compradorId,
    String? productorId,
    int? cantidadSolicitada,
    double? precioUnitario,
    ModalidadLogisticaPedido? modalidadLogistica,
    EstadoPedido? estado,
    DateTime? creadoEn,
  }) {
    return Pedido(
      id: id ?? this.id,
      ofertaId: ofertaId ?? this.ofertaId,
      compradorId: compradorId ?? this.compradorId,
      productorId: productorId ?? this.productorId,
      cantidadSolicitada: cantidadSolicitada ?? this.cantidadSolicitada,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      modalidadLogistica: modalidadLogistica ?? this.modalidadLogistica,
      estado: estado ?? this.estado,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pedido &&
        other.id == id &&
        other.ofertaId == ofertaId &&
        other.compradorId == compradorId &&
        other.productorId == productorId &&
        other.cantidadSolicitada == cantidadSolicitada &&
        other.precioUnitario == precioUnitario &&
        other.modalidadLogistica == modalidadLogistica &&
        other.estado == estado &&
        other.creadoEn == creadoEn;
  }

  @override
  int get hashCode => Object.hash(
        id,
        ofertaId,
        compradorId,
        productorId,
        cantidadSolicitada,
        precioUnitario,
        modalidadLogistica,
        estado,
        creadoEn,
      );

  @override
  String toString() =>
      'Pedido(id: $id, ofertaId: $ofertaId, cantidadSolicitada: $cantidadSolicitada, '
      'totalBruto: $totalBruto, estado: $estado)';
}
