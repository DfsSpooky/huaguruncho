class SpeciesModel {
  final String uuid;
  final String name;
  final String quechuaName;
  final String scientificName;
  final String category;
  final String categoryDisplay;
  final String altitudeRange;
  final String conservationStatus;
  final String conservationStatusDisplay;
  final bool isEndemic;
  final String? imageUrl;
  final String summary;
  final String ecologicalRole;
  final String conservationTip;
  final int order;

  const SpeciesModel({
    required this.uuid,
    required this.name,
    this.quechuaName = '',
    required this.scientificName,
    required this.category,
    this.categoryDisplay = '',
    this.altitudeRange = '',
    required this.conservationStatus,
    this.conservationStatusDisplay = '',
    this.isEndemic = false,
    this.imageUrl,
    required this.summary,
    this.ecologicalRole = '',
    this.conservationTip = '',
    this.order = 0,
  });

  factory SpeciesModel.fromJson(Map<String, dynamic> json) {
    return SpeciesModel(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quechuaName: json['quechua_name']?.toString() ?? '',
      scientificName: json['scientific_name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'flora',
      categoryDisplay: json['category_display']?.toString() ?? '',
      altitudeRange: json['altitude_range']?.toString() ?? '',
      conservationStatus: json['conservation_status']?.toString() ?? 'LC',
      conservationStatusDisplay: json['conservation_status_display']?.toString() ?? '',
      isEndemic: json['is_endemic'] == true,
      imageUrl: json['image_url']?.toString(),
      summary: json['summary']?.toString() ?? '',
      ecologicalRole: json['ecological_role']?.toString() ?? '',
      conservationTip: json['conservation_tip']?.toString() ?? '',
      order: json['order'] is int ? json['order'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'quechua_name': quechuaName,
      'scientific_name': scientificName,
      'category': category,
      'category_display': categoryDisplay,
      'altitude_range': altitudeRange,
      'conservation_status': conservationStatus,
      'conservation_status_display': conservationStatusDisplay,
      'is_endemic': isEndemic,
      'image_url': imageUrl,
      'summary': summary,
      'ecological_role': ecologicalRole,
      'conservation_tip': conservationTip,
      'order': order,
    };
  }
}
