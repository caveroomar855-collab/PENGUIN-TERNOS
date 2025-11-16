import 'package:flutter/material.dart';
import '../models/venta.dart';
import '../services/ventas_service.dart';

class VentasProvider extends ChangeNotifier {
  List<Venta> _ventas = [];
  bool _isLoading = false;
  String? _error;

  List<Venta> get ventas => _ventas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchVentas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ventas = await VentasService.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVentas() async {
    await fetchVentas();
  }

  Future<Venta> createVenta(Map<String, dynamic> data) async {
    try {
      final venta = await VentasService.create(data);
      _ventas.insert(0, venta);
      notifyListeners();
      return venta;
    } catch (e) {
      rethrow;
    }
  }
}
