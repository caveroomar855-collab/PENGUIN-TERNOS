class Cliente {
  final String id;
  final String dni;
  final String nombreCompleto;
  final String telefono;
  final String? correo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cliente({
    required this.id,
    required this.dni,
    required this.nombreCompleto,
    required this.telefono,
    this.correo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      dni: json['dni'],
      nombreCompleto: json['nombre_completo'],
      telefono: json['telefono'],
      correo: json['correo'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dni': dni,
      'nombre_completo': nombreCompleto,
      'telefono': telefono,
      'correo': correo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Cliente copyWith({
    String? id,
    String? dni,
    String? nombreCompleto,
    String? telefono,
    String? correo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cliente(
      id: id ?? this.id,
      dni: dni ?? this.dni,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
