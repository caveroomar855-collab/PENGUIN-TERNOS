import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/articulos_provider.dart';

class NuevoArticuloScreen extends StatefulWidget {
  const NuevoArticuloScreen({Key? key}) : super(key: key);

  @override
  State<NuevoArticuloScreen> createState() => _NuevoArticuloScreenState();
}

class _NuevoArticuloScreenState extends State<NuevoArticuloScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _tallaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioAlquilerController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _cantidadController = TextEditingController(text: '1');

  String _tipoSeleccionado = 'saco';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _tipos = [
    {'value': 'saco', 'label': 'Saco', 'icon': Icons.dry_cleaning},
    {'value': 'pantalon', 'label': 'Pantalón', 'icon': Icons.accessibility},
    {'value': 'camisa', 'label': 'Camisa', 'icon': Icons.checkroom},
    {'value': 'zapatos', 'label': 'Zapatos', 'icon': Icons.shopping_bag},
    {'value': 'corbata', 'label': 'Corbata', 'icon': Icons.style},
    {'value': 'chaleco', 'label': 'Chaleco', 'icon': Icons.checkroom},
    {'value': 'otro', 'label': 'Otro', 'icon': Icons.more_horiz},
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _tallaController.dispose();
    _descripcionController.dispose();
    _precioAlquilerController.dispose();
    _precioVentaController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'nombre': _nombreController.text.trim(),
        'tipo': _tipoSeleccionado,
        'talla': _tallaController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'precio_alquiler': double.parse(_precioAlquilerController.text),
        'precio_venta': double.parse(_precioVentaController.text),
        'cantidad': int.parse(_cantidadController.text),
        'cantidad_disponible': int.parse(_cantidadController.text),
        'cantidad_alquilada': 0,
        'cantidad_mantenimiento': 0,
        'estado': 'disponible',
      };

      await context.read<ArticulosProvider>().addArticulo(data);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artículo agregado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
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
        title: const Text('Nuevo Artículo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipo de artículo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Artículo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tipos.map((tipo) {
                        final isSelected = _tipoSeleccionado == tipo['value'];
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                tipo['icon'],
                                size: 16,
                                color: isSelected ? Colors.white : null,
                              ),
                              const SizedBox(width: 4),
                              Text(tipo['label']),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _tipoSeleccionado = tipo['value']);
                            }
                          },
                          selectedColor: Colors.blue,
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

            // Información básica
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Básica',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Artículo *',
                        hintText: 'Ej: Saco Negro Slim Fit',
                        prefixIcon: Icon(Icons.label),
                        border: OutlineInputBorder(),
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
                      controller: _tallaController,
                      decoration: const InputDecoration(
                        labelText: 'Talla *',
                        hintText: 'Ej: M, L, 42, etc.',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La talla es requerida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (Opcional)',
                        hintText: 'Detalles adicionales del artículo',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Precios
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precios',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _precioAlquilerController,
                            decoration: const InputDecoration(
                              labelText: 'Precio Alquiler *',
                              hintText: '0.00',
                              prefixText: 'S/ ',
                              prefixIcon: Icon(Icons.attach_money),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Número inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _precioVentaController,
                            decoration: const InputDecoration(
                              labelText: 'Precio Venta *',
                              hintText: '0.00',
                              prefixText: 'S/ ',
                              prefixIcon: Icon(Icons.shopping_cart),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Número inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cantidad
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cantidad',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cantidadController,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad *',
                        hintText: '1',
                        prefixIcon: Icon(Icons.inventory_2),
                        border: OutlineInputBorder(),
                        helperText:
                            'Número de unidades a agregar al inventario',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La cantidad es requerida';
                        }
                        final cantidad = int.tryParse(value);
                        if (cantidad == null || cantidad <= 0) {
                          return 'Debe ser mayor a 0';
                        }
                        return null;
                      },
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
                        : const Text('Guardar Artículo'),
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
