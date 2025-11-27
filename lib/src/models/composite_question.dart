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
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      storageKey: json['storage_key']?.toString() ?? '',
      mimeType: json['mime_type']?.toString(),
      width: _parseInt(json['width']),
      height: _parseInt(json['height']),
      sizeBytes: _parseInt(json['size_bytes']),
      checksum: json['checksum']?.toString(),
      metadata: (json['meta_data'] as Map<String, dynamic>?) ?? {},
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
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
      id: json['id']?.toString() ?? '',
      questionId: json['question_id']?.toString() ?? '',
      index: _parseInt(json['index']) ?? 0,
      partType: PartType.fromString(json['part_type']?.toString() ?? 'text'),
      content: json['content']?.toString(),
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
      id: json['id']?.toString() ?? '',
      optionId: json['option_id']?.toString() ?? '',
      index: _parseInt(json['index']) ?? 0,
      partType: PartType.fromString(json['part_type']?.toString() ?? 'text'),
      content: json['content']?.toString(),
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
    return QuestionOption(
      id: json['id']?.toString() ?? '',
      questionId: json['question_id']?.toString() ?? '',
      label: json['label']?.toString(),
      index: _parseInt(json['index']),
      isCorrect: json['is_correct'] == true,
      weight: _parseDouble(json['weight']) ?? 1.0,
      parts: (json['parts'] as List<dynamic>?)?.map((e) => OptionPart.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      metadata: (json['meta_data'] as Map<String, dynamic>?) ?? {},
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
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
  final String? explanation;
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
  final Map<String, dynamic>? userAttempt;

  CompositeQuestion({
    required this.id,
    this.canonicalId,
    this.title,
    this.description,
    this.explanation,
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
    this.userAttempt,
  })  : parts = parts ?? [],
        options = options ?? [],
        scoring = scoring ?? {},
        metadata = metadata ?? {};

  factory CompositeQuestion.fromJson(Map<String, dynamic> json) {
    // Handle explanation from different possible keys
    String? expl;
    if (json['explanation'] != null) {
      expl = json['explanation'].toString();
    } else if (json['question_explanation'] != null) {
      // Sometimes it comes as question_explanation in flat structures
      expl = json['question_explanation'].toString();
    }

    return CompositeQuestion(
      id: json['id']?.toString() ?? '',
      canonicalId: json['canonical_id']?.toString(),
      title: json['title']?.toString() ?? json['question_title']?.toString(),
      description: json['description']?.toString() ?? json['question_description']?.toString(),
      explanation: expl,
      answerType: AnswerType.fromString(json['answer_type']?.toString() ?? 'options'),
      scoring: (json['scoring'] as Map<String, dynamic>?) ?? {},
      difficulty: _parseInt(json['difficulty']),
      estimatedTimeSeconds: _parseInt(json['estimated_time_seconds']),
      parts: (json['parts'] as List<dynamic>?)?.map((e) => QuestionPart.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      options: (json['options'] as List<dynamic>?)?.map((e) => QuestionOption.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      metadata: (json['meta_data'] as Map<String, dynamic>?) ?? {},
      createdBy: json['created_by']?.toString(),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      userAttempt: json['user_attempt'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'canonical_id': canonicalId,
        'title': title,
        'description': description,
        'explanation': explanation,
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
        'user_attempt': userAttempt,
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
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Helper function to parse int from either string or number
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Parse a DateTime from JSON value, safely handling nulls and returning epoch
DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
  try {
    return DateTime.parse(value as String);
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
