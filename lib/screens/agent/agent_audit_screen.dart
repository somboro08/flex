import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../repositories/audit_repository.dart';
import '../../services/api_client.dart';
import '../../shared/widgets/adaptive_overlay.dart';
import '../../shared/widgets/adaptive_dialog_content.dart';

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
  final List<File> _terrainPhotos = [];
  final List<String> _uploadedPhotoUrls = [];
  final _picker = ImagePicker();

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

  final _auditRepo = AuditRepository();

  Future<void> _pickTerrainPhoto() async {
    final source = await AdaptiveOverlay.show<ImageSource>(
      context: context,
      child: AdaptiveDialogContent(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Prendre une photo terrain'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    final file = File(picked.path);
    setState(() => _terrainPhotos.add(file));
    final url = await ApiClient().uploadFile(file);
    if (url != null) {
      setState(() => _uploadedPhotoUrls.add(url));
    }
  }

  Future<void> _submitAudit(CertificationStatus status) async {
    setState(() => _isSubmitting = true);
    try {
      final ok = await _auditRepo.createAudit(
        listingId: widget.listingId,
        serrure: _serrure,
        literie: _literie,
        sanitaires: _sanitaires,
        eclairage: _eclairage,
        identite: _identite,
        photosFideles: _photos,
        adresse: _adresse,
        commentaires: _commentController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (ok) {
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
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la soumission de l\'audit: $e'),
            backgroundColor: FlexColors.error,
          ),
        );
      }
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

            // — Photos terrain
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Photos terrain',
                  style: FlexTextStyles.h3.copyWith(
                    color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickTerrainPhoto,
                  icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_terrainPhotos.isEmpty)
              Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(FlexRadius.md),
                  color: isDark ? FlexColors.neutral800 : FlexColors.neutral50,
                ),
                child: const Center(
                  child: Text(
                    'Appuyez sur « Ajouter » pour photographier le logement',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: FlexColors.neutral400, fontSize: 12),
                  ),
                ),
              )
            else
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _terrainPhotos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _terrainPhotos[i],
                          width: 100, height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (i < _uploadedPhotoUrls.length)
                        Positioned(
                          bottom: 4, right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: FlexColors.certified,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.cloud_done, size: 12, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
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
