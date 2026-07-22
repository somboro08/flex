import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Aide & Support', style: FlexTextStyles.h3),
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
              _SupportCard(
                isDark: isDark,
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Chat avec nous',
                subtitle: 'Discutez en direct avec un conseiller',
                onTap: () {},
              ),
              _SupportCard(
                isDark: isDark,
                icon: Icons.email_outlined,
                title: 'Envoyez un e-mail',
                subtitle: 'support@flex-app.com',
                onTap: () => _launchUrl('mailto:support@flex-app.com'),
              ),
              _SupportCard(
                isDark: isDark,
                icon: Icons.phone_outlined,
                title: 'Appelez-nous',
                subtitle: '+229 00 00 00 00',
                onTap: () => _launchUrl('tel:+22900000000'),
              ),
              const SizedBox(height: FlexSpacing.xl),
              Text(
                'Questions fréquentes',
                style: FlexTextStyles.label.copyWith(
                  color: FlexColors.neutral500,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FlexSpacing.md),
              _FaqItem(
                isDark: isDark,
                question: 'Comment réserver un logement ?',
                answer: 'Sélectionnez un logement, choisissez vos dates et cliquez sur Réserver.',
              ),
              _FaqItem(
                isDark: isDark,
                question: 'Quels sont les modes de paiement ?',
                answer: 'Nous acceptons les paiements par Mobile Money (CinetPay) et carte bancaire.',
              ),
              _FaqItem(
                isDark: isDark,
                question: 'Comment annuler ma réservation ?',
                answer: 'Allez dans "Mes réservations", sélectionnez la réservation et cliquez sur Annuler.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: FlexSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(FlexSpacing.md),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: FlexColors.primary500.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: FlexColors.primary500),
        ),
        title: Text(
          title,
          style: FlexTextStyles.label.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: FlexColors.neutral400),
        onTap: onTap,
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isDark;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: FlexSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(FlexRadius.md),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: FlexTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500),
            ),
          ),
        ],
      ),
    );
  }
}
