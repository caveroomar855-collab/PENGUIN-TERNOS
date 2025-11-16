import 'cliente.dart';
import 'articulo.dart';

enum AlquilerEstado {
  activo,
  enMora,
  devuelto,
  perdido;

  String get displayName {
    switch (this) {
      case AlquilerEstado.activo:
        return 'Activo';
      case AlquilerEstado.enMora:
        return 'En Mora';
      case AlquilerEstado.devuelto:
        return 'Devuelto';
      case AlquilerEstado.perdido:
        return 'Perdido';
    }
  }

  static AlquilerEstado fromString(String estado) {
    return AlquilerEstado.values.firstWhere(
      (e) => e.name.toLowerCase() == estado.toLowerCase().replaceAll('_', ''),
      orElse: () => AlquilerEstado.activo,
    );
  }
}

enum EstadoDevolucion {
  completo,
  incompleto,
  danado,
  perdido;

  String get displayName {
    switch (this) {
      case EstadoDevolucion.completo:
        return 'Completo';
      case EstadoDevolucion.incompleto:
        return 'Incompleto';
      case EstadoDevolucion.danado:
        return 'Dañado';
      case EstadoDevolucion.perdido:
        return 'Perdido';
    }
  }

  static EstadoDevolucion fromString(String estado) {
    return EstadoDevolucion.values.firstWhere(
      (e) => e.name == estado.toLowerCase(),
      orElse: () => EstadoDevolucion.completo,
    );
  }
}

enum MedioPago {
  efectivo,
  yapePlin,
  tarjeta;

  String get displayName {
    switch (this) {
      case MedioPago.efectivo:
        return 'Efectivo';
      case MedioPago.yapePlin:
        return 'Yape/Plin';
      case MedioPago.tarjeta:
        return 'Tarjeta';
    }
  }

  static MedioPago fromString(String medio) {
    return MedioPago.values.firstWhere(
      (e) => e.name.toLowerCase() == medio.toLowerCase().replaceAll('-', ''),
      orElse: () => MedioPago.efectivo,
    );
  }
}

class AlquilerItem {
  final String id;
  final String alquilerId;
  final String articuloId;
  final Articulo? articulo;

  AlquilerItem({
    required this.id,
    required this.alquilerId,
    required this.articuloId,
    this.articulo,
  });

  factory AlquilerItem.fromJson(Map<String, dynamic> json) {
    return AlquilerItem(
      id: json['id'],
      alquilerId: json['alquiler_id'],
      articuloId: json['articulo_id'],
      articulo:
          json['articulo'] != null ? Articulo.fromJson(json['articulo']) : null,
    );
  }
}

class Alquiler {
  final String id;
  final String clienteId;
  final Cliente? cliente;
  final DateTime fechaAlquiler;
  final DateTime fechaDevolucion;
  final DateTime? fechaDevolucionReal;
  final AlquilerEstado estado;
  final EstadoDevolucion? estadoDevolucion;
  final MedioPago medioPago;
  final double montoAlquiler;
  final double garantia;
  final bool garantiaRetenida;
  final double montoMora;
  final String? observaciones;
  final bool esRobo;
  final List<AlquilerItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Alquiler({
    required this.id,
    required this.clienteId,
    this.cliente,
    required this.fechaAlquiler,
    required this.fechaDevolucion,
    this.fechaDevolucionReal,
    required this.estado,
    this.estadoDevolucion,
    required this.medioPago,
    required this.montoAlquiler,
    required this.garantia,
    this.garantiaRetenida = false,
    this.montoMora = 0,
    this.observaciones,
    this.esRobo = false,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Alquiler.fromJson(Map<String, dynamic> json) {
    return Alquiler(
      id: json['id'],
      clienteId: json['cliente_id'],
      cliente:
          json['cliente'] != null ? Cliente.fromJson(json['cliente']) : null,
      fechaAlquiler: DateTime.parse(json['fecha_alquiler']),
      fechaDevolucion: DateTime.parse(json['fecha_devolucion']),
      fechaDevolucionReal: json['fecha_devolucion_real'] != null
          ? DateTime.parse(json['fecha_devolucion_real'])
          : null,
      estado: AlquilerEstado.fromString(json['estado']),
      estadoDevolucion: json['estado_devolucion'] != null
          ? EstadoDevolucion.fromString(json['estado_devolucion'])
          : null,
      medioPago: MedioPago.fromString(json['medio_pago']),
      montoAlquiler: (json['monto_alquiler'] as num).toDouble(),
      garantia: (json['garantia'] as num).toDouble(),
      garantiaRetenida: json['garantia_retenida'] ?? false,
      montoMora: (json['monto_mora'] as num?)?.toDouble() ?? 0,
      observaciones: json['observaciones'],
      esRobo: json['es_robo'] ?? false,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => AlquilerItem.fromJson(i))
              .toList()
          : [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  int get diasMora {
    if (estado != AlquilerEstado.activo && estado != AlquilerEstado.enMora) {
      return 0;
    }
    final hoy = DateTime.now();
    if (hoy.isAfter(fechaDevolucion)) {
      return hoy.difference(fechaDevolucion).inDays;
    }
    return 0;
  }

  bool get estaEnMora => diasMora > 0;
}
