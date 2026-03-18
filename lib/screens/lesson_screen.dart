import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../core/theme/app_theme.dart';
import '../core/app_spacing.dart';
import '../models/lesson_model.dart';
import '../services/local_storage_service.dart';
import '../services/supabase_content_service.dart';

/// Tela de player de aula.
/// Corrigida: overflow, anotações persistentes, seek, velocidade, conclusão real, quiz na última aula.
class LessonPlayerScreen extends StatefulWidget {
  final String lessonId;
  final Lesson? lesson;
  final int currentIndex;
  final int totalLessons;
  final String? courseId;

  const LessonPlayerScreen({
    super.key,
    required this.lessonId,
    this.lesson,
    this.currentIndex = 1,
    this.totalLessons = 1,
    this.courseId,
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isCompleted = false;
  bool _isPlaying = false;

  // Apostila do Supabase
  Map<String, dynamic>? _apostilaContent;
  bool _loadingApostila = true;

  // Seek & timer
  double _seekPosition = 0.0;
  Timer? _playTimer;
  VoidCallback? _onTimerTick; // callback para atualizar fullscreen dialog

  // Velocidade
  static const _speeds = [0.5, 1.0, 1.5, 2.0];
  int _speedIndex = 1; // começa em 1x

  // Duração total em segundos
  int get _totalDurationSeconds =>
      widget.lesson?.durationSeconds ?? 1800; // fallback 30min

  // Elapsed em segundos
  int get _currentSeconds =>
      (_seekPosition * _totalDurationSeconds).round();

  // Formatar segundos → HH:MM:SS ou MM:SS
  String _formatTime(int totalSecs) {
    final h = totalSecs ~/ 3600;
    final m = (totalSecs % 3600) ~/ 60;
    final s = totalSecs % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _currentTimeFormatted => _formatTime(_currentSeconds);
  String get _totalTimeFormatted => _formatTime(_totalDurationSeconds);

  // BUG 2 — Anotações persistentes
  late TextEditingController _annotationController;
  Timer? _saveDebounce;

  // Dados da aula
  String get _lessonTitle =>
      widget.lesson?.title ?? 'Riscos de queda e medidas preventivas';
  String get _lessonDescription =>
      widget.lesson?.description.isNotEmpty == true
          ? widget.lesson!.description
          : 'Nesta aula você aprende os conceitos fundamentais do tema abordado, '
              'com exemplos práticos e referências às normas regulamentadoras aplicáveis.';
  List<LessonMaterial> get _materials =>
      widget.lesson?.materials ??
      [
        LessonMaterial(
          id: 'mat-1',
          lessonId: widget.lessonId,
          title: 'Apostila do módulo',
          fileUrl: '',
          fileType: 'PDF',
          fileSizeBytes: 2516582,
        ),
      ];
  // Exibição: tempo atual / total
  String get _timeDisplay => '$_currentTimeFormatted / $_totalTimeFormatted';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Carregar anotação persistida
    final saved = LocalStorageService.getAnnotation(widget.lessonId);
    _annotationController = TextEditingController(text: saved);

    // Verificar se aula já foi concluída
    if (widget.courseId != null) {
      final completed =
          LocalStorageService.getCompletedLessons(widget.courseId!);
      _isCompleted = completed.contains(widget.lessonId);
    }

    // Carregar apostila do Supabase
    _loadApostila();
  }

  Future<void> _loadApostila() async {
    debugPrint('\n📚 _loadApostila START — lessonId=${widget.lessonId}, courseId=${widget.courseId}');
    if (widget.courseId == null) {
      debugPrint('📚 courseId is null — skipping apostila load');
      setState(() => _loadingApostila = false);
      return;
    }
    try {
      final content = await SupabaseContentService.getApostila(widget.lessonId);
      debugPrint('📚 getApostila result: ${content != null ? "FOUND — title: ${content['title']}" : "NULL (not found)"}');
      if (mounted) {
        setState(() {
          _apostilaContent = content;
          _loadingApostila = false;
        });
      }
    } catch (e) {
      debugPrint('📚 _loadApostila EXCEPTION: $e');
      if (mounted) setState(() => _loadingApostila = false);
    }
  }

  void _startTimer() {
    _playTimer?.cancel();
    _playTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_isPlaying) return;
      final increment =
          (_speeds[_speedIndex] * 0.1) / _totalDurationSeconds;
      final newPos = _seekPosition + increment;
      if (newPos >= 1.0) {
        _seekPosition = 1.0;
        _isPlaying = false;
        setState(() {});
        _onTimerTick?.call();
        _stopTimer();
      } else {
        _seekPosition = newPos;
        setState(() {});
        _onTimerTick?.call();
      }
    });
  }

  void _stopTimer() {
    _playTimer?.cancel();
    _playTimer = null;
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      if (_seekPosition >= 1.0) _seekPosition = 0.0;
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    _tabController.dispose();
    _annotationController.dispose();
    _saveDebounce?.cancel();
    super.dispose();
  }

  void _onAnnotationChanged(String text) {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      LocalStorageService.saveAnnotation(widget.lessonId, text);
    });
  }

  void _cycleSpeed() {
    setState(() {
      _speedIndex = (_speedIndex + 1) % _speeds.length;
    });
  }

  Future<void> _toggleComplete() async {
    final wasCompleted = _isCompleted;
    setState(() => _isCompleted = !_isCompleted);

    // Persistir no enrollment
    if (widget.courseId != null && !wasCompleted) {
      await LocalStorageService.markLessonComplete(
        courseId: widget.courseId!,
        lessonId: widget.lessonId,
        totalLessons: widget.totalLessons,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _isCompleted ? 'Aula marcada como concluída!' : 'Aula desmarcada'),
        backgroundColor: _isCompleted ? AppColors.success : Colors.grey,
      ),
    );

    // BUG 8 — Se é a última aula e acabou de concluir, oferecer quiz
    if (_isCompleted &&
        widget.currentIndex >= widget.totalLessons &&
        widget.courseId != null) {
      _showQuizDialog();
    }
  }

  void _showQuizDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: AppColors.secondary),
            SizedBox(width: 8),
            Expanded(child: Text('Parabéns!')),
          ],
        ),
        content: const Text(
          'Você concluiu todas as aulas deste curso! '
          'Agora faça a avaliação para obter seu certificado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Depois'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(
                '/quiz/${widget.courseId}?title=${Uri.encodeComponent(_lessonTitle)}',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Fazer avaliação'),
          ),
        ],
      ),
    );
  }

  void _openFullscreen() {
    bool showNotes = false;

    showDialog(
      context: context,
      barrierColor: Colors.black,
      useSafeArea: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setFS) {
          // Registrar callback para timer atualizar o dialog
          _onTimerTick = () => setFS(() {});
          return Scaffold(
            backgroundColor: Colors.black,
            body: LayoutBuilder(
              builder: (ctx2, constraints) {
                final isLandscape = constraints.maxWidth > constraints.maxHeight;

                // ── Widget do player ──
                Widget playerWidget = GestureDetector(
                  onDoubleTap: () => Navigator.pop(ctx),
                  child: Stack(
                    children: [
                      // Player centralizado
                      Center(
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            color: const Color(0xFF1A1A2E),
                            child: Center(
                              child: GestureDetector(
                                onTap: () => setFS(
                                    () { _togglePlay(); }),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 50,
                                    color: Colors.white
                                        .withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Barra inferior com seek + controles ──
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(
                                8, 0, 8, 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Seek bar
                                SliderTheme(
                                  data: const SliderThemeData(
                                    trackHeight: 4,
                                    thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 7),
                                    activeTrackColor:
                                        AppColors.primary,
                                    inactiveTrackColor:
                                        Colors.white24,
                                    thumbColor: AppColors.primary,
                                    overlayShape:
                                        RoundSliderOverlayShape(
                                            overlayRadius: 14),
                                  ),
                                  child: Slider(
                                    value: _seekPosition,
                                    onChanged: (v) =>
                                        setFS(() => _seekPosition = v),
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Controles inferiores
                                Row(
                                  children: [
                                    // Sair fullscreen
                                    IconButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx),
                                      icon: const Icon(
                                          Icons.fullscreen_exit,
                                          color: Colors.white,
                                          size: 22),
                                      tooltip: 'Sair da tela cheia',
                                      visualDensity:
                                          VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                          minWidth: 32, minHeight: 32),
                                    ),
                                    // -10s
                                    IconButton(
                                      onPressed: () => setFS(() =>
                                          _seekPosition =
                                              (_seekPosition - 0.05)
                                                  .clamp(0.0, 1.0)),
                                      icon: const Icon(
                                          Icons.replay_10,
                                          color: Colors.white70,
                                          size: 20),
                                      visualDensity:
                                          VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                          minWidth: 32, minHeight: 32),
                                    ),
                                    // +10s
                                    IconButton(
                                      onPressed: () => setFS(() =>
                                          _seekPosition =
                                              (_seekPosition + 0.05)
                                                  .clamp(0.0, 1.0)),
                                      icon: const Icon(
                                          Icons.forward_10,
                                          color: Colors.white70,
                                          size: 20),
                                      visualDensity:
                                          VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                          minWidth: 32, minHeight: 32),
                                    ),
                                    const SizedBox(width: 2),
                                    // Velocidade
                                    GestureDetector(
                                      onTap: () {
                                        setFS(() {
                                          _speedIndex =
                                              (_speedIndex + 1) %
                                                  _speeds.length;
                                        });
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                                horizontal: 6,
                                                vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white24,
                                          borderRadius:
                                              BorderRadius.circular(
                                                  6),
                                        ),
                                        child: Text(
                                          '${_speeds[_speedIndex]}x',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.w600,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    // Duração — ocupa espaço restante
                                    Expanded(
                                      child: Text(
                                        _timeDisplay,
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // ── DIREITA: ícone caderno ──
                                    IconButton(
                                      onPressed: () =>
                                          setFS(() => showNotes =
                                              !showNotes),
                                      icon: Icon(
                                        showNotes
                                            ? Icons.menu_book
                                            : Icons
                                                .menu_book_outlined,
                                        color: showNotes
                                            ? AppColors.primary
                                            : Colors.white70,
                                        size: 22,
                                      ),
                                      tooltip: showNotes
                                          ? 'Fechar anotações'
                                          : 'Anotações',
                                      visualDensity:
                                          VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                          minWidth: 32, minHeight: 32),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                // ── Widget das anotações ──
                Widget notesWidget = Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    border: Border(
                      left: isLandscape
                          ? const BorderSide(color: Colors.white12, width: 1)
                          : BorderSide.none,
                      top: !isLandscape
                          ? const BorderSide(color: Colors.white12, width: 1)
                          : BorderSide.none,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.white12, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.edit_note,
                                color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Anotações',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () =>
                                  setFS(() => showNotes = false),
                              icon: const Icon(Icons.close,
                                  color: Colors.white54, size: 18),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                      // Campo de anotação
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: _annotationController,
                            onChanged: _onAnnotationChanged,
                            maxLines: null,
                            expands: true,
                            textAlignVertical:
                                TextAlignVertical.top,
                            keyboardType:
                                TextInputType.multiline,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.5),
                            decoration: InputDecoration(
                              hintText:
                                  'Escreva suas anotações aqui...',
                              hintStyle: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: 0.3)),
                              filled: true,
                              fillColor: const Color(0xFF2A2A3E),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                                  const EdgeInsets.all(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                // ── Layout principal baseado na orientação ──
                if (isLandscape) {
                  // Landscape: Row — player + painel lateral
                  return Row(
                    children: [
                      Expanded(child: playerWidget),
                      if (showNotes)
                        SizedBox(
                          width: constraints.maxWidth * 0.30,
                          child: notesWidget,
                        ),
                    ],
                  );
                } else {
                  // Portrait: Column — 70% vídeo em cima, 30% anotações embaixo
                  return Column(
                    children: [
                      Expanded(
                        flex: showNotes ? 7 : 1,
                        child: playerWidget,
                      ),
                      if (showNotes)
                        Expanded(
                          flex: 3,
                          child: notesWidget,
                        ),
                    ],
                  );
                }
              },
            ),
          );
        },
      ),
    ).then((_) {
      _onTimerTick = null; // limpar callback ao sair do fullscreen
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Aula ${widget.currentIndex} de ${widget.totalLessons}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: AppSpacing.maxContentWidth(context)),
          child: Column(
            children: [
              // Video player area — limitar altura no desktop
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: GestureDetector(
                    onDoubleTap: _openFullscreen,
                    child: Container(
                      width: double.infinity,
                      color: isDark ? const Color(0xFF1A1A2E) : Colors.grey[300],
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Duração
                          Positioned(
                            bottom: 12,
                            right: 52,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _timeDisplay,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          // Botão fullscreen
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: _openFullscreen,
                              icon: const Icon(Icons.fullscreen,
                                  color: Colors.white70, size: 28),
                              tooltip: 'Tela cheia',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black38,
                              ),
                            ),
                          ),
                          // Play/Pause grande
                          GestureDetector(
                            onTap: () =>
                                setState(() { _togglePlay(); }),
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 40,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // BUG 6 — Seek bar clicável
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 12),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor:
                      isDark ? AppColors.darkDivider : Colors.grey[300],
                  thumbColor: AppColors.primary,
                ),
                child: Slider(
                  value: _seekPosition,
                  onChanged: (v) => setState(() => _seekPosition = v),
                ),
              ),

              // Controls
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ControlButton(
                        icon: Icons.replay_10,
                        label: '-10s',
                        onTap: () => setState(() =>
                            _seekPosition =
                                (_seekPosition - 0.05).clamp(0.0, 1.0))),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.darkCard : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 32,
                        ),
                        onPressed: () => _togglePlay(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _ControlButton(
                        icon: Icons.forward_10,
                        label: '+10s',
                        onTap: () => setState(() =>
                            _seekPosition =
                                (_seekPosition + 0.05).clamp(0.0, 1.0))),
                    const SizedBox(width: 16),
                    // BUG 5 — Velocidade clicável
                    GestureDetector(
                      onTap: _cycleSpeed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_speeds[_speedIndex]}x',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: isDark ? Colors.white : Colors.black87,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Sobre'),
                  Tab(text: 'Materiais'),
                  Tab(text: 'Anotações'),
                ],
              ),

              // BUG 1 — Tab content com padding bottom adequado
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Sobre tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_lessonTitle,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(_lessonDescription,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium),
                          const SizedBox(height: 20),
                          if (_materials.isNotEmpty) ...[
                            Text('Materiais desta aula',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium),
                            const SizedBox(height: 8),
                            ..._materials.map(
                                (mat) => _MaterialTile(material: mat)),
                          ],
                        ],
                      ),
                    ),

                    // Materiais tab — Apostila do Supabase + materiais locais
                    _loadingApostila
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Apostila do Supabase
                                if (_apostilaContent != null) ...[
                                  // Header
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                                          const Color(0xFF6C5CE7).withValues(alpha: 0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.auto_stories, size: 20, color: Color(0xFF6C5CE7)),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _apostilaContent!['title'] as String? ?? 'Apostila',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold, fontSize: 15,
                                                      color: isDark ? Colors.white : Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text('Material de estudo',
                                                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () {
                                                if (widget.courseId != null) {
                                                  context.push(
                                                    '/apostila/${widget.courseId}'
                                                    '?title=${Uri.encodeComponent(_apostilaContent!['title'] as String? ?? 'Apostila')}'
                                                    '&lessonId=${widget.lessonId}',
                                                  );
                                                }
                                              },
                                              icon: const Icon(Icons.menu_book, size: 18),
                                              label: const Text('Ler Apostila'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(0xFF6C5CE7),
                                                side: const BorderSide(color: Color(0xFF6C5CE7)),
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Gerando PDF... em breve!')),
                                                );
                                              },
                                              icon: const Icon(Icons.picture_as_pdf, size: 18),
                                              label: const Text('Baixar PDF'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF6C5CE7),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Preview do conteúdo markdown
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF222538) : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDark ? Colors.white12 : Colors.grey[200]!,
                                      ),
                                    ),
                                    child: MarkdownBody(
                                      data: _apostilaContent!['body'] as String? ?? '',
                                      styleSheet: MarkdownStyleSheet(
                                        h2: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : Colors.black87),
                                        h3: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87),
                                        p: TextStyle(fontSize: 13, height: 1.6,
                                            color: isDark ? Colors.white70 : Colors.black87),
                                        listBullet: TextStyle(fontSize: 13,
                                            color: isDark ? Colors.white70 : Colors.black87),
                                        strong: TextStyle(fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : Colors.black),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                // Materiais locais (arquivos antigos)
                                if (_materials.isNotEmpty) ...[
                                  Text('Outros materiais',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
                                          color: isDark ? Colors.white70 : Colors.black54)),
                                  const SizedBox(height: 8),
                                  ..._materials.map((mat) => _MaterialTile(material: mat)),
                                ],
                                if (_apostilaContent == null && _materials.isEmpty)
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 40),
                                        Icon(Icons.folder_open, size: 48, color: Colors.grey[500]),
                                        const SizedBox(height: 12),
                                        Text('Nenhum material disponível',
                                            style: TextStyle(color: Colors.grey[500])),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                    // Anotações tab — caixa grande que preenche todo o espaço
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _annotationController,
                        onChanged: _onAnnotationChanged,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        textAlignVertical: TextAlignVertical.top,
                        textInputAction: TextInputAction.newline,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                          height: 1.6,
                        ),
                        cursorColor: AppColors.secondary,
                        decoration: InputDecoration(
                          hintText: 'Escreva suas anotações aqui...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white30 : Colors.grey[400],
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF2A2D42)
                              : Colors.grey[50],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF4A4D65) : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.secondary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _toggleComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isCompleted ? AppColors.success : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isCompleted ? '✓ Concluída' : 'Marcar como concluída',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _MaterialTile extends StatelessWidget {
  final LessonMaterial material;

  const _MaterialTile({required this.material});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color iconColor;
    switch (material.fileType.toUpperCase()) {
      case 'PDF':
        iconColor = Colors.red;
        break;
      case 'PPT':
      case 'PPTX':
        iconColor = Colors.orange;
        break;
      default:
        iconColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                material.fileType.toUpperCase().replaceAll('PPTX', 'PPT'),
                style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(
                  '${material.fileSizeFormatted} · ${material.fileType}',
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download em breve!')),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Baixar'),
          ),
        ],
      ),
    );
  }
}
