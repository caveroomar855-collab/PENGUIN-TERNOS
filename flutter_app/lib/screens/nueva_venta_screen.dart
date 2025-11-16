import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/cliente.dart';
import '../models/articulo.dart';
import '../providers/clientes_provider.dart';
import '../providers/articulos_provider.dart';
import '../providers/ventas_provider.dart';

class NuevaVentaScreen extends StatefulWidget {
  const NuevaVentaScreen({Key? key}) : super(key: key);

  @override
  State<NuevaVentaScreen> createState() => _NuevaVentaScreenState();
}

class _NuevaVentaScreenState extends State<NuevaVentaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();

  Cliente? _clienteSeleccionado;
  String _medioPago = 'efectivo';
  List<Articulo> _articulosSeleccionados = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientesProvider>().fetchClientes();
      context.read<ArticulosProvider>().fetchArticulos();
    });
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarCliente() async {
    final clientes = context.read<ClientesProvider>().clientes;

    if (clientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay clientes disponibles')),
      );
      return;
    }

    final result = await showDialog<Cliente>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Cliente'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cliente = clientes[index];
              return ListTile(
                title: Text(cliente.nombreCompleto),
                subtitle: Text('DNI: ${cliente.dni}'),
                onTap: () => Navigator.pop(context, cliente),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _clienteSeleccionado = result);
    }
  }

  Future<void> _seleccionarArticulos() async {
    final articulos = context.read<ArticulosProvider>().disponibles;

    if (articulos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No hay artículos disponibles para venta')),
      );
      return;
    }

    final result = await showDialog<List<Articulo>>(
      context: context,
      builder: (context) {
        List<Articulo> selected = List.from(_articulosSeleccionados);
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Seleccionar Artículos'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: articulos.length,
                itemBuilder: (context, index) {
                  final articulo = articulos[index];
                  final isSelected = selected.contains(articulo);
                  return CheckboxListTile(
                    title: Text(articulo.nombre),
                    subtitle: Text(
                        '${articulo.tipo.displayName} - Talla ${articulo.talla} - S/ ${articulo.precioVenta}\n'
                        'Disponibles: ${articulo.cantidadDisponible}'),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selected.add(articulo);
                        } else {
                          selected.remove(articulo);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _articulosSeleccionados = result;
        _calcularMonto();
      });
    }
  }

  void _calcularMonto() {
    double total = 0;
    for (final articulo in _articulosSeleccionados) {
      total += articulo.precioVenta;
    }
    _montoController.text = total.toStringAsFixed(2);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_clienteSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un cliente')),
      );
      return;
    }

    if (_articulosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar al menos un artículo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'cliente_id': _clienteSeleccionado!.id,
        'medio_pago': _medioPago,
        'monto_total': double.parse(_montoController.text),
        'articulos_ids': _articulosSeleccionados.map((a) => a.id).toList(),
      };

      await context.read<VentasProvider>().createVenta(data);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Venta registrada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cliente
            Card(
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: Text(_clienteSeleccionado?.nombreCompleto ??
                    'Seleccionar Cliente'),
                subtitle: _clienteSeleccionado != null
                    ? Text('DNI: ${_clienteSeleccionado!.dni}')
                    : null,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _seleccionarCliente,
              ),
            ),
            const SizedBox(height: 16),

            // Artículos
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.shopping_cart, color: Colors.green),
                    title: const Text('Artículos'),
                    subtitle:
                        Text('${_articulosSeleccionados.length} seleccionados'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _seleccionarArticulos,
                  ),
                  if (_articulosSeleccionados.isNotEmpty)
                    ..._articulosSeleccionados.map((articulo) => ListTile(
                          dense: true,
                          title: Text(articulo.nombre),
                          subtitle: Text(
                              '${articulo.tipo.displayName} - S/ ${articulo.precioVenta}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _articulosSeleccionados.remove(articulo);
                                _calcularMonto();
                              });
                            },
                          ),
                        )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Monto Total
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _montoController,
                  decoration: const InputDecoration(
                    labelText: 'Monto Total *',
                    prefixText: 'S/ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    return null;
                  },
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Medio de Pago
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Medio de Pago',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    RadioListTile<String>(
                      dense: true,
                      title: const Text('Efectivo'),
                      value: 'efectivo',
                      groupValue: _medioPago,
                      onChanged: (value) => setState(() => _medioPago = value!),
                    ),
                    RadioListTile<String>(
                      dense: true,
                      title: const Text('Yape/Plin'),
                      value: 'yape-plin',
                      groupValue: _medioPago,
                      onChanged: (value) => setState(() => _medioPago = value!),
                    ),
                    RadioListTile<String>(
                      dense: true,
                      title: const Text('Tarjeta'),
                      value: 'tarjeta',
                      groupValue: _medioPago,
                      onChanged: (value) => setState(() => _medioPago = value!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Registrar Venta'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
