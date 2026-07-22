import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';

class AgentAuditScreen extends StatefulWidget {
  final String listingId;
  const AgentAuditScreen({super.key, required this.listingId});

  @override
  State<AgentAuditScreen> createState() => _AgentAuditScreenState();
}

class _AgentAuditScreenState extends State<AgentAuditScreen> {
  bool _serrure = false;
  bool _literie = false;
  bool _sanitaires = false;
  bool _eclairage = false;
  bool _identite = false;
  bool _photos = false;
  bool _adresse = false;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  int get _score {
    int s = 0;
    if (_serrure) s++;
    if (_literie) s++;
    if (_sanitaires) s++;
    if (_eclairage) s++;
    if (_identite) s++;
    if (_photos) s++;
    if (_adresse) s++;
    return s;
  }

  bool get _canCertify => _score == 7;

  Future<void> _submitAudit(CertificationStatus status) async {
    setState(() => _isSubmitting = true);
    // TODO: save to Firestore
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSubmitting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == CertificationStatus.certified
                ? '✅ Logement certifié Flex !'
                : '❌ Audit refusé.',
          ),
          backgroundColor: status == CertificationStatus.certified
              ? FlexColors.certified
              : FlexColors.error,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Terrain'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FlexSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score indicator
            Container(
              padding: const EdgeInsets.all(FlexSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _canCertify
                      ? [FlexColors.certified, Color(0xFF16A34A)]
                      : [FlexColors.primary500, FlexColors.primary600],
                ),
                borderRadius: BorderRadius.circular(FlexRadius.lg),
              ),
              child: Row(
                children: [
                  Icon(
                    _canCertify ? Icons.verified_rounded : Icons.shield_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: FlexSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _canCertify ? 'Prêt à certifier' : 'Audit en cours',
                        style: FlexTextStyles.h3.copyWith(color: Colors.white),
                      ),
                      Text(
                        '$_score/7 critères validés',
                        style: FlexTextStyles.body.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Progress ring
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _score / 7,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 4,
                        ),
                        Text(
                          '$_score',
                          style: FlexTextStyles.label.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FlexSpacing.lg),

            Text(
              'Checklist d\'audit',
              style: FlexTextStyles.h3.copyWith(
                color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
              ),
            ),
            const SizedBox(height: FlexSpacing.md),

            // Checklist items
            _CheckItem(
              label: 'Serrure fonctionnelle',
              subtitle: 'La porte ferme correctement à clé',
              icon: Icons.lock_rounded,
              value: _serrure,
              onChanged: (v) => setState(() => _serrure = v),
            ),
            _CheckItem(
              label: 'Literie propre',
              subtitle: 'Draps, oreillers et couvertures en bon état',
              icon: Icons.bed_rounded,
              value: _literie,
              onChanged: (v) => setState(() => _literie = v),
            ),
            _CheckItem(
              label: 'Sanitaires propres',
              subtitle: 'Toilettes, douche/lavabo en bon état',
              icon: Icons.bathroom_rounded,
              value: _sanitaires,
              onChanged: (v) => setState(() => _sanitaires = v),
            ),
            _CheckItem(
              label: 'Éclairage fonctionnel',
              subtitle: 'Ampoules et interrupteurs opérationnels',
              icon: Icons.light_mode_rounded,
              value: _eclairage,
              onChanged: (v) => setState(() => _eclairage = v),
            ),
            _CheckItem(
              label: 'Identité propriétaire vérifiée',
              subtitle: 'Pièce d\'identité valide présentée et vérifiée',
              icon: Icons.badge_rounded,
              value: _identite,
              onChanged: (v) => setState(() => _identite = v),
            ),
            _CheckItem(
              label: 'Photos fidèles à la réalité',
              subtitle: 'Les photos correspondent au logement réel',
              icon: Icons.photo_camera_rounded,
              value: _photos,
              onChanged: (v) => setState(() => _photos = v),
            ),
            _CheckItem(
              label: 'Adresse correcte',
              subtitle: 'L\'adresse sur l\'app correspond à la localisation',
              icon: Icons.location_on_rounded,
              value: _adresse,
              onChanged: (v) => setState(() => _adresse = v),
            ),

            const SizedBox(height: FlexSpacing.lg),
            Text(
              'Commentaires',
              style: FlexTextStyles.h3.copyWith(
                color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Observations particulières, recommandations...',
              ),
            ),
            const SizedBox(height: FlexSpacing.xl),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () => _submitAudit(CertificationStatus.rejected),
                    icon: const Icon(Icons.cancel_rounded),
                    label: const Text('Refuser'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FlexColors.error,
                      side: const BorderSide(color: FlexColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: FlexSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _canCertify && !_isSubmitting
                        ? () => _submitAudit(CertificationStatus.certified)
                        : null,
                    icon: const Icon(Icons.verified_rounded),
                    label: _isSubmitting
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Certifier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlexColors.certified,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FlexSpacing.xl),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(FlexSpacing.md),
        decoration: BoxDecoration(
          color: value
              ? FlexColors.certified.withOpacity(isDark ? 0.15 : 0.06)
              : isDark ? FlexColors.neutral800 : FlexColors.neutral0,
          borderRadius: BorderRadius.circular(FlexRadius.md),
          border: Border.all(
            color: value ? FlexColors.certified : isDark ? FlexColors.neutral700 : FlexColors.neutral200,
            width: value ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: value ? FlexColors.certified : FlexColors.neutral400),
            const SizedBox(width: FlexSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: FlexTextStyles.label.copyWith(
                      color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: value ? FlexColors.certified : Colors.transparent,
                border: Border.all(
                  color: value ? FlexColors.certified : FlexColors.neutral300,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
