enum UnidadMedida {
  quintal,
  cien;

  static const Map<UnidadMedida, String> _valoresDb = {
    UnidadMedida.quintal: 'QUINTAL',
    UnidadMedida.cien: 'CIEN',
  };

  String toJson() => _valoresDb[this]!;

  static UnidadMedida fromJson(String valor) {
    final valorNormalizado = valor.toUpperCase();
    return _valoresDb.entries
        .firstWhere(
          (entrada) => entrada.value == valorNormalizado,
          orElse: () => const MapEntry(UnidadMedida.quintal, 'QUINTAL'),
        )
        .key;
  }
}

extension UnidadMedidaEtiqueta on UnidadMedida {
  String get etiqueta {
    switch (this) {
      case UnidadMedida.quintal:
        return 'Quintal';
      case UnidadMedida.cien:
        return 'Cien';
    }
  }
}

enum ModalidadLogisticaOferta {
  retiro,
  envioProductor,
  transportista,
  todas;

  static const Map<ModalidadLogisticaOferta, String> _valoresDb = {
    ModalidadLogisticaOferta.retiro: 'RETIRO',
    ModalidadLogisticaOferta.envioProductor: 'ENVIO_PRODUCTOR',
    ModalidadLogisticaOferta.transportista: 'TRANSPORTISTA',
    ModalidadLogisticaOferta.todas: 'TODAS',
  };

  String toJson() => _valoresDb[this]!;

  static ModalidadLogisticaOferta fromJson(String valor) {
    final valorNormalizado = valor.toUpperCase();
    return _valoresDb.entries
        .firstWhere(
          (entrada) => entrada.value == valorNormalizado,
          orElse: () => const MapEntry(ModalidadLogisticaOferta.todas, 'TODAS'),
        )
        .key;
  }
}

extension ModalidadLogisticaOfertaEtiqueta on ModalidadLogisticaOferta {
  String get etiqueta {
    switch (this) {
      case ModalidadLogisticaOferta.retiro:
        return 'Retiro en finca';
      case ModalidadLogisticaOferta.envioProductor:
        return 'Envío del productor';
      case ModalidadLogisticaOferta.transportista:
        return 'Transportista';
      case ModalidadLogisticaOferta.todas:
        return 'Todas las modalidades';
    }
  }
}

enum EstadoOferta {
  disponible,
  pausada,
  agotado;

  static const Map<EstadoOferta, String> _valoresDb = {
    EstadoOferta.disponible: 'DISPONIBLE',
    EstadoOferta.pausada: 'PAUSADA',
    EstadoOferta.agotado: 'AGOTADO',
  };

  String toJson() => _valoresDb[this]!;

  static EstadoOferta fromJson(String valor) {
    final valorNormalizado = valor.toUpperCase();
    return _valoresDb.entries
        .firstWhere(
          (entrada) => entrada.value == valorNormalizado,
          orElse: () => const MapEntry(EstadoOferta.disponible, 'DISPONIBLE'),
        )
        .key;
  }
}

extension EstadoOfertaEtiqueta on EstadoOferta {
  String get etiqueta {
    switch (this) {
      case EstadoOferta.disponible:
        return 'Disponible';
      case EstadoOferta.pausada:
        return 'Pausada';
      case EstadoOferta.agotado:
        return 'Agotado';
    }
  }
}

class OfertaLote {
  final String id;
  final String productorId;
  final String productoId;
  final double precioUnitario;
  final UnidadMedida unidadMedida;
  final int cantidadTotal;
  final int cantidadDisponible;
  final ModalidadLogisticaOferta modalidadLogistica;
  final DateTime? fechaCosecha;
  final EstadoOferta estado;
  final DateTime creadoEn;

  OfertaLote({
    required this.id,
    required this.productorId,
    required this.productoId,
    required this.precioUnitario,
    required this.unidadMedida,
    required this.cantidadTotal,
    required this.cantidadDisponible,
    required this.modalidadLogistica,
    this.fechaCosecha,
    this.estado = EstadoOferta.disponible,
    DateTime? creadoEn,
  }) : creadoEn = creadoEn ?? DateTime.now();

  bool get estaDisponible => estado == EstadoOferta.disponible && cantidadDisponible > 0;

  factory OfertaLote.fromJson(Map<String, dynamic> json) {
    return OfertaLote(
      id: json['id'] as String,
      productorId: json['productorId'] as String,
      productoId: json['productoId'] as String,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      unidadMedida: UnidadMedida.fromJson(json['unidadMedida'] as String),
      cantidadTotal: json['cantidadTotal'] as int,
      cantidadDisponible: json['cantidadDisponible'] as int,
      modalidadLogistica: ModalidadLogisticaOferta.fromJson(json['modalidadLogistica'] as String),
      fechaCosecha:
          json['fechaCosecha'] != null ? DateTime.parse(json['fechaCosecha'] as String) : null,
      estado: EstadoOferta.fromJson(json['estado'] as String? ?? 'DISPONIBLE'),
      creadoEn: json['creadoEn'] != null ? DateTime.parse(json['creadoEn'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productorId': productorId,
      'productoId': productoId,
      'precioUnitario': precioUnitario,
      'unidadMedida': unidadMedida.toJson(),
      'cantidadTotal': cantidadTotal,
      'cantidadDisponible': cantidadDisponible,
      'modalidadLogistica': modalidadLogistica.toJson(),
      'fechaCosecha': fechaCosecha?.toIso8601String(),
      'estado': estado.toJson(),
      'creadoEn': creadoEn.toIso8601String(),
    };
  }

  OfertaLote copyWith({
    String? id,
    String? productorId,
    String? productoId,
    double? precioUnitario,
    UnidadMedida? unidadMedida,
    int? cantidadTotal,
    int? cantidadDisponible,
    ModalidadLogisticaOferta? modalidadLogistica,
    DateTime? fechaCosecha,
    EstadoOferta? estado,
    DateTime? creadoEn,
  }) {
    return OfertaLote(
      id: id ?? this.id,
      productorId: productorId ?? this.productorId,
      productoId: productoId ?? this.productoId,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      cantidadTotal: cantidadTotal ?? this.cantidadTotal,
      cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
      modalidadLogistica: modalidadLogistica ?? this.modalidadLogistica,
      fechaCosecha: fechaCosecha ?? this.fechaCosecha,
      estado: estado ?? this.estado,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OfertaLote &&
        other.id == id &&
        other.productorId == productorId &&
        other.productoId == productoId &&
        other.precioUnitario == precioUnitario &&
        other.unidadMedida == unidadMedida &&
        other.cantidadTotal == cantidadTotal &&
        other.cantidadDisponible == cantidadDisponible &&
        other.modalidadLogistica == modalidadLogistica &&
        other.fechaCosecha == fechaCosecha &&
        other.estado == estado &&
        other.creadoEn == creadoEn;
  }

  @override
  int get hashCode => Object.hash(
        id,
        productorId,
        productoId,
        precioUnitario,
        unidadMedida,
        cantidadTotal,
        cantidadDisponible,
        modalidadLogistica,
        fechaCosecha,
        estado,
        creadoEn,
      );

  @override
  String toString() =>
      'OfertaLote(id: $id, productoId: $productoId, productorId: $productorId, '
      'precioUnitario: $precioUnitario, cantidadDisponible: $cantidadDisponible, estado: $estado)';
}

extension OfertaLoteEstadoVisual on OfertaLote {
  String get estadoVisualTexto {
    if (estado == EstadoOferta.pausada) return 'Pausada';
    if (estado == EstadoOferta.agotado || cantidadDisponible <= 0) return 'Agotada';
    if (cantidadDisponible < cantidadTotal) return 'Parcialmente Vendida';
    return 'Activa';
  }
}
