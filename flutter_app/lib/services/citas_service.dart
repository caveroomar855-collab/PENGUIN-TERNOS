import '../models/cita.dart';
import 'api_service.dart';

class CitasService {
  static Future<List<Cita>> getAll() async {
    try {
      final response = await ApiService.get('/citas');
      final List<dynamic> data = response.data;
      return data.map((json) => Cita.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener citas: $e');
    }
  }

  static Future<List<Cita>> getPendientes() async {
    try {
      final response = await ApiService.get('/citas/pendientes');
      final List<dynamic> data = response.data;
      return data.map((json) => Cita.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener citas pendientes: $e');
    }
  }

  static Future<Cita> create(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('/citas', data: data);
      return Cita.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear cita: $e');
    }
  }

  static Future<void> marcarFinalizada(String id) async {
    try {
      await ApiService.put('/citas/$id/finalizar');
    } catch (e) {
      throw Exception('Error al finalizar cita: $e');
    }
  }

  static Future<void> delete(String id) async {
    try {
      await ApiService.delete('/citas/$id');
    } catch (e) {
      throw Exception('Error al eliminar cita: $e');
    }
  }
}
