class CheckpointModel {
  final int? id;
  final String localUuid;
  final String? serverUuid;
  final String checkpointName;
  final String visitorName;
  final String documentType;
  final String documentNumber;
  final String phoneNumber;
  final int groupSize;
  final String routeName;
  final String? guideName;
  final DateTime entryDateTime;
  final String? entryRangerName;

  // Residuos entrada (Subida)
  final int plasticBottlesIn;
  final int cansIn;
  final int plasticWrappersIn;
  final int plasticBagsIn;
  final int batteriesIn;
  final int gasCanistersIn;
  final String? otherWasteDetailsIn;
  final int totalItemsIn;

  // Residuos salida (Bajada)
  final DateTime? exitDateTime;
  final String? exitRangerName;
  final int plasticBottlesOut;
  final int cansOut;
  final int plasticWrappersOut;
  final int plasticBagsOut;
  final int batteriesOut;
  final int gasCanistersOut;
  final int totalItemsOut;

  final String wasteComplianceStatus; // pending_checkout, compliant, extra_collected, infraction_missing
  final String status; // en_montana, completado, alerta_retraso
  final String? notes;

  final String syncStatus; // pending, syncing, synced, failed
  final String? syncError;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CheckpointModel({
    this.id,
    required this.localUuid,
    this.serverUuid,
    this.checkpointName = 'Garita de Control Huaguruncho - Abra Huachón',
    required this.visitorName,
    this.documentType = 'DNI',
    required this.documentNumber,
    this.phoneNumber = '',
    this.groupSize = 1,
    this.routeName = 'Nevado Huaguruncho - Ruta Glaciar',
    this.guideName,
    required this.entryDateTime,
    this.entryRangerName,
    this.plasticBottlesIn = 0,
    this.cansIn = 0,
    this.plasticWrappersIn = 0,
    this.plasticBagsIn = 0,
    this.batteriesIn = 0,
    this.gasCanistersIn = 0,
    this.otherWasteDetailsIn,
    this.totalItemsIn = 0,
    this.exitDateTime,
    this.exitRangerName,
    this.plasticBottlesOut = 0,
    this.cansOut = 0,
    this.plasticWrappersOut = 0,
    this.plasticBagsOut = 0,
    this.batteriesOut = 0,
    this.gasCanistersOut = 0,
    this.totalItemsOut = 0,
    this.wasteComplianceStatus = 'pending_checkout',
    this.status = 'en_montana',
    this.notes,
    this.syncStatus = 'pending',
    this.syncError,
    this.syncedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isInMountain => status == 'en_montana';
  bool get isCompleted => status == 'completado';
  bool get isSynced => syncStatus == 'synced';

  int get calculatedTotalIn =>
      plasticBottlesIn + cansIn + plasticWrappersIn + plasticBagsIn + batteriesIn + gasCanistersIn;

  int get calculatedTotalOut =>
      plasticBottlesOut + cansOut + plasticWrappersOut + plasticBagsOut + batteriesOut + gasCanistersOut;

  int get missingItems => totalItemsIn > totalItemsOut ? totalItemsIn - totalItemsOut : 0;
  int get extraItems => totalItemsOut > totalItemsIn ? totalItemsOut - totalItemsIn : 0;

  Map<String, dynamic> toSyncJson() => {
    'local_uuid': localUuid,
    'checkpoint_name': checkpointName,
    'visitor_name': visitorName,
    'document_type': documentType,
    'document_number': documentNumber,
    'phone': phoneNumber,
    'group_size': groupSize,
    'route_name': routeName,
    'guide_name': guideName ?? '',
    'entry_datetime': entryDateTime.toIso8601String(),
    'entry_ranger_name': entryRangerName ?? '',
    'plastic_bottles_in': plasticBottlesIn,
    'cans_in': cansIn,
    'plastic_wrappers_in': plasticWrappersIn,
    'plastic_bags_in': plasticBagsIn,
    'batteries_in': batteriesIn,
    'gas_canisters_in': gasCanistersIn,
    'other_waste_details_in': otherWasteDetailsIn ?? '',
    'total_items_in': totalItemsIn,
    if (exitDateTime != null) 'exit_datetime': exitDateTime!.toIso8601String(),
    if (exitRangerName != null) 'exit_ranger_name': exitRangerName,
    'plastic_bottles_out': plasticBottlesOut,
    'cans_out': cansOut,
    'plastic_wrappers_out': plasticWrappersOut,
    'plastic_bags_out': plasticBagsOut,
    'batteries_out': batteriesOut,
    'gas_canisters_out': gasCanistersOut,
    'total_items_out': totalItemsOut,
    'waste_compliance_status': wasteComplianceStatus,
    'status': status,
    'notes': notes ?? '',
  };
}
