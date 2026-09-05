enum UnidadMedida {
  quintal,
  cien,
  kg;

  static const Map<UnidadMedida, String> _valoresDb = {
    UnidadMedida.quintal: 'QUINTAL',
    UnidadMedida.cien: 'CIEN',
    UnidadMedida.kg: 'KG',
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
      case UnidadMedida.kg:
        return 'Kilogramo';
    }
  }
}

/// Modalidad de logística acordada. Compartida entre [OfertaAgricola] y
/// SolicitudCompra (modelo_solicitud_compra.dart) según el DER.
enum ModalidadLogistica {
  retiro,
  envioProductor,
  transportista,
  todas;

  static const Map<ModalidadLogistica, String> _valoresDb = {
    ModalidadLogistica.retiro: 'RETIRO',
    ModalidadLogistica.envioProductor: 'ENVIO_PRODUCTOR',
    ModalidadLogistica.transportista: 'TRANSPORTISTA',
    ModalidadLogistica.todas: 'TODAS',
  };

  String toJson() => _valoresDb[this]!;

  static ModalidadLogistica fromJson(String valor) {
    final valorNormalizado = valor.toUpperCase();
    return _valoresDb.entries
        .firstWhere(
          (entrada) => entrada.value == valorNormalizado,
          orElse: () => const MapEntry(ModalidadLogistica.todas, 'TODAS'),
        )
        .key;
  }
}

extension ModalidadLogisticaEtiqueta on ModalidadLogistica {
  String get etiqueta {
    switch (this) {
      case ModalidadLogistica.retiro:
        return 'Retiro en finca';
      case ModalidadLogistica.envioProductor:
        return 'Envío del productor';
      case ModalidadLogistica.transportista:
        return 'Transportista';
      case ModalidadLogistica.todas:
        return 'Todas las modalidades';
    }
  }
}

enum EstadoOferta {
  disponible,
  agotado,
  pausada;

  static const Map<EstadoOferta, String> _valoresDb = {
    EstadoOferta.disponible: 'DISPONIBLE',
    EstadoOferta.agotado: 'AGOTADO',
    EstadoOferta.pausada: 'PAUSADA',
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
      case EstadoOferta.agotado:
        return 'Agotado';
      case EstadoOferta.pausada:
        return 'Pausada';
    }
  }
}

class OfertaAgricola {
  final String id;
  final String productorId;
  final String productoId;
  final double precioUnitario;
  final UnidadMedida unidadMedida;
  final int cantidadTotal;
  final int cantidadDisponible;
  final ModalidadLogistica modalidadLogistica;
  final DateTime? fechaCosecha;
  final EstadoOferta estado;
  final DateTime creadoEn;

  OfertaAgricola({
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

  factory OfertaAgricola.fromJson(Map<String, dynamic> json) {
    return OfertaAgricola(
      id: json['id'] as String,
      productorId: json['productorId'] as String,
      productoId: json['productoId'] as String,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      unidadMedida: UnidadMedida.fromJson(json['unidadMedida'] as String),
      cantidadTotal: json['cantidadTotal'] as int,
      cantidadDisponible: json['cantidadDisponible'] as int,
      modalidadLogistica: ModalidadLogistica.fromJson(json['modalidadLogistica'] as String),
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

  OfertaAgricola copyWith({
    String? id,
    String? productorId,
    String? productoId,
    double? precioUnitario,
    UnidadMedida? unidadMedida,
    int? cantidadTotal,
    int? cantidadDisponible,
    ModalidadLogistica? modalidadLogistica,
    DateTime? fechaCosecha,
    EstadoOferta? estado,
    DateTime? creadoEn,
  }) {
    return OfertaAgricola(
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
    return other is OfertaAgricola &&
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
      'OfertaAgricola(id: $id, productoId: $productoId, productorId: $productorId, '
      'precioUnitario: $precioUnitario, cantidadDisponible: $cantidadDisponible, estado: $estado)';
}

extension OfertaAgricolaEstadoVisual on OfertaAgricola {
  /// Texto de estado mostrado en catálogo, panel del productor y ficha de
  /// trazabilidad: distingue "Parcialmente Vendida" de "Activa" según el
  /// inventario, algo que [EstadoOferta.etiqueta] por sí solo no refleja.
  String get estadoVisualTexto {
    if (estado == EstadoOferta.pausada) return 'Pausada';
    if (estado == EstadoOferta.agotado) return 'Agotada';
    if (cantidadDisponible < cantidadTotal) return 'Parcialmente Vendida';
    return 'Activa';
  }
}
