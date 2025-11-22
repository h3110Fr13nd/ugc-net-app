import '../models/taxonomy_node.dart';
import 'api_factory.dart';

/// Service to fetch taxonomy data from the backend and map it to
/// lightweight client models used by the UI.
class TaxonomyService {
  final _api = ApiFactory.getNetApi().getTaxonomyApi();

  /// Returns the taxonomy tree (top-level nodes with nested children).
  Future<List<TaxonomyNode>> getTaxonomyTree() async {
    final resp = await _api.getTaxonomyTreeApiV1TaxonomyTreeGet();
    final data = resp.data;
    if (data == null) return [];
    // `data` is a BuiltList<TaxonomyTreeResponse>
    return data.map((e) => TaxonomyNode.fromApi(e)).toList();
  }
}
