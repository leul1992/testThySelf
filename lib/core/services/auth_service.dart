import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:test_thy_self/data/repositories/storage_service.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const int _maxAttempts = 5;
  static const Duration _lockDuration = Duration(minutes: 2);
  static const Duration _authTimeout = Duration(minutes: 1);

  Future<bool> authenticateWithPattern(String pattern) async {
    if (await isLockedOut()) {
      return false;
    }

    final storedPattern = StorageService.settingsBox.get('pattern');
    print('Stored pattern: $storedPattern'); // Add this
    print('Input pattern: $pattern');
    if (storedPattern == null || storedPattern.isEmpty) return false;

    final attempts = StorageService.settingsBox.get('attempts', defaultValue: 0);
    final now = DateTime.now();

    if (storedPattern == pattern) {
      await _resetSecurityState();
      return true;
    }

    await _handleFailedAttempt(now, attempts);
    return false;
  }

  Future<void> _resetSecurityState() async {
    await StorageService.settingsBox.put('attempts', 0);
    await StorageService.settingsBox.put('lastAuthTime', DateTime.now().toIso8601String());
    await StorageService.settingsBox.delete('lastAttempt');
    await StorageService.settingsBox.delete('lockedUntil');
    await StorageService.settingsBox.flush();
  }

  Future<void> _handleFailedAttempt(DateTime now, int attempts) async {
    final newAttempts = attempts + 1;
    await StorageService.settingsBox.put('attempts', newAttempts);
    await StorageService.settingsBox.put('lastAttempt', now.toIso8601String());

    if (newAttempts >= _maxAttempts) {
      final lockUntil = now.add(_lockDuration);
      await StorageService.settingsBox.put('lockedUntil', lockUntil.toIso8601String());
    }
    await StorageService.settingsBox.flush();
  }

  static Future<void> clearAuthData() async {
    await StorageService.settingsBox.delete('pattern');
    await StorageService.settingsBox.delete('hasPattern');
    await StorageService.settingsBox.delete('attempts');
    await StorageService.settingsBox.delete('lastAttempt');
    await StorageService.settingsBox.delete('lockedUntil');
    await StorageService.settingsBox.delete('useBiometrics');
    await StorageService.settingsBox.delete('lastAuthTime');
    await StorageService.settingsBox.flush();
  }

  Future<bool> isLockedOut() async {
    final lockedUntil = StorageService.settingsBox.get('lockedUntil');
    if (lockedUntil == null) return false;

    final lockTime = DateTime.parse(lockedUntil);
    return DateTime.now().isBefore(lockTime);
  }

  Duration getRemainingLockTime() {
    final lockedUntil = StorageService.settingsBox.get('lockedUntil');
    if (lockedUntil == null) return Duration.zero;

    final lockTime = DateTime.parse(lockedUntil);
    final remaining = lockTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<bool> shouldReauthenticate() async {
    if (!StorageService.authEnabled) return false;
    
    final lastAuthTime = StorageService.settingsBox.get('lastAuthTime');
    if (lastAuthTime == null) return true;
    
    final lastAuth = DateTime.parse(lastAuthTime);
    return DateTime.now().difference(lastAuth) > _authTimeout;
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      if (!await isBiometricAvailable() || !StorageService.useBiometrics) {
  return false;
}

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your progress',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Authentication required',
            cancelButton: 'Cancel',
            biometricHint: 'Verify your identity',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Please set up your Face ID/Touch ID',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );

      if (authenticated) {
        await _resetSecurityState();
      }
      
      return authenticated;
    } on PlatformException catch (e) {
      print('Biometric auth error: ${e.message}');
      return false;
    }
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;

      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  static Future<bool> savePattern(String pattern) async {
    try {
      if (pattern.isEmpty || pattern.length < 4) {
        throw ArgumentError('Pattern must be at least 4 points');
      }

      await StorageService.settingsBox.put('pattern', pattern);
      await StorageService.settingsBox.put('hasPattern', true);
      await StorageService.settingsBox.put('lastAuthTime', DateTime.now().toIso8601String());
      await StorageService.settingsBox.flush();
      print('Pattern saved: $pattern');
      return true;
    } catch (e) {
      print('Error saving pattern: $e');
      return false;
    }
  }

  static Future<bool> hasPattern() async {
    try {
      final hasPattern = StorageService.settingsBox.get('hasPattern', defaultValue: false) as bool;
      final pattern = StorageService.settingsBox.get('pattern', defaultValue: '') as String;
      return hasPattern && pattern.isNotEmpty;
    } catch (e) {
      print('Pattern check error: $e');
      return false;
    }
  }
}
