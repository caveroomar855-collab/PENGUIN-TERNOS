# SISTEMA DE ESTADOS Y MANTENIMIENTO DE ARTÍCULOS

## PASOS PARA IMPLEMENTAR:

### 1. EJECUTAR EN SUPABASE (SQL Editor):

#### Paso 1: Migración principal
```sql
-- Copiar y ejecutar TODO el contenido de:
backend/database/migration_estados_articulos.sql
```

#### Paso 2: Funciones auxiliares
```sql
-- Copiar y ejecutar TODO el contenido de:
backend/database/funciones_estados_articulos.sql
```

### 2. BACKEND - Actualizar controlador de alquileres

El archivo `backend/src/controllers/alquileres.controller.js` necesita:

- Modificar función `devolver()` para recibir array de estados por artículo
- Agregar lógica para procesar cada artículo individualmente:
  * Si está "completo" → 24h mantenimiento
  * Si está "dañado" → 72h mantenimiento  
  * Si está "perdido" → marcar como perdido permanentemente

### 3. FRONTEND - Pantalla de devolución

Crear nuevo diálogo de devolución que muestre:

**Para cada artículo/traje en el alquiler:**
- Nombre del artículo
- Dropdown para seleccionar estado:
  * ✅ Completo (24h mantenimiento)
  * ⚠️ Dañado (72h mantenimiento)
  * ❌ Perdido
- Campo opcional de observaciones por artículo

**Botón final:** "Devolver Alquiler"

### 4. INVENTARIO - Filtros por estado

Agregar tabs o filtros en pantalla de inventario:
- 🟢 Disponibles
- 🔵 Alquilados  
- 🟡 En Mantenimiento (con contador de tiempo restante)
- 🔴 Perdidos

## ARCHIVOS CREADOS:

✅ migration_estados_articulos.sql
✅ funciones_estados_articulos.sql  
✅ Modelos Flutter actualizados (articulo.dart, traje.dart)

## ARCHIVOS QUE NECESITAN ACTUALIZACIÓN:

⏳ backend/src/controllers/alquileres.controller.js
⏳ flutter_app/lib/screens/alquileres_screen.dart (diálogo devolver)
⏳ flutter_app/lib/screens/inventario_screen.dart (filtros)
⏳ flutter_app/lib/providers/alquileres_provider.dart
⏳ flutter_app/lib/services/alquileres_service.dart

¿Quieres que continue con la implementación completa del backend y frontend?
