class AudioGuideModel {
  final String uuid;
  final String titleEs;
  final String titleQu;
  final String category;
  final String categoryDisplay;
  final String locationName;
  final String durationFormatted;
  final String? audioFileUrl;
  final String transcriptEs;
  final String transcriptQu;
  final String didacticGlossary;
  final int order;

  const AudioGuideModel({
    required this.uuid,
    required this.titleEs,
    this.titleQu = '',
    required this.category,
    this.categoryDisplay = '',
    required this.locationName,
    this.durationFormatted = '3:30 min',
    this.audioFileUrl,
    required this.transcriptEs,
    this.transcriptQu = '',
    this.didacticGlossary = '',
    this.order = 0,
  });

  factory AudioGuideModel.fromJson(Map<String, dynamic> json) {
    return AudioGuideModel(
      uuid: json['uuid']?.toString() ?? '',
      titleEs: json['title_es']?.toString() ?? '',
      titleQu: json['title_qu']?.toString() ?? '',
      category: json['category']?.toString() ?? 'mitologia',
      categoryDisplay: json['category_display']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      durationFormatted: json['duration_formatted']?.toString() ?? '3:30 min',
      audioFileUrl: json['audio_file_url']?.toString(),
      transcriptEs: json['transcript_es']?.toString() ?? '',
      transcriptQu: json['transcript_qu']?.toString() ?? '',
      didacticGlossary: json['didactic_glossary']?.toString() ?? '',
      order: json['order'] is int ? json['order'] as int : 0,
    );
  }
}
