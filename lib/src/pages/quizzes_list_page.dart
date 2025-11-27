import 'package:flutter/material.dart';
import 'page_template.dart';
import '../widgets/widgets.dart';
import '../services/quiz_service.dart';

class _QuizItem {
  final String id;
  final String title;
  final String description;

  _QuizItem(this.id, this.title, this.description);
}

class QuizzesListPage extends StatefulWidget {
  const QuizzesListPage({super.key});

  @override
  State<QuizzesListPage> createState() => _QuizzesListPageState();
}

class _QuizzesListPageState extends State<QuizzesListPage> {
  final QuizService _service = QuizService();
  bool _loading = true;
  List<_QuizItem> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final data = await _service.listQuizzes();
      _items = data.map((m) => _QuizItem(m['id']?.toString() ?? '', m['title'] ?? 'Untitled', m['description'] ?? '')).toList();
    } catch (_) {
      _items = [];
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Quizzes',
      subtitle: 'Browse, filter and manage quizzes',
      children: [
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_items.isEmpty)
          const Center(child: Text('No quizzes found'))
        else
          CardList(
            count: _items.length,
            itemBuilder: (context, idx) {
              final it = _items[idx];
              return ListTile(
                title: Text(it.title),
                subtitle: Text(it.description),
                trailing: IconButton(icon: const Icon(Icons.open_in_new), onPressed: () => Navigator.pushNamed(context, '/pages/quiz_detail')),
              );
            },
          ),
      ],
    );
  }
}
