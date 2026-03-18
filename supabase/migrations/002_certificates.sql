-- ══════════════════════════════════════════════════════
-- Migration 002: Tabela de Certificados
-- ══════════════════════════════════════════════════════
-- Armazena certificados emitidos permanentemente.
-- Cada certificado tem serial único (como um RG),
-- hash SHA-256 para autenticidade, e dados imutáveis.
-- ══════════════════════════════════════════════════════

-- 1. Criar tabela certificates
CREATE TABLE IF NOT EXISTS public.certificates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  course_id TEXT NOT NULL,
  course_code TEXT NOT NULL,
  course_title TEXT NOT NULL,
  course_hours INTEGER NOT NULL DEFAULT 0,

  -- Dados do aluno (imutáveis após emissão)
  student_name TEXT NOT NULL,
  student_cpf TEXT DEFAULT '',
  company TEXT DEFAULT '',

  -- Serial único — como um RG do certificado
  -- Formato: CRP-{ANO}-{CODIGO}-{HASH_CURTO}
  cert_code TEXT NOT NULL UNIQUE,

  -- Hash SHA-256 para verificação de autenticidade
  hash TEXT NOT NULL,

  -- Resultado da avaliação
  quiz_score INTEGER NOT NULL DEFAULT 0,

  -- Instrutor responsável
  instructor_name TEXT DEFAULT 'Eng. Carlos Roberto Palácio',
  instructor_crea TEXT DEFAULT 'CREA-SP · RNP 2614455296',

  -- Datas
  issued_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  valid_until TIMESTAMPTZ NOT NULL,
  status TEXT DEFAULT 'valid' CHECK (status IN ('valid', 'expired', 'revoked')),

  -- Evitar duplicatas: 1 certificado por usuário por curso
  CONSTRAINT unique_user_course UNIQUE (user_id, course_id),

  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Índices para busca rápida
CREATE INDEX IF NOT EXISTS idx_certificates_cert_code ON public.certificates(cert_code);
CREATE INDEX IF NOT EXISTS idx_certificates_user_id ON public.certificates(user_id);
CREATE INDEX IF NOT EXISTS idx_certificates_course_id ON public.certificates(course_id);

-- 3. Habilitar RLS
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;

-- 4. Políticas de segurança:

-- Usuário pode VER seus próprios certificados
CREATE POLICY "Users can view own certificates"
  ON public.certificates FOR SELECT
  USING (auth.uid() = user_id);

-- Usuário pode INSERIR seu próprio certificado (emissão)
CREATE POLICY "Users can issue own certificates"
  ON public.certificates FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- NINGUÉM pode alterar certificados após emissão (imutável)
-- (Sem política UPDATE = certificados são permanentes)

-- 5. Política PÚBLICA para validação de certificados
-- Qualquer pessoa pode buscar um certificado pelo serial
-- (para verificar autenticidade sem login)
CREATE POLICY "Anyone can validate certificates by serial"
  ON public.certificates FOR SELECT
  USING (true);

-- ══════════════════════════════════════════════════════
-- Executar no Supabase Dashboard → SQL Editor → Run
-- ══════════════════════════════════════════════════════
