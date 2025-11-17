import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clientes_provider.dart';
import '../models/cliente.dart';
import '../services/clientes_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({Key? key}) : super(key: key);

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _searchController = TextEditingController();
  List<Cliente> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientesProvider>().loadClientes();
    });
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);
    final results =
        await context.read<ClientesProvider>().searchClientes(query);
    setState(() {
      _searchResults = results;
    });
  }

  Future<void> _mostrarPapelera() async {
    await showDialog(
      context: context,
      builder: (context) => const _PapeleraDialog(),
    );
    // Recargar clientes al cerrar papelera
    if (mounted) {
      context.read<ClientesProvider>().loadClientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Papelera',
            onPressed: () => _mostrarPapelera(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ClientesProvider>().loadClientes(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o DNI',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : const SizedBox.shrink(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _isSearching ? _buildSearchResults() : _buildClientesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNuevoClienteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildClientesList() {
    return Consumer<ClientesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.clientes.isEmpty) {
          return const Center(
            child: Text('No hay clientes registrados'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: provider.clientes.length,
          itemBuilder: (context, index) {
            final cliente = provider.clientes[index];
            return _buildClienteCard(cliente);
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('No se encontraron resultados'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final cliente = _searchResults[index];
        return _buildClienteCard(cliente);
      },
    );
  }

  Widget _buildClienteCard(Cliente cliente) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(cliente.nombreCompleto[0].toUpperCase()),
        ),
        title: Text(cliente.nombreCompleto),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DNI: ${cliente.dni}'),
            Text('Tel: ${cliente.telefono}'),
            if (cliente.correo != null) Text('Email: ${cliente.correo}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditarClienteDialog(cliente),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmarEliminar(cliente),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Está seguro de eliminar a ${cliente.nombreCompleto}?'),
            const SizedBox(height: 12),
            const Text(
              'Advertencia: No se puede eliminar un cliente con citas pendientes.',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await ClientesService.delete(cliente.id);
        await context.read<ClientesProvider>().loadClientes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showNuevoClienteDialog() {
    final nombreController = TextEditingController();
    final dniController = TextEditingController();
    final telefonoController = TextEditingController();
    final emailController = TextEditingController();
    final direccionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Cliente'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dniController,
                  decoration: const InputDecoration(
                    labelText: 'DNI *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El DNI es obligatorio';
                    }
                    if (value.length != 8) {
                      return 'El DNI debe tener 8 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono *',
                    border: OutlineInputBorder(),
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final data = {
                'nombre_completo': nombreController.text.trim(),
                'dni': dniController.text.trim(),
                'telefono': telefonoController.text.trim(),
                'correo': emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
                'direccion': direccionController.text.trim().isEmpty
                    ? null
                    : direccionController.text.trim(),
              };

              final success =
                  await context.read<ClientesProvider>().createCliente(data);

              if (mounted) {
                Navigator.pop(context);

                if (success) {
                  await context.read<ClientesProvider>().loadClientes();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Cliente creado exitosamente'
                        : 'Error al crear cliente'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  void _showEditarClienteDialog(Cliente cliente) {
    final nombreController =
        TextEditingController(text: cliente.nombreCompleto);
    final dniController = TextEditingController(text: cliente.dni);
    final telefonoController = TextEditingController(text: cliente.telefono);
    final emailController = TextEditingController(text: cliente.correo ?? '');
    final direccionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Cliente'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dniController,
                  decoration: const InputDecoration(
                    labelText: 'DNI *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El DNI es obligatorio';
                    }
                    if (value.length != 8) {
                      return 'El DNI debe tener 8 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono *',
                    border: OutlineInputBorder(),
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              // Verificar si el DNI cambió
              final dniCambiado = dniController.text.trim() != cliente.dni;

              if (dniCambiado) {
                final confirmarCambio = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Advertencia'),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Está a punto de cambiar el DNI del cliente.'),
                        SizedBox(height: 8),
                        Text(
                          'Esta acción puede afectar los registros asociados al cliente.',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('¿Desea continuar?'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('CANCELAR'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('CONTINUAR'),
                      ),
                    ],
                  ),
                );

                if (confirmarCambio != true) return;
              }

              final data = {
                'nombre_completo': nombreController.text.trim(),
                'dni': dniController.text.trim(),
                'telefono': telefonoController.text.trim(),
                'correo': emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
                'direccion': direccionController.text.trim().isEmpty
                    ? null
                    : direccionController.text.trim(),
              };

              Navigator.pop(context);
              final success = await context
                  .read<ClientesProvider>()
                  .updateCliente(cliente.id, data);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Cliente actualizado exitosamente'
                        : 'Error al actualizar cliente'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar la papelera de clientes
class _PapeleraDialog extends StatefulWidget {
  const _PapeleraDialog();

  @override
  State<_PapeleraDialog> createState() => _PapeleraDialogState();
}

class _PapeleraDialogState extends State<_PapeleraDialog> {
  List<Cliente> _clientesEliminados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPapelera();
  }

  Future<void> _cargarPapelera() async {
    setState(() => _isLoading = true);
    try {
      final clientes = await ClientesService.getPapelera();
      setState(() {
        _clientesEliminados = clientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar papelera: $e')),
        );
      }
    }
  }

  Future<void> _restaurarCliente(Cliente cliente) async {
    try {
      await ClientesService.restore(cliente.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cliente.nombreCompleto} restaurado'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _cargarPapelera();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al restaurar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarPermanentemente(Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Permanentemente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '¿Está seguro de eliminar permanentemente a ${cliente.nombreCompleto}?'),
            const SizedBox(height: 12),
            const Text(
              'Esta acción NO se puede deshacer.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await ClientesService.deletePermanently(cliente.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente eliminado permanentemente'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        _cargarPapelera();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.delete, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Papelera',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_clientesEliminados.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'La papelera está vacía',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _clientesEliminados.length,
                  itemBuilder: (context, index) {
                    final cliente = _clientesEliminados[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Text(
                            cliente.nombreCompleto[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(cliente.nombreCompleto),
                        subtitle: Text(
                            'DNI: ${cliente.dni}\nTeléfono: ${cliente.telefono}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.restore,
                                  color: Colors.green),
                              tooltip: 'Restaurar',
                              onPressed: () => _restaurarCliente(cliente),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever,
                                  color: Colors.red),
                              tooltip: 'Eliminar permanentemente',
                              onPressed: () =>
                                  _eliminarPermanentemente(cliente),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
