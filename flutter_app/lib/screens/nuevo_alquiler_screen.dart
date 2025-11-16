import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/cliente.dart';
import '../models/traje.dart';
import '../models/articulo.dart';
import '../providers/clientes_provider.dart';
import '../providers/trajes_provider.dart';
import '../providers/articulos_provider.dart';
import '../providers/alquileres_provider.dart';

class NuevoAlquilerScreen extends StatefulWidget {
  const NuevoAlquilerScreen({Key? key}) : super(key: key);

  @override
  State<NuevoAlquilerScreen> createState() => _NuevoAlquilerScreenState();
}

class _NuevoAlquilerScreenState extends State<NuevoAlquilerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _garantiaController = TextEditingController();
  final _observacionesController = TextEditingController();

  Cliente? _clienteSeleccionado;
  DateTime _fechaAlquiler = DateTime.now();
  DateTime _fechaDevolucion = DateTime.now().add(const Duration(days: 3));
  String _medioPago = 'efectivo';

  List<Traje> _trajesSeleccionados = [];
  List<Articulo> _articulosSeleccionados = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientesProvider>().fetchClientes();
      context.read<TrajesProvider>().fetchTrajes();
      context.read<ArticulosProvider>().fetchArticulos();
    });
  }

  @override
  void dispose() {
    _montoController.dispose();
    _garantiaController.dispose();
    _observacionesController.dispose();
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

  Future<void> _seleccionarTrajes() async {
    final trajes = context.read<TrajesProvider>().disponibles;

    if (trajes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay trajes disponibles')),
      );
      return;
    }

    final result = await showDialog<List<Traje>>(
      context: context,
      builder: (context) {
        List<Traje> selected = List.from(_trajesSeleccionados);
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Seleccionar Trajes'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: trajes.length,
                itemBuilder: (context, index) {
                  final traje = trajes[index];
                  final isSelected = selected.contains(traje);
                  return CheckboxListTile(
                    title: Text(traje.nombre),
                    subtitle: Text(
                        'S/ ${traje.precioAlquiler} - Disponibles: ${traje.cantidadDisponible}'),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selected.add(traje);
                        } else {
                          selected.remove(traje);
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
        _trajesSeleccionados = result;
        _calcularMonto();
      });
    }
  }

  Future<void> _seleccionarArticulos() async {
    final articulos = context.read<ArticulosProvider>().disponibles;

    if (articulos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay artículos disponibles')),
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
                        '${articulo.tipo.displayName} - Talla ${articulo.talla} - S/ ${articulo.precioAlquiler}'),
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
    for (final traje in _trajesSeleccionados) {
      total += traje.precioAlquiler;
    }
    for (final articulo in _articulosSeleccionados) {
      total += articulo.precioAlquiler;
    }
    _montoController.text = total.toStringAsFixed(2);

    // Calcular garantía (20% del monto)
    final garantia = total * 0.2;
    _garantiaController.text = garantia.toStringAsFixed(2);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_clienteSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un cliente')),
      );
      return;
    }

    if (_trajesSeleccionados.isEmpty && _articulosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debe seleccionar al menos un traje o artículo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Obtener IDs de artículos de trajes y artículos individuales
      List<String> articulosIds = [];

      // Agregar artículos de cada traje seleccionado
      for (final traje in _trajesSeleccionados) {
        for (final articulo in traje.articulos) {
          articulosIds.add(articulo.id);
        }
      }

      // Agregar artículos individuales
      for (final articulo in _articulosSeleccionados) {
        articulosIds.add(articulo.id);
      }

      final data = {
        'cliente_id': _clienteSeleccionado!.id,
        'fecha_alquiler': _fechaAlquiler.toIso8601String().split('T')[0],
        'fecha_devolucion': _fechaDevolucion.toIso8601String().split('T')[0],
        'medio_pago': _medioPago,
        'monto_alquiler': double.parse(_montoController.text),
        'garantia': double.parse(_garantiaController.text),
        'observaciones': _observacionesController.text.trim(),
        'articulos_ids': articulosIds,
      };

      final success =
          await context.read<AlquileresProvider>().createAlquiler(data);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alquiler creado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('No se pudo crear el alquiler');
        }
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
        title: const Text('Nuevo Alquiler'),
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

            // Trajes
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.checkroom, color: Colors.orange),
                    title: const Text('Trajes'),
                    subtitle:
                        Text('${_trajesSeleccionados.length} seleccionados'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _seleccionarTrajes,
                  ),
                  if (_trajesSeleccionados.isNotEmpty)
                    ..._trajesSeleccionados.map((traje) => ListTile(
                          dense: true,
                          title: Text(traje.nombre),
                          subtitle: Text('S/ ${traje.precioAlquiler}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _trajesSeleccionados.remove(traje);
                                _calcularMonto();
                              });
                            },
                          ),
                        )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Artículos
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.inventory, color: Colors.green),
                    title: const Text('Artículos Individuales'),
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
                              '${articulo.tipo.displayName} - S/ ${articulo.precioAlquiler}'),
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

            // Fechas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fechas',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Fecha de Alquiler'),
                      subtitle: Text(
                          '${_fechaAlquiler.day}/${_fechaAlquiler.month}/${_fechaAlquiler.year}'),
                      trailing: const Icon(Icons.edit, size: 20),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _fechaAlquiler,
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 30)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _fechaAlquiler = date);
                        }
                      },
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.event),
                      title: const Text('Fecha de Devolución'),
                      subtitle: Text(
                          '${_fechaDevolucion.day}/${_fechaDevolucion.month}/${_fechaDevolucion.year}'),
                      trailing: const Icon(Icons.edit, size: 20),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _fechaDevolucion,
                          firstDate: _fechaAlquiler,
                          lastDate:
                              _fechaAlquiler.add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _fechaDevolucion = date);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Montos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _montoController,
                      decoration: const InputDecoration(
                        labelText: 'Monto de Alquiler *',
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
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _garantiaController,
                      decoration: const InputDecoration(
                        labelText: 'Garantía *',
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
                    ),
                  ],
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
            const SizedBox(height: 16),

            // Observaciones
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones (Opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
                      backgroundColor: Colors.blue,
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
                        : const Text('Crear Alquiler'),
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
