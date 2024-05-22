CREATE OR REPLACE PACKAGE PACK_PROJETO IS

  -- AUTHOR  : USUARIO
  -- CREATED : 26/02/2024 10:16:45
  -- PURPOSE : PACKAGE PARA REUNIR PROCESSOS DE GESTÃO DE UM COMÉRCIO DE VENDAS
  
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE GRAVA_CLIENTES (I_NR_CPF         IN OUT CLIENTE.NR_CPF%TYPE,
                            I_NM_CLIENTE     IN CLIENTE.NM_CLIENTE%TYPE,
                            I_DT_NASCIMENTO  IN CLIENTE.DT_NASCIMENTO%TYPE,
                            O_MENSAGEM       OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE GRAVA_PRODUTO (IO_CD_PRODUTO IN OUT PRODUTO.CD_PRODUTO%TYPE,
                           I_DS_PRODUTO  IN PRODUTO.DS_PRODUTO%TYPE,
                           I_VL_UNITARIO IN PRODUTO.VL_UNITARIO%TYPE,
                           O_MENSAGEM       OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------                        
                           
  PROCEDURE GRAVA_VENDA(IO_CD_VENDA       IN OUT VENDA.CD_VENDA%TYPE,
                        I_CD_PRODUTO      IN PRODUTO.CD_PRODUTO%TYPE,
                        I_VL_UNITPROD     IN PRODUTO.VL_UNITARIO%TYPE,
                        I_VL_QTADQUIRIDA  IN VENDA.QT_ADQUIRIDA%TYPE,
                        I_NR_CPFCLIENTE   IN OUT CLIENTE.NR_CPF%TYPE,
                        I_DT_VENDA        IN OUT VENDA.DT_VENDA%TYPE,
                        O_MENSAGEM        OUT VARCHAR2);  
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
                                                                        
  PROCEDURE EXCLUIR_CLIENTE (I_NR_CPF   IN OUT CLIENTE.NR_CPF%TYPE,
                             O_MENSAGEM OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  
  PROCEDURE EXCLUI_PRODUTO (IO_CD_PRODUTO IN PRODUTO.CD_PRODUTO%TYPE,
                            O_MENSAGEM    OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_VENDA (I_CD_VENDA IN VENDA.CD_VENDA%TYPE,
                          O_MENSAGEM OUT VARCHAR2);                                                     
END PACK_PROJETO;
/
CREATE OR REPLACE PACKAGE BODY PACK_PROJETO IS
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE GRAVA_CLIENTES (I_NR_CPF         IN OUT CLIENTE.NR_CPF%TYPE,
                            I_NM_CLIENTE     IN CLIENTE.NM_CLIENTE%TYPE,
                            I_DT_NASCIMENTO  IN CLIENTE.DT_NASCIMENTO%TYPE,
                            O_MENSAGEM       OUT VARCHAR2) IS
                            E_GERAL EXCEPTION;
                           
  BEGIN
    IF I_NR_CPF IS NULL THEN
      O_MENSAGEM := 'O número do CPF/CNPJ precisa ser informado.';
      RAISE E_GERAL;
    END IF;
    
    IF LENGTH(I_NR_CPF) <> 11 THEN
      I_NR_CPF := REGEXP_REPLACE(I_NR_CPF, '[^0-9]', '');
               IF LENGTH(I_NR_CPF) <> 11 THEN
                  O_MENSAGEM := 'Digite um CPF válido';
                  RAISE E_GERAL;
               END IF;
    END IF;
    IF I_NM_CLIENTE IS NULL THEN
      O_MENSAGEM := 'O nome do cliente precisa ser informado.';
      RAISE E_GERAL;  
    END IF;
    IF I_DT_NASCIMENTO BETWEEN TRUNC(SYSDATE-14*365) AND TRUNC(SYSDATE) THEN
      O_MENSAGEM :='Só é possivel cadastrar pessoas maiores de 14 anos.';
      RAISE E_GERAL;
    END IF;
    IF I_DT_NASCIMENTO IS NULL THEN
      O_MENSAGEM := 'Insira uma data de nasicmento';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
       
              INSERT INTO CLIENTE(NR_CPF,
                           NM_CLIENTE,
                           DT_NASCIMENTO)
                    VALUES(I_NR_CPF,
                           I_NM_CLIENTE,
                           I_DT_NASCIMENTO);
                               
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          BEGIN  
            UPDATE CLIENTE
               SET NM_CLIENTE = I_NM_CLIENTE,
                   DT_NASCIMENTO = I_DT_NASCIMENTO
             WHERE NR_CPF = I_NR_CPF;
          EXCEPTION
            WHEN OTHERS THEN
              O_MENSAGEM :='Erro ao atualizar o cliente '||I_NM_CLIENTE||'. Erro: '||SQLERRM;
              RAISE E_GERAL;
          END;
    WHEN OTHERS THEN
      O_MENSAGEM := 'Erro ao inserir cliente '||I_NM_CLIENTE||'. Erro: '||SQLERRM;
      RAISE E_GERAL;
    END;
    
    COMMIT;
    
    EXCEPTION 
      WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_CLIENTES] '||O_MENSAGEM;
      WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_CLIENTES] Erro no procedimento que grava clientes: '||SQLERRM;                   
  END;
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE GRAVA_PRODUTO (IO_CD_PRODUTO IN OUT PRODUTO.CD_PRODUTO%TYPE,
                           I_DS_PRODUTO  IN PRODUTO.DS_PRODUTO%TYPE,
                           I_VL_UNITARIO IN PRODUTO.VL_UNITARIO%TYPE,
                           O_MENSAGEM       OUT VARCHAR2) IS
                           E_GERAL EXCEPTION;
                        
  BEGIN
    IF I_DS_PRODUTO IS NULL THEN
      O_MENSAGEM :='A descrição do produto não foi informada';
      RAISE E_GERAL;
    END IF;
    IF LENGTH(I_DS_PRODUTO) <= 2 THEN
      O_MENSAGEM := 'Descrição muito curta';
      RAISE E_GERAL;
    END IF;
    IF I_VL_UNITARIO <= 0 THEN
      O_MENSAGEM := 'Digite um valor válido';
      RAISE E_GERAL;
    END IF;
    IF I_VL_UNITARIO IS NULL THEN
      O_MENSAGEM := 'Valor inserido de forma incorreta';
      RAISE E_GERAL;
    END IF;
    IF IO_CD_PRODUTO IS NULL THEN
      BEGIN
        SELECT MAX(PRODUTO.CD_PRODUTO)
          INTO IO_CD_PRODUTO
          FROM PRODUTO;
      EXCEPTION
        WHEN OTHERS THEN
          IO_CD_PRODUTO := 0;
      END;
      IO_CD_PRODUTO := NVL(IO_CD_PRODUTO,0) + 1;
    END IF;
    
    BEGIN
      INSERT INTO PRODUTO(CD_PRODUTO,
                          DS_PRODUTO,
                          VL_UNITARIO)
                  VALUES (IO_CD_PRODUTO,
                          I_DS_PRODUTO,
                          I_VL_UNITARIO);       
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE PRODUTO
             SET DS_PRODUTO  = I_DS_PRODUTO,
                 VL_UNITARIO = I_VL_UNITARIO
           WHERE CD_PRODUTO  = IO_CD_PRODUTO;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'Erro ao atualizar produto '||IO_CD_PRODUTO||'. Erro: '||SQLERRM;
            RAISE E_GERAL;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao inserir produto '||IO_CD_PRODUTO||'. Erro: '||SQLERRM;
        RAISE E_GERAL;
    END;
    
    COMMIT;
        
  EXCEPTION 
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_PRODUTO] '||O_MENSAGEM;
      WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_PRODUTO] Erro no procedimento que grava clientes: '||SQLERRM;
  END;
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE GRAVA_VENDA(IO_CD_VENDA       IN OUT VENDA.CD_VENDA%TYPE,
                        I_CD_PRODUTO      IN PRODUTO.CD_PRODUTO%TYPE,
                        I_VL_UNITPROD     IN PRODUTO.VL_UNITARIO%TYPE,
                        I_VL_QTADQUIRIDA  IN VENDA.QT_ADQUIRIDA%TYPE,
                        I_NR_CPFCLIENTE   IN OUT CLIENTE.NR_CPF%TYPE,
                        I_DT_VENDA        IN OUT VENDA.DT_VENDA%TYPE,
                        O_MENSAGEM        OUT VARCHAR2) IS
                        E_GERAL           EXCEPTION;
                        V_COUNT           NUMBER;
  BEGIN
    IF LENGTH(I_NR_CPFCLIENTE) <> 11 THEN
      I_NR_CPFCLIENTE := REGEXP_REPLACE(I_NR_CPFCLIENTE, '[^0-9]', '');
               IF LENGTH(I_NR_CPFCLIENTE) <> 11 THEN
                  O_MENSAGEM := 'Digite um CPF válido';
                  RAISE E_GERAL;
               END IF;
    END IF;
    IF I_CD_PRODUTO IS NULL THEN
      O_MENSAGEM :='O Código do produto precisa ser informado';
      RAISE E_GERAL;
    END IF;
    
    IF I_NR_CPFCLIENTE IS NULL THEN
      O_MENSAGEM :='O CPF do cliente precisa ser informado';
      RAISE E_GERAL;
    END IF;
    IF I_DT_VENDA IS NULL THEN
      I_DT_VENDA := TRUNC(SYSDATE);
    END IF;
    IF I_VL_QTADQUIRIDA IS NULL THEN
      O_MENSAGEM :='A quantidade de produtos precisa ser informada';
      RAISE E_GERAL;
    END IF;
      
    BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM PRODUTO
       WHERE PRODUTO.CD_PRODUTO = I_CD_PRODUTO;
    EXCEPTION
      WHEN OTHERS THEN
      V_COUNT :=0;              
    END;
    IF NVL(V_COUNT,0) = 0 THEN
      O_MENSAGEM := 'O produto de código '||I_CD_PRODUTO||' não tem cadastro';
      RAISE E_GERAL;
    END IF;
    
        BEGIN
        SELECT COUNT (*)
          INTO V_COUNT
          FROM CLIENTE
         WHERE CLIENTE.NR_CPF = I_NR_CPFCLIENTE;
       
        EXCEPTION
          WHEN OTHERS THEN
            V_COUNT := 0;
        END;
    IF NVL(V_COUNT, 0) = 0 THEN
      O_MENSAGEM :='CPF: '||I_NR_CPFCLIENTE||' não cadastrado.';
      RAISE E_GERAL;
    END IF;
    IF IO_CD_VENDA IS NULL THEN
    BEGIN
      SELECT MAX (VENDA.CD_VENDA)
        INTO IO_CD_VENDA
        FROM VENDA;
    EXCEPTION
      WHEN OTHERS THEN
      IO_CD_VENDA := 0;
    END;
    
    IO_CD_VENDA :=NVL(IO_CD_VENDA, 0) + 1;
    END IF;
    BEGIN
        INSERT INTO
      VENDA(CD_VENDA,
            CD_PRODUTO,
            VL_UNITPROD,
            QT_ADQUIRIDA,
            NR_CPFCLIENTE,
            DT_VENDA)
     VALUES(IO_CD_VENDA,
            I_CD_PRODUTO,
            I_VL_UNITPROD,
            I_VL_QTADQUIRIDA,
            I_NR_CPFCLIENTE,
            I_DT_VENDA);
   
        
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE VENDA
             SET CD_PRODUTO = I_CD_PRODUTO,
                 VL_UNITPROD = I_VL_UNITPROD,
                 QT_ADQUIRIDA = I_VL_QTADQUIRIDA,
                 NR_CPFCLIENTE = I_NR_CPFCLIENTE,
                 DT_VENDA = I_DT_VENDA
           WHERE CD_VENDA = IO_CD_VENDA;
        EXCEPTION
          WHEN OTHERS THEN
          O_MENSAGEM := 'Erro ao atualizar venda: '||IO_CD_VENDA||' ERRO: '||SQLERRM;
          RAISE E_GERAL;
        END;
        
        
        END;  
          
        
        COMMIT;
      
    
    EXCEPTION
      WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_VENDA] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[GRAVA_VENDA] Erro no procedimento de cadastrar venda. Erro:'||SQLERRM;
  END;
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUIR_CLIENTE (I_NR_CPF   IN OUT CLIENTE.NR_CPF%TYPE,
                             O_MENSAGEM OUT VARCHAR2) IS
                             E_GERAL EXCEPTION;
                             V_COUNT NUMBER;
                             
                             
  BEGIN
    BEGIN
      BEGIN
        IF LENGTH(I_NR_CPF) <> 11 THEN
           I_NR_CPF := REGEXP_REPLACE(I_NR_CPF, '[^0-9]', '');
              IF LENGTH(I_NR_CPF) <> 11 THEN
                 O_MENSAGEM := 'Digite um CPF válido';
                 RAISE E_GERAL;
              END IF;
        END IF;
      EXCEPTION WHEN OTHERS THEN
        NULL;
        
      END;
      SELECT COUNT(*)
      INTO V_COUNT
      FROM VENDA
      WHERE VENDA.NR_CPFCLIENTE = I_NR_CPF;
    EXCEPTION 
      WHEN OTHERS THEN
      V_COUNT := 0;
    END;    
    IF V_COUNT > 0 THEN
    O_MENSAGEM := 'Cliente não pode ser excluído pois existe vendas em seu nome.';
    RAISE E_GERAL;
    END IF;
    BEGIN
      DELETE CLIENTE
      WHERE I_NR_CPF = CLIENTE.NR_CPF;
    EXCEPTION
      WHEN OTHERS THEN
        O_MENSAGEM :='Erro ao excluir cliente, Erro: '||SQLERRM;
        RAISE E_GERAL;
    END;
    COMMIT;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM :='[EXCLUIR_CLIENTE] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM :='[EXCLUIR_CLIENTE] Erro no procedimento de exluir cliente'||SQLERRM;
  END;
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  
  PROCEDURE EXCLUI_PRODUTO (IO_CD_PRODUTO IN PRODUTO.CD_PRODUTO%TYPE,
                            O_MENSAGEM    OUT VARCHAR2) IS
                            V_COUNT NUMBER;
                            E_GERAL EXCEPTION;
  BEGIN
    BEGIN
      SELECT COUNT(*)
      INTO V_COUNT
      FROM VENDA
      WHERE IO_CD_PRODUTO = VENDA.CD_PRODUTO;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
    END;
    IF V_COUNT > 0 THEN
    O_MENSAGEM := 'Produto não pode ser excluído pois existem vendas com seu código.';
    RAISE E_GERAL;
    END IF;
    BEGIN
      DELETE PRODUTO
      WHERE CD_PRODUTO = IO_CD_PRODUTO;
      
    EXCEPTION
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro ao deletar produto '|| IO_CD_PRODUTO||' Erro: '||SQLERRM;
        RAISE E_GERAL;
    END;
    COMMIT;
      
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM :='[EXCLUI_PRODUTO] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM :='[EXCLUI_PRODUTO] Erro no procedimento de excluir produto, Erro: '||SQLERRM;
  END;                           
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_VENDA (I_CD_VENDA IN VENDA.CD_VENDA%TYPE,
                          O_MENSAGEM OUT VARCHAR2) IS
                          E_GERAL    EXCEPTION;
  BEGIN
    BEGIN
      DELETE VENDA
        WHERE I_CD_VENDA = VENDA.CD_VENDA;
    EXCEPTION
      WHEN OTHERS THEN
        O_MENSAGEM :='Erro ao excluir venda';
        RAISE E_GERAL;
    END;
     COMMIT;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM:='[EXCLUI_VENDA] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM:='[EXCLUI_VENDA] Erro no procedimento de excluir venda, Erro: '||SQLERRM;
  END;                        
                             
END PACK_PROJETO;
/
