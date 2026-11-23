import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/adaptive_overlay.dart';
import '../../shared/widgets/adaptive_dialog_content.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Paramètres', style: FlexTextStyles.h3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(FlexSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apparence',
                style: FlexTextStyles.label.copyWith(
                  color: FlexColors.neutral500,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FlexSpacing.sm),
              _SettingsItem(
                title: 'Mode sombre',
                subtitle: 'Activer le thème sombre pour économiser la batterie',
                isDark: isDark,
                trailing: Switch.adaptive(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: FlexColors.primary500,
                ),
              ),
              const SizedBox(height: FlexSpacing.lg),
              Text(
                'Notifications',
                style: FlexTextStyles.label.copyWith(
                  color: FlexColors.neutral500,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FlexSpacing.sm),
              _SettingsItem(
                title: 'Notifications push',
                subtitle: 'Recevoir des alertes pour vos réservations',
                isDark: isDark,
                trailing: Switch.adaptive(
                  value: true,
                  onChanged: (value) {},
                  activeColor: FlexColors.primary500,
                ),
              ),
              _SettingsItem(
                title: 'E-mails marketing',
                subtitle: 'Recevoir nos meilleures offres par mail',
                isDark: isDark,
                trailing: Switch.adaptive(
                  value: false,
                  onChanged: (value) {},
                  activeColor: FlexColors.primary500,
                ),
              ),
              const SizedBox(height: FlexSpacing.lg),
              Text(
                'Sécurité & Confidentialité',
                style: FlexTextStyles.label.copyWith(
                  color: FlexColors.neutral500,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FlexSpacing.sm),
              _SettingsItem(
                title: 'Changer le mot de passe',
                isDark: isDark,
                onTap: () => _showChangePasswordDialog(context),
              ),
              _SettingsItem(
                title: 'Supprimer mon compte',
                isDark: isDark,
                textColor: FlexColors.error,
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    var saving = false;
    AdaptiveOverlay.show(
      context: context,
      child: StatefulBuilder(
        builder: (ctx, setState) {
          void submit() async {
            if (newPassCtrl.text.length < 6) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Mot de passe : 6 caractères minimum')));
              return;
            }
            setState(() => saving = true);
            try {
              await context.read<AuthService>().changePassword(
                oldPassword: oldPassCtrl.text,
                newPassword: newPassCtrl.text,
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Mot de passe mis à jour avec succès.')),
                );
              }
            } catch (e) {
              if (ctx.mounted) {
                setState(() => saving = false);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(ApiClient.errorMessage(e, fallback: 'Impossible de changer le mot de passe'))),
                );
              }
            }
          }

          return AdaptiveDialogContent(
            title: 'Changer le mot de passe',
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : submit,
                child: saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Valider'),
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: oldPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Ancien mot de passe')),
                const SizedBox(height: 8),
                TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Nouveau mot de passe (6+)')),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    AdaptiveOverlay.show(
      context: context,
      child: AdaptiveDialogContent(
        title: 'Supprimer mon compte',
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: FlexColors.error),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demande de suppression enregistrée.')),
              );
            },
            child: const Text('Confirmer la suppression', style: TextStyle(color: Colors.white)),
          ),
        ],
        child: const Text('Cette action est irréversible. Toutes vos données seront définitivement effacées.'),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isDark;
  final Widget? trailing;
  final Color? textColor;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.title,
    this.subtitle,
    required this.isDark,
    this.trailing,
    this.textColor,
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
        title: Text(
          title,
          style: FlexTextStyles.label.copyWith(
            color: textColor ?? (isDark ? FlexColors.neutral0 : FlexColors.neutral800),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500),
              )
            : null,
        trailing: trailing ?? (onTap != null ? Icon(
          Icons.chevron_right_rounded,
          color: isDark ? FlexColors.neutral600 : FlexColors.neutral300,
        ) : null),
        onTap: onTap,
      ),
    );
  }
}
