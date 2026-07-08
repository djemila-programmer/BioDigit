import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../routes.dart';
import '../services/providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedRole = 'user';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text,
      expectedRole: _selectedRole,
    );

    if (!success || !mounted) return;
    final role = auth.user?.role ?? 'user';
    Navigator.pushReplacementNamed(
      context,
      role == 'admin' ? AppRoutes.adminDashboard : AppRoutes.mainDashboard,
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
              AppTheme.primary.withValues(alpha: 0.20),
              cs.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerPadding, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bouton de retour
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: cs.onSurfaceVariant),
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.landing, (route) => false),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.eco, color: AppTheme.onPrimary, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BioDigit',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Plateforme de supervision des biodigesteurs',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Connexion sécurisée',
                          style: TextStyle(
                            fontSize: 24,
                            height: 30 / 24,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Accédez à votre tableau de bord, à vos alertes et à vos indicateurs en temps réel.',
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email requis';
                            if (!v.contains('@') || !v.contains('.')) return 'Email invalide';
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Adresse email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Mot de passe requis';
                            if (v.length < 6) return 'Min. 6 caractères';
                            return null;
                          },
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Se connecter en tant que',
                            prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'user', child: Text('Utilisateur')),
                            DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedRole = value);
                          },
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                            child: const Text('Mot de passe oublié ?'),
                          ),
                        ),
                        Consumer<AuthProvider>(
                          builder: (_, auth, __) {
                            if (auth.error == null) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorContainer.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.18)),
                                ),
                                child: Text(
                                  auth.error!,
                                  style: const TextStyle(color: AppTheme.error, fontSize: 13),
                                ),
                              ),
                            );
                          },
                        ),
                        Consumer<AuthProvider>(
                          builder: (ctx, auth, __) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: auth.isLoading ? null : _submit,
                                icon: auth.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.arrow_forward),
                                label: Text(auth.isLoading ? 'Connexion...' : 'Se connecter'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Divider(color: cs.outlineVariant)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'ou continuer avec',
                                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant.withValues(alpha: 0.9), letterSpacing: 0.5),
                              ),
                            ),
                            Expanded(child: Divider(color: cs.outlineVariant)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Google Sign-In only on mobile platforms
                        if (Platform.isAndroid || Platform.isIOS)
                          Consumer<AuthProvider>(
                            builder: (ctx, auth, __) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: auth.isLoading
                                          ? null
                                          : () async {
                                              final success = await auth.signInWithGoogle(expectedRole: _selectedRole);
                                              if (!success || !ctx.mounted) return;
                                              final role = auth.user?.role ?? 'user';
                                              Navigator.pushReplacementNamed(
                                                ctx,
                                                role == 'admin' ? AppRoutes.adminDashboard : AppRoutes.mainDashboard,
                                              );
                                            },
                                      icon: const Icon(Icons.g_mobiledata, size: 20),
                                      label: const Text('Google'),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                            child: Text.rich(
                              TextSpan(
                                text: "Pas encore de compte ? ",
                                style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                                children: const [
                                  TextSpan(
                                    text: 'Créer un compte',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
