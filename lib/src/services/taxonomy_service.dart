import '../models/taxonomy_node.dart';
import 'api_factory.dart';

/// Service to fetch taxonomy data from the backend and map it to
/// lightweight client models used by the UI.
class TaxonomyService {
  final _api = ApiFactory.getStatsApi();

  /// Returns the taxonomy tree (top-level nodes with nested children).
  Future<List<TaxonomyNode>> getTaxonomyTree() async {
    try {
      final resp = await _api.getMyTaxonomyTreeApiV1StatsMeTaxonomyTreeGet();
      if (resp == null) return [];
      return resp.map((e) => TaxonomyNode.fromApi(e)).toList();
    } catch (e) {
      // Fallback or rethrow? For now, let's return empty or rethrow.
      // If unauthenticated, this will fail.
      print('Error fetching taxonomy stats: $e');
      return [];
    }
  }
}
