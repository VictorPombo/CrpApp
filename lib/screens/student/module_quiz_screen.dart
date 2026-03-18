import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/supabase_content_service.dart';

/// Tela de quiz por módulo — 5 opções, dados do Supabase.
class ModuleQuizScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const ModuleQuizScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<ModuleQuizScreen> createState() => _ModuleQuizScreenState();
}

class _ModuleQuizScreenState extends State<ModuleQuizScreen> {
  bool _loading = true;
  Map<String, dynamic>? _quiz;
  List<Map<String, dynamic>> _questions = [];
  final Map<String, String> _answers = {};
  bool _submitted = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    debugPrint('\n🧩 _loadQuiz START — moduleId=${widget.moduleId}');
    try {
      final fullQuiz = await SupabaseContentService.getFullModuleQuiz(widget.moduleId);
      debugPrint('🧩 getFullModuleQuiz result: ${fullQuiz != null ? "FOUND — title: ${fullQuiz['title']}, questions: ${(fullQuiz['questions'] as List?)?.length ?? 0}" : "NULL (not found)"}');
      if (mounted) {
        setState(() {
          _quiz = fullQuiz;
          _questions = List<Map<String, dynamic>>.from(fullQuiz?['questions'] ?? []);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('🧩 _loadQuiz EXCEPTION: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitQuiz() async {
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Responda todas as questões antes de enviar.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await SupabaseContentService.submitQuizAttempt(
      quizId: _quiz!['id'].toString(),
      answers: _answers,
      passingScore: _quiz!['passing_score'] as int? ?? 70,
    );

    if (mounted) {
      setState(() {
        _result = result;
        _submitted = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.moduleTitle, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _quiz == null
              ? _buildNoQuiz(isDark)
              : _submitted
                  ? _buildResult(isDark)
                  : _buildQuiz(isDark),
      bottomNavigationBar: !_submitted && !_loading && _quiz != null
          ? _buildSubmitButton(isDark)
          : null,
    );
  }

  Widget _buildNoQuiz(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64,
              color: isDark ? Colors.white24 : Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Quiz não disponível para este módulo',
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    final allAnswered = _answers.length >= _questions.length;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.grey[200]!)),
        ),
        child: ElevatedButton(
          onPressed: allAnswered ? _submitQuiz : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: isDark ? Colors.white12 : Colors.grey[300],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            allAnswered ? 'Enviar respostas' : '${_answers.length}/${_questions.length} respondidas',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(bool isDark) {
    final score = _result?['score'] as int? ?? 0;
    final passed = _result?['passed'] as bool? ?? false;
    final correct = _result?['correct_count'] as int? ?? 0;
    final total = _result?['total_questions'] as int? ?? _questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(children: [
            // Score card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: passed
                      ? [const Color(0xFF00B894), const Color(0xFF00CEC9)]
                      : [const Color(0xFFE17055), const Color(0xFFD63031)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                  color: (passed ? const Color(0xFF00B894) : const Color(0xFFE17055))
                      .withValues(alpha: 0.3),
                  blurRadius: 20, offset: const Offset(0, 8),
                )],
              ),
              child: Column(children: [
                Icon(passed ? Icons.emoji_events_rounded : Icons.refresh_rounded,
                    size: 56, color: Colors.white),
                const SizedBox(height: 12),
                Text(passed ? 'Aprovado!' : 'Tente novamente',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('$score%', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 4),
                Text('$correct de $total corretas',
                    style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.9))),
              ]),
            ),
            const SizedBox(height: 24),

            // Answers review
            ...List.generate(_questions.length, (i) {
              final q = _questions[i];
              final qId = q['id'].toString();
              final userAns = _answers[qId];
              final correctAns = q['correct_option'] as String;
              final isCorrect = userAns == correctAns;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isCorrect ? const Color(0xFF00B894) : const Color(0xFFE17055))
                        .withValues(alpha: 0.4), width: 1.5),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? const Color(0xFF00B894) : const Color(0xFFE17055), size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${i + 1}. ${q['question']}',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87))),
                  ]),
                  if (!isCorrect) ...[
                    const SizedBox(height: 6),
                    Text('Sua: ${userAns?.toUpperCase()} — ${q['option_${userAns}']}',
                        style: TextStyle(color: Colors.red[300], fontSize: 12)),
                  ],
                  const SizedBox(height: 4),
                  Text('Certa: ${correctAns.toUpperCase()} — ${q['option_$correctAns']}',
                      style: TextStyle(color: Colors.green[400], fontSize: 12)),
                  if (q['explanation'] != null && (q['explanation'] as String).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF252540) : const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.lightbulb_outline, size: 14, color: Colors.amber[600]),
                        const SizedBox(width: 6),
                        Expanded(child: Text(q['explanation'] as String,
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54))),
                      ]),
                    ),
                  ],
                ]),
              );
            }),

            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Voltar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )),
              if (!passed) ...[
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => setState(() {
                    _submitted = false;
                    _answers.clear();
                    _result = null;
                  }),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Tentar novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )),
              ],
            ]),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  Widget _buildQuiz(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final q = _questions[index];
        final qId = q['id'].toString();
        final selected = _answers[qId];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10, offset: const Offset(0, 4),
            )],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text('${index + 1}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
                        color: isDark ? AppColors.secondary : AppColors.primary))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(q['question'] as String,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4,
                      color: isDark ? Colors.white : Colors.black87))),
            ]),
            const SizedBox(height: 14),
            ...['a', 'b', 'c', 'd', 'e'].map((opt) {
              final text = q['option_$opt'] as String? ?? '';
              if (text.isEmpty) return const SizedBox.shrink();
              final isSelected = selected == opt;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  onTap: () => setState(() => _answers[qId] = opt),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.12)
                          : isDark ? const Color(0xFF252540) : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? (isDark ? AppColors.secondary : AppColors.primary) : (isDark ? Colors.white10 : Colors.grey[300]!),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(children: [
                      Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? (isDark ? AppColors.secondary : AppColors.primary) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? (isDark ? AppColors.secondary : AppColors.primary) : (isDark ? Colors.white30 : Colors.grey[400]!),
                            width: 2,
                          ),
                        ),
                        child: Center(child: Text(opt.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11,
                                color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.grey[600])))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(text,
                          style: TextStyle(fontSize: 13,
                              color: isSelected
                                  ? (isDark ? Colors.white : Colors.black87)
                                  : (isDark ? Colors.white70 : Colors.black54)))),
                    ]),
                  ),
                ),
              );
            }),
          ]),
        );
      },
    );
  }
}
