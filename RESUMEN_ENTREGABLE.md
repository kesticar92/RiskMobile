# Resumen del entregable: Conexión a BD, registro y login

**Última actualización del documento:** **18 de abril de 2026** (sábado). Ver **§15** para la iteración más reciente (CRM Kevin, documentos Brandon, ramas y merge).

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

## 11. Avance sesión de hoy (RF13, RF15, RF17)

En esta sesión se completaron y validaron 3 requerimientos funcionales adicionales:

- **RF13 (Cálculo de endeudamiento):**
  - Se confirmó visualización del nivel de endeudamiento (%), gauge por color y referencias de ideal/máximo.
  - Se ajustó `availableCapacity` para que nunca sea negativa (si el cálculo da negativo, se muestra y guarda como `0`).

- **RF15 (Score RiskMobile):**
  - Se corrigió el cálculo para incluir la antigüedad laboral (`seniorityMonths`) al generar score.
  - Se agregó la nota informativa en la pantalla de perfil financiero: score orientativo y no equivalente al score oficial de centrales.

- **RF17 (Simulador dinámico):**
  - Se validó funcionamiento de sliders de tasa, plazo y monto.
  - Se validó selector de tipo de crédito, presets de plazo y actualización en tiempo real de:
    - cuota mensual estimada
    - monto máximo viable
    - total a pagar
    - comparación visual monto deseado vs viable.

**Resultado:** RF13, RF15 y RF17 funcionando y validados en ejecución (`flutter run -d chrome`).

---

## 12. Avance sesión del **22 de marzo de 2026** (domingo)

### Bloque asesor / CRM / chat (rama `kevin-main`)

| RF | Contenido |
|----|-----------|
| **RF23** | Panel de clientes: estadística **En proceso** según casos no cerrados (`isCaseInProgress`), búsqueda y filtros. |
| **RF25** | Detalle de cliente: cambio de **estado del caso** con indicador de carga y dropdown deshabilitado mientras guarda. |
| **RF26** | Chat: mensajes hasta **500 caracteres** (contador + validación); cliente usa **UID real del asesor** desde Firestore (`getFirstAdvisorUser`). |

**Navegación:** helper `navigation_helpers.dart` (`popOrGo`, `popOrHomeAsync`); flujo **entrevista → calculadora** sin perder historial; botón atrás en calculadora; `tools/` ignorado en git (`.gitignore`).

### Simulador — cupo por línea de crédito

- Archivo `credit_line_params.dart`: **tasa y plazo de referencia por tipo de crédito** (Vivienda, Vehículo, Microcrédito con tope, etc.).
- El **cupo máximo / monto viable** se recalcula al cambiar la **línea de crédito**; plazos y atajos respetan min/max del producto.

### Documentos y Firebase Storage (RF08, RF09, RF35)

| RF | Contenido |
|----|-----------|
| **RF08** | Cámara y galería con validación de formato (JPG/PNG/PDF según flujo). |
| **RF09** | Selector de archivos nativo (PDF, JPG, PNG, JPEG). |
| **RF35** | Subida a **Firebase Storage** en `documents/{userId}/{caseId}/...`; metadatos en colección Firestore `documents`; caso resuelto con último caso del cliente o carpeta `pending`. |

**Archivos relevantes:** `storage_service.dart`, `storage.rules`, `docs/REGLAS_DOCUMENTOS_FIRESTORE.md`, dependencia `path` en `pubspec.yaml`.

### Detalle a nivel de código (sesión 22-mar-2026)

Tabla de **archivos tocados o nuevos** y qué hace cada cambio (para revisión en IDE o exposición).

#### Constantes y utilidades

| Archivo | Cambio en código |
|---------|------------------|
| `lib/core/constants/app_constants.dart` | `isCaseInProgress(caseStatus)` para estadísticas CRM; `chatMessageMaxLength = 500` para RF26. |
| `lib/core/constants/credit_line_params.dart` | **Nuevo.** Clases `CreditLineParams` y `CreditLineParamsRegistry.forLine(...)`: tasa referencia, plazo min/max/default y `maxAmountCap` por tipo de crédito. |
| `lib/core/router/navigation_helpers.dart` | **Nuevo.** `popOrGo(context, fallbackRoute)` y `popOrHomeAsync(context, ref)` para no dejar el botón atrás sin efecto cuando la pila quedó vacía tras `go()`. |

#### Servicios (Firestore / Storage)

| Archivo | Cambio en código |
|---------|------------------|
| `lib/core/services/firestore_service.dart` | `getFirstAdvisorUser()`: query `users` con `role == advisor`, limit 1. `getLatestCaseIdForClient(clientId)`: último documento en `cases` por `clientId` + `createdAt`. `saveDocumentMetadata(...)`: insert en colección `documents` con URL, path y estado. |
| `lib/core/services/storage_service.dart` | **Nuevo.** `StorageService.uploadCaseDocument(...)`: `putFile` a `documents/{userId}/{caseFolder}/{uuid}_{nombre}` + `saveDocumentMetadata`; progreso vía callback; `maxFileBytes` 15 MB; `kIsWeb` lanza `UnsupportedError` (subida móvil). |

#### Pantallas — asesor y chat

| Archivo | Cambio en código |
|---------|------------------|
| `lib/features/advisor/presentation/screens/advisor_dashboard_screen.dart` | Chip **En proceso**: cuenta perfiles donde `AppConstants.isCaseInProgress(p.caseStatus)` en lugar de solo “Análisis en proceso”. |
| `lib/features/advisor/presentation/screens/client_detail_screen.dart` | Estado `_updatingStatus`; `DropdownButtonFormField` con `onChanged: null` mientras guarda; `try/finally` en `_updateStatus`; `mounted` tras `_load()`. |
| `lib/features/auth/presentation/screens/client_home_screen.dart` | `_loadAdvisor()` + `_openChatWithAdvisor()`: navega a chat con `otherUserId` = UID real del asesor (no string `'advisor'`). |
| `lib/features/chat/presentation/screens/chat_screen.dart` | `maxLength` en `TextField`, contador `actual/500`, validación en `_sendMessage` con `AppConstants.chatMessageMaxLength`; listener `_onMessageChanged` para refrescar contador. Atrás: en código actual `context.pop()` (si se desea mismo patrón que otras pantallas, cambiar a `popOrGo` + `AppRoutes.clientHome`). |

#### Pantallas — flujo cliente (entrevista, calculadora, simulador, documentos)

| Archivo | Cambio en código |
|---------|------------------|
| `lib/features/interview/presentation/screens/interview_screen.dart` | `_back()` usa `popOrGo(..., clientHome)`; tras guardar perfil: `canPop` → `pop()` + `pushReplacement(calculator)`; si no → `go(calculator)`. |
| `lib/features/calculator/presentation/screens/calculator_screen.dart` | Cabecera atrás con `popOrGo` + `InkWell`; botón vacío “Realizar entrevista” usa `push` (no `go`). |
| `lib/features/simulator/presentation/screens/simulator_screen.dart` | Import `credit_line_params`; getters `_lineParams`, `_maxCredit` con tope por línea; `_syncLineParamsFromSelection` al cambiar chip; sliders de plazo acotados a min/max del producto; atajos `_quickTermPresetMonths()`; `initState` inicializa tasa/plazo según primera línea. |
| `lib/features/documents/presentation/screens/documents_screen.dart` | Lista `_DocItem` con `id` único; validación `_allowedExt`; `_resolveCase()` + `_resolvedCaseFolder`; `StorageService` en guardar; barra `LinearProgressIndicator`; `GradientButton` con `isLoading`; `popOrGo` en atrás. |

#### Configuración del repo y Firebase

| Archivo | Cambio |
|---------|--------|
| `.gitignore` | Entrada `/tools/` para no versionar scripts locales. |
| `pubspec.yaml` | Dependencia directa `path: ^1.9.0` (nombres de archivo seguros en Storage). |
| `storage.rules` | **Nuevo.** Reglas Storage: lectura/escritura solo si `request.auth.uid == userId` en ruta `documents/{userId}/{caseId}/{fileName}`. |
| `docs/REGLAS_DOCUMENTOS_FIRESTORE.md` | **Nuevo.** Fragmento sugerido para reglas de la colección `documents` y nota de índice en `cases`. |

#### Pantallas que aún usan solo `context.pop()` (sin `popOrGo`)

Pueden funcionar bien si siempre se abrieron con `push`; si en algún flujo se usó `go()`, el atrás puede fallar. Archivos típicos: `register_screen.dart`, `payments_screen.dart`, `settings_screen.dart`, `client_detail_screen.dart`, `chat_screen.dart` (cabecera).

> **Rama:** la parte asesor/chat/navegación suele ir en **`kevin-main`**; documentos + Storage + `credit_line_params` + simulador en **`brandon-main`** según cómo hayan mergeado. Ajusta la rama si en tu repo todo está en una sola.

---

## 13. Checkpoint de sesión — subida **Brandon** pendiente (cuando vuelvas)

**Estado guardado:** sesión cerrada aquí; los cambios de código del bloque Brandon (RF08, RF09, RF35, simulador por línea, `storage.rules`, docs, `RESUMEN_ENTREGABLE` sección 12, etc.) están en el **working copy** o en commits locales según lo que hayas hecho — **al volver** sube a la rama **`brandon-main`**.

### Pasos sugeridos (PowerShell, `D:\RiskMobile`)

1. Revisar identidad Git (Brandon): `git config user.name` y `git config user.email` (local del repo o global).
2. Cambiar a rama y traer remoto si aplica:
   ```powershell
   cd D:\RiskMobile
   git fetch origin
   git checkout brandon-main
   git pull origin brandon-main
   ```
3. Si los commits están en otra rama, **merge** o **cherry-pick** lo necesario hacia `brandon-main`.
4. Añadir archivos del bloque Brandon y documentación:
   ```powershell
   git add lib/core/constants/credit_line_params.dart lib/core/services/storage_service.dart lib/core/services/firestore_service.dart lib/features/documents lib/features/simulator storage.rules docs pubspec.yaml .gitignore RESUMEN_ENTREGABLE.md
   ```
   *(Ajusta la lista con `git status`.)*
5. Commit (mensaje claro, sin trailers de IA):
   ```powershell
   git commit -m "feat(documents): RF08 RF09 RF35 Storage y Firestore; simulador por linea de credito"
   ```
6. Push:
   ```powershell
   git push origin brandon-main
   ```

### Después del push (Firebase)

- Desplegar **`storage.rules`** (`firebase deploy --only storage` o consola).
- Fusionar en Firestore las reglas de **`docs/REGLAS_DOCUMENTOS_FIRESTORE.md`** para la colección `documents`.
- Crear índice compuesto en **`cases`** si el cliente lo pide al subir documentos.

---

*Documento de seguimiento del entregable RiskMobile (sesión 1: conexión BD/auth, sesión 2: entrevista RF05-RF10-RF07, sesión 3: cálculo/score/simulador RF13-RF15-RF17, **sesión 4 (22-mar-2026):** RF23-RF25-RF26, navegación, simulador por línea de crédito, RF08-RF09-RF35; **sesión 5 (16-abr-2026):** RF-B1–B4, RF-K1–K4; **sesión 6 (18-abr-2026):** RF-K5–K14, RF-B5–B9, flujo de ramas y merge — ver §15).*

---

## 14. Avance sesión del **16 de abril de 2026** (jueves)

En esta sesión se ejecutaron mejoras funcionales para documentos, CRM asesor, trazabilidad y chat; además se actualizó la documentación de exposición.

### 14.1 Requerimientos implementados en código

| Bloque | Implementación |
|---|---|
| **Brandon (RF-B1)** | Reintento de subida por archivo y reintento masivo de fallidos en documentos. |
| **Brandon (RF-B2)** | Validación de calidad de imagen antes de subir (tamaño y resolución mínima). |
| **Brandon (RF-B3)** | Previsualización de adjuntos (imagen + metadato PDF). |
| **Brandon (RF-B4)** | Historial de documentos por caso desde historial de evaluaciones. |
| **Kevin (RF-K1)** | Trazabilidad de cambios de estado de caso en subcolección histórica. |
| **Kevin (RF-K4)** | Notificación al cliente cuando el asesor cambia estado del caso + badge de no leídas. |
| **Kevin (RF-K2)** | Filtros avanzados en CRM: monto, fecha y multiestado. |
| **Kevin (RF-K3)** | Plantillas rápidas de chat con inserción y control de longitud. |

### 14.2 Flujo para mostrar en exposición

1. Cliente abre `Mis documentos` y prueba subida/errores/reintento/previsualización.  
2. Cliente abre `Historial de evaluaciones` y consulta documentos del caso.  
3. Asesor abre `Detalle de cliente`, cambia estado y muestra historial de cambios.  
4. Cliente vuelve a Home y muestra badge de notificaciones no leídas.  
5. Asesor abre CRM y usa filtros avanzados.  
6. En chat, asesor usa plantillas rápidas.

### 14.3 Archivos modificados hoy

- `README.md`
- `RESUMEN_PARA_EXPOSICION_RAMOS.md`
- `lib/core/constants/app_constants.dart`
- `lib/core/services/firestore_service.dart`
- `lib/core/services/storage_service.dart`
- `lib/features/advisor/presentation/screens/advisor_dashboard_screen.dart`
- `lib/features/advisor/presentation/screens/client_detail_screen.dart`
- `lib/features/auth/presentation/screens/client_home_screen.dart`
- `lib/features/chat/presentation/screens/chat_screen.dart`
- `lib/features/documents/presentation/screens/documents_screen.dart`
- `lib/features/history/presentation/screens/evaluations_history_screen.dart`

### 14.4 Archivos creados hoy

- No se crearon archivos nuevos en esta sesión; se modificaron archivos existentes.

---

## 15. Avance sesión del **18 de abril de 2026** (sábado)

Resumen de la iteración más reciente alineada con `RESUMEN_PARA_EXPOSICION_RAMOS.md` (§11–11.5).

### 15.1 Requerimientos en código

| Bloque | IDs | Resumen breve |
|--------|-----|-----------------|
| **Kevin** | RF-K5 a RF-K9 | Nota interna asesor, búsqueda por ID de caso, orden de lista CRM, copiar resumen del caso, chip +7 d sin cambios. |
| **Brandon** | RF-B5 a RF-B9 | Checklist de soportes, optimización JPEG previa a subida, aviso reenvío documento, progreso extractos por obligación, abrir URL en historial; dependencia `image`. |
| **Kevin** | RF-K10 a RF-K14 | Prioridad de caso, filtro “Solo prioridad”, snippet de nota en tarjeta CRM, contador documentos pendientes de revisión, export TSV; contacto WhatsApp si hay teléfono en `users`. |

### 15.2 Ramas Git y merge

- **`kevin-main`:** commits propios del bloque asesor (Kevin) y `chore` de `.gitignore` (carpeta `.cursor/` no versionada).
- **`brandon-main`:** misma base que Kevin más el commit **`feat(brandon): …`** (documentos).
- **`kevin-main`** incorporó documentos mediante **merge** desde `brandon-main` (`Merge brandon-main: sincronizar RF-B5 a RF-B9 en linea kevin-main`) para tener el mismo código al probar la app.
- Documentación del flujo: **`RESUMEN_PARA_EXPOSICION_RAMOS.md` §11.5** y este **§15**.

### 15.3 Archivos tocados (referencia)

- Asesor / CRM: `advisor_dashboard_screen.dart`, `client_detail_screen.dart`.
- Servicios / modelo: `firestore_service.dart`, `financial_profile_model.dart`.
- Documentos / historial: `documents_screen.dart`, `evaluations_history_screen.dart`.
- Dependencias: `pubspec.yaml`, `pubspec.lock`.
- Resúmenes: `RESUMEN_PARA_EXPOSICION_RAMOS.md`, `README.md`, este archivo.

### 15.4 Corrección — paso 2 entrevista (obligaciones / deudas)

Tras la exposición se detectó que **no se podía avanzar bien** al declarar **varias** obligaciones: el botón **Continuar** exigía **extracto bancario** en **todas** las filas antes de salir del paso 2, y los índices del listado provocaban errores al eliminar o actualizar filas.

**Ajustes:** en el paso 2 solo se validan entidad, tipo y cuota; los extractos por obligación siguen siendo obligatorios en **Mis documentos** (RF12). Cada obligación nueva lleva `clientRowId` (solo UI) para listas estables; `toFirestore` no persiste ese campo.
