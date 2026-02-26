import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'course_list_screen.dart';
import 'package:crp_cursos/widgets/course_card.dart';
import '../services/course_service_mock.dart';
import '../models/course_model.dart';
import '../providers/theme_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentIndex = 0;
  final _service = CourseServiceMock();
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _service.fetchCourses();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final pages = [
      buildHome(),
      const CourseListScreen(),
      const ProfileScreen()
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Cursos"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }

  Widget buildHome() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title, search and theme toggle
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "Cursos de Normas Regulamentadoras",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Buscar cursos',
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    // load courses then open search delegate
                    final courses = await _coursesFuture;
                    await showSearch(context: context, delegate: CourseSearchDelegate(courses));
                  },
                ),
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
            const SizedBox(height: 10),
            const Text("Bem-vindo, Usuário Demo!"),
            const SizedBox(height: 20),

            // Horizontal list with multiple NRs
            Expanded(
              child: FutureBuilder<List<Course>>(
                future: _coursesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final courses = snapshot.data ?? [];
                  if (courses.isEmpty) return const Text('Nenhum curso disponível');

                  // Mostrar todos os cursos em um Grid vertical responsivo com 3 colunas
                  final show = courses;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      const gridSpacing = 12.0;
                      final availableWidth = constraints.maxWidth - (gridSpacing * 2);
                      final itemWidth = availableWidth / 3;
                      final childAspectRatio = itemWidth / (itemWidth * 0.75);

                      return GridView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: gridSpacing,
                          mainAxisSpacing: gridSpacing,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: show.length,
                        itemBuilder: (context, index) {
                          final c = show[index];
                          return CourseCard(course: c);
                        },
                      );
                    },
                  );
                },
              ),
            ),

                      ],
                    ),
                  ),
                );
              }
            }

// Simple search delegate for Courses
class CourseSearchDelegate extends SearchDelegate<Course?> {
  final List<Course> courses;
  CourseSearchDelegate(this.courses);

  @override
  String? get searchFieldLabel => 'Pesquisar por nome ou código';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = courses.where((c) {
      final q = query.toLowerCase();
      return c.title.toLowerCase().contains(q) || c.code.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) return const Center(child: Text('Nenhum curso encontrado'));

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final c = results[index];
        return ListTile(
          title: Text(c.title),
          subtitle: Text('${c.code} • ${c.hours}h'),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(c.title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.description),
                    const SizedBox(height: 8),
                    Text('Código: ${c.code}'),
                    Text('Horas: ${c.hours}'),
                  ],
                ),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final q = query.toLowerCase();
    final suggestions = query.isEmpty
        ? courses.take(6).toList()
        : courses.where((c) => c.title.toLowerCase().contains(q) || c.code.toLowerCase().contains(q)).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final c = suggestions[index];
        return ListTile(
          title: Text(c.title),
          subtitle: Text(c.code),
          onTap: () {
            query = c.title;
            showResults(context);
          },
        );
      },
    );
  }
}