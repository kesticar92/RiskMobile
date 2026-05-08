import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias locales (RF33, RF34) — biometría y notificaciones.
class UserPreferences {
  UserPreferences._(this._prefs);
  final SharedPreferences _prefs;

  static const String keyBiometricEnabled = 'pref_biometric_enabled';
  static const String keyNotificationsPush = 'pref_notifications_push';
  static const String keyNotificationsEmail = 'pref_notifications_email';

  static Future<UserPreferences> instance() async {
    final p = await SharedPreferences.getInstance();
    return UserPreferences._(p);
  }

  bool get biometricEnabled =>
      _prefs.getBool(keyBiometricEnabled) ?? false;

  Future<void> setBiometricEnabled(bool value) =>
      _prefs.setBool(keyBiometricEnabled, value);

  bool get notificationsPush =>
      _prefs.getBool(keyNotificationsPush) ?? true;

  Future<void> setNotificationsPush(bool value) =>
      _prefs.setBool(keyNotificationsPush, value);

  bool get notificationsEmail =>
      _prefs.getBool(keyNotificationsEmail) ?? false;

  Future<void> setNotificationsEmail(bool value) =>
      _prefs.setBool(keyNotificationsEmail, value);
}
