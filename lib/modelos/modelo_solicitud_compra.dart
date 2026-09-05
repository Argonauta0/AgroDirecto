import 'modelo_oferta_agricola.dart' show ModalidadLogistica;

export 'modelo_oferta_agricola.dart' show ModalidadLogistica, ModalidadLogisticaEtiqueta;

enum EstadoSolicitud {
  enNegociacion,
  confirmado,
  cancelado;

  static const Map<EstadoSolicitud, String> _valoresDb = {
    EstadoSolicitud.enNegociacion: 'EN_NEGOCIACION',
    EstadoSolicitud.confirmado: 'CONFIRMADO',
    EstadoSolicitud.cancelado: 'CANCELADO',
  };

  String toJson() => _valoresDb[this]!;

  static EstadoSolicitud fromJson(String valor) {
    final valorNormalizado = valor.toUpperCase();
    return _valoresDb.entries
        .firstWhere(
          (entrada) => entrada.value == valorNormalizado,
          orElse: () => const MapEntry(EstadoSolicitud.enNegociacion, 'EN_NEGOCIACION'),
        )
        .key;
  }
}

extension EstadoSolicitudEtiqueta on EstadoSolicitud {
  String get etiqueta {
    switch (this) {
      case EstadoSolicitud.enNegociacion:
        return 'En negociación';
      case EstadoSolicitud.confirmado:
        return 'Confirmado';
      case EstadoSolicitud.cancelado:
        return 'Cancelado';
    }
  }
}

class SolicitudCompra {
  final String id;
  final String ofertaId;
  final String compradorId;
  final String productorId;
  final int cantidadSolicitada;
  final double precioUnitario;
  final ModalidadLogistica modalidadLogistica;
  final EstadoSolicitud estado;
  final DateTime creadoEn;

  SolicitudCompra({
    required this.id,
    required this.ofertaId,
    required this.compradorId,
    required this.productorId,
    required this.cantidadSolicitada,
    required this.precioUnitario,
    required this.modalidadLogistica,
    this.estado = EstadoSolicitud.enNegociacion,
    DateTime? creadoEn,
  }) : creadoEn = creadoEn ?? DateTime.now();

  double get subtotal => cantidadSolicitada * precioUnitario;

  factory SolicitudCompra.fromJson(Map<String, dynamic> json) {
    return SolicitudCompra(
      id: json['id'] as String,
      ofertaId: json['ofertaId'] as String,
      compradorId: json['compradorId'] as String,
      productorId: json['productorId'] as String,
      cantidadSolicitada: json['cantidadSolicitada'] as int,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      modalidadLogistica: ModalidadLogistica.fromJson(json['modalidadLogistica'] as String),
      estado: EstadoSolicitud.fromJson(json['estado'] as String? ?? 'EN_NEGOCIACION'),
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
      'modalidadLogistica': modalidadLogistica.toJson(),
      'estado': estado.toJson(),
      'creadoEn': creadoEn.toIso8601String(),
    };
  }

  SolicitudCompra copyWith({
    String? id,
    String? ofertaId,
    String? compradorId,
    String? productorId,
    int? cantidadSolicitada,
    double? precioUnitario,
    ModalidadLogistica? modalidadLogistica,
    EstadoSolicitud? estado,
    DateTime? creadoEn,
  }) {
    return SolicitudCompra(
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
    return other is SolicitudCompra &&
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
      'SolicitudCompra(id: $id, ofertaId: $ofertaId, cantidadSolicitada: $cantidadSolicitada, '
      'subtotal: $subtotal, estado: $estado)';
}
