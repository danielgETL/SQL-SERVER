USE [DB_ADMIX_IN]
GO

/****** Object:  UserDefinedFunction [dbo].[FN_GET_DATE_STRING]    Script Date: 04/11/2014 11:09:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FN_GET_DATE_STRING](
	@DATA VARCHAR(15)
	, @FORMATO_ENTRADA VARCHAR(10)
	, @FORMATO_SAIDA VARCHAR(10)
)
RETURNS VARCHAR(10)
AS
BEGIN
/*
--------------------------------------------------------------------------------------------------
-- TESTE -----------------------------------------------------------------------------------------
DECLARE @DATA VARCHAR(15)
DECLARE @FORMATO_ENTRADA VARCHAR(10)
DECLARE @FORMATO_SAIDA VARCHAR(10)

--SET @DATA = '13/04/2013'
--SET @FORMATO_ENTRADA = 'DD/MM/YYYY'

--SET @DATA = '2013-04-20'
--SET @FORMATO_ENTRADA = 'YYYY-MM-DD'

--SET @FORMATO_SAIDA = 'YYYYMMDD'
*/

DECLARE	@RESULTADO VARCHAR(8000)
SET @RESULTADO = ''

IF LTRIM(RTRIM(ISNULL(@DATA,''))) <> '' AND CHARINDEX('/',@DATA,0) > 0 AND CHARINDEX('/',@DATA,CHARINDEX('/',@DATA,0) + 1) > 0

BEGIN
	--------------------------------------------------------------------------------------------------
	-- 'DD/MM/YYYY' ----------------------------------------------------------------------------------
	IF (@FORMATO_ENTRADA = 'DD/MM/YYYY' AND @FORMATO_SAIDA = 'YYYYMMDD')
		BEGIN
			SET @RESULTADO =  SUBSTRING(@DATA, CHARINDEX('/',@DATA,CHARINDEX('/',@DATA,0) + 1) + 1, 4) --ANO
								+ RIGHT('00' + SUBSTRING(@DATA, CHARINDEX('/',@DATA,0) + 1, (CHARINDEX('/',@DATA,CHARINDEX('/',@DATA,0) + 1) - CHARINDEX('/',@DATA,0))-1),2) --MES
								+ RIGHT('00' + LEFT(@DATA, CHARINDEX('/', @DATA, 0) -1),2) --DIA
		END
	--------------------------------------------------------------------------------------------------
	-- 'YYYY-MM-DD' ----------------------------------------------------------------------------------
	IF (@FORMATO_ENTRADA = 'YYYY-MM-DD' AND @FORMATO_SAIDA = 'YYYYMMDD')
		BEGIN
			SET @RESULTADO =  LEFT(@DATA,4) --ANO
								+ RIGHT('00' + SUBSTRING(@DATA, CHARINDEX('-',@DATA,0) + 1, (CHARINDEX('-',@DATA,CHARINDEX('-',@DATA,0) + 1) - CHARINDEX('-',@DATA,0))-1),2) 
								+ RIGHT('00' + REVERSE(LEFT(REVERSE(@DATA), CHARINDEX('-',REVERSE(@DATA),0) -1)),2) --DIA
		END

	
END
ELSE
	BEGIN
		IF LTRIM(RTRIM(ISNULL(@DATA,''))) <> '' AND LEN(@DATA) = 8
			--------------------------------------------------------------------------------------------------
			-- 'DDMMYYYY' ------------------------------------------------------------------------------------
			IF (@FORMATO_ENTRADA = 'DDMMYYYY' AND @FORMATO_SAIDA = 'YYYYMMDD')
				BEGIN
					SET @RESULTADO = RIGHT(@DATA, 4) + SUBSTRING(@DATA,3,2) + LEFT(@DATA,2)
				END
	END
	

IF ISDATE(@RESULTADO) = 1
	BEGIN 
		SET @RESULTADO = @RESULTADO
	END
ELSE
	BEGIN 
		SET @RESULTADO = NULL
	END	
	
RETURN @RESULTADO
--SELECT @RESULTADO

END
GO


