MER CadastroKIDS
Snippet de código
erDiagram
    RESPONSAVEIS ||--o{ CRIANCAS : "possui/gerencia (1:N)"
    RESPONSAVEIS ||--o{ TERMOS_ADESAO : "assina (1:N)"
    RESPONSAVEIS ||--o{ PRESENCA_ESPACO_KIDS : "entrega (1:N)"
    RESPONSAVEIS ||--o{ PRESENCA_ESPACO_KIDS : "retira (1:N)"
    EVENTOS ||--o{ PRESENCA_ESPACO_KIDS : "sedia (1:N)"
    CRIANCAS ||--o{ PRESENCA_ESPACO_KIDS : "frequenta (1:N)"

    RESPONSAVEIS {
        int id_responsavel PK
        string nome
        string cpf UK
        string rg
        string telefone
        string telefone_emergencia
        string email
        string parentesco
        timestamp criado_em
    }

    CRIANCAS {
        int id_crianca PK
        int id_responsavel_principal FK
        string nome
        date data_nascimento
        string tipo_sanguineo
        text alergias
        text necessidades_especiais
        text observacoes_medicas
    }

    TERMOS_ADESAO {
        int id_termo PK
        int id_responsavel FK
        enum tipo_assinatura
        string hash_assinatura_digital
        boolean termo_aceito
        timestamp data_assinatura
    }

    EVENTOS {
        int id_evento PK
        string nome_evento
        string local
        datetime data_inicio
        datetime data_fim
    }

    PRESENCA_ESPACO_KIDS {
        int id_presenca PK
        int id_evento FK
        int id_crianca FK
        int id_responsavel_entrada FK
        int id_responsavel_saida FK
        datetime data_hora_entrada
        datetime data_hora_saida
        enum status
        string pulseira_identificacao
        text observacoes_turno
    }
