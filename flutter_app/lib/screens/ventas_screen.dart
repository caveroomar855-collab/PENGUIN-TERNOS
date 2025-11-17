import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ventas_provider.dart';
import 'package:intl/intl.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({Key? key}) : super(key: key);

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final _currencyFormat =
      NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VentasProvider>().fetchVentas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<VentasProvider>().fetchVentas(),
          ),
        ],
      ),
      body: Consumer<VentasProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.ventas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay ventas registradas',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.ventas.length,
            itemBuilder: (context, index) {
              final venta = provider.ventas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.shopping_bag, color: Colors.white),
                  ),
                  title: Text(venta.cliente?.nombreCompleto ?? 'Sin nombre'),
                  subtitle: Text(
                    '${_dateFormat.format(venta.fechaVenta)}\n'
                    'DNI: ${venta.cliente?.dni ?? 'N/A'}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _currencyFormat.format(venta.montoTotal),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        venta.medioPago.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // Mostrar detalles de la venta
                    _showVentaDetails(context, venta);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar a nueva venta
          Navigator.pushNamed(context, '/nueva-venta');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Venta'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showVentaDetails(BuildContext context, dynamic venta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles de la Venta',
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
                                value: venta.cliente?.nombreCompleto ?? 'N/A'),
                            _DetailRow(
                                title: 'DNI',
                                value: venta.cliente?.dni ?? 'N/A'),
                            _DetailRow(
                                title: 'Teléfono',
                                value: venta.cliente?.telefono ?? 'N/A'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Fecha y pago
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('INFORMACIÓN',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _DetailRow(
                                title: 'Fecha',
                                value: _dateFormat.format(venta.fechaVenta)),
                            _DetailRow(
                                title: 'Medio de Pago',
                                value: venta.medioPago.displayName),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Items vendidos
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ARTÍCULOS (${venta.items?.length ?? 0})',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (venta.items != null &&
                                venta.items.isNotEmpty) ...[
                              ...venta.items.map((item) {
                                final articulo = item.articulo;
                                final articuloId = item.articuloId;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(Icons.checkroom,
                                                size: 16,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(articulo?.nombre ??
                                                  'Artículo ${articuloId.length >= 8 ? articuloId.substring(0, 8) : articuloId}'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                          'S/ ${(item.articulo?.precioVenta ?? 0).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ] else ...[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('No hay artículos en esta venta',
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Total
                    Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _DetailRow(
                          title: 'TOTAL',
                          value: _currencyFormat.format(venta.montoTotal),
                          isTotal: true,
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
  final bool isTotal;

  const _DetailRow({
    required this.title,
    required this.value,
    this.isTotal = false,
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
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? null : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
