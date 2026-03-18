-- ═══════════════════════════════════════════════════════════════
-- Migration 003: Conteúdo dos Cursos (Apostilas, Vídeos, Quizzes)
-- ═══════════════════════════════════════════════════════════════

-- 1. Conteúdo das aulas (apostila + vídeo)
CREATE TABLE IF NOT EXISTS lesson_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id TEXT NOT NULL,
  course_id TEXT NOT NULL,
  content_type TEXT NOT NULL CHECK (content_type IN ('apostila', 'video')),
  title TEXT NOT NULL,
  body TEXT,
  video_url TEXT,
  sort_order INT DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Quizzes (1 por módulo)
CREATE TABLE IF NOT EXISTS quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id TEXT NOT NULL,
  module_id TEXT,
  title TEXT NOT NULL,
  passing_score INT DEFAULT 70,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Questões dos quizzes (5 alternativas)
CREATE TABLE IF NOT EXISTS quiz_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  option_a TEXT NOT NULL,
  option_b TEXT NOT NULL,
  option_c TEXT NOT NULL,
  option_d TEXT NOT NULL,
  option_e TEXT NOT NULL,
  correct_option CHAR(1) NOT NULL CHECK (correct_option IN ('a','b','c','d','e')),
  explanation TEXT,
  sort_order INT DEFAULT 1
);

-- 4. Tentativas dos alunos
CREATE TABLE IF NOT EXISTS quiz_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  quiz_id UUID REFERENCES quizzes(id),
  score INT NOT NULL,
  answers JSONB NOT NULL,
  passed BOOLEAN NOT NULL,
  attempted_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, quiz_id)
);

-- ═══════════════════════════════════════════════════════════════
-- Indexes
-- ═══════════════════════════════════════════════════════════════
CREATE INDEX IF NOT EXISTS idx_lesson_content_lesson ON lesson_content(lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_content_course ON lesson_content(course_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_course ON quizzes(course_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_module ON quizzes(module_id);
CREATE INDEX IF NOT EXISTS idx_quiz_questions_quiz ON quiz_questions(quiz_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user ON quiz_attempts(user_id);

-- ═══════════════════════════════════════════════════════════════
-- RLS Policies
-- ═══════════════════════════════════════════════════════════════
ALTER TABLE lesson_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;

-- Conteúdo: leitura pública (qualquer usuário autenticado)
CREATE POLICY "lesson_content_select" ON lesson_content
  FOR SELECT USING (true);

-- Quizzes: leitura pública
CREATE POLICY "quizzes_select" ON quizzes
  FOR SELECT USING (true);

-- Questões: leitura pública
CREATE POLICY "quiz_questions_select" ON quiz_questions
  FOR SELECT USING (true);

-- Tentativas: apenas o próprio usuário
CREATE POLICY "quiz_attempts_select" ON quiz_attempts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "quiz_attempts_insert" ON quiz_attempts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Permitir UPDATE para re-tentativa (UPSERT)
CREATE POLICY "quiz_attempts_update" ON quiz_attempts
  FOR UPDATE USING (auth.uid() = user_id);
