import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/clientes_service.dart';

class ClientesProvider extends ChangeNotifier {
  List<Cliente> _clientes = [];
  bool _isLoading = false;
  String? _error;

  List<Cliente> get clientes => _clientes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchClientes() async {
    await loadClientes();
  }

  Future<void> loadClientes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _clientes = await ClientesService.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Cliente?> buscarPorDni(String dni) async {
    try {
      return await ClientesService.getByDni(dni);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createCliente(Map<String, dynamic> data) async {
    try {
      final nuevo = await ClientesService.create(data);
      _clientes.insert(0, nuevo);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCliente(String id, Map<String, dynamic> data) async {
    try {
      final updated = await ClientesService.update(id, data);
      final index = _clientes.indexWhere((c) => c.id == id);
      if (index != -1) {
        _clientes[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<Cliente>> searchClientes(String query) async {
    try {
      return await ClientesService.search(query);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }
}
