class OfflinePackageModel {
  final String packageUuid;
  final String routeUuid;
  final int version;
  final int sizeBytes;
  final bool isPublished;
  final Map<String, dynamic> manifest;

  const OfflinePackageModel({
    required this.packageUuid,
    required this.routeUuid,
    required this.version,
    required this.sizeBytes,
    required this.isPublished,
    required this.manifest,
  });

  factory OfflinePackageModel.fromJson(Map<String, dynamic> json) {
    return OfflinePackageModel(
      packageUuid: json['package_uuid'] as String? ?? '',
      routeUuid: json['route_uuid'] as String? ?? '',
      version: json['version'] as int? ?? 1,
      sizeBytes: json['size_bytes'] as int? ?? 0,
      isPublished: json['is_published'] as bool? ?? true,
      manifest: json['manifest'] as Map<String, dynamic>? ?? {},
    );
  }

  String get formattedSize {
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
