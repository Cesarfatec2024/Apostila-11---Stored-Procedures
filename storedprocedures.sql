Active: 1718629280013@@127.0.0.1@5432@stored_procedures
-- Exercícios
-- 1.1 
CREATE TABLE tb_log (
    log_id SERIAL PRIMARY KEY,
    procedure_name VARCHAR(200) NOT NULL,
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SELECT * FROM tb_log;

-- Registro do log
INSERT INTO tb_log (procedure_name) VALUES ('sp_obter_notas_para_compor_o_troco');
END;
$$

INSERT INTO tb_log (procedure_name) VALUES ('sp_calcular_troco');
END;
$$

INSERT INTO tb_log (procedure_name) VALUES ('sp_fechar_pedido');
    END IF;
END;
$$

INSERT INTO tb_log (procedure_name) VALUES ('sp_calcular_valor_de_um_pedido');
END;
$$

INSERT INTO tb_log (procedure_name) VALUES ('sp_adicionar_item_a_pedido');
END;
$$

INSERT INTO tb_log (procedure_name) VALUES ('sp_criar_pedido');
END;
$$

INSERT INTO tb_log (procedure_name) VALUES ('sp_cadastrar_cliente');
END;
$$

SELECT * FROM tb_log;


-- 1.2
CREATE OR REPLACE PROCEDURE sp_contar_pedidos_cliente(
    IN p_cod_cliente INT
) LANGUAGE plpgsql
AS $$
DECLARE
    v_total_pedidos INT;
BEGIN
    SELECT COUNT(*)
    INTO v_total_pedidos
    FROM tb_pedido
    WHERE cod_cliente = p_cod_cliente;

    RAISE NOTICE 'Total de pedidos para o cliente %: %', p_cod_cliente, v_total_pedidos;

    INSERT INTO tb_log (procedure_name) VALUES ('sp_contar_pedidos_cliente');
END;
$$;

CALL sp_contar_pedidos_cliente(1); 

SELECT * FROM tb_log;


-- 1.3
CREATE OR REPLACE PROCEDURE sp_obter_total_pedidos_cliente(
    IN p_cod_cliente INT,
    OUT v_total_pedidos INT
) LANGUAGE plpgsql
AS $$
BEGIN
    SELECT COUNT(*)
    INTO v_total_pedidos
    FROM tb_pedido
    WHERE cod_cliente = p_cod_cliente;

    INSERT INTO tb_log (procedure_name) VALUES ('sp_obter_total_pedidos_cliente');
END;
$$;

DO $$
DECLARE
    total_pedidos INT;
BEGIN
    CALL sp_obter_total_pedidos_cliente(1, total_pedidos);  -- Substitua 1 pelo código do cliente desejado
    RAISE NOTICE 'Total de pedidos para o cliente: %', total_pedidos;
END;
$$;

SELECT * FROM tb_log;


-- 1.4
CREATE OR REPLACE PROCEDURE sp_contar_pedidos_cliente_inout(
    INOUT p_cod_cliente INT
) LANGUAGE plpgsql
AS $$
DECLARE
    v_total_pedidos INT;
BEGIN
    SELECT COUNT(*)
    INTO v_total_pedidos
    FROM tb_pedido
    WHERE cod_cliente = p_cod_cliente;

    p_cod_cliente := v_total_pedidos;

    INSERT INTO tb_log (procedure_name) VALUES ('sp_contar_pedidos_cliente_inout');
END;
$$;

DO $$
DECLARE
    cod_cliente INT := 1; 
BEGIN
    CALL sp_contar_pedidos_cliente_inout(cod_cliente);
    RAISE NOTICE 'Total de pedidos para o cliente: %', cod_cliente;
END;
$$;

SELECT * FROM tb_log;


-- 1.5
CREATE OR REPLACE PROCEDURE sp_cadastrar_varios_clientes(
    OUT p_resultado TEXT,
    VARIADIC p_nomes VARCHAR[]
) LANGUAGE plpgsql
AS $$
DECLARE
    v_nome VARCHAR;
    v_nomes_cadastrados TEXT := '';
BEGIN
    FOREACH v_nome IN ARRAY p_nomes LOOP
        INSERT INTO tb_cliente(nome) VALUES (v_nome);

        IF v_nomes_cadastrados = '' THEN
            v_nomes_cadastrados := v_nome;
        ELSE
            v_nomes_cadastrados := v_nomes_cadastrados || ', ' || v_nome;
        END IF;
    END LOOP;

    p_resultado := 'Os clientes: ' || v_nomes_cadastrados || ' foram cadastrados';

    INSERT INTO tb_log (procedure_name) VALUES ('sp_cadastrar_varios_clientes');
END;
$$;

DO $$
DECLARE
    resultado TEXT;
BEGIN
    CALL sp_cadastrar_varios_clientes(resultado, 'Pedro', 'Ana', 'João');
    RAISE NOTICE '%', resultado;
END;
$$;

SELECT * FROM tb_cliente;

SELECT * FROM tb_log;


-- 1.6
DO $$
DECLARE
    resultado TEXT;
BEGIN
    CALL sp_cadastrar_varios_clientes(resultado, 'Pedro', 'Ana', 'João');
    RAISE NOTICE '%', resultado;
END;
$$;

DO $$
DECLARE
    total_pedidos INT := 2; 
BEGIN
    CALL sp_contar_pedidos_cliente(total_pedidos);
    RAISE NOTICE 'O cliente possui % pedidos.', total_pedidos;
END;
$$;

DO $$
DECLARE
    cod_pedido INT;
    cod_cliente INT := 1; 
BEGIN
    CALL sp_criar_pedido(cod_pedido, cod_cliente);
    RAISE NOTICE 'Código do pedido recém criado: %', cod_pedido;
END;
$$;

DO $$
DECLARE
    cod_item INT := 1; 
    cod_pedido INT := 2; 
BEGIN
    CALL sp_adicionar_item_a_pedido(cod_item, cod_pedido);
    RAISE NOTICE 'Item % adicionado ao pedido %.', cod_item, cod_pedido;
END;
$$;

DO $$
DECLARE
    valor_pago_pelo_cliente INT := 30; 
    codigo_pedido INT := 1; 
BEGIN
    CALL sp_fechar_pedido(valor_pago_pelo_cliente, codigo_pedido);
    RAISE NOTICE 'Pedido % fechado com sucesso.', codigo_pedido;
END;
$$;

DO $$
DECLARE
    valor_total INT;
    codigo_pedido INT := 1; 
BEGIN
    CALL sp_calcular_valor_de_um_pedido(codigo_pedido, valor_total);
    RAISE NOTICE 'O valor total do pedido % é R$%.', codigo_pedido, valor_total;
END;
$$;

DO $$
DECLARE
    troco INT;
    valor_pago_pelo_cliente INT := 40; 
    valor_total INT := 30; 
BEGIN
    CALL sp_calcular_troco(troco, valor_pago_pelo_cliente, valor_total);
    RAISE NOTICE 'O troco é R$%.', troco;
END;
$$;

DO $$
DECLARE
    valor1 INT := 2;
    valor2 INT := 3;
BEGIN
    CALL sp_acha_maior(valor1, valor2);
    RAISE NOTICE 'O maior valor é %.', valor1;
END;
$$;

DO $$
BEGIN
    CALL sp_calcula_media(1, 2, 3, 4, 5);
END;
$$;



-- Conteúdo mostrado em aula
-- DO $$
-- DECLARE
--   v_resultado VARCHAR(500);
--   v_troco INT := 43;
-- BEGIN
--   CALL sp_obter_notas_para_compor_o_troco(v_resultado, v_troco);
--   RAISE NOTICE '%', v_resultado;
-- END;
-- $$


-- CREATE OR REPLACE PROCEDURE sp_obter_notas_para_compor_o_troco(
--     OUT p_resultado VARCHAR(500),
--     IN p_troco INT
-- ) LANGUAGE plpgsql 
-- AS $$
-- DECLARE 
--     v_notas200 INT := 0;
--     v_notas100 INT := 0;
--     v_notas50 INT := 0;
--     v_notas20 INT := 0;
--     v_notas10 INT := 0;
--     v_notas5 INT := 0;
--     v_notas2 INT := 0;
--     v_moedas1 INT := 0;
-- BEGIN
--     v_notas200 := p_troco / 200;
--     v_notas100 := p_troco % 200 / 100;
--     v_notas50 := p_troco % 200 % 100 / 50;
--     v_notas20 := p_troco % 200 % 100 % 50 / 20;
--     v_notas10 := p_troco % 200 % 100 % 50 % 20 / 10;
--     v_notas5 := p_troco % 200 % 100 % 50 % 20 % 10 / 5;
--     v_notas2 := p_troco % 200 % 100 % 50 % 20 % 10 % 5 / 2;
--     v_moedas1 := p_troco % 200 % 100 % 50 % 20 % 10 % 5 % 2 / 1;

--     p_resultado := CONCAT(
--         'Notas de 200: ',
--         v_notas200 || E'\n',
--         'Notas de 100: ',
--         v_notas100 || E'\n',
--         'Notas de 50: ',
--         v_notas50 || E'\n',
--         'Notas de 20: ',
--         v_notas20 || E'\n',
--         'Notas de 10: ',
--         v_notas10 || E'\n'
--         'Notas de 5: ',
--         v_notas5 || E'\n',
--         'Notas de 2: ',
--         v_notas2 || E'\n',
--         'Moedas de 1: ',
--         v_moedas1
--     );
-- END;
-- $$


-- DO $$
-- DECLARE 
--     v_troco INT;
--     v_valor_total INT;
--     v_valor_pago_pelo_cliente INT := 50;
-- BEGIN
--     CALL sp_calcular_valor_de_um_pedido(1, v_valor_total);
--     CALL sp_calcular_troco(
--         v_troco,
--         v_valor_pago_pelo_cliente,
--         v_valor_total
--     );
--     RAISE NOTICE 'A conta foi de R$% e você pagou R$%. Assim, seu troco é de R$%. Volte sempre.', v_valor_total, 
--     v_valor_pago_pelo_cliente, v_troco;
-- END;
-- $$


-- -- calcular o troco
-- CREATE OR REPLACE PROCEDURE sp_calcular_troco(
--     OUT p_troco INT,
--     IN p_valor_pago_pelo_cliente INT,
--     IN p_valor_total INT
-- ) LANGUAGE plpgsql AS $$
-- BEGIN
--     p_troco := p_valor_pago_pelo_cliente - p_valor_total;
-- END;
-- $$


-- CALL sp_fechar_pedido(18, 1);
-- CALL sp_fechar_pedido(19, 1);

-- SELECT * FROM tb_pedido;

-- CREATE OR REPLACE PROCEDURE sp_fechar_pedido(
--     IN p_valor_pago_pelo_cliente INT,
--     IN p_codigo_pedido INT
-- )LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     v_valor_total INT;
-- BEGIN
--     CALL sp_calcular_valor_de_um_pedido(
--         p_codigo_pedido,
--         v_valor_total
--     );
--     IF p_valor_pago_pelo_cliente < v_valor_total THEN
--         RAISE NOTICE 'R$% insuficiente para pagar a conta de R$%', 
--         p_valor_pago_pelo_cliente, v_valor_total;
--     ELSE
--         UPDATE tb_pedido p SET
--         data_modificacao = CURRENT_TIMESTAMP,
--         status = 'fechado'
--         WHERE p.cod_pedido = $2;
--     END IF;
-- END;
-- $$


-- DO $$
-- DECLARE 
--     v_valor_total INT;
-- BEGIN
--     CALL sp_calcular_valor_de_um_pedido(1, v_valor_total);
--     RAISE NOTICE 'Total do pedido %: R$%', 1, v_valor_total;
-- END;
-- $$


-- -- calcula o valor total de um pedido
-- CREATE OR REPLACE PROCEDURE sp_calcular_valor_de_um_pedido(
--     IN p_codigo_pedido INT,
--     OUT p_valor_total INT
-- ) LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     SELECT SUM(i.valor) FROM 
--     tb_pedido p
--     INNER JOIN tb_item_pedido ip ON
--     p.cod_pedido = ip.cod_pedido
--     INNER JOIN tb_item i ON
--     ip.cod_item = i.cod_item
--     WHERE p.cod_pedido = $1
--     INTO $2;
-- END;
-- $$

-- SELECT * FROM tb_pedido;
-- SELECT * FROM tb_item_pedido;
-- SELECT * FROM tb_item;


-- SELECT * FROM tb_item_pedido;
-- SELECT * FROM tb_pedido;
-- DELETE FROM tb_pedido
-- WHERE cod_pedido = 2;
-- CALL sp_adicionar_item_a_pedido(1, 1);

-- SELECT * FROM tb_item;
-- INSERT INTO tb_item(descricao, valor, cod_tipo) VALUES 
-- ('Refrigerante', 7, 1),
-- ('Suco', 8, 1),
-- ('Hambúrguer', 12, 2),
-- ('Batata frita', 9, 2)

-- SELECT * FROM tb_tipo_item;
-- INSERT INTO tb_tipo_item (descricao) VALUES('Bebida'), ('Comida');


-- -- adiciona um item a um pedido
-- -- cadastrar o código de item e o código de pedido
-- -- atualizar a tabela de pedido, especificamente no campo data_modificacao
-- CREATE OR REPLACE PROCEDURE sp_adicionar_item_a_pedido(
--     IN cod_item INT,
--     IN cod_pedido INT 
-- ) LANGUAGE plpgsql AS $$
-- BEGIN
--     INSERT INTO tb_item_pedido(cod_item, cod_pedido) VALUES($1, $2);
--     -- atualizar a tabela tb_pedido no campo data_modificacao, registrando a data atual
--     UPDATE tb_pedido p SET data_modificacao = CURRENT_TIMESTAMP
--     WHERE p.cod_pedido = $2;
-- END;
-- $$


-- SELECT * FROM tb_pedido;
-- DO $$
-- DECLARE
--     -- para guardar código de pedido gerado
--     cod_pedido INT;
--     -- o código do cliente que vai fazer o pedido
--     cod_cliente INT;
-- BEGIN
--     -- pegando o código da pessoa cujo nome é 'João da Silva'
--     SELECT c.cod_cliente FROM tb_cliente c
--     WHERE nome LIKE 'João da Silva' INTO cod_cliente;
--     CALL sp_criar_pedido(cod_pedido, cod_cliente);
--     RAISE NOTICE 'Código do pedido recém criado: %', cod_pedido;
-- END;
-- $$


-- cadastro de pedido sem item, ou seja, simulamos a entrada do cliente
-- quando o pedido for cadastrado, o código será gerado
-- ele deverá ser disponibilizado externamente
-- CREATE OR REPLACE PROCEDURE sp_criar_pedido(
--     OUT cod_pedido INT,
--     IN cod_cliente INT
-- ) LANGUAGE plpgsql 
-- AS $$
-- BEGIN 
--     INSERT INTO tb_pedido (cod_cliente) VALUES (cod_cliente);
--     SELECT LASTVAL() INTO cod_pedido;
-- END;
-- $$

-- CALL sp_cadastrar_cliente('João da Silva');
-- CALL sp_cadastrar_cliente('Maria Santos');
-- SELECT * FROM tb_cliente;

-- DELETE FROM tb_cliente
-- WHERE cod_cliente = 4;

-- -- cadastro de novos clientes 
-- -- talvez eu especifique um código, talvez não
-- CREATE OR REPLACE PROCEDURE sp_cadastrar_cliente(
--     IN nome VARCHAR(200),
--     IN codigo INT DEFAULT NULL
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     -- se o código for null, cadastrar nome apenas
--     -- ou seja, usar valor gerado aleatoriamente pelo nome
--     -- SGBD
--     -- caso contrário, cadastrar nome e código que chegaram via parametro
--     IF codigo IS NULL THEN
--         INSERT INTO tb_cliente(nome) VALUES(nome);
--     ELSE
--         INSERT INTO tb_cliente(codigo, nome) VALUES(codigo, nome);
--     END IF;
-- END;
-- $$

-- -- -- sistema de restaurante
-- CREATE TABLE tb_cliente(
--     cod_cliente SERIAL PRIMARY KEY,
--     nome VARCHAR(200) NOT NULL
-- );

-- CREATE TABLE tb_pedido(
--     cod_pedido SERIAL PRIMARY KEY,
--     data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     data_modificacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     status VARCHAR DEFAULT 'aberto',
--     cod_cliente INT NOT NULL,
--     CONSTRAINT fk_cliente FOREIGN KEY (cod_cliente) REFERENCES 
--     tb_cliente(cod_cliente)
-- );

-- CREATE TABLE tb_tipo_item(
--     cod_tipo SERIAL PRIMARY KEY,
--     descricao VARCHAR(200) NOT NULL
-- );

-- CREATE TABLE tb_item(
--     cod_item SERIAL PRIMARY KEY,
--     descricao VARCHAR(200) NOT NULL,
--     valor NUMERIC(10, 2) NOT NULL,
--     cod_tipo INT NOT NULL,
--     CONSTRAINT fk_tipo_item FOREIGN KEY (cod_tipo) REFERENCES 
--     tb_tipo_item(cod_tipo)
-- );

-- CREATE TABLE tb_item_pedido(
--     --surrogate (substituta)
--     cod_item_pedido SERIAL PRIMARY KEY,
--     cod_item INT,
--     cod_pedido INT,
--     CONSTRAINT fk_item FOREIGN KEY (cod_item) REFERENCES 
--     tb_item(cod_item),
--     CONSTRAINT fk_pedido FOREIGN KEY (cod_pedido) REFERENCES 
--     tb_pedido(cod_pedido)
-- );

-- -- parâmetros variadic
-- CREATE OR REPLACE PROCEDURE sp_calcula_media(
--     VARIADIC valores INT[]
-- )LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     media NUMERIC(10, 2) := 0;
--     valor INT;
-- BEGIN
--     FOREACH valor IN ARRAY valores LOOP
--         media := media + valor;
--     END LOOP;
--     RAISE NOTICE 'A média é: %', media / array_length(valores, 1);
-- END;
-- $$
-- CALL sp_calcula_media(1);
-- CALL sp_calcula_media(1, 2, 5, 4, 6, 3);

-- DROP PROCEDURE IF EXISTS sp_acha_maior;
-- CREATE OR REPLACE PROCEDURE sp_acha_maior(
--     INOUT valor1 INT,
--     IN valor2 INT
-- )LANGUAGE plpgsql
-- AS $$
--     BEGIN
--         IF valor2 > valor1 THEN
--             valor1 := valor2;
--         END IF;
--     END;
-- $$
-- -- colocando em execução
-- DO $$
-- DECLARE
-- valor1 INT := 2;
-- valor2 INT := 3;
-- BEGIN
--     CALL sp_acha_maior(valor1, valor2);
--     RAISE NOTICE '% é o maior', valor1;
-- END;
-- $$
  

-- CREATE OR REPLACE PROCEDURE sp_acha_maior(
--     OUT resultado INT,
--     IN valor1 INT,
--     IN valor2 INT
-- ) LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     -- escreva o maior na variável resultado (use case)
--     CASE 
--         WHEN valor1 > valor2 THEN
--             $1 := valor1;
--         ELSE
--             resultado := valor2;
--     END CASE;
-- END;
-- $$

-- --colocando em execução
-- DO $$
-- DECLARE
--   resultado INT;
-- BEGIN
--   CALL sp_acha_maior(resultado, 2, 3);
--   RAISE NOTICE 'Maior: %', resultado;
-- END;
-- $$


-- CREATE OR REPLACE PROCEDURE sp_acha_maior(
--   IN valor1 INT, 
--   IN valor2 INT
-- ) LANGUAGE plpgsql
-- AS $$
-- BEGIN
--   IF valor1 > valor2 THEN
--     RAISE NOTICE '% é o maior', $1;
--   ELSE
--     RAISE NOTICE '% é o maior', $2;
--   END IF;
-- END;
-- $$

-- CALL sp_acha_maior(2, 3);


-- -- Procedure com parâmetro
-- CREATE OR REPLACE PROCEDURE sp_ola_usuario(p_nome VARCHAR(200))
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN 
--     RAISE NOTICE 'Olá(pelo nome), %', p_nome;
--     RAISE NOTICE 'Olá(pelo número), %', $1;
-- END;
-- $$

-- CALL sp_ola_usuario('Pedro');


-- CREATE DATABASE "20241_fatec_ipi_pbdi_stored_procedures";

-- CREATE OR REPLACE PROCEDURE sp_ola_procedures()
-- LANGUAGE plpgsql 
-- AS $$
-- BEGIN 
--     RAISE NOTICE 'Olá, stored procedures';
-- END;
-- $$;

-- CALL sp_ola_procedures();