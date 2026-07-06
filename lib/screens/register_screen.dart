import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../routes.dart';
import '../services/providers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _agreeTerms = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _farmNameController = TextEditingController();
  final String _biodigesterType = 'Small-scale (Home use)';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _farmNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) return;

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions avant de continuer.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      farmName: _farmNameController.text.trim(),
      biodigesterType: _biodigesterType,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé avec succès. Connectez-vous.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
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
                constraints: const BoxConstraints(maxWidth: 620),
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
                                  const Text(
                                    'BioDigit',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Créez votre espace de supervision en quelques minutes.',
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
                          'Créer un compte',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Configurez votre ferme, vos accès et vos notifications dès maintenant.',
                          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant, height: 1.4),
                        ),
                        const SizedBox(height: 24),
                        _buildInputField(context,
                          icon: Icons.person,
                          label: 'Nom complet',
                          hint: 'Entrez votre nom complet',
                          controller: _nameController,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(context,
                                icon: Icons.call,
                                label: 'Téléphone',
                                hint: '+226...',
                                keyboard: TextInputType.phone,
                                controller: _phoneController,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Téléphone requis' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInputField(context,
                                icon: Icons.mail,
                                label: 'Adresse email',
                                hint: 'nom@biodigit.bf',
                                keyboard: TextInputType.emailAddress,
                                controller: _emailController,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Email requis';
                                  if (!v.contains('@') || !v.contains('.')) return 'Email invalide';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(context,
                          icon: Icons.lock,
                          label: 'Mot de passe',
                          hint: 'Min. 8 car. : majuscule, minuscule, chiffre, special',
                          obscure: _obscurePassword,
                          controller: _passwordController,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Mot de passe requis';
                            if (v.length < 8) return 'Min. 8 caracteres';
                            if (!v.contains(RegExp('[A-Z]'))) return 'Au moins 1 majuscule requise';
                            if (!v.contains(RegExp('[a-z]'))) return 'Au moins 1 minuscule requise';
                            if (!v.contains(RegExp('[0-9]'))) return 'Au moins 1 chiffre requis';
                            if (!v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return 'Au moins 1 caractere special requis (!@#...)';
                            return null;
                          },
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(context,
                          icon: Icons.nature,
                          label: 'Nom de la ferme',
                          hint: 'e.g. Ferme Plateau Central',
                          controller: _farmNameController,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom de ferme requis' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(context,
                          icon: Icons.sensors,
                          label: 'Type de biodigesteur',
                          hint: 'Sélectionnez une capacité',
                          items: const [
                            'Small-scale (Home use)',
                            'Industrial (Commercial)',
                            'Community (Shared)',
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreeTerms,
                              onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                              activeColor: AppTheme.primary,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                                child: Text.rich(
                                  TextSpan(
                                    text: 'J\u2019accepte les ',
                                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.4),
                                    children: [
                                      TextSpan(
                                        text: 'conditions d’utilisation',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: ' et la '),
                                      TextSpan(
                                        text: 'politique de confidentialité',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Consumer<AuthProvider>(
                          builder: (ctx, auth, __) {
                            return Column(
                              children: [
                                if (auth.error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.errorContainer.withValues(alpha: 0.55),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.18)),
                                      ),
                                      child: Text(auth.error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                                    ),
                                  ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                                onPressed: auth.isLoading ? null : _submit,
                                    icon: auth.isLoading
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : const Icon(Icons.trending_flat),
                                    label: Text(auth.isLoading ? 'Création...' : 'Créer le compte'),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text.rich(
                              TextSpan(
                                text: 'Déjà un compte BioDigit ? ',
                                style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                                children: const [
                                  TextSpan(
                                    text: 'Se connecter',
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

  Widget _buildInputField(BuildContext context, {
    required IconData icon,
    required String label,
    required String hint,
    TextInputType? keyboard,
    bool obscure = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: cs.outline, size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: cs.outlineVariant, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: cs.outlineVariant, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(BuildContext context, {
    required IconData icon,
    required String label,
    required String hint,
    required List<String> items,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.outlineVariant, width: 1.5),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: cs.outline, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }
}
