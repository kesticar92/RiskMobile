# RiskMobile

**Plataforma móvil SaaS de evaluación financiera, simulación crediticia y gestión de asesoría para asesores financieros independientes.**

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

## Score RiskMobile

El sistema genera un indicador interno de perfil financiero (0-100) antes de consultar centrales de riesgo.

### Fórmula de cálculo

| Factor | Peso |
|---|---|
| Capacidad de pago | 40% |
| Nivel de endeudamiento | 30% |
| Estabilidad laboral | 20% |
| Historial financiero declarado | 10% |

### Clasificación

| Score | Nivel de Riesgo |
|---|---|
| 80 – 100 | Riesgo Bajo |
| 60 – 79 | Riesgo Medio |
| 40 – 59 | Riesgo Alto |
| 0 – 39 | Riesgo Muy Alto |

---

## Requisitos Funcionales

| ID | Requisito | Prioridad |
|---|---|---|
| RF01 | El sistema debe permitir el registro de usuarios mediante correo electrónico y contraseña | Alta |
| RF02 | El sistema debe autenticar usuarios utilizando Firebase Authentication | Alta |
| RF03 | El sistema debe permitir la autenticación biométrica (huella/Face ID) | Alta |
| RF04 | El sistema debe asignar roles diferenciados: Cliente y Asesor | Alta |
| RF05 | El sistema debe permitir al cliente realizar una entrevista financiera digital estructurada | Alta |
| RF06 | El sistema debe solicitar información sobre la actividad económica del cliente (empleado, independiente, pensionado, comerciante, profesional independiente) | Alta |
| RF07 | El sistema debe permitir al cliente registrar sus ingresos mensuales | Alta |
| RF08 | El sistema debe permitir la carga de documentos soporte mediante fotografía desde la cámara | Alta |
| RF09 | El sistema debe permitir la carga de documentos soporte desde archivos (PDF, imagen) | Alta |
| RF10 | El sistema debe solicitar información sobre obligaciones financieras actuales del cliente | Alta |
| RF11 | El sistema debe permitir registrar por cada obligación: entidad, tipo de crédito, cuota mensual y saldo | Alta |
| RF12 | El sistema debe permitir la carga de extractos bancarios como soporte de obligaciones | Media |
| RF13 | El sistema debe calcular automáticamente el nivel de endeudamiento (total cuotas / ingresos) | Alta |
| RF14 | El sistema debe calcular la capacidad disponible para nueva cuota | Alta |
| RF15 | El sistema debe generar el Score RiskMobile (0-100) basado en capacidad de pago, endeudamiento, estabilidad laboral e historial financiero | Alta |
| RF16 | El sistema debe clasificar el riesgo del cliente (bajo, medio, alto, muy alto) | Alta |
| RF17 | El sistema debe proporcionar un simulador dinámico de crédito con slider de tasa de interés | Alta |
| RF18 | El sistema debe proporcionar un slider de plazo de crédito (6-240 meses) | Alta |
| RF19 | El sistema debe permitir seleccionar el tipo de crédito (vivienda, vehículo, libre inversión, libranza, educativo, microcrédito) | Alta |
| RF20 | El sistema debe calcular automáticamente la cuota mensual y el monto máximo estimado según los parámetros del simulador | Alta |
| RF21 | El sistema debe permitir al cliente registrar el monto deseado de crédito | Media |
| RF22 | El sistema debe comparar el monto deseado contra el monto viable y mostrar el análisis de brecha | Media |
| RF23 | El sistema debe proporcionar al asesor un panel CRM con todos los clientes asignados | Alta |
| RF24 | El sistema debe permitir al asesor visualizar el perfil financiero completo de cada cliente | Alta |
| RF25 | El sistema debe permitir al asesor actualizar el estado del caso (entrevista completada, análisis en proceso, documentos pendientes, solicitud radicada, crédito aprobado, crédito rechazado) | Alta |
| RF26 | El sistema debe proporcionar comunicación en tiempo real entre asesor y cliente mediante chat interno | Alta |
| RF27 | El sistema debe permitir al asesor buscar y filtrar clientes por nombre y estado del caso | Media |
| RF28 | El sistema debe permitir al asesor registrar comisiones cobradas por caso | Alta |
| RF29 | El sistema debe calcular la utilidad neta del asesor (comisión - costos) | Alta |
| RF30 | El sistema debe mostrar un panel financiero del asesor con ingresos totales, comisiones, costos y utilidades | Alta |
| RF31 | El sistema debe mostrar estadísticas de clientes: total, aprobados, en proceso | Media |
| RF32 | El sistema debe permitir cerrar sesión desde cualquier pantalla | Baja |
| RF33 | El sistema debe permitir la configuración de notificaciones push | Media |
| RF34 | El sistema debe permitir la activación/desactivación de autenticación biométrica | Media |
| RF35 | El sistema debe almacenar los documentos cargados de forma segura en Firebase Storage | Alta |

---

## Requisitos No Funcionales

| ID | Requisito | Categoría |
|---|---|---|
| RNF01 | La información financiera debe almacenarse cifrada en reposo mediante las reglas de seguridad de Firestore | Seguridad |
| RNF02 | Todas las comunicaciones deben realizarse mediante protocolo HTTPS/TLS | Seguridad |
| RNF03 | El sistema debe implementar autenticación multifactor (correo + biometría) | Seguridad |
| RNF04 | El acceso a datos debe estar controlado por roles (cliente solo ve sus datos, asesor ve sus clientes) | Seguridad |
| RNF05 | El sistema debe aplicar principios Zero-Trust: verificación continua de identidad | Seguridad |
| RNF06 | Las contraseñas deben tener un mínimo de 8 caracteres | Seguridad |
| RNF07 | La aplicación debe tener disponibilidad mínima del 99% (garantizada por Firebase) | Disponibilidad |
| RNF08 | El tiempo de respuesta del cálculo de evaluación financiera no debe superar 2 segundos | Rendimiento |
| RNF09 | El simulador de crédito debe actualizar los valores en tiempo real al mover los sliders | Rendimiento |
| RNF10 | La carga de documentos debe mostrar indicador de progreso | Rendimiento |
| RNF11 | La aplicación debe ejecutarse en Android 10+ y iOS 14+ | Compatibilidad |
| RNF12 | La aplicación debe funcionar correctamente en pantallas de 5" a 12" | Compatibilidad |
| RNF13 | El proceso de entrevista financiera debe completarse en máximo 3 pasos | Usabilidad |
| RNF14 | La interfaz debe seguir las guías de diseño de Material 3 con tipografía tipo Apple (Inter/SF Pro) | Usabilidad |
| RNF15 | La paleta de colores debe usar azul claro (#4FC3F7), morado claro (#CE93D8), tonos traslúcidos y fondos blancos | Usabilidad |
| RNF16 | La aplicación debe mostrar animaciones fluidas (mínimo 60fps) | Usabilidad |
| RNF17 | El sistema debe soportar múltiples clientes concurrentes sin degradación de rendimiento | Escalabilidad |
| RNF18 | La arquitectura debe permitir la futura integración de OCR para análisis automático de documentos | Escalabilidad |
| RNF19 | La arquitectura debe permitir la futura integración con APIs bancarias y centrales de riesgo (Datacrédito) | Escalabilidad |
| RNF20 | La arquitectura debe permitir la futura integración de modelos de IA/ML para predicción de riesgo | Escalabilidad |

---

## Flujo del Sistema

1. **Registro** — El usuario crea su cuenta (correo + contraseña + rol)
2. **Entrevista financiera** — Responde preguntas sobre actividad económica e ingresos
3. **Carga de documentos** — Adjunta soportes de ingresos y obligaciones (foto/archivo)
4. **Evaluación de obligaciones** — Registra créditos actuales y cuotas mensuales
5. **Cálculo de perfil** — El sistema calcula endeudamiento, capacidad y Score RiskMobile
6. **Simulación** — El usuario explora montos, tasas y plazos con sliders interactivos
7. **Intención** — El usuario declara cuánto dinero desea solicitar
8. **Panel del asesor** — El asesor analiza el perfil, documentos y la brecha monto deseado vs viable
9. **Comunicación** — Asesor y cliente intercambian mensajes por chat
10. **Gestión del caso** — El asesor actualiza estados, registra avances y tareas
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

# Configurar Firebase (reemplazar firebase_options.dart con tus credenciales)
# flutterfire configure

# Ejecutar en modo debug
flutter run
```

---

## Trabajo Futuro

- Integración de OCR para análisis automático de documentos
- Integración con APIs de centrales de riesgo (Datacrédito Experian)
- Modelos de IA/ML para predicción avanzada de riesgo crediticio
- Integración con pasarelas de pago (PSE, tarjeta)
- Firma digital de documentos
- Modo offline con sincronización automática
- Dashboard web para administradores

---

## Licencia

Proyecto académico — Universidad | Computación Móvil 2026-1

**Desarrollado por Kevin Cardoso y Brandon Faruck Villamarin**
