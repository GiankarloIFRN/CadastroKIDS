package com.kidsdb.ui;

import com.kidsdb.dao.CriancaDAO;
import com.kidsdb.dao.PresencaDAO;
import com.kidsdb.dao.ResponsavelDAO;

import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.util.Arrays;
import java.util.List;

public class MainFrame extends JFrame {

    private final ResponsavelDAO responsavelDAO = new ResponsavelDAO();
    private final CriancaDAO criancaDAO = new CriancaDAO();
    private final PresencaDAO presencaDAO = new PresencaDAO();

    public MainFrame() {
        setTitle("KidsDB - Gestão de Espaço Kids");
        setSize(950, 650);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        JTabbedPane tabbedPane = new JTabbedPane();
        tabbedPane.addTab("1. Responsáveis & Termo", criarPainelResponsaveis());
        tabbedPane.addTab("2. Crianças", criarPainelCriancas());
        tabbedPane.addTab("3. Eventos & Check-in/Out", criarPainelPresenca());
        tabbedPane.addTab("4. Emergência & Presentes", criarPainelConsultas());

        add(tabbedPane);
    }

    private JPanel criarPainelResponsaveis() {
        JPanel panel = new JPanel(new GridLayout(14, 2, 8, 6));
        panel.setBorder(BorderFactory.createEmptyBorder(15, 20, 15, 20));

        JTextField txtNome = new JTextField();
        JTextField txtCpf = new JTextField();
        JTextField txtTelefone = new JTextField();
        JTextField txtParentesco = new JTextField();
        JTextField txtEmails = new JTextField();
        JTextField txtLogradouro = new JTextField();
        JTextField txtNumero = new JTextField();
        JTextField txtBairro = new JTextField();
        JTextField txtCidade = new JTextField();
        JTextField txtUf = new JTextField();
        JTextField txtCep = new JTextField();
        JComboBox<String> cbAssinatura = new JComboBox<>(new String[]{"FISICA", "DIGITAL"});
        JCheckBox chkTermo = new JCheckBox("Termo de Adesão Assinado e Conferido", true);
        JButton btnSalvar = new JButton("Cadastrar Responsável + Termo");

        panel.add(new JLabel("Nome Completo:*")); panel.add(txtNome);
        panel.add(new JLabel("CPF (000.000.000-00):*")); panel.add(txtCpf);
        panel.add(new JLabel("Telefone:*")); panel.add(txtTelefone);
        panel.add(new JLabel("Parentesco (Pai, Mãe, etc.):*")); panel.add(txtParentesco);
        panel.add(new JLabel("E-mails (separados por vírgula):")); panel.add(txtEmails);
        panel.add(new JLabel("Logradouro:")); panel.add(txtLogradouro);
        panel.add(new JLabel("Número:")); panel.add(txtNumero);
        panel.add(new JLabel("Bairro:")); panel.add(txtBairro);
        panel.add(new JLabel("Cidade:")); panel.add(txtCidade);
        panel.add(new JLabel("UF (2 letras):")); panel.add(txtUf);
        panel.add(new JLabel("CEP:")); panel.add(txtCep);
        panel.add(new JLabel("Tipo de Assinatura do Termo:")); panel.add(cbAssinatura);
        panel.add(new JLabel("Status do Termo:")); panel.add(chkTermo);
        panel.add(new JLabel("")); panel.add(btnSalvar);

        btnSalvar.addActionListener(e -> {
            try {
                List<String> listaEmails = Arrays.asList(txtEmails.getText().split(","));
                int idGerado = responsavelDAO.cadastrarCompleto(
                        txtNome.getText(), txtCpf.getText(), txtTelefone.getText(), txtParentesco.getText(),
                        txtLogradouro.getText(), txtNumero.getText(), txtBairro.getText(),
                        txtCidade.getText(), txtUf.getText(), txtCep.getText(),
                        listaEmails, (String) cbAssinatura.getSelectedItem(), chkTermo.isSelected()
                );
                JOptionPane.showMessageDialog(this, "Responsável cadastrado com sucesso! ID: " + idGerado);
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(this, "Erro: " + ex.getMessage(), "Erro", JOptionPane.ERROR_MESSAGE);
            }
        });

        return panel;
    }

    private JPanel criarPainelCriancas() {
        JPanel panel = new JPanel(new GridLayout(9, 2, 8, 8));
        panel.setBorder(BorderFactory.createEmptyBorder(15, 20, 15, 20));

        JTextField txtIdResp = new JTextField();
        JTextField txtNome = new JTextField();
        JTextField txtDataNasc = new JTextField("2018-05-10");
        JTextField txtTipoSang = new JTextField();
        JTextField txtAlergias = new JTextField();
        JTextField txtNecessidades = new JTextField();
        JTextField txtObsMedicas = new JTextField();
        JButton btnSalvar = new JButton("Cadastrar Criança");

        panel.add(new JLabel("ID do Responsável Principal:*")); panel.add(txtIdResp);
        panel.add(new JLabel("Nome da Criança:*")); panel.add(txtNome);
        panel.add(new JLabel("Data Nascimento (AAAA-MM-DD):*")); panel.add(txtDataNasc);
        panel.add(new JLabel("Tipo Sanguíneo:")); panel.add(txtTipoSang);
        panel.add(new JLabel("Alergias:")); panel.add(txtAlergias);
        panel.add(new JLabel("Necessidades Especiais:")); panel.add(txtNecessidades);
        panel.add(new JLabel("Observações Médicas:")); panel.add(txtObsMedicas);
        panel.add(new JLabel("")); panel.add(btnSalvar);

        btnSalvar.addActionListener(e -> {
            try {
                criancaDAO.cadastrar(
                        Integer.parseInt(txtIdResp.getText().trim()),
                        txtNome.getText(), txtDataNasc.getText().trim(),
                        txtTipoSang.getText(), txtAlergias.getText(),
                        txtNecessidades.getText(), txtObsMedicas.getText()
                );
                JOptionPane.showMessageDialog(this, "Criança cadastrada com sucesso!");
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(this, "Erro: " + ex.getMessage(), "Erro", JOptionPane.ERROR_MESSAGE);
            }
        });

        return panel;
    }

    private JPanel criarPainelPresenca() {
        JPanel container = new JPanel(new GridLayout(3, 1, 10, 10));
        container.setBorder(BorderFactory.createEmptyBorder(10, 20, 10, 20));

        // 1. Criar Evento
        JPanel pEvento = new JPanel(new GridLayout(3, 4, 5, 5));
        pEvento.setBorder(BorderFactory.createTitledBorder("Criar Novo Evento"));
        JTextField txtEvNome = new JTextField();
        JTextField txtEvLocal = new JTextField();
        JTextField txtEvInicio = new JTextField("2026-11-24 09:00:00");
        JTextField txtEvFim = new JTextField("2026-11-24 18:00:00");
        JButton btnCriarEv = new JButton("Salvar Evento");

        pEvento.add(new JLabel("Nome Evento:")); pEvento.add(txtEvNome);
        pEvento.add(new JLabel("Local:")); pEvento.add(txtEvLocal);
        pEvento.add(new JLabel("Início (AAAA-MM-DD HH:MM:SS):")); pEvento.add(txtEvInicio);
        pEvento.add(new JLabel("Fim (AAAA-MM-DD HH:MM:SS):")); pEvento.add(txtEvFim);
        pEvento.add(new JLabel("")); pEvento.add(btnCriarEv);

        btnCriarEv.addActionListener(e -> {
            try {
                presencaDAO.criarEvento(txtEvNome.getText(), txtEvLocal.getText(), txtEvInicio.getText(), txtEvFim.getText());
                JOptionPane.showMessageDialog(this, "Evento criado!");
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(this, "Erro: " + ex.getMessage());
            }
        });

        // 2. Check-In
        JPanel pCheckIn = new JPanel(new GridLayout(3, 4, 5, 5));
        pCheckIn.setBorder(BorderFactory.createTitledBorder("Realizar Check-In"));
        JTextField txtInEvento = new JTextField("1");
        JTextField txtInCrianca = new JTextField();
        JTextField txtInResp = new JTextField();
        JTextField txtInPulseira = new JTextField("P-101");
        JTextField txtInObs = new JTextField();
        JButton btnCheckIn = new JButton("Registrar Entrada");

        pCheckIn.add(new JLabel("ID Evento:")); pCheckIn.add(txtInEvento);
        pCheckIn.add(new JLabel("ID Criança:")); pCheckIn.add(txtInCrianca);
        pCheckIn.add(new JLabel("ID Resp. Entrada:")); pCheckIn.add(txtInResp);
        pCheckIn.add(new JLabel("Pulseira:")); pCheckIn.add(txtInPulseira);
        pCheckIn.add(new JLabel("Obs. Turno:")); pCheckIn.add(txtInObs);
        pCheckIn.add(btnCheckIn);

        btnCheckIn.addActionListener(e -> {
            try {
                presencaDAO.realizarCheckIn(
                        Integer.parseInt(txtInEvento.getText().trim()),
                        Integer.parseInt(txtInCrianca.getText().trim()),
                        Integer.parseInt(txtInResp.getText().trim()),
                        txtInPulseira.getText().trim(), txtInObs.getText()
                );
                JOptionPane.showMessageDialog(this, "Check-in realizado com sucesso!");
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(this, "Erro: " + ex.getMessage());
            }
        });

        // 3. Check-Out
        JPanel pCheckOut = new JPanel(new GridLayout(2, 4, 5, 5));
        pCheckOut.setBorder(BorderFactory.createTitledBorder("Realizar Check-Out"));
        JTextField txtOutPresenca = new JTextField();
        JTextField txtOutResp = new JTextField();
        JButton btnCheckOut = new JButton("Registrar Saída");

        pCheckOut.add(new JLabel("ID Presença:")); pCheckOut.add(txtOutPresenca);
        pCheckOut.add(new JLabel("ID Resp. Saída:")); pCheckOut.add(txtOutResp);
        pCheckOut.add(new JLabel("")); pCheckOut.add(btnCheckOut);

        btnCheckOut.addActionListener(e -> {
            try {
                presencaDAO.realizarCheckOut(
                        Integer.parseInt(txtOutPresenca.getText().trim()),
                        Integer.parseInt(txtOutResp.getText().trim())
                );
                JOptionPane.showMessageDialog(this, "Check-out concluído!");
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(this, "Erro: " + ex.getMessage());
            }
        });

        container.add(pEvento);
        container.add(pCheckIn);
        container.add(pCheckOut);
        return container;
    }

    private JPanel criarPainelConsultas() {
        JPanel panel = new JPanel(new GridLayout(2, 1, 10, 10));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 15, 10, 15));

        // Painel Emergência
        JPanel pEmergencia = new JPanel(new BorderLayout(5, 5));
        pEmergencia.setBorder(BorderFactory.createTitledBorder("BUSCA RÁPIDA DE EMERGÊNCIA (Nome ou Pulseira)"));
        JPanel topEm = new JPanel(new FlowLayout(FlowLayout.LEFT));
        JTextField txtBuscaEm = new JTextField(20);
        JButton btnBuscarEm = new JButton("Buscar Emergência");
        topEm.add(new JLabel("Nome ou Pulseira:"));
        topEm.add(txtBuscaEm);
        topEm.add(btnBuscarEm);

        DefaultTableModel modelEm = new DefaultTableModel(
                new String[]{"Criança", "Idade", "Alergias", "Nec. Especiais", "Obs. Médicas", "Responsável", "Telefone", "Pulseira"}, 0);
        JTable tableEm = new JTable(modelEm);

        btnBuscarEm.addActionListener(e -> {
            try {
                modelEm.setRowCount(0);
                for (Object[] row : presencaDAO.buscarEmergencia(txtBuscaEm.getText().trim())) {
                    modelEm.addRow(row);
                }
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(this, "Erro na busca: " + ex.getMessage());
            }
        });

        pEmergencia.add(topEm, BorderLayout.NORTH);
        pEmergencia.add(new JScrollPane(tableEm), BorderLayout.CENTER);

        // Painel Presentes no Evento
        JPanel pPresentes = new JPanel(new BorderLayout(5, 5));
        pPresentes.setBorder(BorderFactory.createTitledBorder("CRIANÇAS PRESENTES NO EVENTO"));
        JPanel topPres = new JPanel(new FlowLayout(FlowLayout.LEFT));
        JTextField txtIdEvPres = new JTextField("1", 5);
        JButton btnListarPres = new JButton("Atualizar Lista");
        topPres.add(new JLabel("ID do Evento:"));
        topPres.add(txtIdEvPres);
        topPres.add(btnListarPres);

        DefaultTableModel modelPres = new DefaultTableModel(
                new String[]{"ID Presença", "Criança", "Responsável", "Telefone", "Pulseira", "Entrada"}, 0);
        JTable tablePres = new JTable(modelPres);

        btnListarPres.addActionListener(e -> {
            try {
                modelPres.setRowCount(0);
                int idEv = Integer.parseInt(txtIdEvPres.getText().trim());
                for (Object[] row : presencaDAO.listarPresentesNoEvento(idEv)) {
                    modelPres.addRow(row);
                }
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(this, "Erro ao listar: " + ex.getMessage());
            }
        });

        pPresentes.add(topPres, BorderLayout.NORTH);
        pPresentes.add(new JScrollPane(tablePres), BorderLayout.CENTER);

        panel.add(pEmergencia);
        panel.add(pPresentes);
        return panel;
    }
}