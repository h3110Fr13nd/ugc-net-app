import 'package:flutter/material.dart';
import 'page_template.dart';
import '../services/question_service.dart';
import '../models/composite_question.dart';
import 'question_detail_page.dart';

import '../widgets/taxonomy_filter_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _service = QuestionService();
  final _controllerDifficulty = TextEditingController();
  String? _answerType;
  String? _selectedTaxonomyId;
  var _isLoading = false;
  String? _error;
  List<CompositeQuestion> _results = [];

  Future<void> _doSearch() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _results = [];
    });
    try {
      final diff = int.tryParse(_controllerDifficulty.text);
      final items = await _service.searchQuestions(
        difficulty: diff,
        answerType: _answerType,
        taxonomyId: _selectedTaxonomyId,
        pageSize: 30,
      );
      setState(() => _results = items);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controllerDifficulty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Search & Browse',
      subtitle: 'Global search across resources with filters',
      children: [
        ExpansionTile(
          title: Text(_selectedTaxonomyId == null ? 'Filter by Topic' : 'Topic Selected'),
          subtitle: _selectedTaxonomyId == null ? null : const Text('Tap to change or clear'),
          children: [
            SizedBox(
              height: 300,
              child: TaxonomyFilterWidget(
                selectedTaxonomyId: _selectedTaxonomyId,
                onChanged: (id) {
                  setState(() => _selectedTaxonomyId = id);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: _controllerDifficulty, decoration: const InputDecoration(hintText: 'Difficulty (1-5)'))),
          const SizedBox(width: 8),
          DropdownButton<String?>(
            value: _answerType,
            hint: const Text('Answer type'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Any')),
              DropdownMenuItem(value: 'options', child: Text('Options')),
              DropdownMenuItem(value: 'text', child: Text('Text')),
              DropdownMenuItem(value: 'numeric', child: Text('Numeric')),
            ],
            onChanged: (v) => setState(() => _answerType = v),
          ),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: _doSearch, child: const Text('Search')),
        ]),
        const SizedBox(height: 12),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
        if (_error != null) Text('Error: $_error'),
        if (!_isLoading && _results.isEmpty) const Text('No results'),
        if (_results.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _results.length,
            itemBuilder: (context, idx) {
              final q = _results[idx];
              return Card(
                child: ListTile(
                  title: Text(q.title ?? q.combinedText),
                  subtitle: Text(q.metadata['topic']?.toString() ?? 'General'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => QuestionDetailPage(question: q))),
                ),
              );
            },
          ),
      ],
    );
  }
}
 
