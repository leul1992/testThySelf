import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_lock/pattern_lock.dart';
import 'package:test_thy_self/core/services/auth_service.dart';
import 'package:test_thy_self/data/repositories/storage_service.dart';
import 'package:vibration/vibration.dart';
import 'package:local_auth/local_auth.dart';

class PatternLockScreen extends StatefulWidget {
  final bool isSettingUp;
  final Future<bool> Function(String)? onConfirmed;

  const PatternLockScreen({
    super.key,
    this.isSettingUp = false,
    this.onConfirmed,
  });

  @override
  State<PatternLockScreen> createState() => _PatternLockScreenState();
}

class _PatternLockScreenState extends State<PatternLockScreen> with SingleTickerProviderStateMixin {
  String? _firstPattern;
  String? _error;
  bool _isBiometricAvailable = false;
  bool _isAuthenticating = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    try {
      final isAvailable = await _localAuth.isDeviceSupported() &&
          await _localAuth.canCheckBiometrics &&
          StorageService.useBiometrics;
      if (mounted) {
        setState(() => _isBiometricAvailable = isAvailable);
      }
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
    }
  }

  Future<bool> _authenticateWithBiometrics() async {
    if (_isAuthenticating) return false;
    setState(() => _isAuthenticating = true);
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      if (authenticated && mounted) {
        await Vibration.vibrate(duration: 100);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Biometric auth error: $e');
      return false;
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

 void _onPatternEnter(List<int> pattern) async {
  if (_isAuthenticating) return;

  await Vibration.vibrate(duration: 50);
  final patternStr = pattern.join();

  if (widget.isSettingUp) {
    if (_firstPattern == null) {
      if (pattern.length < 4) {
        setState(() {
          _error = 'Pattern must include at least 4 dots';
          _animationController.forward(from: 0);
        });
        await Future.delayed(const Duration(milliseconds: 300));
        return;
      }
      setState(() {
        _firstPattern = patternStr;
        _error = null;
      });
    } else if (_firstPattern == patternStr) {
      await Vibration.vibrate(pattern: [0, 100, 100, 100]);
      Navigator.of(context).pop(patternStr); // Always pop when patterns match during setup
    } else {
      setState(() {
        _error = 'Patterns do not match. Please try again.';
        _animationController.forward(from: 0);
      });
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _firstPattern = null);
    }
  } else {
    if (widget.onConfirmed != null) {
      final success = await widget.onConfirmed!(patternStr);
      if (success && mounted) {
        await Vibration.vibrate(pattern: [0, 100, 100, 100]);
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _error = 'Incorrect pattern. Try again.';
          _animationController.forward(from: 0);
        });
      }
    } else {
      debugPrint('onConfirmed is not provided for authentication');
    }
  }
}
  void _resetPattern() {
    setState(() {
      _firstPattern = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop && widget.isSettingUp) {
          await AuthService.clearAuthData();
          await StorageService.setAuthEnabled(false);
          await StorageService.setUseBiometrics(false);
          if (mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: Text(
                        widget.isSettingUp
                            ? _firstPattern == null
                                ? 'Draw New Pattern'
                                : 'Confirm Your Pattern'
                            : 'Unlock App',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                    child: Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red[400],
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 320,
                      height: 320,
                      child: PatternLock(
                        selectedColor: Colors.blue[400]!,
                        notSelectedColor: Colors.white.withOpacity(0.4),
                        pointRadius: 12,
                        showInput: true,
                        onInputComplete: _onPatternEnter,
                        dimension: 3,
                        fillPoints: true,
                      ),
                    ),
                  ),
                ),
                if (!widget.isSettingUp && _isBiometricAvailable) ...[
                  const SizedBox(height: 24),
                  _isAuthenticating
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.fingerprint,
                            size: 56,
                            color: Colors.blue[400],
                          ),
                          onPressed: () async {
                            final authenticated = await _authenticateWithBiometrics();
                            if (authenticated && mounted) {
                              Navigator.of(context).pop(true);
                            }
                          },
                        ),
                  const SizedBox(height: 8),
                  Text(
                    'Use Fingerprint or Face ID',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (widget.isSettingUp) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_firstPattern != null)
                        TextButton(
                          onPressed: _resetPattern,
                          child: const Text(
                            'Reset Pattern',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (_firstPattern != null) const SizedBox(width: 16),
                      TextButton(
                        onPressed: () async {
                          await AuthService.clearAuthData();
                          await StorageService.setAuthEnabled(false);
                          await StorageService.setUseBiometrics(false);
                          if (mounted) Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}