r# Resumen para exposicion por ramas

Este documento es para compartir con el equipo y exponer que se hizo en cada rama.

---

## 1) Rama `brandon-main`

### Objetivo de esta rama

Implementar y dejar funcional la base del proyecto para autenticacion y entrevista financiera inicial.

### Requerimientos trabajados

- **RF01 / RF02 / RF36 (bloque de autenticacion)**
  - Registro con correo y contrasena.
  - Login con correo y contrasena.
  - Recuperacion de contrasena por correo.
  - Integracion con Firebase Authentication y Firestore.

- **RF05 (Entrevista paso 1)**
  - Actividad economica.
  - Tipo de contrato (condicional).
  - Antiguedad laboral (meses).
  - Ingresos mensuales.
  - Validaciones para permitir continuar.

- **RF10 (Entrevista paso 2)**
  - Switch de obligaciones (si/no).
  - Lista dinamica de obligaciones.
  - Modal para agregar obligacion.
  - Campos: entidad, tipo de credito, cuota mensual, saldo pendiente opcional.
  - Validaciones de datos minimos.

- **RF07 (Entrevista paso 3)**
  - Monto deseado.
  - Tipo de credito de interes.
  - Validaciones para continuar y guardar.

### Cambios funcionales clave

- Pantallas de auth funcionales: splash, login, registro, recuperar contrasena.
- Saludo con nombre real del usuario en home cliente.
- Entrevista financiera de 3 pasos completa y guardando datos en `cases`.
- Archivo de guia operativa para pruebas: `COMO_EJECUTAR.md`.
- Reglas de referencia en `firestore.rules`.

### Como explicarlo en exposicion (guion corto)

1. "En la rama `brandon-main` dejamos la base: autenticacion y entrevista en 3 pasos."
2. "Mostramos registro/login reales con Firebase y guardado de perfil en Firestore."
3. "La entrevista captura actividad, obligaciones e intencion de credito con validaciones."
4. "Con esto dejamos lista la entrada de datos para calculos y simulador."

---

## 2) Rama `kevin-main`

### Objetivo de esta rama

Completar la capa de calculo financiero y simulacion sobre los datos ya capturados.

### Requerimientos trabajados

- **RF13 (Nivel de endeudamiento y capacidad disponible)**
  - Visualizacion de nivel de endeudamiento con gauge y colores.
  - Referencias de negocio: ideal <30% y maximo 40%.
  - Ajuste de capacidad disponible para no mostrar valores negativos (minimo 0).

- **RF15 (Generacion de Score RiskMobile)**
  - Correccion del calculo para incluir antiguedad laboral (`seniorityMonths`).
  - Presentacion visual del score (0 a 100), etiqueta y color por riesgo.
  - Nota informativa de que el score es orientativo y no reemplaza centrales de riesgo.

- **RF17 (Simulador dinamico de credito)**
  - Slider de tasa mensual.
  - Slider de plazo en meses.
  - Slider de monto deseado.
  - Selector de tipo de credito.
  - Presets rapidos de plazo (6M, 1A, 2A, 3A, 5A, 7A).
  - Calculo en tiempo real de cuota, total a pagar y monto maximo.
  - Comparacion visual monto deseado vs monto viable.

### Cambios funcionales clave

- Capa de calculo alineada al modelo del proyecto.
- Score actualizado con variables de la entrevista.
- Simulador interactivo listo para demostracion funcional.
- Flujo completo: entrevista -> perfil financiero -> simulador.

### Como explicarlo en exposicion (guion corto)

1. "En `kevin-main` tomamos los datos capturados y los convertimos en analitica financiera."
2. "Calculamos endeudamiento, capacidad y score de riesgo en forma visual."
3. "Luego llevamos eso al simulador para ver cuota, plazo y viabilidad en tiempo real."
4. "Asi cerramos un flujo completo de preevaluacion crediticia dentro de la app."

---

## 3) Demo recomendada para exponer (orden)

1. Registro/Login (Firebase) -> Home cliente.
2. Entrevista paso 1, 2 y 3.
3. Perfil financiero: score + endeudamiento + capacidad.
4. Simulador: mover sliders y mostrar cambios en tiempo real.
5. Firebase Console: mostrar usuario en Authentication y caso en Firestore.

---

## 4) Resumen ejecutivo para el profesor

- Se dividio el trabajo por ramas para separar responsabilidades.
- `brandon-main`: autenticacion + captura de datos (entrevista).
- `kevin-main`: calculo, score y simulacion.
- Resultado: flujo funcional de punta a punta para preevaluacion crediticia.

---

## 5) Que parte del codigo cambio en cada rama (detalle para revisar)

### A. Cambios principales en `brandon-main`

#### 1) Autenticacion y flujo de acceso

- `lib/core/services/auth_service.dart`
  - Registro con Firebase Auth + guardado de perfil en Firestore.
  - Login con email/password.
  - Recuperacion de contrasena por correo.
  - Ajustes de manejo de errores.

- `lib/core/router/app_router.dart`
  - Rutas de auth (incluye ruta de recuperar contrasena).

- `lib/features/auth/presentation/screens/login_screen.dart`
  - Formulario login y enlace "Olvidaste tu contrasena".

- `lib/features/auth/presentation/screens/register_screen.dart`
  - Formulario de registro (nombre, email, telefono, rol, contrasena).

- `lib/features/auth/presentation/screens/forgot_password_screen.dart`
  - Pantalla nueva de recuperacion.

- `lib/features/auth/presentation/screens/splash_screen.dart`
  - Splash con progreso y redireccion segun sesion.

- `lib/features/auth/presentation/screens/client_home_screen.dart`
  - Saludo con nombre real del usuario.

#### 2) Entrevista financiera (RF05, RF10, RF07)

- `lib/features/interview/presentation/screens/interview_screen.dart`
  - Paso 1: actividad, contrato, antiguedad, ingresos.
  - Paso 2: obligaciones dinamicas con modal.
  - Paso 3: monto deseado + tipo de credito.
  - Validaciones por paso para habilitar "Continuar".

- `lib/shared/models/financial_profile_model.dart`
  - Nuevos campos del perfil para entrevista (`contractType`, `seniorityMonths`, obligaciones, intencion).

#### 3) Soporte documental

- `COMO_EJECUTAR.md`
  - Guia para correr/probar la app.

- `firestore.rules`
  - Reglas base para acceso a `users/{userId}` por usuario autenticado.

---

### B. Cambios principales en `kevin-main`

#### 1) Calculo financiero (RF13 y RF15)

- `lib/core/services/firestore_service.dart`
  - Guardado de score calculado incluyendo antiguedad laboral (`monthsInActivity`).

- `lib/shared/models/financial_profile_model.dart`
  - Ajuste de `availableCapacity` para evitar negativos (`max(0, ...)`).

- `lib/core/utils/risk_calculator.dart`
  - Motor de score y formulas financieras (endeudamiento, capacidad, cuota, monto maximo).

#### 2) Perfil financiero y score visual

- `lib/features/calculator/presentation/screens/calculator_screen.dart`
  - Card de score.
  - Gauge de endeudamiento.
  - Metricas (ingreso, cuotas, capacidad, monto deseado).
  - Nota informativa de score orientativo.

- `lib/shared/widgets/risk_score_widget.dart`
  - Widget circular de score y gauge de endeudamiento con semaforizacion.

#### 3) Simulador dinamico (RF17)

- `lib/features/simulator/presentation/screens/simulator_screen.dart`
  - Sliders de tasa/plazo/monto.
  - Chips de tipo de credito.
  - Presets de plazo.
  - Cuota mensual, total a pagar, monto maximo y comparacion visual.

---

### C. Ruta de lectura de codigo recomendada para el equipo

1. `auth_service.dart` -> entender login/registro y Firestore.
2. `interview_screen.dart` -> entender captura de datos.
3. `financial_profile_model.dart` -> entender modelo y calculos derivados.
4. `risk_calculator.dart` -> entender formulas.
5. `calculator_screen.dart` + `risk_score_widget.dart` -> entender resultado visual.
6. `simulator_screen.dart` -> entender simulacion interactiva.
