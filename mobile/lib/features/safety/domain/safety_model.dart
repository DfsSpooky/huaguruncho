class SafetyModel {
  final int id;
  final String category;
  final String categoryDisplay;
  final String title;
  final String description;
  final int order;
  final bool isChecked;

  const SafetyModel({
    required this.id,
    required this.category,
    required this.categoryDisplay,
    required this.title,
    required this.description,
    required this.order,
    this.isChecked = false,
  });

  factory SafetyModel.fromJson(Map<String, dynamic> json, {bool isChecked = false}) {
    return SafetyModel(
      id: json['id'] as int? ?? 0,
      category: json['category'] as String? ?? 'seguridad',
      categoryDisplay: json['category_display'] as String? ?? 'Seguridad',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      isChecked: isChecked,
    );
  }

  SafetyModel copyWith({bool? isChecked}) {
    return SafetyModel(
      id: id,
      category: category,
      categoryDisplay: categoryDisplay,
      title: title,
      description: description,
      order: order,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
