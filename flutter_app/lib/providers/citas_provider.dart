import 'package:flutter/material.dart';
import '../models/cita.dart';
import '../services/citas_service.dart';

class CitasProvider extends ChangeNotifier {
  List<Cita> _citas = [];
  bool _isLoading = false;
  String? _error;

  List<Cita> get citas => _citas;
  List<Cita> get citasPendientes =>
      _citas.where((c) => c.estado == EstadoCita.pendiente).toList();
  List<Cita> get citasFinalizadas =>
      _citas.where((c) => c.estado == EstadoCita.finalizada).toList();
  List<Cita> get pendientes =>
      _citas.where((c) => c.estado == EstadoCita.pendiente).toList();
  List<Cita> get finalizadas =>
      _citas.where((c) => c.estado == EstadoCita.finalizada).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCitas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _citas = await CitasService.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCitas() async {
    await fetchCitas();
  }

  Future<Cita> createCita(Map<String, dynamic> data) async {
    try {
      final cita = await CitasService.create(data);
      _citas.insert(0, cita);
      notifyListeners();
      return cita;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> finalizarCita(String id) async {
    try {
      await CitasService.marcarFinalizada(id);
      await fetchCitas();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
