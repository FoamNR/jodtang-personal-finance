import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  static const _pinKey = 'app_pin_hash';
  static const _pinEnabledKey = 'pin_enabled';
  static const _biometricEnabledKey = 'biometric_enabled';

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<bool> isPinEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _pinEnabledKey);
      final hash = await _secureStorage.read(key: _pinKey);
      return enabled == 'true' && hash != null && hash.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setPin(String pin) async {
    try {
      final hashed = _hashPin(pin);
      await _secureStorage.write(key: _pinKey, value: hashed);
      await _secureStorage.write(key: _pinEnabledKey, value: 'true');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> verifyPin(String enteredPin) async {
    try {
      final savedHash = await _secureStorage.read(key: _pinKey);
      if (savedHash == null) return false;
      return savedHash == _hashPin(enteredPin);
    } catch (_) {
      return false;
    }
  }

  Future<void> disablePin() async {
    try {
      await _secureStorage.delete(key: _pinKey);
      await _secureStorage.write(key: _pinEnabledKey, value: 'false');
      await _secureStorage.write(key: _biometricEnabledKey, value: 'false');
    } catch (_) {}
  }

  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(key: _biometricEnabledKey, value: enabled.toString());
    } catch (_) {}
  }

  Future<bool> canCheckBiometrics() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateBiometrics({String reason = 'กรุณายืนยันตัวตนเพื่อเข้าใช้งาน จดตัง'}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
