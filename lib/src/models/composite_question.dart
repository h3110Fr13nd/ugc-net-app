/// Media model for images, diagrams, videos, etc.
class Media {
  final String id;
  final String url;
  final String storageKey;
  final String? mimeType;
  final int? width;
  final int? height;
  final int? sizeBytes;
  final String? checksum;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Media({
    required this.id,
    required this.url,
    required this.storageKey,
    this.mimeType,
    this.width,
    this.height,
    this.sizeBytes,
    this.checksum,
    Map<String, dynamic>? metadata,
    required this.createdAt,
    required this.updatedAt,
  }) : metadata = metadata ?? {};

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'].toString(),
      url: json['url'] as String,
      storageKey: json['storage_key'] as String,
      mimeType: json['mime_type'] as String?,
      width: _parseInt(json['width']),
      height: _parseInt(json['height']),
      sizeBytes: _parseInt(json['size_bytes']),
      checksum: json['checksum'] as String?,
      metadata: (json['meta_data'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'storage_key': storageKey,
        'mime_type': mimeType,
        'width': width,
        'height': height,
        'size_bytes': sizeBytes,
        'checksum': checksum,
        'meta_data': metadata,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

/// Part types for question and option parts
enum PartType {
  text,
  image,
  diagram,
  latex,
  code,
  audio,
  video,
  table;

  static PartType fromString(String value) {
    return PartType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PartType.text,
    );
  }
}

/// A part of a question (can be text, image, diagram, etc.)
class QuestionPart {
  final String id;
  final String questionId;
  final int index;
  final PartType partType;
  final String? content;
  final Map<String, dynamic>? contentJson;
  final String? mediaId;
  final Media? media;
  final Map<String, dynamic> metadata;

  QuestionPart({
    required this.id,
    required this.questionId,
    required this.index,
    required this.partType,
    this.content,
    this.contentJson,
    this.mediaId,
    this.media,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  factory QuestionPart.fromJson(Map<String, dynamic> json) {
    return QuestionPart(
      id: json['id'].toString(),
      questionId: json['question_id'].toString(),
      index: _parseInt(json['index']) ?? 0,
      partType: PartType.fromString(json['part_type'] as String),
      content: json['content'] as String?,
      contentJson: json['content_json'] as Map<String, dynamic>?,
      mediaId: json['media_id']?.toString(),
      media: json['media'] != null ? Media.fromJson(json['media'] as Map<String, dynamic>) : null,
      metadata: (json['meta_data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question_id': questionId,
        'index': index,
        'part_type': partType.name,
        'content': content,
        'content_json': contentJson,
        'media_id': mediaId,
        'media': media?.toJson(),
        'meta_data': metadata,
      };
}

/// A part of an option (similar to QuestionPart but for options)
class OptionPart {
  final String id;
  final String optionId;
  final int index;
  final PartType partType;
  final String? content;
  final String? mediaId;
  final Media? media;

  OptionPart({
    required this.id,
    required this.optionId,
    required this.index,
    required this.partType,
    this.content,
    this.mediaId,
    this.media,
  });

  factory OptionPart.fromJson(Map<String, dynamic> json) {
    return OptionPart(
      id: json['id'].toString(),
      optionId: json['option_id'].toString(),
      index: _parseInt(json['index']) ?? 0,
      partType: PartType.fromString(json['part_type'] as String),
      content: json['content'] as String?,
      mediaId: json['media_id']?.toString(),
      media: json['media'] != null ? Media.fromJson(json['media'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'option_id': optionId,
        'index': index,
        'part_type': partType.name,
        'content': content,
        'media_id': mediaId,
        'media': media?.toJson(),
      };
}

/// An option for a question (can have multiple parts)
class QuestionOption {
  final String id;
  final String questionId;
  final String? label;
  final int? index;
  final bool isCorrect;
  final double weight;
  final List<OptionPart> parts;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuestionOption({
    required this.id,
    required this.questionId,
    this.label,
    this.index,
    this.isCorrect = false,
    this.weight = 1.0,
    List<OptionPart>? parts,
    Map<String, dynamic>? metadata,
    required this.createdAt,
    required this.updatedAt,
  })  : parts = parts ?? [],
        metadata = metadata ?? {};

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    print('DEBUG QuestionOption.fromJson: $json');
    print('DEBUG weight value: ${json['weight']}, type: ${json['weight'].runtimeType}');
    
    return QuestionOption(
      id: json['id'].toString(),
      questionId: json['question_id'].toString(),
      label: json['label'] as String?,
      index: _parseInt(json['index']),
      isCorrect: json['is_correct'] as bool? ?? false,
      weight: _parseDouble(json['weight']) ?? 1.0,
      parts: (json['parts'] as List<dynamic>?)?.map((e) => OptionPart.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      metadata: (json['meta_data'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question_id': questionId,
        'label': label,
        'index': index,
        'is_correct': isCorrect,
        'weight': weight,
        'parts': parts.map((p) => p.toJson()).toList(),
        'meta_data': metadata,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

/// Answer type enumeration
enum AnswerType {
  options,
  text,
  numeric,
  integer,
  regex,
  file,
  composite;

  static AnswerType fromString(String value) {
    return AnswerType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AnswerType.options,
    );
  }
}

/// Composite question with parts and options
class CompositeQuestion {
  final String id;
  final String? canonicalId;
  final String? title;
  final String? description;
  final AnswerType answerType;
  final Map<String, dynamic> scoring;
  final int? difficulty;
  final int? estimatedTimeSeconds;
  final List<QuestionPart> parts;
  final List<QuestionOption> options;
  final Map<String, dynamic> metadata;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompositeQuestion({
    required this.id,
    this.canonicalId,
    this.title,
    this.description,
    this.answerType = AnswerType.options,
    Map<String, dynamic>? scoring,
    this.difficulty,
    this.estimatedTimeSeconds,
    List<QuestionPart>? parts,
    List<QuestionOption>? options,
    Map<String, dynamic>? metadata,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  })  : parts = parts ?? [],
        options = options ?? [],
        scoring = scoring ?? {},
        metadata = metadata ?? {};

  factory CompositeQuestion.fromJson(Map<String, dynamic> json) {
    return CompositeQuestion(
      id: json['id'].toString(),
      canonicalId: json['canonical_id']?.toString(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      answerType: AnswerType.fromString(json['answer_type'] as String? ?? 'options'),
      scoring: (json['scoring'] as Map<String, dynamic>?) ?? {},
      difficulty: _parseInt(json['difficulty']),
      estimatedTimeSeconds: _parseInt(json['estimated_time_seconds']),
      parts: (json['parts'] as List<dynamic>?)?.map((e) => QuestionPart.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      options: (json['options'] as List<dynamic>?)?.map((e) => QuestionOption.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      metadata: (json['meta_data'] as Map<String, dynamic>?) ?? {},
      createdBy: json['created_by']?.toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'canonical_id': canonicalId,
        'title': title,
        'description': description,
        'answer_type': answerType.name,
        'scoring': scoring,
        'difficulty': difficulty,
        'estimated_time_seconds': estimatedTimeSeconds,
        'parts': parts.map((p) => p.toJson()).toList(),
        'options': options.map((o) => o.toJson()).toList(),
        'meta_data': metadata,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Helper to get text representation of all parts combined
  String get combinedText {
    return parts.where((p) => p.partType == PartType.text && p.content != null).map((p) => p.content!).join('\n\n');
  }

  /// Helper to check if question has media parts
  bool get hasMedia {
    return parts.any((p) => p.partType != PartType.text);
  }
}

/// Helper function to parse double from either string or number
double? _parseDouble(dynamic value) {
  print('DEBUG _parseDouble: value=$value, type=${value.runtimeType}');
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    final result = double.tryParse(value);
    print('DEBUG _parseDouble: parsed string "$value" to $result');
    return result;
  }
  print('DEBUG _parseDouble: unexpected type ${value.runtimeType}');
  return null;
}

/// Helper function to parse int from either string or number
int? _parseInt(dynamic value) {
  print('DEBUG _parseInt: value=$value, type=${value.runtimeType}');
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) {
    final result = int.tryParse(value);
    print('DEBUG _parseInt: parsed string "$value" to $result');
    return result;
  }
  print('DEBUG _parseInt: unexpected type ${value.runtimeType}');
  return null;
}
