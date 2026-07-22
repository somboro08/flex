// ─────────────────────────────────────────────
//  USER MODEL
// ─────────────────────────────────────────────

enum UserRole { voyageur, hote, agent }
enum IdentityVerificationStatus { none, pending, verified, rejected } // New enum

class FlexUser {
  final String id;
  final String nom;
  final String prenom;
  final String telephone;
  final String? photoUrl;
  final UserRole role;
  final bool isVerified;
  final DateTime createdAt;
  final List<String> favorites; // New field
  final IdentityVerificationStatus verificationStatus; // New field
  final String? idCardUrl; // New field
  final String? birthCertificateUrl; // New field

  FlexUser({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    this.photoUrl,
    required this.role,
    this.isVerified = false,
    required this.createdAt,
    this.favorites = const [], // Initialize with an empty list
    this.verificationStatus = IdentityVerificationStatus.none, // Initialize
    this.idCardUrl,
    this.birthCertificateUrl,
  });

  String get fullName => '$prenom $nom';

  factory FlexUser.fromMap(Map<String, dynamic> map) {
    return FlexUser(
      id: map['id'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      telephone: map['telephone'] ?? '',
      photoUrl: map['photoUrl'],
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.voyageur,
      ),
      isVerified: map['isVerified'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      favorites: List<String>.from(map['favorites'] ?? []), // Handle favorites
      verificationStatus: IdentityVerificationStatus.values.firstWhere(
        (s) => s.name == map['verificationStatus'],
        orElse: () => IdentityVerificationStatus.none,
      ),
      idCardUrl: map['idCardUrl'],
      birthCertificateUrl: map['birthCertificateUrl'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'telephone': telephone,
    'photoUrl': photoUrl,
    'role': role.name,
    'isVerified': isVerified,
    'createdAt': createdAt.toIso8601String(),
    'favorites': favorites, // Add favorites to map
    'verificationStatus': verificationStatus.name,
    'idCardUrl': idCardUrl,
    'birthCertificateUrl': birthCertificateUrl,
  };
}

// ─────────────────────────────────────────────
//  LISTING MODEL
// ─────────────────────────────────────────────

enum CertificationStatus { pending, certified, rejected }

class Listing {
  final String id;
  final String hoteId;
  final String titre;
  final String description;
  final String ville;
  final String quartier;
  final String adresse;
  final double latitude;
  final double longitude;
  final double prixParNuit;
  final int nombreChambres;
  final List<String> photos;
  final List<String> equipements;
  final CertificationStatus certification;
  final double note;
  final int nombreAvis;
  final bool isDisponible;
  final DateTime createdAt;

  Listing({
    required this.id,
    required this.hoteId,
    required this.titre,
    required this.description,
    required this.ville,
    required this.quartier,
    required this.adresse,
    required this.latitude,
    required this.longitude,
    required this.prixParNuit,
    this.nombreChambres = 1,
    required this.photos,
    required this.equipements,
    this.certification = CertificationStatus.pending,
    this.note = 0.0,
    this.nombreAvis = 0,
    this.isDisponible = true,
    required this.createdAt,
  });

  bool get isCertified => certification == CertificationStatus.certified;

  factory Listing.fromMap(Map<String, dynamic> map) {
    return Listing(
      id: map['id'] ?? '',
      hoteId: map['hoteId'] ?? '',
      titre: map['titre'] ?? '',
      description: map['description'] ?? '',
      ville: map['ville'] ?? '',
      quartier: map['quartier'] ?? '',
      adresse: map['adresse'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      prixParNuit: (map['prixParNuit'] ?? 0.0).toDouble(),
      nombreChambres: map['nombreChambres'] ?? 1,
      photos: List<String>.from(map['photos'] ?? []),
      equipements: List<String>.from(map['equipements'] ?? []),
      certification: CertificationStatus.values.firstWhere(
        (s) => s.name == map['certification'],
        orElse: () => CertificationStatus.pending,
      ),
      note: (map['note'] ?? 0.0).toDouble(),
      nombreAvis: map['nombreAvis'] ?? 0,
      isDisponible: map['isDisponible'] ?? true,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'hoteId': hoteId,
    'titre': titre,
    'description': description,
    'ville': ville,
    'quartier': quartier,
    'adresse': adresse,
    'latitude': latitude,
    'longitude': longitude,
    'prixParNuit': prixParNuit,
    'nombreChambres': nombreChambres,
    'photos': photos,
    'equipements': equipements,
    'certification': certification.name,
    'note': note,
    'nombreAvis': nombreAvis,
    'isDisponible': isDisponible,
    'createdAt': createdAt.toIso8601String(),
  };
}

// ─────────────────────────────────────────────
//  BOOKING MODEL
// ─────────────────────────────────────────────

enum BookingStatus { pending, confirmed, checkedIn, completed, cancelled }

enum PaymentMethod { mtnMomo, moovMoney, wave, creditCard, cash, cinetpay }

class Booking {
  final String id;
  final String voyageurId;
  final String listingId;
  final String hoteId;
  final DateTime dateArrivee;
  final DateTime dateDepart;
  final int nombreNuits;
  final double montantTotal;
  final BookingStatus status;
  final PaymentMethod? paymentMethod;
  final bool isPaid;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.voyageurId,
    required this.listingId,
    required this.hoteId,
    required this.dateArrivee,
    required this.dateDepart,
    required this.nombreNuits,
    required this.montantTotal,
    this.status = BookingStatus.pending,
    this.paymentMethod,
    this.isPaid = false,
    required this.createdAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      voyageurId: map['voyageurId'] ?? '',
      listingId: map['listingId'] ?? '',
      hoteId: map['hoteId'] ?? '',
      dateArrivee: DateTime.tryParse(map['dateArrivee'] ?? '') ?? DateTime.now(),
      dateDepart: DateTime.tryParse(map['dateDepart'] ?? '') ?? DateTime.now(),
      nombreNuits: map['nombreNuits'] ?? 1,
      montantTotal: (map['montantTotal'] ?? 0.0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      paymentMethod: map['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (p) => p.name == map['paymentMethod'],
              orElse: () => PaymentMethod.cash,
            )
          : null,
      isPaid: map['isPaid'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'voyageurId': voyageurId,
    'listingId': listingId,
    'hoteId': hoteId,
    'dateArrivee': dateArrivee.toIso8601String(),
    'dateDepart': dateDepart.toIso8601String(),
    'nombreNuits': nombreNuits,
    'montantTotal': montantTotal,
    'status': status.name,
    'paymentMethod': paymentMethod?.name,
    'isPaid': isPaid,
    'createdAt': createdAt.toIso8601String(),
  };
}

// ─────────────────────────────────────────────
//  AUDIT MODEL (Agent Terrain)
// ─────────────────────────────────────────────

class AuditChecklist {
  final bool serrureFonctionnelle;
  final bool literiePrope;
  final bool sanitairesPropres;
  final bool eclairageFonctionnel;
  final bool identiteProprietaireVerifiee;
  final bool photosFideles;
  final bool adresseCorrecte;
  final String? commentaires;

  AuditChecklist({
    this.serrureFonctionnelle = false,
    this.literiePrope = false,
    this.sanitairesPropres = false,
    this.eclairageFonctionnel = false,
    this.identiteProprietaireVerifiee = false,
    this.photosFideles = false,
    this.adresseCorrecte = false,
    this.commentaires,
  });

  bool get isComplete =>
      serrureFonctionnelle &&
      literiePrope &&
      sanitairesPropres &&
      eclairageFonctionnel &&
      identiteProprietaireVerifiee &&
      photosFideles &&
      adresseCorrecte;

  int get score {
    int count = 0;
    if (serrureFonctionnelle) count++;
    if (literiePrope) count++;
    if (sanitairesPropres) count++;
    if (eclairageFonctionnel) count++;
    if (identiteProprietaireVerifiee) count++;
    if (photosFideles) count++;
    if (adresseCorrecte) count++;
    return count;
  }
}
