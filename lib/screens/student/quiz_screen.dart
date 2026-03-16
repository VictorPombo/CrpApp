import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/quiz_question.dart';
import '../../services/quiz_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/certificate_eligibility_service.dart';
import '../../providers/auth_service.dart';
import '../../widgets/certificate_eligibility_card.dart';

/// Tela de avaliação final — SEGURANÇA: nunca recebe correctIndex.
/// A validação é feita internamente pelo QuizService.submitAnswers().
class QuizScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final double progressPercent;

  const QuizScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
    this.progressPercent = 1.0,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  int? _selectedOption;
  bool _confirmed = false;
  QuizResult? _result;

  // Respostas do usuário: questionId → selectedIndex (embaralhado)
  final Map<String, int> _userAnswers = {};

  // Feedback da questão atual (após confirmar)
  QuestionFeedback? _currentFeedback;

  // Cronômetro
  late Stopwatch _stopwatch;
  Timer? _timer;
  String _elapsedTime = '00:00';

  // Animação de transição entre perguntas
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _questions = QuizService.getQuestionsForCourse(widget.courseId);
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _result == null) {
        setState(() {
          final d = _stopwatch.elapsed;
          final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
          final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
          _elapsedTime = '$m:$s';
        });
      }
    });
    _slideController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _slideController.dispose();
    super.dispose();
  }

  QuizQuestion get _currentQuestion => _questions[_currentIndex];
  bool get _isLastQuestion => _currentIndex == _questions.length - 1;

  /// Confirmar resposta — envia APENAS esta questão para validação parcial
  void _confirmAnswer() {
    if (_selectedOption == null) return;
    _userAnswers[_currentQuestion.id] = _selectedOption!;

    // Validar TODAS as respostas até agora para obter feedback da atual
    final partialResult = QuizService.submitAnswers(
      courseId: widget.courseId,
      userAnswers: Map.from(_userAnswers),
      timeTaken: _stopwatch.elapsed,
    );

    final fb = partialResult.feedback.firstWhere(
      (f) => f.questionId == _currentQuestion.id,
      orElse: () => QuestionFeedback(
        questionId: _currentQuestion.id, isCorrect: false,
        userAnswer: _selectedOption!, explanation: '',
      ),
    );

    setState(() {
      _confirmed = true;
      _currentFeedback = fb;
    });

    // Re-carregar questões para a próxima validação (re-embaralhar mapping)
    if (!_isLastQuestion) {
      QuizService.getQuestionsForCourse(widget.courseId);
    }
  }

  void _nextQuestion() {
    if (_isLastQuestion) {
      _showResult();
    } else {
      _slideController.reset();
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _confirmed = false;
        _currentFeedback = null;
      });
      _slideController.forward();
    }
  }

  void _showResult() {
    _stopwatch.stop();
    // Submeter TODAS as respostas de uma vez para resultado final
    final result = QuizService.submitAnswers(
      courseId: widget.courseId,
      userAnswers: Map.from(_userAnswers),
      timeTaken: _stopwatch.elapsed,
    );

    // Salvar resultado no enrollment
    _saveResult(result);

    setState(() => _result = result);
  }

  Future<void> _saveResult(QuizResult result) async {
    await LocalStorageService.saveQuizResult(
      widget.courseId, result.score);
  }

  void _retryQuiz() {
    _userAnswers.clear();
    _stopwatch.reset();
    _stopwatch.start();
    _slideController.reset();
    setState(() {
      _questions = QuizService.getQuestionsForCourse(widget.courseId);
      _currentIndex = 0;
      _selectedOption = null;
      _confirmed = false;
      _currentFeedback = null;
      _result = null;
    });
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) return _buildResultScreen(context);
    return _buildQuestionScreen(context);
  }

  // ═══════════════════════════════════════
  // Tela de pergunta
  // ═══════════════════════════════════════
  Widget _buildQuestionScreen(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliação Final'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          // Cronômetro
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 4),
                Text(_elapsedTime, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                )),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com progresso
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.courseTitle,
                        style: TextStyle(fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    _buildDifficultyBadge(_currentQuestion.difficulty, isDark),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Mínimo 70% para aprovação',
                  style: TextStyle(fontSize: 12, color: AppColors.secondary,
                    fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Pergunta ${_currentIndex + 1} de ${_questions.length}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${((_currentIndex + 1) / _questions.length * 100).toInt()}%',
                      style: TextStyle(fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    backgroundColor: isDark ? AppColors.darkDivider : Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),

          // Pergunta com animação
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(_currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600, height: 1.4)),
                    const SizedBox(height: 20),
                    ...List.generate(4, (i) => _buildOption(i, isDark)),

                    // Explicação (após confirmar — vem do server, não do client)
                    if (_confirmed && _currentFeedback != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(Icons.lightbulb_outline,
                                size: 18, color: AppColors.info),
                              const SizedBox(width: 6),
                              Text('Explicação', style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: AppColors.info)),
                            ]),
                            const SizedBox(height: 8),
                            Text(_currentFeedback!.explanation,
                              style: TextStyle(fontSize: 13,
                                fontStyle: FontStyle.italic, height: 1.4,
                                color: isDark ? Colors.grey[300] : Colors.grey[700])),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Botão inferior
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _confirmed
              ? ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _isLastQuestion ? 'Ver resultado' : 'Próxima pergunta',
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
                )
              : ElevatedButton(
                  onPressed: _selectedOption != null ? _confirmAnswer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Confirmar resposta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(QuizDifficulty d, bool isDark) {
    final (label, color) = switch (d) {
      QuizDifficulty.easy => ('Fácil', AppColors.success),
      QuizDifficulty.medium => ('Médio', AppColors.secondary),
      QuizDifficulty.hard => ('Difícil', AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _buildOption(int index, bool isDark) {
    final isSelected = _selectedOption == index;

    Color borderColor;
    Color bgColor;
    IconData? trailingIcon;

    if (!_confirmed || _currentFeedback == null) {
      // Antes de confirmar — SEM GABARITO, só visual de seleção
      borderColor = isSelected
          ? AppColors.primary
          : (isDark ? AppColors.darkDivider : Colors.grey[300]!);
      bgColor = isSelected
          ? AppColors.primary.withValues(alpha: 0.08)
          : (isDark ? AppColors.darkCard : Colors.white);
      trailingIcon = null;
    } else {
      // Após confirmar — feedback do server (isCorrect), sem correctIndex
      final wasSelected = isSelected;
      final userWasCorrect = _currentFeedback!.isCorrect;

      if (wasSelected && userWasCorrect) {
        // Selecionou e acertou
        borderColor = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.08);
        trailingIcon = Icons.check_circle;
      } else if (wasSelected && !userWasCorrect) {
        // Selecionou e errou
        borderColor = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.08);
        trailingIcon = Icons.cancel;
      } else {
        // Não selecionada — sem destaque (não mostramos a resposta certa!)
        borderColor = isDark ? AppColors.darkDivider : Colors.grey[200]!;
        bgColor = isDark ? AppColors.darkCard : Colors.grey[50]!;
        trailingIcon = null;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: _confirmed ? null : () => setState(() => _selectedOption = index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected && !_confirmed
                      ? AppColors.primary
                      : (isDark ? AppColors.darkDivider : Colors.grey[200]),
                ),
                child: Center(
                  child: Text(String.fromCharCode(65 + index),
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: isSelected && !_confirmed
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    )),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(_currentQuestion.options[index],
                  style: TextStyle(fontSize: 14, height: 1.3,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal)),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 22,
                  color: _currentFeedback!.isCorrect && isSelected
                      ? AppColors.success : AppColors.error),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // Tela de resultado
  // ═══════════════════════════════════════
  Widget _buildResultScreen(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = _result!;

    final user = AuthService.currentUser;
    final eligibility = CertificateEligibilityService.check(
      progressPercent: widget.progressPercent,
      quizScore: result.score,
      userCpf: user.cpf,
      userCompany: user.company,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Ícone resultado
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (result.approved ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.12),
              ),
              child: Icon(
                result.approved
                    ? Icons.emoji_events_outlined
                    : Icons.sentiment_dissatisfied_outlined,
                size: 52,
                color: result.approved ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              result.approved ? 'Parabéns! Você foi aprovado!' : 'Não foi dessa vez...',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(widget.courseTitle,
              style: TextStyle(fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600]),
              textAlign: TextAlign.center),
            const SizedBox(height: 24),

            // Card de nota
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('${result.correctAnswers}/${result.totalQuestions}',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Nota: ${result.score}%',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                      color: result.approved ? AppColors.success : AppColors.error)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: result.score / 100,
                      backgroundColor: isDark ? AppColors.darkDivider : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        result.approved ? AppColors.success : AppColors.error),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0%', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('70% mín.',
                          style: TextStyle(fontSize: 10, color: AppColors.secondary,
                            fontWeight: FontWeight.w600)),
                      ),
                      Text('100%', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                  // Resumo por dificuldade
                  if (result.easyTotal > 0 || result.mediumTotal > 0 || result.hardTotal > 0) ...[
                    const SizedBox(height: 16),
                    Divider(color: isDark ? AppColors.darkDivider : Colors.grey[200]),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (result.easyTotal > 0)
                          _diffStat('Fácil', result.easyCorrect, result.easyTotal, AppColors.success),
                        if (result.mediumTotal > 0)
                          _diffStat('Médio', result.mediumCorrect, result.mediumTotal, AppColors.secondary),
                        if (result.hardTotal > 0)
                          _diffStat('Difícil', result.hardCorrect, result.hardTotal, AppColors.error),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text('Tempo: ${_elapsedTime}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Elegibilidade do certificado (se aprovado)
            if (result.approved)
              CertificateEligibilityCard(
                result: eligibility,
                onViewCertificate: eligibility.isEligible
                    ? () => context.push('/certificate/${widget.courseId}',
                        extra: {'quizScore': result.score,
                                'progressPercent': widget.progressPercent})
                    : null,
                onCompleteProfile: () => context.push('/profile/personal-data'),
              ),

            if (!result.approved) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Text('Você precisa de pelo menos 70% para ser aprovado.',
                      style: TextStyle(fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[700]),
                      textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text('Você pode tentar quantas vezes precisar.',
                      style: TextStyle(fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Botões
            if (!result.approved) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _retryQuiz,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Tentar novamente',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: result.approved
                  ? OutlinedButton(
                      onPressed: () => Navigator.pop(context, result),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Voltar ao curso',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    )
                  : TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Revisar aulas',
                        style: TextStyle(fontSize: 15)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _diffStat(String label, int correct, int total, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text('$correct/$total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
          color: correct == total ? AppColors.success : Colors.grey[600])),
      ],
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da avaliação?'),
        content: const Text('Seu progresso será perdido e você precisará recomeçar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Sair', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
