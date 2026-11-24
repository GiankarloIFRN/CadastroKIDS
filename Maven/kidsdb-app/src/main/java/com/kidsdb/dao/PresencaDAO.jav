package com.kidsdb.dao;

import com.kidsdb.db.ConexaoDB;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PresencaDAO {

    public void criarEvento(String nome, String local, String inicio, String fim) throws SQLException {
        String sql = "INSERT INTO eventos (nome_evento, local, data_inicio, data_fim) VALUES (?, ?, ?, ?)";
        try (Connection conn = ConexaoDB.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, nome);
            stmt.setString(2, local);
            stmt.setTimestamp(3, Timestamp.valueOf(inicio));
            stmt.setTimestamp(4, Timestamp.valueOf(fim));
            stmt.executeUpdate();
        }
    }

    public void realizarCheckIn(int idEvento, int idCrianca, int idRespEntrada, String pulseira, String obs) throws SQLException {
        String sql = "INSERT INTO presenca_espaco_kids (id_evento, id_crianca, id_responsavel_entrada, status, pulseira_identificacao, observacoes_turno) VALUES (?, ?, ?, 'PRESENTE', ?, ?)";
        try (Connection conn = ConexaoDB.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idEvento);
            stmt.setInt(2, idCrianca);
            stmt.setInt(3, idRespEntrada);
            stmt.setString(4, pulseira);
            stmt.setString(5, obs);
            stmt.executeUpdate();
        }
    }

    public void realizarCheckOut(int idPresenca, int idRespSaida) throws SQLException {
        String sql = "UPDATE presenca_espaco_kids SET status = 'AUSENTE', id_responsavel_saida = ?, data_hora_saida = NOW() WHERE id_presenca = ? AND status = 'PRESENTE'";
        try (Connection conn = ConexaoDB.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idRespSaida);
            stmt.setInt(2, idPresenca);
            int rows = stmt.executeUpdate();
            if (rows == 0) {
                throw new SQLException("Registro não encontrado ou criança já realizou check-out.");
            }
        }
    }

    // CONSULTA 1: Busca rápida em casos de emergência
    public List<Object[]> buscarEmergencia(String termoBusca) throws SQLException {
        String sql = """
            SELECT c.nome AS nome_crianca,
                   TIMESTAMPDIFF(YEAR, c.data_nascimento, CURDATE()) AS idade,
                   c.alergias, c.necessidades_especiais, c.observacoes_medicas,
                   r.nome AS nome_responsavel, r.telefone, p.pulseira_identificacao
            FROM presenca_espaco_kids p
            JOIN criancas c ON p.id_crianca = c.id_crianca
            JOIN responsaveis r ON c.id_responsavel_principal = r.id_responsavel
            WHERE (c.nome LIKE ? OR p.pulseira_identificacao = ?)
              AND p.status = 'PRESENTE'
            """;

        List<Object[]> resultados = new ArrayList<>();
        try (Connection conn = ConexaoDB.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + termoBusca + "%");
            stmt.setString(2, termoBusca);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                resultados.add(new Object[]{
                    rs.getString("nome_crianca"),
                    rs.getInt("idade"),
                    rs.getString("alergias"),
                    rs.getString("necessidades_especiais"),
                    rs.getString("observacoes_medicas"),
                    rs.getString("nome_responsavel"),
                    rs.getString("telefone"),
                    rs.getString("pulseira_identificacao")
                });
            }
        }
        return resultados;
    }

    // CONSULTA 2: Lista de crianças presentes no evento
    public List<Object[]> listarPresentesNoEvento(int idEvento) throws SQLException {
        String sql = """
            SELECT p.id_presenca, c.nome AS crianca, r.nome AS responsavel,
                   r.telefone, p.pulseira_identificacao, p.data_hora_entrada
            FROM presenca_espaco_kids p
            JOIN criancas c ON p.id_crianca = c.id_crianca
            JOIN responsaveis r ON c.id_responsavel_principal = r.id_responsavel
            WHERE p.id_evento = ? AND p.status = 'PRESENTE'
            ORDER BY p.data_hora_entrada DESC
            """;

        List<Object[]> resultados = new ArrayList<>();
        try (Connection conn = ConexaoDB.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idEvento);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                resultados.add(new Object[]{
                    rs.getInt("id_presenca"),
                    rs.getString("crianca"),
                    rs.getString("responsavel"),
                    rs.getString("telefone"),
                    rs.getString("pulseira_identificacao"),
                    rs.getTimestamp("data_hora_entrada")
                });
            }
        }
        return resultados;
    }
}