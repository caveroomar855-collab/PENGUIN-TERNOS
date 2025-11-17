import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/citas_provider.dart';
import '../providers/clientes_provider.dart';
import '../models/cliente.dart';
import '../services/clientes_service.dart';

class NuevaCitaScreen extends StatefulWidget {
  const NuevaCitaScreen({Key? key}) : super(key: key);

  @override
  State<NuevaCitaScreen> createState() => _NuevaCitaScreenState();
}

class _NuevaCitaScreenState extends State<NuevaCitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _descripcionController = TextEditingController();

  String _tipoCitaSeleccionado = 'pruebas';
  DateTime _fechaSeleccionada = DateTime.now();
  TimeOfDay _horaSeleccionada = TimeOfDay.now();
  bool _isLoading = false;
  bool _clienteExistente = false;
  Cliente? _clienteEncontrado;

  final List<Map<String, dynamic>> _tiposCita = [
    {
      'value': 'pruebas',
      'label': 'Pruebas',
      'icon': Icons.science,
      'color': Colors.orange
    },
    {
      'value': 'toma_medidas',
      'label': 'Toma de Medidas',
      'icon': Icons.straighten,
      'color': Colors.green
    },
    {
      'value': 'alquiler',
      'label': 'Alquiler',
      'icon': Icons.card_travel,
      'color': Colors.blue
    },
    {
      'value': 'otros',
      'label': 'Otros',
      'icon': Icons.more_horiz,
      'color': Colors.grey
    },
  ];

  @override
  void dispose() {
    _dniController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _buscarCliente() async {
    final dni = _dniController.text.trim();
    if (dni.length != 8) return;

    setState(() => _isLoading = true);

    try {
      // Buscar cliente por DNI
      final cliente = await ClientesService.getByDni(dni);

      if (cliente != null) {
        setState(() {
          _clienteEncontrado = cliente;
          _clienteExistente = true;
          _nombreController.text = cliente.nombreCompleto;
          _telefonoController.text = cliente.telefono;
          _correoController.text = cliente.correo ?? '';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente encontrado'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() {
          _clienteEncontrado = null;
          _clienteExistente = false;
          _nombreController.clear();
          _telefonoController.clear();
          _correoController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fecha != null) {
      setState(() => _fechaSeleccionada = fecha);
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
    );

    if (hora != null) {
      setState(() => _horaSeleccionada = hora);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String clienteId;

      // Si el cliente no existe, crearlo primero
      if (_clienteEncontrado == null) {
        final clienteData = {
          'dni': _dniController.text.trim(),
          'nombre_completo': _nombreController.text.trim(),
          'telefono': _telefonoController.text.trim(),
          'correo': _correoController.text.trim().isEmpty
              ? null
              : _correoController.text.trim(),
        };

        final nuevoCliente = await ClientesService.create(clienteData);
        clienteId = nuevoCliente.id;
      } else {
        clienteId = _clienteEncontrado!.id;
      }

      // Combinar fecha y hora
      final fechaHora = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
        _horaSeleccionada.hour,
        _horaSeleccionada.minute,
      );

      final data = {
        'cliente_id': clienteId,
        'tipo_cita': _tipoCitaSeleccionado,
        'fecha_hora': fechaHora.toIso8601String(),
        'descripcion': _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
      };

      await context.read<CitasProvider>().createCita(data);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita agendada correctamente'),
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
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Cita'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipo de cita
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Cita',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tiposCita.map((tipo) {
                        final isSelected =
                            _tipoCitaSeleccionado == tipo['value'];
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                tipo['icon'],
                                size: 16,
                                color:
                                    isSelected ? Colors.white : tipo['color'],
                              ),
                              const SizedBox(width: 4),
                              Text(tipo['label']),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(
                                  () => _tipoCitaSeleccionado = tipo['value']);
                            }
                          },
                          selectedColor: tipo['color'],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Datos del cliente
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
                      decoration: const InputDecoration(
                        labelText: 'DNI *',
                        hintText: '12345678',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      onChanged: (value) {
                        if (value.length == 8) {
                          _buscarCliente();
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El DNI es requerido';
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
                      decoration: InputDecoration(
                        labelText: 'Nombre Completo *',
                        hintText: 'Juan Pérez García',
                        prefixIcon: const Icon(Icons.person),
                        border: const OutlineInputBorder(),
                        enabled: !_clienteExistente,
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonoController,
                      decoration: InputDecoration(
                        labelText: 'Teléfono *',
                        hintText: '987654321',
                        prefixIcon: const Icon(Icons.phone),
                        border: const OutlineInputBorder(),
                        enabled: !_clienteExistente,
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El teléfono es requerido';
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _correoController,
                      decoration: InputDecoration(
                        labelText: 'Correo (Opcional)',
                        hintText: 'cliente@ejemplo.com',
                        prefixIcon: const Icon(Icons.email),
                        border: const OutlineInputBorder(),
                        enabled: !_clienteExistente,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Correo inválido';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fecha y hora
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha y Hora',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _seleccionarFecha,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(dateFormat.format(_fechaSeleccionada)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _seleccionarHora,
                            icon: const Icon(Icons.access_time),
                            label: Text(_horaSeleccionada.format(context)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Descripción
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descripción',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción Breve (Opcional)',
                        hintText: 'Detalles adicionales de la cita',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
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
                      backgroundColor: Colors.purple,
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
                        : const Text('Agendar Cita'),
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
