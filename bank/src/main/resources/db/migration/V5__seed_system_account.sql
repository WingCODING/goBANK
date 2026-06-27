-- usuário "banco" (dono da conta de sistema)
INSERT INTO users (id, name, email, cpf, password_hash, created_at)
VALUES ('00000000-0000-0000-0000-000000000001', 'Banco Sistema',
        'system@bank.internal', '00000000000', 'N/A', now());

-- conta de sistema: a "fonte" do dinheiro emprestado, com um pool grande
INSERT INTO accounts (id, user_id, balance, status, created_at)
VALUES ('00000000-0000-0000-0000-0000000000a1',
        '00000000-0000-0000-0000-000000000001',
        10000000.00, 'ACTIVE', now());