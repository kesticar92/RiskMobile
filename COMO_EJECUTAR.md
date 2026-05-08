# Cómo ejecutar y probar RiskMobile

*Guía vigente; alineada con la documentación del proyecto al **18 de abril de 2026**.*

## 1. Requisitos previos

- **Flutter SDK** instalado (3.0 o superior). Verifica con:
  ```bash
  flutter doctor
  ```
- **Android Studio** (para Android) o **Xcode** (para iOS en Mac).
- **Dispositivo** físico o emulador conectado/en marcha.

---

## 2. Instalar dependencias

En la raíz del proyecto (`RiskMobile`):

```bash
cd d:\RiskMobile
flutter pub get
```

---

## 3. Ejecutar la app

### En un emulador o dispositivo Android

1. Conecta un celular con USB (modo desarrollador y depuración USB activos) o abre un emulador desde Android Studio.
2. Ejecuta:
   ```bash
   flutter run
   ```
3. Si tienes varios dispositivos, elige uno:
   ```bash
   flutter devices
   flutter run -d <id-del-dispositivo>
   ```

### En Chrome (solo para probar UI rápido)

```bash
flutter run -d chrome
```

**Nota:** En web, Firebase Auth y Firestore funcionan, pero la biometría no estará disponible.

### En iOS (solo en Mac con Xcode)

```bash
flutter run
```
(o selecciona el simulador iOS con `flutter run -d <id>`).

---

## 4. Ver los cambios en tiempo real

Con la app en marcha (`flutter run` o `flutter run -d chrome`), los cambios de código **no se ven solos** en el navegador o el emulador. Hay que recargar desde la **terminal donde está corriendo Flutter**:

| Qué hacer | Tecla | Efecto |
|-----------|--------|--------|
| **Hot reload** | Pulsa **`r`** (minúscula) y Enter | Aplica los cambios de código y mantiene el estado (sigues logueado, en la misma pantalla). Es lo más rápido para ver cambios. |
| **Hot restart** | Pulsa **`R`** (mayúscula) y Enter | Reinicia la app desde cero. Pierdes la sesión y vuelves al login. Úsalo si con `r` no se actualiza algo. |
| **Parar y volver a ejecutar** | **Ctrl + C** en la terminal, luego `flutter run -d chrome` (o el comando que uses) | Cierra la app y la vuelve a abrir desde cero. |

La pestaña del navegador (por ejemplo `http://localhost:55021/#/client-home`) muestra lo que Flutter está ejecutando; para que se apliquen cambios de código hay que hacer **hot reload (`r`)** o **hot restart (`R`)** en esa terminal.

---

## 5. Flujo para probar Login y Registro

1. **Splash**  
   Al abrir la app verás el logo RiskMobile, la barra de progreso y "v1.0.0". Espera unos segundos.

2. **Login**  
   Si no hay sesión, llegarás a la pantalla de inicio de sesión.
   - **Crear cuenta:** toca "Regístrate".
   - **Registro:** llena nombre, correo, contraseña (mín. 8 caracteres, una letra y un número), confirma contraseña y elige **Cliente** o **Asesor**. Toca "Crear cuenta".
   - Tras registrarte, deberías entrar al **Home del cliente** o al **Dashboard del asesor** según el rol.

3. **Cerrar sesión y probar Login**  
   - Ve a **Configuración** (desde el menú o perfil) y cierra sesión.
   - Vuelve al Login e inicia sesión con el mismo correo y contraseña.

4. **Recuperar contraseña**  
   - En Login, toca "¿Olvidaste tu contraseña?".
   - Ingresa el correo registrado y "Enviar enlace".
   - Revisa el correo (y carpeta de spam) para el enlace de restablecimiento de Firebase.

5. **Acceso biométrico**  
   - Solo funciona en **dispositivo físico** (no en emulador ni web).
   - Primero inicia sesión una vez con correo/contraseña; después podrás usar "Acceso biométrico" si el dispositivo lo soporta.

---

## 6. Si algo falla

### "No devices found"
- Android: abre un emulador (Android Studio → Device Manager) o conecta un celular.
- Ejecuta `flutter devices` para ver dispositivos disponibles.

### Errores de Firebase (Auth o Firestore)
- En [Firebase Console](https://console.firebase.google.com/) → proyecto **riskmobile-c59fc**:
  - **Authentication** → pestaña "Sign-in method" → habilita **Correo/Contraseña**.
  - **Firestore** → crea la base de datos si no existe y configura reglas (en desarrollo puedes usar reglas de prueba; en producción restringe por `auth.uid`).

### Android: "google-services.json" o plugin de Google services
- Si Flutter te pide `google-services.json`, descárgalo desde Firebase Console → Configuración del proyecto → Tu app Android → y colócalo en `android/app/google-services.json`.
- Luego ejecuta de nuevo `flutter run`.

### Limpiar y volver a compilar
```bash
flutter clean
flutter pub get
flutter run
```

---

## 7. Cómo demostrar la conexión a la base de datos (para el profesor)

Si te piden **probar o explicar** la conexión a la base de datos, puedes hacer lo siguiente.

### Qué explicar en palabras

Puedes decir algo así:

> "La app se conecta a Firebase como base de datos en la nube. Usamos dos servicios: **Firebase Authentication** para registrar e iniciar sesión (correo y contraseña), y **Cloud Firestore** para guardar el perfil del usuario (nombre, rol, teléfono). La conexión se configura al iniciar la app en `main.dart` con `Firebase.initializeApp()`. Al registrarse, se crea el usuario en Auth y su documento en la colección `users` de Firestore. Al iniciar sesión, se valida con Auth y se lee el perfil desde Firestore para mostrar el nombre y redirigir según el rol (Cliente o Asesor)."

### Qué mostrar en la app (demostración en vivo)

1. **Ejecutar la app** (por ejemplo `flutter run -d chrome`).
2. **Registro:** tocar "Regístrate" → llenar nombre, correo, contraseña, elegir Cliente o Asesor → "Crear cuenta".
3. **Comprobar que entró:** debe aparecer el Home con "Hola, [tu nombre]" (nombre que viene de la base de datos).
4. **Cerrar sesión** (Configuración → Cerrar sesión).
5. **Login:** ingresar el mismo correo y contraseña → "Iniciar sesión".
6. **Comprobar de nuevo:** mismo Home con el nombre; eso confirma que Auth validó y Firestore devolvió el perfil.

Con eso se ve que **registro y login usan la base de datos** (Auth + Firestore).

### Qué mostrar en Firebase Console (prueba de que sí se guarda)

Abre [Firebase Console](https://console.firebase.google.com/) → proyecto **riskmobile-c59fc** y enseña:

| Dónde | Qué mostrar |
|-------|-------------|
| **Authentication** → pestaña **Users** | La lista de usuarios registrados (correos). Ahí se ve que el registro guardó en la nube. |
| **Firestore Database** → pestaña **Datos** | La colección **users**. Al abrirla, se ven documentos con el **uid** de cada usuario y los campos: `name`, `email`, `role`, `phone`, `createdAt`. Eso prueba que el perfil se guarda en la base de datos al registrarse. |

Así el profesor ve que **hay conexión real**: los datos no solo están en la app, sino en Firebase (Auth + Firestore).

### Resumen para entregar o presentar

- **Conexión:** Firebase (Auth + Firestore) configurado en el proyecto e inicializado en `main.dart`.
- **Registro:** crea usuario en Auth y documento en Firestore (`users`).
- **Login:** valida con Auth, lee perfil en Firestore, redirige por rol.
- **Prueba:** usuario en Authentication + documento en Firestore con nombre, email, rol.

---

## Resumen rápido

| Qué quieres hacer      | Comando / acción                                      |
|------------------------|--------------------------------------------------------|
| Ejecutar en Android    | `flutter run` (con emulador o celular conectado)      |
| Ejecutar en navegador  | `flutter run -d chrome`                               |
| Ver cambios sin cerrar sesión | En la terminal de `flutter run`: pulsar **`r`** (hot reload) |
| Reiniciar la app       | En la terminal: pulsar **`R`** (hot restart)           |
| Ver dispositivos       | `flutter devices`                                     |
| Instalar dependencias  | `flutter pub get`                                     |
| Probar registro        | Splash → Regístrate → llenar formulario → Crear cuenta |
| Probar login           | Cerrar sesión → Iniciar sesión con ese correo/contraseña |
| Probar recuperar clave | Login → ¿Olvidaste tu contraseña? → enviar correo     |
