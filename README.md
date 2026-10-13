#Projeto: Sistema de Gestão e Segurança Kids (Espaço Kids Eventos)
1. Visão Geral do Projeto
O Espaço Kids Eventos é um sistema projetado para otimizar a recepção, o controle de acesso e a segurança de crianças em áreas recreativas de eventos.

🎯 Problema Resolvido
Em eventos de grande porte, as filas de entrada nos espaços infantis costumam ser longas devido à complexidade da checagem de documentos e termos de responsabilidade. O processo manual/desintegrado causa gargalos, aumenta a insatisfação e compromete o tempo de resposta em situações de emergência.

💡 Solução Proposta
Uma plataforma centralizada que:

Unifica Responsáveis e Dependente(s): Responsáveis com mais de uma criança realizam o cadastro de seus dados uma única vez (Relacionamento 1:N).

Digitalização de Termos: Assinatura do termo de compromisso digital/física vinculada ao cadastro do responsável, dispensando preenchimentos repetitivos.

Acesso Rápido a Informações Médicas: Pronto atendimento a alergias e restrições médicas diretamente na tela de busca.

Controle de Presença e Trilha de Auditoria: Registro de Check-in/Check-out em tempo real com rastreabilidade de quem entregou e quem retirou a criança.

2. Estrutura do Banco de Dados e Regras de Negócio
Entidades Principais
responsaveis (Lado 1): Armazena dados únicos dos adultos responsáveis.

criancas (Lado N): Cadastra os dependentes vinculados a um responsável principal, contendo alertas médicos/alérgicos em destaque.

termos_adesao: Registra o aceite do termo de responsabilidade e o tipo de assinatura (digital ou física).

eventos: Cadastra a edição ou espaço Kids ativo.

presenca_espaco_kids: Tabela associativa que controla a frequência (entrada/saída) e registra o responsável autorizante da retirada.

3. Modelo Entidade-Relacionamento (MER)
3.1. Representação Textual (DER Conceptual)
RESPONSÁVEL (1,N) ------ (1,1) CRIANÇA

Um responsável pode ter uma ou várias crianças cadastradas.

Cada criança está vinculada obrigatoriamente a um responsável principal.

RESPONSÁVEL (1,N) ------ (1,1) TERMO_ADESAO

Um responsável pode possuir um ou mais termos de adesão aceitos ao longo do tempo.

EVENTO (1,N) ------ (1,1) PRESENCA_ESPACO_KIDS

Um evento possui vários registros de presença.

CRIANÇA (1,N) ------ (1,1) PRESENCA_ESPACO_KIDS

Uma criança pode ter múltiplos registros de entrada/saída em eventos.

RESPONSÁVEL (Entrada/Saída) (1,N) ------ (1,1) PRESENCA_ESPACO_KIDS

O responsável registra o check-in e autoriza/executa o check-out da criança.

3.2. Gráfico do Diagrama Entidade-Relacionamento (Diagrama ER)
