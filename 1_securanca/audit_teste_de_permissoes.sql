-- =====================================================
-- TESTE 1: Usu�rio ETL pode inserir dados
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

REVERT;  -- Voltar ao usu�rio original
GO

-- =====================================================
-- TESTE 2: Usu�rio ETL N�O pode deletar dados
-- =====================================================
EXECUTE AS USER = 'app_etl_crypto';
GO

BEGIN TRY
    DELETE FROM dbo.coins WHERE symbol = 'TEST';
    PRINT 'FALHA NA SEGURAN�A: DELETE n�o deveria ser permitido!';
END TRY
BEGIN CATCH
    PRINT 'SUCESSO: DELETE bloqueado corretamente';
    PRINT '   Mensagem: ' + ERROR_MESSAGE();
END CATCH

REVERT;
GO

-- =====================================================
-- TESTE 3: Usu�rio READ-ONLY n�o pode modificar dados
-- =====================================================
EXECUTE AS USER = 'usr_crypto_ro';
GO

BEGIN TRY
    UPDATE dbo.coins SET id = 999 WHERE symbol = 'TEST';
    PRINT 'FALHA NA SEGURAN�A: UPDATE n�o deveria ser permitido!';
END TRY
BEGIN CATCH
    PRINT 'SUCESSO: UPDATE bloqueado para usu�rio READ-ONLY';
END CATCH

REVERT;
GO