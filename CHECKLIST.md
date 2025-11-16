# ✅ CHECKLIST - Solucionar Problema de Trajes

Marca cada casilla cuando completes el paso.

---

## 🗃️ PARTE 1: CONFIGURAR BASE DE DATOS (Supabase)

### [ ] 1. Abrir Supabase Dashboard
- Ir a: https://supabase.com/dashboard
- Iniciar sesión
- Abrir proyecto: **hqqprbxhfljarfptzsdb**

### [ ] 2. Ir al SQL Editor
- Clic en ícono **"SQL"** en menú lateral (parece terminal)
- Clic en botón **"New Query"**

### [ ] 3. Ejecutar el esquema SQL
- Abrir archivo local: `c:\PENGUIN TERNOS\backend\database\schema_completo.sql`
- Copiar **TODO** el contenido (Ctrl+A, Ctrl+C)
- Pegar en Supabase (Ctrl+V)
- Clic en **"Run"** (botón verde) o presionar **F5**

### [ ] 4. Verificar resultado
Debe aparecer en la consola:
```
✅ Base de datos creada exitosamente
✅ Total de tablas: 10
✅ Configuración inicial insertada
✅ 3 clientes de prueba insertados
```

### [ ] 5. Verificar tablas creadas
- Clic en **"Table Editor"** (ícono de tabla)
- Verificar que existen estas 10 tablas:
  - [ ] empleados
  - [ ] clientes (debe tener 3 registros)
  - [ ] trajes (vacía)
  - [ ] articulos (vacía)
  - [ ] alquileres (vacía)
  - [ ] alquiler_items (vacía)
  - [ ] ventas (vacía)
  - [ ] venta_items (vacía)
  - [ ] citas (vacía)
  - [ ] configuracion (debe tener 1 registro)

---

## 🖥️ PARTE 2: INICIAR BACKEND (Node.js)

### [ ] 6. Abrir PowerShell
- Presionar **Win + X**
- Seleccionar **"Windows PowerShell"**

### [ ] 7. Navegar al backend
```powershell
cd "c:\PENGUIN TERNOS\backend"
```

### [ ] 8. Verificar dependencias
```powershell
npm install
```
Esperar a que termine (30-60 segundos)

### [ ] 9. Iniciar servidor
```powershell
npm start
```

### [ ] 10. Verificar que inició correctamente
Debe mostrar:
```
🚀 Servidor corriendo en puerto 3000
📝 Ambiente: development
```

### [ ] 11. Mantener ventana abierta
**IMPORTANTE:** No cierres esta ventana, el servidor debe seguir corriendo.

---

## 📱 PARTE 3: PROBAR APP FLUTTER

### [ ] 12. Abrir OTRA PowerShell (nueva ventana)
- Presionar **Win + X** nuevamente
- Seleccionar **"Windows PowerShell"**

### [ ] 13. Navegar a Flutter
```powershell
cd "c:\PENGUIN TERNOS\flutter_app"
```

### [ ] 14. Limpiar proyecto
```powershell
flutter clean
flutter pub get
```

### [ ] 15. Ejecutar app
```powershell
flutter run
```
Esperar a que compile (2-3 minutos la primera vez)

### [ ] 16. App inicia correctamente
La app debe abrir y mostrar el dashboard

---

## 🧪 PARTE 4: CREAR TRAJE DE PRUEBA

### [ ] 17. Navegar a Inventario
- En la app, ir a **"INVENTARIO"** (botón naranja en dashboard)

### [ ] 18. Ir a tab Trajes
- Seleccionar tab **"Trajes"**
- Debe mostrar lista vacía

### [ ] 19. Abrir formulario
- Clic en botón **"+"** (FloatingActionButton naranja abajo derecha)

### [ ] 20. Llenar información del traje
- **Nombre:** Test Traje 1
- **Descripción:** Traje de prueba
- **Precio Alquiler:** 150
- **Precio Venta:** 800
- **Cantidad Predefinida:** 1

### [ ] 21. Llenar información del SACO
- Expandir card "Saco"
- **Nombre:** Saco Negro
- **Talla:** L
- **P. Alquiler:** 40
- **P. Venta:** 200

### [ ] 22. Llenar información del PANTALÓN
- Expandir card "Pantalón"
- **Nombre:** Pantalón Negro
- **Talla:** L
- **P. Alquiler:** 30
- **P. Venta:** 150

### [ ] 23. Llenar información de la CAMISA
- Expandir card "Camisa"
- **Nombre:** Camisa Blanca
- **Talla:** L
- **P. Alquiler:** 20
- **P. Venta:** 100

### [ ] 24. Llenar información de los ZAPATOS
- Expandir card "Zapatos"
- **Nombre:** Zapatos Negros
- **Talla:** 42
- **P. Alquiler:** 25
- **P. Venta:** 180

### [ ] 25. Guardar traje
- Clic en botón **"Guardar Traje"** (botón naranja abajo)
- Esperar loading spinner

### [ ] 26. Verificar mensaje de éxito
Debe aparecer SnackBar verde:
```
✅ Traje agregado correctamente
```

### [ ] 27. Verificar que regresa a la lista
La pantalla debe cerrar y volver a la lista de trajes

### [ ] 28. Verificar traje en lista
El traje **"Test Traje 1"** debe aparecer en la lista

---

## 🔍 PARTE 5: VERIFICAR EN SUPABASE

### [ ] 29. Volver a Supabase Dashboard
- Ir a: https://supabase.com/dashboard
- Abrir proyecto: **hqqprbxhfljarfptzsdb**

### [ ] 30. Verificar tabla trajes
- Clic en **"Table Editor"**
- Seleccionar tabla **"trajes"**
- Verificar que existe 1 registro:
  - [ ] Nombre: "Test Traje 1"
  - [ ] Precio Alquiler: 150.00
  - [ ] Precio Venta: 800.00
  - [ ] Disponible: true

### [ ] 31. Verificar tabla articulos
- Seleccionar tabla **"articulos"**
- Verificar que existen 4 registros:
  - [ ] Tipo: saco, Nombre: "Saco Negro", Talla: L
  - [ ] Tipo: pantalon, Nombre: "Pantalón Negro", Talla: L
  - [ ] Tipo: camisa, Nombre: "Camisa Blanca", Talla: L
  - [ ] Tipo: zapatos, Nombre: "Zapatos Negros", Talla: 42

### [ ] 32. Verificar campo traje_id
- Los 4 artículos deben tener el mismo `traje_id`
- Ese `traje_id` debe coincidir con el `id` del traje en tabla trajes

---

## 🎉 RESULTADO FINAL

### [ ] 33. TODO FUNCIONA CORRECTAMENTE

Si marcaste todas las casillas anteriores:

✅ La base de datos está configurada
✅ El backend está corriendo
✅ La app Flutter funciona
✅ Puedes crear trajes
✅ Los trajes se guardan en Supabase
✅ Los artículos se crean automáticamente

**🎊 ¡FELICIDADES! EL PROBLEMA ESTÁ SOLUCIONADO**

---

## ❌ TROUBLESHOOTING

Si algún paso falló, marca cuál:

### [ ] Error en Paso 3 (Ejecutar SQL)
**Mensaje:** "syntax error at or near..."
- Asegúrate de copiar TODO el archivo
- Verifica que no haya caracteres extraños
- Intenta ejecutar el archivo original `schema.sql` primero

### [ ] Error en Paso 9 (Iniciar backend)
**Mensaje:** "Cannot find module..."
- Ejecuta: `npm install`
- Verifica que existe archivo `.env`
- Verifica las credenciales en `.env`

### [ ] Error en Paso 15 (Ejecutar app)
**Mensaje:** "Build failed..."
- Ejecuta: `flutter clean`
- Ejecuta: `flutter pub get`
- Ejecuta: `flutter run`

### [ ] Error en Paso 25 (Guardar traje)
**Mensaje:** "Error al guardar..."
- Verifica que el backend esté corriendo (Paso 9)
- Revisa logs del backend en la terminal
- Verifica la URL en `api_constants.dart`

### [ ] Traje no aparece en Supabase (Paso 30-31)
- Revisa logs del backend
- Ejecuta `node test_traje.js` para probar conexión
- Verifica que las políticas RLS estén correctas

---

## 📞 AYUDA ADICIONAL

Si después de revisar todo sigue sin funcionar:

1. **Logs del backend:**
   - Revisa la terminal donde ejecutaste `npm start`
   - Copia cualquier error que aparezca

2. **Logs de Flutter:**
   - Revisa la terminal donde ejecutaste `flutter run`
   - Copia cualquier error que aparezca

3. **Archivos de referencia:**
   - `EMPEZAR_AQUI.md` - Guía rápida
   - `SOLUCION_TRAJES.md` - Solución detallada
   - `backend/test_traje.js` - Test de conexión

---

**Última actualización:** 2025-01-16
**Versión:** 1.0
