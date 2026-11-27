import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/flex_theme.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../core/responsive/breakpoints.dart';
import '../shared/widgets/adaptive_overlay.dart';
import '../shared/widgets/adaptive_dialog_content.dart';
import '../utils/password_validator.dart';
import 'auth/forgot_password_dialog.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isRegisterPasswordVisible = false;
  String _selectedCountryCode = '+229';
  String _selectedRole = 'voyageur';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  final List<Map<String, String>> _countries = [
    {'code': '+229', 'flag': '🇧🇯', 'name': 'Bénin'},
    {'code': '+225', 'flag': '🇨🇮', 'name': 'Côte d\'Ivoire'},
    {'code': '+223', 'flag': '🇲🇱', 'name': 'Mali'},
    {'code': '+221', 'flag': '🇸🇳', 'name': 'Sénégal'},
    {'code': '+226', 'flag': '🇧🇫', 'name': 'Burkina Faso'},
    {'code': '+228', 'flag': '🇹🇬', 'name': 'Togo'},
    {'code': '+227', 'flag': '🇳🇪', 'name': 'Niger'},
  ];

  String get _fullPhone => '$_selectedCountryCode${_phoneController.text.trim()}';

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 8) { _showError('Entrez un numéro de téléphone valide'); return; }
    if (_passwordController.text.isEmpty) { _showError('Entrez votre mot de passe'); return; }

    setState(() => _isLoading = true);
    try {
      final ok = await context.read<AuthService>().login(_fullPhone, _passwordController.text);
      if (!mounted) return;
      if (ok) {
        context.go('/home');
      } else {
        _showError('Identifiants incorrects');
      }
    } catch (e) {
      if (!mounted) return;
      _showError(ApiClient.errorMessage(e, fallback: 'Connexion impossible. Vérifiez votre connexion internet.'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openForgotPassword() async {
    final reset = await showForgotPasswordDialog(
      context,
      initialPhone: _fullPhone,
    );
    if (reset == true && mounted) {
      _showError('Mot de passe réinitialisé. Vous pouvez vous connecter.');
    }
  }

  Future<void> _register() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _registerPasswordController.text;

    if (nom.isEmpty) { _showError('Entrez votre nom'); return; }
    if (prenom.isEmpty) { _showError('Entrez votre prénom'); return; }
    if (phone.length < 8) { _showError('Entrez un numéro de téléphone valide'); return; }
    final passwordError = strongPasswordError(password);
    if (passwordError != null) { _showError('Mot de passe : $passwordError'); return; }
    final email = _emailController.text.trim();
    if (email.isNotEmpty && !email.contains('@')) { _showError('Entrez un e-mail valide'); return; }

    setState(() => _isLoading = true);
    try {
      final ok = await context.read<AuthService>().register(
        nom: nom,
        prenom: prenom,
        telephone: _fullPhone,
        password: password,
        email: email,
        role: _selectedRole,
      );
      if (!mounted) return;
      if (ok) {
        context.go('/home');
      } else {
        _showError('Inscription impossible, réessayez');
      }
    } catch (e) {
      if (!mounted) return;
      _showError(ApiClient.errorMessage(e, fallback: 'Inscription impossible. Vérifiez votre connexion internet.'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); }

  void _skipAuth() => context.go('/home');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLogin = _tabController.index == 0;

    // ── Desktop: two-column hero + form layout ────────────
    if (context.isDesktop) {
      return Scaffold(
        backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
        body: Row(
          children: [
            // Left: full-height brand panel
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [FlexColors.primary600, FlexColors.primary500, Color(0xFFFF8C42)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GeometricBackgroundPainter(color: Colors.white, opacity: 0.07),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          Row(
                            children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/icons/flexIco.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.home_rounded, color: FlexColors.primary500, size: 28),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text('FLEX', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 2)),
                            ],
                          ),
                          const Spacer(),
                          // Hero text
                          const Text(
                            'Hébergement économique\ncertifié.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Trouvez un logement de confiance en Afrique de l\'Ouest — aussi simple que d\'envoyer un message.',
                            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16, height: 1.5),
                          ),
                          const Spacer(),
                          // Stats row
                          Row(
                            children: [
                              _HeroBadge(value: '200+', label: 'Logements'),
                              const SizedBox(width: 32),
                              _HeroBadge(value: '6', label: 'Pays'),
                              const SizedBox(width: 32),
                              _HeroBadge(value: '100%', label: 'Certifiés'),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right: form panel
            Expanded(
              flex: 4,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _buildFormSection(isDark, isLogin),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Mobile / Tablet: original stacked layout ──────────
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMobileHero(context, isDark),
            Container(
              padding: const EdgeInsets.all(24),
              child: _buildFormSection(isDark, isLogin),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHero(BuildContext context, bool isDark) {
    final width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          width: width,
          height: 240,
          decoration: const BoxDecoration(
            color: FlexColors.primary600,
            image: DecorationImage(
              image: AssetImage('assets/images/flex_auth_hero.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
            ),
          ),
        ),
        Container(
          width: width,
          height: 240,
          padding: const EdgeInsets.fromLTRB(28, 50, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)]
                    ),
                    child: Image.asset(
                      'assets/icons/flexIco.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text('FLEX', style: TextStyle(color: FlexColors.primary500, fontWeight: FontWeight.bold, fontSize: 12))
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('FLEX', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  const Spacer(),
                  TextButton(
                    onPressed: _skipAuth,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black38,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ),
                    child: const Text('Passer', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Réseau d\'hébergement économique certifié', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  const Text('Bienvenue sur Flex', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(bool isDark, bool isLogin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Desktop header
        if (context.isDesktop) ...[
          Text('Bienvenue sur Flex', style: FlexTextStyles.h2.copyWith(
            color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
          )),
          const SizedBox(height: 4),
          Text('Connectez-vous ou créez un compte', style: FlexTextStyles.body.copyWith(
            color: FlexColors.neutral500,
          )),
          const SizedBox(height: 24),
        ],
        // Tab bar
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (_) => setState(() {}),
            indicator: BoxDecoration(color: FlexColors.primary500, borderRadius: BorderRadius.circular(12)),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: FlexColors.neutral500,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: const [Tab(text: 'Se connecter'), Tab(text: 'Créer un compte')],
          ),
        ),
        const SizedBox(height: 20),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLogin ? _buildLoginForm(isDark) : _buildRegisterForm(isDark),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: _isLoading ? null : (isLogin ? _login : _register),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(isLogin ? 'Se connecter' : 'Créer mon compte'),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: Divider(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('ou', style: TextStyle(fontSize: 12, color: FlexColors.neutral400)),
            ),
            Expanded(child: Divider(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          'En continuant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.',
          style: TextStyle(fontSize: 11, color: FlexColors.neutral400),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: _skipAuth,
          child: Text('Explorer sans compte', style: TextStyle(fontSize: 13, color: FlexColors.primary500, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _phoneField(bool isDark, {TextEditingController? controller, String? hint}) {
    return Row(
      children: [
        GestureDetector(
          onTap: _showCountryPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
              borderRadius: BorderRadius.circular(10), border: Border.all(color: isDark ? FlexColors.neutral600 : FlexColors.neutral200)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_countries.firstWhere((c) => c['code'] == _selectedCountryCode)['flag']!, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text(_selectedCountryCode, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? FlexColors.neutral0 : FlexColors.neutral700)),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: FlexColors.neutral400),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller ?? _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(fontSize: 16, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800),
            decoration: InputDecoration(hintText: hint ?? '97 00 00 00'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isDark) {
    return Column(
      key: const ValueKey('login'),
      children: [
        _phoneField(isDark),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          onSubmitted: (_) => _login(),
          style: TextStyle(fontSize: 16, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800),
          decoration: InputDecoration(hintText: 'Mot de passe', prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible))),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isLoading ? null : _openForgotPassword,
            child: const Text('Mot de passe oublié ?'),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(bool isDark) {
    return Column(
      key: const ValueKey('register'),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _prenomController,
                style: TextStyle(fontSize: 16, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800),
                decoration: const InputDecoration(hintText: 'Prénom'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _nomController,
                style: TextStyle(fontSize: 16, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800),
                decoration: const InputDecoration(hintText: 'Nom'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _phoneField(isDark),
        const SizedBox(height: 12),
        TextField(
          controller: _registerPasswordController,
          obscureText: !_isRegisterPasswordVisible,
          style: TextStyle(fontSize: 16, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800),
          decoration: InputDecoration(hintText: 'Mot de passe (8+, maj., min., chiffre, spécial)', prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(icon: Icon(_isRegisterPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => _isRegisterPasswordVisible = !_isRegisterPasswordVisible))),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(fontSize: 16, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800),
          decoration: const InputDecoration(hintText: 'E-mail (facultatif)', prefixIcon: Icon(Icons.email_outlined)),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Je suis un(e)…', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlexColors.neutral500)),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _roleChip('voyageur', 'Voyageur', Icons.luggage_outlined, isDark),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _roleChip('hote', 'Propriétaire', Icons.home_work_outlined, isDark),
            ),
          ],
        ),
      ],
    );
  }

  Widget _roleChip(String value, String label, IconData icon, bool isDark) {
    final selected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? FlexColors.primary500.withValues(alpha: 0.12) : (isDark ? FlexColors.neutral700 : FlexColors.neutral100),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? FlexColors.primary500 : (isDark ? FlexColors.neutral600 : FlexColors.neutral200),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? FlexColors.primary500 : FlexColors.neutral400),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: selected ? FlexColors.primary500 : FlexColors.neutral500)),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker() {
    AdaptiveOverlay.show(
      context: context,
      child: AdaptiveDialogContent(
        title: 'Choisir le pays',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._countries.map((c) => ListTile(
              leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
              title: Text(c['name']!, style: const TextStyle(fontSize: 14)),
              trailing: Text(c['code']!, style: TextStyle(fontSize: 13, color: FlexColors.neutral500)),
              onTap: () { setState(() => _selectedCountryCode = c['code']!); Navigator.pop(context); },
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }
}

class GeometricBackgroundPainter extends CustomPainter {
  final Color color;
  final double opacity;
  const GeometricBackgroundPainter({required this.color, this.opacity = 1});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rnd = Random(7);
    for (var i = 0; i < 26; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final radius = 18 + rnd.nextDouble() * 70;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GeometricBackgroundPainter oldDelegate) => false;
}

class _HeroBadge extends StatelessWidget {
  final String value;
  final String label;
  const _HeroBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

