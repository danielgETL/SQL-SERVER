USE [DB_ADMIX_IN]
GO

/****** Object:  UserDefinedFunction [dbo].[FN_VERIFICA_STRING_INTEIRO]    Script Date: 04/11/2014 11:11:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[FN_VERIFICA_STRING_INTEIRO] 
(
    @NR_NUMERO VARCHAR(1000)
)
RETURNS BIT
AS
BEGIN
	--------------------------------------------------------------------------------------------------------------------------------
	-- DECLARA VARIAVEIS -----------------------------------------------------------------------------------------------------------
	DECLARE @QT_CARACTERES INT
	DECLARE @NR_POSICAO_ATUAL INT
	DECLARE @FL_NUMERO BIT

	--------------------------------------------------------------------------------------------------------------------------------
	-- SETA VARIAVEIS --------------------------------------------------------------------------------------------------------------
	SET @QT_CARACTERES = LEN(@NR_NUMERO)
	SET @FL_NUMERO = 1
	SET @NR_POSICAO_ATUAL = 1

	--------------------------------------------------------------------------------------------------------------------------------
	-- VERIFICAR SE O VALOR É UM NÚMERO INTEIRO ------------------------------------------------------------------------------------
	WHILE @NR_POSICAO_ATUAL <= @QT_CARACTERES AND @FL_NUMERO = 1
	BEGIN
		IF SUBSTRING(@NR_NUMERO,@NR_POSICAO_ATUAL,1) LIKE '[0-9]' 
			BEGIN
				SET @NR_POSICAO_ATUAL = @NR_POSICAO_ATUAL + 1
			END
		ELSE
			BEGIN
				SET @FL_NUMERO = 0
			END
	END

	RETURN @FL_NUMERO
END

GO


