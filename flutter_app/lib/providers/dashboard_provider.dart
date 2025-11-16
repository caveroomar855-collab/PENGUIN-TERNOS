import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  Map<String, dynamic>? _resumenDia;
  Map<String, dynamic>? _estadisticas;

  Map<String, dynamic>? get resumenDia => _resumenDia;
  Map<String, dynamic>? get estadisticas => _estadisticas;

  void setResumenDia(Map<String, dynamic> data) {
    _resumenDia = data;
    notifyListeners();
  }

  void setEstadisticas(Map<String, dynamic> data) {
    _estadisticas = data;
    notifyListeners();
  }
}
