import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/flex_theme.dart';
import 'theme/theme_provider.dart';
import 'services/auth_service.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr', null);

  final authService = AuthService();
  await authService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => authService),
      ],
      child: FlexApp(authService: authService),
    ),
  );
}

class FlexApp extends StatefulWidget {
  final AuthService authService;
  const FlexApp({super.key, required this.authService});

  @override
  State<FlexApp> createState() => _FlexAppState();
}

class _FlexAppState extends State<FlexApp> {
  late final GoRouter _router = createAppRouter(AuthService());

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'Flex',
      debugShowCheckedModeBanner: false,
      theme: flexLightTheme(),
      darkTheme: flexDarkTheme(),
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}

// ─────────────────────────────────────────────
//  SPLASH — shown on mobile before navigation.
//  On desktop/web, we route immediately without
//  a blocking full-screen animation.
// ─────────────────────────────────────────────

class FlexSplashScreen extends StatefulWidget {
  const FlexSplashScreen({super.key});

  @override
  State<FlexSplashScreen> createState() => _FlexSplashScreenState();
}

class _FlexSplashScreenState extends State<FlexSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Desktop / Web: no splash animation — just a blank screen while routing
    if (kIsWeb) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: FlexColors.primary500,
            ),
          ),
        ),
      );
    }

    // Mobile: full branded splash
    return Scaffold(
      backgroundColor: FlexColors.primary500,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.home_rounded,
                      size: 48,
                      color: FlexColors.primary500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Flex',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chez vous, partout.',
                  style: FlexTextStyles.body.copyWith(
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
