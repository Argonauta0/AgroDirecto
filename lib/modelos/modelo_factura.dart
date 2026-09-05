enum MetodoPago {
  efectivo,
  transferencia,
  pasarela;

  static const Map<MetodoPago, String> _valoresDb = {
    MetodoPago.efectivo: 'EFECTIVO',
    MetodoPago.transferencia: 'TRANSFERENCIA',
    MetodoPago.pasarela: 'PASARELA',
  };

  String toJson() => _valoresDb[this]!;

  static MetodoPago fromJson(String valor) {
    final valorNormalizado = valor.toUpperCase();
    return _valoresDb.entries
        .firstWhere(
          (entrada) => entrada.value == valorNormalizado,
          orElse: () => const MapEntry(MetodoPago.efectivo, 'EFECTIVO'),
        )
        .key;
  }
}

extension MetodoPagoEtiqueta on MetodoPago {
  String get etiqueta {
    switch (this) {
      case MetodoPago.efectivo:
        return 'Efectivo';
      case MetodoPago.transferencia:
        return 'Transferencia bancaria';
      case MetodoPago.pasarela:
        return 'Pasarela de pago';
    }
  }
}

enum EstadoPago {
  pendiente,
  completado,
  reembolsado;

  static const Map<EstadoPago, String> _valoresDb = {
    EstadoPago.pendiente: 'PENDIENTE',
    EstadoPago.completado: 'COMPLETADO',
    EstadoPago.reembolsado: 'REEMBOLSADO',
  };

  String toJson() => _valoresDb[this]!;

  static EstadoPago fromJson(String valor) {
    final valorNormalizado = valor.toUpperCase();
    return _valoresDb.entries
        .firstWhere(
          (entrada) => entrada.value == valorNormalizado,
          orElse: () => const MapEntry(EstadoPago.pendiente, 'PENDIENTE'),
        )
        .key;
  }
}

extension EstadoPagoEtiqueta on EstadoPago {
  String get etiqueta {
    switch (this) {
      case EstadoPago.pendiente:
        return 'Pendiente';
      case EstadoPago.completado:
        return 'Completado';
      case EstadoPago.reembolsado:
        return 'Reembolsado';
    }
  }
}

class Factura {
  final String id;
  final String solicitudCompraId;
  final String numeroFactura;
  final double subtotal;
  final double porcentajeComision;
  final double montoComision;
  final double montoProductor;
  final double totalPagado;
  final String? referenciaPasarela;
  final MetodoPago metodoPago;
  final EstadoPago estadoPago;
  final DateTime fechaEmision;

  Factura({
    required this.id,
    required this.solicitudCompraId,
    required this.numeroFactura,
    required this.subtotal,
    required this.porcentajeComision,
    required this.montoComision,
    required this.montoProductor,
    required this.totalPagado,
    required this.metodoPago,
    this.referenciaPasarela,
    this.estadoPago = EstadoPago.pendiente,
    DateTime? fechaEmision,
  }) : fechaEmision = fechaEmision ?? DateTime.now();

  factory Factura.fromJson(Map<String, dynamic> json) {
    return Factura(
      id: json['id'] as String,
      solicitudCompraId: json['solicitudCompraId'] as String,
      numeroFactura: json['numeroFactura'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      porcentajeComision: (json['porcentajeComision'] as num).toDouble(),
      montoComision: (json['montoComision'] as num).toDouble(),
      montoProductor: (json['montoProductor'] as num).toDouble(),
      totalPagado: (json['totalPagado'] as num).toDouble(),
      referenciaPasarela: json['referenciaPasarela'] as String?,
      metodoPago: MetodoPago.fromJson(json['metodoPago'] as String),
      estadoPago: EstadoPago.fromJson(json['estadoPago'] as String? ?? 'PENDIENTE'),
      fechaEmision:
          json['fechaEmision'] != null ? DateTime.parse(json['fechaEmision'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'solicitudCompraId': solicitudCompraId,
      'numeroFactura': numeroFactura,
      'subtotal': subtotal,
      'porcentajeComision': porcentajeComision,
      'montoComision': montoComision,
      'montoProductor': montoProductor,
      'totalPagado': totalPagado,
      'referenciaPasarela': referenciaPasarela,
      'metodoPago': metodoPago.toJson(),
      'estadoPago': estadoPago.toJson(),
      'fechaEmision': fechaEmision.toIso8601String(),
    };
  }

  Factura copyWith({
    String? id,
    String? solicitudCompraId,
    String? numeroFactura,
    double? subtotal,
    double? porcentajeComision,
    double? montoComision,
    double? montoProductor,
    double? totalPagado,
    String? referenciaPasarela,
    MetodoPago? metodoPago,
    EstadoPago? estadoPago,
    DateTime? fechaEmision,
  }) {
    return Factura(
      id: id ?? this.id,
      solicitudCompraId: solicitudCompraId ?? this.solicitudCompraId,
      numeroFactura: numeroFactura ?? this.numeroFactura,
      subtotal: subtotal ?? this.subtotal,
      porcentajeComision: porcentajeComision ?? this.porcentajeComision,
      montoComision: montoComision ?? this.montoComision,
      montoProductor: montoProductor ?? this.montoProductor,
      totalPagado: totalPagado ?? this.totalPagado,
      referenciaPasarela: referenciaPasarela ?? this.referenciaPasarela,
      metodoPago: metodoPago ?? this.metodoPago,
      estadoPago: estadoPago ?? this.estadoPago,
      fechaEmision: fechaEmision ?? this.fechaEmision,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Factura &&
        other.id == id &&
        other.solicitudCompraId == solicitudCompraId &&
        other.numeroFactura == numeroFactura &&
        other.subtotal == subtotal &&
        other.porcentajeComision == porcentajeComision &&
        other.montoComision == montoComision &&
        other.montoProductor == montoProductor &&
        other.totalPagado == totalPagado &&
        other.referenciaPasarela == referenciaPasarela &&
        other.metodoPago == metodoPago &&
        other.estadoPago == estadoPago &&
        other.fechaEmision == fechaEmision;
  }

  @override
  int get hashCode => Object.hash(
        id,
        solicitudCompraId,
        numeroFactura,
        subtotal,
        porcentajeComision,
        montoComision,
        montoProductor,
        totalPagado,
        referenciaPasarela,
        metodoPago,
        estadoPago,
        fechaEmision,
      );

  @override
  String toString() =>
      'Factura(id: $id, numeroFactura: $numeroFactura, solicitudCompraId: $solicitudCompraId, '
      'totalPagado: $totalPagado, estadoPago: $estadoPago)';
}
