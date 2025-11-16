# PENGUIN TERNOS - Sistema de Gestión de Alquileres y Ventas

Sistema completo de gestión para tienda de alquiler y venta de trajes formales, diseñado para empleados.

## ✨ Características Principales

- ✅ **Alquileres de trajes** con seguimiento completo
- ✅ **Marcado de trajes perdidos/robados** con retención automática de garantía
- ✅ **Gestión de clientes** con búsqueda rápida
- ✅ **Control de inventario** automático
- ✅ **Dashboard en tiempo real** con estadísticas
- ✅ **Mantenimiento automático** de trajes (24 horas)
- ✅ **Modo oscuro/claro**

## 🏗️ Tecnologías

### Backend
- Node.js 18+ con Express.js
- Supabase (PostgreSQL)
- PDFKit para reportes
- 40+ endpoints REST

### Frontend
- Flutter 3.0+ (Android)
- Provider para estado
- Material Design 3
- Dio HTTP client

## 📋 Instalación Rápida

### 1. Base de Datos

1. Crea cuenta en [supabase.com](https://supabase.com)
2. Ejecuta `backend/database/schema.sql`
3. Copia `Project URL` y `anon key`

### 2. Backend

```powershell
cd backend
npm install

# Crea .env con:
# SUPABASE_URL=https://tu-proyecto.supabase.co
# SUPABASE_KEY=tu-anon-key

npm run dev  # http://localhost:3000
```

### 3. Frontend

```powershell
cd flutter_app
flutter pub get

# Edita lib/config/api_constants.dart:
# baseUrl = 'http://10.0.2.2:3000/api'

flutter run
```

## 🚨 Funcionalidad Estrella: Marcar como Perdido/Robo

1. Ve a **ALQUILERES** → pestaña **ACTIVOS**
2. Menú (⋮) → **Marcar Perdido/Robo**
3. **Advertencia**: Acción irreversible
4. Ingresa observaciones obligatorias
5. Confirma dos veces

**Resultado automático**:
- ✅ Garantía retenida
- ✅ Inventario descontado
- ✅ Registro permanente con indicador de robo
- ❌ NO se puede revertir

## 📱 Pantallas

| Pantalla | Función |
|----------|---------|
| **Inicio** | Dashboard con resumen del día |
| **Clientes** | CRUD + búsqueda por DNI/nombre |
| **Alquileres** | Activos + Historial + Marcar perdido |
| **Configuración** | Valores + Modo oscuro + Cerrar sesión |

## 🌐 Deployment

### Backend → Render.com
```
Build: npm install
Start: npm start
Env: SUPABASE_URL, SUPABASE_KEY
```

### Frontend → APK
```powershell
flutter build apk --release
# APK en: build/app/outputs/flutter-apk/
```

## 📊 API Endpoints Clave

```
POST   /api/alquileres              # Crear alquiler
GET    /api/alquileres/activos      # Lista activos
PUT    /api/alquileres/:id/devolver # Devolver
PUT    /api/alquileres/:id/marcar-perdido ⭐ # Marcar perdido
GET    /api/dashboard/resumen-dia   # Dashboard
GET    /api/clientes/search?q=      # Buscar cliente
```

## 🔧 Estructura de Archivos

```
PENGUIN TERNOS/
├── backend/
│   ├── src/
│   │   ├── controllers/
│   │   │   └── alquileres.controller.js  ⭐ marcarPerdido()
│   │   ├── routes/
│   │   └── server.js
│   ├── database/schema.sql
│   └── package.json
└── flutter_app/
    ├── lib/
    │   ├── models/
    │   │   └── alquiler.dart       ⭐ esRobo field
    │   ├── screens/
    │   │   └── alquileres_screen.dart  ⭐ Dialog perdido
    │   ├── services/
    │   │   └── alquileres_service.dart ⭐ marcarPerdido()
    │   └── main.dart
    └── pubspec.yaml
```

## 🐛 Troubleshooting

**Error de conexión**: Verifica URL en `api_constants.dart`
- Emulador: `http://10.0.2.2:3000/api`
- Dispositivo: `http://TU_IP:3000/api`
- Producción: `https://tu-app.onrender.com/api`

**Flutter pub get falla**:
```powershell
flutter clean
flutter pub get
```

## 📄 Licencia

Privado - PENGUIN TERNOS © 2024

---

**Versión**: 1.0.0  
**Estado**: ✅ Listo para producción
