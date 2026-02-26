# 📚 CRP Cursos

Aplicativo Flutter para gerenciamento e visualização de **Cursos de Normas Regulamentadoras (NRs)**.  
O projeto foi desenvolvido com foco em usabilidade, responsividade e boas práticas de arquitetura.

---

## 🚀 Funcionalidades

- Listagem de cursos de Normas Regulamentadoras (NR-10, NR-35, NR-12, etc.)
- Pesquisa de cursos por nome ou código
- Alternância entre **modo claro** e **modo escuro**
- Navegação por abas: Início, Cursos e Perfil
- Mock de serviços para simulação de dados
- Estrutura modular com `models`, `providers`, `services` e `widgets`

---

## 🛠️ Tecnologias Utilizadas

- [Flutter](https://flutter.dev/)  
- [Dart](https://dart.dev/)  
- **StateNotifier** para gerenciamento de estado  
- **SharedPreferences** para persistência simples  
- Arquitetura baseada em **Providers**

---

## 📂 Estrutura do Projeto
lib/
├── models/          # Modelos de dados (Course, AuthState, etc.)
├── providers/       # Providers e Notifiers (Auth, Theme)
├── screens/         # Telas principais (Home, Cursos, Perfil)
├── services/        # Serviços (mock de cursos, autenticação)
├── widgets/         # Componentes reutilizáveis (CourseCard, etc.)
└── main.dart        # Ponto de entrada da aplicação

## 👨‍💻 Autor

Projeto desenvolvido por **Victor Pombo**.  
Este repositório está em fase inicial e **não está aberto para contribuições públicas** no momento.  

- 🌐 [GitHub](https://github.com/VictorPombo)   

---

## 📄 Licença

Este projeto é de uso **restrito** e não está disponível sob licença pública neste momento.  
A abertura do código e definição de licença poderão ser avaliadas futuramente.

