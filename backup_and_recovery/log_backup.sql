-- PERSONALIZANDO NOME DO ARQUIVO DE BACKUP

USE master;
GO

DECLARE @DatabaseName NVARCHAR(128) = 'CryptoDB';
DECLARE @BackupType NVARCHAR(50) = 'Log';
DECLARE @BackupPath NVARCHAR(256) = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXCHANGERATE\MSSQL\Backup\crypto_db\Log\';
DECLARE @DateTimeString NVARCHAR(50) = FORMAT(GETDATE(), 'yyyy-MM-dd-HHmmss');
DECLARE @BackupFileName NVARCHAR(256)= @DatabaseName + '_' + @BackupType + '_' + @DateTimeString + '.trn';


-- Definir o caminho do backup
SET @BackupPath =  @BackupPath + @BackupFileName;

-- Executar o backup
BACKUP LOG @DatabaseName
TO DISK = @BackupPath
WITH COMPRESSION, -- Compressão para reduzir tamanho
CHECKSUM,   -- Verifica a integridade dos dados antes do backup.
STATS = 25;


PRINT @DatabaseName + ' Backup ' + @BackupType + ' criado com sucesso em: ' + @BackupPath;
PRINT @BackupType + @DatabaseName + ' backup' + ' created successfully on: ' + @BackupPath

