enum RolSeguridad {
  admin,
  auditor,
  usuario;

  String toJson() => name.toUpperCase();

  static RolSeguridad fromJson(String valor) {
    return RolSeguridad.values.firstWhere(
      (rol) => rol.name.toUpperCase() == valor.toUpperCase(),
      orElse: () => RolSeguridad.usuario,
    );
  }
}

enum TipoPerfil {
  productor,
  comprador;

  String toJson() => name.toUpperCase();

  static TipoPerfil fromJson(String valor) {
    return TipoPerfil.values.firstWhere(
      (tipo) => tipo.name.toUpperCase() == valor.toUpperCase(),
      orElse: () => TipoPerfil.productor,
    );
  }
}

class Usuario {
  final String id;
  final String nombreCompleto;
  final String telefono;
  final String passwordHash;
  final RolSeguridad rolSeguridad;
  final TipoPerfil tipoPerfil;
  final String departamento;
  final String municipio;
  final String direccionExacta;
  final DateTime creadoEn;

  Usuario({
    required this.id,
    required this.nombreCompleto,
    required this.telefono,
    required this.tipoPerfil,
    required this.departamento,
    required this.municipio,
    this.passwordHash = '',
    this.rolSeguridad = RolSeguridad.usuario,
    this.direccionExacta = '',
    DateTime? creadoEn,
  }) : creadoEn = creadoEn ?? DateTime.now();

  bool get esProductor => tipoPerfil == TipoPerfil.productor;
  bool get esComprador => tipoPerfil == TipoPerfil.comprador;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nombreCompleto: json['nombreCompleto'] as String,
      telefono: json['telefono'] as String,
      passwordHash: json['passwordHash'] as String? ?? '',
      rolSeguridad: RolSeguridad.fromJson(json['rolSeguridad'] as String? ?? 'USUARIO'),
      tipoPerfil: TipoPerfil.fromJson(json['tipoPerfil'] as String),
      departamento: json['departamento'] as String,
      municipio: json['municipio'] as String,
      direccionExacta: json['direccionExacta'] as String? ?? '',
      creadoEn: json['creadoEn'] != null
          ? DateTime.parse(json['creadoEn'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreCompleto': nombreCompleto,
      'telefono': telefono,
      'passwordHash': passwordHash,
      'rolSeguridad': rolSeguridad.toJson(),
      'tipoPerfil': tipoPerfil.toJson(),
      'departamento': departamento,
      'municipio': municipio,
      'direccionExacta': direccionExacta,
      'creadoEn': creadoEn.toIso8601String(),
    };
  }

  Usuario copyWith({
    String? id,
    String? nombreCompleto,
    String? telefono,
    String? passwordHash,
    RolSeguridad? rolSeguridad,
    TipoPerfil? tipoPerfil,
    String? departamento,
    String? municipio,
    String? direccionExacta,
    DateTime? creadoEn,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      telefono: telefono ?? this.telefono,
      passwordHash: passwordHash ?? this.passwordHash,
      rolSeguridad: rolSeguridad ?? this.rolSeguridad,
      tipoPerfil: tipoPerfil ?? this.tipoPerfil,
      departamento: departamento ?? this.departamento,
      municipio: municipio ?? this.municipio,
      direccionExacta: direccionExacta ?? this.direccionExacta,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
