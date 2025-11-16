import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  String? _employeeName;
  String? _deviceId;
  bool _isFirstTime = true;

  AuthProvider(this._prefs) {
    _loadAuthData();
  }

  String? get employeeName => _employeeName;
  String? get deviceId => _deviceId;
  bool get isFirstTime => _isFirstTime;
  bool get isAuthenticated => _employeeName != null && _deviceId != null;

  void _loadAuthData() {
    _employeeName = _prefs.getString('employee_name');
    _deviceId = _prefs.getString('device_id');
    _isFirstTime = _employeeName == null;
    notifyListeners();
  }

  Future<String> _getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor ?? 'unknown';
      } else {
        _deviceId = 'unknown';
      }
    } catch (e) {
      _deviceId = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
    }

    await _prefs.setString('device_id', _deviceId!);
    return _deviceId!;
  }

  Future<bool> setEmployeeName(String name) async {
    try {
      _employeeName = name;
      _deviceId = await _getDeviceId();

      await _prefs.setString('employee_name', name);
      await _prefs.setString('device_id', _deviceId!);

      _isFirstTime = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error saving employee name: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _prefs.remove('employee_name');
    _employeeName = null;
    _isFirstTime = true;
    notifyListeners();
  }
}
