import '../models/quiz_question.dart';

/// Serviço de questões para avaliação final de cada curso NR.
/// Cada curso tem seu próprio banco — nunca reutilizar entre NRs.
class QuizService {
  /// Retorna as questões de avaliação para um curso específico.
  static List<QuizQuestion> getQuestionsForCourse(String courseId) {
    switch (courseId) {
      case 'nr35':
        return _nr35Questions;
      case 'nr10':
        return _nr10Questions;
      case 'nr12':
        return _nr12Questions;
      case 'nr23':
        return _nr23Questions;
      case 'nr06':
        return _nr06Questions;
      default:
        return _genericQuestions;
    }
  }

  // ══════════════════════════════════════════
  // NR-35 — Trabalho em Altura (10 questões)
  // ══════════════════════════════════════════
  static const _nr35Questions = [
    QuizQuestion(
      id: 'nr35_01',
      question:
          'Qual a altura mínima definida pela NR-35 para considerar trabalho em altura?',
      options: ['1 metro', '1,5 metros', '2 metros', '3 metros'],
      correctIndex: 2,
      explanation:
          'A NR-35 define como trabalho em altura qualquer atividade executada acima de 2,00m do nível inferior, onde haja risco de queda.',
    ),
    QuizQuestion(
      id: 'nr35_02',
      question:
          'O que é obrigatório elaborar antes de iniciar qualquer trabalho em altura?',
      options: [
        'Apenas usar cinto de segurança',
        'Análise de Risco (AR) e, quando aplicável, Permissão de Trabalho (PT)',
        'Avisar o supervisor imediato',
        'Instalar rede de proteção',
      ],
      correctIndex: 1,
      explanation:
          'A NR-35 exige elaboração de Análise de Risco (AR) antes de cada trabalho em altura. A Permissão de Trabalho (PT) é exigida para atividades de risco elevado.',
    ),
    QuizQuestion(
      id: 'nr35_03',
      question:
          'Com que frequência os EPIs de proteção contra quedas devem ser inspecionados?',
      options: [
        'Mensalmente',
        'A cada 6 meses',
        'Anualmente',
        'Antes de cada uso e periodicamente conforme fabricante',
      ],
      correctIndex: 3,
      explanation:
          'Os EPIs devem ser inspecionados antes de cada uso pelo próprio trabalhador e periodicamente por pessoa habilitada, conforme recomendação do fabricante.',
    ),
    QuizQuestion(
      id: 'nr35_04',
      question:
          'Qual o prazo de validade do treinamento de trabalho em altura (NR-35)?',
      options: ['1 ano', '2 anos', '3 anos', '5 anos'],
      correctIndex: 1,
      explanation:
          'O treinamento da NR-35 tem validade de 2 anos. Também é obrigatório realizar treinamento periódico sempre que houver mudança nas condições de trabalho.',
    ),
    QuizQuestion(
      id: 'nr35_05',
      question:
          'O que caracteriza um Sistema de Proteção Coletiva contra quedas?',
      options: [
        'Uso de cinto de segurança por todos os trabalhadores',
        'Instalação de corda de segurança',
        'Andaimes, guarda-corpos, redes de proteção e telas — medidas que protegem todos',
        'Sinalização de área de risco',
      ],
      correctIndex: 2,
      explanation:
          'Proteções Coletivas (EPC) são prioritárias sobre proteções individuais (EPI). Exemplos: andaimes, plataformas, guarda-corpos, redes e telas de proteção.',
    ),
    QuizQuestion(
      id: 'nr35_06',
      question:
          'Em caso de resgate de trabalhador inconsciente suspenso em altura, qual a preocupação crítica?',
      options: [
        'Aguardar o SAMU antes de qualquer ação',
        'Remover o EPI imediatamente',
        'Síndrome do arnês — posição horizontal o mais rápido possível',
        'Cortar a corda de segurança',
      ],
      correctIndex: 2,
      explanation:
          'A síndrome do arnês (trauma de suspensão) pode causar morte em minutos. O trabalhador deve ser colocado em posição horizontal imediatamente após o resgate.',
    ),
    QuizQuestion(
      id: 'nr35_07',
      question: 'Quem pode ministrar o treinamento de NR-35?',
      options: [
        'Qualquer trabalhador com experiência em altura',
        'Profissional habilitado ou qualificado, com capacitação em NR-35',
        'Apenas engenheiros de segurança do trabalho',
        'O próprio supervisor da obra',
      ],
      correctIndex: 1,
      explanation:
          'O treinamento deve ser ministrado por profissional legalmente habilitado ou qualificado, com capacitação específica em trabalho em altura.',
    ),
    QuizQuestion(
      id: 'nr35_08',
      question:
          'O que deve conter o plano de resgate antes de iniciar trabalho em altura?',
      options: [
        'Apenas o número do SAMU',
        'Procedimentos, equipamentos, responsáveis treinados e contatos de emergência',
        'Somente a localização do hospital mais próximo',
        'Lista de EPIs disponíveis no canteiro',
      ],
      correctIndex: 1,
      explanation:
          'O plano de resgate deve contemplar procedimentos, equipamentos, pessoal treinado e contatos de emergência.',
    ),
    QuizQuestion(
      id: 'nr35_09',
      question:
          'Trabalhador com acrofobia pode realizar trabalho em altura?',
      options: [
        'Sim, desde que use todos os EPIs',
        'Sim, se o supervisor autorizar',
        'Não — a NR-35 exige aptidão médica. Condições que comprometam o equilíbrio são impeditivas',
        'Sim, desde que seja abaixo de 5 metros',
      ],
      correctIndex: 2,
      explanation:
          'A NR-35 exige aptidão médica. Condições que afetam equilíbrio, consciência ou coordenação motora são impeditivas.',
    ),
    QuizQuestion(
      id: 'nr35_10',
      question:
          'O ponto de ancoragem para trabalho em altura deve suportar no mínimo:',
      options: ['200 kgf', '500 kgf', '1.000 kgf', '1.500 kgf (15 kN)'],
      correctIndex: 3,
      explanation:
          'O ponto de ancoragem deve suportar pelo menos 15 kN (~1.500 kgf) para quedas com fator ≥ 1, conforme especificação do fabricante do EPI.',
    ),
  ];

  // ══════════════════════════════════════════
  // NR-10 — Segurança em Eletricidade (5 questões)
  // ══════════════════════════════════════════
  static const _nr10Questions = [
    QuizQuestion(
      id: 'nr10_01',
      question: 'Qual a tensão mínima considerada perigosa pela NR-10?',
      options: ['12V', '25V em CA ou 60V em CC', '50V', '110V'],
      correctIndex: 1,
      explanation:
          'A NR-10 estabelece 50V em CA e 120V em CC como limites de extra-baixa tensão. Tensões acima de 25V CA ou 60V CC em ambientes úmidos já são consideradas perigosas.',
    ),
    QuizQuestion(
      id: 'nr10_02',
      question:
          'A primeira medida de segurança ao trabalhar com eletricidade é:',
      options: [
        'Usar luvas isolantes',
        'Desligar, bloquear e etiquetar a fonte de energia',
        'Verificar a tensão com multímetro',
        'Avisar o supervisor',
      ],
      correctIndex: 1,
      explanation:
          'O primeiro passo é sempre desenergizar: desligar, bloquear e sinalizar conforme procedimento de Lock-Out/Tag-Out (LOTO).',
    ),
    QuizQuestion(
      id: 'nr10_03',
      question: 'Qual a validade do curso NR-10 básico (40h)?',
      options: ['1 ano', '2 anos', '3 anos', '5 anos'],
      correctIndex: 1,
      explanation:
          'A reciclagem do treinamento de NR-10 deve ocorrer a cada 2 anos, ou quando houver mudanças significativas nas instalações ou procedimentos.',
    ),
    QuizQuestion(
      id: 'nr10_04',
      question: 'O que é a "zona controlada" em instalações elétricas?',
      options: [
        'Área ao redor de equipamento energizado com risco de choque',
        'Sala do quadro elétrico',
        'Qualquer local com fiação exposta',
        'Área com piso isolante',
      ],
      correctIndex: 0,
      explanation:
          'A zona controlada é a área ao redor de partes energizadas onde o acesso é restrito a profissionais autorizados com treinamento em NR-10.',
    ),
    QuizQuestion(
      id: 'nr10_05',
      question: 'O prontuário de instalações elétricas deve conter:',
      options: [
        'Apenas os diagramas unifilares',
        'Somente os laudos de aterramento',
        'Diagramas, laudos, procedimentos de segurança e certificados de treinamento',
        'Apenas os registros de manutenção',
      ],
      correctIndex: 2,
      explanation:
          'O prontuário deve conter diagramas, especificações, laudos, procedimentos operacionais, de segurança e certificados de treinamento.',
    ),
  ];

  // ══════════════════════════════════════════
  // NR-12 — Segurança em Máquinas (5 questões)
  // ══════════════════════════════════════════
  static const _nr12Questions = [
    QuizQuestion(
      id: 'nr12_01',
      question: 'Qual o objetivo principal da NR-12?',
      options: [
        'Regular o uso de EPIs em fábricas',
        'Definir medidas de proteção para garantir segurança em máquinas e equipamentos',
        'Estabelecer regras de ergonomia',
        'Normatizar a manutenção preventiva',
      ],
      correctIndex: 1,
      explanation:
          'A NR-12 define referências técnicas, princípios e medidas de proteção para garantir a saúde e integridade dos trabalhadores que operam máquinas.',
    ),
    QuizQuestion(
      id: 'nr12_02',
      question: 'O que são dispositivos de intertravamento em máquinas?',
      options: [
        'Dispositivos que aumentam a velocidade da máquina',
        'Sistemas que impedem o funcionamento em condições inseguras',
        'Alarmes sonoros de emergência',
        'Equipamentos de proteção individual',
      ],
      correctIndex: 1,
      explanation:
          'Dispositivos de intertravamento impedem o funcionamento da máquina quando condições de segurança não são atendidas (ex: porta de proteção aberta).',
    ),
    QuizQuestion(
      id: 'nr12_03',
      question: 'A parada de emergência de uma máquina deve:',
      options: [
        'Ser acionada apenas pelo supervisor',
        'Estar acessível a qualquer trabalhador, com acionamento rápido e prioritário',
        'Funcionar apenas em horário comercial',
        'Ser testada apenas uma vez por ano',
      ],
      correctIndex: 1,
      explanation:
          'O dispositivo de parada de emergência deve ser acessível, de fácil acionamento e ter prioridade sobre qualquer outro comando da máquina.',
    ),
    QuizQuestion(
      id: 'nr12_04',
      question: 'A zona de perigo (zona de risco) de uma máquina é:',
      options: [
        'A área administrativa da fábrica',
        'Qualquer área onde um trabalhador pode ficar exposto a perigos da máquina',
        'Apenas a zona de corte ou prensagem',
        'A área do almoxarifado de peças',
      ],
      correctIndex: 1,
      explanation:
          'A zona de perigo compreende qualquer área dentro ou ao redor da máquina onde o trabalhador pode estar exposto a riscos mecânicos, elétricos ou térmicos.',
    ),
    QuizQuestion(
      id: 'nr12_05',
      question: 'A capacitação para operar máquinas deve incluir:',
      options: [
        'Apenas treinamento prático',
        'Conteúdo teórico e prático, com carga horária compatível',
        'Apenas leitura do manual do fabricante',
        'Apenas demonstração visual',
      ],
      correctIndex: 1,
      explanation:
          'A capacitação deve ter conteúdo programático, carga horária compatível, parte teórica e prática, ministrada por profissional qualificado.',
    ),
  ];

  // ══════════════════════════════════════════
  // NR-23 — Proteção Contra Incêndios (5 questões)
  // ══════════════════════════════════════════
  static const _nr23Questions = [
    QuizQuestion(
      id: 'nr23_01',
      question: 'Qual o agente extintor adequado para incêndios em equipamentos elétricos?',
      options: ['Água', 'Espuma', 'CO₂ (gás carbônico)', 'Areia'],
      correctIndex: 2,
      explanation:
          'Em incêndios classe C (equipamentos elétricos energizados), deve-se usar extintor de CO₂ ou pó químico seco. Nunca usar água.',
    ),
    QuizQuestion(
      id: 'nr23_02',
      question: 'O que deve constar em um plano de emergência contra incêndio?',
      options: [
        'Apenas os telefones de emergência',
        'Rotas de fuga, pontos de encontro, brigada de incêndio e procedimentos de evacuação',
        'Somente a localização dos extintores',
        'Apenas o mapa do prédio',
      ],
      correctIndex: 1,
      explanation:
          'O plano de emergência deve incluir rotas de fuga, saídas de emergência, pontos de encontro, composição da brigada e procedimentos de evacuação.',
    ),
    QuizQuestion(
      id: 'nr23_03',
      question: 'De quanto em quanto tempo o extintor deve ser inspecionado?',
      options: ['Semestralmente', 'Anualmente', 'A cada 2 anos', 'A cada 5 anos'],
      correctIndex: 1,
      explanation:
          'A inspeção (recarga) dos extintores deve ser anual ou quando utilizado, e o teste hidrostático a cada 5 anos.',
    ),
    QuizQuestion(
      id: 'nr23_04',
      question: 'As saídas de emergência devem:',
      options: [
        'Estar trancadas com chave',
        'Abrir no sentido da fuga, sem trancas que impeçam a saída rápida',
        'Estar sinalizadas apenas em horário comercial',
        'Ter acesso restrito a funcionários',
      ],
      correctIndex: 1,
      explanation:
          'As saídas de emergência devem abrir no sentido do fluxo de fuga, sem trancas, e estar sempre desobstruídas e sinalizadas.',
    ),
    QuizQuestion(
      id: 'nr23_05',
      question: 'Incêndio classe A envolve materiais como:',
      options: [
        'Líquidos inflamáveis',
        'Equipamentos elétricos',
        'Materiais sólidos que queimam em superfície e profundidade (madeira, papel, tecido)',
        'Metais combustíveis',
      ],
      correctIndex: 2,
      explanation:
          'Classe A: sólidos que queimam em superfície e profundidade (madeira, papel, tecido). Classe B: líquidos. Classe C: elétricos. Classe D: metais.',
    ),
  ];

  // ══════════════════════════════════════════
  // NR-06 — EPIs (5 questões)
  // ══════════════════════════════════════════
  static const _nr06Questions = [
    QuizQuestion(
      id: 'nr06_01',
      question: 'De quem é a responsabilidade de fornecer EPIs ao trabalhador?',
      options: [
        'Do próprio trabalhador',
        'Do sindicato',
        'Do empregador, gratuitamente',
        'Do governo federal',
      ],
      correctIndex: 2,
      explanation:
          'A NR-06 estabelece que o empregador deve fornecer EPIs adequados ao risco, em perfeito estado, gratuitamente.',
    ),
    QuizQuestion(
      id: 'nr06_02',
      question: 'O que é o CA (Certificado de Aprovação) de um EPI?',
      options: [
        'O certificado de treinamento do trabalhador',
        'O documento que comprova que o EPI atende às normas técnicas',
        'O CNPJ do fabricante',
        'A nota fiscal de compra do equipamento',
      ],
      correctIndex: 1,
      explanation:
          'O CA é emitido pelo MTE e garante que o EPI foi testado e aprovado conforme normas técnicas. Todo EPI deve ter CA válido.',
    ),
    QuizQuestion(
      id: 'nr06_03',
      question: 'O trabalhador pode se recusar a usar o EPI?',
      options: [
        'Sim, sempre que quiser',
        'Sim, se achar desconfortável',
        'Não — o uso é obrigatório e a recusa pode gerar justa causa',
        'Sim, se tiver mais de 10 anos de experiência',
      ],
      correctIndex: 2,
      explanation:
          'O uso do EPI é obrigatório. A recusa injustificada constitui ato faltoso e pode gerar advertência, suspensão ou justa causa (CLT art. 482).',
    ),
    QuizQuestion(
      id: 'nr06_04',
      question: 'Quando o EPI deve ser substituído?',
      options: [
        'Apenas quando o trabalhador solicitar',
        'Quando danificado, extraviado ou em fim de vida útil',
        'A cada 6 meses, obrigatoriamente',
        'Somente após acidente de trabalho',
      ],
      correctIndex: 1,
      explanation:
          'O EPI deve ser substituído quando danificado, extraviado, com defeito ou quando atingir o fim da vida útil indicada pelo fabricante.',
    ),
    QuizQuestion(
      id: 'nr06_05',
      question: 'Quais são as obrigações do trabalhador em relação ao EPI?',
      options: [
        'Apenas vestir quando o supervisor estiver presente',
        'Usar, guardar, conservar e comunicar danos ao empregador',
        'Escolher o modelo que preferir no mercado',
        'Fazer a manutenção e reparo por conta própria',
      ],
      correctIndex: 1,
      explanation:
          'O trabalhador deve usar o EPI adequadamente, guardar e conservar, e comunicar qualquer dano ou alteração ao empregador.',
    ),
  ];

  // ══════════════════════════════════════════
  // Questões genéricas de segurança do trabalho
  // ══════════════════════════════════════════
  static const _genericQuestions = [
    QuizQuestion(
      id: 'gen_01',
      question: 'O que é PPRA?',
      options: [
        'Programa de Proteção contra Riscos Ambientais',
        'Plano de Prevenção de Riscos de Acidente',
        'Programa de Prevenção de Riscos Ambientais',
        'Protocolo de Proteção a Riscos Associados',
      ],
      correctIndex: 2,
      explanation:
          'PPRA = Programa de Prevenção de Riscos Ambientais, substituído pelo PGR (Programa de Gerenciamento de Riscos) a partir de 2022.',
    ),
    QuizQuestion(
      id: 'gen_02',
      question: 'O que são Normas Regulamentadoras (NRs)?',
      options: [
        'Recomendações opcionais do governo',
        'Disposições obrigatórias relativas à segurança e saúde no trabalho',
        'Regras internas de cada empresa',
        'Normas aplicáveis apenas à construção civil',
      ],
      correctIndex: 1,
      explanation:
          'As NRs são disposições complementares ao Capítulo V da CLT, de observância obrigatória por todas as empresas com empregados regidos pela CLT.',
    ),
    QuizQuestion(
      id: 'gen_03',
      question: 'Quem é responsável por fiscalizar o cumprimento das NRs?',
      options: [
        'A polícia federal',
        'O sindicato dos trabalhadores',
        'A Inspeção do Trabalho (MTE)',
        'O Corpo de Bombeiros',
      ],
      correctIndex: 2,
      explanation:
          'A Inspeção do Trabalho, vinculada ao Ministério do Trabalho e Emprego, é responsável por fiscalizar o cumprimento das normas de segurança e saúde.',
    ),
    QuizQuestion(
      id: 'gen_04',
      question: 'O que é CIPA?',
      options: [
        'Comissão Interna de Prevenção de Acidentes',
        'Centro de Investigação e Prevenção de Acidentes',
        'Comissão de Inspeção e Proteção Ambiental',
        'Conselho Interno de Proteção e Assistência',
      ],
      correctIndex: 0,
      explanation:
          'CIPA = Comissão Interna de Prevenção de Acidentes e de Assédio, regulamentada pela NR-05.',
    ),
    QuizQuestion(
      id: 'gen_05',
      question: 'O treinamento de integração de segurança é obrigatório para:',
      options: [
        'Apenas gerentes e supervisores',
        'Todos os trabalhadores admitidos, incluindo terceirizados',
        'Apenas trabalhadores do setor de produção',
        'Apenas menores de idade',
      ],
      correctIndex: 1,
      explanation:
          'Todo trabalhador admitido, transferido ou que mude de função deve receber treinamento de integração sobre os riscos do ambiente de trabalho.',
    ),
  ];
}
