import 'cliente.dart';

enum TipoCita {
  alquiler,
  devolucion,
  prueba;

  String get displayName {
    switch (this) {
      case TipoCita.alquiler:
        return 'Alquiler';
      case TipoCita.devolucion:
        return 'Devolución';
      case TipoCita.prueba:
        return 'Prueba';
    }
  }

  static TipoCita fromString(String tipo) {
    return TipoCita.values.firstWhere(
      (e) => e.name == tipo.toLowerCase(),
      orElse: () => TipoCita.alquiler,
    );
  }
}

enum EstadoCita {
  pendiente,
  finalizada;

  String get displayName {
    switch (this) {
      case EstadoCita.pendiente:
        return 'Pendiente';
      case EstadoCita.finalizada:
        return 'Finalizada';
    }
  }

  static EstadoCita fromString(String estado) {
    return EstadoCita.values.firstWhere(
      (e) => e.name == estado.toLowerCase(),
      orElse: () => EstadoCita.pendiente,
    );
  }
}

class Cita {
  final String id;
  final String clienteId;
  final Cliente? cliente;
  final DateTime fechaHora;
  final TipoCita tipoCita;
  final String? descripcion;
  final EstadoCita estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cita({
    required this.id,
    required this.clienteId,
    this.cliente,
    required this.fechaHora,
    required this.tipoCita,
    this.descripcion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'],
      clienteId: json['cliente_id'],
      cliente: json['cliente'] != null
          ? Cliente.fromJson(json['cliente'])
          : null,
      fechaHora: DateTime.parse(json['fecha_hora']),
      tipoCita: TipoCita.fromString(json['tipo_cita']),
      descripcion: json['descripcion'],
      estado: EstadoCita.fromString(json['estado']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'fecha_hora': fechaHora.toIso8601String(),
      'tipo_cita': tipoCita.name,
      'descripcion': descripcion,
      'estado': estado.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
