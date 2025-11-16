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
                        venta.medioPago.name.toUpperCase(),
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
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalles de la Venta',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _DetailRow(
                  title: 'Cliente',
                  value: venta.cliente?.nombreCompleto ?? 'N/A'),
              _DetailRow(title: 'DNI', value: venta.cliente?.dni ?? 'N/A'),
              _DetailRow(
                  title: 'Teléfono', value: venta.cliente?.telefono ?? 'N/A'),
              _DetailRow(
                title: 'Fecha',
                value: _dateFormat.format(venta.fechaVenta),
              ),
              _DetailRow(
                title: 'Medio de Pago',
                value: venta.medioPago.name.toUpperCase(),
              ),
              const Divider(height: 24),
              _DetailRow(
                title: 'Total',
                value: _currencyFormat.format(venta.montoTotal),
                isTotal: true,
              ),
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
