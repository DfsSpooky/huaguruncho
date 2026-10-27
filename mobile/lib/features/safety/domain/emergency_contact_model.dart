class EmergencyContactModel {
  final String uuid;
  final String title;
  final String shortPhone;
  final String fullNumber;
  final String description;
  final String icon;
  final int priorityOrder;

  const EmergencyContactModel({
    required this.uuid,
    required this.title,
    required this.shortPhone,
    this.fullNumber = '',
    required this.description,
    this.icon = 'local_police_rounded',
    this.priorityOrder = 1,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      uuid: json['uuid']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      shortPhone: json['short_phone']?.toString() ?? '105',
      fullNumber: json['full_number']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'local_police_rounded',
      priorityOrder: json['priority_order'] is int ? json['priority_order'] as int : 1,
    );
  }
}
