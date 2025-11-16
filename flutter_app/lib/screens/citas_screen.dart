import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/citas_provider.dart';
import '../models/cita.dart';
import 'package:intl/intl.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({Key? key}) : super(key: key);

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CitasProvider>().fetchCitas();
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
        title: const Text('Citas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pendientes', icon: Icon(Icons.event_note)),
            Tab(text: 'Finalizadas', icon: Icon(Icons.event_available)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CitasProvider>().fetchCitas(),
          ),
        ],
      ),
      body: Consumer<CitasProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCitasTab(provider.citasPendientes, true),
              _buildCitasTab(provider.citasFinalizadas, false),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/nueva-cita');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildCitasTab(List<dynamic> citas, bool isPendiente) {
    if (citas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPendiente ? Icons.event_note : Icons.event_available,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay citas ${isPendiente ? 'pendientes' : 'finalizadas'}',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<CitasProvider>().fetchCitas(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: citas.length,
        itemBuilder: (context, index) {
          final cita = citas[index];
          final Color tipoColor = _getTipoCitaColor(cita.tipoCita);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: tipoColor,
                child: Icon(
                  _getTipoCitaIcon(cita.tipoCita),
                  color: Colors.white,
                ),
              ),
              title: Text(cita.cliente?.nombreCompleto ?? 'Sin nombre'),
              subtitle: Text(
                '${_dateFormat.format(cita.fechaHora)}\n'
                'Tipo: ${_getTipoCitaText(cita.tipoCita.name)}\n'
                'DNI: ${cita.cliente?.dni ?? 'N/A'}',
              ),
              trailing: isPendiente
                  ? IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => _finalizarCita(cita.id),
                      tooltip: 'Marcar como finalizada',
                    )
                  : const Icon(Icons.check_circle, color: Colors.grey),
              isThreeLine: true,
              onTap: () => _showCitaDetails(context, cita, isPendiente),
            ),
          );
        },
      ),
    );
  }

  Color _getTipoCitaColor(TipoCita tipo) {
    switch (tipo) {
      case TipoCita.alquiler:
        return Colors.blue;
      case TipoCita.devolucion:
        return Colors.green;
      case TipoCita.prueba:
        return Colors.orange;
    }
  }

  IconData _getTipoCitaIcon(TipoCita tipo) {
    switch (tipo) {
      case TipoCita.alquiler:
        return Icons.card_travel;
      case TipoCita.devolucion:
        return Icons.assignment_return;
      case TipoCita.prueba:
        return Icons.checkroom;
    }
  }

  String _getTipoCitaText(String tipo) {
    switch (tipo) {
      case 'alquiler':
        return 'Alquiler';
      case 'devolucion':
        return 'Devolución';
      case 'prueba':
        return 'Prueba';
      default:
        return tipo.toUpperCase();
    }
  }

  void _finalizarCita(String citaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Cita'),
        content: const Text('¿Marcar esta cita como finalizada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<CitasProvider>().finalizarCita(citaId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cita finalizada correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _showCitaDetails(BuildContext context, dynamic cita, bool isPendiente) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detalles de la Cita',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Chip(
                    label: Text(
                      isPendiente ? 'PENDIENTE' : 'FINALIZADA',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: isPendiente ? Colors.orange : Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DetailRow(
                  title: 'Cliente',
                  value: cita.cliente?.nombreCompleto ?? 'N/A'),
              _DetailRow(title: 'DNI', value: cita.cliente?.dni ?? 'N/A'),
              _DetailRow(
                title: 'Teléfono',
                value: cita.cliente?.telefono ?? 'N/A',
              ),
              _DetailRow(
                title: 'Correo',
                value: cita.cliente?.correo ?? 'N/A',
              ),
              const Divider(height: 24),
              _DetailRow(
                title: 'Fecha y Hora',
                value: _dateFormat.format(cita.fechaHora),
              ),
              _DetailRow(
                title: 'Tipo de Cita',
                value: _getTipoCitaText(cita.tipoCita.name),
              ),
              if (cita.descripcion != null && cita.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Descripción:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(cita.descripcion!),
              ],
              if (isPendiente) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _finalizarCita(cita.id);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Marcar como Finalizada'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
