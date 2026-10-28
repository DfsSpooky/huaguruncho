class HotspotModel {
  final String uuid;
  final String? sourceSceneUuid;
  final String title;
  final String content;
  final String type; // navigation, information, photo_poi, audio_guide, warning
  final String? typeDisplay;
  final double yaw;
  final double pitch;
  final double? targetYaw;
  final double? targetPitch;
  final String? targetSceneUuid;
  final String? mediaImageUrl;
  final String? audioUrl;
  final String icon;

  const HotspotModel({
    required this.uuid,
    this.sourceSceneUuid,
    required this.title,
    required this.content,
    required this.type,
    this.typeDisplay,
    required this.yaw,
    required this.pitch,
    this.targetYaw,
    this.targetPitch,
    this.targetSceneUuid,
    this.mediaImageUrl,
    this.audioUrl,
    required this.icon,
  });

  bool get hasPhoto => mediaImageUrl != null && mediaImageUrl!.trim().isNotEmpty;
  bool get hasAudio => audioUrl != null && audioUrl!.trim().isNotEmpty;
  bool get isNavigation =>
      type == 'navigation' &&
      targetSceneUuid != null &&
      targetSceneUuid!.isNotEmpty &&
      targetSceneUuid != sourceSceneUuid;

  factory HotspotModel.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? 'navigation';
    String defaultIcon = 'arrow_forward';
    if (type == 'photo_poi') {
      defaultIcon = 'photo_camera';
    } else if (type == 'audio_guide') {
      defaultIcon = 'headphones';
    } else if (type == 'warning') {
      defaultIcon = 'warning';
    } else if (type == 'information') {
      defaultIcon = 'info';
    }

    return HotspotModel(
      uuid: json['uuid']?.toString() ?? '',
      sourceSceneUuid: json['source_scene_uuid']?.toString(),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: type,
      typeDisplay: json['type_display']?.toString(),
      yaw: _parseDouble(json['yaw']),
      pitch: _parseDouble(json['pitch']),
      targetYaw: _parseDoubleNullable(json['target_yaw']),
      targetPitch: _parseDoubleNullable(json['target_pitch']),
      targetSceneUuid: json['target_scene_uuid']?.toString(),
      mediaImageUrl: json['media_image_url']?.toString(),
      audioUrl: json['audio_url']?.toString(),
      icon: (json['icon'] != null && json['icon'].toString().isNotEmpty)
          ? json['icon'].toString()
          : defaultIcon,
    );
  }

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  static double? _parseDoubleNullable(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'source_scene_uuid': sourceSceneUuid,
        'title': title,
        'content': content,
        'type': type,
        'type_display': typeDisplay,
        'yaw': yaw,
        'pitch': pitch,
        'target_yaw': targetYaw,
        'target_pitch': targetPitch,
        'target_scene_uuid': targetSceneUuid,
        'media_image_url': mediaImageUrl,
        'audio_url': audioUrl,
        'icon': icon,
      };
}
