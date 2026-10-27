class MunicipalNoticeModel {
  final String uuid;
  final String title;
  final String subtitle;
  final String category;
  final String categoryDisplay;
  final String priority;
  final String priorityDisplay;
  final String department;
  final String icon;
  final String? imageUrl;
  final String fullText;
  final String recommendations;
  final String publishedAt;

  const MunicipalNoticeModel({
    required this.uuid,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.categoryDisplay,
    required this.priority,
    required this.priorityDisplay,
    required this.department,
    required this.icon,
    this.imageUrl,
    required this.fullText,
    required this.recommendations,
    required this.publishedAt,
  });

  factory MunicipalNoticeModel.fromJson(Map<String, dynamic> json) {
    return MunicipalNoticeModel(
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      category: json['category'] ?? 'comunal',
      categoryDisplay: json['category_display'] ?? 'Actividad Comunal',
      priority: json['priority'] ?? 'informativo',
      priorityDisplay: json['priority_display'] ?? 'Informativo',
      department: json['department'] ?? 'Municipalidad Distrital de Huachón',
      icon: json['icon'] ?? 'info_outline',
      imageUrl: json['image_url'],
      fullText: json['full_text'] ?? '',
      recommendations: json['recommendations'] ?? '',
      publishedAt: json['published_at'] ?? '',
    );
  }

  bool get isUrgent => priority.toLowerCase() == 'urgente';
}
