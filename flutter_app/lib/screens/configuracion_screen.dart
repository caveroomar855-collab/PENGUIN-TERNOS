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
                  _ConfigCard(
                    icon: Icons.shield,
                    title: 'Garantía',
                    value: config.garantiaValor,
                    suffix: 'soles',
                    onEdit: () => _editValue(
                      context,
                      'Garantía',
                      config.garantiaValor,
                      (value) => provider.updateConfiguracion(
                        garantiaValor: value,
                      ),
                    ),
                  ),
                  _ConfigCard(
                    icon: Icons.warning,
                    title: 'Mora Diaria',
                    value: config.moraValor,
                    suffix: 'soles/día',
                    onEdit: () => _editValue(
                      context,
                      'Mora por Día',
                      config.moraValor,
                      (value) => provider.updateConfiguracion(
                        moraValor: value,
                      ),
                    ),
                  ),
                  _ConfigCard(
                    icon: Icons.calendar_today,
                    title: 'Días Máximos de Mora',
                    value: config.moraDiasMaximos.toDouble(),
                    suffix: 'días',
                    isInteger: true,
                    onEdit: () => _editValue(
                      context,
                      'Días Máximos de Mora',
                      config.moraDiasMaximos.toDouble(),
                      (value) => provider.updateConfiguracion(
                        moraDiasMaximos: value.toInt(),
                      ),
                      isInteger: true,
                    ),
                  ),
                  Card(
                    color: Colors.blue.shade50,
                    child: ListTile(
                      leading:
                          const Icon(Icons.info_outline, color: Colors.blue),
                      title: const Text('Mora Máxima Posible'),
                      subtitle: Text(
                        NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2)
                            .format(config.moraMaximaPosible),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${config.moraDiasMaximos} días × S/ ${config.moraValor}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
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

  Future<void> _editValue(
    BuildContext context,
    String title,
    double currentValue,
    Future<void> Function(double) onSave, {
    bool isInteger = false,
  }) async {
    final controller = TextEditingController(
      text:
          isInteger ? currentValue.toInt().toString() : currentValue.toString(),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $title'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value >= 0) {
                Navigator.pop(context, value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Valor inválido')),
                );
              }
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );

    if (result != null) {
      await onSave(result);
    }
  }
}

class _ConfigCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final String suffix;
  final VoidCallback onEdit;
  final bool isInteger;

  const _ConfigCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.suffix,
    required this.onEdit,
    this.isInteger = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue =
        isInteger ? value.toInt().toString() : value.toStringAsFixed(2);

    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(
          '$displayValue $suffix',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
