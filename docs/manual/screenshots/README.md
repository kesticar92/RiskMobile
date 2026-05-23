# Capturas de pantalla — Manual de usuario

Esta carpeta debe contener las capturas referenciadas en `docs/manual/MANUAL_USUARIO.md`.

## Estado actual

Las capturas **no se generaron automáticamente** en este entorno (sin emulador Android/iOS conectado ni sesión gráfica para screenshots). Los archivos PNG listados abajo deben insertarse manualmente antes de la entrega impresa o PDF.

## Cómo generar las capturas

1. Instalar el APK: `adb install releases/RiskMobile-v1.0.0.apk` (o abrir con el emulador).
2. Crear una cuenta de prueba **Cliente** y otra **Asesor** (correos distintos).
3. Recorrer los flujos descritos en el manual y tomar screenshot en cada paso.
4. Guardar cada imagen con el nombre exacto indicado abajo.

Alternativa en desarrollo:

```bash
flutter run -d chrome   # UI rápida (sin biometría)
# o
flutter run             # emulador/dispositivo Android
```

## Lista de capturas requeridas

| Archivo | Descripción de lo que debe mostrar |
|---------|--------------------------------------|
| `01-splash-login.png` | Pantalla Splash o Login con logo RiskMobile |
| `02-registro.png` | Formulario de registro con selector Cliente/Asesor |
| `03-cliente-home.png` | Home del cliente con saludo "Hola, [nombre]" |
| `04-entrevista-paso1.png` | Entrevista paso 1: actividad económica e ingresos |
| `05-entrevista-paso2.png` | Entrevista paso 2: obligaciones financieras |
| `06-entrevista-paso3.png` | Entrevista paso 3: monto deseado y tipo de crédito |
| `07-perfil-financiero.png` | Perfil financiero con Score RiskMobile y gauge de endeudamiento |
| `08-simulador.png` | Simulador con sliders de tasa, plazo y monto |
| `09-documentos.png` | Pantalla de carga de documentos (cámara/galería/archivo) |
| `10-historial.png` | Historial de evaluaciones del cliente |
| `11-asesor-crm.png` | Panel CRM del asesor con lista de clientes |
| `12-asesor-detalle.png` | Detalle de cliente visto por el asesor |
| `13-chat.png` | Chat asesor-cliente con burbujas de mensajes |
| `14-configuracion.png` | Pantalla de configuración (notificaciones, biometría, cerrar sesión) |
| `15-comisiones.png` | Panel de comisiones / pagos del asesor |

## Formato recomendado

- Resolución: 1080×1920 px (portrait) o captura nativa del dispositivo.
- Formato: PNG.
- Evitar datos personales reales; usar cuentas de prueba.
