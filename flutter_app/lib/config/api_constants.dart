class ApiConstants {
  // URL de producción en Render
  static const String baseUrl =
      'https://alquiler-ternos-backend.onrender.com/api'; // Endpoints
  static const String clientes = '$baseUrl/clientes';
  static const String articulos = '$baseUrl/articulos';
  static const String trajes = '$baseUrl/trajes';
  static const String alquileres = '$baseUrl/alquileres';
  static const String ventas = '$baseUrl/ventas';
  static const String citas = '$baseUrl/citas';
  static const String configuracion = '$baseUrl/configuracion';
  static const String dashboard = '$baseUrl/dashboard';
  static const String reportes = '$baseUrl/reportes';
  static const String empleados = '$baseUrl/empleados';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
