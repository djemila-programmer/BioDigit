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
  final bool _obscurePassword = true;
  bool _agreeTerms = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _farmNameController = TextEditingController();
  final String _biodigesterType = 'Small-scale (Home use)';
  String? _validationError;

  /// Validates registration input. Returns an error message, or null if valid.
  String? _validateInput() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final farmName = _farmNameController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || farmName.isEmpty) {
      return 'Veuillez remplir tous les champs obligatoires.';
    }
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Adresse email invalide.';
    }
    if (password.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères.';
    }
    final phoneRegex = RegExp(r'^\+?[0-9\s-]{6,20}$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Numéro de téléphone invalide.';
    }
    if (!_agreeTerms) {
      return 'Vous devez accepter les conditions d\'utilisation.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'BioDigit',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppTheme.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 24,
                    left: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            height: 36 / 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Join the smart biodigester network',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.sectionMargin),

            // Farmer Details Section
            _buildSectionHeader(Icons.person, 'Farmer Details'),
            const SizedBox(height: 16),
            _buildInputField(
              icon: Icons.person,
              label: 'Full Name',
              hint: 'Enter your full name',
              controller: _nameController,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    icon: Icons.call,
                    label: 'Phone Number',
                    hint: '+226...',
                    keyboard: TextInputType.phone,
                    controller: _phoneController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    icon: Icons.mail,
                    label: 'Email Address',
                    hint: 'name@biodigit.bf',
                    keyboard: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInputField(
              icon: Icons.lock,
              label: 'Password',
              hint: 'Min. 8 characters',
              obscure: _obscurePassword,
              controller: _passwordController,
            ),
            const SizedBox(height: 32),

            // Facility Information Section
            Divider(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            _buildSectionHeader(Icons.agriculture, 'Facility Information'),
            const SizedBox(height: 16),
            _buildInputField(
              icon: Icons.nature,
              label: 'Farm Name',
              hint: 'e.g. Ferme Plateau Central',
              controller: _farmNameController,
            ),
            const SizedBox(height: 12),
            _buildDropdownField(
              icon: Icons.sensors,
              label: 'Biodigester Type',
              hint: 'Select system capacity',
              items: [
                'Small-scale (Home use)',
                'Industrial (Commercial)',
                'Community (Shared)',
              ],
            ),
            const SizedBox(height: 32),

            // Terms Checkbox
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
                        text: 'I agree to the ',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.onSurfaceVariant,
                          height: 16 / 11,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: ' regarding my agricultural data.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Create Account Button
            Consumer<AuthProvider>(
              builder: (ctx, auth, __) {
                return Column(
                  children: [
                    if (_validationError != null || auth.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_validationError ?? auth.error!,
                            style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: auth.isLoading ? null : () async {
                          final validationError = _validateInput();
                          if (validationError != null) {
                            setState(() => _validationError = validationError);
                            return;
                          }
                          setState(() => _validationError = null);
                          final success = await auth.signUp(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                            fullName: _nameController.text.trim(),
                            phone: _phoneController.text.trim(),
                            farmName: _farmNameController.text.trim(),
                            biodigesterType: _biodigesterType,
                          );
                          if (success && ctx.mounted) {
                            Navigator.pushReplacementNamed(ctx, AppRoutes.mainDashboard);
                          }
                        },
                        icon: auth.isLoading
                            ? const SizedBox(height: 18, width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.trending_flat),
                        label: const Text('Create Account'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Login Link
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text.rich(
                  TextSpan(
                    text: 'Already using BioDigit? ',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Log in here',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 16),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String label,
    required String hint,
    TextInputType? keyboard,
    bool obscure = false,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.outline, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.outlineVariant, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.outlineVariant, width: 1.5),
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

  Widget _buildDropdownField({
    required IconData icon,
    required String label,
    required String hint,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.outlineVariant, width: 1.5),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppTheme.outline, size: 20),
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
