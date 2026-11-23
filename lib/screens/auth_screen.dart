import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/auth_service.dart';
import '../theme/flex_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String _selectedCountryCode = '+229';

  final _authService = AuthService();

  final List<Map<String, String>> _countries = [
    {'code': '+229', 'flag': '🇧🇯', 'name': 'Bénin'},
    {'code': '+225', 'flag': '🇨🇮', 'name': 'Côte d\'Ivoire'},
    {'code': '+223', 'flag': '🇲🇱', 'name': 'Mali'},
    {'code': '+221', 'flag': '🇸🇳', 'name': 'Sénégal'},
    {'code': '+226', 'flag': '🇧🇫', 'name': 'Burkina Faso'},
    {'code': '+228', 'flag': '🇹🇬', 'name': 'Togo'},
    {'code': '+227', 'flag': '🇳🇪', 'name': 'Niger'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  String get _telephone {
    final value = _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');
    if (value.startsWith('+')) return value;
    return '$_selectedCountryCode${value.replaceFirst(RegExp(r'^0+'), '')}';
  }

  Future<void> _submit() async {
    final telephone = _telephone;
    final password = _passwordController.text;

    if (telephone.length < 8) {
      _showError('Entrez un numéro de téléphone valide.');
      return;
    }
    if (password.length < 8) {
      _showError('Le mot de passe doit contenir au moins 8 caractères.');
      return;
    }

    final isRegister = _tabController.index == 1;
    if (isRegister &&
        (_nomController.text.trim().isEmpty ||
            _prenomController.text.trim().isEmpty)) {
      _showError('Renseignez votre nom et votre prénom.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (isRegister) {
        await _authService.register(
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          telephone: telephone,
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          password: password,
        );
      } else {
        await _authService.login(
          telephone: telephone,
          password: password,
        );
      }

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      }
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Une erreur inattendue est survenue.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _skipAuth() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: size.width,
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [FlexColors.primary500, FlexColors.primary600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GeometricBackgroundPainter(
                          color: Colors.white,
                          opacity: 0.06,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/flex.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    FlexColors.primary500,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _skipAuth,
                              child: Text(
                                'Explorer',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Bienvenue sur',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Flex',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Chez vous, partout en Afrique de l\'Ouest.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDark
                            ? FlexColors.neutral700
                            : FlexColors.neutral100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: FlexColors.primary500,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: FlexColors.neutral500,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: const [
                          Tab(text: 'Connexion'),
                          Tab(text: 'Créer un compte'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) {
                        final isRegister = _tabController.index == 1;
                        return Column(
                          children: [
                            if (isRegister) ...[
                              _buildInput(
                                controller: _prenomController,
                                hint: 'Prénom',
                                icon: Icons.person_outline,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              _buildInput(
                                controller: _nomController,
                                hint: 'Nom',
                                icon: Icons.person_outline,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                            ],
                            _buildPhoneInput(isDark),
                            if (isRegister) ...[
                              const SizedBox(height: 12),
                              _buildInput(
                                controller: _emailController,
                                hint: 'E-mail (facultatif)',
                                icon: Icons.email_outlined,
                                isDark: isDark,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ],
                            const SizedBox(height: 12),
                            TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark
                                    ? FlexColors.neutral0
                                    : FlexColors.neutral800,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Mot de passe',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _isPasswordVisible =
                                        !_isPasswordVisible,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : AnimatedBuilder(
                                animation: _tabController,
                                builder: (context, _) => Text(
                                  _tabController.index == 0
                                      ? 'Se connecter'
                                      : 'Créer mon compte',
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Connexion sécurisée par le serveur Flex (JWT).',
                      style: TextStyle(
                        fontSize: 11,
                        color: FlexColors.neutral400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _skipAuth,
                      child: Text(
                        'Explorer sans compte',
                        style: TextStyle(
                          fontSize: 13,
                          color: FlexColors.primary500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(
        fontSize: 15,
        color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildPhoneInput(bool isDark) {
    return Row(
      children: [
        GestureDetector(
          onTap: _showCountryPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? FlexColors.neutral600
                    : FlexColors.neutral200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _countries.firstWhere(
                    (country) => country['code'] == _selectedCountryCode,
                  )['flag']!,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 4),
                Text(
                  _selectedCountryCode,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? FlexColors.neutral0
                        : FlexColors.neutral700,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: FlexColors.neutral400,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 16,
              color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
            ),
            decoration: const InputDecoration(
              hintText: '97 00 00 00',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
        ),
      ],
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              Text(
                'Choisir le pays',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? FlexColors.neutral0
                      : FlexColors.neutral800,
                ),
              ),
              const SizedBox(height: 8),
              ..._countries.map(
                (country) => ListTile(
                  leading: Text(
                    country['flag']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(country['name']!),
                  trailing: Text(country['code']!),
                  onTap: () {
                    setState(
                      () => _selectedCountryCode = country['code']!,
                    );
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    super.dispose();
  }
}
