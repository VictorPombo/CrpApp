# PROMPT — QUIZ + CERTIFICADO
# CRP Cursos — Avaliação por curso + Emissão de certificado

---

## REGRA OBRIGATÓRIA

Ao concluir CADA tarefa, atualizar `docs/crp_dev_dashboard.html`:
- Itens concluídos: status → `"done"`
- Novos bugs encontrados: status → `"bug"`
- Salvar o arquivo antes de avançar para próxima tarefa

---

## CONTEXTO — BANCO DE QUESTÕES

Cada NR tem seu próprio banco de questões único e coerente com a norma.

**Estratégia por demanda:**
- Alta demanda (NR-35, 10, 12, 33, 23, 05, 17, 18): 10 questões cada
- Média demanda (NR-06, 07, 09, 13, 15, 16, 20, 26, 32, 37): 5 questões cada
- Baixa demanda (demais): 3 questões genéricas + TODO para expandir

**Regras para as questões:**
1. Baseadas na legislação real de cada NR
2. Sempre 4 alternativas, apenas 1 correta
3. Linguagem técnica mas acessível
4. `explanation` obrigatório em todas
5. Nunca repetir questões entre NRs
6. Dificuldade progressiva: fácil → médio → difícil
7. Cobrir pontos mais cobrados em fiscalizações do MTE

---

## TAREFA 1 — Model e QuizService

### lib/models/quiz_question.dart

```dart
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;      // sempre 4
  final int correctIndex;          // 0-3
  final String explanation;        // obrigatório
  final QuizDifficulty difficulty;
  final String topic;
}

enum QuizDifficulty { easy, medium, hard }

class QuizResult {
  final String courseId;
  final int totalQuestions;
  final int correctAnswers;
  final int score;          // 0-100
  final bool approved;      // score >= 70
  final DateTime completedAt;
  final List<int> userAnswers;
  final Duration timeTaken;

  Map<String, dynamic> toJson();
  factory QuizResult.fromJson(Map<String, dynamic> json);
}
```

### lib/services/quiz_service.dart

```dart
class QuizService {
  // Retorna até 10 questões EMBARALHADAS do curso
  // Embaralhar sempre — evitar memorização de posição
  static List<QuizQuestion> getQuestionsForCourse(String courseId) {
    final bank = _bankByCourse[courseId] ?? _genericQuestions;
    return (List.from(bank)..shuffle()).take(10).toList();
  }

  static const Map<String, List<QuizQuestion>> _bankByCourse = {
    'nr35': _nr35Questions,
    'nr10': _nr10Questions,
    'nr12': _nr12Questions,
    'nr33': _nr33Questions,
    'nr23': _nr23Questions,
    'nr05': _nr05Questions,
    'nr17': _nr17Questions,
    'nr18': _nr18Questions,
    'nr06': _nr06Questions,
    'nr07': _nr07Questions,
    'nr15': _nr15Questions,
    'nr16': _nr16Questions,
    // demais NRs → _genericQuestions até banco expandido
  };
```

### Banco de questões — gerar para cada NR:

**NR-35 — Trabalho em Altura (10 questões obrigatórias)**
Tópicos obrigatórios a cobrir:
- Definição de trabalho em altura (altura mínima: 2m)
- Análise de Risco (AR) e Permissão de Trabalho (PT)
- Inspeção de EPIs (antes de cada uso)
- Validade do treinamento (2 anos)
- Condições impeditivas (saúde, labirintite, acrofobia)
- Síndrome do Arnês e procedimento de resgate
- Carga mínima do ponto de ancoragem (15 kN)
- Quem pode ministrar o treinamento
- EPI vs EPC (proteção coletiva tem prioridade)
- Interrupção por condições meteorológicas adversas

**NR-10 — Eletricidade (10 questões)**
Tópicos:
- Definição de EBT, BT e AT (tensões)
- Lockout/Tagout (bloqueio e etiquetagem)
- Distâncias de segurança
- Validade do treinamento (2 anos)
- Prontuário de instalações elétricas
- 5 medidas básicas antes de trabalhar (desenergizar, bloquear, sinalizar, verificar, iniciar)
- EPIs obrigatórios (luvas dielétricas, capacete, óculos)
- Procedimento em caso de choque elétrico
- Responsabilidades do empregador
- Inspeção de ferramentas e equipamentos

**NR-12 — Máquinas e Equipamentos (10 questões)**
Tópicos:
- Definição de zona de perigo
- Dispositivo de parada de emergência
- Documentação obrigatória (inventário, ART, manual)
- Proibição de ajustes com máquina em movimento
- Inventário de máquinas
- Proteções fixas
- Quem pode fazer manutenção
- Intertravamento
- Sinalização obrigatória
- Obrigações antes de nova máquina entrar em operação

**NR-33 — Espaços Confinados (10 questões)**
Tópicos:
- Definição de espaço confinado
- Nível mínimo de O₂ (19,5%)
- Função do Vigia
- Permissão de Entrada e Trabalho (PET)
- Procedimento em caso de acidente (Vigia NÃO entra)
- SCBA para atmosfera IDLH
- Calibração dos equipamentos de medição
- Validade do treinamento NR-33 (1 ano)
- Três perigos atmosféricos principais
- Supervisor de entrada e suas responsabilidades

**NR-23 — Proteção Contra Incêndios (10 questões)**
Tópicos:
- Classes de incêndio (A, B, C, D, K)
- Extintor proibido em classe C (água)
- Triângulo do fogo
- Frequência de inspeção dos extintores
- Plano de abandono
- Técnica PASS de uso do extintor
- Brigada de incêndio (NBR 14276)
- Distância máxima para extintor (25m)
- Procedimento ao descobrir incêndio
- Extintor classe K (acetato de potássio)

**NR-05 — CIPA (10 questões)**
Tópicos:
- Definição da CIPA (inclui assédio desde 2023)
- Eleição dos representantes dos empregados
- Estabilidade do cipeiro (candidatura até 1 ano após mandato)
- Duração do mandato (1 ano, 1 reeleição)
- Mapa de Riscos
- Frequência das reuniões ordinárias (mensal)
- Quando a CIPA é obrigatória (Quadro I da NR-05)
- Designado de segurança em empresas menores
- Treinamento obrigatório (20 horas)
- CIPA e prevenção de assédio (atualização 2023)

**NR-17 — Ergonomia (10 questões)**
Tópicos:
- Definição de ergonomia conforme NR-17
- O que é AET (Análise Ergonômica do Trabalho)
- Peso máximo para transporte (avaliação ergonômica — não tem peso fixo)
- Conforto térmico (IBUTG)
- LER/DORT definição
- Altura ideal de trabalho sentado
- Pausas em teleatendimento (Anexo II: 20min a cada 1h40min)
- Conteúdo do laudo ergonômico
- Quem elabora a AET
- Iluminação como fator ergonômico

**NR-18 — Construção Civil (10 questões)**
Tópicos:
- Aplicação da NR-18
- PCMAT (obrigatório para 20+ trabalhadores)
- Especificações do guarda-corpo (1,20m / 0,70m / rodapé 0,20m)
- EPIs obrigatórios na construção
- Altura para proteção contra queda (2m)
- Ordem de Serviço de Segurança
- Escavações acima de 1,25m (escoramento obrigatório)
- Largura mínima de andaime (0,60m)
- SESMT na construção
- Proibição de içar pessoas com materiais

**NR-06 — EPI (5 questões)**
Tópicos: CA, obrigações do empregador, recusa do trabalhador,
validade do CA (5 anos), controle de entrega com assinatura

**NR-07 — PCMSO (5 questões)**
Tópicos: definição, 5 tipos de exame, quem elabora (médico do trabalho),
ASO, demissão por motivo de saúde (ilegal)

**NR-15 — Insalubridade (5 questões)**
Tópicos: definição, graus e adicionais (10/20/40% do salário mínimo),
eliminação/neutralização, limite de ruído (85 dB), acúmulo com periculosidade

**NR-16 — Periculosidade (5 questões)**
Tópicos: adicional (30% salário base), atividades perigosas,
EPI não elimina periculosidade, motociclista (Lei 12.997/2014), laudo

**Questões genéricas (3) para demais NRs:**
- Objetivo das NRs
- Prazo para emitir CAT (1º dia útil)
- Direito de recusa em risco grave e iminente (CLT Art. 483)

**Critério de aceite da Tarefa 1:**
- Model `QuizQuestion` e `QuizResult` completos
- `QuizService` com banco para todas as NRs listadas
- Questões embaralhadas a cada quiz
- Máximo 10 questões por quiz
- Atualizar dashboard

---

## TAREFA 2 — QuizScreen

### lib/screens/student/quiz_screen.dart

**Header:**
- AppBar: "Avaliação Final"
- Subtítulo: "[Nome do Curso] · Mínimo 70%"
- Cronômetro crescente (canto superior direito)

**Por pergunta:**
- `LinearProgressIndicator` no topo ("Pergunta 3 de 10")
- Texto da pergunta (16px, w600, padding generoso)
- Badge de dificuldade (fácil/médio/difícil) no canto do card
- 4 alternativas como Cards:
  - Normal → borda neutra, fundo neutro
  - Selecionado (antes de confirmar) → borda azul, fundo azul claro
  - Correto (após confirmar) → ícone ✓ + borda verde + fundo verde claro
  - Errado selecionado → ícone ✗ + borda vermelha + fundo vermelho claro
  - Resposta correta sempre destacada mesmo quando errou
- Card de explicação expansível abaixo após confirmar
- Botão "Confirmar" (ativo só após selecionar)
- Após confirmar → botão "Próxima" ou "Ver resultado" (última)

**Tela de resultado:**
- Ícone grande: ✓ verde (aprovado) ou ✗ vermelho (reprovado)
- Nota em destaque: "8/10 — 80%"
- Barra de progresso colorida
- "Aprovado!" ou "Reprovado — mínimo 70%"
- Resumo: "Fácil: 3/3 · Médio: 4/5 · Difícil: 1/2"
- Tempo total gasto

**Se aprovado:**
```dart
await enrollmentService.saveQuizResult(courseId, result);
final eligibility = CertificateEligibilityService.check(
  progressPercent: enrollment.progressPercent,
  quizScore: result.score,
  userCpf: user?.cpf,
  userCompany: user?.company,
);
// Se elegível → botão "Emitir certificado" → CertificateScreen
// Se falta algo → CertificateEligibilityCard mostrando o que falta
```

**Se reprovado:**
- Botão "Tentar novamente" (embaralha questões)
- Botão "Revisar aulas" → CourseScreen
- Texto: "Você pode tentar quantas vezes precisar"

**Conexão:**
- `CourseScreen`: quando `progress >= 0.75` → botão "Fazer avaliação"
- Se quiz já aprovado → mostrar `CertificateEligibilityCard`

**Critério de aceite:**
- Quiz funciona do início ao fim para NR-35 (10 questões)
- Explicação exibida após cada resposta
- Resultado salvo no enrollment
- Atualizar dashboard

---

## TAREFA 3 — CertificateScreen com dados reais

### Verificação de elegibilidade (obrigatória)

```dart
final eligibility = CertificateEligibilityService.check(
  progressPercent: enrollment.progressPercent,
  quizScore: enrollment.quizScore,
  userCpf: user?.cpf,
  userCompany: user?.company,
);

if (!eligibility.isEligible) {
  return CertificateEligibilityCard(
    result: eligibility,
    onStartQuiz: () => context.push('/quiz/$courseId'),
    onCompleteProfile: () => context.push('/profile/personal-data'),
  );
}
```

**Card do certificado (quando elegível):**
```
Logo CRP ENGENHARIA
────────────────────
"Certificamos que"
[NOME COMPLETO DO ALUNO]     ← do perfil
"concluiu com êxito o curso"
[NOME DO CURSO + CÓDIGO NR]

Carga: 16h  |  Conclusão: 15/03/2026
Validade: 15/03/2028  |  Nota: Aprovado com 80%

────────────────────
Instrutor: [nome + registro]   ← do mock do curso
CNPJ: CRP Engenharia
────────────────────
[QR CODE]
Código: CRP-NR35-abc123-2026
Valide em: crpengenharia.com.br/validar/CRP-NR35-abc123-2026
```

**Geração do código único:**
```dart
final code = 'CRP-${courseCode.toUpperCase()}-'
    '${userId.substring(0, 6)}-'
    '${DateTime.now().year}';
```

**Botões de ação:**
- "Baixar PDF" → `pdf` + `printing` package (layout mock)
- "Compartilhar" → `Share.share()` com texto + código
- "LinkedIn" → `openLink()` com URL de compartilhamento

**Emissão automática na 1ª visita elegível:**
```dart
// Se elegível e ainda não emitido → emitir e salvar
if (eligibility.isEligible && !alreadyIssued) {
  await certificateService.issueCertificate(
    courseId: courseId,
    userId: userId,
    code: code,
    score: enrollment.quizScore!,
    issuedAt: DateTime.now(),
    validUntil: DateTime.now().add(const Duration(days: 730)),
  );
}
```

**Critério de aceite:**
- Certificado só exibe com 3 condições OK
- Dados reais do aluno, curso e nota
- QR code com código único gerado
- Compartilhamento funcional
- Aparece em CertificatesScreen após emissão
- Atualizar dashboard

---

## TAREFA 4 — CertificatesScreen

### lib/screens/student/certificates_screen.dart

**Lista de certificados:**
- Card com gradiente da cor do curso
- Nome + código NR
- Data de emissão e validade
- Badge: "Válido" (verde) ou "Expirado" (vermelho)
- Botão "Ver" → CertificateScreen
- Botão "Compartilhar" direto na lista

**Empty state:**
```
[ícone de certificado]
"Você ainda não tem certificados"
"Conclua um curso e passe na avaliação para emitir"
[Botão] "Ver meus cursos"
```

**Critério de aceite:**
- Busca de `certificateService.getCertificates(userId)`
- Empty state correto
- Navegação para CertificateScreen individual
- Atualizar dashboard

---

## FLUXO COMPLETO — testar ao final

```
1. Entrar em curso → assistir aulas → progress >= 75%
2. CourseScreen → botão "Fazer avaliação" aparece
3. QuizScreen → responder → ver explicações → ver resultado
4. Se aprovado → checar elegibilidade
5. Se falta CPF/empresa → CertificateEligibilityCard
6. Preencher perfil → voltar → emitir certificado
7. CertificateScreen → dados reais + QR code
8. CertificatesScreen → certificado aparece na lista
9. Compartilhar funciona
```

---

## AO CONCLUIR TUDO

```bash
flutter analyze
flutter build web --debug
```

Relatório final:
- Tarefas concluídas e arquivos criados/modificados
- Dashboard atualizado (listar o que foi marcado como done)
- Percentual de progresso do MVP estimado

---

## COMECE PELA TAREFA 1

Implemente `QuizQuestion`, `QuizResult` e `QuizService`
com o banco completo de questões.
Aguarde confirmação antes de avançar para a Tarefa 2.
**Lembre de atualizar `docs/crp_dev_dashboard.html` ao concluir.**
