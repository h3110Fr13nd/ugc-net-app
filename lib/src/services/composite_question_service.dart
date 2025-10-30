import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/composite_question.dart';
import 'api_client.dart';

/// Service for managing composite questions via API
class CompositeQuestionService {
  final ApiClient _client;

  CompositeQuestionService(this._client);

  /// List questions with pagination and filters
  Future<List<CompositeQuestion>> listQuestions({
    int page = 1,
    int pageSize = 20,
    String? answerType,
    int? difficulty,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (answerType != null) 'answer_type': answerType,
      if (difficulty != null) 'difficulty': difficulty.toString(),
    };

    final uri = Uri.parse('${_client.baseUrl}/questions').replace(queryParameters: params);
    final response = await http.get(uri, headers: _client.defaultHeaders);

    print('DEBUG LIST: Response status: ${response.statusCode}');
    print('DEBUG LIST: Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('DEBUG LIST: Decoded data: $data');
        final questions = (data['questions'] as List<dynamic>)
            .map((q) => CompositeQuestion.fromJson(q as Map<String, dynamic>))
            .toList();
        return questions;
      } catch (e, stackTrace) {
        print('DEBUG LIST: Error parsing response: $e');
        print('DEBUG LIST: Stack trace: $stackTrace');
        rethrow;
      }
    } else {
      throw Exception('Failed to load questions: ${response.statusCode}');
    }
  }

  /// Get a single question by ID
  Future<CompositeQuestion> getQuestion(String questionId) async {
    final response = await _client.get('/questions/$questionId');

    print('DEBUG GET: Response status: ${response.statusCode}');
    print('DEBUG GET: Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final decoded = _client.decode(response.body);
        print('DEBUG GET: Decoded JSON: $decoded');
        return CompositeQuestion.fromJson(decoded);
      } catch (e, stackTrace) {
        print('DEBUG GET: Error parsing response: $e');
        print('DEBUG GET: Stack trace: $stackTrace');
        rethrow;
      }
    } else if (response.statusCode == 404) {
      throw Exception('Question not found');
    } else {
      throw Exception('Failed to load question: ${response.statusCode}');
    }
  }

  /// Create a new question
  Future<CompositeQuestion> createQuestion(CompositeQuestion question) async {
    final body = json.encode(_prepareQuestionForApi(question));
    print('DEBUG: Creating question with body: $body');
    
    final response = await _client.post(
      '/questions',
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('DEBUG: Response status: ${response.statusCode}');
    print('DEBUG: Response body: ${response.body}');

    if (response.statusCode == 201) {
      try {
        final decoded = _client.decode(response.body);
        print('DEBUG: Decoded JSON: $decoded');
        final options = decoded['options'] as List?;
        if (options != null && options.isNotEmpty) {
          print('DEBUG: JSON types - weight: ${options[0]['weight'].runtimeType}');
        } else {
          print('DEBUG: No options in response');
        }
        return CompositeQuestion.fromJson(decoded);
      } catch (e, stackTrace) {
        print('DEBUG: Error parsing response: $e');
        print('DEBUG: Stack trace: $stackTrace');
        rethrow;
      }
    } else {
      throw Exception('Failed to create question: ${response.statusCode} - ${response.body}');
    }
  }

  /// Update an existing question
  Future<CompositeQuestion> updateQuestion(String questionId, CompositeQuestion question) async {
    final body = json.encode(_prepareQuestionForApi(question));
    final response = await http.put(
      Uri.parse('${_client.baseUrl}/questions/$questionId'),
      headers: {
        ..._client.defaultHeaders,
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return CompositeQuestion.fromJson(_client.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Question not found');
    } else {
      throw Exception('Failed to update question: ${response.statusCode} - ${response.body}');
    }
  }

  /// Delete a question
  Future<void> deleteQuestion(String questionId) async {
    final response = await http.delete(
      Uri.parse('${_client.baseUrl}/questions/$questionId'),
      headers: _client.defaultHeaders,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete question: ${response.statusCode}');
    }
  }

  /// Prepare question data for API (convert to create/update format)
  Map<String, dynamic> _prepareQuestionForApi(CompositeQuestion question) {
    return {
      'title': question.title,
      'description': question.description,
      'answer_type': question.answerType.name,
      'scoring': question.scoring,
      'difficulty': question.difficulty,
      'estimated_time_seconds': question.estimatedTimeSeconds,
      'meta_data': question.metadata,
      'created_by': question.createdBy,
      'parts': question.parts.map((part) => {
        'index': part.index,
        'part_type': part.partType.name,
        'content': part.content,
        'content_json': part.contentJson,
        'media_id': part.mediaId,
        'meta_data': part.metadata,
      }).toList(),
      'options': question.options.map((option) => {
        'label': option.label,
        'index': option.index,
        'is_correct': option.isCorrect,
        'weight': option.weight,
        'meta_data': option.metadata,
        'parts': option.parts.map((part) => {
          'index': part.index,
          'part_type': part.partType.name,
          'content': part.content,
          'media_id': part.mediaId,
        }).toList(),
      }).toList(),
    };
  }

  /// Create a simple text-based question (helper)
  Future<CompositeQuestion> createSimpleTextQuestion({
    required String questionText,
    required List<String> optionTexts,
    required int correctOptionIndex,
    String? title,
    int? difficulty,
  }) async {
    final now = DateTime.now();
    
    final question = CompositeQuestion(
      id: '', // Will be assigned by server
      title: title,
      answerType: AnswerType.options,
      difficulty: difficulty,
      parts: [
        QuestionPart(
          id: '',
          questionId: '',
          index: 0,
          partType: PartType.text,
          content: questionText,
        ),
      ],
      options: optionTexts.asMap().entries.map((entry) {
        final index = entry.key;
        final text = entry.value;
        return QuestionOption(
          id: '',
          questionId: '',
          label: String.fromCharCode(65 + index), // A, B, C, D
          index: index,
          isCorrect: index == correctOptionIndex,
          parts: [
            OptionPart(
              id: '',
              optionId: '',
              index: 0,
              partType: PartType.text,
              content: text,
            ),
          ],
          createdAt: now,
          updatedAt: now,
        );
      }).toList(),
      createdAt: now,
      updatedAt: now,
    );

    return createQuestion(question);
  }
}
