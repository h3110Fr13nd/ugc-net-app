import 'package:flutter/material.dart';
import '../models/composite_question.dart';
import '../widgets/composite_question_card.dart';

class QuestionDetailPage extends StatelessWidget {
  final CompositeQuestion question;
  const QuestionDetailPage({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: CompositeQuestionCard(question: question),
      ),
    );
  }
}
