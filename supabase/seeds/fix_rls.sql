-- ═══════════════════════════════════════
-- FIX: Corrigir acesso RLS para tabelas de conteúdo
-- ═══════════════════════════════════════

-- Primeiro, remover policies que possam estar quebradas
DROP POLICY IF EXISTS "lesson_content_select" ON lesson_content;
DROP POLICY IF EXISTS "quizzes_select" ON quizzes;
DROP POLICY IF EXISTS "quiz_questions_select" ON quiz_questions;
DROP POLICY IF EXISTS "Anyone can view lesson_content" ON lesson_content;
DROP POLICY IF EXISTS "Anyone can view quizzes" ON quizzes;
DROP POLICY IF EXISTS "Anyone can view quiz_questions" ON quiz_questions;

-- Recriar policies de leitura pública
CREATE POLICY "public_read_lesson_content" ON lesson_content
  FOR SELECT USING (true);

CREATE POLICY "public_read_quizzes" ON quizzes
  FOR SELECT USING (true);

CREATE POLICY "public_read_quiz_questions" ON quiz_questions
  FOR SELECT USING (true);

-- Verificar que funcionou
SELECT 'lesson_content' as tabela, COUNT(*) as total FROM lesson_content
UNION ALL SELECT 'quizzes', COUNT(*) FROM quizzes
UNION ALL SELECT 'quiz_questions', COUNT(*) FROM quiz_questions;
