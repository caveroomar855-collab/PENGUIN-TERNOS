import 'articulo.dart';

class Traje {
  final String id;
  final String nombre;
  final String? descripcion;
  final double precioAlquiler;
  final double precioVenta;
  final bool disponible;
  final ArticuloEstado estado;
  final DateTime? fechaFinMantenimiento;
  final List<Articulo> articulos;
  final DateTime createdAt;
  final DateTime updatedAt;

  Traje({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precioAlquiler,
    required this.precioVenta,
    required this.disponible,
    required this.estado,
    this.fechaFinMantenimiento,
    this.articulos = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Traje.fromJson(Map<String, dynamic> json) {
    return Traje(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precioAlquiler: (json['precio_alquiler'] as num).toDouble(),
      precioVenta: (json['precio_venta'] as num).toDouble(),
      disponible: json['disponible'] ?? true,
      estado: json['estado'] != null
          ? ArticuloEstado.fromString(json['estado'])
          : ArticuloEstado.disponible,
      fechaFinMantenimiento: json['fecha_fin_mantenimiento'] != null
          ? DateTime.parse(json['fecha_fin_mantenimiento'])
          : null,
      articulos: json['articulos'] != null
          ? (json['articulos'] as List)
              .map((a) => Articulo.fromJson(a))
              .toList()
          : [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio_alquiler': precioAlquiler,
      'precio_venta': precioVenta,
      'disponible': disponible,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get tieneTodasLasPiezas {
    if (articulos.length != 4) return false;
    final tipos = articulos.map((a) => a.tipo).toSet();
    return tipos.contains(ArticuloTipo.saco) &&
        tipos.contains(ArticuloTipo.pantalon) &&
        tipos.contains(ArticuloTipo.camisa) &&
        tipos.contains(ArticuloTipo.zapatos);
  }

  int get cantidadDisponible {
    if (articulos.isEmpty) return 0;
    return articulos
        .map((a) => a.cantidadDisponible)
        .reduce((a, b) => a < b ? a : b);
  }
}
