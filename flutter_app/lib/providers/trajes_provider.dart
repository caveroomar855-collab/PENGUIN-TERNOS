import 'package:flutter/material.dart';
import '../models/traje.dart';
import '../services/trajes_service.dart';

class TrajesProvider extends ChangeNotifier {
  List<Traje> _trajes = [];
  bool _isLoading = false;
  String? _error;

  List<Traje> get trajes => _trajes;
  List<Traje> get disponibles =>
      _trajes.where((t) => t.disponible && t.cantidadDisponible > 0).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTrajes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trajes = await TrajesService.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTrajes() async {
    await fetchTrajes();
  }

  Future<Traje> addTraje(Map<String, dynamic> data) async {
    try {
      final traje = await TrajesService.create(data);
      _trajes.insert(0, traje);
      notifyListeners();
      return traje;
    } catch (e) {
      rethrow;
    }
  }
}
