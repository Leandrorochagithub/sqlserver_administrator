-- =====================================================
-- TESTE 1: Usuário ETL pode inserir dados
-- =====================================================
EXECUTE AS USER = 'app_etl_crypto';
GO

BEGIN TRY
    INSERT INTO dbo.coins (ID, symbol, name)
    VALUES (1000, 'TEST', 'TESTE');
    
    PRINT 'SUCESSO: app_etl_crypto pode inserir dados';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
END CATCH

REVERT;  -- Voltar ao usuário original
GO

-- =====================================================
-- TESTE 2: Usuário ETL NÃO pode deletar dados
-- =====================================================
EXECUTE AS USER = 'app_etl_crypto';
GO

BEGIN TRY
    DELETE FROM dbo.coins WHERE symbol = 'TEST';
    PRINT 'FALHA NA SEGURANÇA: DELETE não deveria ser permitido!';
END TRY
BEGIN CATCH
    PRINT 'SUCESSO: DELETE bloqueado corretamente';
    PRINT '   Mensagem: ' + ERROR_MESSAGE();
END CATCH

REVERT;
GO

-- =====================================================
-- TESTE 3: Usuário READ-ONLY não pode modificar dados
-- =====================================================
EXECUTE AS USER = 'usr_crypto_ro';
GO

BEGIN TRY
    UPDATE dbo.coins SET id = 999 WHERE symbol = 'TEST';
    PRINT 'FALHA NA SEGURANÇA: UPDATE não deveria ser permitido!';
END TRY
BEGIN CATCH
    PRINT 'SUCESSO: UPDATE bloqueado para usuário READ-ONLY';
END CATCH

REVERT;
GO