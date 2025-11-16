import '../models/venta.dart';
import 'api_service.dart';

class VentasService {
  static Future<List<Venta>> getAll() async {
    try {
      final response = await ApiService.get('/ventas');
      final List<dynamic> data = response.data;
      return data.map((json) => Venta.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener ventas: $e');
    }
  }

  static Future<Venta> create(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('/ventas', data: data);
      return Venta.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear venta: $e');
    }
  }

  static Future<Venta> getById(String id) async {
    try {
      final response = await ApiService.get('/ventas/$id');
      return Venta.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener venta: $e');
    }
  }
}
