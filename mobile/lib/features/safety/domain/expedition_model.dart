class ExpeditionModel {
  final String uuid;
  final String touristName;
  final String touristPhone;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String? routeId;
  final String routeName;
  final int groupSize;
  final String guideName;
  final DateTime departureDatetime;
  final DateTime expectedReturnDatetime;
  final DateTime? actualReturnDatetime;
  final String status;
  final String statusDisplay;
  final String healthNotes;
  final bool gearChecklistVerified;
  final String? adminNotes;

  const ExpeditionModel({
    required this.uuid,
    required this.touristName,
    required this.touristPhone,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    this.routeId,
    required this.routeName,
    required this.groupSize,
    required this.guideName,
    required this.departureDatetime,
    required this.expectedReturnDatetime,
    this.actualReturnDatetime,
    required this.status,
    required this.statusDisplay,
    required this.healthNotes,
    required this.gearChecklistVerified,
    this.adminNotes,
  });

  bool get isOngoing => status == 'en_curso';
  bool get isReturned => status == 'retornada';
  bool get isDelayed => status == 'retrasada' || (isOngoing && DateTime.now().isAfter(expectedReturnDatetime));

  factory ExpeditionModel.fromJson(Map<String, dynamic> json) {
    return ExpeditionModel(
      uuid: json['uuid'] ?? '',
      touristName: json['tourist_name'] ?? '',
      touristPhone: json['tourist_phone'] ?? '',
      emergencyContactName: json['emergency_contact_name'] ?? '',
      emergencyContactPhone: json['emergency_contact_phone'] ?? '',
      routeId: json['route']?.toString(),
      routeName: json['route_name'] ?? 'Ruta al Nevado Huaguruncho',
      groupSize: json['group_size'] is int ? json['group_size'] : int.tryParse(json['group_size']?.toString() ?? '1') ?? 1,
      guideName: json['guide_name'] ?? '',
      departureDatetime: DateTime.tryParse(json['departure_datetime'] ?? '') ?? DateTime.now(),
      expectedReturnDatetime: DateTime.tryParse(json['expected_return_datetime'] ?? '') ?? DateTime.now().add(const Duration(hours: 8)),
      actualReturnDatetime: json['actual_return_datetime'] != null ? DateTime.tryParse(json['actual_return_datetime']) : null,
      status: json['status'] ?? 'en_curso',
      statusDisplay: json['status_display'] ?? 'En Curso',
      healthNotes: json['health_notes'] ?? '',
      gearChecklistVerified: json['gear_checklist_verified'] ?? true,
      adminNotes: json['admin_notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tourist_name': touristName,
      'tourist_phone': touristPhone,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'group_size': groupSize,
      'guide_name': guideName,
      'departure_datetime': departureDatetime.toIso8601String(),
      'expected_return_datetime': expectedReturnDatetime.toIso8601String(),
      'health_notes': healthNotes,
      'gear_checklist_verified': gearChecklistVerified,
    };
  }
}
