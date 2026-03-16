# PROMPT — SESSÃO DE DESENVOLVIMENTO — CRP CURSOS v2
# Tarefas prioritárias para fechar o MVP

---

## CONTEXTO ATUAL DO PROJETO

O app Flutter CRP Cursos está com **59% do MVP concluído**.
As seguintes funcionalidades já existem e estão funcionando:

✅ Design system completo (AppTheme, dark/light)
✅ Models: Course, Module, Lesson, Enrollment, Certificate
✅ Mock data: 7 cursos NR com módulos, aulas, instrutores
✅ Catálogo de cursos com busca e destaques
✅ Tela de detalhe do curso (hero, módulos, preço, comprar)
✅ Tela Meus Cursos (stats, filtros, cards com progresso)
✅ Player de aula (placeholder vídeo, tabs Sobre/Materiais/Anotações)
✅ Tela de certificado com QR code
✅ Perfil completo (dados pessoais, histórico, pagamentos, alterar senha)
✅ Fluxo de compra (Carrinho → Pagamento → Processando → Sucesso/Falha)
✅ GoRouter com rotas dinâmicas
✅ Bug #1 resolvido: navegação do perfil
✅ Bug #2 resolvido: fluxo de compra conectado
✅ Bug #3 resolvido: aulas navegam para LessonPlayerScreen

A pasta `docs/` contém imagens de referência de UX/UI.

---

## CONTEXTO LEGAL IMPORTANTE — LEIA ANTES DE IMPLEMENTAR

Os cursos da CRP Engenharia são treinamentos de Normas Regulamentadoras (NRs)
obrigatórios por lei (CLT + Portarias do Ministério do Trabalho).

O certificado emitido pelo app é um DOCUMENTO LEGAL usado por empresas
para comprovar conformidade em fiscalizações do MTE.

Por isso, o certificado NÃO pode ser emitido livremente como faz o Udemy.
O modelo correto é o do SENAI/Coursera: avaliação obrigatória com nota mínima.

### REGRA DE NEGÓCIO CENTRAL — NUNCA VIOLAR:

O certificado só pode ser emitido quando as 3 condições abaixo forem
satisfeitas SIMULTANEAMENTE:

  CONDIÇÃO 1 — PRESENÇA
  └── progressPercent >= 0.75 (mínimo 75% das aulas assistidas)
  
  CONDIÇÃO 2 — APROVAÇÃO NA AVALIAÇÃO  
  └── quizScore >= 70 (nota mínima de 70%)
  
  CONDIÇÃO 3 — DADOS COMPLETOS DO ALUNO
  └── user.cpf != null && user.cpf.isNotEmpty
  └── user.company != null && user.company.isNotEmpty

Se qualquer condição não for atendida, o botão de certificado fica bloqueado
com mensagem explicativa de qual condição está faltando.

Esta lógica deve ser implementada em um único lugar:
`lib/services/certificate_eligibility_service.dart`
para que todas as telas a consultem — sem duplicação de regra.

---

## REGRAS DESTA SESSÃO

1. **Implemente UMA tarefa por vez**
2. Ao concluir cada tarefa:
   - Liste os arquivos criados/modificados
   - Confirme que `flutter analyze` passa sem erros críticos
   - Pergunte: "Tarefa X concluída. Posso avançar para a Tarefa Y?"
3. **Nunca reescreva** código que já está funcionando
4. Mantenha suporte a tema claro/escuro em todas as telas
5. Todos os comentários em português
6. **Pense sempre em não gerar retrabalho futuro** — implemente já preparado
   para quando conectarmos ao Supabase (backend real)

---

## TAREFA 1 — CertificateEligibilityService (base de tudo)

**Por que primeiro:** todas as tarefas seguintes dependem desta regra central.
Criar o serviço antes garante que nenhuma tela implemente a lógica sozinha.

Criar `lib/services/certificate_eligibility_service.dart`:

```dart
/// Serviço central de elegibilidade para emissão de certificado.
/// 
/// REGRA LEGAL: cursos de NR são treinamentos obrigatórios pelo MTE.
/// O certificado só pode ser emitido com as 3 condições satisfeitas.
/// Nunca mover esta lógica para dentro de widgets ou telas.

enum CertificateBlockReason {
  insufficientProgress,   // menos de 75% das aulas assistidas
  quizNotApproved,        // avaliação não realizada ou nota < 70%
  incompleteProfileData,  // CPF ou empresa não preenchidos
}

class CertificateEligibilityResult {
  final bool isEligible;
  final List<CertificateBlockReason> blockedBy;
  final double progressPercent;
  final int? quizScore;
  final bool hasRequiredProfileData;

  const CertificateEligibilityResult({
    required this.isEligible,
    required this.blockedBy,
    required this.progressPercent,
    this.quizScore,
    required this.hasRequiredProfileData,
  });

  /// Mensagem amigável para exibir ao aluno explicando o que falta
  String get blockMessage {
    if (isEligible) return '';
    final messages = <String>[];
    if (blockedBy.contains(CertificateBlockReason.insufficientProgress)) {
      messages.add('• Complete pelo menos 75% das aulas');
    }
    if (blockedBy.contains(CertificateBlockReason.quizNotApproved)) {
      messages.add('• Realize a avaliação final com nota mínima de 70%');
    }
    if (blockedBy.contains(CertificateBlockReason.incompleteProfileData)) {
      messages.add('• Preencha seu CPF e empresa no perfil');
    }
    return 'Para emitir o certificado:\n${messages.join('\n')}';
  }
}

class CertificateEligibilityService {
  /// Verifica se o aluno pode emitir o certificado para um curso específico.
  /// 
  /// [progressPercent] — de 0.0 a 1.0 (ex: 0.85 = 85%)
  /// [quizScore] — de 0 a 100, ou null se avaliação não foi feita
  /// [userCpf] — CPF do aluno (pode estar em AuthService ou UserProfile)
  /// [userCompany] — Empresa do aluno
  static CertificateEligibilityResult check({
    required double progressPercent,
    required int? quizScore,
    required String? userCpf,
    required String? userCompany,
  }) {
    final blocked = <CertificateBlockReason>[];

    // Condição 1: presença mínima de 75%
    if (progressPercent < 0.75) {
      blocked.add(CertificateBlockReason.insufficientProgress);
    }

    // Condição 2: avaliação aprovada com 70%+
    if (quizScore == null || quizScore < 70) {
      blocked.add(CertificateBlockReason.quizNotApproved);
    }

    // Condição 3: dados obrigatórios do aluno preenchidos
    final hasCpf = userCpf != null && userCpf.trim().isNotEmpty;
    final hasCompany = userCompany != null && userCompany.trim().isNotEmpty;
    if (!hasCpf || !hasCompany) {
      blocked.add(CertificateBlockReason.incompleteProfileData);
    }

    return CertificateEligibilityResult(
      isEligible: blocked.isEmpty,
      blockedBy: blocked,
      progressPercent: progressPercent,
      quizScore: quizScore,
      hasRequiredProfileData: hasCpf && hasCompany,
    );
  }
}
```

Também criar `lib/widgets/certificate_eligibility_card.dart`:

```dart
/// Widget reutilizável que mostra o status de elegibilidade do certificado.
/// Usar em: CourseScreen (ao final), MyCoursesScreen (no card), CertificateScreen.

class CertificateEligibilityCard extends StatelessWidget {
  final CertificateEligibilityResult result;
  final VoidCallback? onStartQuiz;
  final VoidCallback? onCompleteProfile;
  final VoidCallback? onViewCertificate;

  // Se elegível: card verde com botão "Ver certificado"
  // Se bloqueado: card âmbar com lista do que falta + botões de ação
  // Ex: "Preencher perfil" → navega para personal_data_screen
  //     "Fazer avaliação" → navega para quiz_screen
}
```

**Critério de aceite:**
- Serviço criado e testável isoladamente
- `CertificateEligibilityService.check(...)` retorna resultado correto
  para todos os cenários (todas ok, uma bloqueada, todas bloqueadas)
- Widget `CertificateEligibilityCard` renderiza corretamente nos 2 estados

---

## TAREFA 2 — Guards de rota

**O que fazer:**

### 2a. Expandir AuthService com persistência de sessão

Em `lib/services/auth_service.dart` (expandir, não reescrever):

```dart
// Adicionar campos se não existirem no modelo de usuário:
// user.cpf, user.company, user.role (student | admin)

bool get isAuthenticated => _currentUser != null;

Future<void> restoreSession() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');
  if (userId != null) {
    // Restaurar usuário da sessão salva
    _currentUser = User(
      id: userId,
      name: prefs.getString('user_name') ?? '',
      email: prefs.getString('user_email') ?? '',
      cpf: prefs.getString('user_cpf'),
      company: prefs.getString('user_company'),
    );
    notifyListeners();
  }
}

Future<void> persistSession(User user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_id', user.id);
  await prefs.setString('user_name', user.name);
  await prefs.setString('user_email', user.email);
  if (user.cpf != null) await prefs.setString('user_cpf', user.cpf!);
  if (user.company != null) await prefs.setString('user_company', user.company!);
}

Future<void> clearSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  _currentUser = null;
  notifyListeners();
}
```

### 2b. GoRouter redirect

```dart
redirect: (BuildContext context, GoRouterState state) {
  final auth = context.read<AuthService>();
  final isLoggedIn = auth.isAuthenticated;

  // Rotas que exigem login
  final protectedPrefixes = ['/lesson', '/certificate', '/quiz'];
  final isProtected = protectedPrefixes
      .any((r) => state.uri.path.startsWith(r));

  if (isProtected && !isLoggedIn) {
    final destination = Uri.encodeComponent(state.uri.toString());
    return '/login?redirect=$destination';
  }
  return null;
},
```

### 2c. LoginScreen: redirecionar para origem após login

```dart
final redirect = GoRouterState.of(context)
    .uri.queryParameters['redirect'];
final destination = redirect != null
    ? Uri.decodeComponent(redirect) : '/home';
context.go(destination);
```

### 2d. Restaurar sessão no main()

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.restoreSession(); // sempre antes do runApp
  runApp(MyApp(authService: authService));
}
```

**Critério de aceite:**
- /lesson/qualquer-id sem login → redireciona para /login
- Após login → retorna para a tela original
- Fechar e reabrir o app → sessão restaurada automaticamente

---

## TAREFA 3 — QuizScreen (avaliação final)

**IMPORTANTE:** esta tela deve usar o `CertificateEligibilityService`
criado na Tarefa 1. Nunca validar a nota diretamente na tela.

### Model

Criar `lib/models/quiz_question.dart`:

```dart
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;     // sempre 4 opções
  final int correctIndex;         // índice da resposta correta (0-3)
  final String? explanation;      // explicação da resposta (mostrar após responder)

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });
}

class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int score;              // 0-100
  final bool approved;          // score >= 70
  final DateTime completedAt;
  final List<int> userAnswers;  // índices das respostas do aluno

  bool get approved => score >= 70;
}
```

### Banco de questões mock por NR

Criar `lib/services/quiz_service.dart`:

```dart
class QuizService {
  /// Retorna as questões de avaliação para um curso específico.
  /// Cada curso tem seu próprio banco de questões — nunca reutilizar
  /// questões entre NRs diferentes.
  static List<QuizQuestion> getQuestionsForCourse(String courseId) {
    switch (courseId) {
      case 'nr35': return _nr35Questions;
      case 'nr10': return _nr10Questions;
      case 'nr12': return _nr12Questions;
      case 'nr23': return _nr23Questions;
      case 'nr06': return _nr06Questions;
      default: return _genericQuestions;
    }
  }

  static const _nr35Questions = [
    QuizQuestion(
      id: 'nr35_01',
      question: 'Qual a altura mínima definida pela NR-35 para considerar trabalho em altura?',
      options: ['1 metro', '1,5 metros', '2 metros', '3 metros'],
      correctIndex: 2,
      explanation: 'A NR-35 define como trabalho em altura qualquer atividade executada acima de 2,00m do nível inferior, onde haja risco de queda.',
    ),
    QuizQuestion(
      id: 'nr35_02',
      question: 'O que é obrigatório elaborar antes de iniciar qualquer trabalho em altura?',
      options: [
        'Apenas usar cinto de segurança',
        'Análise de Risco (AR) e, quando aplicável, Permissão de Trabalho (PT)',
        'Avisar o supervisor imediato',
        'Instalar rede de proteção'
      ],
      correctIndex: 1,
      explanation: 'A NR-35 exige elaboração de Análise de Risco (AR) antes de cada trabalho em altura. A Permissão de Trabalho (PT) é exigida para atividades de risco elevado.',
    ),
    QuizQuestion(
      id: 'nr35_03',
      question: 'Com que frequência os EPIs de proteção contra quedas devem ser inspecionados?',
      options: ['Mensalmente', 'A cada 6 meses', 'Anualmente', 'Antes de cada uso e periodicamente conforme fabricante'],
      correctIndex: 3,
      explanation: 'Os EPIs devem ser inspecionados antes de cada uso pelo próprio trabalhador e periodicamente por pessoa habilitada, conforme recomendação do fabricante.',
    ),
    QuizQuestion(
      id: 'nr35_04',
      question: 'Qual o prazo de validade do treinamento de trabalho em altura (NR-35)?',
      options: ['1 ano', '2 anos', '3 anos', '5 anos'],
      correctIndex: 1,
      explanation: 'O treinamento da NR-35 tem validade de 2 anos. Também é obrigatório realizar treinamento periódico sempre que houver mudança nas condições de trabalho.',
    ),
    QuizQuestion(
      id: 'nr35_05',
      question: 'O que caracteriza um Sistema de Proteção Coletiva contra quedas?',
      options: [
        'Uso de cinto de segurança por todos os trabalhadores',
        'Instalação de corda de segurança',
        'Andaimes, guarda-corpos, redes de proteção e telas — medidas que protegem todos independentemente de ação individual',
        'Sinalização de área de risco'
      ],
      correctIndex: 2,
      explanation: 'Proteções Coletivas (EPC) são prioritárias sobre proteções individuais (EPI). Exemplos: andaimes, plataformas, guarda-corpos, redes e telas de proteção.',
    ),
    QuizQuestion(
      id: 'nr35_06',
      question: 'Em caso de resgate de trabalhador inconsciente suspenso em altura, qual a preocupação crítica?',
      options: [
        'Aguardar o SAMU antes de qualquer ação',
        'Remover o EPI imediatamente para facilitar o resgate',
        'Síndrome do arnês — posição horizontal o mais rápido possível para evitar colapso circulatório',
        'Cortar a corda de segurança para descê-lo mais rápido'
      ],
      correctIndex: 2,
      explanation: 'A síndrome do arnês (trauma de suspensão) pode causar morte em minutos. O trabalhador deve ser colocado em posição horizontal imediatamente após o resgate.',
    ),
    QuizQuestion(
      id: 'nr35_07',
      question: 'Quem pode ministrar o treinamento de NR-35?',
      options: [
        'Qualquer trabalhador com experiência em altura',
        'Profissional legalmente habilitado ou qualificado, com capacitação em NR-35',
        'Apenas engenheiros de segurança do trabalho',
        'O próprio supervisor da obra'
      ],
      correctIndex: 1,
      explanation: 'O treinamento deve ser ministrado por profissional legalmente habilitado (engenheiro, técnico de segurança) ou qualificado, com capacitação específica em trabalho em altura.',
    ),
    QuizQuestion(
      id: 'nr35_08',
      question: 'O que deve conter o plano de resgate antes de iniciar trabalho em altura?',
      options: [
        'Apenas o número do SAMU',
        'Procedimentos de resgate, equipamentos disponíveis, responsáveis treinados e contatos de emergência',
        'Somente a localização do hospital mais próximo',
        'Lista de EPIs disponíveis no canteiro'
      ],
      correctIndex: 1,
      explanation: 'O plano de resgate deve ser elaborado antes do início da atividade, contemplando procedimentos, equipamentos, pessoal treinado e contatos de emergência.',
    ),
    QuizQuestion(
      id: 'nr35_09',
      question: 'Trabalhador com acrofobia (medo de altura) pode realizar trabalho em altura?',
      options: [
        'Sim, desde que use todos os EPIs',
        'Sim, se o supervisor autorizar',
        'Não — a NR-35 exige aptidão médica. Condições que comprometam o equilíbrio são impeditivas',
        'Sim, desde que seja em altura menor que 5 metros'
      ],
      correctIndex: 2,
      explanation: 'A NR-35 exige que o trabalhador seja considerado apto pelo médico do trabalho. Condições que afetam equilíbrio, consciência ou coordenação motora são impeditivas.',
    ),
    QuizQuestion(
      id: 'nr35_10',
      question: 'O ponto de ancoragem para trabalho em altura deve suportar no mínimo:',
      options: ['200 kg', '300 kg', '500 kg', '1000 kg'],
      correctIndex: 0,
      explanation: 'Conforme NR-35, o ponto de ancoragem deve ser capaz de suportar pelo menos 15 kN (aproximadamente 1.500 kgf) para quedas com fator ≥ 1, ou conforme especificação do fabricante do EPI.',
    ),
  ];

  // Adicionar questões similares para NR-10, NR-12, NR-23, NR-06
  // (5 questões cada no mínimo para o mock)
  static const _nr10Questions = [ /* 5+ questões NR-10 */ ];
  static const _nr12Questions = [ /* 5+ questões NR-12 */ ];
  static const _nr23Questions = [ /* 5+ questões NR-23 */ ];
  static const _nr06Questions = [ /* 5+ questões NR-06 */ ];
  static const _genericQuestions = [ /* questões genéricas de segurança */ ];
}
```

### Layout da QuizScreen

Criar `lib/screens/student/quiz_screen.dart`:

**Header:**
- AppBar: "Avaliação Final"
- Subtítulo: "[Nome do curso] · Mínimo 70% para aprovação"

**Corpo (uma pergunta por vez):**
- Indicador: "Pergunta 3 de 10" + LinearProgressIndicator
- Texto da pergunta (16px, fontWeight.w600, padding generoso)
- 4 alternativas como Cards clicáveis:
  - Normal: borda sutil, fundo neutro
  - Selecionado (antes de confirmar): borda azul, fundo azul claro
  - Correto (após confirmar): borda verde + ícone ✓ + fundo verde claro
  - Errado (após confirmar): borda vermelha + ícone ✗ + fundo vermelho claro
  - Resposta correta destacada mesmo quando aluno errou

**Após confirmar resposta:**
- Card de explicação expandido abaixo das alternativas
- Texto da explicação em itálico (question.explanation)
- Botão "Próxima pergunta" (ou "Ver resultado" na última)

**Tela de resultado:**
- Ícone grande: ✓ verde (aprovado) ou ✗ vermelho (reprovado)
- Nota em destaque: "8/10 — 80%"
- Barra mostrando 80% preenchida
- Status: "Aprovado! Você pode emitir o certificado." ou
          "Reprovado. Você precisa de 70% para passar."
- Se aprovado: salvar QuizResult no EnrollmentService/Provider
  e checar CertificateEligibilityService.check(...)
  - Se todas as 3 condições ok → botão "Emitir certificado" → CertificateScreen
  - Se ainda falta algo → CertificateEligibilityCard mostrando o que falta
- Se reprovado: botão "Tentar novamente" (reset estado do quiz)
               + botão "Revisar aulas" → volta para CourseScreen

**Conectar:**
- Em CourseScreen: quando progress >= 75%, mostrar botão "Fazer avaliação"
- Se quiz já foi feito e aprovado: mostrar CertificateEligibilityCard
- Salvar resultado do quiz no enrollment: `enrollment.quizScore = result.score`

**Critério de aceite:**
- Quiz funciona do início ao fim para NR-35 (10 questões)
- Nota calculada corretamente
- Explicação de cada resposta exibida após confirmar
- Resultado salvo no enrollment
- CertificateEligibilityService consultado corretamente no resultado

---

## TAREFA 4 — Atualizar CertificateScreen com validação real

Agora que o CertificateEligibilityService existe, atualizar a tela de
certificado para consultar o serviço antes de exibir/permitir o download.

Em `lib/screens/student/certificate_screen.dart`:

```dart
// No initState ou build, verificar elegibilidade
final enrollment = enrollmentProvider.getEnrollment(courseId);
final user = authService.currentUser;

final eligibility = CertificateEligibilityService.check(
  progressPercent: enrollment.progressPercent,
  quizScore: enrollment.quizScore,
  userCpf: user?.cpf,
  userCompany: user?.company,
);

if (!eligibility.isEligible) {
  // Mostrar CertificateEligibilityCard em vez do certificado
  return CertificateEligibilityCard(
    result: eligibility,
    onStartQuiz: () => context.push('/quiz/$courseId'),
    onCompleteProfile: () => context.push('/profile/personal-data'),
  );
}

// Se elegível: exibir o certificado completo
```

**O certificado deve exibir:**
- Nome completo do aluno (do perfil)
- CPF do aluno (do perfil)
- Empresa do aluno (do perfil)
- Nome do curso + código NR
- Carga horária
- Nota obtida na avaliação: "Aprovado com X%"
- Data de conclusão (hoje)
- Data de validade (hoje + 2 anos)
- Nome e registro do instrutor (do mock do curso)
- CNPJ da CRP Engenharia
- QR code com código único: "CRP-[COURSE_CODE]-[USER_ID_CURTO]-[ANO]"
- URL de validação: "Valide em: crpengenharia.com.br/validar/[codigo]"

**Critério de aceite:**
- Certificado só exibe quando as 3 condições são atendidas
- Dados do aluno aparecem corretamente no certificado
- Botão de download/compartilhar funciona (mock OK)

---

## TAREFA 5 — Splash screen com verificação de autenticação

Criar ou refatorar `lib/screens/splash_screen.dart`:

```dart
class SplashScreen extends StatefulWidget { ... }

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    // Auth já foi restaurada no main() antes do runApp
    final auth = context.read<AuthService>();
    if (auth.isAuthenticated) {
      context.go('/home?tab=my_courses');
    } else {
      context.go('/home?tab=catalog');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E0E12) : const Color(0xFF1A2A4A),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo CRP (usar logo real se disponível em assets)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text('CRP',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Engenharia',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Cursos & Treinamentos NR',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

Definir como rota inicial no GoRouter:
```dart
initialLocation: '/splash',
GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
```

**Critério de aceite:**
- Splash com animação fade+scale abre ao iniciar o app
- Após ~2s: vai para Meus Cursos (logado) ou Catálogo (não logado)
- Não aparece ao navegar entre telas — apenas na abertura do app

---

## TAREFA 6 — Shimmer + Estados vazios + Filtro de categoria

### 6a. Shimmer loading

```bash
flutter pub add shimmer
```

Criar `lib/widgets/shimmer_card.dart`:
- ShimmerCourseCard — skeleton de um card de curso (altura 120px)
- ShimmerList({int count = 3}) — coluna com N shimmer cards
- Usar cor correta para dark/light mode

Aplicar em: HomeScreen, MyCoursesScreen, CourseScreen
— substituir conteúdo quando `isLoading == true`

### 6b. Estado vazio

Criar `lib/widgets/empty_state.dart`:
```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;
  // Ícone grande + título + subtítulo + botão opcional
}
```

Usar em:
- MyCoursesScreen vazia → "Nenhum curso ainda" + botão "Explorar catálogo"
- Certificados vazios → "Nenhum certificado ainda" + botão "Ver meus cursos"
- Resultado de busca vazio → "Nenhum curso encontrado para '[query]'"

### 6c. Estado de erro

Criar `lib/widgets/error_state.dart`:
```dart
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  // Ícone de alerta + mensagem + botão "Tentar novamente"
}
```

### 6d. Filtro de categoria no catálogo

Em HomeScreen adicionar chips horizontais acima da lista:

```dart
// Estado
String _selectedCategory = 'Todos';
final categories = ['Todos', 'Eletricidade', 'Altura', 'Máquinas',
                    'Incêndio', 'Segurança', 'Ergonomia', 'Cargas'];

// Widget: SingleChildScrollView horizontal com ChoiceChips
// Filtro combinado: categoria + busca por texto aplicados juntos
void _applyFilters() {
  _filteredCourses = _allCourses.where((c) {
    final catOk = _selectedCategory == 'Todos' ||
                  c.category == _selectedCategory;
    final searchOk = _searchQuery.isEmpty ||
                     c.title.toLowerCase().contains(_searchQuery) ||
                     c.code.toLowerCase().contains(_searchQuery);
    return catOk && searchOk;
  }).toList();
}
```

**Critério de aceite:**
- Shimmer aparece antes dos cursos carregarem
- EmptyState aparece quando lista está vazia
- Chips de categoria filtram corretamente
- Busca + categoria funcionam juntos

---

## APÓS CONCLUIR TODAS AS 6 TAREFAS

Execute e reporte:
```bash
flutter analyze
flutter build apk --debug
```

Informe:
1. Quais tarefas foram concluídas
2. Arquivos criados/modificados
3. Problemas encontrados e como foram resolvidos
4. Percentual estimado de progresso do MVP

---

## COMECE AGORA PELA TAREFA 1 — CertificateEligibilityService

Esta é a base legal do produto. Implemente apenas a Tarefa 1
e aguarde confirmação antes de avançar.
