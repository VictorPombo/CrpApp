# CRP Cursos — Backlog de desenvolvimento
Gerado em 14/03/2026

## Tarefas pendentes (21)

---
### TAREFA 1: Tela de login
Prioridade: high

Crie a tela de login (login_screen.dart).

O que fazer:
- Campo e-mail com validação de formato
- Campo senha com toggle mostrar/ocultar
- Botão "Entrar" com loading state
- Link "Esqueci minha senha" → ForgotPasswordScreen
- Link "Criar conta" → RegisterScreen
- Mock: qualquer e-mail/senha válidos → autenticar e ir para MyCourses
- Após login: retornar para rota de origem se houver

Critério de aceite: login funciona, sessão persiste ao reabrir app.

---
### TAREFA 2: Tela de cadastro
Prioridade: high

Crie a tela de cadastro (register_screen.dart).

Campos: nome completo, e-mail, senha (mín. 6 chars), confirmar senha.
Validações: e-mail válido, senhas iguais, campos obrigatórios.
Botão "Criar conta" com loading.
Link "Já tenho conta" → LoginScreen.
Após cadastro: autenticar e ir para MyCourses.

---
### TAREFA 3: Guards de rota
Prioridade: high

Implemente guards de rota e persistência de sessão.

O que fazer:
1. Criar auth_guard.dart verificando AuthProvider.isAuthenticated
2. Proteger rotas: MyCourses, CourseScreen, LessonPlayer, Profile
3. Rotas públicas livres: Catalog, CourseDetail, Login, Register
4. Salvar token em SharedPreferences, restaurar ao abrir app
5. Após login, redirecionar para rota de origem

Critério de aceite: área do aluno sem login redireciona para login.

---
### TAREFA 4: Tela de certificado
Prioridade: high

Crie certificate_screen.dart (referência: docs/certificado.png).

Layout:
- Logo CRP Engenharia
- "Certificamos que [Nome] concluiu o curso [Nome do Curso]"
- Carga horária, data de conclusão, validade (2 anos)
- QR code mock (package: qr_flutter)
- Código: "CRP-[NR]-[ANO]-[ID]"
- Botões: Baixar PDF (mock), Compartilhar (share_plus), LinkedIn

Conectar: botão "Ver certificado" em MyCourses → CertificateScreen

---
### TAREFA 5: Conectar backend (Supabase)
Prioridade: high

Configure o Supabase como backend.
1. Instalar supabase_flutter no pubspec.yaml
2. Configurar cliente em lib/services/supabase_client.dart
3. Migrar auth_service.dart para Supabase Auth
4. Migrar course_service.dart para queries no PostgreSQL do Supabase
5. Criar tabelas: users, courses, purchases, progress, certificates

---
### TAREFA 6: Hospedagem de vídeos (Cloudflare Stream)
Prioridade: high

Integre Cloudflare Stream para hospedar e streamar os vídeos.
1. Configurar conta Cloudflare Stream
2. Criar video_service.dart com método getVideoUrl(lessonId)
3. Integrar package video_player ou chewie no lesson_player_screen
4. Substituir placeholder por player real com URL do Cloudflare

---
### TAREFA 7: Build e publicação nas stores
Prioridade: high

Configure e publique o app nas stores.

Android:
1. Gerar keystore de produção
2. Configurar build.gradle com versão, packageName, signingConfig
3. Build: flutter build appbundle --release
4. Upload no Google Play Console

iOS:
1. Configurar Bundle ID e certificados no Xcode
2. Build: flutter build ipa --release
3. Upload via Xcode ou Transporter

---
### TAREFA 8: Recuperação de senha
Prioridade: medium

Crie forgot_password_screen.dart.
Campo e-mail + botão "Enviar link".
Após envio: tela de confirmação "Verifique seu e-mail".

---
### TAREFA 9: Avaliação / prova do curso
Prioridade: medium

Crie quiz_screen.dart com questionário de múltipla escolha.
- Lista de perguntas com 4 alternativas cada
- Indicador de progresso (Pergunta X de Y)
- Destaque na alternativa selecionada
- Botão "Próxima" / "Finalizar"
- Tela de resultado: nota, passou/reprovou, botão tentar novamente

---
### TAREFA 10: Histórico de compras
Prioridade: medium

Implemente payments_screen.dart com histórico completo.
- Lista de compras: nome do curso, data, valor, status (pago/pendente/reembolsado)
- Botão "Ver recibo" abre dialog com detalhes da transação
- Dados mock

---
### TAREFA 11: Estados de loading (shimmer)
Prioridade: medium

Adicione shimmer loading em todas as listas.
- Instalar package shimmer no pubspec.yaml
- Criar widgets/shimmer_card.dart
- Usar em: catálogo, meus cursos, tela do curso

---
### TAREFA 12: Estados de erro e vazio
Prioridade: medium

Crie widgets reutilizáveis de estado.
1. error_state.dart: ícone + mensagem + botão "Tentar novamente"
2. empty_state.dart: ilustração + mensagem contextual
Usar em: Meus Cursos vazio, Certificados vazio, erro de rede

---
### TAREFA 13: Busca e filtro no catálogo
Prioridade: medium

Implemente busca e filtro de categoria no catálogo.
- Verificar se TextField de busca já filtra a lista
- Adicionar chips horizontais: Todos | NR-10 | NR-12 | NR-35 | NR-23 | NR-18
- Filtrar lista ao tocar em categoria
- Combinar busca + categoria simultaneamente

---
### TAREFA 14: Geração de certificado PDF
Prioridade: medium

Implemente geração de certificado PDF real.
1. Usar package pdf + printing no Flutter
2. Criar certificate_service.dart
3. Gerar PDF com: logo, dados do aluno, curso, datas, QR code
4. QR code aponta para URL de validação pública: crpengenharia.com/validar/[codigo]
5. Salvar PDF no Supabase Storage
6. Enviar link por e-mail ao aluno

---
### TAREFA 15: Splash screen / onboarding
Prioridade: low

Criar/verificar splash_screen.dart.
- Logo CRP centralizado em fundo escuro
- Após 2s: verificar SharedPreferences → se logado ir para MyCourses, senão ir para Home

---
### TAREFA 16: Perfil: itens não navegam
Prioridade: critical

Implemente a navegação completa do menu de Perfil.

Problema: todos os ListTiles do perfil (Dados pessoais, Histórico de cursos, Certificados, Pagamentos, Alterar senha) não fazem nada ao clicar.

O que fazer:
1. Criar lib/screens/student/personal_data_screen.dart — formulário com nome, CPF, telefone, empresa
2. Criar lib/screens/student/course_history_screen.dart — lista de cursos comprados
3. Criar lib/screens/student/certificates_screen.dart — lista de certificados
4. Criar lib/screens/student/payments_screen.dart — histórico de pagamentos
5. Criar lib/screens/auth/change_password_screen.dart — formulário senha atual + nova senha
6. Conectar cada ListTile no profile_screen.dart via Navigator.push
7. Todas as telas com AppBar e botão voltar

Critério de aceite: clicar em cada item do perfil abre a tela correta.
Aguarde confirmação antes de avançar para a próxima tarefa.

---
### TAREFA 17: Botão 'Comprar curso' cortado
Prioridade: critical

Corrija o botão 'Comprar curso' que aparece cortado na tela de detalhe do curso.

O que fazer:
1. Em course_detail_screen.dart, envolver o sticky bottom bar com SafeArea
2. Adicionar padding: EdgeInsets.fromLTRB(16, 12, 16, 12) no container do botão
3. Garantir que o body do Scaffold tem padding inferior para não ficar atrás do botão
4. Testar no emulador iOS e Android

Critério de aceite: botão totalmente visível e tocável em todas as telas.
Aguarde confirmação antes de avançar.

---
### TAREFA 18: 'Meus Cursos' sem navegação interna
Prioridade: critical

Implemente a navegação dos cards de curso em Meus Cursos.

O que fazer:
1. Criar lib/screens/student/course_screen.dart com:
   - Header: nome do curso + barra de progresso geral
   - Lista de módulos (ExpansionTile)
   - Dentro de cada módulo: lista de aulas
   - Cada aula: ícone (play/check/cadeado) + nome + duração
   - Aula disponível ao toque → navegar para LessonPlayerScreen
2. Em my_courses_screen.dart: adicionar onTap nos cards → Navigator.push(CourseScreen(courseId))

Critério de aceite: clicar em curso abre tela com módulos e aulas.
Aguarde confirmação.

---
### TAREFA 19: Player de vídeo ausente
Prioridade: critical

Crie a tela de player de aula (lesson_player_screen.dart).

Layout (referência: docs/player_aula.png):

ÁREA DO PLAYER (fundo escuro):
- Container escuro com ícone play centralizado
- Texto "Aula X de Y"
- Barra de progresso simulada
- Controles: -10s | play/pause | +10s | velocidade (1x/1.5x/2x)

TABBAR COM 3 ABAS:
1. Sobre — título + descrição da aula
2. Materiais — lista de PDFs/slides com botão Baixar
3. Anotações — TextField multilinha

RODAPÉ FIXO:
- Botão "Marcar como concluída" (azul, largura total)
- Ao tocar: atualizar progresso, ir para próxima aula
- Se última aula: AlertDialog de conclusão

Critério de aceite: tela abre, abas funcionam, botão marca conclusão.
Aguarde confirmação.

---
### TAREFA 20: Fluxo de compra inexistente
Prioridade: critical

Implemente o fluxo completo de compra de curso.

CRIAR AS SEGUINTES TELAS:

1. lib/screens/purchase/cart_screen.dart
   - Card do curso (nome, preço)
   - Campo de cupom + botão Aplicar
   - Resumo: subtotal, desconto, total
   - Botão "Continuar" → PaymentScreen

2. lib/screens/purchase/payment_screen.dart
   - 3 opções: Cartão | Pix | Boleto
   - Cartão: campos número, nome, validade, CVV
   - Pix: QR code mock + código copia-e-cola
   - Botão "Finalizar pagamento" → ProcessingScreen

3. lib/screens/purchase/processing_screen.dart
   - Loading animation + "Processando..."
   - Após 2s → PaymentSuccessScreen

4. lib/screens/purchase/payment_success_screen.dart
   - Check verde animado + "Pagamento aprovado!"
   - Botão "Começar agora" → CourseScreen
   - Adicionar curso em Meus Cursos automaticamente

5. lib/screens/purchase/payment_failed_screen.dart
   - X vermelho + "Pagamento não aprovado"
   - Botão "Tentar novamente" → PaymentScreen

CONECTAR: botão "Comprar curso" → CartScreen
Se não logado: redirecionar para LoginScreen primeiro.

Critério de aceite: conseguir comprar um curso do início ao fim (mock).
Aguarde confirmação.

---
### TAREFA 21: Integração de pagamento (Mercado Pago)
Prioridade: critical

Integre o Mercado Pago como gateway de pagamento.
1. Instalar mercadopago_sdk (ou usar API REST)
2. Criar payment_service.dart
3. Implementar: criar preferência de pagamento, processar cartão, gerar Pix, gerar boleto
4. Configurar webhook para receber confirmação
5. Ao confirmar: atualizar status da compra no Supabase + liberar acesso ao curso

