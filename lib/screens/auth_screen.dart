import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/flex_theme.dart';
import '../services/auth_service.dart';
import '../utils/rental_utils.dart';

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
    if (email.isEmpty || !email.contains('@')) { _showError('Entrez un e-mail valide'); return; }
    if (password.length < 6) { _showError('Mot de passe 6+ caractères'); return; }
    setState(() => _isLoading = true);
    try {
      try { await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password); }
      on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') { await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password); }
        else rethrow;
      }
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) { _showError(e.message ?? 'Erreur d\'authentification'); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  void _authWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await AuthService().signInWithGoogle();
      if (userCredential != null && mounted) Navigator.of(context).pushReplacementNamed('/home');
    } catch (_) { _showError('Erreur de connexion avec Google'); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  void _showError(String message) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); }

  void _skipAuth() => Navigator.of(context).pushReplacementNamed('/home');

  void _sendOTP() async {
    final phone = '$_selectedCountryCode${_phoneController.text.trim()}';
    if (_phoneController.text.trim().length < 8) { _showError('Entrez un numéro valide'); return; }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) Navigator.of(context).pushReplacementNamed('/home');
        },
        verificationFailed: (e) { setState(() => _isLoading = false); _showError(e.message ?? 'Échec'); },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _isLoading = false);
          if (mounted) Navigator.of(context).push(MaterialPageRoute(builder: (_) => OTPScreen(phone: phone, verificationId: verificationId, resendToken: resendToken)));
        },
        codeAutoRetrievalTimeout: (String verificationId) { if (mounted) setState(() => _isLoading = false); },
      );
    } catch (_) { setState(() => _isLoading = false); _showError('Une erreur est survenue'); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Top brand section ───
            Container(
              width: size.width,
              padding: const EdgeInsets.fromLTRB(28, 60, 28, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [FlexColors.primary500, FlexColors.primary600],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Geometric background
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GeometricBackgroundPainter(color: Colors.white, opacity: 0.06),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo + skip
                      Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Center(child: SvgPicture.asset('assets/icons/flex.svg', width: 24, height: 24,
                              colorFilter: const ColorFilter.mode(FlexColors.primary500, BlendMode.srcIn))),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _skipAuth,
                            child: Text('Passer', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text('Bienvenue sur', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
                      const Text('Flex', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, fontFamily: 'Poppins', letterSpacing: -1)),
                      const SizedBox(height: 6),
                      Text('Chez vous, partout en Afrique de l\'Ouest.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Bottom form section ───
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Tabs
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(color: FlexColors.primary500, borderRadius: BorderRadius.circular(12)),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: FlexColors.neutral500,
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      tabs: const [Tab(text: 'Téléphone'), Tab(text: 'E-mail')],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 120,
                    child: TabBarView(
                      controller: _tabController,
                      children: [_buildPhoneForm(isDark), _buildEmailForm(isDark)],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _tabController.index == 0 ? _sendOTP() : _authWithEmail(),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_tabController.index == 0 ? 'Recevoir le code' : 'Continuer'),
                    ),
                  ),

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _authWithGoogle,
                      icon: Image.network('https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg', height: 20,
                        errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 20)),
                      label: Text('Continuer avec Google', style: TextStyle(fontSize: 13, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800)),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: isDark ? FlexColors.neutral600 : FlexColors.neutral200)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'En continuant, vous acceptez nos Conditions d\'utilisation\net notre Politique de confidentialité.',
                    style: TextStyle(fontSize: 11, color: FlexColors.neutral400),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: _skipAuth,
                    child: Text('Explorer sans compte', style: TextStyle(fontSize: 13, color: FlexColors.primary500, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneForm(bool isDark) {
    return Column(
      children: [
        Row(
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
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(fontSize: 16, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800),
                decoration: const InputDecoration(hintText: '97 00 00 00'),
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
        TextField(controller: _emailController, keyboardType: TextInputType.emailAddress,
          style: TextStyle(fontSize: 16, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800),
          decoration: const InputDecoration(hintText: 'votre@email.com', prefixIcon: Icon(Icons.email_outlined))),
        const SizedBox(height: 12),
        TextField(controller: _passwordController, obscureText: !_isPasswordVisible,
          style: TextStyle(fontSize: 16, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800),
          decoration: InputDecoration(hintText: 'Mot de passe', prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)))),
      ],
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: FlexColors.neutral300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Choisir le pays', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800)),
            const SizedBox(height: 8),
            ..._countries.map((c) => ListTile(
              leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
              title: Text(c['name']!, style: TextStyle(fontSize: 14)),
              trailing: Text(c['code']!, style: TextStyle(fontSize: 13, color: FlexColors.neutral500)),
              onTap: () { setState(() => _selectedCountryCode = c['code']!); Navigator.pop(ctx); },
            )),
          ]),
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

// ─── OTP SCREEN ───

class OTPScreen extends StatelessWidget {
  final String phone; final String verificationId; final int? resendToken;
  const OTPScreen({super.key, required this.phone, required this.verificationId, this.resendToken});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top illustration
              Container(
                width: size.width, height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [FlexColors.primary500, FlexColors.primary600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: GeometricBackgroundPainter(color: Colors.white, opacity: 0.06))),
                    Column(
                      children: [
                        const Spacer(),
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                          child: const Icon(Icons.smartphone_rounded, size: 32, color: Colors.white),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: _OTPForm(phone: phone, verificationId: verificationId, resendToken: resendToken),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OTPForm extends StatefulWidget {
  final String phone; final String verificationId; final int? resendToken;
  const _OTPForm({required this.phone, required this.verificationId, this.resendToken});

  @override
  State<_OTPForm> createState() => _OTPFormState();
}

class _OTPFormState extends State<_OTPForm> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  late String _verificationId; late int? _resendToken;

  @override
  void initState() { super.initState(); _verificationId = widget.verificationId; _resendToken = widget.resendToken; }

  void _resendCode() async {
    setState(() => _isLoading = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        if (mounted) Navigator.of(context).pushReplacementNamed('/home');
      },
      verificationFailed: (e) { setState(() => _isLoading = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Échec'))); },
      codeSent: (String vid, int? token) { setState(() { _isLoading = false; _verificationId = vid; _resendToken = token; }); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code renvoyé !'))); },
      codeAutoRetrievalTimeout: (vid) => _verificationId = vid,
      forceResendingToken: _resendToken,
    );
  }

  void _verify() async {
    final smsCode = _controllers.map((c) => c.text).join();
    if (smsCode.length < 6) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: smsCode));
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) { setState(() => _isLoading = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Code invalide'))); }
    catch (_) { setState(() => _isLoading = false); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur'))); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text('Code de vérification', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800)),
        const SizedBox(height: 8),
        Text('Entrez le code à 6 chiffres envoyé à', style: TextStyle(color: FlexColors.neutral500)),
        Text(widget.phone, style: TextStyle(fontWeight: FontWeight.w600, color: FlexColors.primary500)),
        const SizedBox(height: 32),

        // OTP fields
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => SizedBox(
            width: 48, height: 56,
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center, maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800),
              decoration: InputDecoration(counterText: '', contentPadding: EdgeInsets.zero),
              onChanged: (val) {
                if (val.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
                if (_controllers.every((c) => c.text.isNotEmpty)) _verify();
              },
            ),
          )),
        ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verify,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Vérifier'),
          ),
        ),

        const SizedBox(height: 16),

        TextButton(
          onPressed: _isLoading ? null : _resendCode,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text('Renvoyer le code', style: TextStyle(color: FlexColors.primary500, fontWeight: FontWeight.w500)),
        ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/auth'),
          child: Text('Changer de numéro', style: TextStyle(fontSize: 12, color: FlexColors.neutral400)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }
}
