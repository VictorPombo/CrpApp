/// Configuração do Supabase — CRP Cursos
///
/// URL e chave pública do projeto Supabase.
/// A chave pública (anon) é segura para uso no cliente.
/// A chave secreta (service_role) NUNCA deve ir no código do app.
class SupabaseConfig {
  static const String url = 'https://asyicusgdulqjfoqfibi.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzeWljdXNnZHVscWpmb3FmaWJpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM3Njk5MDAsImV4cCI6MjA4OTM0NTkwMH0.opGIGHjPwmUigVAdarIsuwrEDt4fewJuofB8h-OEZ9Q';

  /// Flag para controlar mock vs Supabase Auth real.
  ///
  /// - `false` → usa AuthService mock (SharedPreferences) — padrão para dev
  /// - `true`  → usa SupabaseAuthService real (requer tabela profiles no Supabase)
  ///
  /// Para ativar: trocar para true APÓS executar o SQL migration no Supabase.
  static const bool useSupabaseAuth = true;
}
