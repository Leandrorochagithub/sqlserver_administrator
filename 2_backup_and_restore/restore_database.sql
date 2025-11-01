USE master;
GO

-- Restaura o banco de dados a partir do backup.
RESTORE DATABASE [CryptoDB]
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXCHANGERATE\MSSQL\Backup\crypto_db\Database\CryptoDB_Full_2025-09-19-145031.bak'
WITH
    REPLACE, -- Força a restauração sobre o banco de dados existente.
    RECOVERY;-- Deixa o banco de dados pronto para uso após a restauração.
GO

PRINT 'Restauração do CryptoDB concluída com sucesso!';
PRINT 'CryptoDB restore completed successfully!';