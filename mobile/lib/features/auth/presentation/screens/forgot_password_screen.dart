import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:unify/core/services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _codeSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _hasValidEmail {
    final email = _emailController.text.trim();
    return email.contains('@') && email.contains('.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _apiErrorMessage(DioException error, String fallback) {
    final responseData = error.response?.data;
    if (responseData is Map) {
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return fallback;
  }

  Future<void> _sendResetCode() async {
    if (!_hasValidEmail) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _apiService.requestPasswordReset(
        email: _emailController.text,
      );
      if (!mounted) return;
      setState(() => _codeSent = true);
      _showMessage(response.data['message'] as String);
    } on DioException catch (error) {
      _showMessage(_apiErrorMessage(
        error,
        'Unable to send code. Please check your connection and try again.',
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    if (_codeController.text.trim().length != 6) {
      _showMessage('Enter the six-digit code from your email.');
      return;
    }
    if (password.length < 8) {
      _showMessage('Your new password must be at least 8 characters.');
      return;
    }
    if (password != _confirmPasswordController.text) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _apiService.resetPassword(
        email: _emailController.text,
        code: _codeController.text,
        password: password,
      );
      if (!mounted) return;
      _showMessage(response.data['message'] as String);
      context.go('/login');
    } on DioException catch (error) {
      _showMessage(_apiErrorMessage(
        error,
        'Unable to reset password. Please check your connection and try again.',
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Reset your password',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                _codeSent
                    ? 'Enter the six-digit code sent to your email, then choose a new password.'
                    : 'Enter your account email and we will send a six-digit reset code.',
                style: const TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                enabled: !_codeSent && !_isLoading,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  hintText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              if (_codeSent) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  decoration: const InputDecoration(
                    hintText: 'Six-digit reset code',
                    prefixIcon: Icon(Icons.pin_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(
                    hintText: 'New password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => _isLoading ? null : _resetPassword(),
                  decoration: InputDecoration(
                    hintText: 'Confirm new password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _codeSent
                          ? _resetPassword
                          : _sendResetCode,
                  child: Text(_isLoading
                      ? 'Please wait...'
                      : _codeSent
                          ? 'Reset Password'
                          : 'Send Reset Code'),
                ),
              ),
              if (_codeSent)
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _sendResetCode,
                    child: const Text('Send a new code'),
                  ),
                ),
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : () => context.go('/login'),
                  child: const Text('Back to Sign In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
