# Resumen del entregable: Conexión a BD, registro y login

Documento para exposición y referencia del equipo.

---

## 1. Requerimiento cumplido

**"Lista la conexión a base de datos con registro y login"**

La app RiskMobile quedó conectada a Firebase (base de datos en la nube) y tiene funcionando registro, login, recuperar contraseña y flujo de autenticación completo.

---

## 2. ¿Qué es la "conexión a base de datos"?

- **Firebase** es el backend en la nube (de Google).
- Se usan dos servicios:
  - **Firebase Authentication:** registra usuarios (correo + contraseña) y valida el login.
  - **Cloud Firestore:** base de datos NoSQL donde se guarda el perfil (nombre, rol, teléfono) en la colección `users`.
- La conexión se inicia en `main.dart` con `Firebase.initializeApp()`.
- Al registrarse: se crea el usuario en Auth y su documento en Firestore.
- Al iniciar sesión: se valida en Auth y se lee el perfil en Firestore para mostrar el nombre y redirigir según rol (Cliente o Asesor).

---

## 3. Lo que se implementó o ajustó

| Componente | Qué se hizo |
|------------|-------------|
| **Splash** | Logo RiskMobile, tagline "Tu asesoría crediticia, en tu mano", barra de progreso determinada, versión v1.0.0. Redirige a Login o Home según sesión. |
| **Login** | Pantalla con correo, contraseña, "¿Olvidaste tu contraseña?", botón "Iniciar sesión", "Acceso biométrico", enlace a Registro. Conectado a Firebase Auth. |
| **Registro** | Formulario con nombre, correo, teléfono (opcional), contraseña, confirmar contraseña, selector Cliente/Asesor. Crea usuario en Auth y documento en Firestore. |
| **Recuperar contraseña** | Nueva pantalla y ruta `/forgot-password`. El usuario ingresa correo y recibe enlace para restablecer contraseña vía Firebase. |
| **Saludo con nombre** | En Home del cliente se muestra "Hola, [nombre]" usando el nombre con el que se registró (desde Firestore o Auth). |
| **Manejo de errores** | Mensajes claros en español para registro (correo ya existe, contraseña débil, permisos Firestore, etc.). |
| **COMO_EJECUTAR.md** | Guía para ejecutar la app, probar login/registro, hot reload y demostrar la conexión a BD al profesor. |
| **firestore.rules** | Archivo de referencia con reglas para la colección `users` (cada usuario solo accede a su documento). |

---

## 4. Archivos modificados o creados

| Archivo | Cambio |
|---------|--------|
| `lib/main.dart` | Ya tenía Firebase inicializado (sin cambios relevantes). |
| `lib/core/services/auth_service.dart` | Ajustes en registro (manejo de errores, rollback si falla Firestore). |
| `lib/core/router/app_router.dart` | Ruta `/forgot-password` y pantalla de recuperar contraseña. |
| `lib/features/auth/presentation/screens/splash_screen.dart` | Barra de progreso determinada (animada). |
| `lib/features/auth/presentation/screens/login_screen.dart` | Botón "¿Olvidaste tu contraseña?" conectado a la nueva ruta. |
| `lib/features/auth/presentation/screens/register_screen.dart` | Mejor manejo de errores (Firebase Auth y Firestore). |
| `lib/features/auth/presentation/screens/forgot_password_screen.dart` | **Nuevo.** Pantalla de recuperar contraseña. |
| `lib/features/auth/presentation/screens/client_home_screen.dart` | Saludo "Hola, [nombre]" usando Firestore o Auth. |
| `COMO_EJECUTAR.md` | **Nuevo.** Guía de ejecución, pruebas y demostración. |
| `firestore.rules` | **Nuevo.** Reglas de referencia para Firestore. |

---

## 5. Configuración en Firebase Console

Para que la app funcione, en Firebase se configuró lo siguiente:

### Paso 1: Authentication (Correo/contraseña)

1. Menú lateral → **Seguridad** (o Build) → **Authentication**.
2. Si es la primera vez, clic en **Comenzar**.
3. Pestaña **Sign-in method** (Método de acceso).
4. Clic en **Correo/contraseña** (Email/Password).
5. Activar el interruptor **Habilitar**.
6. Guardar.

### Paso 2: Firestore Database

1. Menú lateral → **Bases de datos y almacenamiento** → **Firestore Database**.
2. Si no hay base de datos, clic en **Crear base de datos**.
3. Elegir modo **Prueba** (desarrollo) o **Producción**.
4. Seleccionar región (ej. us-central1 o southamerica-east1).
5. Habilitar.

### Paso 3: Reglas de Firestore

1. En Firestore Database, pestaña **Reglas**.
2. Reemplazar el contenido por:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```
3. Clic en **Publicar**.

### Paso 4: Dominios autorizados (para web/Chrome)

1. **Authentication** → **Settings** (Configuración).
2. Pestaña **Authorized domains**.
3. Verificar que exista **localhost** (suele venir por defecto).
4. Si no está, agregar solo: `localhost` (sin http://, sin puerto).

### Resumen de lo configurado

| Componente | Dónde | Qué se hizo |
|------------|-------|-------------|
| Auth | Authentication → Sign-in method | Habilitado **Correo/contraseña**. |
| Firestore | Firestore Database | Base de datos creada. |
| Reglas | Firestore → Reglas | Reglas publicadas para `users/{userId}`. |
| Dominios | Authentication → Authorized domains | **localhost** incluido. |

---

## 6. Cómo ejecutar y probar

```bash
cd d:\RiskMobile
flutter pub get
flutter run -d chrome
```

1. Splash → Login.
2. "Regístrate" → llenar formulario → Crear cuenta.
3. Entrar al Home y ver "Hola, [nombre]".
4. Cerrar sesión → Iniciar sesión con el mismo correo y contraseña.
5. Probar "¿Olvidaste tu contraseña?" con un correo registrado.

---

## 7. Cómo demostrar la conexión a la base de datos

**En la app:** registro → Home con nombre → cerrar sesión → login → mismo Home. Esto muestra que Auth y Firestore están funcionando.

**En Firebase Console:**
- **Authentication → Users:** se ven los correos registrados.
- **Firestore → Datos → users:** se ven documentos con `name`, `email`, `role`, etc.

---

## 8. Rama y despliegue

- **Rama:** brandon-main  
- **Repositorio:** kesticar92/RiskMobile  
- **Proyecto Firebase:** riskmobile-c59fc  
- **Commit desplegado:** bd148f9  
- **Mensaje del commit:** "Entregable: conexión BD, registro, login, recuperar contraseña, splash, saludo con nombre, COMO_EJECUTAR y firestore.rules"  
- **Archivos en el push:** 10 archivos modificados/creados (528 líneas añadidas, 142 eliminadas):
  - Modificados: `app_router.dart`, `auth_service.dart`, `client_home_screen.dart`, `login_screen.dart`, `register_screen.dart`, `splash_screen.dart`, `pubspec.lock`
  - Nuevos: `COMO_EJECUTAR.md`, `firestore.rules`, `forgot_password_screen.dart`

> **Nota:** Este archivo (`RESUMEN_ENTREGABLE.md`) se creó después del push. Para subirlo también: `git add RESUMEN_ENTREGABLE.md`, `git commit -m "Agregar resumen del entregable"`, `git push origin brandon-main`.

---

## 9. Equipo

- **Brandon Faruck Villamarin** – Desarrollador / QA  
- **Kevin Cardoso** – Desarrollador principal / Arquitectura  

---

## 10. Avance sesión de hoy (RF05, RF10, RF07)

Durante la sesión actual se implementaron 3 requerimientos funcionales de la entrevista financiera:

- **RF05 (Paso 1):**
  - Se añadió `tipo de contrato` cuando la actividad es **Empleado** o **Profesional independiente**.
  - Se añadió `antigüedad laboral` en meses.
  - Se reforzó validación para no avanzar si faltan campos obligatorios o valores inválidos.
  - Se guardan en Firestore los nuevos campos: `contractType` y `seniorityMonths`.

- **RF10 (Paso 2):**
  - Se mantuvo el flujo dinámico de obligaciones con switch Sí/No.
  - Se añadió `saldo pendiente` opcional al modal de creación de obligaciones.
  - Se validó entidad y cuota mensual para evitar registros incompletos.
  - Si el usuario marca que no tiene obligaciones, se limpia la lista de obligaciones.

- **RF07 (Paso 3):**
  - Se reforzó validación de `monto deseado` (numérico y no negativo).
  - Se hizo obligatoria la selección de `tipo de crédito de interés` para continuar.

**Resultado:** flujo de entrevista de 3 pasos funcionando y probado en navegador (`flutter run -d chrome`) con guardado correcto hacia la colección `cases`.

---

*Documento de seguimiento del entregable RiskMobile (sesión 1: conexión BD/auth y sesión 2: entrevista RF05-RF10-RF07).*
