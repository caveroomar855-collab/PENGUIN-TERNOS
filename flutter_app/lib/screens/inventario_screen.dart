import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/articulos_provider.dart';
import '../providers/trajes_provider.dart';
import '../models/articulo.dart';
import 'package:intl/intl.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({Key? key}) : super(key: key);

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currencyFormat =
      NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrajesProvider>().fetchTrajes();
      context.read<ArticulosProvider>().fetchArticulos();
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
        title: const Text('Inventario'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Trajes', icon: Icon(Icons.checkroom)),
            Tab(text: 'Artículos', icon: Icon(Icons.inventory_2)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TrajesProvider>().fetchTrajes();
              context.read<ArticulosProvider>().fetchArticulos();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrajesTab(),
          _buildArticulosTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptionsDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildTrajesTab() {
    return Consumer<TrajesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.trajes.isEmpty) {
          return _buildEmptyState('trajes', Icons.checkroom);
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchTrajes(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.trajes.length,
            itemBuilder: (context, index) {
              final traje = provider.trajes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: const Icon(Icons.checkroom, color: Colors.white),
                  ),
                  title: Text(traje.nombre),
                  subtitle: Text(
                    traje.descripcion ?? 'Sin descripción',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _currencyFormat.format(traje.precioAlquiler),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        'V: ${_currencyFormat.format(traje.precioVenta)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    _showTrajeDetails(context, traje);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildArticulosTab() {
    return Consumer<ArticulosProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.articulos.isEmpty) {
          return _buildEmptyState('artículos', Icons.inventory_2);
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchArticulos(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.articulos.length,
            itemBuilder: (context, index) {
              final articulo = provider.articulos[index];
              final Color estadoColor = _getEstadoColor(articulo.estado);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: estadoColor,
                    child: Text(
                      '${articulo.cantidadDisponible}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text('${articulo.nombre} - Talla ${articulo.talla}'),
                  subtitle: Text(
                    'Tipo: ${articulo.tipo.displayName}\n'
                    'Disponibles: ${articulo.cantidadDisponible} | '
                    'Alquilados: ${articulo.cantidadAlquilada} | '
                    'Mantenimiento: ${articulo.cantidadMantenimiento}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _currencyFormat.format(articulo.precioAlquiler),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'V: ${_currencyFormat.format(articulo.precioVenta)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    _showArticuloDetails(context, articulo);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String item, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay $item registrados',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para agregar',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(ArticuloEstado estado) {
    switch (estado) {
      case ArticuloEstado.disponible:
        return Colors.green;
      case ArticuloEstado.alquilado:
        return Colors.orange;
      case ArticuloEstado.mantenimiento:
        return Colors.amber;
    }
  }

  void _showAddOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar al Inventario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.checkroom, color: Colors.orange),
              title: const Text('Agregar Traje'),
              subtitle: const Text('Conjunto de 4 artículos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/nuevo-traje');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.inventory_2, color: Colors.blue),
              title: const Text('Agregar Artículo'),
              subtitle: const Text('Artículo individual'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/nuevo-articulo');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTrajeDetails(BuildContext context, dynamic traje) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    traje.nombre,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (traje.descripcion != null &&
                      traje.descripcion!.isNotEmpty)
                    Text(
                      traje.descripcion!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    title: 'Precio Alquiler',
                    value: _currencyFormat.format(traje.precioAlquiler),
                  ),
                  _DetailRow(
                    title: 'Precio Venta',
                    value: _currencyFormat.format(traje.precioVenta),
                  ),
                  const Divider(height: 24),
                  Text(
                    'Artículos del Traje',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Consulta los artículos individuales en la pestaña de Artículos',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showArticuloDetails(BuildContext context, dynamic articulo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    articulo.nombre,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(title: 'Tipo', value: articulo.tipo.displayName),
                  _DetailRow(title: 'Talla', value: articulo.talla),
                  _DetailRow(
                    title: 'Estado',
                    value: articulo.estado.displayName,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    title: 'Total en Inventario',
                    value: '${articulo.cantidad}',
                  ),
                  _DetailRow(
                    title: 'Disponibles',
                    value: '${articulo.cantidadDisponible}',
                  ),
                  _DetailRow(
                    title: 'Alquilados',
                    value: '${articulo.cantidadAlquilada}',
                  ),
                  _DetailRow(
                    title: 'En Mantenimiento',
                    value: '${articulo.cantidadMantenimiento}',
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    title: 'Precio Alquiler',
                    value: _currencyFormat.format(articulo.precioAlquiler),
                  ),
                  _DetailRow(
                    title: 'Precio Venta',
                    value: _currencyFormat.format(articulo.precioVenta),
                  ),
                  if (articulo.descripcion != null &&
                      articulo.descripcion!.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      'Descripción',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(articulo.descripcion!),
                  ],
                  const SizedBox(height: 24),
                  if (articulo.cantidadMantenimiento > 0)
                    ElevatedButton.icon(
                      onPressed: () {
                        // Quitar del mantenimiento
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.build_circle),
                      label: const Text('Quitar de Mantenimiento'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                ],
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
