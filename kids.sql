
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

--Atividade do dia 13/10 começa aqui

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


-- 8 Inserções individuais na Tabela A (responsaveis)
INSERT INTO responsaveis (id_responsavel, nome, cpf, rg, telefone, telefone_emergencia, email, parentesco) 
VALUES (1, 'Carlos Silva', '111.111.111-11', '11111111-1', '(11) 91111-1111', '(11) 91111-0000', 'carlos@email.com', 'Pai');

INSERT INTO responsaveis (id_responsavel, nome, cpf, rg, telefone, telefone_emergencia, email, parentesco) 
VALUES (2, 'Mariana Oliveira', '222.222.222-22', '22222222-2', '(11) 92222-2222', '(11) 92222-0000', 'mariana@email.com', 'Mãe');

INSERT INTO responsaveis (id_responsavel, nome, cpf, rg, telefone, telefone_emergencia, email, parentesco) 
VALUES (3, 'Roberto Santos', '333.333.333-33', '33333333-3', '(11) 93333-3333', '(11) 93333-0000', 'roberto@email.com', 'Tio');

INSERT INTO responsaveis (id_responsavel, nome, cpf, rg, telefone, telefone_emergencia, email, parentesco) 
VALUES (4, 'Fernanda Lima', '444.444.444-44', '44444444-4', '(11) 94444-4444', '(11) 94444-0000', 'fernanda@email.com', 'Mãe');

INSERT INTO responsaveis (id_responsavel, nome, cpf, rg, telefone, telefone_emergencia, email, parentesco) 
VALUES (5, 'Lucas Mendes', '555.555.555-55', '55555555-5', '(11) 95555-5555', '(11) 95555-0000', 'lucas@email.com', 'Pai');

INSERT INTO responsaveis (id_responsavel, nome, cpf, rg, telefone, telefone_emergencia, email, parentesco) 
VALUES (6, 'Beatriz Souza', '666.666.666-66', '66666666-6', '(11) 96666-6666', '(11) 96666-0000', 'beatriz@email.com', 'Avó');

INSERT INTO responsaveis (id_responsavel, nome, cpf, rg, telefone, telefone_emergencia, email, parentesco) 
VALUES (7, 'Rodrigo Almeida', '777.777.777-77', '77777777-7', '(11) 97777-7777', '(11) 97777-0000', 'rodrigo@email.com', 'Pai');

-- Registro 8: Sem nenhuma criança cadastrada no banco
INSERT INTO responsaveis (id_responsavel, nome, cpf, rg, telefone, telefone_emergencia, email, parentesco) 
VALUES (8, 'Patricia Rocha', '888.888.888-88', '88888888-8', '(11) 98888-8888', '(11) 98888-0000', 'patricia@email.com', 'Mãe');

-- Crianças do Responsável 1 (2 crianças)
INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (1, 'Enzo Silva', '2018-05-10', 'A+', 'Lactose');

INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (1, 'Valentina Silva', '2020-08-15', 'A+', 'Nenhuma');

-- Crianças do Responsável 2 (2 crianças)
INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (2, 'Lucas Oliveira', '2017-02-20', 'O+', 'Picada de abelha');

INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (2, 'Sophia Oliveira', '2019-11-05', 'O+', 'Nenhuma');

-- Crianças do Responsável 3 (2 crianças)
INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (3, 'Gabriel Santos', '2016-07-30', 'B+', 'Glúten');

INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (3, 'Isabela Santos', '2021-01-12', 'B+', 'Nenhuma');

-- Crianças do Responsável 4 (2 crianças)
INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (4, 'Matheus Lima', '2018-09-22', 'AB+', 'Amendoim');

INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (4, 'Alice Lima', '2020-04-18', 'AB+', 'Nenhuma');

-- Crianças do Responsável 5 (2 crianças)
INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (5, 'Arthur Mendes', '2017-12-01', 'O-', 'Nenhuma');

INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (5, 'Helena Mendes', '2022-03-14', 'O-', 'Corante amarelo');

-- Crianças do Responsável 6 (2 crianças)
INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (6, 'Bernardo Souza', '2015-06-11', 'A-', 'Nenhuma');

INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (6, 'Laura Souza', '2019-10-25', 'A-', 'Dipirona');

-- Crianças do Responsável 7 (4 crianças - Teste de Agrupamento/Contagem)
INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (7, 'Pedro Almeida', '2016-04-05', 'O+', 'Nenhuma');

INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (7, 'Davi Almeida', '2018-01-19', 'O+', 'Nenhuma');

INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (7, 'Manuela Almeida', '2020-06-30', 'O+', 'Camarão');

INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias) 
VALUES (7, 'Gael Almeida', '2022-09-09', 'O+', 'Nenhuma');
SELECT 
    r.id_responsavel,
    r.nome AS nome_responsavel,
    r.telefone,
    c.id_crianca,
    c.nome AS nome_crianca,
    c.alergias
FROM responsaveis r
INNER JOIN criancas c ON r.id_responsavel = c.id_responsavel_principal
ORDER BY r.id_responsavel, c.nome;

SELECT 
    r.id_responsavel,
    r.nome AS nome_responsavel,
    COUNT(c.id_crianca) AS total_criancas
FROM responsaveis r
INNER JOIN criancas c ON r.id_responsavel = c.id_responsavel_principal
GROUP BY r.id_responsavel, r.nome
ORDER BY total_criancas DESC;

SELECT 
    r.id_responsavel,
    r.nome AS nome_responsavel,
    r.cpf,
    c.nome AS nome_crianca
FROM responsaveis r
LEFT JOIN criancas c ON r.id_responsavel = c.id_responsavel_principal
WHERE c.id_crianca IS NULL;