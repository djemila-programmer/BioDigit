import 'package:flutter/material.dart';

/// Simple localization system for BioDigit (French + English only).
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('fr'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('en'),
  ];

  // ─── French translations ──────────────────────────────────────────────
  static const Map<String, String> _fr = {
    // General
    'app_name': 'BioDigit',
    'loading': 'Chargement...',
    'error': 'Erreur',
    'success': 'Succès',
    'cancel': 'Annuler',
    'confirm': 'Confirmer',
    'save': 'Enregistrer',
    'delete': 'Supprimer',
    'edit': 'Modifier',
    'close': 'Fermer',
    'back': 'Retour',
    'next': 'Suivant',
    'search': 'Rechercher',
    'no_data': 'Aucune donnée disponible',
    'retry': 'Réessayer',
    'yes': 'Oui',
    'no': 'Non',
    'ok': 'OK',

    // Auth
    'login': 'Connexion',
    'login_title': 'Connexion sécurisée',
    'login_subtitle': 'Accédez à votre tableau de bord, à vos alertes et à vos indicateurs en temps réel.',
    'email': 'Adresse email',
    'email_required': 'Email requis',
    'email_invalid': 'Email invalide',
    'password': 'Mot de passe',
    'password_required': 'Mot de passe requis',
    'password_min': 'Min. 6 caractères',
    'forgot_password': 'Mot de passe oublié ?',
    'login_as': 'Se connecter en tant que',
    'user': 'Utilisateur',
    'admin': 'Administrateur',
    'sign_in': 'Se connecter',
    'signing_in': 'Connexion...',
    'or_continue': 'ou continuer avec',
    'no_account': 'Pas encore de compte ?',
    'create_account': 'Créer un compte',
    'sign_out': 'Déconnexion',

    // Register
    'register_title': 'Créer un compte',
    'register_subtitle': 'Configurez votre ferme, vos accès et vos notifications dès maintenant.',
    'full_name': 'Nom complet',
    'full_name_required': 'Nom requis',
    'phone': 'Téléphone',
    'phone_required': 'Téléphone requis',
    'farm_name': 'Nom de la ferme',
    'farm_name_required': 'Nom de ferme requis',
    'farm_name_hint': 'e.g. Ferme Plateau Central',
    'biodigester_type': 'Type de biodigesteur',
    'select_capacity': 'Sélectionnez une capacité',
    'accept_terms': "J'accepte les ",
    'terms_of_use': "conditions d'utilisation",
    'and': ' et la ',
    'privacy_policy': 'politique de confidentialité',
    'terms_required': 'Veuillez accepter les conditions avant de continuer.',
    'creating_account': 'Création...',
    'create_account_btn': 'Créer le compte',
    'already_account': 'Déjà un compte BioDigit ?',
    'sign_in_link': 'Se connecter',

    // Navigation
    'home': 'Accueil',
    'live': 'En direct',
    'alerts': 'Alertes',
    'history': 'Historique',
    'profile': 'Profil',

    // Dashboard
    'dashboard': 'Tableau de bord',
    'production_today': "Production aujourd'hui",
    'biogas_produced': 'Biogaz produit',
    'efficiency': 'Efficacité',
    'active_alerts': 'Alertes actives',
    'system_health': 'Santé du système',
    'healthy': 'Sain',
    'warning': 'Attention',
    'critical': 'Critique',
    'sensor_status': 'État des capteurs',
    'online': 'En ligne',
    'offline': 'Hors ligne',
    'temperature': 'Température',
    'pressure': 'Pression',
    'methane': 'Méthane',
    'slurry_level': 'Niveau de bouillie',

    // Settings
    'settings': 'Paramètres',
    'account': 'Compte',
    'security': 'Sécurité',
    'security_subtitle': 'Mot de passe, session et protection',
    'esp32_connection': 'Connexion ESP32',
    'esp32_connected': 'Connecté · 192.168.1.100',
    'notifications': 'Notifications',
    'notifications_subtitle': 'Alertes et push settings',
    'preferences': 'Préférences',
    'language': 'Langue',
    'dark_mode': 'Dark Mode',
    'support': 'Support',
    'help_center': 'Help Center',
    'help_subtitle': 'FAQs & guides',
    'about': 'About',
    'privacy': 'Privacy Policy',
    'privacy_subtitle': 'Data & permissions',

    // Alerts
    'alert_management': 'Gestion des alertes',
    'no_alerts': 'Aucune alerte active',
    'no_alerts_filter': 'No active alerts for this filter.',
    'acknowledge': 'Acquitter',
    'resolve': 'Résoudre',

    // Farm
    'farm_management': 'Gestion de la ferme',
    'my_farms': 'Mes fermes',
    'add_farm': 'Ajouter une ferme',

    // Reports
    'reports': 'Rapports',
    'export_pdf': 'Exporter PDF',
    'export_excel': 'Exporter Excel',

    // Common
    'version': 'Version',
  };

  // ─── English translations ─────────────────────────────────────────────
  static const Map<String, String> _en = {
    // General
    'app_name': 'BioDigit',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'close': 'Close',
    'back': 'Back',
    'next': 'Next',
    'search': 'Search',
    'no_data': 'No data available',
    'retry': 'Retry',
    'yes': 'Yes',
    'no': 'No',
    'ok': 'OK',

    // Auth
    'login': 'Login',
    'login_title': 'Secure Login',
    'login_subtitle': 'Access your dashboard, alerts and real-time indicators.',
    'email': 'Email address',
    'email_required': 'Email required',
    'email_invalid': 'Invalid email',
    'password': 'Password',
    'password_required': 'Password required',
    'password_min': 'Min. 6 characters',
    'forgot_password': 'Forgot password?',
    'login_as': 'Login as',
    'user': 'User',
    'admin': 'Administrator',
    'sign_in': 'Sign in',
    'signing_in': 'Signing in...',
    'or_continue': 'or continue with',
    'no_account': "Don't have an account?",
    'create_account': 'Create account',
    'sign_out': 'Sign out',

    // Register
    'register_title': 'Create an account',
    'register_subtitle': 'Set up your farm, access and notifications in minutes.',
    'full_name': 'Full name',
    'full_name_required': 'Name required',
    'phone': 'Phone',
    'phone_required': 'Phone required',
    'farm_name': 'Farm name',
    'farm_name_required': 'Farm name required',
    'farm_name_hint': 'e.g. Plateau Central Farm',
    'biodigester_type': 'Biodigester type',
    'select_capacity': 'Select a capacity',
    'accept_terms': 'I accept the ',
    'terms_of_use': 'terms of use',
    'and': ' and the ',
    'privacy_policy': 'privacy policy',
    'terms_required': 'Please accept the terms before continuing.',
    'creating_account': 'Creating...',
    'create_account_btn': 'Create account',
    'already_account': 'Already have a BioDigit account?',
    'sign_in_link': 'Sign in',

    // Navigation
    'home': 'Home',
    'live': 'Live',
    'alerts': 'Alerts',
    'history': 'History',
    'profile': 'Profile',

    // Dashboard
    'dashboard': 'Dashboard',
    'production_today': 'Production today',
    'biogas_produced': 'Biogas produced',
    'efficiency': 'Efficiency',
    'active_alerts': 'Active alerts',
    'system_health': 'System health',
    'healthy': 'Healthy',
    'warning': 'Warning',
    'critical': 'Critical',
    'sensor_status': 'Sensor status',
    'online': 'Online',
    'offline': 'Offline',
    'temperature': 'Temperature',
    'pressure': 'Pressure',
    'methane': 'Methane',
    'slurry_level': 'Slurry level',

    // Settings
    'settings': 'Settings',
    'account': 'Account',
    'security': 'Security',
    'security_subtitle': 'Password, session and protection',
    'esp32_connection': 'ESP32 Connection',
    'esp32_connected': 'Connected · 192.168.1.100',
    'notifications': 'Notifications',
    'notifications_subtitle': 'Alerts and push settings',
    'preferences': 'Preferences',
    'language': 'Language',
    'dark_mode': 'Dark Mode',
    'support': 'Support',
    'help_center': 'Help Center',
    'help_subtitle': 'FAQs & guides',
    'about': 'About',
    'privacy': 'Privacy Policy',
    'privacy_subtitle': 'Data & permissions',

    // Alerts
    'alert_management': 'Alert Management',
    'no_alerts': 'No active alerts',
    'no_alerts_filter': 'No active alerts for this filter.',
    'acknowledge': 'Acknowledge',
    'resolve': 'Resolve',

    // Farm
    'farm_management': 'Farm Management',
    'my_farms': 'My Farms',
    'add_farm': 'Add Farm',

    // Reports
    'reports': 'Reports',
    'export_pdf': 'Export PDF',
    'export_excel': 'Export Excel',

    // Common
    'version': 'Version',
  };

  String translate(String key) {
    if (locale.languageCode == 'en') {
      return _en[key] ?? key;
    }
    return _fr[key] ?? key;
  }

  // Shorthand
  String tr(String key) => translate(key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(
    _AppLocalizationsDelegate old,
  ) => false;
}
