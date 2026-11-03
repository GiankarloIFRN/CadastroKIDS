CREATE DATABASE kidsDB;
USE kidsDB;

-- 1. TABELA DE RESPONSÁVEIS
-- 1FN (Atributo Composto): Endereço desmembrado em partes atômicas.
CREATE TABLE responsaveis (
    id_responsavel INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    parentesco VARCHAR(30) NOT NULL, -- Ex: Pai, Mãe, Tio, Avô, Tutor
    
    -- Campos do Atributo Composto (Endereço)
    logradouro VARCHAR(150),
    numero VARCHAR(20),
    bairro VARCHAR(50),
    cidade VARCHAR(50),
    uf CHAR(2),
    cep VARCHAR(10),
    
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1.1. TABELA DE E-MAILS DOS RESPONSÁVEIS
-- 1FN (Atributo Multivalorado): Um responsável pode ter 1 ou N e-mails cadastrados.
CREATE TABLE responsaveis_emails (
    id_email INT AUTO_INCREMENT PRIMARY KEY,
    id_responsavel INT NOT NULL,
    email VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_responsavel) REFERENCES responsaveis(id_responsavel) ON DELETE CASCADE
);

-- 2. TABELA DE TERMOS DE RESPONSABILIDADE
CREATE TABLE termos_adesao (
    id_termo INT AUTO_INCREMENT PRIMARY KEY,
    id_responsavel INT NOT NULL,
    tipo_assinatura ENUM('DIGITAL', 'FISICA') NOT NULL,
    hash_assinatura_digital VARCHAR(255), 
    termo_aceito BOOLEAN NOT NULL DEFAULT FALSE,
    data_assinatura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_responsavel) REFERENCES responsaveis(id_responsavel) ON DELETE CASCADE
);

-- 3. TABELA DE CRIANÇAS
CREATE TABLE criancas (
    id_crianca INT AUTO_INCREMENT PRIMARY KEY,
    id_responsavel_principal INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    tipo_sanguineo VARCHAR(5),
    alergias TEXT,
    necessidades_especiais TEXT,
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
CREATE TABLE presenca_espaco_kids (
    id_presenca INT AUTO_INCREMENT PRIMARY KEY,
    id_evento INT NOT NULL,
    id_crianca INT NOT NULL,
    id_responsavel_entrada INT NOT NULL,
    id_responsavel_saida INT NULL,
    data_hora_entrada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_hora_saida DATETIME NULL,
    status ENUM('PRESENTE', 'AUSENTE') NOT NULL DEFAULT 'PRESENTE',
    pulseira_identificacao VARCHAR(50),
    observacoes_turno TEXT,
    FOREIGN KEY (id_evento) REFERENCES eventos(id_evento),
    FOREIGN KEY (id_crianca) REFERENCES criancas(id_crianca),
    FOREIGN KEY (id_responsavel_entrada) REFERENCES responsaveis(id_responsavel),
    FOREIGN KEY (id_responsavel_saida) REFERENCES responsaveis(id_responsavel)
);

-- ÍNDICES PARA OTIMIZAÇÃO DE BUSCA E EMERGÊNCIA
CREATE INDEX idx_responsaveis_cpf ON responsaveis(cpf);
CREATE INDEX idx_criancas_nome ON criancas(nome);
CREATE INDEX idx_presenca_status ON presenca_espaco_kids(status, id_evento);

-- CONSULTA 1: Busca rápida em casos de emergência
SELECT 
    c.nome AS nome_crianca,
    TIMESTAMPDIFF(YEAR, c.data_nascimento, CURDATE()) AS idade,
    c.alergias,
    c.necessidades_especiais,
    c.observacoes_medicas,
    r.nome AS nome_responsavel,
    r.telefone,
    p.pulseira_identificacao
FROM presenca_espaco_kids p
JOIN criancas c ON p.id_crianca = c.id_crianca
JOIN responsaveis r ON c.id_responsavel_principal = r.id_responsavel
WHERE (c.nome LIKE '%NomeDaCrianca%' OR p.pulseira_identificacao = 'P-102')
  AND p.status = 'PRESENTE';

-- CONSULTA 2: Lista de crianças presentes no evento
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
