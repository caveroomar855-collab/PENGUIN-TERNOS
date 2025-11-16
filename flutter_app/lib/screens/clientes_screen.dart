import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clientes_provider.dart';
import '../models/cliente.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
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
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showEditarClienteDialog(cliente),
        ),
      ),
    );
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El teléfono es obligatorio';
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
                'nombre': nombreController.text.trim(),
                'dni': dniController.text.trim(),
                'telefono': telefonoController.text.trim(),
                'email': emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
                'direccion': direccionController.text.trim().isEmpty
                    ? null
                    : direccionController.text.trim(),
              };

              Navigator.pop(context);
              final success =
                  await context.read<ClientesProvider>().createCliente(data);

              if (mounted) {
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
                  controller: TextEditingController(text: cliente.dni),
                  decoration: const InputDecoration(
                    labelText: 'DNI',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El teléfono es obligatorio';
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
                'nombre': nombreController.text.trim(),
                'telefono': telefonoController.text.trim(),
                'email': emailController.text.trim().isEmpty
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
