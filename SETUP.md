# Penguin Ternos - Instrucciones de Desarrollo

## 🎯 Próximos Pasos para Completar la Aplicación

### 1. Instalar Dependencias del Backend

```powershell
cd "c:\PENGUIN TERNOS\backend"
npm install
```

### 2. Configurar Supabase

1. Ve a https://supabase.com y crea una cuenta
2. Crea un nuevo proyecto
3. Copia las credenciales del proyecto (Project URL y API Keys)
4. En Supabase Dashboard, ve a **SQL Editor**
5. Abre el archivo `backend\database\schema.sql`
6. Copia todo el contenido y pégalo en el SQL Editor
7. Ejecuta el SQL (botón "Run")

### 3. Configurar Variables de Entorno del Backend

```powershell
cd "c:\PENGUIN TERNOS\backend"
copy .env.example .env
```

Edita `.env` con tus credenciales de Supabase:
```env
PORT=3000
NODE_ENV=development
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_anon_key_aqui
SUPABASE_SERVICE_KEY=tu_service_role_key_aqui
```

### 4. Probar el Backend

```powershell
cd "c:\PENGUIN TERNOS\backend"
npm run dev
```

Abre http://localhost:3000/health en tu navegador. Deberías ver: `{"status":"OK"}`

### 5. Instalar Flutter

Si no tienes Flutter instalado:
1. Descarga Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Descomprime en `C:\src\flutter`
3. Agrega `C:\src\flutter\bin` al PATH
4. Ejecuta: `flutter doctor`

### 6. Configurar Flutter App

```powershell
cd "c:\PENGUIN TERNOS\flutter_app"
flutter pub get
```

### 7. Conectar Flutter con el Backend

Edita `flutter_app\lib\config\api_constants.dart`:

```dart
// Para desarrollo local (reemplaza con tu IP local)
static const String baseUrl = 'http://192.168.1.X:3000/api';
```

Para obtener tu IP local:
```powershell
ipconfig
```
Busca "Dirección IPv4" de tu adaptador WiFi o Ethernet.

### 8. Ejecutar la App en Android

1. Conecta un dispositivo Android con USB debugging habilitado, o
2. Inicia un emulador Android

```powershell
cd "c:\PENGUIN TERNOS\flutter_app"
flutter devices  # Verifica que tu dispositivo esté conectado
flutter run
```

## 🔨 Desarrollo de las Pantallas Restantes

La estructura base está completa. Ahora necesitas implementar las pantallas:

### Archivos por Crear

**Providers:**
- `lib/providers/clientes_provider.dart` - Gestión de clientes
- `lib/providers/articulos_provider.dart` - Gestión de artículos
- `lib/providers/trajes_provider.dart` - Gestión de trajes
- `lib/providers/alquileres_provider.dart` - Gestión de alquileres
- `lib/providers/ventas_provider.dart` - Gestión de ventas
- `lib/providers/citas_provider.dart` - Gestión de citas
- `lib/providers/configuracion_provider.dart` - Configuración
- `lib/providers/dashboard_provider.dart` - Dashboard

**Services (API Calls):**
- `lib/services/api_service.dart` - Cliente HTTP base
- `lib/services/clientes_service.dart`
- `lib/services/articulos_service.dart`
- `lib/services/trajes_service.dart`
- `lib/services/alquileres_service.dart`
- `lib/services/ventas_service.dart`
- `lib/services/citas_service.dart`
- `lib/services/configuracion_service.dart`
- `lib/services/reportes_service.dart`

**Screens:**
- `lib/screens/home/` - Pantalla de inicio con dashboard
- `lib/screens/inventario/` - Gestión de inventario
- `lib/screens/alquileres/` - Gestión de alquileres
- `lib/screens/ventas/` - Gestión de ventas
- `lib/screens/citas/` - Gestión de citas
- `lib/screens/clientes/` - Gestión de clientes
- `lib/screens/reportes/` - Generación de reportes
- `lib/screens/configuracion/` - Configuración

**Widgets:**
- `lib/widgets/custom_button.dart`
- `lib/widgets/custom_card.dart`
- `lib/widgets/articulo_card.dart`
- `lib/widgets/traje_card.dart`
- `lib/widgets/alquiler_card.dart`
- `lib/widgets/loading_indicator.dart`
- etc.

### Estructura Recomendada para Cada Módulo

Ejemplo para el módulo de **Alquileres**:

```
lib/screens/alquileres/
├── alquileres_screen.dart          # Pantalla principal con tabs
├── crear_alquiler_screen.dart      # Formulario para crear alquiler
├── detalle_alquiler_screen.dart    # Ver detalles de un alquiler
├── prolongar_alquiler_dialog.dart  # Dialog para prolongar
└── devolver_alquiler_dialog.dart   # Dialog para registrar devolución
```

## 📦 Deploy en Producción

### Backend en Render

1. Sube tu código a GitHub
2. Ve a https://render.com y crea una cuenta
3. Crea nuevo "Web Service"
4. Conecta tu repo de GitHub
5. Configura:
   - Root Directory: `backend`
   - Build Command: `npm install`
   - Start Command: `npm start`
6. Agrega las variables de entorno
7. Deploy

Una vez desplegado, actualiza `flutter_app/lib/config/api_constants.dart`:
```dart
static const String baseUrl = 'https://tu-app.onrender.com/api';
```

### Generar APK para Android

```powershell
cd "c:\PENGUIN TERNOS\flutter_app"
flutter build apk --release
```

El APK estará en: `build\app\outputs\flutter-apk\app-release.apk`

## 🎨 Tips de Desarrollo

1. **Usa Hot Reload**: Presiona `r` en la terminal mientras la app corre para recargar cambios
2. **Hot Restart**: Presiona `R` para reiniciar la app completamente
3. **DevTools**: Ejecuta `flutter pub global activate devtools` y luego `flutter pub global run devtools`
4. **Testing**: Prueba cada endpoint del backend con Postman o Thunder Client antes de integrarlo en Flutter
5. **Estado**: Usa Provider para gestión de estado, ya está configurado

## 🐛 Problemas Comunes

### Error de conexión Backend-Flutter
- Verifica que el backend esté corriendo
- Usa la IP local en vez de `localhost` en la app
- Verifica que ambos dispositivos estén en la misma red

### Error de CORS en el backend
Ya está configurado CORS en el backend, pero si tienes problemas, verifica `backend/src/server.js`

### Errores de compilación en Flutter
```powershell
flutter clean
flutter pub get
flutter run
```

## 📚 Recursos Útiles

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Supabase Docs](https://supabase.com/docs)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)

¡Éxito con el desarrollo! 🚀
