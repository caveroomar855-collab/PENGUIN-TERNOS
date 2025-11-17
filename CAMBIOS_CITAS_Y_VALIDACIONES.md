# Cambios Realizados - Módulo de Citas y Validaciones

## Fecha
2024

## Problemas Reportados
1. ❌ Al crear citas no se agregaban a la base de datos
2. ❌ Los campos no se autocompletaban al poner el DNI
3. ❌ No se podía ver cita activa ni el historial de citas
4. ❌ No existía validación para eliminar cliente con cita activa
5. ❌ No había advertencia al cambiar DNI de un cliente
6. ❌ No había advertencia al eliminar un cliente
7. ❌ Los números de teléfono no estaban validados (deben ser 9 dígitos, empezando con 9)

## Soluciones Implementadas

### Backend (Node.js + Express)

#### 1. `backend/src/controllers/citas.controller.js`
**Problema:** Cuando se creaba una cita, el backend no devolvía los datos completos del cliente, causando que se mostrara "N/A" en la interfaz.

**Solución (líneas 96-115):**
```javascript
// Después de insertar la cita, seleccionar con datos completos del cliente
const { data: citaCompleta } = await supabase
  .from('citas')
  .select(`
    *,
    cliente:clientes(*)
  `)
  .eq('id', data[0].id)
  .single();

return res.status(201).json(citaCompleta);
```

#### 2. `backend/src/controllers/clientes.controller.js`

**A. Validación de DNI y Teléfono en CREATE (líneas 71-83):**
```javascript
// Validar formato de DNI (8 dígitos)
if (!/^\d{8}$/.test(dni)) {
  return res.status(400).json({ 
    error: 'El DNI debe tener exactamente 8 dígitos' 
  });
}

// Validar formato de teléfono (9 dígitos, empieza con 9)
if (!/^9\d{8}$/.test(telefono)) {
  return res.status(400).json({ 
    error: 'El teléfono debe tener 9 dígitos y empezar con 9' 
  });
}
```

**B. Validación en UPDATE (líneas 114-128):**
- Mismas validaciones aplicadas al actualizar clientes

**C. Verificación antes de DELETE (líneas 134-158):**
```javascript
// Verificar si el cliente tiene citas pendientes
const { data: citas } = await supabase
  .from('citas')
  .select('id')
  .eq('cliente_id', id)
  .eq('estado', 'pendiente');

if (citas && citas.length > 0) {
  return res.status(400).json({
    error: 'No se puede eliminar un cliente con citas pendientes'
  });
}
```

### Frontend (Flutter)

#### 3. `flutter_app/lib/screens/nueva_cita_screen.dart`

**A. Importaciones añadidas (líneas 1-8):**
```dart
import '../services/clientes_service.dart';
import '../models/cliente.dart';
```

**B. Variable para cliente encontrado (línea 30):**
```dart
Cliente? _clienteEncontrado;
```

**C. Método para buscar cliente por DNI (líneas 57-106):**
```dart
Future<void> _buscarCliente() async {
  final dni = _clienteDniController.text.trim();
  if (dni.isEmpty || dni.length != 8) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('DNI debe tener 8 dígitos')),
    );
    return;
  }

  try {
    final cliente = await ClientesService.getByDni(dni);
    if (cliente != null) {
      setState(() {
        _clienteEncontrado = cliente;
        _clienteNombreController.text = cliente.nombreCompleto;
        _clienteTelefonoController.text = cliente.telefono;
        _clienteEmailController.text = cliente.correo ?? '';
      });
      // Mostrar mensaje de éxito
    } else {
      // Cliente no encontrado, se puede crear uno nuevo
    }
  } catch (e) {
    // Manejo de errores
  }
}
```

**D. Método _guardar() reescrito (líneas 108-175):**
```dart
Future<void> _guardar() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    int clienteId;

    // Si no se encontró un cliente, crear uno nuevo
    if (_clienteEncontrado == null) {
      final nuevoCliente = await ClientesService.create({
        'nombre_completo': _clienteNombreController.text.trim(),
        'dni': _clienteDniController.text.trim(),
        'telefono': _clienteTelefonoController.text.trim(),
        'correo': _clienteEmailController.text.trim().isEmpty
            ? null
            : _clienteEmailController.text.trim(),
      });
      clienteId = nuevoCliente.id;
    } else {
      clienteId = _clienteEncontrado!.id;
    }

    // Crear la cita con cliente_id (no cliente_dni)
    final data = {
      'cliente_id': clienteId,
      'fecha': _fechaController.text,
      'hora': _horaController.text,
      'tipo_cita': _tipoCitaController.text.trim(),
      'notas': _notasController.text.trim().isEmpty
          ? null
          : _notasController.text.trim(),
      'estado': 'pendiente',
    };

    await CitasService.create(data);
    // ... resto del código
  } catch (e) {
    // Manejo de errores
  }
}
```

**E. Validación de teléfono (líneas 347-357):**
```dart
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
```

#### 4. `flutter_app/lib/screens/clientes_screen.dart`

**A. Validación de teléfono en diálogo de CREAR (líneas 268-287):**
```dart
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
```

**B. Validación de teléfono en diálogo de EDITAR:**
- Misma validación aplicada

**C. Advertencia al eliminar cliente (líneas 168-202):**
```dart
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
      // ... botones
    ),
  );
  // ... resto del método
}
```

**D. Advertencia al cambiar DNI (líneas 475-518):**
```dart
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
      // ... botones
    ),
  );

  if (confirmarCambio != true) return;
}
```

## Deployment

### Backend
```bash
cd backend
git add .
git commit -m "Fix: Validaciones de DNI y teléfono + incluir datos completos en citas"
git push
```
✅ **Commit:** 85e49d3
✅ **Auto-deploy en Render:** Activado automáticamente

### Flutter
```bash
cd flutter_app
flutter clean
flutter run
```
✅ **Compilación:** Exitosa
✅ **Instalación en dispositivo 23013PC75G:** Completada

## Resultados Esperados

### ✅ Citas
- Las citas ahora se crean correctamente en la base de datos
- Se envía `cliente_id` en lugar de `cliente_dni`
- El backend devuelve datos completos del cliente
- Los campos se autocompletan al buscar por DNI
- Si el cliente no existe, se crea automáticamente

### ✅ Visualización
- Las citas pendientes se muestran correctamente
- El historial de citas funciona
- Los nombres de clientes se muestran en lugar de "N/A"

### ✅ Validaciones
- DNI: Debe tener exactamente 8 dígitos
- Teléfono: Debe tener 9 dígitos y empezar con 9
- No se puede eliminar un cliente con citas pendientes
- Se muestra advertencia al cambiar DNI
- Se muestra advertencia al eliminar cliente

## Testing Recomendado

1. **Crear cita con cliente existente:**
   - Ingresar DNI de cliente existente
   - Verificar que los campos se autocompleten
   - Guardar y verificar que aparezca en "Pendientes"

2. **Crear cita con cliente nuevo:**
   - Ingresar DNI que no existe
   - Completar datos del nuevo cliente
   - Verificar que se cree el cliente y la cita

3. **Validaciones de teléfono:**
   - Intentar ingresar teléfono con menos de 9 dígitos
   - Intentar ingresar teléfono que no empiece con 9
   - Verificar mensajes de error

4. **Eliminar cliente:**
   - Intentar eliminar cliente con cita pendiente (debe fallar)
   - Verificar mensaje de advertencia
   - Finalizar la cita y luego eliminar (debe funcionar)

5. **Cambiar DNI:**
   - Editar cliente y cambiar su DNI
   - Verificar que aparezca el diálogo de advertencia
   - Confirmar y verificar que se actualice

## Notas Técnicas

- El backend valida en el servidor antes de insertar/actualizar
- El frontend valida en el formulario antes de enviar
- Doble validación asegura integridad de datos
- Los mensajes de error son claros y específicos
- Las advertencias usan colores (naranja) para llamar la atención
