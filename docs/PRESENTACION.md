# Presentación — RiskMobile v1.0.0

**Duración total:** 5–7 minutos (demo incluida)  
**Equipo:** Kevin Cardoso · Brandon Faruck Villamarin  
**Curso:** Computación Móvil 2026-1 · USC

---

## Outline de slides (12 diapositivas)

| Slide | Título | Contenido clave | Tiempo |
|-------|--------|-----------------|--------|
| 1 | Portada | RiskMobile · Evaluación financiera móvil · v1.0.0 · Equipo | 15 s |
| 2 | El problema | Solicitudes sin viabilidad · huellas en centrales · procesos ineficientes | 30 s |
| 3 | La solución | App integral: entrevista + score + simulador + CRM + chat | 30 s |
| 4 | Actores | Cliente (evalúa y simula) · Asesor (gestiona y asesora) | 20 s |
| 5 | Arquitectura | Flutter → Riverpod → Services → Firebase · diagrama capas | 40 s |
| 6 | Stack tecnológico | Flutter 3.41 · Firebase · Riverpod · GoRouter · Material 3 | 30 s |
| 7 | Score RiskMobile | 4 variables · fórmula ponderada · clasificación colores · **orientativo** | 45 s |
| 8 | Demo Cliente | Entrevista 3 pasos → Score → Documentos → Simulador | 2 min |
| 9 | Demo Asesor | CRM → Detalle → Estado → Validar docs → Chat → Comisiones | 2 min |
| 10 | Seguridad | firestore.rules · storage.rules · roles · biometría | 30 s |
| 11 | Métricas del proyecto | 16 pantallas · 38 RF · 62 validaciones · APK release | 30 s |
| 12 | Cierre | Trabajo futuro (OCR, Datacrédito, IA) · preguntas · contacto | 20 s |

---

## Guion por slide

### Slide 1 — Portada (15 s)

> "Buenos días/tardes. Somos Kevin Cardoso y Brandon Faruck Villamarin. Hoy presentamos **RiskMobile**, nuestra plataforma móvil de evaluación financiera y gestión de asesoría crediticia, versión 1.0.0."

### Slide 2 — El problema (30 s)

> "Muchas personas solicitan créditos sin saber si califican. Eso genera consultas innecesarias en centrales de riesgo, empeora el historial crediticio y hace ineficiente el trabajo del asesor. No existía una app móvil que integrara evaluación, simulación y gestión del caso en un solo lugar."

### Slide 3 — La solución (30 s)

> "RiskMobile integra entrevista financiera digital, motor de evaluación con Score propio, simulador dinámico con sliders, CRM para asesores, chat en tiempo real y módulo de comisiones. Todo en Flutter multiplataforma con Firebase como backend."

### Slide 4 — Actores (20 s)

> "Dos roles: el **Cliente** completa la entrevista, carga documentos, ve su score y simula créditos. El **Asesor** gestiona clientes en un CRM, valida documentos, actualiza estados y registra comisiones."

### Slide 5 — Arquitectura (40 s)

> "La arquitectura tiene cuatro capas: UI en features con Material 3, estado con Riverpod, servicios que encapsulan Firebase, y el backend BaaS. GoRouter maneja 16 rutas. El motor RiskCalculator vive en la capa de dominio."

*Mostrar diagrama de [diagramas/arquitectura.md](./diagramas/arquitectura.md).*

### Slide 6 — Stack (30 s)

> "Frontend: Flutter 3.41 y Dart 3.11. Backend: Firebase Auth, Firestore y Storage. Estado: Riverpod. Navegación: GoRouter. UI: Material 3 con tipografía Inter. Integraciones: local_auth, share_plus, image_picker, file_picker."

### Slide 7 — Score RiskMobile (45 s)

> "El Score RiskMobile va de 0 a 100 con cuatro variables: capacidad de pago 40%, endeudamiento 30%, estabilidad laboral 20% e historial declarado 10%. Se clasifica en cuatro niveles con colores. **Es orientativo**: no reemplaza Datacrédito ni TransUnion."

*Mostrar fórmula y ejemplo del README.*

### Slide 8 — Demo Cliente (2 min) — EN VIVO

**Guion demo Cliente:**

1. **Splash → Login** (5 s): "Versión 1.0.0, redirige según sesión."
2. **Login como Cliente** (10 s): "Autenticación Firebase con correo y contraseña."
3. **Home** (10 s): "Saludo personalizado desde Firestore, accesos rápidos."
4. **Entrevista Paso 1** (20 s): "Actividad económica, contrato, antigüedad, ingresos."
5. **Paso 2** (20 s): "Obligaciones dinámicas; suma automática de cuotas."
6. **Paso 3** (15 s): "Monto deseado y tipo de crédito; aviso sin huella en centrales."
7. **Perfil financiero** (25 s): "Score animado, gauge de endeudamiento, clasificación de riesgo."
8. **Documentos** (15 s): "Cámara, galería o archivo; estados y reintento."
9. **Simulador** (20 s): "Sliders en tiempo real; cuota y monto viable."

> "El cliente completa todo el flujo en menos de 5 minutos sin salir de la app."

### Slide 9 — Demo Asesor (2 min) — EN VIVO

**Guion demo Asesor:**

1. **Cerrar sesión → Login Asesor** (10 s)
2. **CRM** (25 s): "Métricas, búsqueda, filtros por estado, monto y fecha."
3. **Detalle cliente** (25 s): "Perfil completo, score, obligaciones, nota interna."
4. **Cambio de estado** (20 s): "Selector de estado; historial y notificación al cliente."
5. **Validación documentos** (20 s): "Aprobar o rechazar; cliente notificado."
6. **Chat** (15 s): "Plantillas rápidas; mensajes en tiempo real vía Firestore."
7. **Comisiones** (15 s): "Registro con utilidad automática; panel financiero."

> "El asesor digitaliza su operación: del primer contacto al cobro de comisión."

### Slide 10 — Seguridad (30 s)

> "Reglas Firestore por rol: clientes solo sus datos, asesores acceden a casos. Storage aislado por userId. Biometría local post-login. HTTPS/TLS en todas las comunicaciones. Contraseñas con política mínima de complejidad."

### Slide 11 — Métricas (30 s)

> "16 pantallas implementadas, 38 requerimientos funcionales, 62 validaciones, 9 módulos, 2 roles. APK release de 60 MB compilado y disponible en releases/. Documentación técnica, manual de usuario y guiones incluidos."

### Slide 12 — Cierre (20 s)

> "Trabajo futuro: OCR de documentos, integración Datacrédito, pasarela de pagos, IA predictiva. RiskMobile: tu asesoría crediticia, en tu mano. ¿Preguntas?"

---

## Checklist pre-presentación

- [ ] APK instalado o `flutter run` en emulador Pixel 7
- [ ] Cuentas demo Cliente y Asesor creadas
- [ ] Al menos un caso con entrevista completada
- [ ] Documento de prueba cargado
- [ ] Conexión Internet estable
- [ ] Firebase Console abierta (opcional, para mostrar datos en nube)
- [ ] Diagrama arquitectura visible en slide 5

---

## Material de apoyo

| Documento | Uso en presentación |
|-----------|---------------------|
| [TECNICA.md](./TECNICA.md) | Slides 5–7, 10–11 |
| [ELEVATOR_PITCH.md](./ELEVATOR_PITCH.md) | Introducción 2 min si piden pitch corto |
| [MANUAL_USUARIO.md](./manual/MANUAL_USUARIO.md) | Referencia flujos demo |
| [demo/README.md](./demo/README.md) | Grabación video demo |
| [releases/RiskMobile-v1.0.0.apk](../releases/RiskMobile-v1.0.0.apk) | Distribución APK |

---

**RiskMobile · USC · 2026**
