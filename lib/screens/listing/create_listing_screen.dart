import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../repositories/listing_repository.dart';
import '../../core/responsive/content_container.dart';
import '../../shared/widgets/adaptive_overlay.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _listingRepo = ListingRepository();
  bool _isSubmitting = false;
  int _currentStep = 0;

  // Controllers
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _quartierCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _chambresCtrl = TextEditingController(text: '1');
  final _latitudeCtrl = TextEditingController();
  final _longitudeCtrl = TextEditingController();

  String _typeLogement = 'chambre';
  final List<String> _selectedEquipements = [];
  final List<XFile> _selectedImages = [];

  static const _types = ['chambre', 'studio', 'appartement', 'villa', 'maison', 'cohabitation', 'espace', 'club', 'autre'];
  static const _equipements = [
    'WiFi', 'Climatisation', 'Ventilateur', 'Eau chaude', 'Eau courante',
    'Cuisine', 'Parking', 'Sécurité 24h', 'Jardin', 'Piscine',
    'Petit-déjeuner', 'Ménage', 'Télévision', 'Réfrigérateur',
  ];

  @override
  void dispose() {
    _titreCtrl.dispose(); _descCtrl.dispose(); _villeCtrl.dispose();
    _quartierCtrl.dispose(); _adresseCtrl.dispose(); _prixCtrl.dispose();
    _chambresCtrl.dispose();
    _latitudeCtrl.dispose(); _longitudeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _openMapPicker() async {
    LatLng selectedLocation = const LatLng(9.337, 2.628); // Parakou by default
    if (_latitudeCtrl.text.isNotEmpty && _longitudeCtrl.text.isNotEmpty) {
      final lat = double.tryParse(_latitudeCtrl.text);
      final lng = double.tryParse(_longitudeCtrl.text);
      if (lat != null && lng != null) {
        selectedLocation = LatLng(lat, lng);
      }
    }

    final result = await AdaptiveOverlay.show<LatLng>(
      context: context,
      child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: FlexColors.neutral200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sélectionner la position', style: FlexTextStyles.h3),
                    IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    return FlutterMap(
                      options: MapOptions(
                        initialCenter: selectedLocation,
                        initialZoom: 13,
                        onTap: (tapPosition, point) {
                          setModalState(() {
                            selectedLocation = point;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.flex.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: selectedLocation,
                              width: 40,
                              height: 40,
                              child: const Icon(LucideIcons.mapPin, color: FlexColors.primary500, size: 40),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, selectedLocation),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlexColors.primary500,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Confirmer la position'),
                ),
              ),
            ],
          ),
      ),
    );

    if (result != null) {
      setState(() {
        _latitudeCtrl.text = result.latitude.toString();
        _longitudeCtrl.text = result.longitude.toString();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = AuthService();
    if (!auth.isLoggedIn || (auth.currentUser?.role != UserRole.hote && auth.currentUser?.role != UserRole.agent)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devenez propriétaire pour publier un logement')),
      );
      context.push('/auth');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      List<String> uploadedPhotoUrls = [];
      
      // Upload images first
      if (_selectedImages.isNotEmpty) {
        for (var imageFile in _selectedImages) {
          final url = await ApiClient().uploadXFile(imageFile);
          if (url != null) {
            uploadedPhotoUrls.add(url);
          }
        }
      }

      final listing = await _listingRepo.createListing({
        'titre': _titreCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'typeLogement': _typeLogement,
        'ville': _villeCtrl.text.trim(),
        'quartier': _quartierCtrl.text.trim(),
        'adresse': _adresseCtrl.text.trim(),
        'latitude': double.tryParse(_latitudeCtrl.text.trim()) ?? 0.0,
        'longitude': double.tryParse(_longitudeCtrl.text.trim()) ?? 0.0,
        'prixParNuit': double.tryParse(_prixCtrl.text.trim()) ?? 0,
        'nombreChambres': int.tryParse(_chambresCtrl.text.trim()) ?? 1,
        'equipements': _selectedEquipements,
        'photos': uploadedPhotoUrls,
      });

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (listing != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Logement publié avec succès !'),
              backgroundColor: FlexColors.success,
            ),
          );
          Navigator.pop(context, listing);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible de créer le logement. Veuillez réessayer.'),
              backgroundColor: FlexColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ApiClient.errorMessage(e)),
            backgroundColor: FlexColors.error,
            duration: const Duration(seconds: 4),
          ),
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
        title: const Text('Publier un logement', style: FlexTextStyles.h3),
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AdaptiveContentContainer(
        child: Form(
          key: _formKey,
          child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _submit();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlexColors.primary500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSubmitting && _currentStep == 2
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_currentStep < 2 ? 'Suivant' : 'Publier', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Retour'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Informations de base'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildStep1(isDark),
            ),
            Step(
              title: const Text('Localisation & Prix'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildStep2(isDark),
            ),
            Step(
              title: const Text('Équipements & Photos'),
              isActive: _currentStep >= 2,
              state: StepState.indexed,
              content: _buildStep3(isDark),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titreCtrl,
          decoration: const InputDecoration(labelText: 'Titre du logement *', hintText: 'Ex: Studio meublé Centre-ville'),
          validator: (v) => v == null || v.isEmpty ? 'Le titre est requis' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descCtrl,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Description *', hintText: 'Décrivez votre logement...'),
          validator: (v) => v == null || v.isEmpty ? 'La description est requise' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _typeLogement,
          decoration: const InputDecoration(labelText: 'Type de logement *'),
          items: _types.map((t) => DropdownMenuItem(value: t, child: Text(_capitalize(t)))).toList(),
          onChanged: (v) => setState(() => _typeLogement = v!),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _chambresCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Nombre de chambres *'),
          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
        ),
      ],
    );
  }

  Widget _buildStep2(bool isDark) {
    return Column(
      children: [
        TextFormField(
          controller: _villeCtrl,
          decoration: const InputDecoration(labelText: 'Ville *', hintText: 'Ex: Parakou'),
          validator: (v) => v == null || v.isEmpty ? 'La ville est requise' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _quartierCtrl,
          decoration: const InputDecoration(labelText: 'Quartier', hintText: 'Ex: Zongo'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _adresseCtrl,
          decoration: const InputDecoration(labelText: 'Adresse complète', hintText: 'Rue, numéro...'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _prixCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Prix par nuit (FCFA) *',
            prefixText: 'FCFA ',
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Le prix est requis';
            if (double.tryParse(v) == null) return 'Entrez un montant valide';
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _latitudeCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Latitude *', hintText: 'Ex: 9.337'),
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val == 0) return 'Requis';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _longitudeCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Longitude *', hintText: 'Ex: 2.628'),
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val == 0) return 'Requis';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _openMapPicker,
          icon: const Icon(LucideIcons.map),
          label: const Text('Sélectionner sur la carte'),
          style: ElevatedButton.styleFrom(
            backgroundColor: FlexColors.neutral100,
            foregroundColor: FlexColors.primary500,
            elevation: 0,
            side: const BorderSide(color: FlexColors.primary500),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Équipements disponibles', style: FlexTextStyles.label.copyWith(
          color: isDark ? FlexColors.neutral200 : FlexColors.neutral700,
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _equipements.map((eq) {
            final sel = _selectedEquipements.contains(eq);
            return GestureDetector(
              onTap: () => setState(() {
                if (sel) _selectedEquipements.remove(eq); else _selectedEquipements.add(eq);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? FlexColors.primary500 : Colors.transparent,
                  borderRadius: BorderRadius.circular(FlexRadius.full),
                  border: Border.all(color: sel ? FlexColors.primary500 : FlexColors.neutral300),
                ),
                child: Text(eq, style: TextStyle(
                  fontSize: 12,
                  color: sel ? Colors.white : (isDark ? FlexColors.neutral300 : FlexColors.neutral600),
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                )),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text('Photos', style: FlexTextStyles.label.copyWith(
          color: isDark ? FlexColors.neutral200 : FlexColors.neutral700,
        )),
        const SizedBox(height: 8),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8, top: 8),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: kIsWeb ? NetworkImage(_selectedImages[index].path) as ImageProvider : FileImage(File(_selectedImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.x, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(LucideIcons.imagePlus),
          label: const Text('Ajouter des photos'),
          style: ElevatedButton.styleFrom(
            backgroundColor: FlexColors.neutral100,
            foregroundColor: FlexColors.primary500,
            elevation: 0,
            side: const BorderSide(color: FlexColors.primary500),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: FlexColors.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: FlexColors.info.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: FlexColors.info),
              SizedBox(width: 8),
              Expanded(child: Text(
                'Votre logement sera soumis à un audit de certification Flex avant d\'être visible publiquement.',
                style: TextStyle(fontSize: 12, color: FlexColors.info),
              )),
            ],
          ),
        ),
      ],
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
