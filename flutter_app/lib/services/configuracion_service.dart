import '../models/configuracion.dart';
import 'api_service.dart';

class ConfiguracionService {
  static Future<Configuracion> get() async {
    try {
      final response = await ApiService.get('/configuracion');
      return Configuracion.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener configuración: $e');
    }
  }

  static Future<Configuracion> update(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.put('/configuracion', data: data);
      return Configuracion.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al actualizar configuración: $e');
    }
  }
}
