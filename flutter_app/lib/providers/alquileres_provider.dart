import 'package:flutter/material.dart';
import '../models/alquiler.dart';
import '../services/alquileres_service.dart';

class AlquileresProvider extends ChangeNotifier {
  List<Alquiler> _alquileres = [];
  bool _isLoading = false;
  String? _error;

  List<Alquiler> get alquileres => _alquileres;
  List<Alquiler> get activos => _alquileres
      .where((a) =>
          a.estado == AlquilerEstado.activo ||
          a.estado == AlquilerEstado.enMora)
      .toList();
  List<Alquiler> get historial => _alquileres
      .where((a) =>
          a.estado == AlquilerEstado.devuelto ||
          a.estado == AlquilerEstado.perdido)
      .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get activosCount => activos.length;
  int get devolucionesPendientes =>
      activos.where((a) => a.fechaDevolucion.isBefore(DateTime.now())).length;

  Future<void> loadAlquileres() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _alquileres = await AlquileresService.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadActivos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _alquileres = await AlquileresService.getActivos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAlquiler(Map<String, dynamic> data) async {
    try {
      final alquiler = await AlquileresService.create(data);
      _alquileres.insert(0, alquiler);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> prolongarAlquiler(String id, int dias, double monto) async {
    try {
      await AlquileresService.prolongar(id, dias, monto);
      await loadAlquileres();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> devolverAlquiler(String id, Map<String, dynamic> data) async {
    try {
      await AlquileresService.devolver(id, data);
      await loadAlquileres();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> marcarComoPerdido(String id, String? observaciones) async {
    try {
      await AlquileresService.marcarPerdido(id, observaciones);
      await loadAlquileres();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
