import 'package:crp_cursos/providers/theme_service.dart';
import 'package:flutter/material.dart';
// no Riverpod here; simple StatefulWidget
import '../services/course_service_mock.dart';
import '../models/course_model.dart';
import '../widgets/course_card.dart';
// theme handled by ThemeService via Profile screen

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _service = CourseServiceMock();
  late Future<List<Course>> _future;
  String selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();
    _future = _service.fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () => Navigator.of(context).pushNamed('/login'),
          ),
        ],
      ),
      body: FutureBuilder<List<Course>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: "+snapshot.error.toString()'));
          }
          final courses = snapshot.data ?? [];
          final categories = <String>{'Todos'}..addAll(courses.map((c) => c.category));
          final filtered = selectedCategory == 'Todos'
              ? courses
              : courses.where((c) => c.category == selectedCategory).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Text('Categoria: '),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: selectedCategory,
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => selectedCategory = v ?? 'Todos'),
                    ),
                    const Spacer(),
                    // Ícone de tema
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: ThemeService.notifier,
                        builder: (context, mode, _) {
                          final isDarkMode = mode == ThemeMode.dark;

                          return Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.blue.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              tooltip: isDarkMode ? 'Modo claro' : 'Modo escuro',
                              icon: Icon(
                                isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                                color: isDarkMode ? Colors.orange : const Color.fromARGB(255, 0, 0, 0),
                              ),
                              onPressed: () async => await ThemeService.toggle(),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final c = filtered[index];
                    return CourseCard(course: c);
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
