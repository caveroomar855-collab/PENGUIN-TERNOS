# 🚀 ACCIÓN INMEDIATA - RESUELVE EL PROBLEMA EN 5 MINUTOS

## ❌ PROBLEMA
Cuando creas un traje en la app, dice "creado con éxito" pero NO se guarda en Supabase.

## ✅ SOLUCIÓN
Sigue estos 3 pasos **EN ORDEN**:

---

## 📍 PASO 1: Ejecutar SQL en Supabase (2 minutos)

### 1.1 Abrir Supabase
```
https://supabase.com/dashboard
```

### 1.2 Ir al proyecto "hqqprbxhfljarfptzsdb"

### 1.3 Clic en "SQL Editor" (ícono de terminal)

### 1.4 Clic en "New Query"

### 1.5 Abrir este archivo en tu computadora:
```
c:\PENGUIN TERNOS\backend\database\schema_completo.sql
```

### 1.6 Copiar TODO el contenido y pegarlo en Supabase

### 1.7 Clic en "Run" (botón verde) o presionar F5

### 1.8 Esperar a que termine (debe mostrar):
```
✅ Base de datos creada exitosamente
✅ Total de tablas: 10
✅ Configuración inicial insertada
✅ 3 clientes de prueba insertados
```

---

## 📍 PASO 2: Iniciar el Backend (1 minuto)

### 2.1 Abrir PowerShell en Windows

### 2.2 Ejecutar:
```powershell
cd "c:\PENGUIN TERNOS\backend"
npm start
```

### 2.3 Debe mostrar:
```
🚀 Servidor corriendo en puerto 3000
✅ Conectado a Supabase
```

**DEJA ESTA VENTANA ABIERTA** - El servidor debe estar corriendo.

---

## 📍 PASO 3: Probar la App (2 minutos)

### 3.1 Abrir OTRA PowerShell (nueva ventana)

### 3.2 Ejecutar:
```powershell
cd "c:\PENGUIN TERNOS\flutter_app"
flutter run
```

### 3.3 En la app:
1. Ir a **INVENTARIO**
2. Tab **"Trajes"**
3. Clic en botón **"+"** (abajo derecha)
4. Llenar los datos:

   **Traje:**
   - Nombre: Test Traje 1
   - Precio Alquiler: 150
   - Precio Venta: 800
   - Cantidad: 1

   **Expandir cada artículo** y llenar:
   
   **SACO:**
   - Nombre: Saco Negro
   - Talla: L
   - P. Alquiler: 40
   - P. Venta: 200

   **PANTALÓN:**
   - Nombre: Pantalón Negro
   - Talla: L
   - P. Alquiler: 30
   - P. Venta: 150

   **CAMISA:**
   - Nombre: Camisa Blanca
   - Talla: L
   - P. Alquiler: 20
   - P. Venta: 100

   **ZAPATOS:**
   - Nombre: Zapatos Negros
   - Talla: 42
   - P. Alquiler: 25
   - P. Venta: 180

5. Clic en **"Guardar Traje"**

### 3.4 Resultado esperado:
- ✅ Mensaje: "Traje agregado correctamente"
- ✅ Regresa a la lista
- ✅ El traje aparece en la lista

---

## 🔍 VERIFICAR EN SUPABASE

1. Ir a Supabase Dashboard
2. Clic en "Table Editor"
3. Seleccionar tabla **"trajes"**
   - Debe aparecer tu traje
4. Seleccionar tabla **"articulos"**
   - Deben aparecer 4 artículos (saco, pantalón, camisa, zapatos)

---

## 🚨 SI ALGO FALLA

### ⚠️ Backend no inicia
```powershell
cd "c:\PENGUIN TERNOS\backend"
npm install
npm start
```

### ⚠️ Flutter no compila
```powershell
cd "c:\PENGUIN TERNOS\flutter_app"
flutter clean
flutter pub get
flutter run
```

### ⚠️ Error "relation 'trajes' does not exist"
- Regresa al PASO 1 y ejecuta el SQL nuevamente

### ⚠️ Error 401 o 403
- Verifica que el archivo `.env` tenga las credenciales correctas:
```
SUPABASE_URL=https://hqqprbxhfljarfptzsdb.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 🎯 CAMBIOS REALIZADOS

He actualizado estos archivos (ya están listos, no necesitas hacer nada):

1. ✅ `flutter_app/lib/providers/trajes_provider.dart`
   - Agregué método `addTraje()` que llama al servicio real

2. ✅ `flutter_app/lib/screens/nuevo_traje_screen.dart`
   - Ahora envía datos reales a Supabase (antes era simulación)

3. ✅ `backend/database/schema_completo.sql`
   - Esquema completo con DROP tables para reiniciar limpio

4. ✅ `backend/test_traje.js`
   - Script de prueba para verificar conexión (opcional)

---

## ✅ TODO LISTO

Si seguiste los 3 pasos, **ahora puedes crear trajes y se guardarán en Supabase correctamente**.

**¿Funcionó? ¡Perfecto! 🎉**

**¿No funcionó?** Revisa la sección "SI ALGO FALLA" arriba.

---

## 📱 Contacto
Si necesitas ayuda, mándame:
1. Captura de pantalla del error
2. Logs del backend (en la terminal donde hiciste `npm start`)
3. Logs de Flutter (en la terminal donde hiciste `flutter run`)
