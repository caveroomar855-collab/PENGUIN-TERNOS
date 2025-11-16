import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../services/dashboard_service.dart';
import 'package:intl/intl.dart';
import 'alquileres_screen.dart';
import 'ventas_screen.dart';
import 'inventario_screen.dart';
import 'citas_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _currencyFormat =
      NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final resumen = await DashboardService.getResumenDia();
      final estadisticas = await DashboardService.getEstadisticas();

      if (mounted) {
        final provider = context.read<DashboardProvider>();
        provider.setResumenDia(resumen);
        provider.setEstadisticas(estadisticas);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PENGUIN TERNOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Conectando con el servidor...'),
                  SizedBox(height: 8),
                  Text(
                    'Esto puede tardar unos segundos si el servidor está iniciando',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No se pudo conectar al servidor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Asegúrate de que el backend esté desplegado en Render',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : Consumer<DashboardProvider>(
                  builder: (context, dashboard, _) {
                    if (dashboard.resumenDia == null ||
                        dashboard.estadisticas == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final resumen = dashboard.resumenDia!;
                    final stats = dashboard.estadisticas!;

                    return RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // 4 BOTONES PRINCIPALES
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.3,
                            children: [
                              _MainButton(
                                title: 'ALQUILERES',
                                icon: Icons.card_travel,
                                color: Colors.blue,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AlquileresScreen()),
                                  );
                                },
                              ),
                              _MainButton(
                                title: 'VENTAS',
                                icon: Icons.shopping_bag,
                                color: Colors.green,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const VentasScreen()),
                                  );
                                },
                              ),
                              _MainButton(
                                title: 'INVENTARIO',
                                icon: Icons.inventory,
                                color: Colors.orange,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const InventarioScreen()),
                                  );
                                },
                              ),
                              _MainButton(
                                title: 'CITAS PENDIENTES',
                                icon: Icons.event_note,
                                color: Colors.purple,
                                badge: stats['citas_pendientes'],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CitasScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // RESUMEN DEL DÍA
                          Text(
                            'Resumen del Día',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _StatCard(
                            title: 'Alquileres Activos',
                            value: '${stats['alquileres_activos'] ?? 0}',
                            icon: Icons.assignment,
                            color: Colors.indigo,
                            isLarge: true,
                          ),
                          const SizedBox(height: 12),
                          _StatCard(
                            title: 'Devoluciones Pendientes',
                            value: '${stats['devoluciones_pendientes'] ?? 0}',
                            icon: Icons.assignment_return,
                            color: (stats['devoluciones_pendientes'] ?? 0) > 0
                                ? Colors.red
                                : Colors.grey,
                            isLarge: true,
                          ),
                          const SizedBox(height: 12),
                          // GANANCIAS DEL DÍA
                          Text(
                            'Ganancias del Día',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: 'Alquileres',
                                  value: _currencyFormat.format(
                                      resumen['ingresos_alquileres'] ?? 0),
                                  icon: Icons.card_travel,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: 'Ventas',
                                  value: _currencyFormat
                                      .format(resumen['ingresos_ventas'] ?? 0),
                                  icon: Icons.shopping_bag,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // INFORMACIÓN ADICIONAL
                          Row(
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  title: 'Trajes Disponibles',
                                  value: '${stats['trajes_disponibles'] ?? 0}',
                                  subtitle:
                                      'Artículos: ${stats['articulos_disponibles'] ?? 0}',
                                  icon: Icons.checkroom,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InfoCard(
                                  title: 'Total Clientes',
                                  value: '${stats['total_clientes'] ?? 0}',
                                  subtitle: 'Registrados',
                                  icon: Icons.people,
                                  color: Colors.cyan,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _MainButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badge;

  const _MainButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: color),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null && badge! > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const _StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLarge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isLarge
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}
