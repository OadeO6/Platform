import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a Platform user stored in Firestore under users/{user_id}.
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? whatsappContact;
  final String? photoUrl;
  final String? city;
  final String? area;
  final double? latitude;
  final double? longitude;
  final DateTime memberSince;
  final int listingCount;
  final int spaceCount;
  final String? fcmToken;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.whatsappContact,
    this.photoUrl,
    this.city,
    this.area,
    this.latitude,
    this.longitude,
    required this.memberSince,
    this.listingCount = 0,
    this.spaceCount = 0,
    this.fcmToken,
  });

  /// Creates a UserModel from a Firestore DocumentSnapshot.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['display_name'] as String? ?? '',
      whatsappContact: data['whatsapp_contact'] as String?,
      photoUrl: data['photo_url'] as String?,
      city: data['city'] as String?,
      area: data['area'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      memberSince: (data['member_since'] as Timestamp?)?.toDate() ?? DateTime.now(),
      listingCount: data['listing_count'] as int? ?? 0,
      spaceCount: data['space_count'] as int? ?? 0,
      fcmToken: data['fcm_token'] as String?,
    );
  }

  /// Converts UserModel to a Map for Firestore writes.
  Map<String, dynamic> toMap() => {
        'email': email,
        'display_name': displayName,
        'whatsapp_contact': whatsappContact,
        'photo_url': photoUrl,
        'city': city,
        'area': area,
        'latitude': latitude,
        'longitude': longitude,
        'member_since': Timestamp.fromDate(memberSince),
        'listing_count': listingCount,
        'space_count': spaceCount,
        'fcm_token': fcmToken,
      };

  /// Returns a copy of this UserModel with updated fields.
  UserModel copyWith({
    String? displayName,
    String? whatsappContact,
    String? photoUrl,
    String? city,
    String? area,
    double? latitude,
    double? longitude,
    int? listingCount,
    int? spaceCount,
    String? fcmToken,
  }) =>
      UserModel(
        id: id,
        email: email,
        displayName: displayName ?? this.displayName,
        whatsappContact: whatsappContact ?? this.whatsappContact,
        photoUrl: photoUrl ?? this.photoUrl,
        city: city ?? this.city,
        area: area ?? this.area,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        memberSince: memberSince,
        listingCount: listingCount ?? this.listingCount,
        spaceCount: spaceCount ?? this.spaceCount,
        fcmToken: fcmToken ?? this.fcmToken,
      );

  /// Returns true if the user has a WhatsApp number set.
  bool get hasWhatsApp =>
      whatsappContact != null && whatsappContact!.isNotEmpty;

  /// Returns true if the user has a profile photo.
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  /// Returns true if the user has a known location.
  bool get hasLocation => city != null && city!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
