# 🚀 Guía Rápida: Despliegue en Render

## Paso 1: Configurar Render

1. **Ir a Render:**
   - Visita: https://dashboard.render.com/
   - Inicia sesión o crea una cuenta

2. **Crear Web Service:**
   - Clic en "New +" (esquina superior derecha)
   - Seleccionar "Web Service"

3. **Conectar Repositorio:**
   - Si es primera vez: "Connect GitHub" o "Connect GitLab"
   - Buscar: `alquiler-ternos-backend`
   - Clic en "Connect"

## Paso 2: Configuración del Servicio

### Configuración Básica:
```
Name: penguin-ternos-api
Region: Oregon (US West)
Branch: main
Root Directory: backend
Runtime: Node
Build Command: npm install
Start Command: npm start
```

### Plan:
- **Free** (para desarrollo/pruebas)
  - ⚠️ Se duerme después de 15 min de inactividad
  - Primera request tarda 30-60 seg en despertar
  
- **Starter** - $7/mes (recomendado para producción)
  - Siempre activo
  - Sin tiempos de espera

## Paso 3: Variables de Entorno

En la sección **"Environment"** agregar estas variables:

### Variables Requeridas:
```env
NODE_ENV=production
PORT=3000
SUPABASE_URL=https://hqqprbxhfljarfptzsdb.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhxcXByYnhoZmxqYXJmcHR6c2RiIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MzIzOTMzNCwiZXhwIjoyMDc4ODE1MzM0fQ.KKxzmxIJRYpfUT4PnD9WvLmBNn1OGoQHde9ZkjNst0s
```

### Cómo Agregarlas:
1. Scroll hasta "Environment Variables"
2. Clic en "Add Environment Variable"
3. Agregar cada par Key/Value
4. Clic en "Save Changes"

## Paso 4: Deploy

1. **Clic en "Create Web Service"**
2. Render automáticamente:
   - Clona el repositorio
   - Instala dependencias
   - Inicia el servidor

3. **Esperar Deploy:**
   - Tarda ~2-3 minutos
   - Ver progreso en la sección "Logs"

## Paso 5: Verificar Despliegue

### 1. Copiar URL:
Tu backend estará en:
```
https://penguin-ternos-api.onrender.com
```
(o el nombre que hayas elegido)

### 2. Probar Health Check:
Abre en el navegador:
```
https://TU-APP.onrender.com/health
```

Debe responder:
```json
{
  "status": "OK",
  "timestamp": "2025-11-16T..."
}
```

### 3. Probar un Endpoint:
```
https://TU-APP.onrender.com/api/configuracion
```

## Paso 6: Configurar Supabase (Si no está hecho)

1. **Ir a Supabase:**
   - https://supabase.com/dashboard
   - Proyecto: `hqqprbxhfljarfptzsdb`

2. **Ejecutar SQL:**
   - SQL Editor → New Query
   - Copiar todo el contenido de `backend/database/schema.sql`
   - Run

3. **Verificar Tablas:**
   - Table Editor
   - Debes ver: clientes, articulos, trajes, alquileres, ventas, citas, etc.

## Paso 7: Actualizar Flutter App

### Archivo: `flutter_app/lib/config/api_constants.dart`

```dart
class ApiConstants {
  // ⬇️ CAMBIAR ESTA URL
  static const String baseUrl =
      'https://TU-APP.onrender.com/api';
      
  // ... resto del código
}
```

**Reemplazar `TU-APP` con tu URL real de Render**

## Paso 8: Probar la App

1. **Reiniciar Flutter:**
```bash
cd flutter_app
flutter clean
flutter pub get
flutter run
```

2. **Primera Carga:**
   - Si usas Free tier, la primera request tarda 30-60 seg
   - El mensaje "Conectando con el servidor..." aparecerá
   - Luego cargará normal

3. **Verificar:**
   - ✅ Dashboard carga estadísticas
   - ✅ Se pueden ver clientes
   - ✅ Inventario funciona
   - ✅ Citas se pueden crear

---

## 🔧 Comandos Útiles

### Ver Logs en Tiempo Real:
Dashboard → Tu servicio → Logs

### Redesplegar:
Dashboard → Tu servicio → Manual Deploy → "Deploy latest commit"

### Cambiar Variables de Entorno:
Dashboard → Tu servicio → Environment → Edit → Save Changes

---

## 📋 Checklist Final

- [ ] Backend desplegado en Render
- [ ] Health check responde OK
- [ ] Variables de entorno configuradas
- [ ] Base de datos creada en Supabase
- [ ] URL actualizada en Flutter
- [ ] App Flutter probada y funcionando

---

## 🐛 Problemas Comunes

### "No se pudo conectar al servidor"
- ✅ Verifica que el backend esté desplegado
- ✅ Verifica la URL en `api_constants.dart`
- ✅ Si es Free tier, espera 30-60 seg en la primera request

### "Error 500" en requests
- ✅ Verifica logs en Render Dashboard
- ✅ Confirma variables de entorno
- ✅ Verifica que Supabase tenga las tablas

### "CORS Error"
- ✅ El backend ya tiene CORS habilitado
- ✅ Verifica que estés usando la URL correcta

### App se queda en loading
- ✅ Verifica conexión a internet
- ✅ Verifica URL del backend
- ✅ Si es Free tier, espera a que despierte el servidor

---

## 💡 Tips

1. **Free Tier:** Usa para desarrollo, no para producción
2. **Logs:** Revisa siempre los logs si algo falla
3. **Auto-Deploy:** Render redespliega automáticamente en cada push a `main`
4. **Health Check:** Úsalo para verificar que el servidor está activo

---

## ✅ ¡Listo!

Una vez completados todos los pasos, tu app estará completamente funcional con:
- ✅ Backend en Render
- ✅ Base de datos en Supabase
- ✅ App Flutter conectada

**¡A vender y alquilar ternos! 🤵**
