class Cliente {
  final String id;
  final String dni;
  final String nombreCompleto;
  final String telefono;
  final String? correo;
  final bool eliminado;
  final DateTime? fechaEliminacion;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cliente({
    required this.id,
    required this.dni,
    required this.nombreCompleto,
    required this.telefono,
    this.correo,
    this.eliminado = false,
    this.fechaEliminacion,
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
      eliminado: json['eliminado'] ?? false,
      fechaEliminacion: json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'])
          : null,
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
      'eliminado': eliminado,
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
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
    bool? eliminado,
    DateTime? fechaEliminacion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cliente(
      id: id ?? this.id,
      dni: dni ?? this.dni,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      eliminado: eliminado ?? this.eliminado,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
