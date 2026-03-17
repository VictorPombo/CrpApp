/// Configuração do Supabase — CRP Cursos
///
/// URL e chave pública do projeto Supabase.
/// A chave pública (anon) é segura para uso no cliente.
/// A chave secreta (service_role) NUNCA deve ir no código do app.
class SupabaseConfig {
  static const String url = 'https://asyicusgdulqjfoqfibi.supabase.co';
  static const String anonKey = 'sb_publishable_j80WP0L-pWhRrfwptrCLIg_49VJK5_e';

  /// Flag para controlar mock vs Supabase Auth real.
  ///
  /// - `false` → usa AuthService mock (SharedPreferences) — padrão para dev
  /// - `true`  → usa SupabaseAuthService real (requer tabela profiles no Supabase)
  ///
  /// Para ativar: trocar para true APÓS executar o SQL migration no Supabase.
  static const bool useSupabaseAuth = false;
}
