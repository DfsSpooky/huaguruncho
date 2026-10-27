class CommunityServiceReviewModel {
  final String uuid;
  final String authorName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const CommunityServiceReviewModel({
    required this.uuid,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory CommunityServiceReviewModel.fromJson(Map<String, dynamic> json) {
    return CommunityServiceReviewModel(
      uuid: json['uuid']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? 'Turista Anónimo',
      rating: json['rating'] is int ? json['rating'] as int : int.tryParse(json['rating']?.toString() ?? '5') ?? 5,
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class CommunityServiceModel {
  final String uuid;
  final String name;
  final String category;
  final String categoryDisplay;
  final String contactPhone;
  final String whatsappNumber;
  final String locationAddress;
  final String priceRange;
  final String badgeText;
  final String experienceYears;
  final String servicesDescription;
  final String? imageUrl;
  final int order;
  final double averageRating;
  final int reviewsCount;
  final List<CommunityServiceReviewModel> reviews;

  const CommunityServiceModel({
    required this.uuid,
    required this.name,
    required this.category,
    this.categoryDisplay = '',
    this.contactPhone = '',
    this.whatsappNumber = '',
    this.locationAddress = '',
    this.priceRange = '',
    this.badgeText = '',
    this.experienceYears = '',
    required this.servicesDescription,
    this.imageUrl,
    this.order = 0,
    this.averageRating = 4.8,
    this.reviewsCount = 0,
    this.reviews = const [],
  });

  factory CommunityServiceModel.fromJson(Map<String, dynamic> json) {
    return CommunityServiceModel(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'guia',
      categoryDisplay: json['category_display']?.toString() ?? '',
      contactPhone: json['contact_phone']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString() ?? '',
      locationAddress: json['location_address']?.toString() ?? '',
      priceRange: json['price_range']?.toString() ?? '',
      badgeText: json['badge_text']?.toString() ?? '',
      experienceYears: json['experience_years']?.toString() ?? '',
      servicesDescription: json['services_description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      order: json['order'] is int ? json['order'] as int : 0,
      averageRating: json['average_rating'] != null ? (json['average_rating'] as num).toDouble() : 4.8,
      reviewsCount: json['reviews_count'] is int ? json['reviews_count'] as int : int.tryParse(json['reviews_count']?.toString() ?? '0') ?? 0,
      reviews: json['reviews'] is List
          ? (json['reviews'] as List).map((r) => CommunityServiceReviewModel.fromJson(r as Map<String, dynamic>)).toList()
          : const [],
    );
  }
}
