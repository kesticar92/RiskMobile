# Instrucciones para grabar el video demo — RiskMobile

**Duración sugerida:** 5–7 minutos  
**Formato:** MP4, 1080p, pantalla del emulador o dispositivo físico  
**Herramientas:** OBS Studio, QuickTime (Mac) o grabación nativa de Android

---

## Preparación previa

1. Instalar el APK release desde `releases/RiskMobile-v1.0.0.apk` o ejecutar `flutter run`.
2. Tener dos cuentas de prueba:
   - **Cliente:** `cliente.demo@riskmobile.test`
   - **Asesor:** `asesor.demo@riskmobile.test`
3. Completar al menos una entrevista financiera con el cliente demo antes de grabar.
4. Activar modo avión desactivado; conexión estable a Internet (Firebase).
5. Ocultar notificaciones del sistema durante la grabación.

---

## Estructura del video (5–7 min)

| Minuto | Sección | Qué mostrar |
|--------|---------|-------------|
| 0:00–0:30 | Intro | Splash RiskMobile v1.0.0 → Login |
| 0:30–2:00 | Flujo Cliente | Registro o login → Entrevista 3 pasos → Score → Perfil financiero |
| 2:00–3:00 | Documentos y simulador | Carga de documento → Simulador con sliders |
| 3:00–4:30 | Flujo Asesor | CRM → Detalle cliente → Cambio de estado → Validar documento |
| 4:30–5:30 | Chat y comisiones | Mensaje asesor-cliente → Registrar comisión |
| 5:30–6:00 | Cierre | Configuración → Aviso legal del score → Logo final |

---

## Pasos detallados

### Parte 1 — Cliente (≈3 min)

1. Abrir app → esperar Splash (barra de progreso, tagline).
2. Iniciar sesión como **Cliente**.
3. Home: mostrar saludo "Hola, [nombre]" y accesos rápidos.
4. **Entrevista financiera:**
   - Paso 1: actividad económica, contrato, antigüedad, ingresos.
   - Paso 2: obligaciones (agregar al menos una).
   - Paso 3: monto deseado y tipo de crédito → "Calcular mi perfil".
5. **Perfil financiero:** score circular, gauge de endeudamiento, aviso orientativo.
6. **Documentos:** tomar foto o subir PDF de prueba.
7. **Simulador:** mover sliders de tasa, plazo y monto; mostrar cuota en tiempo real.

### Parte 2 — Asesor (≈3 min)

1. Cerrar sesión → login como **Asesor**.
2. **CRM:** métricas, búsqueda, filtros por estado.
3. Abrir **detalle de cliente:** perfil completo, score, obligaciones.
4. Cambiar **estado del caso** → mostrar historial de cambios.
5. **Validar documento:** aprobar o rechazar → notificación al cliente.
6. **Chat:** enviar mensaje con plantilla rápida.
7. **Comisiones:** registrar comisión → panel financiero con utilidad neta.

---

## Consejos de grabación

- Usar emulador **Pixel 7 API 34** o dispositivo Android 10+.
- Resolución recomendada: 1080×2400 (portrait).
- Narrar en voz clara qué hace cada acción ("Ahora el asesor aprueba el documento…").
- Evitar mostrar correos reales o datos personales sensibles.
- Al final, mencionar: *"Score RiskMobile orientativo; no reemplaza centrales de riesgo."*

---

## Comandos útiles

```bash
# Lanzar emulador Android
flutter emulators --launch Pixel_7_API34

# Ejecutar app en el emulador
flutter run -d Pixel_7_API34

# Instalar APK release en dispositivo conectado
adb install releases/RiskMobile-v1.0.0.apk
```

---

## Entregable final

- Archivo: `RiskMobile-demo-v1.0.0.mp4`
- Subir a Drive/YouTube (enlace no listado) e incluir URL en la presentación oral.
