class CommunityPostModel {
  final String uuid;
  final String authorName;
  final String authorRole;
  final String category;
  final String categoryDisplay;
  final String locationName;
  final String content;
  final String? imageUrl;
  final int munayCount;
  final bool lntVerified;
  final bool isApproved;
  final DateTime? createdAt;

  const CommunityPostModel({
    required this.uuid,
    required this.authorName,
    this.authorRole = 'Centinela Ambiental',
    required this.category,
    this.categoryDisplay = '',
    required this.locationName,
    required this.content,
    this.imageUrl,
    this.munayCount = 0,
    this.lntVerified = true,
    this.isApproved = true,
    this.createdAt,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      uuid: json['uuid']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? '',
      authorRole: json['author_role']?.toString() ?? 'Centinela Ambiental',
      category: json['category']?.toString() ?? 'fotografia',
      categoryDisplay: json['category_display']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      munayCount: json['munay_count'] is int ? json['munay_count'] as int : 0,
      lntVerified: json['lnt_verified'] == true,
      isApproved: json['is_approved'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
