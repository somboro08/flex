import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/flex_theme.dart';
import '../../services/auth_service.dart';
import '../booking/my_bookings_screen.dart';
import 'favorites_screen.dart'; // Import the new FavoritesScreen
import 'identity_verification_screen.dart'; // Import the new IdentityVerificationScreen
import 'settings_screen.dart';
import 'support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
              }
            },
            child: const Text('Déconnexion', style: TextStyle(color: FlexColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? 'Utilisateur Flex';
    final String contactInfo = user?.email ?? user?.phoneNumber ?? 'Aucun contact';
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Profil', style: FlexTextStyles.h3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: FlexSpacing.lg),
            // Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: FlexColors.primary100,
                        child: Text(
                          initial,
                          style: FlexTextStyles.display.copyWith(
                            color: FlexColors.primary600,
                            fontSize: 40,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: FlexColors.primary500,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FlexSpacing.md),
                  Text(
                    displayName,
                    style: FlexTextStyles.h2.copyWith(
                      color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                    ),
                  ),
                  Text(
                    contactInfo,
                    style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: FlexSpacing.xl),

            // Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.bookmark_outline_rounded,
                    title: 'Mes Réservations',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
                      );
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.favorite_border_rounded,
                    title: 'Mes Favoris',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FavoritesScreen()),
                      );
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Vérification d\'identité',
                    isDark: isDark,
                    trailing: const Icon(Icons.error_outline_rounded, color: FlexColors.warning, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => IdentityVerificationScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: FlexSpacing.lg),
                  _ProfileMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Paramètres',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Aide & Support',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SupportScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: FlexSpacing.lg),
                  _ProfileMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Déconnexion',
                    isDark: isDark,
                    textColor: FlexColors.error,
                    iconColor: FlexColors.error,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;
  final Color? textColor;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.isDark,
    this.textColor,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: FlexSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(
          color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
          width: 0.5,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? FlexColors.primary500),
        title: Text(
          title,
          style: FlexTextStyles.label.copyWith(
            color: textColor ?? (isDark ? FlexColors.neutral0 : FlexColors.neutral800),
          ),
        ),
        trailing: trailing ?? Icon(
          Icons.chevron_right_rounded,
          color: isDark ? FlexColors.neutral600 : FlexColors.neutral300,
        ),
        onTap: onTap ?? () {},
      ),
    );
  }
}
