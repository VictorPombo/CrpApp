# PROMPT — MIGRAÇÃO COMPLETA PARA SUPABASE
# CRP Cursos — Backend real + Otimização do app

---

## REGRA OBRIGATÓRIA

Ao concluir CADA tarefa, atualizar `docs/crp_dev_dashboard.html`:
- Itens concluídos: status → `"done"`
- Novos itens descobertos: adicionar com status correto
- Salvar antes de avançar

---

## CONTEXTO

O app CRP Cursos usa atualmente dados mock + SharedPreferences.
Este prompt guia a migração completa para Supabase como backend real.

**Pré-requisitos (fazer antes de rodar este prompt):**
1. Criar conta em supabase.com (gratuito)
2. Criar novo projeto "crp-cursos"
3. Gerar Access Token em supabase.com/dashboard/account/tokens
4. Conectar Supabase MCP no Antigravity:
   MCP → Manage Servers → Supabase → colar token

**Importante sobre planos:**
- Gratuito: OK para desenvolvimento e testes
- Pro ($25/mês ≈ R$140): obrigatório antes do primeiro cliente pagar
  (evita pausa automática do banco após 7 dias sem uso)

---

## PARTE 1 — AUDITORIA: O QUE PRECISA SER MIGRADO

Antes de codar, auditar TODO o código e listar o que usa mock/local:

### 1.1 — Dados que saem do SharedPreferences para o Supabase

```
AUTH:
├── Usuário atual (id, name, email, cpf, company, role)
├── Sessão JWT (token, refresh token)
└── Preferência de tema (MANTER local — não vai para o banco)

CURSOS:
├── Lista de cursos → tabela courses
├── Módulos → tabela modules
├── Aulas → tabela lessons
└── Materiais → tabela lesson_materials + Supabase Storage

PROGRESSO DO ALUNO:
├── Enrollments (matrícula em curso) → tabela enrollments
├── Aulas concluídas → tabela lesson_progress
└── Anotações por aula → tabela lesson_notes

QUIZ:
├── Questões (sem gabarito) → tabela quiz_questions
├── Gabarito (correctIndex) → tabela quiz_answers (RLS restritivo)
├── Resultados do quiz → tabela quiz_results
└── Validação das respostas → Edge Function (nunca no cliente)

PAGAMENTOS:
├── Compras realizadas → tabela payments
└── Status de pagamento → atualizado por webhook do Mercado Pago

CERTIFICADOS:
├── Certificados emitidos → tabela certificates
└── PDF gerado → Supabase Storage (pasta /certificates)
```

### 1.2 — O que DEVE FICAR local (não migrar)

```
MANTER NO DISPOSITIVO:
├── Preferência de tema claro/escuro → SharedPreferences
├── Anotações offline (cache) → SharedPreferences com sync posterior
├── Dados do usuário em cache → SharedPreferences (atualiza no login)
└── Token de sessão → SharedPreferences (gerenciado pelo supabase_flutter)
```

---

## PARTE 2 — SCHEMA DO BANCO DE DADOS

Criar todas as tabelas no Supabase via MCP:

### 2.1 — Tabelas principais

```sql
-- USUÁRIOS (gerenciado pelo Supabase Auth + perfil estendido)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  name TEXT NOT NULL,
  cpf TEXT,
  phone TEXT,
  company TEXT,
  job_title TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'student' CHECK (role IN ('student', 'admin')),
  two_factor_enabled BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- CURSOS
CREATE TABLE courses (
  id TEXT PRIMARY KEY, -- 'nr35', 'nr10', etc.
  code TEXT NOT NULL,  -- 'NR-35'
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  hours INTEGER,
  price DECIMAL(10,2),
  rating DECIMAL(3,1) DEFAULT 0,
  rating_count INTEGER DEFAULT 0,
  badge TEXT,
  instructor_name TEXT,
  instructor_register TEXT,
  instructor_bio TEXT,
  thumbnail_color_start TEXT,
  thumbnail_color_end TEXT,
  validity_years INTEGER DEFAULT 2,
  target_audience TEXT,
  is_published BOOLEAN DEFAULT FALSE,
  is_featured BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- MÓDULOS
CREATE TABLE modules (
  id TEXT PRIMARY KEY,
  course_id TEXT REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  sort_order INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- AULAS
CREATE TABLE lessons (
  id TEXT PRIMARY KEY,
  module_id TEXT REFERENCES modules(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  video_url TEXT,           -- Cloudflare Stream URL (fase futura)
  duration_seconds INTEGER,
  sort_order INTEGER NOT NULL,
  is_free BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- MATERIAIS DAS AULAS
CREATE TABLE lesson_materials (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  lesson_id TEXT REFERENCES lessons(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  file_url TEXT NOT NULL,   -- Supabase Storage URL
  file_type TEXT,           -- 'pdf', 'pptx', 'xlsx'
  file_size_bytes INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- MATRÍCULAS (quem comprou qual curso)
CREATE TABLE enrollments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  course_id TEXT REFERENCES courses(id),
  status TEXT DEFAULT 'active' CHECK (status IN ('active','completed','expired')),
  progress_pct DECIMAL(5,2) DEFAULT 0,
  quiz_score INTEGER,       -- null até fazer o quiz
  quiz_approved BOOLEAN DEFAULT FALSE,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  UNIQUE(user_id, course_id)
);

-- PROGRESSO POR AULA
CREATE TABLE lesson_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  enrollment_id UUID REFERENCES enrollments(id) ON DELETE CASCADE,
  lesson_id TEXT REFERENCES lessons(id),
  completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  watch_seconds INTEGER DEFAULT 0,  -- segundos assistidos
  UNIQUE(enrollment_id, lesson_id)
);

-- ANOTAÇÕES POR AULA
CREATE TABLE lesson_notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  lesson_id TEXT REFERENCES lessons(id),
  content TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, lesson_id)
);

-- QUIZ — QUESTÕES (sem gabarito — acesso público para alunos matriculados)
CREATE TABLE quiz_questions (
  id TEXT PRIMARY KEY,
  course_id TEXT REFERENCES courses(id),
  question TEXT NOT NULL,
  options JSONB NOT NULL,   -- List<String> com 4 opções
  difficulty TEXT CHECK (difficulty IN ('easy','medium','hard')),
  topic TEXT,
  sort_order INTEGER DEFAULT 0
);

-- QUIZ — GABARITO (acesso BLOQUEADO para clientes — só Edge Function lê)
CREATE TABLE quiz_answers (
  question_id TEXT REFERENCES quiz_questions(id) PRIMARY KEY,
  correct_index INTEGER NOT NULL CHECK (correct_index BETWEEN 0 AND 3),
  explanation TEXT NOT NULL
);

-- RESULTADOS DO QUIZ
CREATE TABLE quiz_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  course_id TEXT REFERENCES courses(id),
  enrollment_id UUID REFERENCES enrollments(id),
  score INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  correct_answers INTEGER NOT NULL,
  approved BOOLEAN NOT NULL,
  time_taken_seconds INTEGER,
  answers JSONB,            -- respostas do aluno (índices)
  completed_at TIMESTAMPTZ DEFAULT NOW()
);

-- PAGAMENTOS
CREATE TABLE payments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  course_id TEXT REFERENCES courses(id),
  amount DECIMAL(10,2) NOT NULL,
  method TEXT,              -- 'pix', 'credit_card', 'boleto'
  status TEXT DEFAULT 'pending'
    CHECK (status IN ('pending','approved','refused','refunded')),
  external_id TEXT,         -- ID do Mercado Pago
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- CERTIFICADOS
CREATE TABLE certificates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  course_id TEXT REFERENCES courses(id),
  enrollment_id UUID REFERENCES enrollments(id),
  certificate_code TEXT UNIQUE NOT NULL,
  quiz_score INTEGER NOT NULL,
  pdf_url TEXT,             -- Supabase Storage URL
  issued_at TIMESTAMPTZ DEFAULT NOW(),
  valid_until TIMESTAMPTZ NOT NULL,
  revoked BOOLEAN DEFAULT FALSE,
  revoked_at TIMESTAMPTZ
);
```

### 2.2 — Row Level Security (RLS)

```sql
-- Habilitar RLS em todas as tabelas
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;

-- Perfil: usuário só vê e edita o próprio
CREATE POLICY "perfil_proprio" ON profiles
  FOR ALL USING (auth.uid() = id);

-- Matrículas: usuário só vê as próprias
CREATE POLICY "enrollment_proprio" ON enrollments
  FOR ALL USING (auth.uid() = user_id);

-- Progresso: usuário só vê o próprio
CREATE POLICY "progress_proprio" ON lesson_progress
  FOR ALL USING (
    enrollment_id IN (
      SELECT id FROM enrollments WHERE user_id = auth.uid()
    )
  );

-- Anotações: usuário só vê as próprias
CREATE POLICY "notes_proprias" ON lesson_notes
  FOR ALL USING (auth.uid() = user_id);

-- GABARITO: NINGUÉM lê pelo cliente — só Edge Function (service_role)
CREATE POLICY "gabarito_bloqueado" ON quiz_answers
  FOR ALL USING (FALSE); -- bloqueia 100% o acesso pelo cliente

-- Certificados: usuário só vê os próprios
CREATE POLICY "certificados_proprios" ON certificates
  FOR SELECT USING (auth.uid() = user_id);

-- Cursos e questões: leitura pública (sem autenticação)
CREATE POLICY "cursos_publicos" ON courses
  FOR SELECT USING (is_published = TRUE);
CREATE POLICY "questoes_publicas" ON quiz_questions
  FOR SELECT USING (TRUE);
```

### 2.3 — Edge Function: validação segura do quiz

```typescript
// supabase/functions/submit-quiz/index.ts
// Esta função é o único lugar que lê quiz_answers
// O cliente NUNCA vê o gabarito

import { serve } from 'https://deno.land/std/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js'

serve(async (req) => {
  const { courseId, enrollmentId, userAnswers } = await req.json()
  // userAnswers: Map<questionId, selectedIndex>

  // Usar service_role — bypassa RLS para ler quiz_answers
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Buscar gabarito (só a Edge Function tem acesso)
  const { data: answers } = await supabase
    .from('quiz_answers')
    .select('question_id, correct_index, explanation')
    .in('question_id', Object.keys(userAnswers))

  // Calcular resultado
  let correct = 0
  const feedback = answers.map(a => {
    const isCorrect = userAnswers[a.question_id] === a.correct_index
    if (isCorrect) correct++
    return {
      questionId: a.question_id,
      correct: isCorrect,
      correctIndex: a.correct_index,  // revelado só após responder
      explanation: a.explanation,
    }
  })

  const score = Math.round((correct / answers.length) * 100)
  const approved = score >= 70

  // Salvar resultado
  await supabase.from('quiz_results').insert({
    user_id: req.headers.get('x-user-id'),
    course_id: courseId,
    enrollment_id: enrollmentId,
    score, correct_answers: correct,
    total_questions: answers.length,
    approved,
    answers: userAnswers,
  })

  // Se aprovado, atualizar enrollment
  if (approved) {
    await supabase.from('enrollments')
      .update({ quiz_score: score, quiz_approved: true })
      .eq('id', enrollmentId)
  }

  // Retornar resultado SEM expor gabarito antecipadamente
  return new Response(JSON.stringify({ score, approved, feedback }))
})
```

---

## PARTE 3 — MIGRAÇÃO DO CÓDIGO FLUTTER

### 3.1 — Instalar dependências

```bash
flutter pub add supabase_flutter
flutter pub add cached_network_image  # imagens com cache
flutter pub add flutter_cache_manager  # cache de arquivos
```

### 3.2 — Inicialização em main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    // authOptions com persistência automática de sessão
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const CrpApp());
}

// Acessar em qualquer lugar:
final supabase = Supabase.instance.client;
```

### 3.3 — Trocar MockAuthService por SupabaseAuthService

```dart
// Apenas ESTA troca no main.dart — nenhuma tela muda
// ANTES:
ChangeNotifierProvider(create: (_) => MockAuthService())
// DEPOIS:
ChangeNotifierProvider(create: (_) => SupabaseAuthService())
```

### 3.4 — Trocar MockCourseService por SupabaseCourseService

```dart
// ANTES: carregava de assets/mock_data/courses.json
// DEPOIS: busca do Supabase com cache local

class SupabaseCourseService {
  Future<List<Course>> getCourses() async {
    final data = await supabase
      .from('courses')
      .select('*, modules(*, lessons(*))')
      .eq('is_published', true)
      .order('is_featured', ascending: false);
    return data.map(Course.fromJson).toList();
  }
}
```

### 3.5 — Quiz: remover gabarito do cliente

```dart
// ANTES: app calculava nota localmente com correctIndex
// DEPOIS: app envia respostas → Edge Function valida → retorna resultado

Future<QuizResult> submitQuiz(
  String courseId,
  String enrollmentId,
  Map<String, int> userAnswers,
) async {
  final response = await supabase.functions.invoke(
    'submit-quiz',
    body: {
      'courseId': courseId,
      'enrollmentId': enrollmentId,
      'userAnswers': userAnswers,
    },
  );
  return QuizResult.fromJson(response.data);
}
```

---

## PARTE 4 — OTIMIZAÇÃO DO APP (PESO E PERFORMANCE)

**Objetivo:** app leve, rápido e que funcione bem em dispositivos
modestos (Android entry-level com 2-3 GB RAM).

### 4.1 — Auditoria de assets (fazer agora)

```bash
# Verificar tamanho atual do bundle
flutter build apk --analyze-size
flutter build web --release

# O relatório mostra o que está pesando mais
```

Remover do projeto:
- Fontes não usadas (verificar pubspec.yaml → fonts)
- Imagens PNG de alta resolução → converter para WebP
- Arquivos JSON grandes no bundle → mover para Supabase
- Dependências não utilizadas (`flutter pub deps`)

### 4.2 — Imagens otimizadas

```dart
// Nunca usar Image.network() diretamente
// Sempre usar CachedNetworkImage com placeholder

CachedNetworkImage(
  imageUrl: course.thumbnailUrl,
  placeholder: (_, __) => ShimmerCourseCard(),
  errorWidget: (_, __, ___) => CourseCardPlaceholder(),
  // Cache automático em disco — não baixa de novo
  memCacheWidth: 400,   // limita tamanho em memória
  memCacheHeight: 225,
)
```

### 4.3 — Lazy loading de dados

```dart
// Nunca carregar todos os 36 cursos de uma vez
// Usar paginação desde o início

Future<List<Course>> getCourses({
  int page = 0,
  int pageSize = 10,
  String? category,
}) async {
  var query = supabase
    .from('courses')
    .select()
    .eq('is_published', true)
    .range(page * pageSize, (page + 1) * pageSize - 1);

  if (category != null && category != 'Todos') {
    query = query.eq('category', category);
  }
  return (await query).map(Course.fromJson).toList();
}
```

### 4.4 — Cache inteligente com Supabase

```dart
// Estratégia: cache-first com revalidação
// 1. Mostrar dados do cache imediatamente (sem loading)
// 2. Buscar dados novos em background
// 3. Atualizar UI silenciosamente se houver mudança

class CacheService {
  static const Duration courseCacheDuration = Duration(hours: 24);
  static const Duration userDataCacheDuration = Duration(minutes: 30);
  static const Duration progressCacheDuration = Duration(minutes: 5);

  // Cursos mudam raramente → cache longo
  // Progresso muda frequentemente → cache curto
}
```

### 4.5 — Regras de otimização para todas as telas

Aplicar em todo o app:

```dart
// 1. const em widgets que não mudam
const Text('CRP Engenharia') // ← compile-time constant

// 2. ListView.builder em vez de ListView com children
ListView.builder(  // só renderiza o que está na tela
  itemCount: courses.length,
  itemBuilder: (_, i) => CourseCard(course: courses[i]),
)

// 3. RepaintBoundary em animações
RepaintBoundary(
  child: AnimatedProgressBar(value: progress),
)

// 4. Evitar rebuild desnecessário com Consumer granular
Consumer<EnrollmentProvider>(
  builder: (_, enrollment, __) => ProgressBar(
    value: enrollment.getProgress(courseId),
  ),
)

// 5. Vídeo: usar Cloudflare Stream com qualidade adaptativa
// Nunca armazenar vídeo no bundle do app
// Player carrega sob demanda via URL
```

### 4.6 — Tamanho máximo alvo do app

| Plataforma | Tamanho alvo | Como atingir |
|---|---|---|
| Android APK | < 25 MB | R8 + ProGuard + split ABI |
| Android App Bundle | < 15 MB base | AAB com dynamic delivery |
| iOS | < 30 MB | Bitcode + strip symbols |
| Web (inicial) | < 2 MB JS | Tree-shaking + deferred loading |

```bash
# Build otimizado Android
flutter build apk --release --split-per-abi
# Gera 3 APKs pequenos (arm64, arm, x86_64)
# Em vez de 1 APK grande com os 3 juntos

# Build Web otimizado
flutter build web --release --pwa-strategy=offline-first
```

### 4.7 — Deferred loading para Flutter Web

```dart
// Módulos carregados só quando necessário
import 'package:crp_cursos/screens/quiz_screen.dart' deferred as quiz;

// Ao navegar para o quiz:
await quiz.loadLibrary(); // baixa só quando o usuário for fazer o quiz
quiz.QuizScreen(courseId: id);
```

---

## PARTE 5 — CHECKLIST FINAL ANTES DO LANÇAMENTO

### Segurança
- [ ] RLS ativo em todas as tabelas com dados sensíveis
- [ ] `quiz_answers` com policy `USING (FALSE)` — 100% bloqueado
- [ ] Edge Function validando quiz no servidor
- [ ] Chaves de API no `.env` — nunca no código
- [ ] `.env` no `.gitignore` — nunca commitado
- [ ] HTTPS obrigatório (Supabase e Vercel já forçam)
- [ ] Certificados com código único e hash de integridade

### Performance
- [ ] `flutter analyze` sem warnings
- [ ] `flutter build apk --analyze-size` — APK < 25 MB
- [ ] Imagens com CachedNetworkImage
- [ ] Listas com ListView.builder
- [ ] Sem `debugPrint` no código de produção
- [ ] Paginação implementada no catálogo

### Dados
- [ ] Todos os dados mock removidos do bundle
- [ ] SharedPreferences usado apenas para preferências locais
- [ ] Sessão Supabase persistida automaticamente
- [ ] Cache com duração adequada por tipo de dado
- [ ] Sync de anotações offline implementado

### Funcional
- [ ] Fluxo completo: cadastro → compra → aula → quiz → certificado
- [ ] Certificado com QR code e URL de validação real
- [ ] Compartilhamento de certificado funcional
- [ ] Logout limpa dados locais corretamente

---

## QUANDO EXECUTAR ESTE PROMPT

**NÃO executar agora.** Este prompt é para a fase de backend.

Executar quando:
1. App mock estiver 100% funcional e testado
2. Conta Supabase criada e token gerado
3. MCP do Supabase conectado no Antigravity
4. Pelo menos 1 curso pronto para subir ao banco

**Ordem de execução:**
1. Parte 2 (schema + RLS) via MCP Supabase
2. Parte 3 (migração Flutter) — trocar services
3. Parte 4 (otimização) — antes do build de produção
4. Parte 5 (checklist) — antes do primeiro cliente

---

## COMECE PELA PARTE 2 — Schema do banco

Quando chegar a hora, iniciar pela criação das tabelas via MCP.
Confirmar cada tabela criada antes de avançar.
**Atualizar `docs/crp_dev_dashboard.html` ao concluir cada parte.**
