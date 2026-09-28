import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the user wants biometric (Face ID / fingerprint) app unlock.
class AppBiometricUnlockController extends ChangeNotifier {
  static const _prefKey = 'app_biometric_unlock_enabled';

  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _enabled = false;
  bool _authenticatorAvailable = false;

  bool get enabled => _enabled;

  bool get authenticatorAvailable => _authenticatorAvailable;

  LocalAuthentication get localAuth => _localAuth;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefKey) ?? false;
    await refreshAuthenticatorAvailability();
    notifyListeners();
  }

  Future<void> refreshAuthenticatorAvailability() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      final types = await _localAuth.getAvailableBiometrics();
      _authenticatorAvailable = supported && (types.isNotEmpty || canCheck);
    } catch (_) {
      _authenticatorAvailable = false;
    }
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }
}
