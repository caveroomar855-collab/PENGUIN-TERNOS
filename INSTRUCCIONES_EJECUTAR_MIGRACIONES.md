# 🚀 INSTRUCCIONES PARA EJECUTAR MIGRACIONES SQL

## ⚠️ IMPORTANTE - DEBES HACER ESTO PRIMERO

El backend ya está actualizado y desplegado en Render, **PERO** necesitas ejecutar 2 archivos SQL en tu base de datos Supabase para que el sistema funcione correctamente.

---

## 📋 PASO 1: Ejecutar migración de estados

1. Ve a tu proyecto de Supabase: https://supabase.com/dashboard
2. Selecciona tu proyecto
3. En el menú lateral, haz clic en **SQL Editor**
4. Haz clic en **"+ New Query"**
5. Copia y pega **TODO** el contenido del archivo: `backend/database/migration_estados_articulos.sql`
6. Haz clic en **RUN** (botón verde)
7. Verifica que aparezca: "Success. No rows returned"

### ¿Qué hace esta migración?

- Crea el tipo ENUM `estado_articulo` con: disponible, alquilado, mantenimiento, perdido
- Agrega columnas `estado` y `fecha_fin_mantenimiento` a tablas `articulos` y `trajes`
- Crea tabla `alquiler_articulos_detalle` para historial de devoluciones
- Actualiza estados existentes (disponible para todo lo que no está alquilado)

---

## 📋 PASO 2: Ejecutar funciones de mantenimiento

1. Repite el proceso pero con: `backend/database/funciones_estados_articulos.sql`
2. Haz clic en **"+ New Query"** de nuevo
3. Copia y pega **TODO** el contenido
4. Haz clic en **RUN**
5. Verifica que aparezca: "Success. No rows returned"

### ¿Qué hace este archivo?

Crea 4 funciones SQL:
- `poner_en_mantenimiento()` - Pone artículo en mantenimiento por 24h o 72h
- `marcar_articulo_perdido()` - Marca artículo como perdido permanentemente
- `liberar_articulos_mantenimiento()` - Libera automáticamente artículos cuando termina mantenimiento
- `obtener_inventario_por_estado()` - Obtiene conteo de inventario por estado

---

## ✅ VERIFICAR QUE TODO FUNCIONA

Después de ejecutar ambos archivos, ejecuta esta consulta para verificar:

```sql
-- Verificar que se crearon las columnas
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'articulos' 
AND column_name IN ('estado', 'fecha_fin_mantenimiento');

-- Verificar estados de artículos
SELECT estado, COUNT(*) as total 
FROM articulos 
GROUP BY estado;

-- Verificar que exista la tabla de detalles
SELECT table_name 
FROM information_schema.tables 
WHERE table_name = 'alquiler_articulos_detalle';
```

Deberías ver:
- 2 columnas (estado, fecha_fin_mantenimiento)
- Conteo de artículos por estado
- La tabla alquiler_articulos_detalle existe

---

## 🎯 AHORA SÍ PUEDES PROBAR

Una vez ejecutadas las migraciones:

1. ✅ El backend ya está listo (commit 2298118 ya está en Render)
2. ✅ El Flutter ya tiene el UI de devolución con estados individuales
3. ✅ Ahora necesito actualizar el inventario con filtros de estado

---

## ⚡ LO QUE FALTA POR HACER

Después de que ejecutes las migraciones, YO voy a:
- [ ] Actualizar inventario_screen.dart con tabs por estado (Disponibles / Alquilados / Mantenimiento / Perdidos)
- [ ] Agregar botón para liberar artículos de mantenimiento
- [ ] Probar el flujo completo de devolución

---

## 🆘 SI HAY PROBLEMAS

Si alguna migración falla:
1. Copia el ERROR completo que aparece
2. Dímelo y lo arreglo inmediatamente
3. NO borres las tablas manualmente

---

## 📝 RESUMEN RÁPIDO

```bash
PASO 1: Ejecutar migration_estados_articulos.sql ✅
PASO 2: Ejecutar funciones_estados_articulos.sql ✅
PASO 3: Verificar con queries de arriba ✅
PASO 4: Decirme "ya ejecuté las migraciones" ✅
PASO 5: Yo actualizo el inventario y probamos todo ✅
```

**¿Ya ejecutaste las 2 migraciones?** Dime si tuviste algún error o si todo salió bien.
