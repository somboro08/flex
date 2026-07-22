import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../theme/theme_provider.dart';
import 'package:provider/provider.dart';

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
                onTap: () {},
              ),
              _SettingsItem(
                title: 'Supprimer mon compte',
                isDark: isDark,
                textColor: FlexColors.error,
                onTap: () {},
              ),
            ],
          ),
        ),
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
