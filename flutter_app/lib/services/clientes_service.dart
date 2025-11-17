import '../models/cliente.dart';
import 'api_service.dart';

class ClientesService {
  static Future<List<Cliente>> getAll() async {
    try {
      final response = await ApiService.get('/clientes');
      final List<dynamic> data = response.data;
      return data.map((json) => Cliente.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener clientes: $e');
    }
  }

  static Future<List<Cliente>> search(String query) async {
    try {
      final response = await ApiService.get('/clientes/search',
          queryParameters: {'q': query});
      final List<dynamic> data = response.data;
      return data.map((json) => Cliente.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al buscar clientes: $e');
    }
  }

  static Future<Cliente?> getByDni(String dni) async {
    try {
      final response = await ApiService.get('/clientes/$dni');
      return Cliente.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  static Future<Cliente> create(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('/clientes', data: data);
      return Cliente.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear cliente: $e');
    }
  }

  static Future<Cliente> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await ApiService.put('/clientes/$id', data: data);
      return Cliente.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al actualizar cliente: $e');
    }
  }

  static Future<void> delete(String id) async {
    try {
      await ApiService.delete('/clientes/$id');
    } catch (e) {
      throw Exception('Error al eliminar cliente: $e');
    }
  }

  static Future<List<Cliente>> getPapelera() async {
    try {
      final response = await ApiService.get('/clientes/papelera');
      final List<dynamic> data = response.data;
      return data.map((json) => Cliente.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener papelera: $e');
    }
  }

  static Future<Cliente> restore(String id) async {
    try {
      final response = await ApiService.put('/clientes/$id/restore', data: {});
      return Cliente.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al restaurar cliente: $e');
    }
  }

  static Future<void> deletePermanently(String id) async {
    try {
      await ApiService.delete('/clientes/$id/permanently');
    } catch (e) {
      throw Exception('Error al eliminar permanentemente: $e');
    }
  }
}
