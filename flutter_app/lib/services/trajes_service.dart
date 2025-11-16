import '../models/traje.dart';
import 'api_service.dart';

class TrajesService {
  static Future<List<Traje>> getAll() async {
    try {
      final response = await ApiService.get('/trajes');
      final List<dynamic> data = response.data;
      return data.map((json) => Traje.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener trajes: $e');
    }
  }

  static Future<List<Traje>> getDisponibles() async {
    try {
      final response = await ApiService.get('/trajes/disponibles');
      final List<dynamic> data = response.data;
      return data.map((json) => Traje.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener trajes disponibles: $e');
    }
  }

  static Future<Traje> create(Map<String, dynamic> data) async {
    try {
      print('🚀 TrajesService.create - Enviando datos:');
      print('   URL: ${ApiService.dio.options.baseUrl}/trajes');
      print('   Datos: $data');

      final response = await ApiService.post('/trajes', data: data);

      print('✅ TrajesService.create - Respuesta recibida:');
      print('   Status: ${response.statusCode}');
      print('   Data: ${response.data}');

      return Traje.fromJson(response.data);
    } catch (e) {
      print('❌ TrajesService.create - Error:');
      print('   Error: $e');
      throw Exception('Error al crear traje: $e');
    }
  }

  static Future<Traje> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await ApiService.put('/trajes/$id', data: data);
      return Traje.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al actualizar traje: $e');
    }
  }
}
