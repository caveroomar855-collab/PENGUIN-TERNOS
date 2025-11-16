import '../models/alquiler.dart';
import 'api_service.dart';

class AlquileresService {
  static Future<List<Alquiler>> getAll() async {
    try {
      final response = await ApiService.get('/alquileres');
      final List<dynamic> data = response.data;
      return data.map((json) => Alquiler.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener alquileres: $e');
    }
  }

  static Future<List<Alquiler>> getActivos() async {
    try {
      final response = await ApiService.get('/alquileres/activos');
      final List<dynamic> data = response.data;
      return data.map((json) => Alquiler.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener alquileres activos: $e');
    }
  }

  static Future<Alquiler> create(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('/alquileres', data: data);
      return Alquiler.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear alquiler: $e');
    }
  }

  static Future<void> prolongar(String id, int dias, double monto) async {
    try {
      await ApiService.put('/alquileres/$id/prolongar', data: {
        'dias_prolongacion': dias,
        'monto_prolongacion': monto,
      });
    } catch (e) {
      throw Exception('Error al prolongar alquiler: $e');
    }
  }

  static Future<void> devolver(String id, Map<String, dynamic> data) async {
    try {
      await ApiService.put('/alquileres/$id/devolver', data: data);
    } catch (e) {
      throw Exception('Error al devolver alquiler: $e');
    }
  }

  static Future<void> marcarPerdido(String id, String? observaciones) async {
    try {
      await ApiService.put('/alquileres/$id/marcar-perdido', data: {
        'observaciones': observaciones,
      });
    } catch (e) {
      throw Exception('Error al marcar como perdido: $e');
    }
  }
}
