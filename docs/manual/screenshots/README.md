# Lista de capturas requeridas — Manual de usuario RiskMobile

Este directorio debe contener **18 capturas PNG** para ilustrar el [MANUAL_USUARIO.md](../MANUAL_USUARIO.md).

> **Estado:** Placeholders en el manual. Sustituir cada imagen siguiendo las instrucciones de esta lista.

---

## Cómo capturar

### Opción A — Emulador Android

```bash
flutter emulators --launch Pixel_7_API34
flutter run -d Pixel_7_API34
# En otra terminal, con el emulador enfocado:
adb exec-out screencap -p > docs/manual/screenshots/01-splash.png
```

### Opción B — Dispositivo físico

1. Ejecutar la app en el celular.
2. Navegar a la pantalla indicada.
3. Captura nativa (Power + Volumen en Android).
4. Transferir vía USB o ADB pull.

### Opción C — Flutter DevTools

Desde `flutter run`, usar el botón de screenshot del emulador o `adb screencap`.

---

## Lista de 18 capturas

| # | Archivo | Pantalla | Ruta | Rol | Qué debe verse |
|---|---------|----------|------|-----|----------------|
| 01 | `01-splash.png` | Splash | `/` | Todos | Logo RiskMobile, tagline, barra progreso, v1.0.0 |
| 02 | `02-login.png` | Login | `/login` | Todos | Campos correo/contraseña, botón biométrico, enlace registro |
| 03 | `03-register.png` | Registro | `/register` | Todos | Formulario completo, chips Cliente/Asesor |
| 04 | `04-client-home.png` | Home Cliente | `/client-home` | Cliente | Saludo "Hola, [nombre]", accesos rápidos, badge notificaciones |
| 05 | `05-interview-step1.png` | Entrevista Paso 1 | `/interview` | Cliente | Actividad económica, contrato, antigüedad, ingresos |
| 06 | `06-interview-step2.png` | Entrevista Paso 2 | `/interview` | Cliente | Switch obligaciones, lista de créditos agregados |
| 07 | `07-interview-step3.png` | Entrevista Paso 3 | `/interview` | Cliente | Monto deseado, chips tipo crédito, botón calcular |
| 08 | `08-calculator-score.png` | Perfil financiero | `/calculator` | Cliente | Score circular, clasificación, gauge endeudamiento |
| 09 | `09-documents.png` | Documentos | `/documents` | Cliente | Lista archivos, botones cámara/galería/archivo, estados |
| 10 | `10-simulator.png` | Simulador | `/simulator` | Cliente | Sliders tasa/plazo/monto, cuota estimada, barras comparativas |
| 11 | `11-evaluations-history.png` | Historial | `/evaluations-history` | Cliente | Lista evaluaciones con score y fecha |
| 12 | `12-chat-client.png` | Chat | `/chat` | Cliente | Burbujas mensajes, input, indicador en línea |
| 13 | `13-settings.png` | Configuración | `/settings` | Todos | Switches biometría/notificaciones, cerrar sesión |
| 14 | `14-advisor-crm.png` | CRM Asesor | `/advisor-dashboard` | Asesor | Métricas, búsqueda, filtros, tarjetas clientes |
| 15 | `15-client-detail.png` | Detalle cliente | `/client-detail` | Asesor | Perfil completo, score, cambio estado, historial |
| 16 | `16-document-validation.png` | Validación docs | `/client-detail` | Asesor | Lista documentos con selector Aprobado/Rechazado |
| 17 | `17-chat-advisor.png` | Chat asesor | `/chat` | Asesor | Plantillas rápidas, conversación con cliente |
| 18 | `18-commissions.png` | Comisiones | `/payments` | Asesor | Formulario comisión, panel utilidad neta |

---

## Convenciones

- **Formato:** PNG, resolución mínima 1080×1920.
- **Nombre:** exactamente como la columna "Archivo" (minúsculas, guiones).
- **Datos demo:** usar cuentas de prueba; no datos reales.
- **Idioma UI:** español (es_CO).

---

## Verificación

Tras agregar las capturas, comprobar que el manual las renderiza:

```bash
# Desde la raíz del proyecto
ls docs/manual/screenshots/*.png | wc -l
# Debe mostrar: 18
```

Si falta alguna captura, el manual muestra el texto alternativo del placeholder markdown.
