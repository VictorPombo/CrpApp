import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/quiz_question.dart';
import '../../services/quiz_service.dart';
import '../../services/certificate_eligibility_service.dart';
import '../../widgets/certificate_eligibility_card.dart';

/// Tela de avaliação final do curso.
/// Usa CertificateEligibilityService para validar resultado.
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

class _QuizScreenState extends State<QuizScreen> {
  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  int? _selectedOption;
  bool _confirmed = false;
  final List<int> _userAnswers = [];
  QuizResult? _result;

  @override
  void initState() {
    super.initState();
    _questions = QuizService.getQuestionsForCourse(widget.courseId);
  }

  QuizQuestion get _currentQuestion => _questions[_currentIndex];
  bool get _isLastQuestion => _currentIndex == _questions.length - 1;

  void _confirmAnswer() {
    if (_selectedOption == null) return;
    setState(() {
      _confirmed = true;
      _userAnswers.add(_selectedOption!);
    });
  }

  void _nextQuestion() {
    if (_isLastQuestion) {
      _showResult();
    } else {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _confirmed = false;
      });
    }
  }

  void _showResult() {
    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i].correctIndex) correct++;
    }
    setState(() {
      _result = QuizResult(
        totalQuestions: _questions.length,
        correctAnswers: correct,
        userAnswers: List.from(_userAnswers),
      );
    });
  }

  void _retryQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedOption = null;
      _confirmed = false;
      _userAnswers.clear();
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) {
      return _buildResultScreen(context);
    }
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
      ),
      body: Column(
        children: [
          // Header com progresso
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.courseTitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Mínimo 70% para aprovação',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Pergunta ${_currentIndex + 1} de ${_questions.length}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '${((_currentIndex + 1) / _questions.length * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    backgroundColor:
                        isDark ? AppColors.darkDivider : Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),

          // Pergunta
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    _currentQuestion.question,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  // Opções
                  ...List.generate(4, (i) => _buildOption(i, isDark)),

                  // Explicação (após confirmar)
                  if (_confirmed &&
                      _currentQuestion.explanation != null) ...[
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
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  size: 18, color: AppColors.info),
                              SizedBox(width: 6),
                              Text('Explicação',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.info)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentQuestion.explanation!,
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
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
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
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
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
        ),
      ),
    );
  }

  Widget _buildOption(int index, bool isDark) {
    final isSelected = _selectedOption == index;
    final isCorrect = index == _currentQuestion.correctIndex;

    Color borderColor;
    Color bgColor;
    IconData? trailingIcon;

    if (!_confirmed) {
      // Antes de confirmar
      borderColor = isSelected
          ? AppColors.primary
          : (isDark ? AppColors.darkDivider : Colors.grey[300]!);
      bgColor = isSelected
          ? AppColors.primary.withValues(alpha: 0.08)
          : (isDark ? AppColors.darkCard : Colors.white);
      trailingIcon = null;
    } else {
      // Após confirmar
      if (isCorrect) {
        borderColor = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.08);
        trailingIcon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.08);
        trailingIcon = Icons.cancel;
      } else {
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
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              // Letra (A, B, C, D)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected && !_confirmed
                      ? AppColors.primary
                      : (isDark ? AppColors.darkDivider : Colors.grey[200]),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected && !_confirmed
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _currentQuestion.options[index],
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon,
                    size: 22,
                    color: isCorrect ? AppColors.success : AppColors.error),
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

    // Verificar elegibilidade do certificado
    final eligibility = CertificateEligibilityService.check(
      progressPercent: widget.progressPercent,
      quizScore: result.score,
      // Mock: considerar que o aluno tem CPF e empresa preenchidos
      userCpf: '123.456.789-00',
      userCompany: 'CRP Engenharia',
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
              width: 100,
              height: 100,
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
              result.approved
                  ? 'Parabéns! Você foi aprovado!'
                  : 'Não foi dessa vez...',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.courseTitle,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
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
                  Text(
                    '${result.correctAnswers}/${result.totalQuestions}',
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nota: ${result.score}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color:
                          result.approved ? AppColors.success : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Barra de progresso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: result.score / 100,
                      backgroundColor:
                          isDark ? AppColors.darkDivider : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        result.approved ? AppColors.success : AppColors.error,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0%',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[500])),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('70% mín.',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600)),
                      ),
                      Text('100%',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card de elegibilidade (se aprovado)
            if (result.approved)
              CertificateEligibilityCard(
                result: eligibility,
                onViewCertificate: eligibility.isEligible
                    ? () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      }
                    : null,
                onCompleteProfile: () {
                  Navigator.pop(context);
                },
              ),

            // Mensagem de reprovação
            if (!result.approved) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Você precisa de pelo menos 70% para ser aprovado.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Revise as aulas e tente novamente.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
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
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
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

  // Dialog de confirmação ao sair
  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da avaliação?'),
        content: const Text(
            'Seu progresso será perdido e você precisará recomeçar.'),
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
            child: const Text('Sair',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
