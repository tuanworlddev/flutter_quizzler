class Question {
  final String title;
  final bool answer;
  final String? explanation;

  const Question({
    required this.title,
    required this.answer,
    this.explanation,
  });
}