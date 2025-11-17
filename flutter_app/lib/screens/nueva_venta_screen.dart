import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/cliente.dart';
import '../models/articulo.dart';
import '../models/traje.dart';
import '../providers/clientes_provider.dart';
import '../providers/articulos_provider.dart';
import '../providers/trajes_provider.dart';
import '../providers/ventas_provider.dart';
import '../services/clientes_service.dart';

class NuevaVentaScreen extends StatefulWidget {
  const NuevaVentaScreen({Key? key}) : super(key: key);

  @override
  State<NuevaVentaScreen> createState() => _NuevaVentaScreenState();
}

class _NuevaVentaScreenState extends State<NuevaVentaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _dniController = TextEditingController();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();

  Cliente? _clienteEncontrado;
  String _medioPago = 'efectivo';
  List<Articulo> _articulosSeleccionados = [];
  List<Traje> _trajesSeleccionados = [];

  bool _isLoading = false;
  bool _buscandoCliente = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientesProvider>().fetchClientes();
      context.read<ArticulosProvider>().fetchArticulos();
      context.read<TrajesProvider>().fetchTrajes();
    });
  }

  @override
  void dispose() {
    _montoController.dispose();
    _dniController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _buscarClientePorDNI(String dni) async {
    if (dni.length < 8) return;

    setState(() => _buscandoCliente = true);

    try {
      await context.read<ClientesProvider>().fetchClientes();
      final clientes = context.read<ClientesProvider>().clientes;

      final cliente = clientes.firstWhere(
        (c) => c.dni == dni,
        orElse: () => Cliente(
          id: '',
          dni: '',
          nombreCompleto: '',
          telefono: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (cliente.id.isNotEmpty) {
        setState(() {
          _clienteEncontrado = cliente;
          _nombreController.text = cliente.nombreCompleto;
          _telefonoController.text = cliente.telefono;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente encontrado en el sistema'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() {
          _clienteEncontrado = null;
          _nombreController.clear();
          _telefonoController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar cliente: $e')),
        );
      }
    } finally {
      setState(() => _buscandoCliente = false);
    }
  }

  Future<void> _seleccionarTrajes() async {
    final trajes = context.read<TrajesProvider>().trajes;

    if (trajes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay trajes disponibles para venta')),
      );
      return;
    }

    final result = await showDialog<List<Traje>>(
      context: context,
      builder: (context) {
        List<Traje> selected = List.from(_trajesSeleccionados);
        List<Traje> filteredTrajes = List.from(trajes);
        TextEditingController searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Seleccionar Trajes'),
            content: SizedBox(
              width: double.maxFinite,
              height: 500,
              child: Column(
                children: [
                  // Buscador
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar traje',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  searchController.clear();
                                  filteredTrajes = List.from(trajes);
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          filteredTrajes = List.from(trajes);
                        } else {
                          filteredTrajes = trajes
                              .where((t) => t.nombre
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Lista de trajes
                  Expanded(
                    child: filteredTrajes.isEmpty
                        ? const Center(
                            child: Text('No se encontraron trajes'),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredTrajes.length,
                            itemBuilder: (context, index) {
                              final traje = filteredTrajes[index];
                              final isSelected = selected.contains(traje);
                              return CheckboxListTile(
                                title: Text(traje.nombre),
                                subtitle: Text(
                                    'S/ ${traje.precioVenta} - ${traje.articulos.length} artículos'),
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selected),
                child: Text('Aceptar (${selected.length})'),
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
        const SnackBar(
            content: Text('No hay artículos disponibles para venta')),
      );
      return;
    }

    final result = await showDialog<List<Articulo>>(
      context: context,
      builder: (context) {
        List<Articulo> selected = List.from(_articulosSeleccionados);
        List<Articulo> filteredArticulos = List.from(articulos);
        TextEditingController searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Seleccionar Artículos'),
            content: SizedBox(
              width: double.maxFinite,
              height: 500,
              child: Column(
                children: [
                  // Buscador
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar artículo',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  searchController.clear();
                                  filteredArticulos = List.from(articulos);
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          filteredArticulos = List.from(articulos);
                        } else {
                          filteredArticulos = articulos
                              .where((a) =>
                                  a.nombre
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  a.tipo.displayName
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  a.talla
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                              .toList();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Lista de artículos
                  Expanded(
                    child: filteredArticulos.isEmpty
                        ? const Center(
                            child: Text('No se encontraron artículos'),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredArticulos.length,
                            itemBuilder: (context, index) {
                              final articulo = filteredArticulos[index];
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selected),
                child: Text('Aceptar (${selected.length})'),
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
      total += traje.precioVenta;
    }
    for (final articulo in _articulosSeleccionados) {
      total += articulo.precioVenta;
    }
    _montoController.text = total.toStringAsFixed(2);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dniController.text.isEmpty || _nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete los datos del cliente')),
      );
      return;
    }

    if (_articulosSeleccionados.isEmpty && _trajesSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar al menos un artículo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Si el cliente no existe, crear uno nuevo
      String clienteId;
      if (_clienteEncontrado == null || _clienteEncontrado!.id.isEmpty) {
        final nuevoCliente = await ClientesService.create({
          'dni': _dniController.text,
          'nombre_completo': _nombreController.text,
          'telefono': _telefonoController.text,
          'correo': '',
        });
        clienteId = nuevoCliente.id;
        // Actualizar lista de clientes
        await context.read<ClientesProvider>().fetchClientes();
      } else {
        clienteId = _clienteEncontrado!.id;
      }

      final data = {
        'cliente_id': clienteId,
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
            // Datos del Cliente
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Datos del Cliente',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dniController,
                      decoration: InputDecoration(
                        labelText: 'DNI *',
                        border: const OutlineInputBorder(),
                        suffixIcon: _buscandoCliente
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : _clienteEncontrado != null
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : null,
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      onChanged: (value) {
                        if (value.length == 8) {
                          _buscarClientePorDNI(value);
                        } else {
                          setState(() {
                            _clienteEncontrado = null;
                            _nombreController.clear();
                            _telefonoController.clear();
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el DNI';
                        }
                        if (value.length != 8) {
                          return 'El DNI debe tener 8 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo *',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el nombre completo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonoController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 9,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El teléfono es obligatorio';
                        }
                        if (value.length != 9) {
                          return 'El teléfono debe tener 9 dígitos';
                        }
                        if (!value.startsWith('9')) {
                          return 'El teléfono debe empezar con 9';
                        }
                        return null;
                      },
                    ),
                    if (_clienteEncontrado != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 16, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Cliente existente en el sistema',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
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
                          subtitle: Text('S/ ${traje.precioVenta}'),
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
                    leading:
                        const Icon(Icons.shopping_cart, color: Colors.green),
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
