import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../theme/flex_theme.dart';
import '../../utils/password_validator.dart';

/// Opens the "mot de passe oublié" flow.
///
/// Returns `true` when the password was successfully reset.
Future<bool?> showForgotPasswordDialog(
  BuildContext context, {
  String? initialPhone,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ForgotPasswordDialog(initialPhone: initialPhone),
  );
}

class ForgotPasswordDialog extends StatefulWidget {
  final String? initialPhone;

  const ForgotPasswordDialog({super.key, this.initialPhone});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  late final TextEditingController _phoneController;
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _sending = false;
  bool _resetting = false;
  bool _codeSent = false;
  bool _obscure = true;
  String? _error;
  String? _info;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 8) {
      setState(() => _error = 'Entrez un numéro de téléphone valide.');
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
      _info = null;
    });

    try {
      await AuthService().sendPasswordResetOtp(phone);
      if (!mounted) return;
      setState(() {
        _sending = false;
        _codeSent = true;
        _info = 'Code envoyé par SMS. Il expire dans 10 minutes.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = ApiClient.errorMessage(
          e,
          fallback: "Impossible d'envoyer le code.",
        );
      });
    }
  }

  Future<void> _resetPassword() async {
    final phone = _phoneController.text.trim();
    final code = _otpController.text.trim();
    final password = _passwordController.text;

    if (phone.length < 8) {
      setState(() => _error = 'Entrez un numéro de téléphone valide.');
      return;
    }
    if (code.length != 6) {
      setState(() => _error = 'Entrez le code à 6 chiffres.');
      return;
    }
    final passwordError = strongPasswordError(password);
    if (passwordError != null) {
      setState(() => _error = 'Mot de passe : $passwordError');
      return;
    }

    setState(() {
      _resetting = true;
      _error = null;
      _info = null;
    });

    try {
      await AuthService().resetPassword(
        telephone: phone,
        otpCode: code,
        newPassword: password,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resetting = false;
        _error = ApiClient.errorMessage(
          e,
          fallback: 'Impossible de réinitialiser le mot de passe.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? FlexColors.neutral0 : FlexColors.neutral800;

    return AlertDialog(
      title: const Text('Mot de passe oublié'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Recevez un code par SMS, puis choisissez un nouveau mot de passe.',
                style: TextStyle(fontSize: 13, color: FlexColors.neutral500),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _sending ? null : _sendCode,
                icon: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sms_outlined, size: 18),
                label: Text(_codeSent ? 'Renvoyer le code' : 'Envoyer le code'),
              ),
              if (_codeSent) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Code reçu par SMS',
                    prefixIcon: Icon(Icons.pin_outlined),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    helperText:
                        '8+ caractères, majuscule, minuscule, chiffre, spécial',
                    helperMaxLines: 2,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
              ],
              if (_info != null) ...[
                const SizedBox(height: 12),
                Text(
                  _info!,
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: FlexColors.error, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: (_sending || _resetting)
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        if (_codeSent)
          ElevatedButton(
            onPressed: _resetting ? null : _resetPassword,
            child: _resetting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Réinitialiser'),
          ),
      ],
    );
  }
}
