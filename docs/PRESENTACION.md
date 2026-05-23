# Presentación — RiskMobile

**Formato:** 10 slides · Markdown  
**Duración total sugerida:** 15–20 min (presentación + demo + Q&A)  
**Equipo:** Kevin Cardoso · Brandon Faruck Villamarin

---

## Slide 1 — Portada

**RiskMobile**  
*Tu asesoría crediticia, en tu mano*

Plataforma móvil SaaS de evaluación financiera y gestión de asesoría crediticia

- Computación Móvil 2026-1
- Kevin Cardoso · Brandon Faruck Villamarin
- Versión 1.0.0 · Mayo 2026

---

## Slide 2 — El problema

**Muchas personas solicitan créditos sin conocer su viabilidad real.**

- Cada solicitud fallida genera **huella en centrales de riesgo** (Datacrédito, TransUnion)
- El score crediticio **se deteriora** con consultas innecesarias
- No existen apps móviles que integren **simulación + evaluación + asesoría + CRM** en un solo flujo
- Los asesores financieros independientes carecen de herramientas digitales integradas

> *"Aplico a créditos a ciegas y cada rechazo me cierra más puertas."*

---

## Slide 3 — Audiencia objetivo

| Actor | Necesidad |
|-------|-----------|
| **Cliente** | Conocer su capacidad de pago antes de solicitar crédito |
| **Asesor financiero independiente** | Gestionar clientes, casos, documentos y comisiones en un solo lugar |

**Mercado:** Personas naturales interesadas en créditos de consumo, vivienda, vehículo; asesores que cobran comisión por gestión crediticia.

**Plataformas:** Android (APK entregado), iOS y Web en desarrollo con Flutter.

---

## Slide 4 — Nuestra solución

RiskMobile integra en **una sola aplicación móvil**:

1. Entrevista financiera digital (3 pasos)
2. Motor de evaluación con **Score RiskMobile** (0–100)
3. Simulador dinámico de crédito (sliders en tiempo real)
4. Carga y validación documental
5. CRM del asesor con filtros avanzados
6. Chat en tiempo real asesor–cliente
7. Panel de comisiones y utilidades

**Sin consultar centrales de riesgo. Sin huella negativa.**

---

## Slide 5 — Diferenciador

| Aspecto | RiskMobile | Alternativas típicas |
|---------|------------|---------------------|
| Evaluación preliminar | Sí, Score propio | No o solo simulador básico |
| Huella en centrales | No | Sí (al aplicar) |
| CRM para asesor | Integrado | Herramientas separadas |
| Chat asesor-cliente | Tiempo real | WhatsApp externo |
| Gestión documental | Con revisión y estados | Manual / email |
| Comisiones del asesor | Panel integrado | Excel / cuaderno |

**Propuesta de valor:** Todo el ciclo crediticio preliminar en una app, para cliente y asesor.

---

## Slide 6 — Arquitectura técnica

```
Flutter (UI) → Riverpod (Estado) → Services → Firebase BaaS
```

| Capa | Tecnología |
|------|------------|
| Frontend | Flutter 3.41 · Material 3 · 16 pantallas |
| Estado | Riverpod |
| Navegación | GoRouter |
| Backend | Firebase Auth + Firestore + Storage |
| Cálculos | RiskCalculator (Dart puro) |

Ver diagrama completo: [`docs/diagramas/arquitectura.mmd`](diagramas/arquitectura.mmd)

**Seguridad:** Reglas Firestore por rol (cliente/asesor), autenticación biométrica opcional.

---

## Slide 7 — Demo en vivo (guion 5–7 min)

### Parte A — Flujo Cliente (~3 min)

1. **Login/Registro** — Mostrar selector Cliente/Asesor
2. **Entrevista paso 1** — Empleado, ingreso $3.000.000, 24 meses antigüedad
3. **Entrevista paso 2** — Agregar obligación Bancolombia, cuota $600.000
4. **Entrevista paso 3** — Monto deseado $20.000.000, Libre inversión
5. **Perfil financiero** — Mostrar Score (~85), gauge de endeudamiento, capacidad
6. **Simulador** — Mover slider de plazo, mostrar cuota en tiempo real
7. **Documentos** — Subir foto o PDF, mostrar estado completado

### Parte B — Flujo Asesor (~3 min)

1. **CRM** — Mostrar lista de clientes, métricas, filtro por estado
2. **Detalle cliente** — Score, obligaciones, nota interna
3. **Cambiar estado** — "Análisis en proceso" → SnackBar confirmación
4. **Revisar documento** — Aprobar o rechazar, notificación al cliente
5. **Chat** — Enviar mensaje o plantilla rápida
6. **Comisiones** — Registrar comisión, mostrar utilidad calculada

### Tips para la demo

- Tener **dos cuentas** creadas (cliente + asesor) antes de la exposición
- Proyectar Firebase Console (Auth + Firestore) como evidencia de persistencia
- Si falla internet, mostrar screenshots de `docs/manual/screenshots/`

---

## Slide 8 — Tecnologías y métricas

| Métrica | Valor |
|---------|-------|
| Pantallas | 16 |
| Requerimientos funcionales | 38 |
| Requerimientos no funcionales | 20 |
| Validaciones | 62 |
| Módulos | 9 |
| Roles | 2 (Cliente / Asesor) |
| APK release | 60.6 MB |

**Stack:** Flutter · Dart · Firebase · Riverpod · GoRouter · local_auth · image_picker · share_plus

---

## Slide 9 — Requerimientos funcionales implementados

**Bloque base (RF01–RF38):** Registro, login, biometría, entrevista 3 pasos, obligaciones, documentos, Score RiskMobile, simulador, CRM, chat, comisiones, historial, validación documental, notificaciones.

**Bloque Kevin (RF-K5–K19):** Nota interna, búsqueda por ID, orden CRM, prioridad, filtros avanzados, etiquetas, archivar, seguimiento, export TSV, WhatsApp.

**Bloque Brandon (RF-B5–B14):** Checklist soportes, compresión imagen, banner reenvío, progreso extractos, agrupación documentos, búsqueda, vista cuadrícula, compartir URL.

> Algunos RF marcados como "parcial" en README requieren QA formal pero tienen implementación funcional.

---

## Slide 10 — Futuro, equipo y cierre

### Trabajo futuro

- Integración OCR para lectura automática de documentos
- Consulta real a centrales de riesgo (Datacrédito) con pasarela de pago
- Modelos ML para predicción de riesgo
- Dashboard web para administradores
- Modo offline con sincronización

### Equipo

| Nombre | Rol |
|--------|-----|
| Kevin Cardoso | Desarrollador principal / Arquitectura |
| Brandon Faruck Villamarin | Desarrollador / QA |

### Cierre

**RiskMobile** — Evalúa antes de aplicar. Gestiona antes de perder clientes.

Repositorio: [github.com/kesticar92/RiskMobile](https://github.com/kesticar92/RiskMobile)  
APK: `releases/RiskMobile-v1.0.0.apk`

---

## Slide 11 — Q&A

**Preguntas anticipadas:**

| Pregunta | Respuesta breve |
|----------|-----------------|
| ¿Consulta Datacrédito? | No. Score interno basado en datos declarados. |
| ¿Es seguro? | Firebase con reglas por rol, HTTPS, biometría opcional. |
| ¿Funciona offline? | No en v1.0. Requiere internet. |
| ¿Cuánto cuesta? | Proyecto académico; modelo SaaS futuro. |
| ¿Por qué Flutter? | Multiplataforma con un solo código (Android, iOS, Web). |
| ¿Cómo se calcula el score? | 4 variables ponderadas: capacidad 40%, endeudamiento 30%, estabilidad 20%, historial 10%. |

**¡Gracias! ¿Preguntas?**
