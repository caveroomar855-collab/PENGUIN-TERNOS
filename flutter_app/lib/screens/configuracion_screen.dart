import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../providers/configuracion_provider.dart';
import '../models/configuracion.dart';
import 'package:intl/intl.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({Key? key}) : super(key: key);

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  String? _employeeName;
  String? _deviceId;

  @override
  void initState() {
    super.initState();
    _loadEmployeeInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConfiguracionProvider>().loadConfiguracion();
    });
  }

  Future<void> _loadEmployeeInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _employeeName = prefs.getString('employee_name');
      _deviceId = prefs.getString('device_id');
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Empleado'),
              subtitle: Text(_employeeName ?? 'Cargando...'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Dispositivo'),
              subtitle: Text(_deviceId ?? 'Cargando...'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              title: const Text('Modo Oscuro'),
              subtitle:
                  Text(themeProvider.isDarkMode ? 'Activado' : 'Desactivado'),
              value: themeProvider.isDarkMode,
              onChanged: (_) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'CONFIGURACIÓN DE ALQUILERES',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Consumer<ConfiguracionProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              final config = provider.configuracion;
              if (config == null) {
                return const Card(
                  child: ListTile(
                    title: Text('No se pudo cargar la configuración'),
                  ),
                );
              }

              return Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.monetization_on),
                      title: const Text('Garantía'),
                      subtitle: Text(_formatConfig(
                          config.garantiaTipo, config.garantiaValor)),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning),
                      title: const Text('Mora por Día'),
                      subtitle: Text(
                          _formatConfig(config.moraTipo, config.moraValor)),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber),
                      title: const Text('Mora Máxima'),
                      subtitle: Text(
                          NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2)
                              .format(config.moraMaxima)),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.update),
                      title: const Text('Prolongación'),
                      subtitle: Text(_formatConfig(
                          config.prolongacionTipo, config.prolongacionValor)),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content:
                      const Text('¿Estás seguro de que deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('CANCELAR'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('CERRAR SESIÓN'),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/employee-setup');
                }
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatConfig(TipoValor tipo, double valor) {
    final symbol = tipo == TipoValor.porcentaje ? '%' : 'S/';
    return '${tipo.displayName}: ${NumberFormat.currency(symbol: "$symbol ", decimalDigits: 2).format(valor)}';
  }
}
