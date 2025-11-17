import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/alquileres_provider.dart';
import '../providers/configuracion_provider.dart';
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
            onTap: () => _showAlquilerDetails(context, alquiler),
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
      case 'perdido':
        _showMarcarPerdidoDialog(alquiler);
        break;
    }
  }

  void _showDevolverDialog(Alquiler alquiler) {
    // Estado para cada artículo individual
    final List<Map<String, dynamic>> articulosEstados = [];

    // Inicializar estados por defecto para cada artículo
    for (final item in alquiler.items) {
      articulosEstados.add({
        'articulo_id': item.articuloId,
        'traje_id': null,
        'tipo': 'articulo',
        'estado_devolucion': 'completo', // Por defecto completo
        'observaciones': '',
        'nombre': item.articulo?.nombre ?? 'Artículo sin nombre',
      });
    }

    bool retenerGarantia = false;
    final observacionesGeneralesController = TextEditingController();
    final List<TextEditingController> observacionesControllers =
        List.generate(articulosEstados.length, (_) => TextEditingController());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Devolver Alquiler'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cliente: ${alquiler.cliente?.nombreCompleto ?? "N/A"}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Marca el estado de cada artículo:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Divider(height: 24),

                  // Lista de artículos con su estado individual
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: articulosEstados.length,
                    itemBuilder: (context, index) {
                      final articulo = articulosEstados[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                articulo['nombre'] ?? 'Artículo ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Estado de devolución',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                value: articulo['estado_devolucion'],
                                items: const [
                                  DropdownMenuItem(
                                    value: 'completo',
                                    child:
                                        Text('✓ Completo (24h mantenimiento)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'danado',
                                    child: Text('⚠ Dañado (72h mantenimiento)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'perdido',
                                    child: Text('✗ Perdido (no devuelto)'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    articulo['estado_devolucion'] = value;
                                    // Si hay algún perdido, automáticamente retener garantía
                                    if (value == 'perdido') {
                                      retenerGarantia = true;
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: observacionesControllers[index],
                                decoration: const InputDecoration(
                                  labelText: 'Observaciones (opcional)',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                maxLines: 2,
                                onChanged: (value) {
                                  articulo['observaciones'] = value;
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 24),
                  const Text(
                    'Información general:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Retener garantía'),
                    subtitle: Text(
                      articulosEstados
                              .any((a) => a['estado_devolucion'] == 'perdido')
                          ? 'Se retendrá automáticamente por artículos perdidos'
                          : 'Opcional',
                      style: TextStyle(
                        fontSize: 12,
                        color: articulosEstados
                                .any((a) => a['estado_devolucion'] == 'perdido')
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    ),
                    value: retenerGarantia,
                    onChanged: (value) {
                      setState(() => retenerGarantia = value ?? false);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: observacionesGeneralesController,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones generales (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                for (var controller in observacionesControllers) {
                  controller.dispose();
                }
                observacionesGeneralesController.dispose();
                Navigator.pop(context);
              },
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                final provider = context.read<AlquileresProvider>();
                final success = await provider.devolverAlquiler(
                  alquiler.id,
                  {
                    'articulos_estados': articulosEstados
                        .map((a) => {
                              'articulo_id': a['articulo_id'],
                              'traje_id': a['traje_id'],
                              'tipo': a['tipo'],
                              'estado_devolucion': a['estado_devolucion'],
                              'observaciones': a['observaciones'],
                            })
                        .toList(),
                    'retener_garantia': retenerGarantia,
                    'observaciones_generales':
                        observacionesGeneralesController.text.isEmpty
                            ? null
                            : observacionesGeneralesController.text,
                    'monto_mora': 0, // Calcular según sea necesario
                  },
                );

                // Limpiar controladores
                for (var controller in observacionesControllers) {
                  controller.dispose();
                }
                observacionesGeneralesController.dispose();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Alquiler devuelto exitosamente'
                          : 'Error al devolver alquiler'),
                      backgroundColor: success ? Colors.green : Colors.red,
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

  void _showAlquilerDetails(BuildContext context, Alquiler alquiler) {
    final currencyFormat =
        NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles del Alquiler',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 16),

                    // Cliente info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CLIENTE',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _DetailRow(
                                title: 'Nombre',
                                value:
                                    alquiler.cliente?.nombreCompleto ?? 'N/A'),
                            _DetailRow(
                                title: 'DNI',
                                value: alquiler.cliente?.dni ?? 'N/A'),
                            _DetailRow(
                                title: 'Teléfono',
                                value: alquiler.cliente?.telefono ?? 'N/A'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Fechas y estado
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FECHAS Y ESTADO',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _DetailRow(
                                title: 'Fecha Alquiler',
                                value:
                                    _dateFormat.format(alquiler.fechaAlquiler)),
                            _DetailRow(
                                title: 'Fecha Devolución',
                                value: _dateFormat
                                    .format(alquiler.fechaDevolucion)),
                            if (alquiler.fechaDevolucionReal != null)
                              _DetailRow(
                                  title: 'Devuelto el',
                                  value: _dateFormat
                                      .format(alquiler.fechaDevolucionReal!)),
                            _DetailRow(
                                title: 'Estado',
                                value: alquiler.estado.displayName),
                            if (alquiler.estadoDevolucion != null)
                              _DetailRow(
                                  title: 'Estado Devolución',
                                  value:
                                      alquiler.estadoDevolucion!.displayName),
                            if (alquiler.diasMora > 0)
                              _DetailRow(
                                  title: 'Días en Mora',
                                  value: '${alquiler.diasMora} días',
                                  isHighlight: true),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Montos
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MONTOS',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _DetailRow(
                                title: 'Monto Alquiler',
                                value: currencyFormat
                                    .format(alquiler.montoAlquiler)),
                            _DetailRow(
                                title: 'Garantía',
                                value:
                                    currencyFormat.format(alquiler.garantia)),
                            if (alquiler.montoMora > 0)
                              _DetailRow(
                                  title: 'Mora',
                                  value:
                                      currencyFormat.format(alquiler.montoMora),
                                  isHighlight: true),
                            _DetailRow(
                                title: 'Medio de Pago',
                                value: alquiler.medioPago.displayName),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Items
                    if (alquiler.items.isNotEmpty) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ARTÍCULOS (${alquiler.items.length})',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...alquiler.items.map((item) {
                                final articulo = item.articulo;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.checkroom,
                                          size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(articulo?.nombre ??
                                            'Artículo ${item.articuloId.substring(0, 8)}'),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Observaciones
                    if (alquiler.observaciones != null &&
                        alquiler.observaciones!.isNotEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('OBSERVACIONES',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(alquiler.observaciones!),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isHighlight;

  const _DetailRow({
    required this.title,
    required this.value,
    this.isHighlight = false,
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
              fontWeight: FontWeight.normal,
              color: isHighlight ? null : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}
