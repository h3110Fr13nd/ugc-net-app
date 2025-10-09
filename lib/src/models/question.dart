class Question {
  final int? id;
  final String text;
  final List<String> options;
  final String answer;
  final String topic;

  Question({this.id, required this.text, required this.options, required this.answer, required this.topic});

  factory Question.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    return Question(
      id: json['id'] as int?,
      text: json['text'] as String? ?? '',
      options: opts,
      answer: json['answer'] as String? ?? '',
      topic: json['topic'] as String? ?? 'General',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'options': options,
        'answer': answer,
        'topic': topic,
      };
}
