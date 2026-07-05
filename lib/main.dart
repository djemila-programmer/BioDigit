import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'supabase.dart';
import 'theme/app_theme.dart';
import 'routes.dart';
import 'core/app_localizations.dart';

import 'services/auth_service.dart';
import 'services/sensor_service.dart';
import 'services/alert_service.dart';
import 'services/farm_service.dart';
import 'services/history_service.dart';
import 'services/anomaly_service.dart';
import 'services/notification_service.dart';
import 'services/pdf_service.dart';
import 'services/excel_service.dart';
import 'services/cache_service.dart';
import 'services/simulation_service.dart';
import 'services/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await initSupabase();

  final cacheService = CacheService();
  await cacheService.initialize();

  // Open the theme box for dark mode persistence
  await Hive.openBox('themeBox');
  await Hive.openBox('localeBox');

  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    BioSmartApp(
      cacheService: cacheService,
      notificationService: notificationService,
    ),
  );
}

class BioSmartApp extends StatelessWidget {
  final CacheService cacheService;
  final NotificationService notificationService;

  const BioSmartApp({
    super.key,
    required this.cacheService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final sensorService = SensorService();
    final alertService = AlertService();
    final farmService = FarmService();
    final historyService = HistoryService();
    final anomalyService = AnomalyService();
    final pdfService = PdfService();
    final excelService = ExcelService();
    final simulationService = SimulationService();

    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<SensorService>.value(value: sensorService),
        Provider<AlertService>.value(value: alertService),
        Provider<FarmService>.value(value: farmService),
        Provider<HistoryService>.value(value: historyService),
        Provider<AnomalyService>.value(value: anomalyService),
        Provider<NotificationService>.value(value: notificationService),
        Provider<PdfService>.value(value: pdfService),
        Provider<ExcelService>.value(value: excelService),
        Provider<CacheService>.value(value: cacheService),
        Provider<SimulationService>.value(value: simulationService),

        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),

        ChangeNotifierProvider(
          create: (_) => SensorProvider(
            sensorService,
            historyService,
            notificationService,
            cacheService,
            simulationService,
          ),
        ),

        ChangeNotifierProvider(create: (_) => AlertProvider(alertService)),

        ChangeNotifierProvider(create: (_) => AnomalyProvider(anomalyService)),

        ChangeNotifierProvider(create: (_) => HistoryProvider(historyService)),

        ChangeNotifierProvider(create: (_) => FarmProvider(farmService)),

        ChangeNotifierProvider(
          create: (_) => NotificationProvider(notificationService),
        ),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        ChangeNotifierProvider(create: (_) => LocaleProvider()),

        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider()..startListening(),
        ),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'BioSmart Africa',
            theme: AppTheme.theme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            navigatorKey: AppNavigation.navigatorKey,
            builder: (context, child) {
              return AppSessionListener(child: child ?? const SizedBox.shrink());
            },
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}

class AppNavigation {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class AppSessionListener extends StatefulWidget {
  final Widget child;

  const AppSessionListener({super.key, required this.child});

  @override
  State<AppSessionListener> createState() => _AppSessionListenerState();
}

class _AppSessionListenerState extends State<AppSessionListener> {
  bool _hasRoutedRecovery = false;
  bool _dataListenersStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final auth = context.watch<AuthProvider>();

    // ── Start data listeners once after successful authentication ──
    if (auth.isAuthenticated && !_dataListenersStarted) {
      _dataListenersStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<SensorProvider>().startListening();
        context.read<AlertProvider>().startListening();
        context.read<NotificationProvider>().startListening();
      });
    }

    // Reset flag when user logs out so listeners restart on next login
    if (!auth.isAuthenticated) {
      _dataListenersStarted = false;
    }

    if (auth.isPasswordRecovery && !_hasRoutedRecovery) {
      _hasRoutedRecovery = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppNavigation.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.resetPassword,
          (route) => false,
        );
        auth.clearRecoveryState();
      });
    }

    if (!auth.isPasswordRecovery) {
      _hasRoutedRecovery = false;
    }
  }

  @override
  void dispose() {
    // Stop listeners on dispose to avoid leaks
    try {
      context.read<SensorProvider>().stopListening();
      context.read<AlertProvider>().stopListening();
      context.read<NotificationProvider>().stopListening();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
