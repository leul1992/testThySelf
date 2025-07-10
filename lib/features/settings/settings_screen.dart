import 'package:flutter/material.dart';
import 'package:test_thy_self/core/services/auth_service.dart';
import 'package:test_thy_self/data/repositories/service_locator.dart';
import 'package:test_thy_self/data/repositories/storage_service.dart';
import 'package:test_thy_self/features/auth/pattern_lock_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _authEnabled = false;
  bool _biometricAvailable = false;
  bool _useBiometrics = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final authEnabled = StorageService.authEnabled;
      final hasPattern = await AuthService.hasPattern();
      final biometricAvailable = await ServiceLocator.instance.authService.isBiometricAvailable();
      
      setState(() {
        _authEnabled = authEnabled && hasPattern;
        _biometricAvailable = biometricAvailable;
        _useBiometrics = authEnabled && biometricAvailable && StorageService.useBiometrics;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAuth(bool value) async {
    if (_isLoading || value == _authEnabled) return;

    setState(() => _isLoading = true);
    try {
      if (value) {
        final pattern = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => const PatternLockScreen(isSettingUp: true),
          ),
        );

        if (pattern != null && pattern.isNotEmpty) {
          final success = await AuthService.savePattern(pattern);
          if (success && mounted) {
            await StorageService.setAuthEnabled(true);
            await StorageService.setUseBiometrics(_biometricAvailable);
            setState(() {
              _authEnabled = true;
              _useBiometrics = _biometricAvailable;
            });
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to save pattern')),
            );
          }
        }
      } else {
        await AuthService.clearAuthData();
        await StorageService.setAuthEnabled(false);
        await StorageService.setUseBiometrics(false);
        if (mounted) {
          setState(() {
            _authEnabled = false;
            _useBiometrics = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error toggling auth: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (_isLoading || !_authEnabled) return;
    
    setState(() => _isLoading = true);
    try {
      await StorageService.setUseBiometrics(value);
      if (mounted) {
        setState(() => _useBiometrics = value);
      }
    } catch (e) {
      debugPrint('Error toggling biometrics: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update biometrics setting')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changePattern() async {
    setState(() => _isLoading = true);
    try {
      final pattern = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => const PatternLockScreen(isSettingUp: true),
        ),
      );

      if (pattern != null && pattern.isNotEmpty) {
        final success = await AuthService.savePattern(pattern);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pattern updated successfully')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update pattern')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error changing pattern: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAuthSection(),
                  if (_authEnabled) _buildSecurityOptions(),
                ],
              ),
            ),
    );
  }

  Widget _buildAuthSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Enable App Lock', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Secure your app with a pattern lock'),
              value: _authEnabled,
              onChanged: _toggleAuth,
              activeColor: Colors.blue,
            ),
            if (_authEnabled && _biometricAvailable)
              SwitchListTile(
                title: const Text('Use Biometric Authentication'),
                subtitle: const Text('Enable fingerprint or face recognition'),
                value: _useBiometrics,
                onChanged: _toggleBiometrics,
                activeColor: Colors.blue,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOptions() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          ListTile(
            title: const Text('Change Pattern Lock'),
            leading: const Icon(Icons.lock_outline, color: Colors.blue),
            trailing: const Icon(Icons.chevron_right, color: Colors.blue),
            onTap: _changePattern,
          ),
        ],
      ),
    );
  }
}