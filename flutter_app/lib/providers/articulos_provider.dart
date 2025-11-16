import 'package:flutter/material.dart';
import '../models/articulo.dart';
import '../services/articulos_service.dart';

class ArticulosProvider extends ChangeNotifier {
  List<Articulo> _articulos = [];
  bool _isLoading = false;
  String? _error;

  List<Articulo> get articulos => _articulos;
  List<Articulo> get disponibles => _articulos
      .where((a) =>
          a.estado == ArticuloEstado.disponible && a.cantidadDisponible > 0)
      .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchArticulos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _articulos = await ArticulosService.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadArticulos() async {
    await fetchArticulos();
  }

  List<Articulo> getByTipo(ArticuloTipo tipo) {
    return _articulos.where((a) => a.tipo == tipo).toList();
  }

  List<Articulo> getByTraje(String trajeId) {
    return _articulos.where((a) => a.trajeId == trajeId).toList();
  }

  Future<Articulo> addArticulo(Map<String, dynamic> data) async {
    try {
      final articulo = await ArticulosService.create(data);
      _articulos.insert(0, articulo);
      notifyListeners();
      return articulo;
    } catch (e) {
      rethrow;
    }
  }
}
