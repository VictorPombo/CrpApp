/// Modelo de questão para a avaliação final do curso.
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options; // sempre 4 opções
  final int correctIndex; // índice da resposta correta (0-3)
  final String? explanation; // explicação exibida após responder

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });
}

/// Resultado da avaliação final.
class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int score; // 0-100
  final DateTime completedAt;
  final List<int> userAnswers; // índices das respostas do aluno

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.userAnswers,
    DateTime? completedAt,
  })  : score = totalQuestions > 0
            ? ((correctAnswers / totalQuestions) * 100).round()
            : 0,
        completedAt = completedAt ?? DateTime.now();

  bool get approved => score >= 70;
}
