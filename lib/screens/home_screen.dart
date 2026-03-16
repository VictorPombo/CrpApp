import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_service.dart';
import '../services/course_service_mock.dart';
import '../models/course_model.dart';
import '../widgets/course_card.dart';
import '../widgets/shimmer_card.dart';
import '../widgets/empty_state.dart';
import 'my_courses_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    _CatalogPage(),
    MyCoursesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Meus cursos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

/// Página de catálogo (home principal)
class _CatalogPage extends StatefulWidget {
  const _CatalogPage();

  @override
  State<_CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<_CatalogPage> {
  final _service = CourseServiceMock();
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  bool _loading = true;
  String _selectedCategory = 'Todos';

  static const _categories = [
    'Todos', 'Altura', 'Eletricidade', 'Máquinas', 'Incêndio',
    'Segurança', 'Saúde', 'Gestão', 'Construção', 'Ergonomia',
    'Confinado', 'Cargas', 'Industrial', 'Rural', 'Ambiental',
    'Pressão', 'Mineração', 'Portuário', 'Aquaviário', 'Naval',
    'Alimentício', 'Petróleo', 'Fiscalização',
  ];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final courses = await _service.fetchCourses();
    setState(() {
      _allCourses = courses;
      _filteredCourses = courses;
      _loading = false;
    });
  }

  void _applyFilter(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Todos') {
        _filteredCourses = _allCourses;
      } else {
        _filteredCourses = _allCourses
            .where((c) => c.category == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.asset(
                            'assets/images/crp_logo.png',
                            height: 42,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Catálogo de Cursos',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  // Busca
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: ThemeService.notifier,
                    builder: (context, mode, _) {
                      return Row(
                        children: [
                          IconButton(
                            tooltip: 'Buscar cursos',
                            icon: const Icon(Icons.search),
                            onPressed: () async {
                              final courses = _allCourses;
                              if (!mounted) return;
                              await showSearch(
                                context: context,
                                delegate: _CourseSearchDelegate(courses),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: ThemeService.isDark
                                ? 'Modo claro'
                                : 'Modo escuro',
                            icon: Icon(
                              ThemeService.isDark
                                  ? Icons.wb_sunny
                                  : Icons.nightlight_round,
                              color: ThemeService.isDark
                                  ? AppColors.secondary
                                  : Colors.black87,
                            ),
                            onPressed: () => ThemeService.toggle(),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Cursos
          SliverToBoxAdapter(
            child: _loading
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Carregando cursos...',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        const ShimmerList(count: 4),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // Em destaque
                        Text('Em destaque',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 260,
                          child: Builder(builder: (context) {
                            // Cursos em destaque: NR-05 (em andamento),
                            // NR-35 (pronto para quiz), NR-10 (completo)
                            final featuredIds = ['nr05', 'nr35', 'nr10'];
                            final featured = featuredIds
                                .map((id) => _allCourses
                                    .where((c) => c.id == id)
                                    .firstOrNull)
                                .whereType<Course>()
                                .toList();
                            final displayList = featured.isNotEmpty
                                ? featured
                                : _allCourses.take(3).toList();
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: displayList.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  width: 280,
                                  child: CourseCard(
                                      course: displayList[index]),
                                );
                              },
                            );
                          }),
                        ),

                        const SizedBox(height: 24),

                        // Filtro de categorias
                        Text('Categorias',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              final selected = cat == _selectedCategory;
                              return ChoiceChip(
                                label: Text(cat),
                                selected: selected,
                                onSelected: (_) => _applyFilter(cat),
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  fontSize: 13,
                                  color: selected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[700]),
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                backgroundColor: isDark
                                    ? AppColors.darkCard
                                    : Colors.grey[100],
                                side: BorderSide(
                                  color: selected
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.darkDivider
                                          : Colors.grey[300]!),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20)),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Todos os cursos (filtrados)
                        Row(
                          children: [
                            Text(
                              _selectedCategory == 'Todos'
                                  ? 'Todos os cursos'
                                  : _selectedCategory,
                              style:
                                  Theme.of(context).textTheme.titleLarge,
                            ),
                            const Spacer(),
                            Text(
                              '${_filteredCourses.length} cursos',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (_filteredCourses.isEmpty)
                          EmptyState(
                            icon: Icons.search_off,
                            title: 'Nenhum curso encontrado',
                            subtitle:
                                'Não há cursos na categoria "$_selectedCategory".',
                            buttonLabel: 'Ver todos',
                            onButtonTap: () => _applyFilter('Todos'),
                          )
                        else
                          LayoutBuilder(
                            builder: (context, constraints) {
                              int cols = 1;
                              if (constraints.maxWidth >= 1200) {
                                cols = 4;
                              } else if (constraints.maxWidth >= 800) {
                                cols = 3;
                              } else if (constraints.maxWidth >= 500) {
                                cols = 2;
                              }

                              return GridView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  mainAxisExtent: 270,
                                ),
                                itemCount: _filteredCourses.length,
                                itemBuilder: (_, i) => CourseCard(
                                    course: _filteredCourses[i]),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// Search delegate
class _CourseSearchDelegate extends SearchDelegate<Course?> {
  final List<Course> courses;
  _CourseSearchDelegate(this.courses);

  @override
  String? get searchFieldLabel => 'Pesquisar por nome ou código';

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
              icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final q = query.toLowerCase();
    final filtered = q.isEmpty
        ? courses
        : courses
            .where((c) =>
                c.title.toLowerCase().contains(q) ||
                c.code.toLowerCase().contains(q))
            .toList();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return CourseCard(course: filtered[index]);
      },
    );
  }
}