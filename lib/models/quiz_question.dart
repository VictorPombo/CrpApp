import 'dart:math';

/// Modelo de questão para a avaliação final do curso.
/// SEGURANÇA: NÃO contém o gabarito (correctIndex).
/// O gabarito fica apenas no QuizService (server-side).
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options; // sempre 4, embaralhadas
  final QuizDifficulty difficulty;
  final String topic;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.difficulty,
    required this.topic,
  });
}

enum QuizDifficulty { easy, medium, hard }

/// Resultado de uma questão individual (retornado após validação server-side).
class QuestionFeedback {
  final String questionId;
  final bool isCorrect;
  final int userAnswer;
  final String explanation;

  const QuestionFeedback({
    required this.questionId,
    required this.isCorrect,
    required this.userAnswer,
    required this.explanation,
  });
}

/// Resultado completo da avaliação (retornado pelo QuizService.submitAnswers).
/// Contém feedback por questão MAS NÃO o correctIndex.
class QuizResult {
  final String courseId;
  final int totalQuestions;
  final int correctAnswers;
  final int score; // 0-100
  final bool approved; // score >= 70
  final DateTime completedAt;
  final Duration timeTaken;
  final List<QuestionFeedback> feedback;

  // Resumo por dificuldade
  final int easyCorrect;
  final int easyTotal;
  final int mediumCorrect;
  final int mediumTotal;
  final int hardCorrect;
  final int hardTotal;

  QuizResult({
    required this.courseId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.feedback,
    required this.timeTaken,
    this.easyCorrect = 0,
    this.easyTotal = 0,
    this.mediumCorrect = 0,
    this.mediumTotal = 0,
    this.hardCorrect = 0,
    this.hardTotal = 0,
    DateTime? completedAt,
  })  : score = totalQuestions > 0
            ? ((correctAnswers / totalQuestions) * 100).round()
            : 0,
        approved = totalQuestions > 0 &&
            ((correctAnswers / totalQuestions) * 100).round() >= 70,
        completedAt = completedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'course_id': courseId,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'score': score,
        'approved': approved,
        'completed_at': completedAt.toIso8601String(),
        'time_taken_seconds': timeTaken.inSeconds,
      };

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      courseId: json['course_id'] as String? ?? '',
      totalQuestions: json['total_questions'] as int? ?? 0,
      correctAnswers: json['correct_answers'] as int? ?? 0,
      feedback: [],
      timeTaken: Duration(seconds: json['time_taken_seconds'] as int? ?? 0),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }
}
