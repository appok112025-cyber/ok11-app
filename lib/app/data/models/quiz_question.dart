class QuizQuestion {
  final String? quizId;
  final String question;
  final List<String> options;
  final String? selectedAnswer;

  QuizQuestion({
    this.quizId,
    required this.question,
    required this.options,
    this.selectedAnswer,
  });
}
