class Producto {
  final String id;
  final String nombre;
  final String categoria;

  const Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      categoria: json['categoria'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
    };
  }

  Producto copyWith({
    String? id,
    String? nombre,
    String? categoria,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Producto &&
        other.id == id &&
        other.nombre == nombre &&
        other.categoria == categoria;
  }

  @override
  int get hashCode => Object.hash(id, nombre, categoria);

  @override
  String toString() => 'Producto(id: $id, nombre: $nombre, categoria: $categoria)';
}
