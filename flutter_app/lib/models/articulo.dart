enum ArticuloTipo {
  saco,
  pantalon,
  camisa,
  zapatos,
  corbata,
  chaleco,
  otro;

  String get displayName {
    switch (this) {
      case ArticuloTipo.saco:
        return 'Saco';
      case ArticuloTipo.pantalon:
        return 'Pantalón';
      case ArticuloTipo.camisa:
        return 'Camisa';
      case ArticuloTipo.zapatos:
        return 'Zapatos';
      case ArticuloTipo.corbata:
        return 'Corbata';
      case ArticuloTipo.chaleco:
        return 'Chaleco';
      case ArticuloTipo.otro:
        return 'Otro';
    }
  }

  static ArticuloTipo fromString(String tipo) {
    return ArticuloTipo.values.firstWhere(
      (e) => e.name == tipo.toLowerCase(),
      orElse: () => ArticuloTipo.otro,
    );
  }
}

enum ArticuloEstado {
  disponible,
  alquilado,
  mantenimiento,
  perdido;

  String get displayName {
    switch (this) {
      case ArticuloEstado.disponible:
        return 'Disponible';
      case ArticuloEstado.alquilado:
        return 'Alquilado';
      case ArticuloEstado.mantenimiento:
        return 'Mantenimiento';
      case ArticuloEstado.perdido:
        return 'Perdido';
    }
  }

  static ArticuloEstado fromString(String estado) {
    return ArticuloEstado.values.firstWhere(
      (e) => e.name == estado.toLowerCase(),
      orElse: () => ArticuloEstado.disponible,
    );
  }
}

enum EstadoDevolucion {
  completo,
  danado,
  perdido;

  String get displayName {
    switch (this) {
      case EstadoDevolucion.completo:
        return 'Completo';
      case EstadoDevolucion.danado:
        return 'Dañado';
      case EstadoDevolucion.perdido:
        return 'Perdido';
    }
  }

  String get descripcion {
    switch (this) {
      case EstadoDevolucion.completo:
        return 'Buen estado - 24h mantenimiento';
      case EstadoDevolucion.danado:
        return 'Requiere reparación - 72h mantenimiento';
      case EstadoDevolucion.perdido:
        return 'No devuelto';
    }
  }

  static EstadoDevolucion fromString(String estado) {
    return EstadoDevolucion.values.firstWhere(
      (e) => e.name == estado.toLowerCase(),
      orElse: () => EstadoDevolucion.completo,
    );
  }
}

class Articulo {
  final String id;
  final String nombre;
  final ArticuloTipo tipo;
  final String talla;
  final String? descripcion;
  final double precioAlquiler;
  final double precioVenta;
  final int cantidad;
  final int cantidadDisponible;
  final int cantidadAlquilada;
  final int cantidadMantenimiento;
  final ArticuloEstado estado;
  final String? trajeId;
  final DateTime? fechaFinMantenimiento;
  final DateTime createdAt;
  final DateTime updatedAt;

  Articulo({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.talla,
    this.descripcion,
    required this.precioAlquiler,
    required this.precioVenta,
    required this.cantidad,
    required this.cantidadDisponible,
    required this.cantidadAlquilada,
    required this.cantidadMantenimiento,
    required this.estado,
    this.trajeId,
    this.fechaFinMantenimiento,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Articulo.fromJson(Map<String, dynamic> json) {
    return Articulo(
      id: json['id'],
      nombre: json['nombre'],
      tipo: ArticuloTipo.fromString(json['tipo']),
      talla: json['talla'],
      descripcion: json['descripcion'],
      precioAlquiler: (json['precio_alquiler'] as num).toDouble(),
      precioVenta: (json['precio_venta'] as num).toDouble(),
      cantidad: json['cantidad'],
      cantidadDisponible: json['cantidad_disponible'],
      cantidadAlquilada: json['cantidad_alquilada'],
      cantidadMantenimiento: json['cantidad_mantenimiento'],
      estado: ArticuloEstado.fromString(json['estado']),
      trajeId: json['traje_id'],
      fechaFinMantenimiento: json['fecha_fin_mantenimiento'] != null
          ? DateTime.parse(json['fecha_fin_mantenimiento'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo.name,
      'talla': talla,
      'descripcion': descripcion,
      'precio_alquiler': precioAlquiler,
      'precio_venta': precioVenta,
      'cantidad': cantidad,
      'cantidad_disponible': cantidadDisponible,
      'cantidad_alquilada': cantidadAlquilada,
      'cantidad_mantenimiento': cantidadMantenimiento,
      'estado': estado.name,
      'traje_id': trajeId,
      'fecha_fin_mantenimiento': fechaFinMantenimiento?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
