SQL
-- 1. TABELA DE RESPONSÁVEIS
-- Evita recadastramento: um responsável pode ter N crianças vinculadas.
CREATE TABLE responsaveis (
    id_responsavel INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    rg VARCHAR(20),
    telefone VARCHAR(20) NOT NULL,
    telefone_emergencia VARCHAR(20),
    email VARCHAR(100),
    parentesco VARCHAR(30) NOT NULL, -- Ex: Pai, Mãe, Tio, Avô, Tutor
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. TABELA DE TERMOS DE RESPONSABILIDADE
-- O termo pode ser assinado digitalmente ou fisicamente e reutilizado.
CREATE TABLE termos_adesao (
    id_termo INT AUTO_INCREMENT PRIMARY KEY,
    id_responsavel INT NOT NULL,
    tipo_assinatura ENUM('DIGITAL', 'FISICA') NOT NULL,
    hash_assinatura_digital VARCHAR(255), -- Hash/Token da assinatura digital se aplicável
    termo_aceito BOOLEAN NOT NULL DEFAULT FALSE,
    data_assinatura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_responsavel) REFERENCES responsaveis(id_responsavel) ON DELETE CASCADE
);

-- 3. TABELA DE CRIANÇAS
-- Foco em busca rápida e informações de emergência em destaque.
CREATE TABLE criancas (
    id_crianca INT AUTO_INCREMENT PRIMARY KEY,
    id_responsavel_principal INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    
    -- Campos críticos de emergência
    tipo_sanguineo VARCHAR(5),
    alergias TEXT,                     -- Ex: Pícada de abelha, Amendoim, Lactose
    necessidades_especiais TEXT,       -- Ex: Autismo, TDAH, restrições físicas
    observacoes_medicas TEXT,
    
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_responsavel_principal) REFERENCES responsaveis(id_responsavel)
);

-- 4. TABELA DE EVENTOS
CREATE TABLE eventos (
    id_evento INT AUTO_INCREMENT PRIMARY KEY,
    nome_evento VARCHAR(100) NOT NULL,
    local VARCHAR(100),
    data_inicio DATETIME NOT NULL,
    data_fim DATETIME NOT NULL
);

-- 5. TABELA DE CONTROLE DE FREQUÊNCIA (CHECK-IN / CHECK-OUT)
-- Gerencia presença em tempo real e rastreia quem retirou a criança.
CREATE TABLE presenca_espaco_kids (
    id_presenca INT AUTO_INCREMENT PRIMARY KEY,
    id_evento INT NOT NULL,
    id_crianca INT NOT NULL,
    id_responsavel_entrada INT NOT NULL,  -- Quem deixou a criança
    id_responsavel_saida INT NULL,        -- Quem retirou a criança
    
    data_hora_entrada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_hora_saida DATETIME NULL,
    
    status ENUM('PRESENTE', 'AUSENTE') NOT NULL DEFAULT 'PRESENTE',
    pulseira_identificacao VARCHAR(50),  -- Código/Cor da pulseira no evento
    observacoes_turno TEXT,
    
    FOREIGN KEY (id_evento) REFERENCES eventos(id_evento),
    FOREIGN KEY (id_crianca) REFERENCES criancas(id_crianca),
    FOREIGN KEY (id_responsavel_entrada) REFERENCES responsaveis(id_responsavel),
    FOREIGN KEY (id_responsavel_saida) REFERENCES responsaveis(id_responsavel)
);

-- ÍNDICES PARA OTIMIZAÇÃO DE BUSCA E EMERGÊNCIA
-- Aceleram a pesquisa no balcão e em casos de emergência
CREATE INDEX idx_responsaveis_cpf ON responsaveis(cpf);
CREATE INDEX idx_criancas_nome ON criancas(nome);
CREATE INDEX idx_presenca_status ON presenca_espaco_kids(status, id_evento);

SQL
SELECT 
    c.nome AS nome_crianca,
    TIMESTAMPDIFF(YEAR, c.data_nascimento, CURDATE()) AS idade,
    c.alergias,
    c.necessidades_especiais,
    c.observacoes_medicas,
    r.nome AS nome_responsavel,
    r.telefone,
    r.telefone_emergencia,
    p.pulseira_identificacao
FROM presenca_espaco_kids p
JOIN criancas c ON p.id_crianca = c.id_crianca
JOIN responsaveis r ON c.id_responsavel_principal = r.id_responsavel
WHERE (c.nome LIKE '%NomeDaCrianca%' OR p.pulseira_identificacao = 'P-102')
  AND p.status = 'PRESENTE';

  SQL
SELECT 
    c.nome AS crianca,
    r.nome AS responsavel,
    r.telefone,
    p.pulseira_identificacao,
    p.data_hora_entrada
FROM presenca_espaco_kids p
JOIN criancas c ON p.id_crianca = c.id_crianca
JOIN responsaveis r ON c.id_responsavel_principal = r.id_responsavel
WHERE p.id_evento = 1 
  AND p.status = 'PRESENTE'
ORDER BY p.data_hora_entrada DESC;
