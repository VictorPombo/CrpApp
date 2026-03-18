import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../core/theme/app_theme.dart';
import '../services/supabase_content_service.dart';

/// Tela de exibição de apostila — renderiza markdown do Supabase.
class LessonContentScreen extends StatefulWidget {
  final String lessonId;
  final String courseId;
  final String lessonTitle;
  final int currentIndex;
  final int totalLessons;

  const LessonContentScreen({
    super.key,
    required this.lessonId,
    required this.courseId,
    required this.lessonTitle,
    this.currentIndex = 1,
    this.totalLessons = 1,
  });

  @override
  State<LessonContentScreen> createState() => _LessonContentScreenState();
}

class _LessonContentScreenState extends State<LessonContentScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _contents = [];
  int _currentContentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    // Try to fetch apostila content by lesson_id pattern
    // The lesson_id in Supabase follows pattern: nr{XX}_m{Y}_l{Z}
    final contents = await SupabaseContentService.getLessonContent(
      widget.courseId,
      contentType: 'apostila',
    );

    if (mounted) {
      setState(() {
        _contents = contents;
        _loading = false;
        // Try to find the current lesson by lesson_id
        final idx = contents.indexWhere((c) => c['lesson_id'] == widget.lessonId);
        if (idx >= 0) _currentContentIndex = idx;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: Text(
          widget.lessonTitle,
          style: const TextStyle(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        actions: [
          if (_contents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentContentIndex + 1}/${_contents.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _contents.isEmpty
              ? _buildEmpty(isDark)
              : _buildContent(isDark),
      bottomNavigationBar: _contents.length > 1 ? _buildNavBar(isDark) : null,
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 64,
              color: isDark ? Colors.white24 : Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Conteúdo ainda não disponível',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final content = _contents[_currentContentIndex];
    final title = content['title'] as String? ?? '';
    final body = content['body'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Apostila badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_stories, size: 14, color: Color(0xFF6C5CE7)),
                    SizedBox(width: 6),
                    Text('Apostila', style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: Color(0xFF6C5CE7),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Title
              if (title.isNotEmpty) ...[
                Text(title, style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.3,
                )),
                const SizedBox(height: 16),
                Divider(color: isDark ? Colors.white12 : Colors.grey[200]),
                const SizedBox(height: 16),
              ],

              // Markdown body
              MarkdownBody(
                data: body,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  h2: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.5,
                  ),
                  h3: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                    height: 1.5,
                  ),
                  p: TextStyle(
                    fontSize: 15, height: 1.7,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  listBullet: TextStyle(
                    fontSize: 15, color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  strong: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  blockquote: TextStyle(
                    fontSize: 14, fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white60 : Colors.grey[700],
                  ),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 3,
                      ),
                    ),
                  ),
                  blockquotePadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                  tableHead: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  tableBody: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  tableBorder: TableBorder.all(
                    color: isDark ? Colors.white24 : Colors.grey[300]!,
                    width: 0.5,
                  ),
                  tableCellsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  tableHeadAlign: TextAlign.left,
                  code: TextStyle(
                    fontSize: 13, fontFamily: 'monospace',
                    color: isDark ? const Color(0xFFE8D44D) : const Color(0xFF6C5CE7),
                    backgroundColor: isDark ? const Color(0xFF252540) : const Color(0xFFF0F2F5),
                  ),
                  horizontalRuleDecoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar(bool isDark) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? Colors.white12 : Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            // Previous
            Expanded(
              child: _currentContentIndex > 0
                  ? TextButton.icon(
                      onPressed: () => setState(() => _currentContentIndex--),
                      icon: const Icon(Icons.chevron_left, size: 20),
                      label: const Text('Anterior', style: TextStyle(fontSize: 14)),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? AppColors.secondary : AppColors.primary,
                      ),
                    )
                  : const SizedBox(),
            ),

            // Page indicator dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _contents.length > 10 ? 0 : _contents.length, // hide if too many
                (i) => Container(
                  width: i == _currentContentIndex ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i == _currentContentIndex
                        ? (isDark ? AppColors.secondary : AppColors.primary)
                        : (isDark ? Colors.white24 : Colors.grey[300]),
                  ),
                ),
              ),
            ),

            // Next
            Expanded(
              child: _currentContentIndex < _contents.length - 1
                  ? TextButton.icon(
                      onPressed: () => setState(() => _currentContentIndex++),
                      icon: const Text('Próxima', style: TextStyle(fontSize: 14)),
                      label: const Icon(Icons.chevron_right, size: 20),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? AppColors.secondary : AppColors.primary,
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
