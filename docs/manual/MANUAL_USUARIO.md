# Manual de Usuario — RiskMobile v1.0.0

**Plataforma móvil de evaluación financiera y asesoría crediticia**  
**Equipo:** Kevin Cardoso · Brandon Faruck Villamarin  
**Versión de la app:** 1.0.0 · Mayo 2026

---

## Tabla de contenidos

1. [¿Qué es RiskMobile?](#1-qué-es-riskmobile)
2. [Requisitos e instalación](#2-requisitos-e-instalación)
3. [Flujo Cliente paso a paso](#3-flujo-cliente-paso-a-paso)
4. [Flujo Asesor paso a paso](#4-flujo-asesor-paso-a-paso)
5. [Preguntas frecuentes (FAQ)](#5-preguntas-frecuentes-faq)
6. [Aviso legal — Score orientativo](#6-aviso-legal--score-orientativo)

---

## 1. ¿Qué es RiskMobile?

RiskMobile es una aplicación móvil que permite:

- **Clientes:** conocer su perfil financiero preliminar, simular créditos y contactar a un asesor, **sin generar consulta en centrales de riesgo**.
- **Asesores financieros independientes:** gestionar clientes en un CRM, validar documentos, comunicarse por chat y registrar comisiones.

La app funciona en **Android 10+** e **iOS 14+** (requiere conexión a Internet para sincronizar con Firebase).

---

## 2. Requisitos e instalación

### 2.1 Requisitos del dispositivo

| Requisito | Detalle |
|-----------|---------|
| Sistema operativo | Android 10+ o iOS 14+ |
| Conexión | Internet (Wi‑Fi o datos móviles) |
| Almacenamiento | ~80 MB libres |
| Permisos | Cámara, archivos (para documentos); biometría opcional |
| Cuenta | Correo electrónico válido |

### 2.2 Instalar el APK (Android)

1. Descargue `RiskMobile-v1.0.0.apk` desde la carpeta `releases/` del repositorio.
2. En el dispositivo Android, habilite **Instalar apps de fuentes desconocidas** (Ajustes → Seguridad).
3. Abra el archivo APK descargado y confirme **Instalar**.
4. Al finalizar, toque **Abrir** o busque el ícono **RiskMobile** en el launcher.

**Alternativa por ADB (desarrolladores):**

```bash
adb install releases/RiskMobile-v1.0.0.apk
```

### 2.3 Primera ejecución

Al abrir la app verá la pantalla de **Splash** con el logo, la frase *"Tu asesoría crediticia, en tu mano"* y la versión **v1.0.0**. Tras unos segundos, la app redirige al **Login** o al **Home** si ya tiene sesión activa.

![Pantalla Splash — logo, tagline y barra de progreso](screenshots/01-splash.png)
*Captura 01 — Si no ve la imagen, consulte [screenshots/README.md](screenshots/README.md) para generarla.*

---

## 3. Flujo Cliente paso a paso

### 3.1 Registro e inicio de sesión

#### Registro (primera vez)

1. En la pantalla de **Login**, toque **Regístrate**.
2. Complete el formulario:
   - **Nombre completo** (mín. 3 caracteres)
   - **Correo electrónico** (formato válido)
   - **Teléfono** (opcional)
   - **Contraseña** (mín. 8 caracteres, al menos una letra y un número)
   - **Confirmar contraseña**
   - **Tipo de usuario:** seleccione **Cliente**
3. Toque **Crear cuenta**.
4. Será redirigido al **Home del Cliente**.

![Pantalla de registro con selector Cliente/Asesor](screenshots/03-register.png)

#### Inicio de sesión

1. Ingrese **correo** y **contraseña**.
2. Toque **Iniciar sesión**.
3. Opcional: use **Acceso biométrico** (solo dispositivo físico, después del primer login).
4. Si olvidó la contraseña: **¿Olvidaste tu contraseña?** → ingrese correo → revise su bandeja de entrada.

![Pantalla de login](screenshots/02-login.png)

### 3.2 Home del Cliente

Desde el Home accede a todas las funciones:

- Entrevista financiera
- Mis documentos
- Simulador de crédito
- Historial de evaluaciones
- Chat con asesor
- Configuración

Verá el saludo **"Hola, [su nombre]"** y un badge si tiene notificaciones pendientes.

![Home del cliente con accesos rápidos](screenshots/04-client-home.png)

### 3.3 Entrevista financiera (3 pasos)

Toque **Entrevista financiera** o el acceso equivalente en el Home.

#### Paso 1 — Actividad económica e ingresos

1. Seleccione su **actividad económica** (Empleado, Independiente, Pensionado, Comerciante, Profesional independiente).
2. Si aplica, elija **tipo de contrato**.
3. Indique **antigüedad laboral** en meses.
4. Ingrese **ingresos mensuales** en pesos.
5. Toque **Continuar**.

![Entrevista paso 1 — actividad e ingresos](screenshots/05-interview-step1.png)

#### Paso 2 — Obligaciones financieras

1. Active el switch **¿Tiene créditos actualmente?**
   - Si **No**: avance directamente al Paso 3.
   - Si **Sí**: toque **Agregar obligación** y complete:
     - Entidad financiera
     - Tipo de crédito
     - Cuota mensual
     - Saldo pendiente (opcional)
2. Puede agregar varias obligaciones.
3. Toque **Continuar**.

![Entrevista paso 2 — obligaciones](screenshots/06-interview-step2.png)

#### Paso 3 — Monto deseado e intención

1. Ingrese el **monto deseado** del crédito.
2. Seleccione el **tipo de crédito de interés** (chips).
3. Lea el aviso: *"Esta evaluación es preliminar y no genera huella en centrales de riesgo"*.
4. Toque **Calcular mi perfil financiero**.

![Entrevista paso 3 — monto y tipo de crédito](screenshots/07-interview-step3.png)

### 3.4 Perfil financiero y Score RiskMobile

Tras completar la entrevista, la app muestra:

- **Score RiskMobile** (0–100) en widget circular con color según riesgo.
- **Clasificación:** Riesgo Bajo / Medio / Alto / Muy Alto.
- **Gauge de endeudamiento** con porcentaje y capacidad disponible.
- Comparación **monto deseado vs viable**.

![Perfil financiero con score y gauge](screenshots/08-calculator-score.png)

> **Importante:** el Score RiskMobile es orientativo. Ver [sección 6](#6-aviso-legal--score-orientativo).

### 3.5 Carga de documentos

1. Desde el Home o el flujo post-entrevista, acceda a **Mis documentos**.
2. Elija método de carga:
   - **Cámara** — tomar foto del documento
   - **Galería** — seleccionar imagen existente
   - **Archivo** — PDF o imagen del dispositivo
3. Tipos aceptados: certificado laboral, extractos, RUT, resolución de pensión, etc.
4. Cada archivo muestra estado: pendiente, subiendo, completado o error.
5. Si hay error, use **Reintentar** individual o masivo.

![Pantalla de documentos con estados de carga](screenshots/09-documents.png)

### 3.6 Simulador de crédito

1. Acceda al **Simulador** desde el Home o perfil financiero.
2. Ajuste con los sliders:
   - **Tasa de interés mensual** (0,50% – 4,00%)
   - **Plazo** (6 – 240 meses; use presets 6M, 1A, 2A…)
   - **Monto deseado**
   - **Tipo de crédito**
3. Observe en tiempo real:
   - Cuota mensual estimada
   - Monto máximo viable
   - Total a pagar
   - Barras deseado vs viable

![Simulador con sliders y cuota estimada](screenshots/10-simulator.png)

### 3.7 Historial de evaluaciones

1. Toque **Historial de evaluaciones**.
2. Vea la lista ordenada por fecha (más reciente primero).
3. Cada tarjeta muestra: fecha, score, endeudamiento, estado del caso.
4. Toque una evaluación para ver el detalle completo.
5. Opción **Ver documentos del caso** en evaluaciones anteriores.

![Historial de evaluaciones](screenshots/11-evaluations-history.png)

### 3.8 Chat con el asesor

1. Desde el Home, acceda al **Chat**.
2. Escriba su mensaje (máx. 500 caracteres) y envíe.
3. Los mensajes aparecen en tiempo real.
4. Sus mensajes se alinean a la derecha; los del asesor a la izquierda.

![Chat cliente con burbujas de mensaje](screenshots/12-chat-client.png)

### 3.9 Configuración

En **Configuración** puede:

- Activar/desactivar **notificaciones**
- Activar/desactivar **autenticación biométrica**
- **Cerrar sesión** (vuelve al Login)

![Pantalla de configuración](screenshots/13-settings.png)

---

## 4. Flujo Asesor paso a paso

Regístrese o inicie sesión seleccionando el rol **Asesor** para acceder al panel CRM.

### 4.1 Panel CRM

Al iniciar sesión como asesor verá el **Dashboard CRM** con:

- **Estadísticas:** total clientes, aprobados, en proceso.
- **Búsqueda** por nombre (tiempo real).
- **Filtros:** por estado del caso, monto, fecha, multiestado, prioridad, etiquetas.
- **Tarjetas de cliente:** nombre, actividad, ingreso, score (badge color), estado, última actividad.

![CRM del asesor con filtros y tarjetas](screenshots/14-advisor-crm.png)

### 4.2 Detalle de cliente

1. Toque una tarjeta de cliente en el CRM.
2. Revise el **perfil financiero completo:**
   - Datos de entrevista (actividad, ingresos, obligaciones)
   - Score RiskMobile y gauge de endeudamiento
   - Monto deseado vs viable
3. Agregue **nota interna**, **prioridad**, **etiquetas** o **próximo seguimiento** (campos CRM).

![Detalle de cliente con perfil y score](screenshots/15-client-detail.png)

### 4.3 Cambio de estado del caso

1. En el detalle del cliente, localice el selector **Estado del caso**.
2. Elija entre:
   - Entrevista completada
   - Análisis en proceso
   - Documentos pendientes
   - Solicitud radicada
   - Crédito aprobado
   - Crédito rechazado
3. Confirme el cambio.
4. El cliente recibe **notificación** y queda registro en **historial de estados**.

### 4.4 Validación de documentos

1. En el detalle del cliente, revise la sección **Documentos**.
2. Por cada documento, seleccione el estado:
   - **Pendiente de revisión**
   - **Aprobado**
   - **Rechazado (requiere reenvío)**
3. Si rechaza un documento, el cliente recibe notificación para reenviarlo.

![Validación documental por el asesor](screenshots/16-document-validation.png)

Funciones adicionales (RF-B): agrupar por tipo, ordenar, buscar, vista cuadrícula, compartir enlace del documento.

### 4.5 Chat con el cliente

1. Desde el detalle del cliente o CRM, abra el **Chat**.
2. Use el botón de **plantillas rápidas** para respuestas frecuentes.
3. Edite la plantilla antes de enviar si lo desea.
4. Comuníquese en tiempo real con el cliente.

![Chat del asesor con plantillas](screenshots/17-chat-advisor.png)

### 4.6 Comisiones y panel financiero

1. Acceda a **Comisiones / Pagos** desde el menú del asesor.
2. Registre una comisión:
   - Nombre del cliente
   - Valor del crédito aprobado
   - Comisión cobrada
   - Costos del proceso (opcional)
3. La **utilidad estimada** se calcula automáticamente: `Comisión − Costos`.
4. En el **panel financiero** vea totales de comisiones, costos y utilidad neta, más el historial detallado.

![Registro de comisiones y utilidad](screenshots/18-commissions.png)

---

## 5. Preguntas frecuentes (FAQ)

**¿RiskMobile consulta Datacrédito o TransUnion?**  
No. La evaluación es preliminar con datos que usted declara. No genera huella en centrales de riesgo.

**¿Puedo usar la app sin Internet?**  
No. Se requiere conexión para sincronizar con Firebase (login, datos, chat, documentos).

**¿Cómo recupero mi contraseña?**  
Login → ¿Olvidaste tu contraseña? → ingrese su correo → siga el enlace del email de Firebase.

**¿La biometría funciona en emulador?**  
No. Solo en dispositivo físico con sensor de huella o Face ID, después del primer login con contraseña.

**¿Qué formatos de documento acepta la app?**  
PDF, JPG, JPEG y PNG. Imágenes deben cumplir resolución mínima de calidad.

**¿Puedo tener cuenta Cliente y Asesor con el mismo correo?**  
No. Cada correo se registra una sola vez con un rol.

**¿El asesor ve todos los clientes de la plataforma?**  
Sí, los asesores autenticados pueden consultar casos según las reglas de Firestore del proyecto.

**¿Cómo cierro sesión?**  
Configuración → Cerrar sesión. También disponible desde el perfil del asesor.

**¿Qué significa "Riesgo Bajo" en mi score?**  
Indica un perfil financiero sólido según sus datos declarados. No garantiza aprobación bancaria.

**¿Puedo simular un crédito mayor al monto viable?**  
Sí, el simulador lo permite, pero la app mostrará la brecha entre lo deseado y lo viable según su capacidad.

---

## 6. Aviso legal — Score orientativo

> **El Score RiskMobile es un indicador meramente informativo y orientativo.**  
> Su propósito es dar al usuario una aproximación del perfil de riesgo que podría estar manejando, con base en la información financiera que él mismo declara dentro de la plataforma.
>
> **Este score NO reemplaza ni representa el score real de las centrales de riesgo** (Datacrédito, TransUnion, etc.). Para conocer el score directo de las centrales, el usuario debe realizar la consulta oficial con pago correspondiente.
>
> RiskMobile no es una entidad financiera regulada. No otorga créditos ni garantiza aprobaciones. La asesoría prestada por terceros es responsabilidad del asesor independiente.

---

## Referencias

- [Documentación técnica](../TECNICA.md)
- [Lista de capturas](screenshots/README.md)
- [Cómo ejecutar la app](../../COMO_EJECUTAR.md)
- [APK release](../../releases/RiskMobile-v1.0.0.apk)

---

**RiskMobile — Tu asesoría crediticia, en tu mano**  
Desarrollado por Kevin Cardoso y Brandon Faruck Villamarin · USC · 2026
