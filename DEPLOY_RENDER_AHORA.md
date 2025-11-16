# 🚀 DESPLEGAR BACKEND EN RENDER - PASO A PASO

## ✅ Tu código ya está listo y subido a GitHub

Commit: `ee36417` - Backend actualizado con schema y scripts de prueba

---

## 📍 PASO 1: Ir a Render (2 minutos)

### 1.1 Abrir Render Dashboard
```
https://dashboard.render.com/
```

### 1.2 Iniciar sesión
- Si no tienes cuenta, créala con GitHub (es gratis)
- Si ya tienes cuenta, inicia sesión

---

## 📍 PASO 2: Crear Web Service (3 minutos)

### 2.1 Crear nuevo servicio
- Clic en **"New +"** (botón azul arriba derecha)
- Seleccionar **"Web Service"**

### 2.2 Conectar repositorio
- Buscar: `alquiler-ternos-backend`
- Clic en **"Connect"** al lado del repositorio

### 2.3 Configurar el servicio

**Name:**
```
penguin-ternos-api
```

**Region:**
```
Oregon (US West)
```

**Branch:**
```
main
```

**Root Directory:**
```
backend
```

**Runtime:**
```
Node
```

**Build Command:**
```
npm install
```

**Start Command:**
```
npm start
```

**Instance Type:**
- **Free** (se duerme después de 15 minutos sin uso, tarda 30-60s en despertar)
- **Starter ($7/mes)** (siempre activo, recomendado para producción)

---

## 📍 PASO 3: Agregar Variables de Entorno (2 minutos)

Scroll hacia abajo hasta **"Environment Variables"** y agregar:

### Variable 1:
- **Key:** `NODE_ENV`
- **Value:** `production`

### Variable 2:
- **Key:** `PORT`
- **Value:** `3000`

### Variable 3:
- **Key:** `SUPABASE_URL`
- **Value:** `https://hqqprbxhfljarfptzsdb.supabase.co`

### Variable 4:
- **Key:** `SUPABASE_SERVICE_KEY`
- **Value:** 
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhxcXByYnhoZmxqYXJmcHR6c2RiIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MzIzOTMzNCwiZXhwIjoyMDc4ODE1MzM0fQ.KKxzmxIJRYpfUT4PnD9WvLmBNn1OGoQHde9ZkjNst0s
```

---

## 📍 PASO 4: Deploy (5-10 minutos)

### 4.1 Iniciar despliegue
- Clic en **"Create Web Service"** (botón azul abajo)
- Esperar mientras Render despliega tu backend

### 4.2 Monitorear el proceso
Verás logs en tiempo real:
```
==> Cloning from https://github.com/caveroomar855-collab/alquiler-ternos-backend...
==> Checking out commit ee36417...
==> Running 'npm install'
==> Running 'npm start'
==> Your service is live 🎉
```

### 4.3 Verificar que esté activo
- Cuando termine, verás **"Live"** en verde arriba
- Tu URL será: `https://penguin-ternos-api.onrender.com`

---

## 📍 PASO 5: Probar el Backend (1 minuto)

### 5.1 Probar Health Check
Abre en tu navegador:
```
https://penguin-ternos-api.onrender.com/health
```

**Debe mostrar:**
```json
{
  "status": "OK",
  "timestamp": "2025-11-16T..."
}
```

### 5.2 Probar endpoint de trajes
```
https://penguin-ternos-api.onrender.com/api/trajes
```

**Debe mostrar:**
```json
[
  {
    "id": "41a1d8b6-1fb6-4dbf-b4a0-40cb311366b4",
    "nombre": "Traje de Prueba Test",
    "precio_alquiler": 150,
    "precio_venta": 800,
    ...
  }
]
```

---

## 📍 PASO 6: Actualizar URL en Flutter (SOLO SI ES NECESARIO)

Tu app Flutter ya está configurada para usar:
```
https://alquiler-ternos-backend.onrender.com/api
```

### ⚠️ Si tu URL de Render es diferente:

1. Abrir: `flutter_app/lib/config/api_constants.dart`

2. Cambiar:
```dart
static const String baseUrl = 'https://TU-URL-REAL.onrender.com/api';
```

3. Recompilar app:
```powershell
cd "c:\PENGUIN TERNOS\flutter_app"
flutter clean
flutter pub get
flutter run
```

---

## 🎉 ¡LISTO!

Tu backend ahora está:
- ✅ Desplegado en Render
- ✅ Siempre disponible (o casi, si usas plan Free)
- ✅ Conectado a Supabase
- ✅ Listo para usar desde tu app Flutter

---

## 📊 Verificar desde la App

1. **Abrir tu app Flutter**
2. **Ir a INVENTARIO → Trajes**
3. **Clic en "+"**
4. **Crear un traje de prueba**
5. **Debe aparecer en la lista**
6. **Verificar en Supabase que se guardó**

---

## 🚨 Si Algo Sale Mal

### Error: "Deploy failed"
- Revisa los logs en Render
- Verifica que `Root Directory` sea `backend`
- Verifica que las variables de entorno estén bien

### Error: "Application failed to respond"
- El puerto debe ser `3000` o usar `process.env.PORT`
- Verificar en los logs que el servidor inicie correctamente

### Error: 401 o 403 en la app
- Verifica que `SUPABASE_SERVICE_KEY` esté correcta
- Verifica que las políticas RLS en Supabase permitan operaciones

### La primera request tarda mucho (Plan Free)
- Es normal, el servidor se duerme después de 15 minutos
- Primera request tarda 30-60 segundos en despertar
- Considera upgrading a plan Starter ($7/mes) para mantenerlo siempre activo

---

## 💡 Tips

### Mantener activo el servidor Free
Si quieres que no se duerma, usa un servicio de ping:
- https://uptimerobot.com/ (gratis)
- Configurar para hacer ping cada 10 minutos

### Ver logs en tiempo real
En Render Dashboard:
- Tu servicio → **"Logs"** tab
- Verás todos los requests y errores

### Auto-deploy
Render ya está configurado para auto-deploy:
- Cada vez que hagas `git push` a `main`
- Render automáticamente desplegará los cambios

---

**¿Todo funcionando? ¡Perfecto! Ahora tu backend está en la nube 🚀**
