import 'package:flutter/material.dart';
import '../models/configuracion.dart';
import '../services/configuracion_service.dart';

class ConfiguracionProvider extends ChangeNotifier {
  Configuracion? _configuracion;
  bool _isLoading = false;
  String? _error;

  Configuracion? get configuracion => _configuracion;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConfiguracion() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _configuracion = await ConfiguracionService.get();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateConfiguracion(Map<String, dynamic> data) async {
    try {
      _configuracion = await ConfiguracionService.update(data);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  double calcularGarantia(double monto) {
    return _configuracion?.calcularGarantia(monto) ?? 0;
  }

  double calcularMora(double monto, int dias) {
    return _configuracion?.calcularMora(monto, dias) ?? 0;
  }

  double calcularProlongacion(double monto, int dias) {
    return _configuracion?.calcularProlongacion(monto, dias) ?? 0;
  }
}
