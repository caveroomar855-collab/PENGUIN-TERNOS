import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/trajes_provider.dart';

class NuevoTrajeScreen extends StatefulWidget {
  const NuevoTrajeScreen({Key? key}) : super(key: key);

  @override
  State<NuevoTrajeScreen> createState() => _NuevoTrajeScreenState();
}

class _NuevoTrajeScreenState extends State<NuevoTrajeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioAlquilerController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _cantidadController = TextEditingController(text: '1');

  // Controladores para los 4 artículos del traje
  final Map<String, Map<String, TextEditingController>> _articulosControllers =
      {
    'saco': {
      'nombre': TextEditingController(),
      'talla': TextEditingController(),
      'precioAlquiler': TextEditingController(),
      'precioVenta': TextEditingController(),
      'cantidad': TextEditingController(text: '1'),
    },
    'pantalon': {
      'nombre': TextEditingController(),
      'talla': TextEditingController(),
      'precioAlquiler': TextEditingController(),
      'precioVenta': TextEditingController(),
      'cantidad': TextEditingController(text: '1'),
    },
    'camisa': {
      'nombre': TextEditingController(),
      'talla': TextEditingController(),
      'precioAlquiler': TextEditingController(),
      'precioVenta': TextEditingController(),
      'cantidad': TextEditingController(text: '1'),
    },
    'zapatos': {
      'nombre': TextEditingController(),
      'talla': TextEditingController(),
      'precioAlquiler': TextEditingController(),
      'precioVenta': TextEditingController(),
      'cantidad': TextEditingController(text: '1'),
    },
  };

  bool _cantidadPersonalizada = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioAlquilerController.dispose();
    _precioVentaController.dispose();
    _cantidadController.dispose();
    _articulosControllers.forEach((_, controllers) {
      controllers.forEach((_, controller) => controller.dispose());
    });
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Preparar datos del traje
      final trajeData = {
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'precio_alquiler': double.parse(_precioAlquilerController.text),
        'precio_venta': double.parse(_precioVentaController.text),
        'cantidad_predefinida':
            _cantidadPersonalizada ? null : int.parse(_cantidadController.text),
        'personalizar_cantidades': _cantidadPersonalizada,
        'articulos': [
          {
            'tipo': 'saco',
            'nombre': _articulosControllers['saco']!['nombre']!.text.trim(),
            'talla': _articulosControllers['saco']!['talla']!.text.trim(),
            'precio_alquiler': double.parse(
                _articulosControllers['saco']!['precioAlquiler']!.text),
            'precio_venta': double.parse(
                _articulosControllers['saco']!['precioVenta']!.text),
            'cantidad': _cantidadPersonalizada
                ? int.parse(_articulosControllers['saco']!['cantidad']!.text)
                : int.parse(_cantidadController.text),
          },
          {
            'tipo': 'pantalon',
            'nombre': _articulosControllers['pantalon']!['nombre']!.text.trim(),
            'talla': _articulosControllers['pantalon']!['talla']!.text.trim(),
            'precio_alquiler': double.parse(
                _articulosControllers['pantalon']!['precioAlquiler']!.text),
            'precio_venta': double.parse(
                _articulosControllers['pantalon']!['precioVenta']!.text),
            'cantidad': _cantidadPersonalizada
                ? int.parse(
                    _articulosControllers['pantalon']!['cantidad']!.text)
                : int.parse(_cantidadController.text),
          },
          {
            'tipo': 'camisa',
            'nombre': _articulosControllers['camisa']!['nombre']!.text.trim(),
            'talla': _articulosControllers['camisa']!['talla']!.text.trim(),
            'precio_alquiler': double.parse(
                _articulosControllers['camisa']!['precioAlquiler']!.text),
            'precio_venta': double.parse(
                _articulosControllers['camisa']!['precioVenta']!.text),
            'cantidad': _cantidadPersonalizada
                ? int.parse(_articulosControllers['camisa']!['cantidad']!.text)
                : int.parse(_cantidadController.text),
          },
          {
            'tipo': 'zapatos',
            'nombre': _articulosControllers['zapatos']!['nombre']!.text.trim(),
            'talla': _articulosControllers['zapatos']!['talla']!.text.trim(),
            'precio_alquiler': double.parse(
                _articulosControllers['zapatos']!['precioAlquiler']!.text),
            'precio_venta': double.parse(
                _articulosControllers['zapatos']!['precioVenta']!.text),
            'cantidad': _cantidadPersonalizada
                ? int.parse(_articulosControllers['zapatos']!['cantidad']!.text)
                : int.parse(_cantidadController.text),
          },
        ],
      };

      // Llamar al provider para crear el traje
      await context.read<TrajesProvider>().addTraje(trajeData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Traje agregado correctamente'),
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

  Widget _buildArticuloCard(String tipo, IconData icon, String label) {
    final controllers = _articulosControllers[tipo]!;

    return Card(
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: controllers['nombre'],
                  decoration: InputDecoration(
                    labelText: 'Nombre del $label *',
                    hintText: 'Ej: $label Negro',
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controllers['talla'],
                        decoration: const InputDecoration(
                          labelText: 'Talla *',
                          hintText: 'M, L, 42...',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_cantidadPersonalizada) ...[
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: controllers['cantidad'],
                          decoration: const InputDecoration(
                            labelText: 'Cant. *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Req.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controllers['precioAlquiler'],
                        decoration: const InputDecoration(
                          labelText: 'P. Alquiler *',
                          prefixText: 'S/ ',
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
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: controllers['precioVenta'],
                        decoration: const InputDecoration(
                          labelText: 'P. Venta *',
                          prefixText: 'S/ ',
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
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Traje'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Información del traje
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Traje',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Traje *',
                        hintText: 'Ej: Traje Ejecutivo Negro',
                        prefixIcon: Icon(Icons.checkroom),
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
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (Opcional)',
                        hintText: 'Detalles adicionales del traje',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _precioAlquilerController,
                            decoration: const InputDecoration(
                              labelText: 'Precio Alquiler Total *',
                              prefixText: 'S/ ',
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
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _precioVentaController,
                            decoration: const InputDecoration(
                              labelText: 'Precio Venta Total *',
                              prefixText: 'S/ ',
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
                    if (!_cantidadPersonalizada)
                      TextFormField(
                        controller: _cantidadController,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad Predefinida *',
                          hintText: '1',
                          helperText: 'Misma cantidad para los 4 artículos',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La cantidad es requerida';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Personalizar cantidades por artículo'),
                      value: _cantidadPersonalizada,
                      onChanged: (value) {
                        setState(() => _cantidadPersonalizada = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Artículos del traje
            Text(
              'Artículos del Traje (4 piezas)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildArticuloCard('saco', Icons.dry_cleaning, 'Saco'),
            const SizedBox(height: 8),
            _buildArticuloCard('pantalon', Icons.downhill_skiing, 'Pantalón'),
            const SizedBox(height: 8),
            _buildArticuloCard('camisa', Icons.checkroom, 'Camisa'),
            const SizedBox(height: 8),
            _buildArticuloCard('zapatos', Icons.shopping_bag, 'Zapatos'),
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
                      backgroundColor: Colors.orange,
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
                        : const Text('Guardar Traje'),
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
