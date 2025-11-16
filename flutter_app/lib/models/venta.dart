import 'cliente.dart';
import 'articulo.dart';
import 'alquiler.dart';

class VentaItem {
  final String id;
  final String ventaId;
  final String articuloId;
  final Articulo? articulo;

  VentaItem({
    required this.id,
    required this.ventaId,
    required this.articuloId,
    this.articulo,
  });

  factory VentaItem.fromJson(Map<String, dynamic> json) {
    return VentaItem(
      id: json['id'],
      ventaId: json['venta_id'],
      articuloId: json['articulo_id'],
      articulo: json['articulo'] != null
          ? Articulo.fromJson(json['articulo'])
          : null,
    );
  }
}

class Venta {
  final String id;
  final String clienteId;
  final Cliente? cliente;
  final DateTime fechaVenta;
  final MedioPago medioPago;
  final double montoTotal;
  final List<VentaItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Venta({
    required this.id,
    required this.clienteId,
    this.cliente,
    required this.fechaVenta,
    required this.medioPago,
    required this.montoTotal,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'],
      clienteId: json['cliente_id'],
      cliente: json['cliente'] != null
          ? Cliente.fromJson(json['cliente'])
          : null,
      fechaVenta: DateTime.parse(json['fecha_venta']),
      medioPago: MedioPago.fromString(json['medio_pago']),
      montoTotal: (json['monto_total'] as num).toDouble(),
      items: json['items'] != null
          ? (json['items'] as List).map((i) => VentaItem.fromJson(i)).toList()
          : [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
