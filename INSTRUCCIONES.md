# 📝 INSTRUCCIONES INMEDIATAS - PENGUIN TERNOS

## 🎯 LO QUE DEBES HACER AHORA (Paso a Paso)

### 1️⃣ Desplegar Backend en Render (5 minutos)

1. **Abrir Render:**
   - Ve a: https://dashboard.render.com/
   - Inicia sesión con GitHub

2. **Crear Servicio:**
   - Clic en **"New +"** → **"Web Service"**
   - Conectar repositorio: `alquiler-ternos-backend`
   - Clic en **"Connect"**

3. **Configurar:**
   ```
   Name: penguin-ternos-api
   Region: Oregon
   Branch: main
   Root Directory: backend
   Runtime: Node
   Build Command: npm install
   Start Command: npm start
   Plan: Free (o Starter si quieres que esté siempre activo)
   ```

4. **Agregar Variables de Entorno:**
   - Scroll hasta "Environment Variables"
   - Agregar estas 3 variables:

   ```
   NODE_ENV=production
   PORT=3000
   SUPABASE_URL=https://hqqprbxhfljarfptzsdb.supabase.co
   SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhxcXByYnhoZmxqYXJmcHR6c2RiIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MzIzOTMzNCwiZXhwIjoyMDc4ODE1MzM0fQ.KKxzmxIJRYpfUT4PnD9WvLmBNn1OGoQHde9ZkjNst0s
   ```

5. **Deploy:**
   - Clic en **"Create Web Service"**
   - Espera 2-3 minutos mientras despliega
   - ✅ Cuando termine, verás "Live" en verde

6. **Copiar URL:**
   - En la parte superior verás tu URL, ejemplo:
   ```
   https://penguin-ternos-api.onrender.com
   ```
   - **¡COPIA ESTA URL!** La necesitas para el siguiente paso

---

### 2️⃣ Actualizar URL en Flutter (1 minuto)

1. **Abrir archivo:**
   ```
   flutter_app/lib/config/api_constants.dart
   ```

2. **Cambiar esta línea:**
   ```dart
   static const String baseUrl =
       'https://alquiler-ternos-backend.onrender.com/api';
   ```

   **POR (con tu URL real de Render):**
   ```dart
   static const String baseUrl =
       'https://TU-URL-DE-RENDER.onrender.com/api';
   ```

3. **Guardar archivo** (Ctrl + S)

---

### 3️⃣ Verificar Supabase (2 minutos)

1. **Ir a Supabase:**
   - https://supabase.com/dashboard
   - Abrir tu proyecto

2. **Verificar Tablas:**
   - Clic en **"Table Editor"** (ícono de tabla)
   - Debes ver estas tablas:
     - ✅ clientes
     - ✅ articulos
     - ✅ trajes
     - ✅ alquileres
     - ✅ ventas
     - ✅ citas
     - ✅ configuracion

3. **Si NO existen las tablas:**
   - Clic en **"SQL Editor"** → **"New Query"**
   - Abrir archivo: `backend/database/schema.sql`
   - Copiar TODO el contenido
   - Pegar en Supabase
   - Clic en **"Run"**

---

### 4️⃣ Probar la App (1 minuto)

1. **En la terminal:**
   ```powershell
   cd "c:\PENGUIN TERNOS\flutter_app"
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Primera vez:**
   - Aparecerá "Conectando con el servidor..."
   - Si usas Free tier de Render, espera 30-60 segundos
   - El servidor está "despertando"

3. **Verificar que funcione:**
   - ✅ Dashboard carga sin quedarse en loading infinito
   - ✅ Se ven los 4 botones (ALQUILERES, VENTAS, INVENTARIO, CITAS)
   - ✅ Puedes navegar entre las pantallas

---

## ⚠️ IMPORTANTE

### Si la App se Queda en Loading:

1. **Verificar URL del backend:**
   - Asegúrate de que cambiaste la URL en `api_constants.dart`
   - La URL debe terminar en `/api`

2. **Verificar que Render esté activo:**
   - Abre en navegador: `https://TU-URL.onrender.com/health`
   - Debe mostrar: `{"status":"OK",...}`

3. **Si usas Free Tier:**
   - El servidor se duerme después de 15 minutos
   - Primera request tarda 30-60 segundos en despertar
   - Es NORMAL que tarde la primera vez

### Si ves "Error al conectar":

1. Verifica que las variables de entorno estén bien en Render
2. Revisa los logs en Render Dashboard → Tu servicio → Logs
3. Verifica que Supabase tenga las tablas creadas

---

## 🎉 ¿Todo Funcionando?

Si la app carga correctamente, ¡felicidades! Ahora puedes:

✅ Ver el dashboard
✅ Navegar por las 4 pantallas principales
✅ Ver inventario (vacío por ahora)
✅ Agregar artículos y trajes
✅ Gestionar clientes
✅ Crear citas

---

## 📞 Checklist Final

Marca cuando completes cada paso:

- [ ] Backend desplegado en Render
- [ ] URL copiada de Render
- [ ] URL actualizada en `api_constants.dart`
- [ ] Tablas verificadas en Supabase
- [ ] App Flutter ejecutándose
- [ ] Dashboard carga correctamente
- [ ] Los 4 botones principales funcionan

---

## 🚀 Siguiente Fase

Una vez que todo funcione, tendrás que:

1. Agregar datos de prueba (artículos, trajes, clientes)
2. Probar flujo completo de alquiler
3. Probar ventas
4. Probar reportes PDF

**Pero primero, ¡asegúrate de que la conexión funcione!**

---

## 💡 Tip Final

**Si usas Free Tier de Render:**
- La primera request SIEMPRE tarda 30-60 segundos
- Es completamente NORMAL
- Para evitar esto, usa el plan Starter ($7/mes)
- O mantén el backend activo con un servicio de ping cada 10 minutos

---

**¿Listo? ¡Manos a la obra! 🚀**

Si algo no funciona, revisa los logs de Render y verifica que todas las variables de entorno estén correctas.
