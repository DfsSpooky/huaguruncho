class GuardianBadgeModel {
  final String uuid;
  final String slug;
  final String title;
  final String quechuaTitle;
  final String description;
  final String tier;
  final String tierDisplay;
  final String icon;
  final int xpPoints;
  final int order;
  final bool isUnlocked;

  const GuardianBadgeModel({
    required this.uuid,
    required this.slug,
    required this.title,
    required this.quechuaTitle,
    required this.description,
    required this.tier,
    required this.tierDisplay,
    required this.icon,
    required this.xpPoints,
    required this.order,
    this.isUnlocked = true,
  });

  factory GuardianBadgeModel.fromJson(Map<String, dynamic> json) {
    return GuardianBadgeModel(
      uuid: json['uuid'] ?? '',
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      quechuaTitle: json['quechua_title'] ?? '',
      description: json['description'] ?? '',
      tier: json['tier'] ?? 'bronce',
      tierDisplay: json['tier_display'] ?? 'Bronce',
      icon: json['icon'] ?? 'military_tech',
      xpPoints: json['xp_points'] ?? 50,
      order: json['order'] ?? 1,
      isUnlocked: true,
    );
  }
}

class TrailPassportStampModel {
  final String uuid;
  final String name;
  final String quechuaName;
  final int altitudeMasl;
  final String landmarkIcon;
  final String secretCode;
  final int order;
  final bool isCollected;
  final double? latitude;
  final double? longitude;

  const TrailPassportStampModel({
    required this.uuid,
    required this.name,
    required this.quechuaName,
    required this.altitudeMasl,
    required this.landmarkIcon,
    required this.secretCode,
    required this.order,
    this.isCollected = false,
    this.latitude,
    this.longitude,
  });

  TrailPassportStampModel copyWith({
    bool? isCollected,
  }) {
    return TrailPassportStampModel(
      uuid: uuid,
      name: name,
      quechuaName: quechuaName,
      altitudeMasl: altitudeMasl,
      landmarkIcon: landmarkIcon,
      secretCode: secretCode,
      order: order,
      isCollected: isCollected ?? this.isCollected,
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory TrailPassportStampModel.fromJson(Map<String, dynamic> json) {
    return TrailPassportStampModel(
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      quechuaName: json['quechua_name'] ?? '',
      altitudeMasl: json['altitude_masl'] ?? 3400,
      landmarkIcon: json['landmark_icon'] ?? 'landscape',
      secretCode: json['secret_code'] ?? '',
      order: json['order'] ?? 1,
      isCollected: json['is_collected'] ?? false,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }
}
