import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/flex_theme.dart';
import 'identity_verification_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Profil', style: FlexTextStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: FlexColors.neutral500),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(isDark),
            const SizedBox(height: 8),
            _buildStats(isDark),
            const SizedBox(height: 24),
            _buildMenuSection(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(FlexSpacing.md),
      padding: const EdgeInsets.all(FlexSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: FlexColors.primary100,
                child: Text('JD', style: FlexTextStyles.h2.copyWith(color: FlexColors.primary500)),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: FlexColors.success, shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jean Dupont', style: FlexTextStyles.h2.copyWith(
                  color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                )),
                const SizedBox(height: 4),
                Text('Voyageur', style: FlexTextStyles.caption.copyWith(
                  color: FlexColors.primary500, fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 4),
                Text('+229 97 00 00 00', style: FlexTextStyles.caption.copyWith(
                  color: FlexColors.neutral500,
                )),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('Modifier', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
      child: Row(
        children: [
          _MiniStat(icon: Icons.bookmark_rounded, value: '3', label: 'Voyages'),
          _MiniStat(icon: Icons.star_rounded, value: '4.8', label: 'Note'),
          _MiniStat(icon: Icons.favorite_rounded, value: '5', label: 'Favoris'),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.verified_outlined, title: 'Vérification d\'identité',
            subtitle: 'Passez à la vérification pour plus de confiance',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IdentityVerificationScreen())),
          ),
          _MenuTile(
            icon: Icons.favorite_border_rounded, title: 'Mes favoris',
            subtitle: 'Consultez vos logements sauvegardés',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
          ),
          _MenuTile(
            icon: Icons.home_work_rounded, title: 'Mes locations',
            subtitle: 'Gérez vos locations, paiements et renouvellements',
            onTap: () => Navigator.pushNamed(context, '/locataire-rentals'),
          ),
          _MenuTile(
            icon: Icons.receipt_long_outlined, title: 'Mes réservations',
            subtitle: 'Historique de vos séjours',
            onTap: () => Navigator.pushNamed(context, '/bookings'),
          ),
          _MenuTile(
            icon: Icons.support_outlined, title: 'Support',
            subtitle: 'Aide et assistance',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())),
          ),
          _MenuTile(
            icon: Icons.info_outline, title: 'À propos de Flex',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon; final String value; final String label;
  const _MiniStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: FlexColors.primary500.withOpacity(0.08),
          borderRadius: BorderRadius.circular(FlexRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: FlexColors.primary500),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: FlexColors.primary500)),
            Text(label, style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: FlexColors.primary500.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: FlexColors.primary500, size: 20),
        ),
        title: Text(title, style: FlexTextStyles.label.copyWith(
          color: isDark ? FlexColors.neutral0 : FlexColors.neutral700, fontWeight: FontWeight.w600,
        )),
        subtitle: Text(subtitle, style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral400)),
        trailing: const Icon(Icons.chevron_right_rounded, color: FlexColors.neutral400),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FlexRadius.md),
        ),
      ),
    );
  }
}
