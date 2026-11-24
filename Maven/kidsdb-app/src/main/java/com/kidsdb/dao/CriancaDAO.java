package com.kidsdb.dao;

import com.kidsdb.db.ConexaoDB;
import java.sql.*;

public class CriancaDAO {

    public void cadastrar(int idResponsavel, String nome, String dataNascSql, String tipoSanguineo,
                          String alergias, String necessidades, String obsMedicas) throws SQLException {
        String sql = "INSERT INTO criancas (id_responsavel_principal, nome, data_nascimento, tipo_sanguineo, alergias, necessidades_especiais, observacoes_medicas) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = ConexaoDB.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idResponsavel);
            stmt.setString(2, nome);
            stmt.setDate(3, Date.valueOf(dataNascSql)); // Formato YYYY-MM-DD
            stmt.setString(4, tipoSanguineo);
            stmt.setString(5, alergias);
            stmt.setString(6, necessidades);
            stmt.setString(7, obsMedicas);
            stmt.executeUpdate();
        }
    }
}