import 'package:net_api/net_api.dart' as api;
import 'api_factory.dart';
import '../models/composite_question.dart';

/// QuestionService provides question fetching helpers.
/// - `listQuestions` returns raw API responses (useful for admin flows)
/// - `listQuestionsForTaxonomy` is a best-effort filter: it pages
///   questions and uses available metadata to prefer questions linked
///   to the given taxonomy id. This is a fallback until the API
///   exposes a server-side filter for taxonomy.
class QuestionService {
  final _api = ApiFactory.getNetApi().getQuestionsApi();


  // In-memory per-taxonomy cache. Keyed by taxonomyId.
  final Map<String, List<CompositeQuestion>> _taxonomyCache = {};
  // Track next page to fetch per taxonomy (1-based). If absent, page 1 is next.
  final Map<String, int> _taxonomyNextPage = {};
  // Track whether there are more pages available for a taxonomy.
  final Map<String, bool> _taxonomyHasMore = {};
  // Prevent concurrent loads per taxonomy.
  final Map<String, bool> _taxonomyLoading = {};

  Future<List<CompositeQuestion>> listQuestions({int page = 1, int pageSize = 20, String? status, bool randomize = false}) async {
    final resp = await _api.listQuestionsApiV1QuestionsGet(page: page, pageSize: pageSize, status: status, randomize: randomize);
    if (resp == null) return [];
    return resp.questions.map((q) => _mapApiToApp(q)).toList();
  }

  /// Deep copy helper for metadata maps to handle nested collections
  Map<String, dynamic> _deepCopyMetadata(Map<String, Object?> source) {
    final result = <String, dynamic>{};
    // Iterate over keys to avoid CastMap's casting behavior during iteration
    for (final key in source.keys) {
      // Access value directly by key, which doesn't trigger cast in CastMap
      final value = source[key];
      if (value == null) {
        result[key] = null;
      } else if (value is Map) {
        result[key] = Map<String, dynamic>.from(value);
      } else if (value is List) {
        result[key] = List<dynamic>.from(value);
      } else {
        result[key] = value;
      }
    }
    return result;
  }

  /// Map an API QuestionResponse into the app's CompositeQuestion model.
  CompositeQuestion _mapApiToApp(api.QuestionResponse src) {
    try {
    // Map Question Parts
    final qParts = <QuestionPart>[];
    if (src.parts.isNotEmpty) {
      final sorted = src.parts.toList()..sort((a, b) => a.index.compareTo(b.index));
      for (final p in sorted) {
        Media? media;
        if (p.media != null) {
          media = Media(
            id: p.media!.id,
            url: p.media!.url,
            storageKey: p.media!.storageKey,
            mimeType: p.media!.mimeType,
            width: p.media!.width,
            height: p.media!.height,
            sizeBytes: p.media!.sizeBytes,
            checksum: p.media!.checksum,
            metadata: _deepCopyMetadata(p.media!.metaData),
            createdAt: p.media!.createdAt,
            updatedAt: p.media!.updatedAt,
          );
        }

        qParts.add(QuestionPart(
          id: p.id,
          questionId: p.questionId,
          index: p.index,
          partType: PartType.fromString(p.partType),
          content: p.content,
          contentJson: p.contentJson != null ? _deepCopyMetadata(p.contentJson!) : null,
          mediaId: p.mediaId,
          media: media,
          metadata: _deepCopyMetadata(p.metaData),
        ));
      }
    } else {
      // Fallback to title/description if no parts
      final t = src.title ?? src.description ?? '';
      if (t.isNotEmpty) {
        qParts.add(QuestionPart(
          id: 'generated',
          questionId: src.id,
          index: 0,
          partType: PartType.text,
          content: t,
        ));
      }
    }

    // Map Options
    final options = <QuestionOption>[];
    final sortedOpts = src.options.toList()..sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));
    for (final o in sortedOpts) {
      final oParts = <OptionPart>[];
      if (o.parts.isNotEmpty) {
         final sortedOParts = o.parts.toList()..sort((a, b) => a.index.compareTo(b.index));
         for (final p in sortedOParts) {
           Media? media;
           if (p.media != null) {
             media = Media(
               id: p.media!.id,
               url: p.media!.url,
               storageKey: p.media!.storageKey,
               mimeType: p.media!.mimeType,
               width: p.media!.width,
               height: p.media!.height,
               sizeBytes: p.media!.sizeBytes,
               checksum: p.media!.checksum,
               metadata: _deepCopyMetadata(p.media!.metaData),
               createdAt: p.media!.createdAt,
               updatedAt: p.media!.updatedAt,
             );
           }

           oParts.add(OptionPart(
             id: p.id,
             optionId: p.optionId,
             index: p.index,
             partType: PartType.fromString(p.partType),
             content: p.content,
             mediaId: p.mediaId,
             media: media,
           ));
         }
      } else {
        // Fallback to label
        if (o.label != null) {
          oParts.add(OptionPart(
            id: 'generated',
            optionId: o.id,
            index: 0,
            partType: PartType.text,
            content: o.label,
          ));
        }
      }

      options.add(QuestionOption(
        id: o.id,
        questionId: o.questionId,
        label: o.label,
        index: o.index,
        isCorrect: o.isCorrect == true,
        weight: double.tryParse(o.weight) ?? 1.0,
        parts: oParts,
        metadata: _deepCopyMetadata(o.metaData),
        createdAt: o.createdAt,
        updatedAt: o.updatedAt,
      ));
    }

    final result = CompositeQuestion(
      id: src.id,
      title: src.title,
      description: src.description,
      // Default to options if not specified, or map from src if available (assuming src has answerType)
      // The generated API might not have answerType on QuestionResponse yet if it wasn't in the spec I saw.
      // Checking QuestionResponse definition... it doesn't seem to have answerType.
      // But CompositeQuestion needs it. Defaulting to options.
      answerType: AnswerType.options, 
      parts: qParts,
      options: options,
      metadata: _deepCopyMetadata(src.metaData),
      createdAt: src.createdAt,
      updatedAt: src.updatedAt,
    );
    return result;
    } catch (e, stackTrace) {
      print('ERROR in _mapApiToApp: $e');
      print('Stack trace: $stackTrace');
      print('Source metaData type: ${src.metaData.runtimeType}');
      print('Source metaData: ${src.metaData}');
      rethrow;
    }
  }

  /// Fetch a single page of questions for a given taxonomy id and map to app
  /// CompositeQuestion objects. This is useful for implementing UI-level pagination.
  Future<List<CompositeQuestion>> listQuestionsForTaxonomyPage(String taxonomyId, {int page = 1, int pageSize = 20}) async {
    final resp = await _api.listQuestionsApiV1QuestionsGet(
      page: page,
      pageSize: pageSize,
      taxonomyId: taxonomyId,
    );
    if (resp == null) return [];
    final items = resp.questions.toList();
    return items.map((q) => _mapApiToApp(q)).toList();
  }

  // Caching helpers
  List<CompositeQuestion>? getCachedQuestionsForTaxonomy(String taxonomyId) => _taxonomyCache[taxonomyId];

  /// Returns whether we believe there are more pages for this taxonomy.
  bool hasMoreCachedForTaxonomy(String taxonomyId) => _taxonomyHasMore[taxonomyId] ?? true;

  /// Clear cached entries for a taxonomy (useful for refresh).
  void clearTaxonomyCache(String taxonomyId) {
    _taxonomyCache.remove(taxonomyId);
    _taxonomyNextPage.remove(taxonomyId);
    _taxonomyHasMore.remove(taxonomyId);
    _taxonomyLoading.remove(taxonomyId);
  }

  /// Clear all taxonomy caches.
  void clearAllTaxonomyCache() {
    _taxonomyCache.clear();
    _taxonomyNextPage.clear();
    _taxonomyHasMore.clear();
    _taxonomyLoading.clear();
  }

  /// Load the next page for a taxonomy and append to the internal cache.
  /// Returns the newly fetched items. This is concurrency-safe per-taxonomy.
  Future<List<CompositeQuestion>> loadNextPageForTaxonomy(String taxonomyId, {int pageSize = 20}) async {
    if (_taxonomyLoading[taxonomyId] == true) return [];
    _taxonomyLoading[taxonomyId] = true;
    try {
      final nextPage = _taxonomyNextPage[taxonomyId] ?? 1;
      final items = await listQuestionsForTaxonomyPage(taxonomyId, page: nextPage, pageSize: pageSize);
      final existing = _taxonomyCache[taxonomyId] ?? <CompositeQuestion>[];
      existing.addAll(items);
      _taxonomyCache[taxonomyId] = existing;
      // Update next page
      _taxonomyNextPage[taxonomyId] = nextPage + 1;
      // If fewer items returned than pageSize, there's no more pages
      if (items.length < pageSize) {
        _taxonomyHasMore[taxonomyId] = false;
      } else {
        _taxonomyHasMore[taxonomyId] = true;
      }
      return items;
    } finally {
      _taxonomyLoading[taxonomyId] = false;
    }
  }

  /// Attempt to return questions for a given taxonomy node.
  ///
  /// This is a client-side best-effort implementation. It pages through
  /// server `listQuestions` results and inspects metadata where available
  /// to include only questions related to `taxonomyId`.
  Future<List<CompositeQuestion>> listQuestionsForTaxonomy(String taxonomyId,
      {int page = 1, int pageSize = 50, int maxResults = 50}) async {
    final out = <CompositeQuestion>[];
    var currentPage = page;

    while (out.length < maxResults) {
      // Call the server-side filter using taxonomyId. The generated client
      // now supports passing taxonomyId which maps to the `taxonomy_id`
      // query parameter on the backend.
      final resp = await _api.listQuestionsApiV1QuestionsGet(
        page: currentPage,
        pageSize: pageSize,
        taxonomyId: taxonomyId,
      );

      if (resp == null) break;
      final items = resp.questions.toList();
      if (items.isEmpty) break;

      for (final q in items) {
        out.add(_mapApiToApp(q));
        if (out.length >= maxResults) break;
      }

      // If the server returned fewer items than pageSize we've reached the end.
      if (items.length < pageSize) break;
      currentPage++;
    }

    return out;
  }

  /// Search questions by simple filters (difficulty, answerType, taxonomyId). Returns mapped app Questions.
  Future<List<CompositeQuestion>> searchQuestions({int? difficulty, String? answerType, String? taxonomyId, int page = 1, int pageSize = 20}) async {
    final resp = await _api.listQuestionsApiV1QuestionsGet(
      page: page,
      pageSize: pageSize,
      difficulty: difficulty,
      answerType: answerType,
      taxonomyId: taxonomyId,
    );
    if (resp == null) return [];
    final items = resp.questions.toList();
    return items.map((q) => _mapApiToApp(q)).toList();
  }
}

