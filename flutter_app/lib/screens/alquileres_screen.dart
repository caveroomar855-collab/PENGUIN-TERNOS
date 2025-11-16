import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/alquileres_provider.dart';
import '../models/alquiler.dart';

class AlquileresScreen extends StatefulWidget {
  const AlquileresScreen({Key? key}) : super(key: key);

  @override
  State<AlquileresScreen> createState() => _AlquileresScreenState();
}

class _AlquileresScreenState extends State<AlquileresScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _currencyFormat =
      NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlquileresProvider>().loadAlquileres();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alquileres'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ACTIVOS'),
            Tab(text: 'HISTORIAL'),
          ],
        ),
      ),
      body: Consumer<AlquileresProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildActivosList(provider.activos),
              _buildHistorialList(provider.historial),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => Navigator.pushNamed(context, '/nuevo-alquiler'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActivosList(List<Alquiler> alquileres) {
    if (alquileres.isEmpty) {
      return const Center(
        child: Text('No hay alquileres activos'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alquileres.length,
      itemBuilder: (context, index) {
        final alquiler = alquileres[index];
        final diasRestantes =
            alquiler.fechaDevolucion.difference(DateTime.now()).inDays;
        final enMora = diasRestantes < 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: enMora ? Colors.red : Colors.blue,
              child: Icon(
                enMora ? Icons.warning : Icons.shopping_cart,
                color: Colors.white,
              ),
            ),
            title:
                Text('Cliente: ${alquiler.cliente?.nombreCompleto ?? "N/A"}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alquiler ID: ${alquiler.id.substring(0, 8)}'),
                Text(
                  'Devolución: ${_dateFormat.format(alquiler.fechaDevolucion)}',
                  style: TextStyle(
                    color: enMora ? Colors.red : null,
                    fontWeight: enMora ? FontWeight.bold : null,
                  ),
                ),
                if (enMora) Text('MORA: ${alquiler.diasMora} días'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleAlquilerAction(value, alquiler),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'devolver',
                  child: Row(
                    children: [
                      Icon(Icons.assignment_return, size: 20),
                      SizedBox(width: 8),
                      Text('Devolver'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'prolongar',
                  child: Row(
                    children: [
                      Icon(Icons.update, size: 20),
                      SizedBox(width: 8),
                      Text('Prolongar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'perdido',
                  child: Row(
                    children: [
                      Icon(Icons.dangerous, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Marcar Perdido/Robo',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistorialList(List<Alquiler> alquileres) {
    if (alquileres.isEmpty) {
      return const Center(
        child: Text('No hay historial'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alquileres.length,
      itemBuilder: (context, index) {
        final alquiler = alquileres[index];
        final isPerdido = alquiler.estado == AlquilerEstado.perdido;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPerdido ? Colors.red : Colors.green,
              child: Icon(
                isPerdido ? Icons.dangerous : Icons.check,
                color: Colors.white,
              ),
            ),
            title:
                Text('Cliente: ${alquiler.cliente?.nombreCompleto ?? "N/A"}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alquiler ID: ${alquiler.id.substring(0, 8)}'),
                Text('Alquiler: ${_dateFormat.format(alquiler.fechaAlquiler)}'),
                if (alquiler.fechaDevolucionReal != null)
                  Text(
                      'Devuelto: ${_dateFormat.format(alquiler.fechaDevolucionReal!)}'),
                if (isPerdido) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          alquiler.esRobo ? 'ROBO/PÉRDIDA' : 'NO DEVUELTO',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (alquiler.garantiaRetenida)
                    const Text(
                      'Garantía retenida',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ],
            ),
            trailing: Text(
              _currencyFormat
                  .format(alquiler.montoAlquiler + alquiler.montoMora),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleAlquilerAction(String action, Alquiler alquiler) {
    switch (action) {
      case 'devolver':
        _showDevolverDialog(alquiler);
        break;
      case 'prolongar':
        _showProlongarDialog(alquiler);
        break;
      case 'perdido':
        _showMarcarPerdidoDialog(alquiler);
        break;
    }
  }

  void _showDevolverDialog(Alquiler alquiler) {
    EstadoDevolucion? estadoSeleccionado;
    bool retenerGarantia = false;
    final observacionesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Devolver Alquiler'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cliente: ${alquiler.cliente?.nombreCompleto ?? "N/A"}'),
                const SizedBox(height: 16),
                const Text('Estado de devolución:'),
                DropdownButton<EstadoDevolucion>(
                  isExpanded: true,
                  value: estadoSeleccionado,
                  hint: const Text('Seleccionar estado'),
                  items: EstadoDevolucion.values.map((estado) {
                    return DropdownMenuItem(
                      value: estado,
                      child: Text(_estadoDevolucionLabel(estado)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => estadoSeleccionado = value);
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Retener garantía'),
                  value: retenerGarantia,
                  onChanged: (value) {
                    setState(() => retenerGarantia = value ?? false);
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: observacionesController,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: estadoSeleccionado == null
                  ? null
                  : () async {
                      Navigator.pop(context);
                      final provider = context.read<AlquileresProvider>();
                      final success = await provider.devolverAlquiler(
                        alquiler.id,
                        {
                          'estado_devolucion': estadoSeleccionado!.name,
                          'retener_garantia': retenerGarantia,
                          'observaciones': observacionesController.text.isEmpty
                              ? null
                              : observacionesController.text,
                        },
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Alquiler devuelto exitosamente'
                                : 'Error al devolver alquiler'),
                            backgroundColor:
                                success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
              child: const Text('DEVOLVER'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProlongarDialog(Alquiler alquiler) {
    final diasController = TextEditingController();
    final montoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prolongar Alquiler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cliente: ${alquiler.cliente?.nombreCompleto ?? "N/A"}'),
            const SizedBox(height: 16),
            TextField(
              controller: diasController,
              decoration: const InputDecoration(
                labelText: 'Días de prolongación',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: montoController,
              decoration: const InputDecoration(
                labelText: 'Monto adicional (S/)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              final dias = int.tryParse(diasController.text);
              final monto = double.tryParse(montoController.text);

              if (dias == null || monto == null || dias <= 0 || monto <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingrese valores válidos'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              final provider = context.read<AlquileresProvider>();
              final success =
                  await provider.prolongarAlquiler(alquiler.id, dias, monto);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Alquiler prolongado exitosamente'
                        : 'Error al prolongar alquiler'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('PROLONGAR'),
          ),
        ],
      ),
    );
  }

  void _showMarcarPerdidoDialog(Alquiler alquiler) {
    final observacionesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.dangerous, color: Colors.red),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Marcar como Perdido/Robo',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⚠️ ESTA ACCIÓN ES IRREVERSIBLE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text('Cliente: ${alquiler.cliente?.nombreCompleto ?? "N/A"}'),
              Text('Alquiler ID: ${alquiler.id.substring(0, 8)}'),
              const SizedBox(height: 16),
              const Text(
                'Al marcar este alquiler como perdido:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('✓ Se retendrá la garantía'),
              const Text('✓ Se descontará del inventario'),
              const Text('✓ Se registrará como robo/pérdida'),
              const Text('✓ No se podrá revertir'),
              const SizedBox(height: 16),
              TextField(
                controller: observacionesController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones *',
                  hintText: 'Describa qué sucedió...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (observacionesController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debe ingresar observaciones'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Confirmación adicional
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar'),
                  content: const Text(
                    '¿Está completamente seguro de marcar este alquiler como perdido/robo?\n\nEsta acción NO se puede deshacer.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('NO, CANCELAR'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('SÍ, MARCAR COMO PERDIDO'),
                    ),
                  ],
                ),
              );

              if (confirmar != true) return;

              Navigator.pop(context);
              final provider = context.read<AlquileresProvider>();
              final success = await provider.marcarComoPerdido(
                alquiler.id,
                observacionesController.text,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Alquiler marcado como perdido/robo. Garantía retenida.'
                        : 'Error al marcar como perdido'),
                    backgroundColor: success ? Colors.orange : Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('MARCAR COMO PERDIDO'),
          ),
        ],
      ),
    );
  }

  String _estadoDevolucionLabel(EstadoDevolucion estado) {
    switch (estado) {
      case EstadoDevolucion.completo:
        return 'Completo - Buenas condiciones';
      case EstadoDevolucion.danado:
        return 'Dañado - Requiere reparación';
      case EstadoDevolucion.incompleto:
        return 'Incompleto - Falta piezas';
      case EstadoDevolucion.perdido:
        return 'Perdido/Robo';
    }
  }
}
