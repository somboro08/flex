import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- USERS ---
  Future<void> saveUser(FlexUser user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<FlexUser?> getUser(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    return doc.exists ? FlexUser.fromMap(doc.data()!) : null;
  }

  // --- IDENTITY VERIFICATION ---
  Future<void> updateUserVerification(
    String userId,
    IdentityVerificationStatus status, {
    String? idCardUrl,
    String? birthCertificateUrl,
  }) async {
    Map<String, dynamic> updateData = {
      'verificationStatus': status.name,
    };
    if (idCardUrl != null) updateData['idCardUrl'] = idCardUrl;
    if (birthCertificateUrl != null) updateData['birthCertificateUrl'] = birthCertificateUrl;

    await _db.collection('users').doc(userId).update(updateData);
  }

  // --- FAVORITES ---
  Future<void> addFavorite(String userId, String listingId) async {
    await _db.collection('users').doc(userId).update({
      'favorites': FieldValue.arrayUnion([listingId]),
    });
  }

  Future<void> removeFavorite(String userId, String listingId) async {
    await _db.collection('users').doc(userId).update({
      'favorites': FieldValue.arrayRemove([listingId]),
    });
  }

  Stream<List<Listing>> getFavoriteListings(List<String> listingIds) {
    if (listingIds.isEmpty) {
      return Stream.value([]);
    }
    return _db
        .collection('listings')
        .where(FieldPath.documentId, whereIn: listingIds)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Listing.fromMap(doc.data())).toList());
  }

  // --- LISTINGS ---
  Stream<List<Listing>> getListings() {
    return _db.collection('listings').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Listing.fromMap(doc.data())).toList());
  }

  Future<void> addListing(Listing listing) async {
    await _db.collection('listings').doc(listing.id).set(listing.toMap());
  }

  // --- BOOKINGS ---
  Future<void> createBooking(Booking booking) async {
    await _db.collection('bookings').doc(booking.id).set(booking.toMap());
  }

  Stream<List<Booking>> getUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('voyageurId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromMap(doc.data())).toList());
  }
}
