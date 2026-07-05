import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../services/providers.dart';
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _hasSentResetEmail = false;
  String? _submittedEmail;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Email requis.';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(v)) return 'Email invalide.';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();

    await auth.sendPasswordReset(email);

    if (!mounted) return;

    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _hasSentResetEmail = true;
      _submittedEmail = email;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Email de réinitialisation envoyé. Vérifiez votre boîte de réception.',
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _goBackToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppTheme.primary.withValues(alpha: 0.18),
              cs.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.containerPadding,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Consumer<AuthProvider>(
                    builder: (ctx, auth, _) {
                      final isLoading = auth.isLoading;
                      final error = auth.error;

                      return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.lock_reset,
                                    color: AppTheme.primary,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mot de passe oublié',
                                        style: TextStyle(
                                          fontSize: 24,
                                          height: 30 / 24,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Recevez un lien sécurisé pour réinitialiser votre accès.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: cs.onSurfaceVariant,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.primary.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: AppTheme.primary,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Comment ça marche',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '1. Entrez votre adresse email.\n2. Ouvrez le message de réinitialisation.\n3. Créez un nouveau mot de passe sécurisé.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: cs.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.email],
                              validator: (value) =>
                                  value == null ? 'Email requis.' : _validateEmail(value),
                              decoration: const InputDecoration(
                                labelText: 'Adresse email',
                                hintText: 'nom@domaine.com',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              onFieldSubmitted: (_) => _submit(),
                            ),

                            if (error != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorContainer.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.error.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: Text(
                                  error,
                                  style: const TextStyle(
                                    color: AppTheme.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],

                            if (_hasSentResetEmail) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primary.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.mark_email_read_outlined,
                                          color: AppTheme.primary,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Email envoyé',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Un lien sécurisé a été envoyé à ${_submittedEmail ?? 'votre adresse email'}. Pensez à vérifier vos spams si besoin.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: cs.onSurfaceVariant,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isLoading ? null : _submit,
                                icon: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.send_outlined),
                                label: Text(
                                  isLoading ? 'Envoi en cours...' : 'Envoyer le lien',
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: isLoading ? null : _goBackToLogin,
                                child: const Text('Retour à la connexion'),
                              ),
                            ),

                            if (_hasSentResetEmail) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: isLoading ? null : _submit,
                                  child: const Text('Renvoyer le lien'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
