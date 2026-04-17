# RiskMobile

**Plataforma móvil SaaS de evaluación financiera, simulación crediticia y gestión de asesoría para asesores financieros independientes.**

---

## Cambios del día — 16/04/2026

Esta sección permite identificar rápido lo modificado hoy.

### Modificado hoy (16/04/2026)

- **Subida de documentos (cliente):**
  - Soporte de subida por `bytes` (web) y por `path` (móvil/desktop).
  - Estado por archivo: pendiente, subiendo, completado, error.
  - Reintento por archivo y reintento masivo de fallidos.
  - Previsualización de adjuntos (imagen + metadato PDF).
  - Validación básica de calidad de imagen (tamaño y resolución mínima).
- **Historial documental por caso (cliente):**
  - Consulta de documentos por caso desde historial de evaluaciones.
- **Gestión de estado de caso (asesor):**
  - Trazabilidad del cambio de estado en subcolección `caseStatusHistory`.
  - Notificación al cliente cuando cambia el estado del caso.
  - Visualización del historial de cambios de estado en detalle del cliente.
- **CRM asesor (filtros avanzados):**
  - Filtro por rango de monto (mínimo/máximo).
  - Filtro por fecha (últimos 7/30/90 días).
  - Filtro multiestado con selección múltiple.
  - Acción "Limpiar todo" para reset de filtros avanzados.
- **Chat asesor-cliente (plantillas rápidas):**
  - Botón de plantillas en el input del chat.
  - Inserción de plantilla seleccionada en caja de texto editable.
  - Validación contra límite máximo de caracteres.
- **Home cliente:**
  - Badge de notificaciones pendientes.

### Ruta funcional de lo trabajado hoy

1. **Cliente > Mis documentos (`/documents`)**
   - Adjunta archivos por cámara, galería o archivo.
   - El sistema valida formato, tamaño y calidad mínima (imágenes).
   - Cada archivo queda con estado (`pendiente`, `subiendo`, `completado`, `error`).
   - Si hay error, permite reintento individual o reintento masivo.
2. **Cliente > Historial de evaluaciones (`/evaluations-history`)**
   - En cada caso se puede abrir "Ver documentos del caso".
   - Se listan documentos cargados con tipo y estado.
3. **Asesor > Detalle de cliente (`/client-detail`)**
   - Al cambiar el estado del caso, se registra trazabilidad en historial.
   - Se genera notificación al cliente por cambio de estado.
   - El asesor ve el historial de cambios en la misma pantalla.
4. **Cliente > Home (`/client-home`)**
   - Visualiza badge con conteo de notificaciones no leídas.
5. **Asesor > CRM (`/advisor-dashboard`)**
   - Usa filtros avanzados por monto, fecha y multiestado para encontrar casos.
6. **Chat asesor-cliente (`/chat`)**
   - Inserta plantillas rápidas de mensaje desde modal para respuestas frecuentes.

### Detalle técnico por archivo (qué se cambió)

- `lib/core/services/storage_service.dart`
  - `uploadCaseDocument(...)` ahora soporta subida por `localPath` y `fileBytes`.
  - Soporte real para web usando `putData(...)`.
- `lib/features/documents/presentation/screens/documents_screen.dart`
  - Estados por archivo, reintento individual/masivo, previsualización y validación de calidad.
- `lib/core/services/firestore_service.dart`
  - Nuevos streams/métodos: historial de estado de casos, conteo de notificaciones no leídas y documentos por caso/usuario.
- `lib/features/history/presentation/screens/evaluations_history_screen.dart`
  - Bottom sheet para ver documentos asociados al caso seleccionado.
- `lib/features/advisor/presentation/screens/client_detail_screen.dart`
  - Registro de trazabilidad de estado + creación de notificación al cliente.
  - Bloque visual de historial de cambios de estado.
- `lib/features/auth/presentation/screens/client_home_screen.dart`
  - Badge dinámico de notificaciones no leídas.
- `lib/features/advisor/presentation/screens/advisor_dashboard_screen.dart`
  - Filtros avanzados (monto mínimo/máximo, últimos 7/30/90 días, multiestado, limpiar todo).
- `lib/features/chat/presentation/screens/chat_screen.dart`
  - Botón y modal de plantillas rápidas; inserción en input con validación de longitud.
- `lib/core/constants/app_constants.dart`
  - Catálogo inicial `advisorChatTemplates`.
- `RESUMEN_PARA_EXPOSICION_RAMOS.md`
  - Se agregaron requerimientos nuevos propuestos para Kevin y Brandon.

### Archivos creados hoy (16/04/2026)

- No se crearon archivos nuevos en esta iteración; solo se modificaron archivos existentes.

### Archivos clave tocados hoy

- `lib/core/services/storage_service.dart`
- `lib/features/documents/presentation/screens/documents_screen.dart`
- `lib/core/services/firestore_service.dart`
- `lib/features/history/presentation/screens/evaluations_history_screen.dart`
- `lib/features/advisor/presentation/screens/client_detail_screen.dart`
- `lib/features/advisor/presentation/screens/advisor_dashboard_screen.dart`
- `lib/features/auth/presentation/screens/client_home_screen.dart`
- `lib/features/chat/presentation/screens/chat_screen.dart`
- `lib/core/constants/app_constants.dart`
- `RESUMEN_PARA_EXPOSICION_RAMOS.md`

---

## Cronología y estado de requerimientos

Esta sección consolida el avance histórico por requerimiento, con la mejor fecha disponible en documentación del proyecto.

### Requerimientos realizados (con fecha de trabajo)

| Requerimiento | Estado | Fecha de trabajo | Evidencia breve |
|---|---|---|---|
| RF01 Registro de usuarios | Realizado | Sesión inicial (fecha no registrada) | Registro en Firebase Auth + perfil en Firestore. |
| RF02 Login | Realizado | Sesión inicial (fecha no registrada) | Inicio de sesión por correo/contraseña. |
| RF03 Biometría | Realizado | Entrega abril 2026 | Activación y validación biométrica en flujo de acceso. |
| RF05 Entrevista Paso 1 | Realizado | Sesión previa (fecha no registrada) | Actividad, contrato, antigüedad e ingresos validados. |
| RF07 Entrevista Paso 3 | Realizado | Sesión previa (fecha no registrada) | Monto deseado y tipo de crédito con validaciones. |
| RF08 Carga por cámara | Realizado | 22/03/2026 + 16/04/2026 | Carga por cámara y mejoras de robustez/reintento. |
| RF09 Carga por archivo | Realizado | 22/03/2026 + 16/04/2026 | Selector de archivo PDF/imagen y validaciones. |
| RF10 Obligaciones financieras | Realizado | Sesión previa (fecha no registrada) | Registro dinámico de obligaciones. |
| RF12 Extracto por obligación | Realizado | Entrega abril 2026 | Asociación de extractos por obligación. |
| RF13 Endeudamiento | Realizado | Sesión previa (fecha no registrada) | Cálculo de deuda y capacidad disponible. |
| RF14 Fórmula capacidad 40% | Realizado | Entrega abril 2026 | Visualización explícita de fórmula y valores. |
| RF15 Score RiskMobile | Realizado | Sesión previa (fecha no registrada) | Cálculo de score con variables ponderadas. |
| RF17 Simulador dinámico | Realizado | Sesión previa (fecha no registrada) | Simulación con sliders y cálculo en tiempo real. |
| RF21 Monto deseado | Realizado | Entrega abril 2026 | Regla de 0 válido y mínimo cuando aplica. |
| RF22 Deseado vs viable | Realizado | Entrega abril 2026 | Barras comparativas en perfil financiero. |
| RF23 CRM asesor | Realizado | 22/03/2026 | Panel con métricas, búsqueda y filtros base. |
| RF24 Perfil completo para asesor | Realizado | Entrega abril 2026 | Bloque de datos de entrevista en detalle cliente. |
| RF25 Cambio estado del caso | Realizado | 22/03/2026 + 16/04/2026 | Actualización con feedback y trazabilidad histórica. |
| RF26 Chat asesor-cliente | Realizado | 22/03/2026 + 16/04/2026 | Chat con límite de longitud y plantillas rápidas. |
| RF33 Preferencias de notificación | Realizado | Entrega abril 2026 | Switches de notificación persistidos. |
| RF34 Preferencias biometría | Realizado | Entrega abril 2026 | Configuración biométrica persistida. |
| RF35 Storage seguro documentos | Realizado | 22/03/2026 + 16/04/2026 | Subida a Storage por usuario/caso + metadata. |
| RF36 Recuperar contraseña | Realizado | Sesión inicial (fecha no registrada) | Pantalla y flujo de restablecimiento. |
| RF37 Historial evaluaciones | Realizado | Sesión previa + 16/04/2026 | Historial y consulta documental por caso. |
| RF38 Validación documental asesor | Realizado | Sesión previa (fecha no registrada) | Estados de revisión documental y notificación al cliente. |

### Requerimientos pendientes / por cerrar

| Requerimiento | Estado | Próximo paso sugerido |
|---|---|---|
| RF04 Roles y permisos finos por pantalla | Parcial | Revisión de autorizaciones por ruta y acciones críticas. |
| RF06 Solicitud/almacenamiento de actividad económica | Parcial | Auditoría de campos y consistencia entre entrevista y detalle. |
| RF11 Alta de múltiples obligaciones por formulario dinámico | Parcial | Pruebas de borde y edición/eliminación avanzada. |
| RF16 Clasificación de riesgo completa | Parcial | Validar reglas de color/texto para todos los rangos extremos. |
| RF18 Slider de plazo con presets | Parcial | QA cruzado por cada línea de crédito y límites. |
| RF19 Selector tipo de crédito (6 opciones) | Parcial | Revisar consistencia entre entrevista, simulador y reportes. |
| RF20 Fórmula de cuota francesa y validaciones límite | Parcial | Pruebas con tasas/plazos extremos y redondeos. |
| RF27 Búsqueda + filtro CRM (optimización) | Parcial | Mover filtros avanzados a query server-side progresiva. |
| RF28 Registro de comisiones | Parcial | Completar validaciones de negocio y evidencias en demo. |
| RF29 Panel financiero asesor | Parcial | Verificar totales con casos reales y estados cerrados. |
| RF30 Utilidad neta e historial consolidado | Parcial | Incorporar pruebas de conciliación de cifras. |
| RF31 Estadísticas del asesor | Parcial | Refinar métricas por periodos y estados operativos. |
| RF32 Cierre de sesión en todos los puntos requeridos | Parcial | Validación completa de UX y retorno seguro a login. |

> Nota: "Parcial" significa que existe implementación funcional, pero se recomienda cierre formal con pruebas de aceptación y checklist de demo.

---

## Descripción del Proyecto

RiskMobile es una aplicación móvil multiplataforma (Android/iOS) desarrollada con **Flutter** y **Firebase**, diseñada para realizar preevaluaciones crediticias sin generar consultas en centrales de riesgo. La plataforma conecta a clientes interesados en acceder a créditos con asesores financieros independientes, proporcionando herramientas de evaluación financiera, simulación de crédito y gestión integral del negocio de asesoría.

### Problema

Muchas personas realizan múltiples solicitudes de crédito sin conocer previamente su viabilidad financiera, generando huellas innecesarias en centrales de riesgo, deterioro del score crediticio y procesos ineficientes. No existen aplicaciones móviles que integren simultáneamente simulación financiera, evaluación preliminar de riesgo, interacción asesor-cliente y seguridad robusta.

### Solución

RiskMobile integra en una sola plataforma:
- **Entrevista financiera digital** con carga de documentos (foto/archivo)
- **Motor de evaluación financiera** con Score RiskMobile propio (0-100)
- **Simulador dinámico de crédito** con sliders interactivos
- **CRM para asesores financieros** con gestión de clientes y casos
- **Sistema de comunicación** asesor-cliente en tiempo real
- **Módulo contable** de comisiones y utilidades del asesor

---

## Equipo de Desarrollo

| Nombre | Rol |
|---|---|
| **Kevin Cardoso** | Desarrollador principal / Arquitectura |
| **Brandon Faruck Villamarin** | Desarrollador / QA |

---

## Tecnologías

| Componente | Tecnología |
|---|---|
| Frontend | Flutter 3.41 (Dart) |
| Backend | Firebase (BaaS) |
| Base de datos | Cloud Firestore (NoSQL) |
| Autenticación | Firebase Authentication + Biometría |
| Almacenamiento | Firebase Storage |
| Estado | Riverpod |
| Navegación | GoRouter |
| UI/UX | Material 3 + Google Fonts (Inter) |

---

## Arquitectura del Sistema

```
Cliente Móvil (Flutter)
├── Firebase Authentication (login, registro, biometría)
├── Cloud Firestore (perfiles, casos, mensajes, comisiones)
├── Firebase Storage (documentos, fotos)
├── Motor de Evaluación Financiera (Score RiskMobile)
├── Simulador Dinámico de Crédito
├── CRM del Asesor
├── Sistema de Mensajería
└── Módulo Contable del Asesor
```

---

## Actores del Sistema

### Cliente
Persona interesada en conocer su capacidad para acceder a un crédito. Puede realizar la entrevista financiera, cargar documentos, conocer su nivel de endeudamiento, simular créditos y contactar un asesor.

### Asesor Financiero Independiente
Profesional que gestiona múltiples clientes, analiza perfiles financieros, ofrece asesoría crediticia, gestiona procesos de crédito con cobro de comisión y lleva el control financiero de su negocio.

---

## Módulos del Sistema

1. **Autenticación** — Registro, login, biometría, roles
2. **Entrevista Financiera Digital** — Formulario inteligente por actividad económica
3. **Gestión Documental** — Carga de documentos por foto o archivo (PDF/imagen)
4. **Motor de Evaluación Financiera** — Cálculo de endeudamiento + Score RiskMobile
5. **Simulador de Crédito** — Dashboard interactivo con sliders (tasa, plazo, tipo)
6. **CRM del Asesor** — Gestión de clientes, estados de caso, seguimiento
7. **Comunicación** — Chat en tiempo real asesor-cliente
8. **Pagos** — Cobro de consultas especializadas (ej: Datacrédito)
9. **Control Financiero del Asesor** — Comisiones, costos, utilidades

---

## Estadísticas del Sistema

| Concepto | Cantidad |
|---|---|
| Pantallas diseñadas e implementadas | 16 |
| Requerimientos funcionales | 38 |
| Requerimientos no funcionales | 20 |
| Módulos del sistema | 9 |
| Roles de usuario | 2 (Cliente / Asesor) |
| Archivos Dart del proyecto | 28 |
| Total de campos de entrada (inputs) | 47 |
| Total de validaciones implementadas | 62 |
| Tipos de campo utilizados | 8 (texto, email, numérico, contraseña, selector, slider, switch, chat) |

---

## Score RiskMobile — Indicador Interno de Perfil Financiero

### Aclaración importante

> **El Score RiskMobile es un indicador meramente informativo y orientativo.** Su propósito es dar al usuario una aproximación del perfil de riesgo que podría estar manejando, con base en la información financiera que él mismo declara dentro de la plataforma. **Este score NO reemplaza ni representa el score real de las centrales de riesgo** (Datacrédito, TransUnion, etc.). Para conocer el score directo de las centrales, el usuario debe realizar el pago correspondiente para consultar directamente en dichas centrales su score propio y su historial crediticio oficial.

### Variables que alimentan el Score RiskMobile

El score se calcula al finalizar la entrevista financiera completa (actividad económica + ingresos + obligaciones). Se basa en 4 variables ponderadas:

| # | Variable | Peso | Qué mide | Cómo se obtiene |
|---|---|---|---|---|
| 1 | **Capacidad de pago** | 40% | Cuánto le queda disponible al usuario después de pagar sus cuotas actuales, respecto a su ingreso | Se calcula como `(ingreso × 40% − total_cuotas) / ingreso`. Si le queda ≥40% libre → 100 pts, si ≥30% → 85, si ≥20% → 70, si ≥10% → 50, si ≥0% → 30, si negativo → 0 |
| 2 | **Nivel de endeudamiento** | 30% | Qué porcentaje de los ingresos ya está comprometido en cuotas | Se calcula como `total_cuotas / ingreso`. Si ≤20% → 100, ≤30% → 85, ≤40% → 65, ≤50% → 40, ≤70% → 20, >70% → 5 |
| 3 | **Estabilidad laboral** | 20% | Tipo de actividad económica y antigüedad en ella | Según la actividad: Pensionado=95, Empleado=90, Profesional independiente=75, Comerciante=70, Independiente=65. Bonus: +5 si ≥2 años, +5 adicional si ≥4 años |
| 4 | **Historial financiero declarado** | 10% | Si el usuario tiene o ha tenido obligaciones financieras (experiencia crediticia) | Si declara obligaciones existentes → 80 pts (tiene experiencia crediticia). Si no tiene obligaciones → 60 pts (no tiene historial) |

### Fórmula final

```
Score RiskMobile = (Capacidad × 0.40) + (Endeudamiento × 0.30) + (Estabilidad × 0.20) + (Historial × 0.10)
```

El resultado se redondea a un entero entre 0 y 100.

### Clasificación de riesgo

| Rango | Clasificación | Color en la app | Significado |
|---|---|---|---|
| 80 – 100 | Riesgo Bajo | Verde (#4CAF50) | Perfil financiero sólido, alta probabilidad de aprobación crediticia |
| 60 – 79 | Riesgo Medio | Naranja (#FF9800) | Perfil aceptable con áreas de mejora, aprobación posible con condiciones |
| 40 – 59 | Riesgo Alto | Rojo (#F44336) | Perfil comprometido, se recomienda reducir deuda antes de solicitar crédito |
| 0 – 39 | Riesgo Muy Alto | Morado (#9C27B0) | Capacidad insuficiente, alta probabilidad de rechazo |

### Ejemplo de cálculo

Un empleado con 24 meses de antigüedad, ingreso de $3.000.000, cuotas mensuales de $600.000 y que declara obligaciones:

- Capacidad de pago: ingreso × 40% = $1.200.000 − $600.000 = $600.000 libre → ratio 20% → **70 pts**
- Endeudamiento: $600.000 / $3.000.000 = 20% → **100 pts**
- Estabilidad: Empleado = 90 + bonus 5 (≥24 meses) = **95 pts**
- Historial: tiene obligaciones → **80 pts**

```
Score = (70 × 0.40) + (100 × 0.30) + (95 × 0.20) + (80 × 0.10)
Score = 28 + 30 + 19 + 8 = 85 → Riesgo Bajo ✅
```

---

## Actividad Económica y Ámbito Laboral

La actividad económica del usuario es fundamental para el cálculo del score porque refleja su estabilidad de ingresos:

| Actividad | Descripción | Puntuación base | Justificación |
|---|---|---|---|
| **Empleado** | Persona vinculada laboralmente a una empresa con contrato | 90 | Ingreso estable y predecible, respaldado por nómina |
| **Independiente** | Persona que trabaja por cuenta propia sin registro formal | 65 | Ingresos variables, sin soporte de nómina |
| **Pensionado** | Persona que recibe pensión de jubilación | 95 | Ingreso más estable y garantizado del sistema |
| **Comerciante** | Persona con negocio propio registrado (RUT/Cámara de comercio) | 70 | Ingresos variables pero con soporte de actividad formal |
| **Profesional independiente** | Profesional titulado que trabaja por honorarios o contrato de prestación de servicios | 75 | Ingresos variables pero con mayor capacidad de generación |

### Tipos de contratación (para empleados)

| Tipo de contrato | Impacto en estabilidad |
|---|---|
| Término indefinido | Mayor estabilidad, favorece la evaluación |
| Término fijo | Estabilidad media, depende de renovación |
| Prestación de servicios | Menor estabilidad, similar a independiente |
| Independiente (sin contrato) | Sin vínculo laboral, ingresos no garantizados |

### Antigüedad laboral

| Rango | Bonus al score |
|---|---|
| 0 – 23 meses | Sin bonus |
| 24 – 47 meses (2-3 años) | +5 puntos |
| 48+ meses (4+ años) | +10 puntos |

---

## Requerimientos Funcionales del Sistema

### Requerimientos Funcionales Clave (Especificados)

---

#### RF01 – Registro de usuarios

**Descripción**
El sistema debe permitir el registro de nuevos usuarios mediante correo electrónico y contraseña utilizando Firebase Authentication.

**Campos de entrada (5 inputs)**

| # | Campo | Tipo de campo | Especificaciones |
|---|---|---|---|
| 1 | Nombre completo | Texto | Mín: 3 caracteres · Máx: 100 caracteres · Capitalización automática por palabra |
| 2 | Correo electrónico | Email | Formato obligatorio: `usuario@dominio.com` · Teclado tipo email |
| 3 | Teléfono | Numérico | Opcional · Teclado numérico |
| 4 | Contraseña | Campo de contraseña | Mín: 8 caracteres · Debe contener al menos una letra y un número · Ícono de visibilidad on/off |
| 5 | Confirmar contraseña | Campo de contraseña | Debe coincidir exactamente con el campo contraseña · Ícono de visibilidad on/off |
| 6 | Tipo de usuario | Selector visual (chips) | Opciones: **Cliente** · **Asesor** · Selección obligatoria |

**Validaciones (6)**
- Ningún campo obligatorio puede estar vacío
- El nombre debe tener al menos 3 caracteres
- El correo debe tener formato válido (contener @)
- El correo no debe estar registrado previamente en Firebase
- La contraseña debe tener mínimo 8 caracteres
- Las contraseñas deben coincidir

**Salidas**
- Usuario registrado correctamente → redirige a Home del Cliente o Dashboard del Asesor según el rol
- Mensaje de error si el correo ya está registrado
- Mensaje de error si alguna validación falla

---

#### RF02 – Autenticación de usuarios

**Descripción**
El sistema debe autenticar usuarios mediante correo/contraseña o biometría usando Firebase Authentication.

**Campos de entrada (2 inputs + 1 acción biométrica)**

| # | Campo | Tipo de campo | Especificaciones |
|---|---|---|---|
| 1 | Correo electrónico | Email | Formato obligatorio: `usuario@dominio.com` |
| 2 | Contraseña | Campo de contraseña | Mín: 6 caracteres · Ícono de visibilidad on/off |
| 3 | Acceso biométrico | Botón de acción | Activa sensor de huella o Face ID del dispositivo |

**Validaciones (5)**
- El correo debe tener formato válido
- La contraseña no puede estar vacía
- Si el correo no existe → mostrar "No existe cuenta con este correo"
- Si la contraseña es incorrecta → mostrar "Contraseña incorrecta"
- Si hay demasiados intentos → mostrar "Demasiados intentos. Espera un momento"

**Salidas**
- Login exitoso → redirige según rol (Cliente → Home, Asesor → Dashboard)
- Mensaje de error específico según el tipo de fallo

---

#### RF05 – Entrevista financiera digital (Paso 1: Actividad económica)

**Descripción**
El sistema debe permitir al cliente completar el primer paso de la entrevista financiera, recopilando su actividad económica e ingresos. Esta información es la base para calcular el Score RiskMobile.

**Campos de entrada (4 inputs)**

| # | Campo | Tipo de campo | Especificaciones |
|---|---|---|---|
| 1 | Actividad económica | Selector visual (lista de opciones con íconos) | Opciones: **Empleado** (ícono work) · **Independiente** (ícono self_improvement) · **Pensionado** (ícono elderly) · **Comerciante** (ícono storefront) · **Profesional independiente** (ícono school) · Selección obligatoria · Solo una opción |
| 2 | Tipo de contrato | Selector desplegable (Dropdown) | Opciones: **Término indefinido** · **Término fijo** · **Prestación de servicios** · **Independiente** · Visible solo si actividad = Empleado o Profesional independiente |
| 3 | Antigüedad laboral | Campo numérico | Unidad: meses · Valor mínimo: 0 · Valor máximo: 600 (50 años) · Teclado numérico |
| 4 | Ingresos mensuales | Campo numérico con prefijo $ | Valor mínimo: 0 · Valor máximo: 100.000.000 · Teclado numérico · Prefijo `$` visual |

**Validaciones (4)**
- La actividad económica es obligatoria (no puede avanzar sin seleccionar)
- Los ingresos son obligatorios y deben ser numéricos
- Los ingresos no pueden ser negativos
- La antigüedad no puede ser negativa

**Salidas**
- Datos almacenados temporalmente → avanza al Paso 2
- Botón "Continuar" deshabilitado hasta que los campos obligatorios estén completos

---

#### RF10 – Registro de obligaciones financieras (Paso 2)

**Descripción**
El sistema debe permitir al cliente registrar sus obligaciones financieras actuales (créditos, cuotas, deudas). Puede registrar múltiples obligaciones o indicar que no tiene ninguna.

**Campos de entrada (5 inputs por obligación)**

| # | Campo | Tipo de campo | Especificaciones |
|---|---|---|---|
| 1 | ¿Tiene créditos actualmente? | Switch (toggle) | Sí / No · Si selecciona "No", no se muestran los demás campos |
| 2 | Entidad financiera | Texto | Mín: 2 caracteres · Máx: 100 caracteres · Ejemplo: "Bancolombia", "Davivienda" |
| 3 | Tipo de crédito | Selector desplegable (Dropdown) | Opciones: **Libre inversión** · **Vivienda** · **Vehículo** · **Libranza** · **Crédito educativo** · **Microcrédito** |
| 4 | Cuota mensual | Campo numérico con prefijo $ | Valor mínimo: 0 · Solo valores numéricos · Prefijo `$` |
| 5 | Saldo pendiente | Campo numérico con prefijo $ | Opcional · Valor mínimo: 0 |

**Funcionalidad adicional**
- Botón "Agregar obligación" → abre modal (bottom sheet) para registrar cada obligación
- Se pueden agregar N obligaciones (lista dinámica)
- Cada obligación se muestra como tarjeta con botón de eliminar (X)

**Validaciones (4)**
- Si indica que tiene créditos, debe agregar al menos una obligación con datos completos
- Los valores de cuota y saldo deben ser numéricos
- La entidad financiera no puede estar vacía
- Debe seleccionar un tipo de crédito

**Salidas**
- Lista de obligaciones almacenada → avanza al Paso 3
- Si no tiene obligaciones → avanza directamente

---

#### RF07 – Registro de monto deseado e intención de crédito (Paso 3)

**Descripción**
El sistema debe permitir al cliente declarar cuánto dinero desea solicitar y el tipo de crédito de interés. Estos datos se comparan con la capacidad real calculada.

**Campos de entrada (2 inputs)**

| # | Campo | Tipo de campo | Especificaciones |
|---|---|---|---|
| 1 | Monto deseado | Campo numérico con prefijo $ | Valor mínimo: 0 · Valor máximo: 500.000.000 · Placeholder: "Ej: 20000000" · Teclado numérico |
| 2 | Tipo de crédito de interés | Selector visual (Chips / Wrap) | Opciones: **Libre inversión** · **Vivienda** · **Vehículo** · **Libranza** · **Crédito educativo** · **Microcrédito** · Selección de una opción · Efecto gradiente al seleccionar |

**Validaciones (2)**
- El monto solo acepta valores numéricos
- El monto no puede ser negativo

**Información adicional mostrada**
- Card informativo: "Esta evaluación es preliminar y no genera huella en centrales de riesgo como Datacrédito"

**Salidas**
- Al presionar "Calcular mi perfil financiero" → se guardan todos los datos en Firestore, se calcula el Score RiskMobile y se redirige a la pantalla de Perfil Financiero

---

#### RF13 – Cálculo del nivel de endeudamiento

**Descripción**
El sistema debe calcular automáticamente el nivel de endeudamiento del cliente basándose en sus ingresos y cuotas mensuales declaradas.

**Entradas**
- Ingresos mensuales (del Paso 1)
- Total de cuotas mensuales (suma de todas las obligaciones del Paso 2)

**Proceso de cálculo**

```
Nivel de endeudamiento (%) = (Total cuotas mensuales / Ingresos mensuales) × 100
```

```
Capacidad disponible ($) = (Ingresos × 40%) − Total cuotas mensuales
```

**Validaciones (2)**
- Los ingresos deben ser mayores que cero (evitar división por cero)
- Si la capacidad es negativa, se muestra como $0

**Salidas visuales**
- Gauge (barra de progreso) con nivel de endeudamiento
- Código de colores: Verde (<30%), Naranja (30-40%), Rojo (>40%)
- Indicadores: "Ideal <30%" y "Máximo 40%"
- Porcentaje numérico mostrado

---

#### RF15 – Generación del Score RiskMobile

**Descripción**
Al completar los 3 pasos de la entrevista financiera, el sistema genera automáticamente el Score RiskMobile (0-100) como indicador orientativo del perfil financiero del usuario.

**Entradas (4 variables)**
- Capacidad de pago → calculada de ingresos y cuotas
- Nivel de endeudamiento → calculado de cuotas/ingresos
- Estabilidad laboral → según actividad económica y antigüedad
- Historial financiero → según si declara obligaciones existentes

**Proceso**
- Se aplica la fórmula ponderada descrita en la sección "Score RiskMobile"

**Salidas visuales**
- Widget circular animado mostrando el score (0-100)
- Color según clasificación (verde/naranja/rojo/morado)
- Etiqueta de clasificación ("Riesgo Bajo", "Riesgo Medio", etc.)
- Texto: "/100" debajo del número

**Nota importante mostrada al usuario**
> "El Score RiskMobile es un indicador informativo basado en la información que usted declara. No reemplaza el score de las centrales de riesgo. Para conocer su score real en Datacrédito u otras centrales, debe realizar la consulta directa con pago."

---

#### RF17 – Simulador dinámico de crédito

**Descripción**
El sistema debe proporcionar un simulador interactivo donde el usuario ajusta parámetros y ve en tiempo real la cuota estimada y el monto máximo de crédito.

**Campos de entrada (4 inputs)**

| # | Campo | Tipo de campo | Especificaciones |
|---|---|---|---|
| 1 | Tasa de interés mensual | **Slider** | Rango: 0.50% – 4.00% · Divisiones: 70 (cada 0.05%) · Valor por defecto: 1.50% · Muestra badge con valor actual en tiempo real |
| 2 | Plazo del crédito | **Slider** | Rango: 6 – 240 meses · Divisiones: por cada 6 meses · Valor por defecto: 36 meses · Muestra equivalente en años |
| 3 | Monto deseado | **Slider** | Rango: 0 – Monto máximo × 2 · Divisiones: 40 · Valor inicial: monto declarado en entrevista |
| 4 | Tipo de crédito | Selector horizontal (Chips scroll) | Opciones: **Libre inversión** · **Vivienda** · **Vehículo** · **Libranza** · **Crédito educativo** · **Microcrédito** |

**Presets rápidos de plazo**
- 6 botones: 6M, 1A, 2A, 3A, 5A, 7A (meses/años)

**Proceso de cálculo**

```
Cuota mensual = P × r × (1+r)^n / ((1+r)^n − 1)

Donde:
  P = monto del crédito
  r = tasa de interés mensual (decimal)
  n = plazo en meses
```

```
Monto máximo = Capacidad_disponible × (1 − (1+r)^−n) / r
```

**Validaciones (3)**
- La tasa debe estar dentro del rango permitido
- El plazo debe estar dentro del rango permitido
- Si capacidad = 0, monto máximo = 0

**Salidas visuales (6)**
- Cuota mensual estimada (número grande, actualización en tiempo real)
- Monto máximo viable
- Tasa seleccionada con sufijo "% M.V." (mensual vencida)
- Plazo seleccionado en meses
- Total a pagar (cuota × plazo)
- Comparación visual (barras) monto deseado vs monto viable

---

#### RF23 – Panel CRM del asesor

**Descripción**
El sistema debe mostrar al asesor un panel de gestión de clientes con estadísticas, búsqueda y filtros.

**Campos de entrada (2 inputs)**

| # | Campo | Tipo de campo | Especificaciones |
|---|---|---|---|
| 1 | Búsqueda de cliente | Campo de texto con ícono lupa | Búsqueda por nombre · Filtrado en tiempo real · Botón de limpiar (X) |
| 2 | Filtro de estado | Selector horizontal (Chips scroll) | Opciones: **Todos** · **Entrevista completada** · **Análisis en proceso** · **Documentos pendientes** · **Solicitud radicada** · **Crédito aprobado** · **Crédito rechazado** |

**Información mostrada por cliente**
- Avatar con inicial del nombre
- Nombre completo
- Actividad económica + ingreso mensual
- Score RiskMobile (badge con color)
- Estado del caso (badge con color)
- Tiempo desde última actualización ("hace 2h", "hace 3 días")

**Estadísticas resumen (3 cards)**
- Total de clientes
- Clientes aprobados
- Clientes en proceso

---

#### RF25 – Actualización de estado del caso

**Descripción**
El sistema debe permitir al asesor cambiar el estado del caso de un cliente.

**Campo de entrada (1 input)**

| # | Campo | Tipo de campo | Especificaciones |
|---|---|---|---|
| 1 | Estado del caso | Selector desplegable (Dropdown) | Opciones: **Entrevista completada** · **Análisis en proceso** · **Documentos pendientes** · **Solicitud radicada** · **Crédito aprobado** · **Crédito rechazado** |

**Validaciones (1)**
- Solo asesores pueden cambiar el estado

**Salidas**
- Estado actualizado en Firestore con `updatedAt` actualizado
- SnackBar: "Estado actualizado: [nuevo estado]"

---

#### RF26 – Chat entre asesor y cliente

**Descripción**
El sistema debe permitir comunicación bidireccional en tiempo real mediante chat interno entre asesor y cliente, usando Cloud Firestore como backend de mensajería.

**Campos de entrada (1 input)**

| # | Campo | Tipo de campo | Especificaciones |
|---|---|---|---|
| 1 | Mensaje | Campo de texto multilínea | Mín: 1 carácter · Máx: 500 caracteres · Máximo 4 líneas · Capitalización por oración · Envío con botón o tecla Enter |

**Validaciones (1)**
- El mensaje no puede estar vacío (solo espacios no cuenta)

**Funcionalidad**
- Mensajes en tiempo real via Firestore streams
- Burbujas diferenciadas: mensajes propios (gradiente azul-morado, alineados a la derecha) vs mensajes recibidos (blanco, alineados a la izquierda)
- Avatar del remitente con inicial
- Indicador "En línea"
- Timestamp relativo ("hace 5 min", "hace 2h")
- Auto-scroll al último mensaje

**Salidas**
- Mensaje enviado y visible en tiempo real para ambas partes

---

#### RF28 – Registro de comisiones del asesor

**Descripción**
El sistema debe permitir al asesor registrar las comisiones cobradas por cada caso de crédito gestionado.

**Campos de entrada (4 inputs)**

| # | Campo | Tipo de campo | Especificaciones |
|---|---|---|---|
| 1 | Nombre del cliente | Texto | Capitalización por palabra · No puede estar vacío |
| 2 | Valor del crédito aprobado | Campo numérico con prefijo $ | Valor mínimo: 1 · Solo valores numéricos |
| 3 | Comisión cobrada | Campo numérico con prefijo $ | No puede estar vacío · Solo valores numéricos |
| 4 | Costos del proceso | Campo numérico con prefijo $ | Valor por defecto: 0 · Opcional |

**Cálculo en tiempo real**
```
Utilidad estimada = Comisión − Costos
```
Se muestra en un card hero con gradiente, actualizándose al escribir.

**Validaciones (3)**
- Nombre del cliente obligatorio
- Valor del crédito debe ser mayor que cero
- La comisión es obligatoria

**Salidas**
- Comisión registrada en Firestore
- SnackBar: "Comisión registrada exitosamente"
- Regresa a la pantalla anterior

---

#### RF29 – Panel financiero del asesor

**Descripción**
El sistema debe mostrar un panel financiero con el resumen del negocio del asesor.

**Información mostrada**
| Dato | Cómo se calcula |
|---|---|
| Total de comisiones | Suma de `commissionAmount` de todas las comisiones |
| Costos operativos | Suma de `costs` de todas las comisiones |
| Utilidad neta | Total comisiones − Total costos |
| Historial de comisiones | Lista ordenada por fecha, con nombre de cliente, monto del crédito y comisión |

**Proceso**
```
Utilidad neta = Σ Comisiones − Σ Costos
```

---

#### RF08 – Carga de documentos por cámara

**Descripción**
El sistema debe permitir al cliente capturar documentos soporte mediante la cámara del dispositivo.

**Funcionalidad (3 métodos de carga)**

| # | Método | Tipo de campo | Especificaciones |
|---|---|---|---|
| 1 | Tomar foto | Botón con ícono cámara | Abre cámara del dispositivo · Calidad de imagen: 85% · Formatos: JPG |
| 2 | Galería | Botón con ícono galería | Abre selector de fotos · Calidad: 85% · Formatos: JPG, PNG |
| 3 | Archivo | Botón con ícono upload | Abre selector de archivos · Formatos permitidos: PDF, JPG, PNG, JPEG |

**Tipos de documentos aceptados**
- Certificado laboral / Desprendible de nómina
- Extractos bancarios
- RUT / Cámara de comercio
- Resolución de pensión

**Validaciones (2)**
- Solo se permiten los formatos especificados
- El archivo debe tener un path válido

**Salidas**
- Documento agregado a la lista con ícono según tipo (PDF/imagen)
- Indicador de estado (check verde)
- Opción de eliminar cada documento

---

#### RF36 – Recuperación de contraseña

**Descripción**
El sistema debe permitir al usuario solicitar el restablecimiento de contraseña en caso de olvido.

**Campos de entrada (1 input)**

| # | Campo | Tipo de campo | Especificaciones |
|---|---|---|---|
| 1 | Correo electrónico | Email | Formato obligatorio: `usuario@dominio.com` |

**Validaciones (2)**
- El correo debe tener formato válido
- Firebase envía correo solo si el email está registrado

**Salidas**
- Firebase envía correo de restablecimiento
- Mensaje: "Revisa tu correo para restablecer tu contraseña"

---

#### RF37 – Historial de evaluaciones

**Descripción**
El sistema debe permitir al cliente ver el historial de evaluaciones financieras realizadas, ordenadas por fecha.

**Información mostrada por evaluación**
- Fecha de la evaluación
- Score RiskMobile obtenido
- Nivel de endeudamiento
- Estado del caso
- Actividad económica registrada

**Funcionalidad**
- Lista ordenada por fecha (más reciente primero)
- Tap en una evaluación → abre el detalle completo (Perfil Financiero)

---

#### RF38 – Validación de documentos por el asesor

**Descripción**
El sistema debe permitir al asesor revisar y validar los documentos cargados por el cliente.

**Campos de entrada (1 input por documento)**

| # | Campo | Tipo de campo | Especificaciones |
|---|---|---|---|
| 1 | Estado del documento | Selector | Opciones: **Pendiente de revisión** · **Aprobado** · **Rechazado (requiere reenvío)** |

**Salidas**
- Estado del documento actualizado
- Si rechazado → notificación al cliente para reenviar

---

### Otros Requerimientos Funcionales

| ID | Requisito | Prioridad |
|---|---|---|
| RF03 | El sistema debe permitir autenticación biométrica mediante huella digital o reconocimiento facial usando `local_auth` | Alta |
| RF04 | El sistema debe asignar roles diferenciados (Cliente y Asesor) al momento del registro, determinando la interfaz y permisos disponibles | Alta |
| RF06 | El sistema debe solicitar y almacenar la actividad económica del cliente mediante selector visual con 5 opciones predefinidas | Alta |
| RF09 | El sistema debe permitir subir documentos desde archivos del dispositivo (PDF, imagen) con selector de archivos nativo | Alta |
| RF11 | El sistema debe permitir registrar múltiples obligaciones financieras mediante formulario dinámico con botón "Agregar obligación" y modal de ingreso | Alta |
| RF12 | El sistema debe permitir cargar extractos bancarios como soporte de las obligaciones declaradas | Media |
| RF14 | El sistema debe calcular la capacidad disponible para nueva cuota: `(Ingresos × 40%) − Total cuotas` | Alta |
| RF16 | El sistema debe clasificar el riesgo del cliente en 4 niveles (bajo, medio, alto, muy alto) con colores diferenciados | Alta |
| RF18 | El sistema debe proporcionar un slider de plazo de crédito con rango de 6 a 240 meses y presets rápidos | Alta |
| RF19 | El sistema debe permitir seleccionar el tipo de crédito entre 6 opciones mediante chips horizontales con scroll | Alta |
| RF20 | El sistema debe calcular automáticamente la cuota mensual usando la fórmula de amortización francesa y actualizar en tiempo real | Alta |
| RF21 | El sistema debe permitir al cliente registrar el monto de crédito deseado para compararlo con el monto viable calculado | Media |
| RF22 | El sistema debe comparar visualmente (barras de progreso) el monto deseado contra el monto viable y mostrar si es "Viable" o la "Brecha" en pesos | Media |
| RF24 | El sistema debe permitir al asesor visualizar el perfil financiero completo de cada cliente, incluyendo score, gauge de endeudamiento, obligaciones detalladas y datos de la entrevista | Alta |
| RF27 | El sistema debe permitir al asesor buscar clientes por nombre (filtrado en tiempo real) y filtrar por estado del caso (chips horizontales) | Media |
| RF30 | El sistema debe mostrar un panel financiero con total de comisiones, costos, utilidad neta e historial detallado por cliente | Alta |
| RF31 | El sistema debe mostrar estadísticas de clientes: total, aprobados y en proceso, mediante cards con conteo numérico | Media |
| RF32 | El sistema debe permitir cerrar sesión desde la pantalla de configuración y desde el perfil del asesor, redirigiendo al login | Baja |
| RF33 | El sistema debe permitir activar/desactivar notificaciones push mediante Switch toggle en la pantalla de configuración | Media |
| RF34 | El sistema debe permitir activar/desactivar autenticación biométrica mediante Switch toggle en configuración | Media |
| RF35 | El sistema debe almacenar los documentos cargados de forma segura en Firebase Storage, organizados por usuario | Alta |

---

## Requisitos No Funcionales

| ID | Requisito | Categoría |
|---|---|---|
| RNF01 | La información financiera debe almacenarse cifrada en reposo mediante las reglas de seguridad de Firestore | Seguridad |
| RNF02 | Todas las comunicaciones deben realizarse mediante protocolo HTTPS/TLS | Seguridad |
| RNF03 | El sistema debe implementar autenticación multifactor (correo + biometría) | Seguridad |
| RNF04 | El acceso a datos debe estar controlado por roles (cliente solo ve sus datos, asesor ve sus clientes) | Seguridad |
| RNF05 | El sistema debe aplicar principios Zero-Trust: verificación continua de identidad | Seguridad |
| RNF06 | Las contraseñas deben tener un mínimo de 8 caracteres con al menos una letra y un número | Seguridad |
| RNF07 | La aplicación debe tener disponibilidad mínima del 99% (garantizada por Firebase) | Disponibilidad |
| RNF08 | El tiempo de respuesta del cálculo de evaluación financiera no debe superar 2 segundos | Rendimiento |
| RNF09 | El simulador de crédito debe actualizar los valores en tiempo real al mover los sliders (sin delay perceptible) | Rendimiento |
| RNF10 | La carga de documentos debe mostrar indicador de progreso | Rendimiento |
| RNF11 | La aplicación debe ejecutarse en Android 10+ y iOS 14+ | Compatibilidad |
| RNF12 | La aplicación debe funcionar correctamente en pantallas de 5" a 12" con diseño responsive | Compatibilidad |
| RNF13 | El proceso de entrevista financiera debe completarse en máximo 3 pasos con indicador de progreso | Usabilidad |
| RNF14 | La interfaz debe seguir las guías de diseño de Material 3 con tipografía tipo Apple (Inter/SF Pro) | Usabilidad |
| RNF15 | La paleta de colores debe usar azul claro (#4FC3F7), morado claro (#CE93D8), tonos traslúcidos y fondos blancos | Usabilidad |
| RNF16 | La aplicación debe mostrar animaciones fluidas (mínimo 60fps) usando flutter_animate | Usabilidad |
| RNF17 | El sistema debe soportar múltiples clientes concurrentes sin degradación de rendimiento | Escalabilidad |
| RNF18 | La arquitectura debe permitir la futura integración de OCR para análisis automático de documentos | Escalabilidad |
| RNF19 | La arquitectura debe permitir la futura integración con APIs bancarias y centrales de riesgo (Datacrédito) | Escalabilidad |
| RNF20 | La arquitectura debe permitir la futura integración de modelos de IA/ML para predicción de riesgo | Escalabilidad |

---

## Flujo del Sistema

1. **Registro** — El usuario crea su cuenta (correo + contraseña + rol)
2. **Entrevista financiera — Paso 1** — Actividad económica, tipo de contrato, antigüedad, ingresos
3. **Entrevista financiera — Paso 2** — Obligaciones financieras (entidad, tipo, cuota, saldo)
4. **Entrevista financiera — Paso 3** — Monto deseado y tipo de crédito de interés
5. **Carga de documentos** — Adjunta soportes de ingresos y obligaciones (foto/archivo)
6. **Cálculo de perfil** — El sistema calcula endeudamiento, capacidad y Score RiskMobile
7. **Simulación** — El usuario explora montos, tasas y plazos con sliders interactivos
8. **Panel del asesor** — El asesor analiza el perfil, documentos y la brecha monto deseado vs viable
9. **Comunicación** — Asesor y cliente intercambian mensajes por chat en tiempo real
10. **Gestión del caso** — El asesor actualiza estados del caso
11. **Cobro de servicios** — El asesor puede cobrar consultas especializadas
12. **Control financiero** — El asesor registra comisiones, costos y visualiza utilidades

---

## Modelo de Datos (Firestore)

### Colección: `users`
| Campo | Tipo | Descripción |
|---|---|---|
| name | string | Nombre completo |
| email | string | Correo electrónico |
| role | string | `client` o `advisor` |
| phone | string | Teléfono |
| photoUrl | string | URL foto de perfil |
| createdAt | timestamp | Fecha de registro |
| isActive | boolean | Estado de la cuenta |

### Colección: `cases`
| Campo | Tipo | Descripción |
|---|---|---|
| clientId | string | ID del cliente |
| clientName | string | Nombre del cliente |
| economicActivity | string | Actividad económica |
| contractType | string | Tipo de contrato laboral |
| seniority | number | Antigüedad en meses |
| monthlyIncome | number | Ingreso mensual |
| obligations | array | Lista de obligaciones financieras |
| totalMonthlyPayments | number | Total de cuotas mensuales |
| debtLevel | number | Nivel de endeudamiento (0-1) |
| availableCapacity | number | Capacidad disponible para nueva cuota |
| desiredAmount | number | Monto deseado por el cliente |
| desiredCreditType | string | Tipo de crédito de interés |
| riskScore | number | Score RiskMobile (0-100) |
| caseStatus | string | Estado del caso |
| createdAt | timestamp | Fecha de creación |
| updatedAt | timestamp | Última actualización |

### Colección: `messages/{chatId}/chat`
| Campo | Tipo | Descripción |
|---|---|---|
| senderId | string | ID del emisor |
| senderName | string | Nombre del emisor |
| content | string | Contenido del mensaje |
| timestamp | timestamp | Fecha y hora |

### Colección: `commissions`
| Campo | Tipo | Descripción |
|---|---|---|
| advisorId | string | ID del asesor |
| clientId | string | ID del cliente |
| clientName | string | Nombre del cliente |
| creditAmount | number | Valor del crédito aprobado |
| commissionAmount | number | Comisión cobrada |
| costs | number | Costos del proceso |
| profit | number | Utilidad (comisión - costos) |
| caseId | string | ID del caso |
| createdAt | timestamp | Fecha de registro |

---

## Paleta de Colores

| Color | HEX | Uso |
|---|---|---|
| Azul claro | `#4FC3F7` | Color primario |
| Azul intenso | `#0288D1` | Acentos principales |
| Azul suave | `#B3E5FC` | Fondos secundarios |
| Morado claro | `#CE93D8` | Color secundario |
| Morado intenso | `#9C27B0` | Acentos del asesor |
| Blanco | `#FFFFFF` | Fondos principales |
| Blanco azulado | `#F8FBFF` | Superficies de tarjetas |
| Traslúcidos | Opacidad 12% | Efectos glassmorphism |
| Verde | `#4CAF50` | Riesgo bajo / Aprobado |
| Naranja | `#FF9800` | Riesgo medio / En proceso |
| Rojo | `#F44336` | Riesgo alto / Rechazado |

---

## Instalación y Ejecución

### Prerrequisitos
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Firebase CLI configurado
- Android Studio o Xcode

### Pasos

```bash
# Clonar el repositorio
git clone https://github.com/kesticar92/RiskMobile.git
cd RiskMobile

# Instalar dependencias
flutter pub get

# Ejecutar en modo debug
flutter run
```

---

## Trabajo Futuro

- Integración de OCR para análisis automático de documentos
- Integración con APIs de centrales de riesgo (Datacrédito Experian) para consulta de score real
- Modelos de IA/ML para predicción avanzada de riesgo crediticio
- Integración con pasarelas de pago (PSE, tarjeta) para cobro de consultas
- Firma digital de documentos
- Modo offline con sincronización automática
- Dashboard web para administradores

---

## Licencia

Proyecto académico — Universidad | Computación Móvil 2026-1

**Desarrollado por Kevin Cardoso y Brandon Faruck Villamarin**
