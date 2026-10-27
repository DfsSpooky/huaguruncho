class HotspotModel {
  final String uuid;
  final String title;
  final String content;
  final String type; // navigation, information, photo_poi, audio_guide, warning
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
    required this.title,
    required this.content,
    required this.type,
    required this.yaw,
    required this.pitch,
    this.targetYaw,
    this.targetPitch,
    this.targetSceneUuid,
    this.mediaImageUrl,
    this.audioUrl,
    required this.icon,
  });

  factory HotspotModel.fromJson(Map<String, dynamic> json) {
    return HotspotModel(
      uuid: json['uuid']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'navigation',
      yaw: _parseDouble(json['yaw']),
      pitch: _parseDouble(json['pitch']),
      targetYaw: _parseDoubleNullable(json['target_yaw']),
      targetPitch: _parseDoubleNullable(json['target_pitch']),
      targetSceneUuid: json['target_scene_uuid']?.toString(),
      mediaImageUrl: json['media_image_url']?.toString(),
      audioUrl: json['audio_url']?.toString(),
      icon: json['icon']?.toString() ?? 'arrow_forward',
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
    'title': title,
    'content': content,
    'type': type,
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
