# ✅ Checklist de Verificación - PENGUIN TERNOS

Use este checklist para verificar que todo está correctamente configurado antes de usar el sistema.

## 📋 Pre-requisitos

- [ ] Node.js 18+ instalado
  ```powershell
  node --version  # Debería mostrar v18.x.x o superior
  ```

- [ ] npm instalado
  ```powershell
  npm --version   # Debería mostrar versión
  ```

- [ ] Flutter 3.0+ instalado
  ```powershell
  flutter --version  # Debería mostrar Flutter 3.x.x
  ```

- [ ] Android Studio o VS Code con extensiones Flutter instalados

- [ ] Cuenta en Supabase creada

---

## 🗄️ Configuración de Base de Datos

- [ ] Proyecto creado en Supabase
- [ ] Schema SQL ejecutado completamente (`backend/database/schema.sql`)
- [ ] 10 tablas visibles en Table Editor:
  - [ ] empleados
  - [ ] clientes
  - [ ] articulos
  - [ ] trajes
  - [ ] alquileres
  - [ ] alquileres_items
  - [ ] ventas
  - [ ] ventas_items
  - [ ] citas
  - [ ] configuracion
- [ ] SUPABASE_URL copiado
- [ ] SUPABASE_KEY (anon/public) copiado
- [ ] Configuración inicial insertada (opcional pero recomendado)

---

## 🔧 Configuración de Backend

- [ ] Dependencias instaladas
  ```powershell
  cd backend
  npm install
  ```

- [ ] Archivo `.env` creado (basado en `.env.example`)
- [ ] `.env` contiene SUPABASE_URL correcto
- [ ] `.env` contiene SUPABASE_KEY correcto
- [ ] `.env` tiene PORT=3000
- [ ] `.env` tiene NODE_ENV=development

- [ ] Servidor inicia sin errores
  ```powershell
  npm run dev
  # Debería mostrar: "Server running on port 3000"
  ```

- [ ] Test del API funciona
  - Abre navegador: `http://localhost:3000/api/dashboard/resumen-dia`
  - Debería mostrar JSON (aunque esté vacío)

---

## 📱 Configuración de Frontend

- [ ] Dependencias de Flutter obtenidas
  ```powershell
  cd flutter_app
  flutter pub get
  # Debería completar sin errores
  ```

- [ ] Sin errores de compilación
  ```powershell
  flutter analyze
  # Debería mostrar: "No issues found!"
  ```

- [ ] `lib/config/api_constants.dart` configurado correctamente:
  - [ ] Para emulador: `http://10.0.2.2:3000/api`
  - [ ] Para dispositivo real: `http://TU_IP_LOCAL:3000/api`

- [ ] Dispositivo Android o emulador disponible
  ```powershell
  flutter devices
  # Debería mostrar al menos 1 dispositivo
  ```

---

## 🚀 Pruebas de Funcionalidad

### Primera Ejecución

- [ ] Backend corriendo (`npm run dev`)
- [ ] Flutter app ejecutada (`flutter run`)
- [ ] Splash screen "PENGUIN TERNOS" aparece
- [ ] Pantalla de setup de empleado aparece
- [ ] Puedo ingresar nombre y continuar
- [ ] Dashboard aparece con estadísticas (aunque en 0)

### Navegación

- [ ] Bottom navigation funciona (4 pestañas):
  - [ ] INICIO (Dashboard)
  - [ ] CLIENTES
  - [ ] ALQUILERES
  - [ ] CONFIGURACIÓN

### Clientes

- [ ] Puedo crear un cliente nuevo
- [ ] Cliente aparece en la lista
- [ ] Puedo buscar cliente por nombre/DNI
- [ ] Puedo editar información del cliente

### Configuración

- [ ] Veo mi nombre de empleado
- [ ] Veo device ID
- [ ] Puedo alternar modo oscuro/claro
- [ ] Veo parámetros de alquiler

### Alquileres

- [ ] Veo pestañas ACTIVOS e HISTORIAL
- [ ] Botón flotante (+) aparece
- [ ] (Si hay alquileres) Aparecen en la lista

---

## 🚨 Prueba Funcionalidad Clave: Marcar como Perdido

**Prerequisito**: Debe haber al menos 1 alquiler activo en la base de datos

- [ ] Voy a ALQUILERES → ACTIVOS
- [ ] Click en menú (⋮) de un alquiler
- [ ] Veo opción "Marcar Perdido/Robo" en rojo
- [ ] Click en la opción
- [ ] Aparece diálogo con advertencia "ACCIÓN IRREVERSIBLE"
- [ ] Lista de consecuencias visible
- [ ] Campo de observaciones obligatorio
- [ ] Al intentar sin observaciones, muestra error
- [ ] Con observaciones, pide confirmación adicional
- [ ] Confirmo y el alquiler desaparece de ACTIVOS
- [ ] Aparece en HISTORIAL con indicador de "ROBO/PÉRDIDA"
- [ ] Muestra "Garantía retenida"

### Verificar en Base de Datos (Opcional)

En Supabase SQL Editor:
```sql
SELECT * FROM alquileres WHERE es_robo = true;
-- Debería mostrar el alquiler marcado

SELECT * FROM articulos WHERE id IN (
  SELECT articulo_id FROM alquileres_items 
  WHERE alquiler_id = 'ID_DEL_ALQUILER'
);
-- cantidad_disponible debería haberse reducido en 1
```

---

## 📊 Dashboard

- [ ] Resumen del día muestra datos
- [ ] Estadísticas generales visibles
- [ ] Pull-to-refresh funciona
- [ ] Botón de refresh funciona

---

## 🎨 Temas

- [ ] Tema claro funciona correctamente
- [ ] Tema oscuro funciona correctamente
- [ ] Cambio de tema persiste al cerrar/abrir app
- [ ] Colores se ven bien en ambos temas

---

## 🔐 Cerrar Sesión

- [ ] En CONFIGURACIÓN, botón "Cerrar Sesión" visible
- [ ] Click muestra confirmación
- [ ] Confirmar cierra sesión
- [ ] Vuelve a pantalla de setup de empleado
- [ ] Puedo volver a iniciar sesión

---

## ✅ Verificación Final

### Todos los checks anteriores completados

- [ ] Base de datos configurada ✅
- [ ] Backend funcionando ✅
- [ ] Frontend compilando ✅
- [ ] App ejecutándose ✅
- [ ] Funcionalidades básicas probadas ✅
- [ ] Marcar como perdido probado ✅

---

## 🐛 Si Algo Falla

### Backend no inicia
1. Verifica que .env existe y tiene datos correctos
2. Verifica conexión a internet (Supabase requiere internet)
3. Revisa logs en la terminal
4. Intenta: `npm install` nuevamente

### Flutter no compila
1. Ejecuta: `flutter clean`
2. Ejecuta: `flutter pub get`
3. Verifica que no hay errores: `flutter analyze`
4. Intenta cerrar/abrir VS Code o Android Studio

### App no conecta al backend
1. Verifica que backend esté corriendo
2. Verifica URL en `api_constants.dart`
3. Para emulador Android, usa `10.0.2.2` NO `localhost`
4. Para dispositivo real, usa IP local (ej: `192.168.1.100`)

### Errores de base de datos
1. Verifica que ejecutaste TODO el schema.sql
2. Ve a Table Editor y confirma que hay 10 tablas
3. Intenta ejecutar el schema nuevamente (DROP CASCADE primero si es necesario)

---

## 📞 Recursos de Ayuda

- `README.md` - Documentación principal
- `CONFIGURACION_SUPABASE.md` - Guía detallada de Supabase
- `PROYECTO_COMPLETADO.md` - Resumen ejecutivo del proyecto
- Logs del backend: En la terminal donde ejecutaste `npm run dev`
- Logs de Flutter: En la terminal donde ejecutaste `flutter run`

---

## 🎉 ¡Todo Listo!

Si todos los checks están marcados ✅, tu sistema PENGUIN TERNOS está completamente funcional y listo para usar en producción.

**Siguiente paso**: Deploy a producción siguiendo la sección "Deployment" del README.md

---

**Fecha de verificación**: _____________  
**Verificado por**: _____________  
**Estado**: ✅ Aprobado / ⏳ Pendiente / ❌ Requiere correcciones
