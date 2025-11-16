import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/employee_setup_screen.dart';
import 'screens/main_screen.dart';
import 'screens/nuevo_articulo_screen.dart';
import 'screens/nuevo_traje_screen.dart';
import 'screens/nueva_cita_screen.dart';
import 'screens/nuevo_alquiler_screen.dart';
import 'screens/nueva_venta_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/clientes_provider.dart';
import 'providers/articulos_provider.dart';
import 'providers/trajes_provider.dart';
import 'providers/alquileres_provider.dart';
import 'providers/ventas_provider.dart';
import 'providers/citas_provider.dart';
import 'providers/configuracion_provider.dart';
import 'providers/dashboard_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ClientesProvider()),
        ChangeNotifierProvider(create: (_) => ArticulosProvider()),
        ChangeNotifierProvider(create: (_) => TrajesProvider()),
        ChangeNotifierProvider(create: (_) => AlquileresProvider()),
        ChangeNotifierProvider(create: (_) => VentasProvider()),
        ChangeNotifierProvider(create: (_) => CitasProvider()),
        ChangeNotifierProvider(create: (_) => ConfiguracionProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        return MaterialApp(
          title: 'Penguin Ternos',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
          routes: {
            '/employee-setup': (context) => const EmployeeSetupScreen(),
            '/main': (context) => const MainScreen(),
            '/nuevo-articulo': (context) => const NuevoArticuloScreen(),
            '/nuevo-traje': (context) => const NuevoTrajeScreen(),
            '/nueva-cita': (context) => const NuevaCitaScreen(),
            '/nuevo-alquiler': (context) => const NuevoAlquilerScreen(),
            '/nueva-venta': (context) => const NuevaVentaScreen(),
          },
        );
      },
    );
  }
}
