import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/content_container.dart';
import '../../shared/widgets/adaptive_overlay.dart';
import '../../shared/widgets/adaptive_dialog_content.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Profil', style: FlexTextStyles.h3),
        centerTitle: !context.isDesktop,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Tooltip(
            message: 'Paramètres',
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: FlexColors.neutral500),
              onPressed: () => context.push('/settings'),
            ),
          ),
        ],
      ),
      body: AdaptiveContentContainer(
        maxWidth: 800, // Profile content should be compact even on large screens
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (user == null) ...[
                _buildGuestCard(context, isDark),
                const SizedBox(height: 8),
                _buildMenuSection(context, isDark, null),
              ] else ...[
                _buildProfileHeader(context, isDark, user),
                const SizedBox(height: 8),
                _buildRoleActions(context, isDark, user),
                const SizedBox(height: 8),
                _buildMenuSection(context, isDark, user),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestCard(BuildContext context, bool isDark) {
    final isDesktop = context.isDesktop;

    return Container(
      margin: const EdgeInsets.all(FlexSpacing.md),
      padding: const EdgeInsets.all(FlexSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: FlexColors.primary100,
            child: Icon(Icons.person_outline_rounded, color: FlexColors.primary500, size: 28),
          ),
          const SizedBox(height: 12),
          Text('Invité',
              style: FlexTextStyles.h2.copyWith(color: isDark ? FlexColors.neutral0 : FlexColors.neutral800)),
          const SizedBox(height: 4),
          Text(
            'Connectez-vous pour réserver, gérer vos favoris et bien plus',
            style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // On desktop, button should be intrinsically sized
          if (isDesktop)
            ElevatedButton(
              onPressed: () => context.push('/auth'),
              child: const Text('Se connecter / S\'inscrire'),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/auth'),
                child: const Text('Se connecter / S\'inscrire'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDark, FlexUser user) {
    final fullName = user.fullName.trim().isEmpty ? '—' : user.fullName;
    final initials = fullName.length >= 2 ? fullName.substring(0, 2).toUpperCase() : '?';

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
                child: Text(initials,
                    style: FlexTextStyles.h2.copyWith(color: FlexColors.primary500)),
              ),
              if (user.isVerified)
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: FlexColors.success, shape: BoxShape.circle),
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
                Text(fullName,
                    style: FlexTextStyles.h2.copyWith(
                      color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                    )),
                const SizedBox(height: 4),
                Text(user.roleLabel,
                    style: FlexTextStyles.caption.copyWith(
                      color: FlexColors.primary500,
                      fontWeight: FontWeight.w600,
                    )),
                if (user.telephone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(user.telephone,
                      style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
                ],
                if (user.email != null && user.email!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(user.email!,
                      style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
                ],
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _showEditProfileDialog(context, user),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('Modifier', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleActions(BuildContext context, bool isDark, FlexUser user) {
    if (user.role == UserRole.hote) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: _RoleActionCard(
                icon: Icons.dashboard_rounded,
                label: 'Tableau de bord',
                onTap: () => context.push('/hote-dashboard'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RoleActionCard(
                icon: Icons.home_work_rounded,
                label: 'Mes logements',
                onTap: () => context.push('/hote-rentals'),
              ),
            ),
          ],
        ),
      );
    }
    if (user.role == UserRole.agent) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: _RoleActionCard(
                icon: Icons.fact_check_rounded,
                label: 'Audit terrain',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sélectionnez un logement en attente depuis la liste des annonces')),
                ),
              ),
            ),
          ],
        ),
      );
    }
    // Locataire → Become Hôte CTA
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
      child: GestureDetector(
        onTap: () => _confirmBecomeHote(context),
        child: Container(
          padding: const EdgeInsets.all(FlexSpacing.md),
          decoration: BoxDecoration(
            color: FlexColors.primary500.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(FlexRadius.lg),
            border: Border.all(color: FlexColors.primary500.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: FlexColors.primary500,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Devenir propriétaire',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    SizedBox(height: 2),
                    Text('Publiez vos logements et gérez vos locations',
                        style: TextStyle(fontSize: 11, color: FlexColors.neutral500)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: FlexColors.primary500),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmBecomeHote(BuildContext context) {
    AdaptiveOverlay.show(
      context: context,
      child: AdaptiveDialogContent(
        title: 'Devenir propriétaire',
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<AuthService>().becomeHote();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vous êtes maintenant propriétaire !')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ApiClient.errorMessage(e,
                          fallback: 'Impossible de changer de rôle'))));
                }
              }
            },
            child: const Text('Continuer'),
          ),
        ],
        child: const Text(
            'Vous pourrez publier vos logements sur Flex et gérer vos locations. Voulez-vous continuer ?'),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, bool isDark, FlexUser? user) {
    final isHote = user != null && (user.role == UserRole.hote || user.role == UserRole.agent);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.verified_outlined,
            title: 'Vérification d\'identité',
            subtitle: 'Passez à la vérification pour plus de confiance',
            onTap: () => context.push('/identity-verification'),
          ),
          _MenuTile(
            icon: Icons.favorite_border_rounded,
            title: 'Mes favoris',
            subtitle: 'Consultez vos logements sauvegardés',
            onTap: () => context.push('/favorites'),
          ),
          _MenuTile(
            icon: Icons.home_work_rounded,
            title: 'Mes locations',
            subtitle: 'Gérez vos locations, paiements et renouvellements',
            onTap: () => context.push('/locataire-rentals'),
          ),
          _MenuTile(
            icon: Icons.receipt_long_outlined,
            title: 'Mes réservations',
            subtitle: 'Historique de vos séjours',
            onTap: () => context.go('/bookings'),
          ),
          if (isHote) ...[
            _MenuTile(
              icon: Icons.dashboard_rounded,
              title: 'Espace propriétaire',
              subtitle: 'Tableau de bord, logements, visites',
              onTap: () => context.push('/hote-dashboard'),
            ),
          ],
          _MenuTile(
            icon: Icons.support_outlined,
            title: 'Support',
            subtitle: 'Aide et assistance',
            onTap: () => context.push('/support'),
          ),
          _MenuTile(
            icon: Icons.info_outline,
            title: 'À propos de Flex',
            subtitle: 'Version 1.0.0',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Flex',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2026 Flex — Tous droits réservés',
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 16),
            // Intrinsically-sized logout on desktop, full-width on mobile
            context.isDesktop
                ? OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded, color: FlexColors.error),
                    label: const Text('Se déconnecter',
                        style: TextStyle(color: FlexColors.error, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: FlexColors.error),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FlexRadius.md)),
                    ),
                    onPressed: () => _confirmSignOut(context),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout_rounded, color: FlexColors.error),
                      label: const Text('Se déconnecter',
                          style: TextStyle(color: FlexColors.error, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: FlexColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FlexRadius.md)),
                      ),
                      onPressed: () => _confirmSignOut(context),
                    ),
                  ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, FlexUser user) {
    final nomCtrl = TextEditingController(text: user.nom);
    final prenomCtrl = TextEditingController(text: user.prenom);
    final phoneCtrl = TextEditingController(text: user.telephone);
    final emailCtrl = TextEditingController(text: user.email ?? '');
    var saving = false;

    AdaptiveOverlay.show(
      context: context,
      child: StatefulBuilder(
        builder: (ctx, setState) => AdaptiveDialogContent(
          title: 'Modifier mon profil',
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      setState(() => saving = true);
                      try {
                        await context.read<AuthService>().updateProfile(
                          nom: nomCtrl.text.trim(),
                          prenom: prenomCtrl.text.trim(),
                          telephone: phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(ctx)
                              .showSnackBar(const SnackBar(content: Text('Profil mis à jour !')));
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          setState(() => saving = false);
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                              content: Text(ApiClient.errorMessage(e,
                                  fallback: 'Erreur lors de la mise à jour'))));
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Enregistrer'),
            ),
          ],
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: prenomCtrl, decoration: const InputDecoration(labelText: 'Prénom')),
                const SizedBox(height: 8),
                TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom')),
                const SizedBox(height: 8),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Téléphone'), keyboardType: TextInputType.phone),
                const SizedBox(height: 8),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'E-mail'), keyboardType: TextInputType.emailAddress),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    AdaptiveOverlay.show(
      context: context,
      child: AdaptiveDialogContent(
        title: 'Se déconnecter',
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: FlexColors.error),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthService>().logout();
              if (context.mounted) {
                context.go('/auth');
              }
            },
            child: const Text('Se déconnecter', style: TextStyle(color: Colors.white)),
          ),
        ],
        child: const Text('Voulez-vous vraiment vous déconnecter ?'),
      ),
    );
  }
}

class _RoleActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RoleActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? FlexColors.neutral800 : Colors.white,
            borderRadius: BorderRadius.circular(FlexRadius.lg),
            border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
          ),
          child: Column(
            children: [
              Icon(icon, color: FlexColors.primary500, size: 22),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? FlexColors.neutral0 : FlexColors.neutral700,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        hoverColor: FlexColors.primary500.withOpacity(0.05),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: FlexColors.primary500.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: FlexColors.primary500, size: 20),
        ),
        title: Text(title,
            style: FlexTextStyles.label.copyWith(
              color: isDark ? FlexColors.neutral0 : FlexColors.neutral700,
              fontWeight: FontWeight.w600,
            )),
        subtitle: Text(subtitle,
            style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral400)),
        trailing: const Icon(Icons.chevron_right_rounded, color: FlexColors.neutral400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FlexRadius.md)),
      ),
    );
  }
}
