# Resumen para exposicion por ramas

Este documento explica, de forma descriptiva, los ultimos requerimientos desarrollados, en que rama quedaron, en que archivos estan y que comportamiento se puede demostrar en la exposicion.

---

## 1) Rama `kevin-main` - Bloque asesor (RF23, RF25, RF26)

Este bloque se centra en mejorar la gestion del asesor: ver mejor los casos, actualizar estados con feedback visual y sostener un chat mas robusto con validaciones.

### RF23 - CRM asesor: estadisticas y filtro "En proceso"

**Objetivo funcional**
- Mostrar en el panel del asesor una vista mas real del estado de su cartera.
- El conteo "En proceso" no se limita a un unico estado, sino que agrupa los casos no cerrados.

**Cambios en codigo**
- `lib/core/constants/app_constants.dart`
  - Se agrega `isCaseInProgress(String? caseStatus)`.
  - Esta funcion retorna verdadero para casos que no son `Credito aprobado` ni `Credito rechazado`.
- `lib/features/advisor/presentation/screens/advisor_dashboard_screen.dart`
  - El chip estadistico "En proceso" usa `AppConstants.isCaseInProgress(...)` para contar.
  - Se mantiene busqueda por nombre y filtro por estado para navegacion del asesor.

**Impacto en la demo**
- Al cambiar estados de casos, el numero del chip "En proceso" se actualiza con criterio mas consistente.
- Evita inconsistencias de mostrar "En proceso" solo para `Analisis en proceso`.

---

### RF25 - Estado del caso con retroalimentacion de guardado

**Objetivo funcional**
- Permitir que el asesor cambie el estado del caso sin generar dudas sobre si guardo o no.

**Cambios en codigo**
- `lib/features/advisor/presentation/screens/client_detail_screen.dart`
  - Se agrega estado interno `_updatingStatus`.
  - Durante el guardado:
    - aparece indicador de carga junto al titulo del estado;
    - el `DropdownButtonFormField` queda deshabilitado (`onChanged: null`);
    - al finalizar, se muestra `SnackBar` con confirmacion.
  - Se mejora control de ciclo de vida con `mounted` para evitar `setState` fuera de contexto.
- `lib/core/services/firestore_service.dart`
  - `updateCaseStatus(caseId, newStatus)` mantiene la actualizacion en Firestore con `updatedAt`.

**Impacto en la demo**
- Cuando se cambia estado, el asesor ve feedback inmediato y no puede disparar cambios duplicados mientras guarda.

---

### RF26 - Chat asesor/cliente con validaciones

**Objetivo funcional**
- Controlar calidad de mensajes y asegurar que el chat use el asesor real.

**Cambios en codigo**
- `lib/core/constants/app_constants.dart`
  - `chatMessageMaxLength = 500`.
- `lib/features/chat/presentation/screens/chat_screen.dart`
  - `TextField` con `maxLength`.
  - Contador visible de caracteres (`actual/500`).
  - Validacion en `_sendMessage()` para bloquear textos mayores a 500 y notificar por `SnackBar`.
  - Listener de texto (`_onMessageChanged`) para refrescar contador en tiempo real.
- `lib/core/services/firestore_service.dart`
  - `getFirstAdvisorUser()` para resolver el asesor real por rol en Firestore.
- `lib/features/auth/presentation/screens/client_home_screen.dart`
  - El acceso a chat del cliente usa UID real del asesor (ya no `'advisor'` fijo).

**Impacto en la demo**
- El chat no acepta mensajes excesivos.
- El cliente abre conversacion con el asesor correcto segun datos reales de Firestore.

---

### Revision de documentos del caso (asesor)

**Objetivo funcional**
- Ver los soportes subidos por el cliente en el contexto del caso y actualizar su estado de revision.

**Cambios en codigo**
- `lib/core/constants/app_constants.dart`
  - Estados: `documentPendingReview`, `documentApproved`, `documentRejectedNeedsResend` y lista `documentStates`.
- `lib/features/advisor/presentation/screens/client_detail_screen.dart`
  - `StreamBuilder` con `streamCaseDocuments(caseId)`.
  - `DropdownButtonFormField` para cambiar estado; `_updateDocumentStatus` persiste con `updateDocumentStatus`.
  - Si el documento pasa a estado de rechazo que requiere reenvio, se crea notificacion para el cliente (`createNotification`) segun la logica implementada.
- `lib/core/services/firestore_service.dart`
  - `streamCaseDocuments`, `updateDocumentStatus`, `createNotification`.

**Impacto en la demo**
- El asesor muestra documentos en tiempo casi real y cambia aprobado / pendiente / rechazado con trazabilidad en Firestore.

---

### Ajustes de navegacion relacionados (soporte transversal)

**Objetivo funcional**
- Evitar que el boton atras deje de funcionar en flujos donde se usa `go()` y la pila queda vacia.

**Cambios en codigo**
- `lib/core/router/navigation_helpers.dart` (nuevo)
  - `popOrGo(context, fallbackRoute)`: hace `pop` si hay historial; si no, navega a ruta fallback.
  - `popOrHomeAsync(context, ref)`: idem, pero fallback dinamico segun rol.
- Aplicado en:
  - `lib/features/interview/presentation/screens/interview_screen.dart`
  - `lib/features/calculator/presentation/screens/calculator_screen.dart`
  - `lib/features/simulator/presentation/screens/simulator_screen.dart`
  - `lib/features/documents/presentation/screens/documents_screen.dart`

**Impacto en la demo**
- En rutas criticas, el atras siempre resuelve a una pantalla valida.

**Retorno explicito al menu (cliente)**
- `lib/features/calculator/presentation/screens/calculator_screen.dart`
  - Boton **"Volver al menú principal"** con `context.go(AppRoutes.clientHome)` cuando ya hay perfil/resultados, ademas de la flecha atras con `popOrGo(..., clientHome)`.
- `lib/features/simulator/presentation/screens/simulator_screen.dart`
  - Mismo boton al pie de la simulacion para no quedar "atrapado" en el flujo.

**Impacto en la demo**
- Tras generar perfil o revisar simulacion, el cliente tiene un camino claro al inicio sin depender solo del historial del navegador o del boton atras.

---

### Entrevista financiera - habilitar **Continuar** al completar el paso 1

**Problema observado**
- En **actividad economica**, la opcion se veia seleccionada y los campos de antigüedad e ingreso estaban llenos, pero **Continuar** seguia deshabilitado hasta volver a tocar empleado/independiente/otro.

**Causa tecnica**
- El boton inferior usa `_canProceed`, que lee `_seniorityCtrl` e `_incomeCtrl`. Escribir en esos campos **no disparaba** `setState` en el `State` de la pantalla, asi que la UI no recalculaba la condicion. Un segundo tap en la actividad si llamaba `setState` y ahi el boton se habilitaba.

**Cambios en codigo**
- `lib/features/interview/presentation/screens/interview_screen.dart`
  - En `initState`: listeners en `_seniorityCtrl`, `_incomeCtrl` y `_desiredAmountCtrl` que hacen `setState` al cambiar el texto (misma idea para el monto deseado en el paso 3).
  - En `dispose`: se remueven los listeners antes de liberar los controladores.
  - La animacion de entrada (`fadeIn` / `slideX` de `flutter_animate`) se aplica solo al `AnimatedContainer` de cada fila, **no** envolviendo el `GestureDetector`, y se usa `HitTestBehavior.opaque` para un area de toque consistente.

**Impacto en la demo**
- Flujo del paso 1 coherente: al elegir actividad, contrato (si aplica), meses e ingreso, **Continuar** se activa en cuanto las reglas de validacion se cumplen, sin gestos duplicados.

---

## 1c) Rama `kevin-main` — Entrega abril 2026: seguridad, preferencias y CRM (RF03, RF24, RF33, RF34)

Esta entrega amplia el bloque asesor/transversal: desbloqueo con biometria cuando hay sesion activa, preferencias persistidas y mas contexto de entrevista en la ficha del cliente.

### RF03 y RF34 — Biometria al iniciar y switch en Configuracion

**Objetivo funcional**
- Tras iniciar sesion, el usuario puede activar biometria; en siguientes aperturas de la app, si Firebase mantiene la sesion, se exige validacion con `local_auth` antes de entrar al panel.
- El switch en Configuracion persiste en almacenamiento local y comprueba que el dispositivo permita biometria antes de activar.

**Cambios en codigo**
- `lib/core/services/user_preferences.dart` (nuevo): claves `pref_biometric_enabled`, `pref_notifications_push`, `pref_notifications_email`.
- `lib/core/services/auth_service.dart`: `canUseBiometrics`; `authenticateWithBiometrics` usa esa comprobacion.
- `lib/features/auth/presentation/screens/splash_screen.dart`: tras el splash, si hay usuario y biometria activada, prompt biométrico; si falla, tarjeta **Reintentar** / **Cerrar sesion**.
- `lib/features/auth/presentation/screens/login_screen.dart`: boton de acceso biométrico alineado con preferencia y mensajes si no hay sesion o biometria desactivada.
- `lib/features/settings/presentation/screens/settings_screen.dart`: pantalla con estado cargado desde preferencias; switches funcionales para biometria (con prueba al activar) y notificaciones.

**Impacto en la demo**
- Activar biometria en Configuracion, cerrar y reabrir la app: se pide huella/rostro antes del dashboard.
- Desactivar biometria: entrada directa tras splash si la sesion sigue viva.

---

### RF33 — Preferencias de notificaciones (push y correo)

**Objetivo funcional**
- Dejar guardada la intencion del usuario sobre alertas; base para integrar FCM o correo mas adelante.

**Cambios en codigo**
- Misma pantalla de Configuracion: switches **Notificaciones push** y **Notificaciones por correo** con `SnackBar` de confirmacion.

**Impacto en la demo**
- Mostrar que las opciones se mantienen al salir y volver a Configuracion.

---

### RF24 — Perfil financiero del cliente: bloque "Datos de la entrevista"

**Objetivo funcional**
- Que el asesor vea en un solo lugar actividad economica, tipo de contrato, antigüedad, producto de interes y cantidad de obligaciones declaradas, ademas de las cifras del perfil.

**Cambios en codigo**
- `lib/features/advisor/presentation/screens/client_detail_screen.dart`
  - Tarjeta **Datos de la entrevista** antes del resumen numerico.
  - En **Perfil financiero** se priorizan ingresos, cuotas, capacidad y monto deseado (sin duplicar actividad/tipo de credito ya mostrados arriba).
  - En cada obligacion, si existe, se muestra el nombre del **extracto bancario** adjunto en entrevista (ver RF12).

**Impacto en la demo**
- Abrir un cliente desde el CRM y narrar entrevista + numeros en orden logico.

**Commit de referencia en `origin/kevin-main`:** `ab61843`.

---

## 2) Rama `brandon-main` - Bloque documental y storage (RF08, RF09, RF35)

Este bloque cubre captura/seleccion de soportes, subida a nube de forma estructurada y registro de evidencia en Firestore.

### RF08 - Carga de documentos por camara / galeria

**Objetivo funcional**
- Permitir al cliente adjuntar soportes desde el dispositivo rapidamente.

**Cambios en codigo**
- `lib/features/documents/presentation/screens/documents_screen.dart`
  - Boton "Tomar foto" con `image_picker`.
  - Boton "Galeria" con seleccion de imagen.
  - Validacion de extensiones permitidas.
  - Lista de documentos adjuntados con icono por tipo y opcion de eliminar.

**Impacto en la demo**
- El cliente puede capturar o seleccionar imagenes y verlas en una lista previa antes de subir.

---

### RF09 - Carga desde archivo nativo (PDF/imagen)

**Objetivo funcional**
- Permitir seleccionar archivos existentes del telefono/equipo.

**Cambios en codigo**
- `lib/features/documents/presentation/screens/documents_screen.dart`
  - `file_picker` con extensiones permitidas: `pdf`, `jpg`, `jpeg`, `png`.
  - Rechazo de formato no valido con mensaje claro.

**Impacto en la demo**
- Se puede adjuntar un PDF o imagen desde almacenamiento local sin pasar por camara.

---

### RF35 - Almacenamiento seguro en Firebase Storage por usuario/caso

**Objetivo funcional**
- Guardar documentos de forma organizada y trazable, separando por usuario y caso.

**Cambios en codigo**
- `lib/core/services/storage_service.dart` (nuevo)
  - `uploadCaseDocument(...)`:
    - sube archivo a `documents/{userId}/{caseId}/{uuid}_{nombre}`;
    - reporta progreso;
    - valida tamaño maximo (15 MB);
    - define `contentType`;
    - obtiene `downloadUrl`.
- `lib/core/services/firestore_service.dart`
  - `saveDocumentMetadata(...)` para persistir metadatos en coleccion `documents`.
  - `getLatestCaseIdForClient(...)` para asociar documentos al ultimo caso cuando no viene `caseId`.
- `lib/features/documents/presentation/screens/documents_screen.dart`
  - Integracion completa con StorageService.
  - Barra de progreso (`LinearProgressIndicator`) y estado `_uploading`.
  - Resolucion de carpeta de caso: id real o `pending`.
- `storage.rules` (nuevo)
  - Reglas de acceso por ruta de usuario (`request.auth.uid == userId`).
- `docs/REGLAS_DOCUMENTOS_FIRESTORE.md` (nuevo)
  - Guia de regla para coleccion `documents` en Firestore.

**Impacto en la demo**
- Al pulsar "Guardar y subir documentos", se ve progreso real y los soportes quedan en Storage con estructura ordenada por usuario/caso.

---

## 2c) Misma linea cliente — Entrega abril 2026 (RF12, RF14, RF21, RF22)

Cambios en entrevista y en pantalla de perfil financiero (calculadora) alineados con el README; el codigo se integro en `kevin-main` y debe estar tambien en `brandon-main` tras merge entre ramas.

### RF12 — Extracto bancario por obligacion (entrevista paso 2)

**Objetivo funcional**
- Asociar a cada obligacion declarada un soporte de extracto (PDF o imagen) mediante selector de archivos.

**Cambios en codigo**
- `lib/shared/models/financial_profile_model.dart`: campo opcional `bankExtractFileName` en `FinancialObligation` (map Firestore `bankExtractFileName`).
- `lib/features/interview/presentation/screens/interview_screen.dart`
  - Cada fila de obligacion: boton **Adjuntar** / **Cambiar** con `FilePicker` (`pdf`, `jpg`, `jpeg`, `png`).
  - Validacion de paso: si hay obligaciones, cada una debe tener extracto antes de **Continuar**.
  - `didUpdateWidget` en la pagina de obligaciones para mantener lista local al desactivar obligaciones.

**Impacto en la demo**
- Agregar dos obligaciones y adjuntar extracto a cada una; el asesor ve el nombre del archivo en detalle de cliente.

---

### RF14 — Formula explicita de capacidad disponible (40% ingresos)

**Objetivo funcional**
- Mostrar la regla `(Ingresos × 40%) − Total cuotas = Capacidad disponible` con valores reales del caso.

**Cambios en codigo**
- `lib/features/calculator/presentation/screens/calculator_screen.dart`
  - `GlassCard` con texto que usa `AppConstants.debtCapacityLimit` y formateo de montos.

**Impacto en la demo**
- En perfil financiero, leer la tarjeta en voz alta enlazando con la metrica de capacidad.

---

### RF21 — Monto deseado (paso 3 entrevista)

**Objetivo funcional**
- Aclarar que 0 es valido; si el cliente ingresa monto, minimo razonable (`$1.000` COP) para evitar basura.

**Cambios en codigo**
- `interview_screen.dart`: texto de ayuda bajo el campo; `_canProceed` en paso 3 coherente con esa regla.

**Impacto en la demo**
- Probar 0 y un monto menor a 1000 para mostrar bloqueo del boton **Calcular mi perfil financiero**.

---

### RF22 — Comparacion visual deseado vs viable (perfil financiero)

**Objetivo funcional**
- Barras de progreso que comparan monto deseado con un monto viable de referencia (usa `estimatedViableAmount` del simulador si existe; si no, referencia derivada de la capacidad).

**Cambios en codigo**
- `calculator_screen.dart`: widget de barras dentro del bloque de analisis de capacidad cuando `desiredAmount > 0`.

**Impacto en la demo**
- Completar entrevista con monto deseado, abrir calculadora y mostrar barras; opcionalmente actualizar viable desde simulador y repetir.

**Commit de referencia (mismo que bloque Kevin en remoto):** `ab61843` en `origin/kevin-main`; en `brandon-main` queda reflejado tras merge.

---

## 3) Simulador - cupo por linea de credito (ultimo ajuste funcional)

Este ajuste se hizo para que el cupo no sea un numero plano: depende del producto elegido.

**Objetivo funcional**
- Recalcular cupo maximo y monto viable segun linea de credito seleccionada.

**Cambios en codigo**
- `lib/core/constants/credit_line_params.dart` (nuevo)
  - Define parametros por producto: tasa de referencia, plazo min/max/default y tope opcional.
- `lib/features/simulator/presentation/screens/simulator_screen.dart`
  - Usa esos parametros por linea seleccionada.
  - Recalcula cupo al cambiar tipo de credito.
  - Ajusta sliders y presets al rango permitido por producto.
  - Muestra etiqueta de cupo maximo contextual por linea.

**Impacto en la demo**
- Cambiar la linea de credito modifica inmediatamente el cupo mostrado y el rango de simulacion.

**Nota relacionada (cliente)**
- En el simulador se agrego accion para **guardar simulacion** ligada al caso en Firestore y texto de viabilidad (brecha estimada), ademas del boton de retorno al menu descrito en navegacion.

---

## 3b) Historial de evaluaciones (cliente)

**Objetivo funcional**
- Ver evaluaciones financieras previas del usuario y reabrir la calculadora con contexto.

**Cambios en codigo**
- `lib/features/history/presentation/screens/evaluations_history_screen.dart`
  - Lista con `streamClientProfiles` y navegacion a la ruta de calculadora con el id del perfil.
- `lib/core/services/firestore_service.dart`
  - `streamClientProfiles(clientId)` para listar perfiles del cliente en tiempo real.
- `lib/core/router/app_router.dart` y `lib/features/auth/presentation/screens/client_home_screen.dart`
  - Ruta y acceso desde el menu del cliente ("Historial de evaluaciones").

**Impacto en la demo**
- El cliente puede demostrar trazabilidad de varias evaluaciones sin repetir entrevista desde cero.

---

## 3c) Prueba en navegador (Chrome / Web)

**Objetivo**
- Revisar la app desde el escritorio con `flutter run -d chrome`.

**Contexto del proyecto**
- Se habilito la plataforma **Web** en el repo (carpeta `web/` con `index.html`, iconos, `manifest.json`), manteniendo `firebase_options.dart` con bloque `web` para Firebase.

**Comando habitual**
- `flutter run -d chrome`

**Advertencia para la demo**
- Funciones como biometria (`local_auth`) o camara pueden comportarse distinto en web respecto a Android/iOS; el flujo documental y la entrevista conviene validarlos en el target principal del producto.

---

## 4) Archivos clave para mostrar en exposicion

Si te piden "donde esta eso en codigo", muestra estos archivos en este orden:

1. Pantalla (UI y flujo)
- `lib/features/auth/presentation/screens/splash_screen.dart`
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/settings/presentation/screens/settings_screen.dart`
- `lib/features/advisor/presentation/screens/advisor_dashboard_screen.dart`
- `lib/features/advisor/presentation/screens/client_detail_screen.dart`
- `lib/features/chat/presentation/screens/chat_screen.dart`
- `lib/features/documents/presentation/screens/documents_screen.dart`
- `lib/features/simulator/presentation/screens/simulator_screen.dart`
- `lib/features/auth/presentation/screens/client_home_screen.dart`
- `lib/features/interview/presentation/screens/interview_screen.dart`
- `lib/features/calculator/presentation/screens/calculator_screen.dart`
- `lib/features/history/presentation/screens/evaluations_history_screen.dart`

2. Servicios (reglas de negocio / persistencia)
- `lib/core/services/firestore_service.dart`
- `lib/core/services/storage_service.dart`
- `lib/core/services/user_preferences.dart` (preferencias locales: biometria, notificaciones)

3. Constantes / soporte de arquitectura
- `lib/core/constants/app_constants.dart`
- `lib/core/constants/credit_line_params.dart`
- `lib/core/router/navigation_helpers.dart`

4. Seguridad / despliegue
- `storage.rules`
- `firestore.rules` (reglas generales del proyecto en repo; desplegar con Firebase segun entorno)
- `docs/REGLAS_DOCUMENTOS_FIRESTORE.md`

---

## 5) Sincronizacion de ramas (estado actual Git)

Tras los ultimos entregables:

- **`kevin-main`**: ademas del merge historico con `brandon-main`, incluye la entrega **abril 2026** (`ab61843` en `origin/kevin-main`): RF03, RF12, RF14, RF21, RF22, RF24, RF33, RF34 (autor de commit **KEvin3162** / correo Kevin).
- **`brandon-main`**: debe incorporar el mismo codigo aplicativo mediante **merge** desde `kevin-main` cuando el equipo sincronice ramas; este resumen (`RESUMEN_PARA_EXPOSICION_RAMOS.md`) puede actualizarse en `brandon-main` con el merge o un commit de documentacion (autor **Brandon** segun `git config` local al subir).

Referencias historicas utiles:

- Merge previo Kevin + Brandon: `c0961c5` (linea documental previa `d05ef89`).

**Para la exposicion:** con las ramas sincronizadas, el **codigo** es el mismo; difieren **autoria y orden de commits** en el historial.

---

## 6) Guion corto para explicar en clase

- Bloque **asesor**: pipeline de casos (RF23), estado del caso con feedback (RF25), chat limitado y asesor real (RF26), revision de documentos del caso con estados y notificacion cuando aplica; **abril 2026:** biometria y preferencias (RF03/34/33), bloque entrevista en detalle (RF24).
- Bloque **documental / cliente**: RF08, RF09, RF35 (Storage + metadatos), simulador por linea de credito, guardado de simulacion y texto de viabilidad, historial de evaluaciones; **abril 2026:** extractos por obligacion (RF12), formula capacidad y barras deseado/viable (RF14/22), monto deseado (RF21).
- **UX transversal:** `popOrGo`, vuelta explicita al menu en calculadora y simulador, paso 1 de entrevista sin tener que re-elegir actividad para habilitar Continuar.
- **Demo en PC:** `flutter run -d chrome` (Firebase Web ya configurado); validar camara/biometria principalmente en movil.

---

## 7) Buenas practicas para siguientes cambios (Git)

1. Antes de commitear: `git status`; `git config user.name` y `user.email` en el repo si alternan Kevin / Brandon.
2. No versionar de forma accidental `build/`, `.dart_tool/` ni `tools/` (salvo acuerdo del equipo).
3. Tras resolver conflictos entre ramas, conviene `dart analyze` y una pasada rapida del flujo entrevista → calculadora → documentos en el target de demo.

---

## 8) Propuesta de nuevos requerimientos (siguiente iteracion)

Este bloque deja una propuesta clara de **4 requerimientos para `kevin-main`** y **4 requerimientos para `brandon-main`**, manteniendo la linea funcional ya trabajada.

### 8.1) Nuevos requerimientos para `kevin-main` (asesor + experiencia operativa)

### RF-K1 - Trazabilidad de cambios de estado del caso (auditoria)

**Objetivo funcional**
- Registrar quien cambio el estado del caso, cuando y desde que estado a cual.

**Cambios en codigo (propuestos)**
- `lib/core/services/firestore_service.dart`
  - Nuevo metodo `appendCaseStatusHistory(caseId, fromStatus, toStatus, changedByUid)`.
- `lib/features/advisor/presentation/screens/client_detail_screen.dart`
  - Al confirmar cambio de estado, guardar entrada en subcoleccion `caseStatusHistory`.
  - Nueva seccion "Historial de estados" ordenada por fecha desc.

**Impacto en la demo**
- El asesor puede demostrar evidencia de trazabilidad y control del ciclo del caso.

---

### RF-K2 - Filtros avanzados en CRM asesor (fecha, monto y estado)

**Objetivo funcional**
- Reducir tiempo de busqueda de casos con filtros combinados y persistidos en pantalla.

**Cambios en codigo (propuestos)**
- `lib/features/advisor/presentation/screens/advisor_dashboard_screen.dart`
  - Filtros por rango de fecha, rango de monto y estados multiples.
  - Chips activos con opcion "Limpiar todo".
- `lib/core/services/firestore_service.dart`
  - Consulta optimizada para filtros principales y fallback local para combinaciones complejas.

**Impacto en la demo**
- El asesor localiza rapidamente casos especificos (ejemplo: "En proceso", > 8M, ultimos 30 dias).

---

### RF-K3 - Plantillas rapidas de mensaje en chat asesor/cliente

**Objetivo funcional**
- Estandarizar respuestas frecuentes (solicitud de documentos, estado de revision, observaciones).

**Cambios en codigo (propuestos)**
- `lib/features/chat/presentation/screens/chat_screen.dart`
  - Boton "Plantillas" con selector modal.
  - Insercion en caja de texto editable antes de enviar.
- `lib/core/constants/app_constants.dart`
  - Lista inicial de plantillas y limite de longitud compatible con RF26.

**Impacto en la demo**
- El asesor responde mas rapido y con mensajes consistentes.

---

### RF-K4 - Notificacion interna al cliente por cambio de estado del caso

**Objetivo funcional**
- Informar al cliente automaticamente cuando su caso cambia de estado relevante.

**Cambios en codigo (propuestos)**
- `lib/core/services/firestore_service.dart`
  - Reutilizar/expandir `createNotification` con tipo `case_status_changed`.
- `lib/features/advisor/presentation/screens/client_detail_screen.dart`
  - Al guardar estado, disparar notificacion con titulo + resumen.
- `lib/features/auth/presentation/screens/client_home_screen.dart`
  - Badge de notificaciones pendientes en menu principal.

**Impacto en la demo**
- Al cambiar estado desde asesor, el cliente ve alerta en su panel sin refrescos manuales.

---

### 8.2) Nuevos requerimientos para `brandon-main` (documentos + cliente)

### RF-B1 - Reintento de subida de documentos fallidos

**Objetivo funcional**
- Evitar perdida de avance cuando falla red o se interrumpe la carga.

**Cambios en codigo (propuestos)**
- `lib/features/documents/presentation/screens/documents_screen.dart`
  - Estado por archivo: pendiente, subiendo, error, completado.
  - Boton "Reintentar" solo en items con error.
- `lib/core/services/storage_service.dart`
  - Manejo de excepciones tipificadas y callback de progreso por archivo.

**Impacto en la demo**
- Si una carga falla, el usuario reintenta ese documento sin repetir toda la operacion.

---

### RF-B2 - Validacion de calidad basica para imagenes de soporte

**Objetivo funcional**
- Reducir rechazos por fotos borrosas o muy oscuras antes de subir.

**Cambios en codigo (propuestos)**
- `lib/features/documents/presentation/screens/documents_screen.dart`
  - Reglas de validacion cliente: peso minimo, dimensiones minimas y aviso preventivo.
- `lib/core/services/storage_service.dart`
  - Bloqueo de subida si incumple criterios criticos y mensaje claro al usuario.

**Impacto en la demo**
- El cliente recibe feedback inmediato y mejora calidad documental antes de enviar.

---

### RF-B3 - Previsualizacion de documentos adjuntos (PDF/imagen)

**Objetivo funcional**
- Verificar contenido del soporte antes de subirlo a Storage.

**Cambios en codigo (propuestos)**
- `lib/features/documents/presentation/screens/documents_screen.dart`
  - Tap en item abre previsualizacion.
  - Imagen: visor full-screen; PDF: visor embebido o pagina inicial con metadatos.
- `pubspec.yaml`
  - Dependencia de visor liviano para PDF/imagen segun stack del proyecto.

**Impacto en la demo**
- El cliente confirma que adjunto el archivo correcto y reduce errores de carga.

---

### RF-B4 - Historial de cargas documentales por caso

**Objetivo funcional**
- Mostrar evidencia de que documentos se subieron, cuando y con que estado.

**Cambios en codigo (propuestos)**
- `lib/core/services/firestore_service.dart`
  - `streamCaseDocuments(caseId)` extendido con orden y estado de proceso.
- `lib/features/history/presentation/screens/evaluations_history_screen.dart`
  - Acceso a detalle documental por caso.
- `lib/features/documents/presentation/screens/documents_screen.dart`
  - Seccion "Ultimas cargas" con fecha, tipo y estado.

**Impacto en la demo**
- El cliente y el asesor pueden consultar trazabilidad documental del caso de punta a punta.

---

## 9) Sugerencia de asignacion por sprint

- **Sprint 1 (Kevin):** RF-K1 y RF-K4 (trazabilidad + notificaciones de estado).
- **Sprint 1 (Brandon):** RF-B1 y RF-B3 (reintento + previsualizacion).
- **Sprint 2 (Kevin):** RF-K2 y RF-K3 (filtros avanzados + plantillas).
- **Sprint 2 (Brandon):** RF-B2 y RF-B4 (calidad de imagen + historial documental).

---

## 10) Ejecucion real completada hoy (16/04/2026)

En esta fecha se implemento codigo funcional sobre `brandon-main` para los requerimientos propuestos en la seccion 8.

### Brandon-main — RF-B1, RF-B2, RF-B3, RF-B4 (implementados)

**RF-B1 - Reintento de subida**
- `documents_screen.dart`: estado por archivo (`pending`, `uploading`, `completed`, `error`), reintento individual y reintento masivo de fallidos.
- `storage_service.dart`: subida robusta por `path` o `bytes` segun plataforma.

**RF-B2 - Validacion de calidad**
- `documents_screen.dart`: validaciones previas de tamaño y resolucion minima para imagenes antes de subir.

**RF-B3 - Previsualizacion**
- `documents_screen.dart`: previsualizacion de imagen en dialogo; PDF con vista de metadato previa al envio.

**RF-B4 - Historial documental por caso**
- `firestore_service.dart`: stream de documentos por `userId + caseId`.
- `evaluations_history_screen.dart`: boton "Ver documentos del caso" y listado en bottom sheet.

### Kevin-main — RF-K1, RF-K4, RF-K2, RF-K3 (implementados)

**RF-K1 - Trazabilidad de cambio de estado**
- `firestore_service.dart`: `appendCaseStatusHistory(...)` y `streamCaseStatusHistory(...)`.
- `client_detail_screen.dart`: registro de cambios y bloque visual de historial.

**RF-K4 - Notificacion por cambio de estado**
- `client_detail_screen.dart`: al cambiar estado crea notificacion `case_status_changed`.
- `firestore_service.dart`: soporte de conteo no leido (`streamUnreadNotificationCount`).
- `client_home_screen.dart`: badge de notificaciones pendientes.

**RF-K2 - Filtros avanzados CRM**
- `advisor_dashboard_screen.dart`: filtros por rango de monto, ultimos 7/30/90 dias, multiestado y accion "Limpiar todo".

**RF-K3 - Plantillas rapidas de chat**
- `app_constants.dart`: catalogo `advisorChatTemplates`.
- `chat_screen.dart`: modal de plantillas e insercion en input con control de longitud.

### Rutas de demo para exposicion (hoy)

1. Cliente: `/documents` (subida, error, reintento, previsualizacion).
2. Cliente: `/evaluations-history` (ver documentos por caso).
3. Asesor: `/client-detail` (cambio de estado + historial + notificacion).
4. Cliente: `/client-home` (badge de no leidas).
5. Asesor: `/advisor-dashboard` (filtros avanzados).
6. Chat: `/chat` (plantillas rapidas).

### Archivos modificados hoy (16/04/2026)

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

**Archivos nuevos creados hoy:** no se crearon archivos nuevos en esta iteracion; se trabajaron modificaciones sobre archivos existentes.

### Nota de autoria en `kevin-main` (16/04/2026)

Para dejar trazabilidad de autoria en historial Git de la rama `kevin-main`, este resumen registra como bloque Kevin implementado e integrado en esta iteracion:

- **RF-K1:** trazabilidad de estado de caso.
- **RF-K2:** filtros avanzados en CRM asesor.
- **RF-K3:** plantillas rapidas en chat.
- **RF-K4:** notificacion al cliente por cambio de estado.

---

## 11) Segunda oleada — 5 requerimientos `kevin-main` (RF-K5–K9) y 5 `brandon-main` (RF-B5–B9) — 18/04/2026

Implementación en código sobre la misma base; para **autoría Git** conviene que Kevin haga commit/push en `kevin-main` de los archivos del bloque asesor y Brandon en `brandon-main` del bloque documentos (o merge cruzado según acuerden).

### 11.1) `kevin-main` — RF-K5 a RF-K9

| ID | Nombre | Qué hace |
|----|--------|------------|
| **RF-K5** | Nota interna del asesor | Campo `advisorInternalNote` / `advisorNoteUpdatedAt` en el caso; editor y guardado en detalle de cliente (`client_detail_screen.dart`); método `updateCaseAdvisorNote` en `firestore_service.dart`. |
| **RF-K6** | Búsqueda por ID de caso | En CRM, el buscador coincide también con `profile.id` (`advisor_dashboard_screen.dart`). |
| **RF-K7** | Orden de lista CRM | Chips **Última actualización** (desc) y **Nombre A–Z** (`_ClientSort` en `advisor_dashboard_screen.dart`). |
| **RF-K8** | Copiar resumen del caso | Botón en cabecera de detalle; texto plano con datos clave vía portapapeles (`Clipboard`). |
| **RF-K9** | Indicador de caso “estancado” | En tarjeta de cliente, chip **+7 d sin cambios** si `updatedAt` tiene 7 días o más (`_ClientCard`). |

**Archivos típicos:** `lib/features/advisor/presentation/screens/advisor_dashboard_screen.dart`, `lib/features/advisor/presentation/screens/client_detail_screen.dart`, `lib/core/services/firestore_service.dart`, `lib/shared/models/financial_profile_model.dart` (solo lectura de campos de nota).

### 11.2) `brandon-main` — RF-B5 a RF-B9

| ID | Nombre | Qué hace |
|----|--------|------------|
| **RF-B5** | Checklist de soportes clave | Barra y chips por tipo (extracto, certificado, RUT, pensión) combinando cola local + documentos ya en Firestore (`documents_screen.dart`). |
| **RF-B6** | Optimización de imagen antes de subir | Si la imagen supera ~350 KB, reescala ancho máx. 1600 px y reencode JPEG calidad 82 cuando reduce tamaño (`package:image`, `documents_screen.dart`). |
| **RF-B7** | Abrir documento histórico | En el bottom sheet de historial de evaluaciones, botón para abrir `downloadUrl` con `url_launcher` (`evaluations_history_screen.dart`). |
| **RF-B8** | Aviso de reenvío de documento | Banner en pantalla de documentos si hay notificación no leída tipo `document_rejected` (`streamHasUnreadDocumentRejected` en `firestore_service.dart`). |
| **RF-B9** | Progreso visual de extractos por obligación | Bloque con título, barra de progreso y texto guía cuando aplica `_requiresBankStatement` (`documents_screen.dart`). |

**Dependencia nueva:** `image` en `pubspec.yaml` (compresión/resize RF-B6).

### 11.3) Demo sugerida

1. Asesor: CRM — buscar por ID, ordenar, ver chip +7 d, abrir caso — nota interna — copiar resumen.
2. Cliente: Documentos — checklist, banner reenvío (tras rechazo desde asesor), barra de extractos, subir imagen grande y verificar peso.
3. Cliente: Historial — ver documentos del caso — abrir enlace.

### 11.4) Tercera tanda solo `kevin-main` — RF-K10 a RF-K14

| ID | Nombre | Qué hace |
|----|--------|------------|
| **RF-K10** | Prioridad alta en cartera | Campo `casePriority` en el caso; `updateCasePriority` en `firestore_service.dart`; interruptor en detalle de cliente. No se incluye en `toFirestore()` del perfil cliente para no pisar el flag al guardar entrevista. |
| **RF-K11** | Filtro “Solo prioridad” | `FilterChip` en CRM con conteo de casos prioritarios; se limpia con “Limpiar todo” (`advisor_dashboard_screen.dart`). |
| **RF-K12** | Vista previa de nota interna en tarjeta | Si existe `advisorInternalNote`, se muestra un renglón corto en la tarjeta del listado (`_ClientCard`). |
| **RF-K13** | Contador documentos pendientes de revisión | En detalle de cliente, tarjeta con stream de documentos del caso y conteo con estado `Pendiente de revisión` (`client_detail_screen.dart`). |
| **RF-K14** | Copiar listado filtrado (TSV) | Botón que copia al portapapeles columnas separadas por tabulador (Excel/Sheets) de la vista filtrada actual (`advisor_dashboard_screen.dart`). |

**Contacto WhatsApp (apoyo a K13/K10 en demo):** si el cliente tiene `phone` en `users`, botón “Contactar por WhatsApp” en detalle (`url_launcher`, enlace `wa.me`).

