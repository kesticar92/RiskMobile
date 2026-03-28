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

3. Constantes / soporte de arquitectura
- `lib/core/constants/app_constants.dart`
- `lib/core/constants/credit_line_params.dart`
- `lib/core/router/navigation_helpers.dart`

4. Seguridad / despliegue
- `storage.rules`
- `docs/REGLAS_DOCUMENTOS_FIRESTORE.md`

---

## 5) Guion corto para explicar en clase

- En `kevin-main` cerramos el bloque asesor: mejor lectura del pipeline de casos (RF23), cambio de estado robusto (RF25) y chat validado a 500 caracteres con asesor real (RF26).
- En `brandon-main` cerramos el bloque documental: captura por camara, carga por archivo y persistencia segura en Firebase Storage + metadatos en Firestore (RF08, RF09, RF35).
- Como ajuste transversal, reforzamos navegacion (`popOrGo`, vuelta al menu en calculadora/simulador), simulador por linea de credito, historial de evaluaciones y la correccion del paso 1 de la entrevista (Continuar al escribir ingresos sin tener que re-seleccionar la actividad).
- Para probar en clase desde PC: `flutter run -d chrome`, sabiendo que algunas funciones moviles pueden diferir en web.

---

## 6) Pendiente al retomar el proyecto (Git)

**Recordatorio:** hacer **commit y push** en **ambas ramas** cuando vuelvas a trabajar aqui, segun corresponda a cada bloque:

1. Rama **`kevin-main`**: subir cambios del bloque asesor / cliente compartidos que vayan con esa rama (verificar `git config user.name` y `user.email` local si quieres que el autor sea Kevin).
2. Rama **`brandon-main`**: subir cambios del bloque documental / ajustes que vayan con esa rama (verificar identidad local si el autor debe ser Brandon).

Antes de push: `git status`, revisar que no subas `build/`, `.dart_tool/` ni `tools/` salvo que lo hayan acordado expresamente.

