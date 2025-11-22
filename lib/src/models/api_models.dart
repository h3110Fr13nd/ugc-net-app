// Simple DTOs mapped from backend Pydantic schemas.
// These are lightweight manual implementations (fromJson/toJson). For large projects
// consider generating models using `json_serializable` or codegen from OpenAPI.

class TaxonomyNode {
  final String id;
  final String name;
  final String nodeType;
  final String? parentId;
  final String? path;
  final Map<String, dynamic> metaData;

  TaxonomyNode({required this.id, required this.name, required this.nodeType, this.parentId, this.path, Map<String, dynamic>? metaData})
      : metaData = metaData ?? {};

  factory TaxonomyNode.fromJson(Map<String, dynamic> json) => TaxonomyNode(
        id: json['id'] as String,
        name: json['name'] as String,
        nodeType: json['node_type'] as String? ?? json['nodeType'] as String? ?? 'topic',
        parentId: json['parent_id'] as String?,
        path: json['path'] as String?,
        metaData: (json['meta_data'] as Map<String, dynamic>?) ?? {},
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'node_type': nodeType,
        'parent_id': parentId,
        'path': path,
        'meta_data': metaData,
      };
}

class MediaDto {
  final String id;
  final String url;
  final String storageKey;
  final String? mimeType;

  MediaDto({required this.id, required this.url, required this.storageKey, this.mimeType});

  factory MediaDto.fromJson(Map<String, dynamic> json) => MediaDto(
        id: json['id'].toString(),
        url: json['url'] as String,
        storageKey: json['storage_key'] as String,
        mimeType: json['mime_type'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'storage_key': storageKey,
        'mime_type': mimeType,
      };
}

class QuestionSummary {
  final String id;
  final String? title;
  final String answerType;
  final int? difficulty;

  QuestionSummary({required this.id, this.title, required this.answerType, this.difficulty});

  factory QuestionSummary.fromJson(Map<String, dynamic> json) => QuestionSummary(
        id: json['id'].toString(),
        title: json['title'] as String?,
        answerType: json['answer_type'] as String? ?? 'options',
        difficulty: json['difficulty'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'answer_type': answerType,
        'difficulty': difficulty,
      };
}

class QuizDto {
  final String id;
  final String title;
  final String status;

  QuizDto({required this.id, required this.title, required this.status});

  factory QuizDto.fromJson(Map<String, dynamic> json) => QuizDto(
        id: json['id'].toString(),
        title: json['title'] as String? ?? '',
        status: json['status'] as String? ?? 'draft',
      );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'status': status};
}

class QuizAttemptDto {
  final String id;
  final String quizId;
  final String? userId;
  final String status;
  final double? score;

  QuizAttemptDto({required this.id, required this.quizId, this.userId, required this.status, this.score});

  factory QuizAttemptDto.fromJson(Map<String, dynamic> json) => QuizAttemptDto(
        id: json['id'].toString(),
        quizId: json['quiz_id'].toString(),
        userId: json['user_id']?.toString(),
        status: json['status'] as String? ?? 'in_progress',
        score: (json['score'] != null) ? (json['score'] as num).toDouble() : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'quiz_id': quizId,
        'user_id': userId,
        'status': status,
        'score': score,
      };
}

class UserTaxonomyStatsDto {
  final String taxonomyId;
  final int questionsAttempted;
  final int questionsCorrect;
  final double averageScorePercent;

  UserTaxonomyStatsDto({required this.taxonomyId, required this.questionsAttempted, required this.questionsCorrect, required this.averageScorePercent});

  factory UserTaxonomyStatsDto.fromJson(Map<String, dynamic> json) => UserTaxonomyStatsDto(
        taxonomyId: json['taxonomy_id'].toString(),
        questionsAttempted: json['questions_attempted'] as int? ?? 0,
        questionsCorrect: json['questions_correct'] as int? ?? 0,
        averageScorePercent: (json['average_score_percent'] != null) ? (json['average_score_percent'] as num).toDouble() : 0.0,
      );

  Map<String, dynamic> toJson() => {
        'taxonomy_id': taxonomyId,
        'questions_attempted': questionsAttempted,
        'questions_correct': questionsCorrect,
        'average_score_percent': averageScorePercent,
      };
}
