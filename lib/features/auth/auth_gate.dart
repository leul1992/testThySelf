import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_thy_self/core/services/auth_service.dart';
import 'package:test_thy_self/data/repositories/service_locator.dart';
import 'package:test_thy_self/data/repositories/storage_service.dart';
import 'package:test_thy_self/features/auth/pattern_lock_screen.dart';

class AuthGate extends StatefulWidget {
  final Widget child;
  final Duration authTimeout;

  const AuthGate({
    super.key,
    required this.child,
    this.authTimeout = const Duration(minutes: 5),
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  bool _useBiometrics = false;
  bool _hasPattern = false;
  bool _isLocked = false;
  Duration _remainingLockTime = Duration.zero;
  Timer? _lockTimer;
  Timer? _authTimeoutTimer;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    _authTimeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeAuth() async {
    await StorageService.ensureInitialized();

    if (!StorageService.authEnabled) {
      _grantAccess();
      return;
    }

    final authService = ServiceLocator.instance.authService;
    _hasPattern = await AuthService.hasPattern();
    _useBiometrics = await authService.isBiometricAvailable() &&
        _hasPattern &&
        StorageService.useBiometrics;

    _isLocked = await authService.isLockedOut();
    if (_isLocked) {
      _startLockTimer();
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final shouldAuth = await authService.shouldReauthenticate();
    if (mounted) setState(() => _isLoading = false);

    if (shouldAuth) {
      await _authenticate();
    } else {
      _grantAccess();
    }
  }

  Future<void> _authenticate() async {
    if (_useBiometrics) {
      final success = await ServiceLocator.instance.authService.authenticateWithBiometrics();
      if (success) {
        _grantAccess();
        return;
      }
    }

    final result = await Navigator.of(context).push<bool>(
  MaterialPageRoute(
    builder: (context) => PatternLockScreen(
      onConfirmed: (pattern) async => await ServiceLocator.instance.authService.authenticateWithPattern(pattern),
    ),
    fullscreenDialog: true,
  ),
);

    if (result == true) {
      _grantAccess();
    } else {
      SystemNavigator.pop();
    }
  }

  void _startLockTimer() {
    _remainingLockTime = ServiceLocator.instance.authService.getRemainingLockTime();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingLockTime.inSeconds > 0) {
        if (mounted) {
          setState(() => _remainingLockTime -= const Duration(seconds: 1));
        }
      } else {
        _lockTimer?.cancel();
        if (mounted) {
          setState(() {
            _isLocked = false;
            _initializeAuth();
          });
        }
      }
    });
  }

  void _grantAccess() {
    if (mounted) {
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
    }
  }

  Widget _buildLockScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_clock, size: 64, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'Too many attempts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Try again in ${_remainingLockTime.inMinutes}m ${_remainingLockTime.inSeconds.remainder(60)}s',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_isLocked) {
      return _buildLockScreen();
    }

    if (!_isAuthenticated) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return widget.child;
  }
}