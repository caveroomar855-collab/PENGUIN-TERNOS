import '../models/articulo.dart';
import 'api_service.dart';

class ArticulosService {
  static Future<List<Articulo>> getAll() async {
    try {
      final response = await ApiService.get('/articulos');
      final List<dynamic> data = response.data;
      return data.map((json) => Articulo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener artículos: $e');
    }
  }

  static Future<List<Articulo>> getDisponibles() async {
    try {
      final response = await ApiService.get('/articulos/disponibles');
      final List<dynamic> data = response.data;
      return data.map((json) => Articulo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener artículos disponibles: $e');
    }
  }

  static Future<Articulo> create(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('/articulos', data: data);
      return Articulo.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear artículo: $e');
    }
  }

  static Future<Articulo> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await ApiService.put('/articulos/$id', data: data);
      return Articulo.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al actualizar artículo: $e');
    }
  }

  static Future<void> updateEstado(String id, String estado) async {
    try {
      await ApiService.put('/articulos/$id/estado', data: {'estado': estado});
    } catch (e) {
      throw Exception('Error al actualizar estado: $e');
    }
  }
}
