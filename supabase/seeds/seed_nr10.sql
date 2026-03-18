-- ═══════════════════════════════════════
-- SEED: NR-10 — Apostilas e Quizzes
-- ═══════════════════════════════════════

-- APOSTILAS
INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m1_l1', 'nr10', 'apostila', 'Introdução aos Riscos Elétricos',
'## Introdução aos Riscos Elétricos

A **NR-10** estabelece os requisitos e condições mínimas para garantir a segurança e a saúde dos trabalhadores que interagem com instalações elétricas e serviços com eletricidade.

### O que são Riscos Elétricos?

Riscos elétricos são aqueles originados pela **energia elétrica** e que podem causar:

- **Choque elétrico** — passagem de corrente pelo corpo
- **Arco elétrico** — descarga entre condutores
- **Queimaduras** — por contato ou radiação térmica
- **Incêndio e explosão** — por curto-circuito ou centelhas

### Estatísticas de Acidentes

Segundo o MTE, os acidentes com eletricidade representam cerca de **3% do total de acidentes de trabalho**, porém respondem por aproximadamente **15% dos acidentes fatais** no Brasil.

### Base Legal

- **CLT, Art. 200** — Normas sobre segurança em instalações elétricas
- **NR-10** (Portaria MTE 598/2004, atualizada pela Portaria 915/2019)
- **NBR 5410** — Instalações Elétricas de Baixa Tensão
- **NBR 14039** — Instalações Elétricas de Média Tensão', 1);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m1_l2', 'nr10', 'apostila', 'Efeitos da Corrente Elétrica no Corpo Humano',
'## Efeitos da Corrente Elétrica no Corpo Humano

A gravidade de um choque elétrico depende de diversos fatores: **intensidade da corrente**, **tempo de exposição**, **caminho percorrido** e **condições fisiológicas** da vítima.

### Tabela de Efeitos por Intensidade (CA 60Hz)

| Corrente (mA) | Efeito |
|---|---|
| 1 – 5 | Formigamento, sensação leve |
| 5 – 15 | Contrações musculares involuntárias |
| 15 – 50 | Impossibilidade de soltar o condutor |
| 50 – 100 | Fibrilação ventricular (potencialmente fatal) |
| > 100 | Parada cardíaca, queimaduras graves |

### Fatores Agravantes

1. **Umidade** — reduz a resistência da pele de ~100kΩ para ~1kΩ
2. **Área de contato** — maior área = menor resistência
3. **Caminho da corrente** — mão-mão ou mão-pé são os mais perigosos
4. **Frequência** — 60Hz é a mais perigosa para o coração

### Lei de Ohm Aplicada

> I = V / R

Onde I é a corrente (A), V a tensão (V) e R a resistência do corpo (Ω). Com pele seca (~100kΩ) e 220V: I ≈ 2,2mA. Com pele molhada (~1kΩ) e 220V: I ≈ 220mA — **potencialmente fatal**.', 2);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m1_l3', 'nr10', 'apostila', 'Tensão de Toque e Tensão de Passo',
'## Tensão de Toque e Tensão de Passo

### Tensão de Toque

É a diferença de potencial entre uma **estrutura metálica aterrada** e um ponto da superfície do solo, separados por uma distância horizontal equivalente ao alcance normal do braço (~1m).

**Exemplo prático:** Um trabalhador toca uma carcaça metálica energizada acidentalmente. A corrente percorre do ponto de contato (mão) até os pés, passando por órgãos vitais.

### Tensão de Passo

É a diferença de potencial entre dois pontos do solo, separados por uma distância de **1 passo** (~1m), na direção do maior gradiente de potencial.

**Exemplo prático:** Um cabo de alta tensão cai ao solo. A corrente se espalha radialmente. Uma pessoa caminhando na proximidade recebe um choque entre os dois pés.

### Medidas Preventivas

- **Aterramento adequado** de todas as massas metálicas
- **Equipotencialização** — conectar todas as partes metálicas ao mesmo potencial
- **Pisos isolantes** em áreas de risco
- **Sinalização** de áreas de tensão de passo
- **EPCs** — barreiras e isolamentos', 3);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m1_l4', 'nr10', 'apostila', 'Zonas de Risco e Zonas Controladas',
'## Zonas de Risco e Zonas Controladas

A NR-10 define **zonas de trabalho** ao redor de instalações elétricas energizadas para delimitar áreas de perigo.

### Zona de Risco (ZR)

Região ao redor de partes energizadas onde existe **risco de choque elétrico**. Os limites dependem da tensão:

| Faixa de Tensão (kV) | Distância ZR (m) |
|---|---|
| ≤ 1 | 0,20 |
| 1 – 36 | 0,70 |
| 36 – 145 | 1,00 |
| 145 – 242 | 1,80 |
| 242 – 550 | 3,50 |

### Zona Controlada (ZC)

Região ao redor da zona de risco, onde a permanência é **restrita a profissionais autorizados** e com medidas de proteção.

### Zona Livre

Região além da zona controlada, sem restrição especial de acesso.

### Regras de Acesso

- **Zona Livre** — qualquer pessoa
- **Zona Controlada** — somente trabalhadores autorizados com treinamento NR-10
- **Zona de Risco** — somente com **desenergização** ou uso de EPIs/EPCs adequados', 4);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m1_l5', 'nr10', 'apostila', 'Classificação das Instalações Elétricas',
'## Classificação das Instalações Elétricas

### Por Tensão

A NR-10 classifica as instalações em:

- **Extra-baixa tensão (EBT):** ≤ 50V CA ou ≤ 120V CC
- **Baixa tensão (BT):** > 50V até 1000V CA, ou > 120V até 1500V CC
- **Alta tensão (AT):** > 1000V CA ou > 1500V CC

### Por Ambiente

- **Áreas secas** — resistência da pele elevada, menor risco
- **Áreas úmidas** — resistência reduzida, EBT limitada a 25V CA
- **Áreas submersas** — exigem proteção especial (SELV)

### Tipos de Instalações

1. **Instalações de geração** — usinas, PCHs, painéis solares
2. **Instalações de transmissão** — linhas de AT e subestações
3. **Instalações de distribuição** — redes urbanas e rurais
4. **Instalações de consumo** — prediais, industriais

### Documentação Obrigatória

Toda instalação elétrica deve possuir:
- Diagrama unifilar atualizado
- Especificação dos componentes
- Prontuário das Instalações Elétricas (PIE)
- Procedimentos de trabalho', 5);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m1_l6', 'nr10', 'apostila', 'Prontuário das Instalações Elétricas (PIE)',
'## Prontuário das Instalações Elétricas (PIE)

O **Prontuário das Instalações Elétricas** é um documento obrigatório para estabelecimentos com instalações acima de **75 kW**.

### Conteúdo Obrigatório do PIE

1. **Conjunto de procedimentos e instruções técnicas**
2. **Documentação das inspeções e medições** do SPDA
3. **Especificação dos EPIs e EPCs**
4. **Documentação comprobatória da qualificação** dos trabalhadores
5. **Resultados dos testes de isolação** elétrica dos EPIs
6. **Certificação dos equipamentos** e materiais
7. **Relatório de auditoria** de conformidade da NR-10

### Responsabilidades

- **Empregador** — elaborar, manter atualizado e disponibilizar
- **Profissional legalmente habilitado** — assinar tecnicamente
- **Trabalhador** — conhecer e seguir os procedimentos

### Atualização

O PIE deve ser revisado **sempre que houver alterações** nas instalações elétricas e, no mínimo, a cada **5 anos**.', 6);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m2_l1', 'nr10', 'apostila', 'Medidas de Proteção Coletiva',
'## Medidas de Proteção Coletiva (EPC)

As medidas de proteção coletiva têm **prioridade** sobre as individuais, conforme a NR-10.

### Hierarquia de Controle

1. **Desenergização** — sempre a primeira opção
2. **Barreiras e invólucros** — impedem contato acidental
3. **Obstáculos** — limitam acesso involuntário
4. **Distância de segurança** — afastamento adequado
5. **Dispositivos de proteção** — DR, fusíveis, disjuntores

### Dispositivos de Proteção

- **Disjuntor Diferencial Residual (DR):** Detecta fuga de corrente e desliga o circuito em milissegundos
- **Fusíveis:** Proteção contra sobrecorrente
- **Seccionadoras:** Isolamento visível do circuito
- **Relés de proteção:** Proteção de equipamentos de AT

### Aterramento

O aterramento é fundamental para:
- Escoar correntes de falta
- Limitar sobretensões
- Garantir funcionamento dos dispositivos de proteção', 1);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m2_l2', 'nr10', 'apostila', 'Equipamentos de Proteção Individual',
'## Equipamentos de Proteção Individual (EPI)

Os EPIs para trabalho com eletricidade devem ter **Certificado de Aprovação (CA)** emitido pelo MTE.

### EPIs Obrigatórios

| EPI | Proteção |
|---|---|
| Capacete classe B | Choque e impacto |
| Óculos de segurança | Arco elétrico |
| Luvas isolantes | Choque elétrico |
| Manga isolante | Proteção dos braços |
| Botina isolante | Tensão de passo |
| Vestimenta FR | Arco elétrico |

### Luvas Isolantes — Classes

| Classe | Tensão máxima (V) | Cor |
|---|---|---|
| 00 | 500 | Bege |
| 0 | 1.000 | Vermelha |
| 1 | 7.500 | Branca |
| 2 | 17.000 | Amarela |
| 3 | 26.500 | Verde |
| 4 | 36.000 | Laranja |

### Inspeção e Testes

- Inspeção visual **antes de cada uso**
- Teste de inflação (luvas) **diário**
- Teste dielétrico em laboratório **a cada 6 meses**
- Substituição imediata se apresentar dano', 2);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m2_l3', 'nr10', 'apostila', 'Desenergização — Procedimentos',
'## Desenergização — Procedimentos

A **desenergização** é a medida de controle de risco mais segura e deve ser a **primeira opção** sempre que tecnicamente possível.

### As 5 Etapas da Desenergização

1. **Seccionamento** — abertura do dispositivo de seccionamento
2. **Impedimento de reenergização** — travamento e etiquetagem (LOTO)
3. **Constatação da ausência de tensão** — uso de detector de tensão
4. **Instalação de aterramento temporário** — curto-circuitar e aterrar
5. **Proteção dos elementos energizados remanescentes** — barreiras e sinalização

### Sistema LOTO (Lockout-Tagout)

- **Lockout** — cadeado individual por trabalhador
- **Tagout** — etiqueta com nome, data, setor e assinatura
- Cada trabalhador **coloca e retira** seu próprio cadeado
- Nunca remover cadeado de outro trabalhador

### Reenergização

A reenergização segue a ordem **inversa** da desenergização:
1. Retirar aterramento temporário
2. Remover barreiras
3. Verificar se todos os trabalhadores se afastaram
4. Retirar cadeados/etiquetas
5. Energizar o circuito', 3);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m2_l4', 'nr10', 'apostila', 'Sinalização de Segurança',
'## Sinalização de Segurança

A sinalização elétrica é obrigatória conforme NR-10 e NBR 7195.

### Tipos de Sinalização

**Placas de advertência:**
- ⚡ "PERIGO — ALTA TENSÃO"
- ⚡ "PERIGO DE MORTE"
- ⚡ "NÃO OPERE ESTE EQUIPAMENTO"

**Placas de proibição:**
- 🚫 "PROIBIDA A ENTRADA — PESSOAL NÃO AUTORIZADO"
- 🚫 "NÃO MANOBRE SOB CARGA"

**Placas de instrução:**
- ℹ️ "USE EPI OBRIGATÓRIO"
- ℹ️ "SOMENTE PESSOAL AUTORIZADO"

### Cores de Segurança (NR-26)

| Cor | Significado |
|---|---|
| Vermelho | Proibição, equipamento de combate a incêndio |
| Amarelo | Atenção, cuidado |
| Verde | Segurança, primeiros socorros |
| Azul | Obrigação |
| Laranja | Partes perigosas de máquinas |

### Etiquetagem de Circuitos

Todo quadro elétrico deve possuir **identificação dos circuitos** com etiquetas legíveis e atualizadas.', 4);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m2_l5', 'nr10', 'apostila', 'Proteção Contra Incêndio em Instalações Elétricas',
'## Proteção Contra Incêndio em Instalações Elétricas

### Causas Elétricas de Incêndio

1. **Curto-circuito** — contato entre condutores
2. **Sobrecarga** — corrente acima da capacidade
3. **Mau contato** — aquecimento por resistência elevada
4. **Arco elétrico** — faísca entre terminais

### Classes de Incêndio

- **Classe C** — fogo em equipamentos elétricos energizados
- Após desenergização, passa a ser Classe A (sólidos) ou B (líquidos)

### Agentes Extintores Permitidos

| Agente | Classe C | Observação |
|---|---|---|
| CO₂ | ✅ Sim | Não deixa resíduos |
| Pó químico seco | ✅ Sim | Pode danificar equipamentos |
| FM-200/Novec | ✅ Sim | Para salas de equipamentos |
| Água | ❌ NÃO | Conduz eletricidade |
| Espuma | ❌ NÃO | Conduz eletricidade |

### Prevenção

- Dimensionamento correto dos condutores
- Manutenção preventiva das conexões
- Instalação de dispositivos de proteção (disjuntores, DR)
- Termografia periódica para detectar aquecimentos', 5);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m2_l6', 'nr10', 'apostila', 'Situações de Emergência',
'## Situações de Emergência com Eletricidade

### Procedimentos em Caso de Choque Elétrico

1. **Não tocar na vítima** se ela ainda estiver em contato com a fonte
2. **Desligar a fonte** de energia (disjuntor, chave seccionadora)
3. Se não for possível desligar, **afastar a vítima** usando material isolante
4. **Chamar socorro** — SAMU (192) ou Bombeiros (193)
5. **Avaliar sinais vitais** — consciência, respiração, pulso
6. **Iniciar RCP** se necessário

### Queimaduras Elétricas

- São mais graves do que parecem (atingem tecidos profundos)
- **Não aplicar** pomadas, gelo ou substâncias caseiras
- **Cobrir** com pano limpo e úmido
- **Encaminhar imediatamente** ao hospital

### Plano de Emergência

A empresa deve possuir um plano que inclua:
- Procedimentos de resposta a emergências elétricas
- Lista de contatos de emergência
- Localização dos equipamentos de primeiros socorros
- Treinamento periódico de simulação', 6);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m3_l1', 'nr10', 'apostila', 'Introdução ao SEP',
'## Introdução ao SEP — Sistema Elétrico de Potência

### O que é o SEP?

O Sistema Elétrico de Potência (SEP) compreende as instalações e equipamentos destinados à **geração, transmissão e distribuição** de energia elétrica até a medição, inclusive.

### Componentes do SEP

1. **Geração** — usinas hidrelétricas, termelétricas, eólicas, solares
2. **Transmissão** — linhas de AT (69kV a 765kV) e subestações
3. **Distribuição** — redes de MT (13,8kV) e BT (220/380V)

### Treinamento Complementar — SEP

Trabalhadores que intervenham no SEP necessitam de **treinamento complementar** de no mínimo **80 horas**, além do curso básico de 40h da NR-10.

### Requisitos para Trabalho no SEP

- Treinamento básico NR-10 (40h) + complementar SEP (80h)
- Autorização formal do empregador
- Aptidão física e mental (ASO)
- Uso de EPIs e EPCs adequados à tensão', 1);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m3_l2', 'nr10', 'apostila', 'Subestações e Equipamentos de AT',
'## Subestações e Equipamentos de Alta Tensão

### Tipos de Subestações

- **Subestação elevadora** — na geração (13,8kV → 230kV)
- **Subestação abaixadora** — na distribuição (138kV → 13,8kV)
- **Subestação de manobra** — seccionamento e proteção

### Equipamentos Principais

| Equipamento | Função |
|---|---|
| Transformador de potência | Elevar ou reduzir tensão |
| Disjuntor AT | Interromper correntes de curto |
| Seccionadora | Isolamento visível |
| TC (transformador de corrente) | Medição e proteção |
| TP (transformador de potencial) | Medição de tensão |
| Para-raios | Proteção contra sobretensões |

### Distâncias Mínimas em Subestações

As distâncias de segurança em subestações são maiores que em BT e devem seguir a tabela da NR-10, Anexo II.', 2);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m3_l3', 'nr10', 'apostila', 'Linhas de Transmissão',
'## Trabalho em Linhas de Transmissão

### Características das Linhas de Transmissão

- **Tensões:** 69kV, 138kV, 230kV, 345kV, 500kV, 765kV
- **Estruturas:** torres metálicas, postes de concreto
- **Condutores:** cabos de alumínio com alma de aço (CAA)
- **Faixa de servidão:** área sob a linha com restrições

### Técnicas de Trabalho

1. **Linha morta (desenergizada):** Mais segura, requer manobras de desligamento
2. **Linha viva ao potencial:** Trabalhador no mesmo potencial do condutor
3. **Linha viva à distância:** Uso de ferramentas isolantes desde solo/estrutura

### Procedimentos de Segurança

- **Análise de Risco** antes de qualquer intervenção
- **Permissão de Trabalho (PT)** emitida pelo COI
- **Comunicação constante** com o centro de operação
- **Aterramento temporário** obrigatório em linha desenergizada', 3);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m3_l4', 'nr10', 'apostila', 'Trabalho em Proximidade ao SEP',
'## Trabalho em Proximidade ao SEP

### O que é Trabalho em Proximidade?

É toda atividade realizada nas **Zonas Controladas** de instalações do SEP, sem contato direto com partes energizadas.

### Exemplos de Trabalho em Proximidade

- Poda de árvores próximas a linhas de distribuição
- Construção civil próxima a redes elétricas
- Manutenção de iluminação pública
- Pintura de estruturas energizadas

### Medidas de Segurança

1. **Manter distâncias de segurança** conforme tabela NR-10
2. **Utilizar EPIs adequados** à tensão do circuito próximo
3. **Sinalização** visível da área de trabalho
4. **Vigilante de segurança** para monitorar aproximação
5. **Procedimento escrito** para cada tipo de atividade', 4);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m3_l5', 'nr10', 'apostila', 'Proteção e Combate a Incêndio no SEP',
'## Proteção e Combate a Incêndio no SEP

### Riscos Específicos

Instalações do SEP apresentam riscos elevados de incêndio devido a:
- Grandes quantidades de **óleo isolante** (transformadores)
- **Arcos elétricos** de alta energia
- **Equipamentos de grande porte** de difícil acesso

### Sistemas de Proteção

1. **Detecção automática** — sensores de temperatura e fumaça
2. **Sistema de dilúvio** — sprinklers para transformadores
3. **Muretas de contenção** — para vazamento de óleo
4. **Extintores de CO₂** — para painéis e quadros

### Procedimentos em Caso de Incêndio no SEP

- **Desligar a alimentação** antes de combater o fogo
- **Nunca usar água** em equipamentos energizados
- **Acionar brigada de incêndio** e corpo de bombeiros
- **Evacuar a área** seguindo rota de fuga sinalizada', 5);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m3_l6', 'nr10', 'apostila', 'Responsabilidades e Autorização',
'## Responsabilidades e Autorização para Trabalho no SEP

### Profissional Qualificado

Possui **formação reconhecida** pelo sistema oficial de ensino:
- Engenheiro eletricista
- Técnico em eletrotécnica

### Profissional Habilitado

Qualificado com **registro no CREA** e com atribuição para a atividade.

### Profissional Capacitado

Trabalhador que recebeu **capacitação sob supervisão** de profissional habilitado e autorizado.

### Profissional Autorizado

Profissional qualificado, habilitado ou capacitado, com **anuência formal** da empresa.

### Requisitos para Autorização

1. Treinamento NR-10 básico (40h) + complementar SEP (80h)
2. ASO com aptidão para trabalho com eletricidade
3. Registro no sistema de autorização da empresa
4. Reciclagem **bienal** (a cada 2 anos) ou em caso de:
   - Troca de função ou empresa
   - Retorno de afastamento > 3 meses
   - Acidente grave', 6);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m4_l1', 'nr10', 'apostila', 'Primeiros Socorros — Conceitos',
'## Primeiros Socorros em Acidentes Elétricos — Conceitos

### Definição

Primeiros socorros são o **atendimento imediato e provisório** dado à vítima de acidente, até a chegada de socorro especializado.

### Princípios Fundamentais

1. **Manter a calma**
2. **Garantir segurança** (sua e da vítima)
3. **Chamar socorro** (SAMU 192, Bombeiros 193)
4. **Avaliar a vítima** (consciência, respiração, pulso)
5. **Prestar atendimento** dentro de sua capacitação

### Avaliação Primária (ABCDE)

- **A** — Vias Aéreas (Airway) — desobstruir
- **B** — Respiração (Breathing) — verificar movimentos torácicos
- **C** — Circulação (Circulation) — verificar pulso
- **D** — Neurológico (Disability) — nível de consciência
- **E** — Exposição (Exposure) — examinar o corpo', 1);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m4_l2', 'nr10', 'apostila', 'Ressuscitação Cardiopulmonar (RCP)',
'## Ressuscitação Cardiopulmonar (RCP)

### Quando Realizar?

Quando a vítima estiver **inconsciente, sem respirar** e **sem pulso** palpável.

### Procedimento (Leigo)

1. **Verificar consciência** — chamar e tocar nos ombros
2. **Chamar ajuda** — SAMU 192
3. **Posicionar as mãos** — centro do tórax, entre os mamilos
4. **Comprimir** — 30 compressões a 5cm de profundidade
5. **Frequência** — 100 a 120 compressões por minuto
6. **Não parar** até chegada do socorro

### DEA (Desfibrilador Externo Automático)

- Equipamento que aplica **choque controlado** para reverter fibrilação
- **Qualquer pessoa** pode utilizar — o aparelho dá instruções por voz
- Obrigatório em locais com grande circulação de pessoas

### Cuidados Específicos em Choques Elétricos

- Vítima pode ter **lesões internas** não visíveis
- **Monitorar** por pelo menos 24 horas (risco de arritmia tardia)
- **Queimaduras de entrada e saída** — marcar para o médico', 2);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m4_l3', 'nr10', 'apostila', 'Queimaduras — Classificação e Tratamento',
'## Queimaduras — Classificação e Tratamento

### Classificação por Grau

| Grau | Camada atingida | Sintomas |
|---|---|---|
| 1º grau | Epiderme | Vermelhidão, dor |
| 2º grau | Derme | Bolhas, dor intensa |
| 3º grau | Tecido subcutâneo | Escurecimento, sem dor |
| 4º grau | Músculos/ossos | Carbonização |

### Queimaduras Elétricas — Particularidades

- Corrente segue o **caminho de menor resistência** (nervos, vasos)
- Lesão profunda pode ser **maior internamente** que externamente
- Apresentam **ponto de entrada e ponto de saída**
- Risco de **rabdomiólise** (destruição muscular)

### Primeiro Atendimento

✅ **Fazer:**
- Resfriar com água corrente (1º e 2º grau leves)
- Cobrir com pano limpo e úmido
- Remover roupas não aderidas
- Encaminhar ao hospital

❌ **NÃO fazer:**
- Aplicar pasta de dente, manteiga ou pomadas
- Estourar bolhas
- Arrancar roupas grudadas
- Aplicar gelo diretamente', 3);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m4_l4', 'nr10', 'apostila', 'Fraturas, Quedas e Trauma',
'## Fraturas, Quedas e Trauma

### Quedas Associadas a Choques Elétricos

É comum o trabalhador sofrer **choque + queda**, especialmente em trabalho em altura. O trauma pode ser mais grave que o próprio choque.

### Imobilização

- **Não mover** a vítima se houver suspeita de lesão na coluna
- Imobilizar fraturas na posição encontrada
- Utilizar talas improvisadas se necessário
- **Alinhar cabeça-pescoço-tronco** se suspeita de coluna

### Hemorragias

| Tipo | Característica | Ação |
|---|---|---|
| Arterial | Sangue vermelho vivo, em jatos | Compressão direta firme |
| Venosa | Sangue escuro, contínuo | Compressão e elevação |
| Capilar | Sangramento leve, difuso | Limpeza e curativo |', 4);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m4_l5', 'nr10', 'apostila', 'Transporte de Acidentados',
'## Transporte de Acidentados

### Regra de Ouro

> **Só transporte a vítima se o local oferecer risco maior** que o transporte em si.

### Métodos de Transporte

1. **Maca** — método ideal, mantém alinhamento
2. **Prancha rígida** — obrigatória se suspeita de coluna
3. **Cadeira** — para vítima consciente sem trauma de coluna
4. **Pegada de bombeiro** — emergência, um socorrista

### Transporte com Suspeita de Lesão na Coluna

- Mínimo **3 pessoas** para movimentação
- Usar **colar cervical** antes de qualquer movimento
- **Rolar em bloco** (log roll) para posicionar na prancha
- Fixar com cintas: tórax, quadril, pernas e cabeça', 5);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m4_l6', 'nr10', 'apostila', 'Kit de Primeiros Socorros e Plano de Emergência',
'## Kit de Primeiros Socorros e Plano de Emergência

### Kit Obrigatório (NR-07)

Todo estabelecimento deve possuir kit contendo:
- Gaze esterilizada e ataduras
- Esparadrapo e micropore
- Luvas de procedimento
- Tesoura de ponta redonda
- Talas para imobilização
- Solução fisiológica
- Manta térmica

### Plano de Emergência — Requisitos NR-10

O plano específico para instalações elétricas deve incluir:

1. **Procedimentos de resgate** em cada tipo de instalação
2. **Rotas de fuga** sinalizadas
3. **Pontos de encontro** definidos
4. **Lista de contatos** — SAMU, Bombeiros, hospital
5. **Localização dos kits** de primeiros socorros e DEA
6. **Simulados periódicos** — no mínimo anuais

### Responsabilidades

- **SESMT** — elaborar e manter o plano
- **CIPA** — fiscalizar e sugerir melhorias
- **Trabalhadores** — conhecer o plano e participar dos simulados', 6);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m5_l1', 'nr10', 'apostila', 'Ordem de Serviço e Permissão de Trabalho',
'## Ordem de Serviço e Permissão de Trabalho

### Ordem de Serviço (OS)

Documento que **formaliza a autorização** para execução de um serviço em instalação elétrica.

### Permissão de Trabalho (PT)

Documento mais detalhado, obrigatório para atividades de **alto risco**:
- Trabalho em alta tensão
- Trabalho em espaço confinado com risco elétrico
- Trabalho em altura com proximidade de rede

### Conteúdo da PT

1. Identificação do serviço e local
2. Riscos identificados e medidas de controle
3. EPIs e EPCs necessários
4. Equipe autorizada (nomes e funções)
5. Data, horário de início e término previsto
6. Assinaturas do responsável e executantes

### Análise Preliminar de Risco (APR)

Deve ser realizada **antes de cada serviço** e contemplar:
- Identificação dos perigos
- Avaliação dos riscos
- Medidas preventivas
- Procedimento de emergência', 1);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m5_l2', 'nr10', 'apostila', 'Manutenção Preventiva e Corretiva',
'## Manutenção Preventiva e Corretiva

### Manutenção Preventiva

Realizada **periodicamente** para evitar falhas:
- Inspeção visual de componentes
- Reaperto de conexões
- Limpeza de quadros e painéis
- Teste de dispositivos de proteção (disjuntores, DR)
- **Termografia** — detecção de pontos quentes

### Manutenção Corretiva

Realizada após a **ocorrência de falha**:
- Substituição de componentes danificados
- Reparo de isolamentos
- Correção de aterramento

### Manutenção Preditiva

Uso de **técnicas de monitoramento** para prever falhas:
- Análise termográfica
- Análise de vibração (motores)
- Análise de óleo isolante (transformadores)
- Medição de resistência de isolamento

### Registro

Toda manutenção deve ser **documentada** no PIE com:
- Data, tipo de serviço e equipamento
- Responsável técnico
- Resultados de medições
- Próxima intervenção programada', 2);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m5_l3', 'nr10', 'apostila', 'Trabalho em Equipe e Comunicação',
'## Trabalho em Equipe e Comunicação

### Estrutura de uma Equipe de Trabalho

- **Responsável técnico** — profissional habilitado que coordena
- **Líder de equipe** — coordena a execução em campo
- **Executantes** — realizam o serviço
- **Vigilante (sentinela)** — monitora a segurança

### Comunicação Segura

1. **Rádio comunicador** — canal exclusivo para a equipe
2. **Comandos padronizados** — "pode manobrar", "manobra executada"
3. **Confirmação verbal** — repetir ordens recebidas
4. **Registro escrito** — anotar todas as manobras

### Reunião de Segurança (DDS)

O **Diálogo Diário de Segurança** deve abordar:
- Riscos específicos do serviço do dia
- EPIs necessários
- Procedimentos de emergência
- Condições climáticas (chuva = suspender trabalho ao ar livre)', 3);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m5_l4', 'nr10', 'apostila', 'Documentação e Registros',
'## Documentação e Registros

### Documentos Obrigatórios NR-10

1. **Prontuário de Instalações Elétricas (PIE)**
2. **Projetos elétricos** atualizados (diagramas unifilares)
3. **Ordens de Serviço** e Permissões de Trabalho
4. **Relatórios de inspeção** periódica
5. **Registros de treinamento** (certificados, listas de presença)
6. **ASOs** — Atestados de Saúde Ocupacional
7. **Laudos de ensaio** de EPIs

### Prazos de Guarda

| Documento | Prazo |
|---|---|
| PIE | Permanente (atualizar) |
| Certificados de treinamento | Validade do certificado + 5 anos |
| OS/PT | 5 anos |
| ASOs | 20 anos |
| Relatórios de inspeção | 5 anos |

### Auditorias de Conformidade

A empresa deve realizar auditorias periódicas para verificar conformidade com a NR-10, incluindo:
- Adequação das instalações
- Atualização da documentação
- Eficácia dos treinamentos
- Condição dos EPIs', 4);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m5_l5', 'nr10', 'apostila', 'Normas Técnicas Complementares',
'## Normas Técnicas Complementares

### NBRs Essenciais para NR-10

| NBR | Assunto |
|---|---|
| NBR 5410 | Instalações elétricas de baixa tensão |
| NBR 14039 | Instalações elétricas de média tensão |
| NBR 5419 | Proteção contra descargas atmosféricas (SPDA) |
| NBR 7195 | Cores para segurança |
| NBR IEC 61482 | Vestimentas de proteção contra arco elétrico |
| NBR IEC 60079 | Atmosferas explosivas |

### Relação NR-10 com Outras NRs

- **NR-01** — GRO (Gerenciamento de Riscos Ocupacionais)
- **NR-06** — EPIs
- **NR-26** — Sinalização de segurança
- **NR-33** — Espaços confinados (subestações subterrâneas)
- **NR-35** — Trabalho em altura (postes, torres)', 5);

INSERT INTO lesson_content (lesson_id, course_id, content_type, title, body, sort_order)
VALUES ('nr10_m5_l6', 'nr10', 'apostila', 'Revisão Geral e Boas Práticas',
'## Revisão Geral e Boas Práticas

### Os 10 Mandamentos da Segurança Elétrica

1. **Desenergize** sempre que possível
2. **Comprove** a ausência de tensão antes de trabalhar
3. **Use EPIs** adequados e inspecionados
4. **Sinalize** a área de trabalho
5. **Nunca trabalhe sozinho** em instalações de AT
6. **Siga procedimentos** — nunca improvise
7. **Mantenha treinamento** atualizado (reciclagem bienal)
8. **Conheça o plano de emergência** do local
9. **Reporte** condições inseguras imediatamente
10. **Em dúvida, pare** — consulte o responsável técnico

### Resumo dos Requisitos NR-10

- Treinamento básico: **40 horas** (reciclagem bienal)
- Complementar SEP: **80 horas** adicionais
- ASO com aptidão para trabalho com eletricidade
- Autorização formal do empregador
- PIE atualizado e disponível
- EPIs com CA válido e testados periodicamente', 6);

-- QUIZZES
-- Quiz: Quiz — Riscos Elétricos
DO $$
DECLARE quiz_uuid UUID;
BEGIN
  INSERT INTO quizzes (course_id, module_id, title, passing_score)
  VALUES ('nr10', 'nr10_m1', 'Quiz — Riscos Elétricos', 70)
  RETURNING id INTO quiz_uuid;

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Qual é o principal efeito de uma corrente elétrica de 50 a 100 mA (CA 60Hz) no corpo humano?', 'Apenas formigamento', 'Contrações musculares leves', 'Fibrilação ventricular, potencialmente fatal', 'Queimaduras superficiais', 'Nenhum efeito perceptível', 'c', 'Correntes entre 50 e 100 mA em CA 60Hz podem provocar fibrilação ventricular, que é potencialmente fatal.', 1);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'O que é tensão de passo?', 'A tensão entre as mãos do trabalhador', 'A diferença de potencial entre dois pontos do solo separados por 1 passo', 'A tensão nominal do circuito', 'A tensão de alimentação do EPI', 'A queda de tensão no condutor', 'b', 'Tensão de passo é a diferença de potencial entre dois pontos do solo, separados pela distância de 1 passo (~1m).', 2);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Qual é a distância da Zona de Risco para tensões até 1 kV?', '0,10 m', '0,20 m', '0,50 m', '1,00 m', '1,50 m', 'b', 'Para tensões até 1 kV, a zona de risco tem distância de 0,20 m conforme NR-10.', 3);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'O Prontuário das Instalações Elétricas (PIE) é obrigatório para instalações acima de:', '25 kW', '50 kW', '75 kW', '100 kW', '150 kW', 'c', 'O PIE é obrigatório para estabelecimentos com carga instalada acima de 75 kW.', 4);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Qual fator mais reduz a resistência elétrica da pele humana?', 'Temperatura ambiente', 'Umidade/suor', 'Tipo sanguíneo', 'Idade da pessoa', 'Altura da pessoa', 'b', 'A umidade e o suor reduzem drasticamente a resistência da pele, de ~100kΩ para ~1kΩ.', 5);

END $$;

-- Quiz: Quiz — Medidas de Proteção
DO $$
DECLARE quiz_uuid UUID;
BEGIN
  INSERT INTO quizzes (course_id, module_id, title, passing_score)
  VALUES ('nr10', 'nr10_m2', 'Quiz — Medidas de Proteção', 70)
  RETURNING id INTO quiz_uuid;

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Qual a primeira medida de proteção a ser adotada conforme a NR-10?', 'Uso de EPIs', 'Desenergização', 'Sinalização', 'Barreiras físicas', 'Treinamento adicional', 'b', 'A desenergização é sempre a primeira opção de medida de controle de risco elétrico.', 1);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Quantas etapas possui o procedimento correto de desenergização?', '3', '4', '5', '6', '7', 'c', 'São 5 etapas: seccionamento, impedimento de reenergização, constatação de ausência de tensão, aterramento temporário e proteção dos elementos energizados.', 2);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Luvas isolantes de Classe 0 protegem contra tensão máxima de:', '500 V', '1.000 V', '7.500 V', '17.000 V', '26.500 V', 'b', 'Luvas de Classe 0 suportam tensão máxima de uso de 1.000 V.', 3);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Qual agente extintor NUNCA deve ser usado em incêndio elétrico com equipamento energizado?', 'CO₂', 'Pó químico seco', 'FM-200', 'Água', 'Novec 1230', 'd', 'Água conduz eletricidade e nunca deve ser usada em equipamentos elétricos energizados (Classe C).', 4);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'O sistema LOTO (Lockout-Tagout) serve para:', 'Medir tensão', 'Impedir reenergização acidental', 'Testar EPIs', 'Registrar acidentes', 'Classificar riscos', 'b', 'LOTO é o sistema de travamento e etiquetagem que impede a reenergização acidental durante manutenção.', 5);

END $$;

-- Quiz: Quiz — SEP
DO $$
DECLARE quiz_uuid UUID;
BEGIN
  INSERT INTO quizzes (course_id, module_id, title, passing_score)
  VALUES ('nr10', 'nr10_m3', 'Quiz — SEP', 70)
  RETURNING id INTO quiz_uuid;

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Qual é a carga horária mínima do treinamento complementar para trabalho no SEP?', '20 horas', '40 horas', '60 horas', '80 horas', '120 horas', 'd', 'O treinamento complementar para trabalho no SEP exige no mínimo 80 horas.', 1);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'O que é um profissional autorizado conforme a NR-10?', 'Qualquer engenheiro com CREA', 'Trabalhador com treinamento e anuência formal da empresa', 'Membro da CIPA', 'Técnico de segurança', 'Bombeiro civil', 'b', 'Profissional autorizado é aquele qualificado/habilitado/capacitado com anuência formal do empregador.', 2);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Qual documento é obrigatório para trabalho em linhas de transmissão?', 'Carteira de motorista', 'Permissão de Trabalho (PT)', 'Diploma universitário', 'Contrato de seguro', 'Receita médica', 'b', 'A Permissão de Trabalho (PT) é obrigatória e deve ser emitida pelo Centro de Operação.', 3);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'A reciclagem do treinamento NR-10 deve ocorrer no máximo a cada:', '6 meses', '1 ano', '2 anos', '3 anos', '5 anos', 'c', 'A reciclagem deve ser bienal (a cada 2 anos) ou quando houver troca de função, retorno de afastamento > 3 meses ou acidente grave.', 4);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Uma subestação abaixadora tem função de:', 'Gerar energia', 'Elevar tensão para transmissão', 'Reduzir tensão para distribuição', 'Armazenar energia', 'Medir consumo', 'c', 'Subestações abaixadoras reduzem a tensão da transmissão para níveis de distribuição.', 5);

END $$;

-- Quiz: Quiz — Primeiros Socorros
DO $$
DECLARE quiz_uuid UUID;
BEGIN
  INSERT INTO quizzes (course_id, module_id, title, passing_score)
  VALUES ('nr10', 'nr10_m4', 'Quiz — Primeiros Socorros', 70)
  RETURNING id INTO quiz_uuid;

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Em caso de choque elétrico, qual é a PRIMEIRA ação a ser tomada?', 'Aplicar RCP', 'Chamar o SAMU', 'Desligar a fonte de energia', 'Tocar na vítima para verificar consciência', 'Aplicar água no local', 'c', 'A primeira ação é desligar a fonte de energia para garantir segurança do socorrista e da vítima.', 1);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Qual a frequência correta de compressões torácicas na RCP?', '60 a 80 por minuto', '80 a 100 por minuto', '100 a 120 por minuto', '120 a 150 por minuto', '150 a 180 por minuto', 'c', 'A frequência recomendada é de 100 a 120 compressões por minuto, com 5 cm de profundidade.', 2);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Queimaduras elétricas se diferenciam das térmicas porque:', 'São sempre superficiais', 'Causam lesão interna maior que a externa visível', 'Não causam dor', 'Cicatrizam mais rápido', 'Só afetam a pele', 'b', 'Queimaduras elétricas são mais profundas internamente, pois a corrente segue nervos e vasos sanguíneos.', 3);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Em caso de suspeita de lesão na coluna, como transportar a vítima?', 'Nos braços (colo)', 'Sentada em cadeira', 'Em prancha rígida com colar cervical', 'Arrastando pelo chão', 'De qualquer forma, desde que rapidamente', 'c', 'Vítima com suspeita de lesão na coluna deve ser transportada em prancha rígida com colar cervical, com rolamento em bloco.', 4);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'O DEA (Desfibrilador Externo Automático) pode ser utilizado por:', 'Somente médicos', 'Somente enfermeiros', 'Somente socorristas treinados', 'Qualquer pessoa — o aparelho dá instruções por voz', 'Somente bombeiros', 'd', 'O DEA foi projetado para uso por qualquer pessoa, pois fornece instruções em áudio passo a passo.', 5);

END $$;

-- Quiz: Quiz — Procedimentos de Trabalho
DO $$
DECLARE quiz_uuid UUID;
BEGIN
  INSERT INTO quizzes (course_id, module_id, title, passing_score)
  VALUES ('nr10', 'nr10_m5', 'Quiz — Procedimentos de Trabalho', 70)
  RETURNING id INTO quiz_uuid;

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'A Permissão de Trabalho (PT) é obrigatória para:', 'Qualquer serviço de manutenção', 'Atividades de alto risco em instalações elétricas', 'Apenas trabalho noturno', 'Serviços administrativos', 'Troca de lâmpadas', 'b', 'A PT é obrigatória para atividades de alto risco, como trabalho em AT, espaço confinado ou altura com proximidade de rede.', 1);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'A termografia é uma técnica de manutenção:', 'Corretiva', 'Emergencial', 'Preditiva', 'Destrutiva', 'Temporária', 'c', 'A termografia é uma técnica de manutenção preditiva que identifica pontos quentes antes que ocorram falhas.', 2);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Qual NBR trata de instalações elétricas de baixa tensão?', 'NBR 5419', 'NBR 5410', 'NBR 14039', 'NBR 7195', 'NBR 60079', 'b', 'A NBR 5410 é a norma brasileira que estabelece condições para instalações elétricas de baixa tensão.', 3);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'O DDS (Diálogo Diário de Segurança) deve ser realizado:', 'Semanalmente', 'Mensalmente', 'Antes do início de cada jornada/serviço', 'Apenas após acidentes', 'Anualmente', 'c', 'O DDS deve ser realizado antes do início de cada jornada ou serviço, abordando riscos específicos do dia.', 4);

  INSERT INTO quiz_questions (quiz_id, question, option_a, option_b, option_c, option_d, option_e, correct_option, explanation, sort_order)
  VALUES (quiz_uuid, 'Por quanto tempo os ASOs devem ser guardados?', '1 ano', '5 anos', '10 anos', '20 anos', 'Permanentemente', 'd', 'Os ASOs devem ser arquivados por no mínimo 20 anos, conforme legislação trabalhista.', 5);

END $$;
