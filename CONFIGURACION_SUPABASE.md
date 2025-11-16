# Guía de Configuración de Supabase

## Paso 1: Crear Cuenta y Proyecto

1. Ve a [supabase.com](https://supabase.com)
2. Haz clic en "Start your project"
3. Crea una cuenta (GitHub, Google, o email)
4. Crea una nueva organización (o usa una existente)
5. Crea un nuevo proyecto:
   - **Nombre**: penguin-ternos (o el que prefieras)
   - **Database Password**: Guarda esto en un lugar seguro
   - **Region**: Selecciona la más cercana (e.g., South America)
   - **Pricing Plan**: Free (suficiente para empezar)

## Paso 2: Obtener Credenciales

1. En tu proyecto, ve a **Settings** (⚙️) en el sidebar
2. Click en **API**
3. Copia los siguientes valores:

### Project URL
```
https://abcdefghijklmnop.supabase.co
```
Este es tu `SUPABASE_URL`

### Project API keys → anon/public
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
Esta es tu `SUPABASE_KEY`

## Paso 3: Ejecutar el Schema SQL

1. En tu proyecto Supabase, ve a **SQL Editor** en el sidebar
2. Click en **New query**
3. Abre el archivo `backend/database/schema.sql` de este proyecto
4. Copia TODO el contenido
5. Pégalo en el SQL Editor de Supabase
6. Click en **Run** (▶️ botón verde)
7. Deberías ver: `Success. No rows returned`

### Verificar que Funcionó

1. Ve a **Table Editor** en el sidebar
2. Deberías ver 10 tablas:
   - empleados
   - clientes
   - articulos
   - trajes
   - alquileres
   - alquileres_items
   - ventas
   - ventas_items
   - citas
   - configuracion

## Paso 4: Configurar Backend

1. Abre el archivo `backend/.env.example`
2. Crea una copia llamada `backend/.env`
3. Edita el archivo `.env`:

```env
SUPABASE_URL=https://tu-proyecto-real.supabase.co
SUPABASE_KEY=tu-key-real-aqui
PORT=3000
NODE_ENV=development
```

4. Guarda el archivo

## Paso 5: Configurar Flutter

1. Abre `flutter_app/lib/config/api_constants.dart`
2. Verifica que la URL sea correcta:

```dart
class ApiConstants {
  // Para desarrollo local con emulador Android:
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Para dispositivo real en misma red:
  // static const String baseUrl = 'http://TU_IP_LOCAL:3000/api';
  // Ejemplo: 'http://192.168.1.100:3000/api'
  
  // Para producción (después de deploy):
  // static const String baseUrl = 'https://tu-app.onrender.com/api';
}
```

## Paso 6: Inicializar Datos (Opcional)

### Crear Configuración Inicial

En Supabase SQL Editor, ejecuta:

```sql
INSERT INTO configuracion (
  tema_oscuro,
  garantia_tipo,
  garantia_valor,
  mora_tipo,
  mora_valor,
  mora_maxima,
  prolongacion_tipo,
  prolongacion_valor
) VALUES (
  false,
  'fijo',
  100.00,
  'fijo',
  20.00,
  200.00,
  'fijo',
  50.00
);
```

### Crear Empleado de Prueba (Opcional)

```sql
INSERT INTO empleados (nombre, device_id) 
VALUES ('Empleado Test', 'TEST-001');
```

## Troubleshooting

### Error: "relation does not exist"
- Asegúrate de haber ejecutado TODO el schema.sql
- Verifica que las 10 tablas existan en Table Editor

### Error: "Invalid API key"
- Verifica que copiaste la key completa (es muy larga)
- Usa la key "anon/public", NO la "service_role"
- No debe haber espacios al inicio/final

### Error: "Failed to fetch"
- Verifica que el backend esté corriendo (`npm run dev`)
- Verifica la URL en api_constants.dart
- Para emulador Android, usa `10.0.2.2` en lugar de `localhost`

### Base de datos vacía
- Esto es normal la primera vez
- Los datos se crearán al usar la app
- Puedes insertar datos de prueba con los SQLs de arriba

## Verificación Final

### Backend
```powershell
cd backend
npm run dev
```
Deberías ver: `Server running on port 3000`

### Test del API
Abre en navegador: `http://localhost:3000/api/dashboard/resumen-dia`

Deberías ver JSON con datos:
```json
{
  "nuevos_alquileres": 0,
  "devoluciones": 0,
  ...
}
```

### Flutter
```powershell
cd flutter_app
flutter run
```

La app debería:
1. Mostrar splash "PENGUIN TERNOS"
2. Pedir nombre de empleado
3. Mostrar dashboard con estadísticas

---

## ✅ Todo Configurado

Si llegaste aquí sin errores, ¡felicidades! 🎉

Tu sistema PENGUIN TERNOS está listo para usar.

## 🔐 Seguridad

**IMPORTANTE**: Nunca compartas públicamente:
- Database Password
- SUPABASE_KEY
- Archivo .env

Estos son secretos y deben mantenerse privados.

## 📞 Soporte

Si tienes problemas:
1. Revisa esta guía completa
2. Verifica los logs del backend
3. Verifica los logs de Flutter
4. Consulta README.md principal
