package com.kidsdb.dao;

import com.kidsdb.db.ConexaoDB;
import java.sql.*;
import java.util.List;

public class ResponsavelDAO {

    public int cadastrarCompleto(
            String nome, String cpf, String telefone, String parentesco,
            String logradouro, String numero, String bairro, String cidade, String uf, String cep,
            List<String> emails, String tipoAssinatura, boolean termoAceito) throws SQLException {

        String sqlResp = "INSERT INTO responsaveis (nome, cpf, telefone, parentesco, logradouro, numero, bairro, cidade, uf, cep) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlEmail = "INSERT INTO responsaveis_emails (id_responsavel, email) VALUES (?, ?)";
        String sqlTermo = "INSERT INTO termos_adesao (id_responsavel, tipo_assinatura, termo_aceito) VALUES (?, ?, ?)";

        try (Connection conn = ConexaoDB.getConnection()) {
            conn.setAutoCommit(false); // Inicia transação

            try (PreparedStatement stmtResp = conn.prepareStatement(sqlResp, Statement.RETURN_GENERATED_KEYS)) {
                stmtResp.setString(1, nome);
                stmtResp.setString(2, cpf);
                stmtResp.setString(3, telefone);
                stmtResp.setString(4, parentesco);
                stmtResp.setString(5, logradouro);
                stmtResp.setString(6, numero);
                stmtResp.setString(7, bairro);
                stmtResp.setString(8, cidade);
                stmtResp.setString(9, uf);
                stmtResp.setString(10, cep);
                stmtResp.executeUpdate();

                ResultSet rs = stmtResp.getGeneratedKeys();
                if (!rs.next()) {
                    throw new SQLException("Falha ao obter ID do responsável.");
                }
                int idResponsavel = rs.getInt(1);

                // Inserir E-mails (1FN multivalorado)
                try (PreparedStatement stmtEmail = conn.prepareStatement(sqlEmail)) {
                    for (String email : emails) {
                        if (!email.trim().isEmpty()) {
                            stmtEmail.setInt(1, idResponsavel);
                            stmtEmail.setString(2, email.trim());
                            stmtEmail.addBatch();
                        }
                    }
                    stmtEmail.executeBatch();
                }

                // Inserir Termo de Adesão
                try (PreparedStatement stmtTermo = conn.prepareStatement(sqlTermo)) {
                    stmtTermo.setInt(1, idResponsavel);
                    stmtTermo.setString(2, tipoAssinatura);
                    stmtTermo.setBoolean(3, termoAceito);
                    stmtTermo.executeUpdate();
                }

                conn.commit();
                return idResponsavel;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }
}