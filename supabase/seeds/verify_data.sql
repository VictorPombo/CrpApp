-- ═══════════════════════════════════════
-- VERIFICAÇÃO: Dados inseridos?
-- ═══════════════════════════════════════

-- Verifica se tabelas existem e contém dados
SELECT 'lesson_content' as tabela, COUNT(*) as total FROM lesson_content
UNION ALL
SELECT 'quizzes', COUNT(*) FROM quizzes
UNION ALL
SELECT 'quiz_questions', COUNT(*) FROM quiz_questions;

-- Verifica conteúdo NR-10 especificamente
SELECT lesson_id, content_type, title FROM lesson_content WHERE course_id = 'nr10' LIMIT 5;

-- Verifica quizzes NR-10
SELECT module_id, title FROM quizzes WHERE course_id = 'nr10';
