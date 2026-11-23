import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/flex_theme.dart';
import '../../services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

enum IdentityVerificationStatus { none, pending, verified, rejected }

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  IdentityVerificationStatus _status = IdentityVerificationStatus.none;
  File? _idCardImage;
  File? _birthCertificateImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      _status = IdentityVerificationStatus.values.firstWhere(
        (s) => s.name == user.verificationStatus.name,
        orElse: () => IdentityVerificationStatus.none,
      );
    }
  }

  Future<void> _pickImage(ImageSource source, {required Function(File?) setImage}) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        setImage(File(pickedFile.path));
      });
    }
  }

  bool _isSubmitting = false;

  Future<void> _submitForVerification() async {
    if (_idCardImage == null && _birthCertificateImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez télécharger au moins un document.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Note: In production, upload files to cloud storage and pass the URL.
      // For now, pass the local path as a placeholder identifier.
      await context.read<AuthService>().submitIdentity(
        idCardUrl: _idCardImage?.path ?? '',
        birthCertificateUrl: _birthCertificateImage?.path,
      );

      if (mounted) {
        setState(() {
          _status = IdentityVerificationStatus.pending;
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documents soumis — vérification en cours (24-48h)')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Vérification d\'identité', style: FlexTextStyles.h3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FlexSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pour des raisons de sécurité, veuillez vérifier votre identité.',
              style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
            ),
            const SizedBox(height: FlexSpacing.lg),

            _buildVerificationStatus(isDark),
            const SizedBox(height: FlexSpacing.xl),

            Text(
              'Téléchargez vos documents',
              style: FlexTextStyles.h3.copyWith(
                color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
              ),
            ),
            const SizedBox(height: FlexSpacing.md),

            _buildDocumentUploadCard(
              title: "Carte d'identité",
              image: _idCardImage,
              onPickImage: (file) => _pickImage(ImageSource.gallery, setImage: (f) => _idCardImage = f),
              onCaptureImage: (file) => _pickImage(ImageSource.camera, setImage: (f) => _idCardImage = f),
              isDark: isDark,
            ),
            const SizedBox(height: FlexSpacing.md),
            _buildDocumentUploadCard(
              title: "Acte de naissance",
              image: _birthCertificateImage,
              onPickImage: (file) => _pickImage(ImageSource.gallery, setImage: (f) => _birthCertificateImage = f),
              onCaptureImage: (file) => _pickImage(ImageSource.camera, setImage: (f) => _birthCertificateImage = f),
              isDark: isDark,
            ),
            const SizedBox(height: FlexSpacing.xl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_status == IdentityVerificationStatus.pending || _isSubmitting)
                    ? null
                    : _submitForVerification,
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Soumettre pour vérification'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStatus(bool isDark) {
    IconData icon;
    Color color;
    String message;

    switch (_status) {
      case IdentityVerificationStatus.none:
        icon = Icons.info_outline_rounded;
        color = FlexColors.info;
        message = "Votre identité n'a pas encore été vérifiée.";
        break;
      case IdentityVerificationStatus.pending:
        icon = Icons.pending_actions_rounded;
        color = FlexColors.warning;
        message = "Votre demande de vérification est en cours de traitement.";
        break;
      case IdentityVerificationStatus.verified:
        icon = Icons.check_circle_rounded;
        color = FlexColors.success;
        message = "Votre identité a été vérifiée avec succès !";
        break;
      case IdentityVerificationStatus.rejected:
        icon = Icons.error_outline_rounded;
        color = FlexColors.error;
        message = "Votre demande de vérification a été rejetée. Veuillez réessayer.";
        break;
    }

    return Container(
      padding: const EdgeInsets.all(FlexSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: FlexSpacing.md),
          Expanded(
            child: Text(
              message,
              style: FlexTextStyles.body.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required File? image,
    required Function(File?) onPickImage,
    required Function(File?) onCaptureImage,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(FlexSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(
          color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: FlexTextStyles.label.copyWith(
              color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FlexSpacing.sm),
          if (image != null) ...[
            Image.file(
              image,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: FlexSpacing.sm),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Choisir un fichier'),
                  onPressed: () => onPickImage(null),
                ),
              ),
              const SizedBox(width: FlexSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Prendre une photo'),
                  onPressed: () => onCaptureImage(null),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}
