import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/flex_theme.dart';
import '../services/auth_service.dart';

// ─────────────────────────────────────────────
//  AUTH SCREEN — Phone OTP
// ─────────────────────────────────────────────

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String _selectedCountryCode = '+229';

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

  void _authWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showError('Entrez un e-mail valide');
      return;
    }
    if (password.length < 6) {
      _showError('Le mot de passe doit faire au moins 6 caractères');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Tente de se connecter
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // Si l'utilisateur n'existe pas, on le crée
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Erreur d\'authentification');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _authWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final userCredential = await authService.signInWithGoogle();
      if (userCredential != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      _showError('Erreur de connexion avec Google');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _sendOTP() async {
    final phone = '$_selectedCountryCode${_phoneController.text.trim()}';
    if (_phoneController.text.trim().length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un numéro valide')),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Échec de la vérification')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _isLoading = false);
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OTPScreen(
                  phone: phone,
                  verificationId: verificationId,
                  resendToken: resendToken,
                ),
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (mounted) setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une erreur est survenue')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(FlexSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: FlexColors.primary500,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/flex.svg',
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: FlexSpacing.lg),

                Text(
                  'Bienvenue sur\nFlex',
                  style: FlexTextStyles.h1.copyWith(
                    color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                  ),
                ),
                const SizedBox(height: FlexSpacing.sm),
                Text(
                  'Connectez-vous pour continuer.',
                  style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
                ),
                const SizedBox(height: FlexSpacing.xl),

                // Tabs
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
                    borderRadius: BorderRadius.circular(FlexRadius.md),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: FlexColors.primary500,
                      borderRadius: BorderRadius.circular(FlexRadius.md),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: FlexColors.neutral500,
                    labelStyle: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Téléphone'),
                      Tab(text: 'E-mail'),
                    ],
                  ),
                ),
                const SizedBox(height: FlexSpacing.xl),

                // Tab Content
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Phone Form
                      _buildPhoneForm(isDark),
                      // Email Form
                      _buildEmailForm(isDark),
                    ],
                  ),
                ),

                const SizedBox(height: FlexSpacing.xl),

                // CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_tabController.index == 0) {
                              _sendOTP();
                            } else {
                              _authWithEmail();
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_tabController.index == 0 ? 'Recevoir le code' : 'Continuer'),
                  ),
                ),

                const SizedBox(height: FlexSpacing.xl),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: FlexColors.neutral300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OU',
                        style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral400),
                      ),
                    ),
                    Expanded(child: Divider(color: FlexColors.neutral300)),
                  ],
                ),

                const SizedBox(height: FlexSpacing.xl),

                // Google Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _authWithGoogle,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? FlexColors.neutral600 : FlexColors.neutral200,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FlexRadius.md),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                          height: 24,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.g_mobiledata, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Continuer avec Google',
                          style: FlexTextStyles.label.copyWith(
                            color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: FlexSpacing.xl),

                // Footer
                Center(
                  child: Text(
                    'En continuant, vous acceptez nos\nConditions d\'utilisation et notre Politique de confidentialité.',
                    style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral400),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: FlexSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneForm(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            // Country code picker
            GestureDetector(
              onTap: () => _showCountryPicker(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
                  borderRadius: BorderRadius.circular(FlexRadius.md),
                  border: Border.all(
                    color: isDark ? FlexColors.neutral600 : FlexColors.neutral200,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _countries.firstWhere(
                        (c) => c['code'] == _selectedCountryCode,
                      )['flag']!,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _selectedCountryCode,
                      style: FlexTextStyles.label.copyWith(
                        color: isDark ? FlexColors.neutral0 : FlexColors.neutral700,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: FlexColors.neutral400,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: FlexSpacing.sm),

            // Phone number field
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: FlexTextStyles.bodyLarge.copyWith(
                  color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                ),
                decoration: const InputDecoration(
                  hintText: '97 00 00 00',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailForm(bool isDark) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: FlexTextStyles.bodyLarge.copyWith(
            color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
          ),
          decoration: const InputDecoration(
            hintText: 'votre@email.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: FlexSpacing.md),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: FlexTextStyles.bodyLarge.copyWith(
            color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
          ),
          decoration: InputDecoration(
            hintText: 'Mot de passe',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(FlexRadius.xl)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(FlexSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: FlexColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: FlexSpacing.md),
              Text('Choisir le pays', style: FlexTextStyles.h3),
              const SizedBox(height: FlexSpacing.md),
              ..._countries.map((c) => ListTile(
                leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
                title: Text(c['name']!, style: FlexTextStyles.body),
                trailing: Text(c['code']!, style: FlexTextStyles.label.copyWith(
                  color: FlexColors.neutral500,
                )),
                onTap: () {
                  setState(() => _selectedCountryCode = c['code']!);
                  Navigator.pop(ctx);
                },
              )),
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
    super.dispose();
  }
}

// ─────────────────────────────────────────────
//  OTP SCREEN
// ─────────────────────────────────────────────

class OTPScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  final int? resendToken;
  const OTPScreen({
    super.key,
    required this.phone,
    required this.verificationId,
    this.resendToken,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  late String _verificationId;
  late int? _resendToken;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;
  }

  void _resendCode() async {
    setState(() => _isLoading = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        if (mounted) Navigator.of(context).pushReplacementNamed('/home');
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Échec')),
        );
      },
      codeSent: (String vid, int? token) {
        setState(() {
          _isLoading = false;
          _verificationId = vid;
          _resendToken = token;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code renvoyé !')),
        );
      },
      codeAutoRetrievalTimeout: (vid) => _verificationId = vid,
      forceResendingToken: _resendToken,
    );
  }

  void _verify() async {
    final smsCode = _controllers.map((c) => c.text).join();
    if (smsCode.length < 6) return;

    setState(() => _isLoading = true);
    
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Code invalide')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la vérification')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(FlexSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code envoyé à',
              style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
            ),
            Text(
              widget.phone,
              style: FlexTextStyles.h3.copyWith(
                color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
              ),
            ),
            const SizedBox(height: FlexSpacing.xl),

            // OTP fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                return SizedBox(
                  width: 48,
                  height: 56,
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: FlexTextStyles.h2.copyWith(
                      color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty && i < 5) {
                        _focusNodes[i + 1].requestFocus();
                      }
                      if (_controllers.every((c) => c.text.isNotEmpty)) {
                        _verify();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: FlexSpacing.xl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Vérifier'),
              ),
            ),
            const SizedBox(height: FlexSpacing.md),

            Center(
              child: TextButton(
                onPressed: _isLoading ? null : _resendCode,
                child: const Text('Renvoyer le code'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }
}
