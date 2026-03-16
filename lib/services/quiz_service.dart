import 'dart:math';
import '../models/quiz_question.dart';

class _QE {
  final String id, question, explanation, topic;
  final List<String> options;
  final int correctIndex;
  final QuizDifficulty difficulty;
  const _QE({required this.id, required this.question, required this.options,
    required this.correctIndex, required this.explanation,
    required this.difficulty, required this.topic});
}

class QuizService {
  static final _rng = Random();
  static final Map<String, List<int>> _optionMappings = {};

  static List<QuizQuestion> getQuestionsForCourse(String courseId) {
    final bank = _banks[courseId] ?? _generic;
    final shuffled = List<_QE>.from(bank)..shuffle(_rng);
    final selected = shuffled.take(10).toList();
    return selected.map((e) {
      final indices = List.generate(e.options.length, (i) => i)..shuffle(_rng);
      _optionMappings[e.id] = indices;
      return QuizQuestion(id: e.id, question: e.question,
        options: indices.map((i) => e.options[i]).toList(),
        difficulty: e.difficulty, topic: e.topic);
    }).toList();
  }

  static QuizResult submitAnswers({
    required String courseId,
    required Map<String, int> userAnswers,
    required Duration timeTaken,
  }) {
    final bank = _banks[courseId] ?? _generic;
    final feedbacks = <QuestionFeedback>[];
    int correct = 0;
    int easyC = 0, easyT = 0, medC = 0, medT = 0, hardC = 0, hardT = 0;
    for (final entry in userAnswers.entries) {
      final q = bank.firstWhere((e) => e.id == entry.key, orElse: () => bank.first);
      final mapping = _optionMappings[entry.key];
      final origIdx = mapping != null && entry.value < mapping.length
          ? mapping[entry.value] : entry.value;
      final ok = origIdx == q.correctIndex;
      if (ok) correct++;
      switch (q.difficulty) {
        case QuizDifficulty.easy: easyT++; if (ok) easyC++; break;
        case QuizDifficulty.medium: medT++; if (ok) medC++; break;
        case QuizDifficulty.hard: hardT++; if (ok) hardC++; break;
      }
      feedbacks.add(QuestionFeedback(questionId: entry.key, isCorrect: ok,
        userAnswer: entry.value, explanation: q.explanation));
    }
    _optionMappings.clear();
    return QuizResult(courseId: courseId, totalQuestions: userAnswers.length,
      correctAnswers: correct, feedback: feedbacks, timeTaken: timeTaken,
      easyCorrect: easyC, easyTotal: easyT,
      mediumCorrect: medC, mediumTotal: medT,
      hardCorrect: hardC, hardTotal: hardT);
  }

  static final Map<String, List<_QE>> _banks = {
    'nr35': _nr35, 'nr10': _nr10, 'nr12': _nr12, 'nr33': _nr33,
    'nr23': _nr23, 'nr05': _nr05, 'nr17': _nr17, 'nr18': _nr18,
    'nr06': _nr06, 'nr07': _nr07, 'nr15': _nr15, 'nr16': _nr16,
  };


  // ══════════════════════════════════════════════════
  // NR35 (10 questões)
  // ══════════════════════════════════════════════════
  static const _nr35 = [
    const _QE(id:'nr35_01',question:'Qual a altura mínima definida pela NR-35 para considerar trabalho em altura?',
      options:['1 metro','1,5 metros','2 metros','3 metros'],correctIndex:2,
      explanation:'A NR-35 define como trabalho em altura qualquer atividade acima de 2,00m do nível inferior.',
      difficulty:QuizDifficulty.easy,topic:'Definição'),
    const _QE(id:'nr35_02',question:'O que é obrigatório elaborar antes de iniciar qualquer trabalho em altura?',
      options:['Apenas usar cinto','Análise de Risco (AR) e, quando aplicável, Permissão de Trabalho (PT)','Avisar o supervisor','Instalar rede de proteção'],correctIndex:1,
      explanation:'A NR-35 exige elaboração de Análise de Risco (AR) antes de cada trabalho em altura.',
      difficulty:QuizDifficulty.easy,topic:'AR e PT'),
    const _QE(id:'nr35_03',question:'Com que frequência os EPIs de proteção contra quedas devem ser inspecionados?',
      options:['Mensalmente','A cada 6 meses','Anualmente','Antes de cada uso e periodicamente conforme fabricante'],correctIndex:3,
      explanation:'Os EPIs devem ser inspecionados antes de cada uso e periodicamente conforme recomendação do fabricante.',
      difficulty:QuizDifficulty.medium,topic:'Inspeção EPI'),
    const _QE(id:'nr35_04',question:'Qual o prazo de validade do treinamento de trabalho em altura (NR-35)?',
      options:['1 ano','2 anos','3 anos','5 anos'],correctIndex:1,
      explanation:'O treinamento da NR-35 tem validade de 2 anos.',
      difficulty:QuizDifficulty.easy,topic:'Treinamento'),
    const _QE(id:'nr35_05',question:'O que caracteriza um Sistema de Proteção Coletiva contra quedas?',
      options:['Uso de cinto por todos','Corda de segurança','Andaimes, guarda-corpos, redes — medidas que protegem todos','Sinalização'],correctIndex:2,
      explanation:'Proteções Coletivas (EPC) são prioritárias sobre individuais (EPI).',
      difficulty:QuizDifficulty.medium,topic:'EPC vs EPI'),
    const _QE(id:'nr35_06',question:'Em resgate de trabalhador inconsciente suspenso, qual a preocupação crítica?',
      options:['Aguardar SAMU','Remover o EPI','Síndrome do arnês — posição horizontal o mais rápido possível','Cortar a corda'],correctIndex:2,
      explanation:'A síndrome do arnês pode causar morte em minutos. Posição horizontal imediata.',
      difficulty:QuizDifficulty.hard,topic:'Resgate'),
    const _QE(id:'nr35_07',question:'Quem pode ministrar o treinamento de NR-35?',
      options:['Qualquer trabalhador experiente','Profissional habilitado ou qualificado com capacitação em NR-35','Apenas engenheiros de segurança','O supervisor da obra'],correctIndex:1,
      explanation:'Profissional legalmente habilitado ou qualificado com capacitação específica.',
      difficulty:QuizDifficulty.medium,topic:'Treinamento'),
    const _QE(id:'nr35_08',question:'O que deve conter o plano de resgate?',
      options:['Apenas número do SAMU','Procedimentos, equipamentos, responsáveis treinados e contatos de emergência','Localização do hospital','Lista de EPIs'],correctIndex:1,
      explanation:'Procedimentos, equipamentos, pessoal treinado e contatos de emergência.',
      difficulty:QuizDifficulty.medium,topic:'Resgate'),
    const _QE(id:'nr35_09',question:'Trabalhador com acrofobia pode realizar trabalho em altura?',
      options:['Sim, com EPIs','Sim, com autorização','Não — NR-35 exige aptidão médica. Condições que comprometam equilíbrio são impeditivas','Sim, abaixo de 5m'],correctIndex:2,
      explanation:'A NR-35 exige aptidão médica. Condições que afetam equilíbrio são impeditivas.',
      difficulty:QuizDifficulty.hard,topic:'Aptidão médica'),
    const _QE(id:'nr35_10',question:'O ponto de ancoragem para trabalho em altura deve suportar no mínimo:',
      options:['200 kgf','500 kgf','1.000 kgf','1.500 kgf (15 kN)'],correctIndex:3,
      explanation:'O ponto de ancoragem deve suportar pelo menos 15 kN (~1.500 kgf).',
      difficulty:QuizDifficulty.hard,topic:'Ancoragem'),
  ];

  // ══════════════════════════════════════════════════
  // NR10 (10 questões)
  // ══════════════════════════════════════════════════
  static const _nr10 = [
    const _QE(id:'nr10_01',question:'Qual a tensão mínima considerada perigosa pela NR-10?',
      options:['12V','25V em CA ou 60V em CC','50V','110V'],correctIndex:1,
      explanation:'Tensões acima de 25V CA ou 60V CC em ambientes úmidos são consideradas perigosas.',
      difficulty:QuizDifficulty.easy,topic:'Tensão'),
    const _QE(id:'nr10_02',question:'A primeira medida de segurança ao trabalhar com eletricidade é:',
      options:['Usar luvas isolantes','Desligar, bloquear e etiquetar (LOTO)','Verificar tensão com multímetro','Avisar o supervisor'],correctIndex:1,
      explanation:'Primeiro passo: desenergizar — desligar, bloquear e sinalizar (Lock-Out/Tag-Out).',
      difficulty:QuizDifficulty.easy,topic:'LOTO'),
    const _QE(id:'nr10_03',question:'Qual a validade do curso NR-10 básico (40h)?',
      options:['1 ano','2 anos','3 anos','5 anos'],correctIndex:1,
      explanation:'Reciclagem do treinamento NR-10 a cada 2 anos.',
      difficulty:QuizDifficulty.easy,topic:'Treinamento'),
    const _QE(id:'nr10_04',question:'O que é a zona controlada em instalações elétricas?',
      options:['Área ao redor de equipamento energizado com risco de choque','Sala do quadro elétrico','Local com fiação exposta','Área com piso isolante'],correctIndex:0,
      explanation:'Zona controlada: área ao redor de partes energizadas com acesso restrito.',
      difficulty:QuizDifficulty.medium,topic:'Zona controlada'),
    const _QE(id:'nr10_05',question:'O prontuário de instalações elétricas deve conter:',
      options:['Apenas diagramas unifilares','Somente laudos de aterramento','Diagramas, laudos, procedimentos de segurança e certificados','Apenas registros de manutenção'],correctIndex:2,
      explanation:'Prontuário: diagramas, especificações, laudos, procedimentos e certificados.',
      difficulty:QuizDifficulty.medium,topic:'Prontuário'),
    const _QE(id:'nr10_06',question:'Quais são as 5 etapas para trabalho seguro em instalações elétricas?',
      options:['Desligar, testar, aterrar, sinalizar, trabalhar','Seccionamento, impedimento de reenergização, constatação de ausência de tensão, aterramento temporário, sinalização','Avisar, desligar, trabalhar, religar, registrar','Planejar, executar, verificar, corrigir, documentar'],correctIndex:1,
      explanation:'As 5 medidas: seccionamento, impedimento, constatação, aterramento temporário e sinalização.',
      difficulty:QuizDifficulty.hard,topic:'Procedimentos'),
    const _QE(id:'nr10_07',question:'EPIs obrigatórios para trabalho com eletricidade incluem:',
      options:['Apenas capacete','Luvas dielétricas, capacete classe B, óculos de proteção, calçado isolante','Luvas de couro e óculos','Apenas botas de borracha'],correctIndex:1,
      explanation:'EPIs obrigatórios: luvas dielétricas, capacete classe B, óculos, calçado isolante.',
      difficulty:QuizDifficulty.medium,topic:'EPIs'),
    const _QE(id:'nr10_08',question:'Em caso de choque elétrico, a primeira ação é:',
      options:['Jogar água na vítima','Desligar a fonte de energia sem tocar na vítima','Puxar a vítima com as mãos','Aplicar RCP imediatamente'],correctIndex:1,
      explanation:'Primeiro: desligar a fonte de energia. Nunca tocar na vítima enquanto energizada.',
      difficulty:QuizDifficulty.medium,topic:'Emergência'),
    const _QE(id:'nr10_09',question:'O que é o Prontuário de Instalações Elétricas (PIE)?',
      options:['Manual do fabricante dos equipamentos','Conjunto de documentos com dados das instalações elétricas da empresa','Certificado de treinamento NR-10','Laudo de aterramento'],correctIndex:1,
      explanation:'PIE: conjunto de documentos técnicos sobre as instalações elétricas.',
      difficulty:QuizDifficulty.medium,topic:'Prontuário'),
    const _QE(id:'nr10_10',question:'Quem é o profissional habilitado para trabalhar em instalações elétricas?',
      options:['Qualquer eletricista','Profissional com registro no CREA e treinamento em NR-10','Técnico com experiência de 5 anos','Engenheiro civil'],correctIndex:1,
      explanation:'Profissional habilitado: registro no conselho de classe (CREA) + NR-10.',
      difficulty:QuizDifficulty.hard,topic:'Habilitação'),
  ];

  // ══════════════════════════════════════════════════
  // NR12 (10 questões)
  // ══════════════════════════════════════════════════
  static const _nr12 = [
    const _QE(id:'nr12_01',question:'Qual o objetivo principal da NR-12?',
      options:['Regular uso de EPIs','Definir medidas de proteção para segurança em máquinas e equipamentos','Estabelecer regras de ergonomia','Normatizar manutenção preventiva'],correctIndex:1,
      explanation:'NR-12: medidas de proteção para garantir segurança em máquinas.',
      difficulty:QuizDifficulty.easy,topic:'Objetivo'),
    const _QE(id:'nr12_02',question:'O que são dispositivos de intertravamento?',
      options:['Dispositivos que aumentam velocidade','Sistemas que impedem funcionamento em condições inseguras','Alarmes sonoros','EPIs'],correctIndex:1,
      explanation:'Intertravamento: impede funcionamento quando condições de segurança não são atendidas.',
      difficulty:QuizDifficulty.medium,topic:'Intertravamento'),
    const _QE(id:'nr12_03',question:'A parada de emergência deve:',
      options:['Ser acionada apenas pelo supervisor','Estar acessível a qualquer trabalhador, com acionamento rápido e prioritário','Funcionar apenas em horário comercial','Ser testada uma vez por ano'],correctIndex:1,
      explanation:'Parada de emergência: acessível, fácil acionamento, prioridade sobre outros comandos.',
      difficulty:QuizDifficulty.easy,topic:'Emergência'),
    const _QE(id:'nr12_04',question:'A zona de perigo de uma máquina é:',
      options:['Área administrativa','Qualquer área onde trabalhador pode ficar exposto a perigos da máquina','Apenas zona de corte','Almoxarifado'],correctIndex:1,
      explanation:'Zona de perigo: qualquer área com exposição a riscos mecânicos, elétricos ou térmicos.',
      difficulty:QuizDifficulty.medium,topic:'Zona de perigo'),
    const _QE(id:'nr12_05',question:'A capacitação para operar máquinas deve incluir:',
      options:['Apenas treinamento prático','Conteúdo teórico e prático, com carga horária compatível','Apenas leitura do manual','Apenas demonstração visual'],correctIndex:1,
      explanation:'Capacitação: conteúdo programático, carga horária compatível, teoria e prática.',
      difficulty:QuizDifficulty.easy,topic:'Capacitação'),
    const _QE(id:'nr12_06',question:'È proibido realizar ajustes em máquinas:',
      options:['Com a máquina desligada','Com a máquina em movimento, exceto quando tecnicamente impossível fazê-lo parada','Apenas durante o horário noturno','Apenas aos finais de semana'],correctIndex:1,
      explanation:'Ajustes com máquina em movimento são proibidos, exceto quando tecnicamente justificado.',
      difficulty:QuizDifficulty.hard,topic:'Segurança'),
    const _QE(id:'nr12_07',question:'O inventário de máquinas deve conter:',
      options:['Apenas o nome do fabricante','Tipo, capacidade, localização, estado de conservação e medidas de proteção','Apenas a data de compra','Somente o manual do fabricante'],correctIndex:1,
      explanation:'Inventário: identificação completa incluindo tipo, capacidade, localização e proteções.',
      difficulty:QuizDifficulty.medium,topic:'Inventário'),
    const _QE(id:'nr12_08',question:'Proteções fixas em máquinas devem:',
      options:['Ser removíveis pelo operador','Ser mantidas em posição permanente, só removíveis com ferramentas','Ser transparentes','Ter abertura para ventilação'],correctIndex:1,
      explanation:'Proteções fixas: permanentes, remoção apenas com ferramentas específicas.',
      difficulty:QuizDifficulty.medium,topic:'Proteções'),
    const _QE(id:'nr12_09',question:'Sinalização obrigatória em máquinas inclui:',
      options:['Apenas o nome do fabricante','Avisos de perigo, proibição e instruções de segurança em português','Apenas o número de série','Logo da empresa'],correctIndex:1,
      explanation:'Sinalização: avisos de perigo, proibição e instruções em idioma nacional.',
      difficulty:QuizDifficulty.easy,topic:'Sinalização'),
    const _QE(id:'nr12_10',question:'Antes de nova máquina entrar em operação:',
      options:['Basta plugar e ligar','Deve haver inspeção, ART, treinamento e adequação à NR-12','Apenas informar o RH','Somente instalar o manual'],correctIndex:1,
      explanation:'Nova máquina: inspeção prévia, ART, adequação à NR-12 e treinamento dos operadores.',
      difficulty:QuizDifficulty.hard,topic:'Comissionamento'),
  ];

  // ══════════════════════════════════════════════════
  // NR33 (10 questões)
  // ══════════════════════════════════════════════════
  static const _nr33 = [
    const _QE(id:'nr33_01',question:'O que define um espaço confinado segundo a NR-33?',
      options:['Qualquer local fechado','Espaço não projetado para ocupação humana contínua, com acesso limitado e risco de atmosfera perigosa','Sala sem janelas','Porão de edificação'],correctIndex:1,
      explanation:'Espaço confinado: não projetado para ocupação contínua, acesso limitado, risco atmosférico.',
      difficulty:QuizDifficulty.easy,topic:'Definição'),
    const _QE(id:'nr33_02',question:'Qual o nível mínimo de oxigênio para entrada segura em espaço confinado?',
      options:['16%','18%','19,5%','21%'],correctIndex:2,
      explanation:'Nível mínimo de O₂: 19,5%. Abaixo disso é atmosfera IDLH (perigo imediato).',
      difficulty:QuizDifficulty.easy,topic:'Atmosfera'),
    const _QE(id:'nr33_03',question:'Qual a função do Vigia na NR-33?',
      options:['Operar equipamentos dentro do espaço','Permanecer fora, monitorar os trabalhadores e acionar emergência se necessário','Fazer medições atmosféricas','Autorizar a entrada'],correctIndex:1,
      explanation:'Vigia: permanece fora, monitora trabalhadores, mantém comunicação e aciona emergência.',
      difficulty:QuizDifficulty.medium,topic:'Vigia'),
    const _QE(id:'nr33_04',question:'O que é a PET (Permissão de Entrada e Trabalho)?',
      options:['Autorização verbal do supervisor','Documento escrito com medidas de segurança, válido para uma única entrada','Certificado de treinamento','Laudo de medição atmosférica'],correctIndex:1,
      explanation:'PET: documento formal com procedimentos, medidas de controle e validade para entrada única.',
      difficulty:QuizDifficulty.medium,topic:'PET'),
    const _QE(id:'nr33_05',question:'Em caso de acidente em espaço confinado, o Vigia deve:',
      options:['Entrar imediatamente para socorrer','NUNCA entrar — acionar procedimento de resgate e serviço de emergência','Pedir ajuda a colegas para entrar','Desligar a ventilação'],correctIndex:1,
      explanation:'Vigia NUNCA entra. Aciona resgate treinado e serviço de emergência.',
      difficulty:QuizDifficulty.hard,topic:'Emergência'),
    const _QE(id:'nr33_06',question:'SCBA (Self-Contained Breathing Apparatus) é obrigatório quando:',
      options:['Sempre','A atmosfera é IDLH (perigo imediato à vida ou saúde)','O espaço tem mais de 2 metros','Há poeira no ambiente'],correctIndex:1,
      explanation:'SCBA obrigatório em atmosfera IDLH: deficiência de O₂, gases tóxicos ou inflamáveis.',
      difficulty:QuizDifficulty.hard,topic:'Equipamentos'),
    const _QE(id:'nr33_07',question:'De quanto em quanto tempo os detectores de gases devem ser calibrados?',
      options:['Anualmente','Conforme recomendação do fabricante, geralmente antes de cada uso','A cada 5 anos','Nunca, são permanentes'],correctIndex:1,
      explanation:'Calibração conforme fabricante, tipicamente antes de cada uso e periodicamente.',
      difficulty:QuizDifficulty.medium,topic:'Equipamentos'),
    const _QE(id:'nr33_08',question:'Qual a validade do treinamento NR-33?',
      options:['6 meses','1 ano','2 anos','5 anos'],correctIndex:1,
      explanation:'Treinamento NR-33: validade de 1 ano para trabalhadores e vigias.',
      difficulty:QuizDifficulty.easy,topic:'Treinamento'),
    const _QE(id:'nr33_09',question:'Quais os 3 perigos atmosféricos principais em espaços confinados?',
      options:['Calor, frio, umidade','Deficiência de O₂, gases tóxicos e atmosfera inflamável/explosiva','Poeira, ruído, vibração','Radiação, pressão, temperatura'],correctIndex:1,
      explanation:'Três perigos: deficiência de oxigênio, gases/vapores tóxicos e atmosfera inflamável.',
      difficulty:QuizDifficulty.medium,topic:'Atmosfera'),
    const _QE(id:'nr33_10',question:'O Supervisor de Entrada é responsável por:',
      options:['Entrar no espaço confinado','Emitir a PET, coordenar operações, garantir procedimentos e cancelar entrada se necessário','Fornecer EPIs','Fazer medições atmosféricas'],correctIndex:1,
      explanation:'Supervisor: emite PET, coordena, garante procedimentos e pode cancelar a entrada.',
      difficulty:QuizDifficulty.hard,topic:'Supervisor'),
  ];

  // ══════════════════════════════════════════════════
  // NR23 (10 questões)
  // ══════════════════════════════════════════════════
  static const _nr23 = [
    const _QE(id:'nr23_01',question:'Qual o agente extintor adequado para incêndios em equipamentos elétricos?',
      options:['Água','Espuma','CO₂ (gás carbônico)','Areia'],correctIndex:2,
      explanation:'Classe C (elétricos): CO₂ ou pó químico seco. Nunca usar água.',
      difficulty:QuizDifficulty.easy,topic:'Classes de incêndio'),
    const _QE(id:'nr23_02',question:'O que deve constar no plano de emergência contra incêndio?',
      options:['Apenas telefones','Rotas de fuga, pontos de encontro, brigada e procedimentos de evacuação','Localização dos extintores','Mapa do prédio'],correctIndex:1,
      explanation:'Plano: rotas de fuga, saídas, pontos de encontro, brigada e procedimentos.',
      difficulty:QuizDifficulty.medium,topic:'Plano'),
    const _QE(id:'nr23_03',question:'Frequência de inspeção dos extintores:',
      options:['Semestralmente','Anualmente ou quando utilizado','A cada 2 anos','A cada 5 anos'],correctIndex:1,
      explanation:'Inspeção (recarga) anual ou quando utilizado. Teste hidrostático a cada 5 anos.',
      difficulty:QuizDifficulty.easy,topic:'Manutenção'),
    const _QE(id:'nr23_04',question:'As saídas de emergência devem:',
      options:['Estar trancadas','Abrir no sentido da fuga, sem trancas, sempre desobstruídas','Sinalizadas apenas em horário comercial','Ter acesso restrito'],correctIndex:1,
      explanation:'Saídas: abrem no sentido do fluxo de fuga, sem trancas, sempre desobstruídas.',
      difficulty:QuizDifficulty.easy,topic:'Saídas'),
    const _QE(id:'nr23_05',question:'Incêndio classe A envolve:',
      options:['Líquidos inflamáveis','Equipamentos elétricos','Materiais sólidos que queimam em superfície e profundidade (madeira, papel)','Metais combustíveis'],correctIndex:2,
      explanation:'Classe A: sólidos (madeira, papel, tecido). B: líquidos. C: elétricos. D: metais.',
      difficulty:QuizDifficulty.easy,topic:'Classes'),
    const _QE(id:'nr23_06',question:'O que é o triângulo do fogo?',
      options:['Três tipos de extintor','Combustível, comburente (O₂) e calor — remover qualquer um extingue o fogo','Três classes de incêndio','Três etapas de evacuação'],correctIndex:1,
      explanation:'Triângulo: combustível + comburente + calor. Remover qualquer elemento extingue.',
      difficulty:QuizDifficulty.medium,topic:'Teoria'),
    const _QE(id:'nr23_07',question:'A técnica PASS para uso do extintor significa:',
      options:['Puxar, Apertar, Soprar, Sacudir','Puxar o pino, Apontar a mangueira, Soltar a alavanca, Soprar lateralmente','Pull (puxar pino), Aim (apontar), Squeeze (acionar), Sweep (varrer a base)','Preparar, Avaliar, Sinalizar, Sair'],correctIndex:2,
      explanation:'PASS: Pull, Aim, Squeeze, Sweep — puxar, apontar na base, acionar, varrer.',
      difficulty:QuizDifficulty.medium,topic:'Extintor'),
    const _QE(id:'nr23_08',question:'Distância máxima para alcançar um extintor de incêndio:',
      options:['10 metros','15 metros','25 metros','50 metros'],correctIndex:2,
      explanation:'Distância máxima de caminhamento até o extintor: 25 metros (ABNT).',
      difficulty:QuizDifficulty.hard,topic:'Instalação'),
    const _QE(id:'nr23_09',question:'Ao descobrir um incêndio, o primeiro procedimento é:',
      options:['Tentar combater sozinho','Acionar o alarme de incêndio e alertar as pessoas','Ligar para os bombeiros','Fechar portas e janelas'],correctIndex:1,
      explanation:'Primeiro: acionar alarme e alertar. Depois: combater se possível e seguro.',
      difficulty:QuizDifficulty.medium,topic:'Emergência'),
    const _QE(id:'nr23_10',question:'Extintor classe K é indicado para:',
      options:['Incêndios em metais','Incêndios em cozinhas com óleos e gorduras vegetais/animais','Incêndios florestais','Incêndios em veículos'],correctIndex:1,
      explanation:'Classe K: gorduras de cozinha. Agente: acetato de potássio (saponificação).',
      difficulty:QuizDifficulty.hard,topic:'Classes'),
  ];

  // ══════════════════════════════════════════════════
  // NR05 (10 questões)
  // ══════════════════════════════════════════════════
  static const _nr05 = [
    const _QE(id:'nr05_01',question:'O que é CIPA?',
      options:['Conselho de Inspeção','Comissão Interna de Prevenção de Acidentes e de Assédio','Centro de Informações','Comitê de Investigação'],correctIndex:1,
      explanation:'CIPA: Comissão Interna de Prevenção de Acidentes e de Assédio (atualização 2023).',
      difficulty:QuizDifficulty.easy,topic:'Definição'),
    const _QE(id:'nr05_02',question:'Como são eleitos os representantes dos empregados na CIPA?',
      options:['Indicados pela empresa','Eleição secreta com participação de todos os empregados','Escolhidos pelo sindicato','Sorteio entre voluntários'],correctIndex:1,
      explanation:'Eleição secreta, voto direto, com participação de todos os empregados.',
      difficulty:QuizDifficulty.medium,topic:'Eleição'),
    const _QE(id:'nr05_03',question:'Qual a estabilidade do cipeiro eleito?',
      options:['Nenhuma','Da candidatura até 1 ano após o mandato, contra demissão arbitrária','Apenas durante o mandato','3 anos após o mandato'],correctIndex:1,
      explanation:'Estabilidade: da candidatura até 1 ano após término do mandato.',
      difficulty:QuizDifficulty.medium,topic:'Estabilidade'),
    const _QE(id:'nr05_04',question:'Qual a duração do mandato da CIPA?',
      options:['6 meses','1 ano, permitida 1 reeleição','2 anos','Indeterminado'],correctIndex:1,
      explanation:'Mandato de 1 ano, permitida uma única reeleição.',
      difficulty:QuizDifficulty.easy,topic:'Mandato'),
    const _QE(id:'nr05_05',question:'O que é o Mapa de Riscos?',
      options:['Planta baixa da empresa','Representação gráfica dos riscos ambientais nos setores de trabalho','Lista de acidentes ocorridos','Relatório de EPIs'],correctIndex:1,
      explanation:'Mapa de Riscos: representação gráfica dos riscos por setor, elaborado pela CIPA.',
      difficulty:QuizDifficulty.medium,topic:'Mapa de Riscos'),
    const _QE(id:'nr05_06',question:'Frequência das reuniões ordinárias da CIPA:',
      options:['Quinzenal','Mensal','Trimestral','Semestral'],correctIndex:1,
      explanation:'Reuniões ordinárias mensais, durante o expediente normal.',
      difficulty:QuizDifficulty.easy,topic:'Reuniões'),
    const _QE(id:'nr05_07',question:'Quando a CIPA é obrigatória?',
      options:['Em todas as empresas','Conforme Quadro I da NR-05, baseado no CNAE e número de empregados','Apenas em indústrias','Apenas com mais de 100 empregados'],correctIndex:1,
      explanation:'Obrigatoriedade definida pelo Quadro I: CNAE + número de empregados.',
      difficulty:QuizDifficulty.medium,topic:'Obrigatoriedade'),
    const _QE(id:'nr05_08',question:'Empresas menores sem CIPA devem ter:',
      options:['Nenhuma obrigação','Designado de segurança com treinamento','Apenas kit de primeiros socorros','Contrato com hospital'],correctIndex:1,
      explanation:'Empresas sem CIPA: designado de segurança com treinamento obrigatório.',
      difficulty:QuizDifficulty.medium,topic:'Designado'),
    const _QE(id:'nr05_09',question:'Carga horária do treinamento obrigatório dos cipeiros:',
      options:['8 horas','20 horas','40 horas','60 horas'],correctIndex:1,
      explanation:'Treinamento de 20 horas para membros da CIPA.',
      difficulty:QuizDifficulty.easy,topic:'Treinamento'),
    const _QE(id:'nr05_10',question:'Desde 2023, a CIPA também atua na prevenção de:',
      options:['Acidentes de trânsito','Assédio moral e sexual no ambiente de trabalho','Doenças infecciosas','Acidentes domésticos'],correctIndex:1,
      explanation:'Lei 14.457/2022: CIPA inclui prevenção de assédio moral e sexual.',
      difficulty:QuizDifficulty.hard,topic:'Assédio'),
  ];

  // ══════════════════════════════════════════════════
  // NR17 (10 questões)
  // ══════════════════════════════════════════════════
  static const _nr17 = [
    const _QE(id:'nr17_01',question:'O que é ergonomia conforme a NR-17?',
      options:['Estudo de máquinas','Adaptação das condições de trabalho às características psicofisiológicas dos trabalhadores','Ginástica laboral','Organização do espaço de trabalho'],correctIndex:1,
      explanation:'Ergonomia: adaptação das condições de trabalho ao ser humano.',
      difficulty:QuizDifficulty.easy,topic:'Definição'),
    const _QE(id:'nr17_02',question:'O que é AET (Análise Ergonômica do Trabalho)?',
      options:['Exame médico','Estudo aprofundado das condições ergonômicas que identifica riscos e propõe melhorias','Relatório de acidentes','Avaliação de desempenho'],correctIndex:1,
      explanation:'AET: estudo técnico das condições ergonômicas com diagnóstico e recomendações.',
      difficulty:QuizDifficulty.medium,topic:'AET'),
    const _QE(id:'nr17_03',question:'Sobre peso máximo para transporte manual na NR-17:',
      options:['60 kg fixo','40 kg para homens','A NR-17 não define peso fixo — exige avaliação ergonômica caso a caso','25 kg para todos'],correctIndex:2,
      explanation:'NR-17 não define peso máximo fixo. Exige avaliação ergonômica considerando cada situação.',
      difficulty:QuizDifficulty.hard,topic:'Transporte manual'),
    const _QE(id:'nr17_04',question:'O que é IBUTG e sua relação com conforto térmico?',
      options:['Índice de iluminação','Índice de Bulbo Úmido Termômetro de Globo — mede estresse térmico','Indicador de ruído','Taxa de ventilação'],correctIndex:1,
      explanation:'IBUTG: índice que avalia exposição ao calor no ambiente de trabalho.',
      difficulty:QuizDifficulty.hard,topic:'Conforto térmico'),
    const _QE(id:'nr17_05',question:'O que é LER/DORT?',
      options:['Lesão por esforço físico único','Lesões por Esforços Repetitivos / Distúrbios Osteomusculares Relacionados ao Trabalho','Lesão por exposição a ruído','Doença respiratória ocupacional'],correctIndex:1,
      explanation:'LER/DORT: doenças causadas por movimentos repetitivos e postura inadequada.',
      difficulty:QuizDifficulty.easy,topic:'LER/DORT'),
    const _QE(id:'nr17_06',question:'Altura ideal da superfície de trabalho para posição sentada:',
      options:['Igual à altura do joelho','Na altura dos cotovelos com braços relaxados, permitindo ângulo de 90° nos cotovelos','Na altura do ombro','Qualquer altura com apoio de pé'],correctIndex:1,
      explanation:'Superfície na altura dos cotovelos, ângulo de ~90° nos cotovelos, ombros relaxados.',
      difficulty:QuizDifficulty.medium,topic:'Mobiliário'),
    const _QE(id:'nr17_07',question:'Pausas em teleatendimento segundo Anexo II da NR-17:',
      options:['Nenhuma obrigatória','2 pausas de 10 minutos em jornada de 6h, totalizando 20 min','Pausa de 1 hora','15 minutos a cada 2 horas'],correctIndex:1,
      explanation:'Anexo II: duas pausas de 10 min em jornada de 6h (fora intervalo de refeição).',
      difficulty:QuizDifficulty.medium,topic:'Pausas'),
    const _QE(id:'nr17_08',question:'Quem elabora a AET?',
      options:['O supervisor do setor','Profissional habilitado em ergonomia (ergonomista)','O médico do trabalho','O próprio trabalhador'],correctIndex:1,
      explanation:'AET elaborada por profissional habilitado com conhecimento em ergonomia.',
      difficulty:QuizDifficulty.medium,topic:'AET'),
    const _QE(id:'nr17_09',question:'Iluminação inadequada como fator ergonômico pode causar:',
      options:['Apenas desconforto visual','Fadiga visual, cefaleia, erros e acidentes de trabalho','Problemas auditivos','Doenças respiratórias'],correctIndex:1,
      explanation:'Iluminação inadequada: fadiga, dores de cabeça, erros e riscos de acidentes.',
      difficulty:QuizDifficulty.easy,topic:'Iluminação'),
    const _QE(id:'nr17_10',question:'O que deve constar no laudo ergonômico?',
      options:['Apenas fotos do posto','Análise das condições de trabalho, riscos identificados e recomendações técnicas','Nome dos funcionários','Apenas a planta do setor'],correctIndex:1,
      explanation:'Laudo: análise detalhada, identificação de riscos e recomendações de melhoria.',
      difficulty:QuizDifficulty.medium,topic:'Laudo'),
  ];

  // ══════════════════════════════════════════════════
  // NR18 (10 questões)
  // ══════════════════════════════════════════════════
  static const _nr18 = [
    const _QE(id:'nr18_01',question:'A NR-18 aplica-se a:',
      options:['Todas as indústrias','Atividades da indústria da construção civil','Apenas obras públicas','Apenas edifícios acima de 5 andares'],correctIndex:1,
      explanation:'NR-18: norma regulamentadora da construção civil e atividades complementares.',
      difficulty:QuizDifficulty.easy,topic:'Aplicação'),
    const _QE(id:'nr18_02',question:'O PCMAT é obrigatório para obras com:',
      options:['Qualquer número','20 ou mais trabalhadores','50 ou mais trabalhadores','100 ou mais trabalhadores'],correctIndex:1,
      explanation:'PCMAT obrigatório em obras com 20 ou mais trabalhadores.',
      difficulty:QuizDifficulty.medium,topic:'PCMAT'),
    const _QE(id:'nr18_03',question:'Especificações do guarda-corpo definitivo na construção:',
      options:['1,00m de altura','1,20m de altura, travessão intermediário a 0,70m e rodapé de 0,20m','1,50m de altura','Qualquer altura acima de 0,90m'],correctIndex:1,
      explanation:'Guarda-corpo: 1,20m de altura, travessão a 0,70m e rodapé de 0,20m.',
      difficulty:QuizDifficulty.medium,topic:'Proteção'),
    const _QE(id:'nr18_04',question:'EPIs obrigatórios na construção civil incluem:',
      options:['Apenas capacete','Capacete, calçado de segurança, óculos, protetor auricular e cinto (quando aplicável)','Apenas botas','Apenas luvas e capacete'],correctIndex:1,
      explanation:'EPIs básicos: capacete classe B, calçado, óculos, protetor auricular.',
      difficulty:QuizDifficulty.easy,topic:'EPIs'),
    const _QE(id:'nr18_05',question:'Proteção contra queda na construção é obrigatória a partir de:',
      options:['1 metro','2 metros de altura','3 metros','4 metros'],correctIndex:1,
      explanation:'Proteção contra queda obrigatória a partir de 2m, conforme NR-18.',
      difficulty:QuizDifficulty.easy,topic:'Queda'),
    const _QE(id:'nr18_06',question:'A Ordem de Serviço de Segurança deve:',
      options:['Ser verbal','Informar riscos, medidas de proteção e procedimentos por escrito ao trabalhador','Ser afixada apenas no escritório','Ser entregue apenas na admissão'],correctIndex:1,
      explanation:'Ordem de Serviço: documento escrito com riscos e medidas, entregue ao trabalhador.',
      difficulty:QuizDifficulty.medium,topic:'Documentação'),
    const _QE(id:'nr18_07',question:'Escavações acima de que profundidade exigem escoramento?',
      options:['0,50m','1,25m','2,00m','3,00m'],correctIndex:1,
      explanation:'Escoramento obrigatório em escavações acima de 1,25m de profundidade.',
      difficulty:QuizDifficulty.medium,topic:'Escavações'),
    const _QE(id:'nr18_08',question:'Largura mínima de andaime para trabalho:',
      options:['0,40m','0,60m','0,80m','1,00m'],correctIndex:1,
      explanation:'Largura mínima do piso de andaime: 0,60m.',
      difficulty:QuizDifficulty.hard,topic:'Andaimes'),
    const _QE(id:'nr18_09',question:'O SESMT na construção civil é obrigatório conforme:',
      options:['NR-04, baseado no grau de risco e número de empregados','NR-18 apenas','Decisão do engenheiro','Tamanho da obra'],correctIndex:0,
      explanation:'SESMT dimensionado pela NR-04: grau de risco (3 ou 4) e número de empregados.',
      difficulty:QuizDifficulty.hard,topic:'SESMT'),
    const _QE(id:'nr18_10',question:'É proibido içar pessoas juntamente com materiais:',
      options:['Falso, desde que com autorização','Verdadeiro — transporte de pessoas e materiais deve ser separado','Permitido em obras pequenas','Permitido com EPI adequado'],correctIndex:1,
      explanation:'Proibido transporte simultâneo de pessoas e materiais em equipamentos de içamento.',
      difficulty:QuizDifficulty.easy,topic:'Içamento'),
  ];

  // ══════════════════════════════════════════════════
  // NR06 (5 questões)
  // ══════════════════════════════════════════════════
  static const _nr06 = [
    const _QE(id:'nr06_01',question:'De quem é a responsabilidade de fornecer EPIs?',
      options:['Do trabalhador','Do sindicato','Do empregador, gratuitamente','Do governo'],correctIndex:2,
      explanation:'NR-06: empregador fornece EPIs adequados ao risco, gratuitamente.',
      difficulty:QuizDifficulty.easy,topic:'Fornecimento'),
    const _QE(id:'nr06_02',question:'O que é o CA (Certificado de Aprovação)?',
      options:['Certificado de treinamento','Documento que comprova que o EPI atende às normas técnicas','CNPJ do fabricante','Nota fiscal'],correctIndex:1,
      explanation:'CA: emitido pelo MTE, garante que o EPI foi testado e aprovado.',
      difficulty:QuizDifficulty.easy,topic:'CA'),
    const _QE(id:'nr06_03',question:'O trabalhador pode se recusar a usar EPI?',
      options:['Sim, sempre','Sim, se desconfortável','Não — uso obrigatório, recusa pode gerar justa causa','Sim, com experiência'],correctIndex:2,
      explanation:'Uso obrigatório. Recusa injustificada: advertência, suspensão ou justa causa.',
      difficulty:QuizDifficulty.medium,topic:'Obrigações'),
    const _QE(id:'nr06_04',question:'Validade do CA de um EPI:',
      options:['1 ano','2 anos','3 anos','5 anos'],correctIndex:3,
      explanation:'CA tem validade de 5 anos, podendo ser renovado pelo fabricante.',
      difficulty:QuizDifficulty.medium,topic:'Validade'),
    const _QE(id:'nr06_05',question:'O empregador deve documentar a entrega de EPI com:',
      options:['Nada, basta entregar','Ficha de controle com assinatura do trabalhador','Foto do momento','E-mail de confirmação'],correctIndex:1,
      explanation:'Ficha de entrega com assinatura: comprova o fornecimento e orientação de uso.',
      difficulty:QuizDifficulty.easy,topic:'Controle'),
  ];

  // ══════════════════════════════════════════════════
  // NR07 (5 questões)
  // ══════════════════════════════════════════════════
  static const _nr07 = [
    const _QE(id:'nr07_01',question:'O PCMSO é elaborado por:',
      options:['Engenheiro de segurança','Médico do trabalho','Técnico de segurança','Enfermeiro'],correctIndex:1,
      explanation:'PCMSO: elaborado e coordenado por médico do trabalho.',
      difficulty:QuizDifficulty.easy,topic:'PCMSO'),
    const _QE(id:'nr07_02',question:'Quais são os 5 tipos de exame médico obrigatórios do PCMSO?',
      options:['Apenas admissional e demissional','Admissional, periódico, retorno ao trabalho, mudança de risco e demissional','Admissional, anual e aposentadoria','Apenas periódico e demissional'],correctIndex:1,
      explanation:'Cinco tipos: admissional, periódico, retorno, mudança de risco e demissional.',
      difficulty:QuizDifficulty.medium,topic:'Exames'),
    const _QE(id:'nr07_03',question:'O que é o ASO (Atestado de Saúde Ocupacional)?',
      options:['Atestado de óbito','Documento que registra resultado do exame e aptidão para a função','Receita médica','Declaração de comparecimento'],correctIndex:1,
      explanation:'ASO: documento com resultado do exame médico e aptidão (apto/inapto).',
      difficulty:QuizDifficulty.easy,topic:'ASO'),
    const _QE(id:'nr07_04',question:'A empresa pode demitir trabalhador por motivo de doença ocupacional?',
      options:['Sim, a qualquer momento','Não — demissão por doença ocupacional é ilegal e gera estabilidade','Sim, após 30 dias','Sim, com indenização'],correctIndex:1,
      explanation:'Trabalhador com doença ocupacional tem estabilidade de 12 meses após recuperação.',
      difficulty:QuizDifficulty.hard,topic:'Direitos'),
    const _QE(id:'nr07_05',question:'O PCMSO deve estar articulado com qual outro programa?',
      options:['PPRA/PGR','PCMAT','SIPAT','PAE'],correctIndex:0,
      explanation:'PCMSO articulado com PGR (antigo PPRA) para reconhecer riscos e definir exames.',
      difficulty:QuizDifficulty.medium,topic:'Integração'),
  ];

  // ══════════════════════════════════════════════════
  // NR15 (5 questões)
  // ══════════════════════════════════════════════════
  static const _nr15 = [
    const _QE(id:'nr15_01',question:'O que é insalubridade?',
      options:['Trabalho perigoso','Exposição a agentes nocivos acima dos limites de tolerância, causando danos à saúde','Trabalho noturno','Trabalho em altura'],correctIndex:1,
      explanation:'Insalubridade: exposição a agentes nocivos acima dos limites de tolerância.',
      difficulty:QuizDifficulty.easy,topic:'Definição'),
    const _QE(id:'nr15_02',question:'Quais os graus e adicionais de insalubridade?',
      options:['Único: 20%','Mínimo 10%, médio 20%, máximo 40% sobre o salário mínimo','Mínimo 20%, máximo 50%','Único: 30%'],correctIndex:1,
      explanation:'Três graus: mínimo (10%), médio (20%) e máximo (40%) sobre salário mínimo.',
      difficulty:QuizDifficulty.medium,topic:'Graus'),
    const _QE(id:'nr15_03',question:'A insalubridade pode ser eliminada por:',
      options:['Pagamento do adicional apenas','Eliminação ou neutralização do agente com EPC ou EPI adequado','Acordo coletivo','Mudança de setor'],correctIndex:1,
      explanation:'Eliminar ou neutralizar o agente: EPC prioritário, EPI quando EPC insuficiente.',
      difficulty:QuizDifficulty.medium,topic:'Eliminação'),
    const _QE(id:'nr15_04',question:'Limite de tolerância para ruído contínuo em 8h de exposição:',
      options:['70 dB','80 dB','85 dB','90 dB'],correctIndex:2,
      explanation:'Limite de tolerância: 85 dB(A) para jornada de 8 horas (Anexo 1 da NR-15).',
      difficulty:QuizDifficulty.hard,topic:'Ruído'),
    const _QE(id:'nr15_05',question:'É possível acumular adicionais de insalubridade e periculosidade?',
      options:['Sim, sempre','Não — o trabalhador opta pelo mais vantajoso (CLT Art. 193 §2°)','Sim, em indústrias','Sim, para ruído e eletricidade'],correctIndex:1,
      explanation:'Vedado acúmulo: trabalhador escolhe o adicional mais favorável.',
      difficulty:QuizDifficulty.hard,topic:'Acúmulo'),
  ];

  // ══════════════════════════════════════════════════
  // NR16 (5 questões)
  // ══════════════════════════════════════════════════
  static const _nr16 = [
    const _QE(id:'nr16_01',question:'Qual o percentual do adicional de periculosidade?',
      options:['10%','20%','30% sobre o salário base','40%'],correctIndex:2,
      explanation:'Adicional de periculosidade: 30% sobre o salário base (sem acréscimos).',
      difficulty:QuizDifficulty.easy,topic:'Adicional'),
    const _QE(id:'nr16_02',question:'Atividades perigosas incluem:',
      options:['Trabalho em escritório','Contato com inflamáveis, explosivos, energia elétrica, radiação e segurança pessoal','Trabalho em restaurante','Trabalho em comércio'],correctIndex:1,
      explanation:'Periculosidade: inflamáveis, explosivos, eletricidade, radiação, segurança.',
      difficulty:QuizDifficulty.medium,topic:'Atividades'),
    const _QE(id:'nr16_03',question:'O uso de EPI elimina o direito ao adicional de periculosidade?',
      options:['Sim, sempre','Não — EPI não elimina condição perigosa para fins do adicional','Sim, se aprovado pelo SESMT','Depende do tipo de EPI'],correctIndex:1,
      explanation:'EPI não elimina periculosidade. O adicional é devido enquanto existir a exposição.',
      difficulty:QuizDifficulty.hard,topic:'EPI'),
    const _QE(id:'nr16_04',question:'Motociclista profissional tem direito a adicional de periculosidade?',
      options:['Não','Sim — Lei 12.997/2014 incluiu atividade em motocicleta como perigosa','Apenas motoboys','Apenas policiais'],correctIndex:1,
      explanation:'Lei 12.997/2014: uso de motocicleta no trabalho é atividade perigosa.',
      difficulty:QuizDifficulty.medium,topic:'Motociclista'),
    const _QE(id:'nr16_05',question:'Quem emite o laudo de periculosidade?',
      options:['O empregador','Engenheiro de segurança ou médico do trabalho registrado no MTE','O sindicato','O INSS'],correctIndex:1,
      explanation:'Laudo: engenheiro de segurança ou médico do trabalho com registro no MTE.',
      difficulty:QuizDifficulty.medium,topic:'Laudo'),
  ];

  // ══════════════════════════════════════════════════
  // Genéricas
  // ══════════════════════════════════════════════════
  static const _generic = [
    const _QE(id:'gen_01',question:'Qual o objetivo das Normas Regulamentadoras (NRs)?',
      options:['Recomendações opcionais','Disposições obrigatórias de segurança e saúde no trabalho','Regras internas','Apenas para construção civil'],correctIndex:1,
      explanation:'NRs: disposições complementares ao Cap. V da CLT, de cumprimento obrigatório.',
      difficulty:QuizDifficulty.easy,topic:'NRs'),
    const _QE(id:'gen_02',question:'Qual o prazo para emitir a CAT (Comunicação de Acidente de Trabalho)?',
      options:['Imediatamente','Até o 1º dia útil seguinte ao acidente','7 dias','30 dias'],correctIndex:1,
      explanation:'CAT: até 1º dia útil seguinte. Em caso de morte, comunicação imediata.',
      difficulty:QuizDifficulty.medium,topic:'CAT'),
    const _QE(id:'gen_03',question:'O trabalhador pode recusar trabalho com risco grave e iminente?',
      options:['Nunca','Sim — direito de recusa previsto na CLT Art. 483 e NR-01','Apenas com autorização','Só após acidente'],correctIndex:1,
      explanation:'Direito de recusa: CLT Art. 483 e NR-01 — risco grave e iminente à vida.',
      difficulty:QuizDifficulty.medium,topic:'Direito de recusa'),
  ];
}
