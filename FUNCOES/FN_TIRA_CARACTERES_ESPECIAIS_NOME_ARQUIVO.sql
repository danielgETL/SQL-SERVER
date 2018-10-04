USE [ADMIX_CORP]
GO

/****** Object:  UserDefinedFunction [dbo].[FN_TIRA_CARACTERES_ESPECIAIS_NOME_ARQUIVO]    Script Date: 04/11/2014 11:13:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[FN_TIRA_CARACTERES_ESPECIAIS_NOME_ARQUIVO](@NM_ARQUIVO VARCHAR(1000))
RETURNS VARCHAR(255)
AS
BEGIN
	DECLARE @RESULTADO VARCHAR(1000);
	DECLARE @ARQUIVO VARCHAR(1000);
	DECLARE @EXTENSAO VARCHAR(10);
	DECLARE @TAMANHO INT;
	DECLARE @POSICAO INT;
	DECLARE @INDEX INT;
	DECLARE @LETRA_NOME VARCHAR(1);
	DECLARE @CARACTERES_ESPECIAIS VARCHAR(1000);
	DECLARE @LETRA VARCHAR(1);
	DECLARE @LETRA_C VARCHAR(1);
	DECLARE @CARACTERES_ESPECIAIS_C VARCHAR(1000);

	SET @ARQUIVO = UPPER(LTRIM(RTRIM(@NM_ARQUIVO)))
	SET @EXTENSAO = REVERSE(LEFT(REVERSE(@ARQUIVO),CHARINDEX('.',REVERSE(@ARQUIVO),0)))
	SET @ARQUIVO = REVERSE(SUBSTRING(REVERSE(@ARQUIVO), (CHARINDEX('.',REVERSE(@ARQUIVO),0)+1), (LEN(@ARQUIVO)) ) )
	

	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--REMOVER CARACTERES ESPECIAIS--------------------------------------------------------------------------------------------------------------------------------------
	SET @CARACTERES_ESPECIAIS   = '!#$%®&*()-?:{}][ƒ≈¡¬¿√‰·‚‡„… À»ÈÍÎËÕŒœÃÌÓÔÏ÷”‘“’ˆÛÙÚı⁄Ÿ€‹¸˙˚˘«Á;,*".+=¥`~^|:/<>-_@';
	SET @CARACTERES_ESPECIAIS_C = '                AAAAAAaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUUuuuuCc                   ';
	SET @TAMANHO = LEN(@CARACTERES_ESPECIAIS);
	SET @POSICAO = 1;
	SET @RESULTADO = @ARQUIVO
	
	WHILE @POSICAO <= @TAMANHO
		BEGIN
			IF(CHARINDEX(SUBSTRING(@CARACTERES_ESPECIAIS,@POSICAO,1),@RESULTADO,1)) <> 0
				BEGIN
					SET @LETRA   = SUBSTRING(@CARACTERES_ESPECIAIS  ,@POSICAO,1);
					SET @LETRA_C = SUBSTRING(@CARACTERES_ESPECIAIS_C,@POSICAO,1);
					--SET @RESULTADO = 0;
					SET @RESULTADO = REPLACE(@RESULTADO,@LETRA,@LETRA_C);
					SET @RESULTADO = REPLACE(@RESULTADO,'  ', ' ');
					SET @RESULTADO = REPLACE(@RESULTADO,'  ', ' ');
					--BREAK; 
				END
			SET @POSICAO = @POSICAO + 1;
		END
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--REMOVER ESPACOS DUPLOS--------------------------------------------------------------------------------------------------------------------------------------------
	WHILE CHARINDEX('  ',@RESULTADO,0) > 0
		BEGIN
			SET @RESULTADO = REPLACE(@RESULTADO, '  ', ' ')
		END
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--SUBSTITUIR OS ESPACOS---------------------------------------------------------------------------------------------------------------------------------------------
	WHILE CHARINDEX(' ',@RESULTADO,0) > 0
		BEGIN
			SET @RESULTADO = REPLACE(@RESULTADO, ' ', '_')
		END
	
	RETURN @RESULTADO + @EXTENSAO

END


GO


