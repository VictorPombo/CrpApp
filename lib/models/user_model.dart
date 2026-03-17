/// Modelo de usuário completo para CRP Cursos.
///
/// Usado por MockAuthService e SupabaseAuthService.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? cpf;
  final String? phone;
  final String? company;
  final String role; // 'student', 'instructor', 'admin'
  final String? avatarUrl;
  final bool emailVerified;
  final bool twoFactorEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.cpf,
    this.phone,
    this.company,
    this.role = 'student',
    this.avatarUrl,
    this.emailVerified = false,
    this.twoFactorEnabled = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Cria UserModel a partir de JSON (Supabase/API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      cpf: json['cpf'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      role: json['role'] as String? ?? 'student',
      avatarUrl: json['avatar_url'] as String?,
      emailVerified: json['email_verified'] as bool? ?? false,
      twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'cpf': cpf,
        'phone': phone,
        'company': company,
        'role': role,
        'avatar_url': avatarUrl,
        'email_verified': emailVerified,
        'two_factor_enabled': twoFactorEnabled,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  /// Cria cópia com campos alterados
  UserModel copyWith({
    String? name,
    String? email,
    String? cpf,
    String? phone,
    String? company,
    String? role,
    String? avatarUrl,
    bool? emailVerified,
    bool? twoFactorEnabled,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Nome formatado para exibição
  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  /// Iniciais para avatar
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  /// CPF mascarado para exibição (LGPD)
  String get maskedCpf {
    if (cpf == null || cpf!.length < 11) return '***.***.***-**';
    final clean = cpf!.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length != 11) return '***.***.***-**';
    return '${clean.substring(0, 3)}.***.**${clean.substring(9, 11)}';
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email, role: $role)';
}
