import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

/// Represents a listing item stored in Firestore under items/{item_id}.
class ItemModel {
  final String id;
  final String title;
  final double price;
  final bool priceNegotiable;
  final String category;
  final String condition;
  final String? description;
  final List<String> imageUrls;
  final String? receiptImageUrl;
  final String status; // active | unlisted | sold
  final String sellerId;
  final String sellerName;
  final String whatsappContact;
  final String? city;
  final String? area;
  final double? latitude;
  final double? longitude;
  final int saveCount;
  final bool isPopular;
  final bool edited;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? listedAt;
  final DateTime? expiresAt;

  const ItemModel({
    required this.id,
    required this.title,
    required this.price,
    this.priceNegotiable = false,
    required this.category,
    required this.condition,
    this.description,
    required this.imageUrls,
    this.receiptImageUrl,
    required this.status,
    required this.sellerId,
    required this.sellerName,
    required this.whatsappContact,
    this.city,
    this.area,
    this.latitude,
    this.longitude,
    this.saveCount = 0,
    this.isPopular = false,
    this.edited = false,
    required this.createdAt,
    required this.updatedAt,
    this.listedAt,
    this.expiresAt,
  });

  /// Creates an ItemModel from a Firestore DocumentSnapshot.
  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      priceNegotiable: data['price_negotiable'] as bool? ?? false,
      category: data['category'] as String? ?? '',
      condition: data['condition'] as String? ?? '',
      description: data['description'] as String?,
      imageUrls: List<String>.from(data['image_urls'] as List? ?? []),
      receiptImageUrl: data['receipt_image_url'] as String?,
      status: data['status'] as String? ?? AppConstants.statusUnlisted,
      sellerId: data['seller_id'] as String? ?? '',
      sellerName: data['seller_name'] as String? ?? '',
      whatsappContact: data['whatsapp_contact'] as String? ?? '',
      city: data['city'] as String?,
      area: data['area'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      saveCount: data['save_count'] as int? ?? 0,
      isPopular: data['is_popular'] as bool? ?? false,
      edited: data['edited'] as bool? ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      listedAt: (data['listed_at'] as Timestamp?)?.toDate(),
      expiresAt: (data['expires_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts ItemModel to a Map for Firestore writes.
  Map<String, dynamic> toMap() => {
        'title': title,
        'price': price,
        'price_negotiable': priceNegotiable,
        'category': category,
        'condition': condition,
        'description': description,
        'image_urls': imageUrls,
        'receipt_image_url': receiptImageUrl,
        'status': status,
        'seller_id': sellerId,
        'seller_name': sellerName,
        'whatsapp_contact': whatsappContact,
        'city': city,
        'area': area,
        'latitude': latitude,
        'longitude': longitude,
        'save_count': saveCount,
        'is_popular': isPopular,
        'edited': edited,
        'created_at': Timestamp.fromDate(createdAt),
        'updated_at': Timestamp.fromDate(updatedAt),
        'listed_at': listedAt != null ? Timestamp.fromDate(listedAt!) : null,
        'expires_at': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      };

  /// Returns a copy with updated fields.
  ItemModel copyWith({
    double? price,
    bool? priceNegotiable,
    String? category,
    String? condition,
    String? description,
    List<String>? imageUrls,
    String? receiptImageUrl,
    String? status,
    String? whatsappContact,
    String? city,
    String? area,
    double? latitude,
    double? longitude,
    int? saveCount,
    bool? isPopular,
    bool? edited,
    DateTime? updatedAt,
    DateTime? listedAt,
    DateTime? expiresAt,
  }) =>
      ItemModel(
        id: id,
        title: title, // title is immutable after creation
        price: price ?? this.price,
        priceNegotiable: priceNegotiable ?? this.priceNegotiable,
        category: category ?? this.category,
        condition: condition ?? this.condition,
        description: description ?? this.description,
        imageUrls: imageUrls ?? this.imageUrls,
        receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
        status: status ?? this.status,
        sellerId: sellerId,
        sellerName: sellerName,
        whatsappContact: whatsappContact ?? this.whatsappContact,
        city: city ?? this.city,
        area: area ?? this.area,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        saveCount: saveCount ?? this.saveCount,
        isPopular: isPopular ?? this.isPopular,
        edited: edited ?? this.edited,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        listedAt: listedAt ?? this.listedAt,
        expiresAt: expiresAt ?? this.expiresAt,
      );

  // ── Computed Properties ───────────────────────────────────────────────────

  bool get isActive => status == AppConstants.statusActive;
  bool get isUnlisted => status == AppConstants.statusUnlisted;
  bool get isSold => status == AppConstants.statusSold;
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get hasDescription =>
      description != null && description!.isNotEmpty;
  bool get hasReceipt =>
      receiptImageUrl != null && receiptImageUrl!.isNotEmpty;

  /// The cover image — first image in the list.
  String? get coverImage => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Location display string e.g. "Yaba, Lagos"
  String get locationDisplay {
    if (area != null && city != null) return '$area, $city';
    if (city != null) return city!;
    return 'Location unknown';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ItemModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
