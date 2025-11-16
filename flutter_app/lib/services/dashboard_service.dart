import 'api_service.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getResumenDia() async {
    try {
      final response = await ApiService.get('/dashboard/resumen-dia');
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener resumen del día: $e');
    }
  }

  static Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final response = await ApiService.get('/dashboard/estadisticas');
      return response.data;
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }
}
