# Manual de usuario — RiskMobile

**Versión:** 1.0.0  
**Para:** Clientes y asesores financieros independientes  
**Idioma:** Español · Lenguaje sencillo

---

## 1. ¿Qué es RiskMobile?

RiskMobile es una aplicación para celular que te ayuda a **conocer tu capacidad de pago** antes de solicitar un crédito, **sin consultar centrales de riesgo** como Datacrédito.

Con RiskMobile puedes:

- Responder una entrevista financiera sencilla (3 pasos)
- Ver tu **Score RiskMobile** (una nota de 0 a 100 que resume tu perfil)
- Simular cuotas, plazos y montos de crédito
- Subir documentos de soporte (fotos o PDF)
- Hablar con tu asesor financiero por chat

Si eres **asesor**, también puedes gestionar tus clientes, revisar sus casos y llevar el control de tus comisiones.

> **Importante sobre el Score:** El Score RiskMobile es solo una **guía orientativa** basada en la información que tú mismo ingresas. **No es el score oficial** de Datacrédito ni de otras centrales. Para conocer tu score real debes pagar la consulta directamente en esas entidades.

---

## 2. Requisitos

| Requisito | Detalle |
|-----------|---------|
| Dispositivo | Celular Android 10 o superior |
| Conexión | Internet (Wi‑Fi o datos móviles) |
| Cuenta | Correo electrónico válido |
| APK | Archivo `RiskMobile-v1.0.0.apk` (ver sección 3) |
| Opcional | Huella dactilar o Face ID (solo en celular físico) |

---

## 3. Cómo instalar la aplicación

1. **Descarga** el archivo APK desde la carpeta `releases/` del proyecto o el enlace que te comparta tu profesor/equipo.
2. En tu Android, ve a **Ajustes → Seguridad** y activa **"Instalar apps desconocidas"** para el navegador o gestor de archivos que uses.
3. Abre el archivo `RiskMobile-v1.0.0.apk` y pulsa **Instalar**.
4. Al terminar, pulsa **Abrir**.

> INSERTAR CAPTURA: `docs/manual/screenshots/01-splash-login.png` — Pantalla inicial con logo RiskMobile

---

## 4. Crear tu cuenta

1. Abre la app. Verás la pantalla de inicio (Splash) y luego el **Login**.
2. Pulsa **"Regístrate"**.
3. Completa:
   - Nombre completo
   - Correo electrónico
   - Teléfono (opcional)
   - Contraseña (mínimo 8 caracteres, con letra y número)
   - Confirmar contraseña
4. Elige tu rol:
   - **Cliente** — si quieres evaluar tu perfil financiero
   - **Asesor** — si vas a gestionar clientes
5. Pulsa **"Crear cuenta"**.

> INSERTAR CAPTURA: `docs/manual/screenshots/02-registro.png` — Formulario de registro con selector Cliente/Asesor

---

## 5. Rol Cliente — Guía paso a paso

### 5.1 Iniciar sesión

1. Ingresa tu correo y contraseña.
2. Pulsa **"Iniciar sesión"**.
3. Si olvidaste tu clave, usa **"¿Olvidaste tu contraseña?"** y revisa tu correo.
4. En un celular físico, después del primer login puedes usar **"Acceso biométrico"**.

> INSERTAR CAPTURA: `docs/manual/screenshots/03-cliente-home.png` — Home con "Hola, [tu nombre]"

### 5.2 Entrevista financiera (3 pasos)

Desde el Home, entra a **"Entrevista financiera"**.

**Paso 1 — Tu trabajo e ingresos**

1. Selecciona tu **actividad económica** (Empleado, Independiente, Pensionado, etc.).
2. Si aplica, elige tu **tipo de contrato**.
3. Indica tu **antigüedad** en meses.
4. Escribe tu **ingreso mensual**.
5. Pulsa **Continuar**.

> INSERTAR CAPTURA: `docs/manual/screenshots/04-entrevista-paso1.png`

**Paso 2 — Tus deudas actuales**

1. Indica si tienes créditos activos (Sí/No).
2. Si tienes, pulsa **"Agregar obligación"** y completa: banco, tipo de crédito, cuota mensual y saldo (opcional).
3. Puedes agregar varias obligaciones.
4. Pulsa **Continuar**.

> INSERTAR CAPTURA: `docs/manual/screenshots/05-entrevista-paso2.png`

**Paso 3 — Lo que deseas**

1. Escribe el **monto** que te gustaría solicitar.
2. Elige el **tipo de crédito** (Libre inversión, Vivienda, Vehículo, etc.).
3. Pulsa **"Calcular mi perfil financiero"**.

> INSERTAR CAPTURA: `docs/manual/screenshots/06-entrevista-paso3.png`

### 5.3 Ver tu perfil y Score

Después de la entrevista verás:

- Tu **Score RiskMobile** (número grande de 0 a 100)
- El **nivel de endeudamiento** (barra de colores)
- Tu **capacidad disponible** para una nueva cuota
- Comparación entre lo que deseas y lo que es viable

> INSERTAR CAPTURA: `docs/manual/screenshots/07-perfil-financiero.png`

### 5.4 Simular un crédito

1. Desde el perfil o el menú, entra al **Simulador**.
2. Mueve los sliders de **tasa**, **plazo** y **monto**.
3. Usa los botones rápidos de plazo (6M, 1A, 2A, etc.).
4. Observa cómo cambia la **cuota mensual** y el **monto máximo viable** en tiempo real.

> INSERTAR CAPTURA: `docs/manual/screenshots/08-simulador.png`

### 5.5 Subir documentos

1. Ve a **"Mis documentos"**.
2. Elige cómo subir:
   - **Cámara** — tomar foto
   - **Galería** — elegir imagen
   - **Archivo** — PDF o imagen
3. Espera a que cada archivo muestre estado **Completado**.
4. Si hay error, pulsa **Reintentar**.

Documentos típicos: certificado laboral, desprendible de nómina, extractos bancarios, RUT.

> INSERTAR CAPTURA: `docs/manual/screenshots/09-documentos.png`

### 5.6 Historial y chat

- **Historial:** revisa evaluaciones anteriores y documentos por caso.
- **Chat:** escribe a tu asesor (máximo 500 caracteres por mensaje).

> INSERTAR CAPTURA: `docs/manual/screenshots/10-historial.png`  
> INSERTAR CAPTURA: `docs/manual/screenshots/13-chat.png`

---

## 6. Rol Asesor — Guía paso a paso

### 6.1 Panel CRM

Al iniciar sesión como Asesor verás el **Dashboard** con:

- Total de clientes
- Clientes aprobados
- Clientes en proceso
- Lista de casos con búsqueda y filtros

> INSERTAR CAPTURA: `docs/manual/screenshots/11-asesor-crm.png`

### 6.2 Gestionar un cliente

1. Pulsa un cliente de la lista para abrir su **detalle**.
2. Revisa: score, ingresos, obligaciones, documentos y historial de estados.
3. Cambia el **estado del caso** (Entrevista completada → Análisis → Documentos pendientes → etc.).
4. Revisa documentos y marca: Pendiente / Aprobado / Rechazado.
5. Agrega **nota interna**, **prioridad**, **etiquetas** o **próximo seguimiento** si lo necesitas.

> INSERTAR CAPTURA: `docs/manual/screenshots/12-asesor-detalle.png`

### 6.3 Chat con el cliente

1. Desde el detalle del cliente o el CRM, abre **Chat**.
2. Escribe mensajes o usa **plantillas rápidas** para respuestas frecuentes.
3. El cliente recibe los mensajes en tiempo real.

### 6.4 Comisiones y panel financiero

1. Ve a **Pagos / Comisiones**.
2. Registra: nombre del cliente, valor del crédito, comisión cobrada y costos.
3. La app calcula tu **utilidad estimada** automáticamente.
4. Consulta el historial de comisiones y totales.

> INSERTAR CAPTURA: `docs/manual/screenshots/15-comisiones.png`

---

## 7. Configuración

Desde **Configuración** puedes:

- Activar o desactivar **notificaciones**
- Activar o desactivar **acceso biométrico**
- **Cerrar sesión**

> INSERTAR CAPTURA: `docs/manual/screenshots/14-configuracion.png`

---

## 8. Preguntas frecuentes (FAQ)

**¿RiskMobile consulta Datacrédito?**  
No. La evaluación es preliminar y usa solo la información que tú declaras.

**¿Puedo usar la app sin internet?**  
No. Necesitas conexión para guardar datos y chatear.

**¿Por qué no funciona la biometría?**  
Solo funciona en celular físico con sensor configurado. No en emulador ni navegador.

**¿Puedo tener varios asesores?**  
En esta versión el cliente se conecta al asesor registrado en la plataforma.

**¿Qué pasa si rechazan un documento?**  
Recibirás una notificación y deberás volver a subir el archivo.

**¿Cómo recupero mi contraseña?**  
En Login → "¿Olvidaste tu contraseña?" → ingresa tu correo → revisa tu bandeja (y spam).

**¿Puedo cambiar de Cliente a Asesor?**  
El rol se define al registrarse. Para cambiarlo necesitarías una cuenta nueva.

---

## 9. Aviso legal — Score RiskMobile

El **Score RiskMobile** es un indicador **meramente informativo y orientativo**. Se calcula con datos que el usuario declara voluntariamente dentro de la aplicación.

- **No sustituye** el score de centrales de riesgo oficiales (Datacrédito, TransUnion, CIFIN, etc.).
- **No garantiza** la aprobación ni rechazo de un crédito en ninguna entidad financiera.
- Para conocer su historial crediticio oficial, el usuario debe realizar la consulta directa y pagada ante la central correspondiente.

RiskMobile es un proyecto académico desarrollado con fines educativos.

---

## 10. Soporte

Para dudas técnicas del proyecto académico, contacta al equipo de desarrollo:

- Kevin Cardoso
- Brandon Faruck Villamarin

Repositorio: [github.com/kesticar92/RiskMobile](https://github.com/kesticar92/RiskMobile)
