USE [ADMIX_CORP]
GO

/****** Object:  UserDefinedFunction [dbo].[VERIFICA_CPF]    Script Date: 04/11/2014 11:14:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[VERIFICA_CPF](@CPF VARCHAR(50))
RETURNS VARCHAR(50)
AS
BEGIN
  DECLARE @INDICE INT,
          @SOMA INT,
          @DIG1 INT,
          @DIG2 INT,
          @CPF_TEMP VARCHAR(11),
          @DIGITOS_IGUAIS CHAR(1),
          @RESULTADO VARCHAR(11)

	IF(@CPF <> '00000000000')
	BEGIN
		  SET @CPF = LTRIM(RTRIM(UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@CPF,'.','')
			,'E','')
			,'.','')
			,',','')
			,'#','')
			,'-','')
			,'*','')
			,'+','')
			,'/','')
			,'\','')
			,';','')
			,'?','')
			,'$','')
			,')','')
			,'(','')
			,'@','')
			,'=','')
			,'!','')
		)))

		   IF LEN(@CPF) > 11
			  RETURN NULL;

		   IF ISNUMERIC(@CPF)=0
			  RETURN NULL;

		  SET @CPF = RIGHT('00000000000' + @CPF,11)

		  SET @RESULTADO = NULL

		  SET @CPF_TEMP = SUBSTRING(@CPF,1,1)

		  SET @INDICE = 1
		  SET @DIGITOS_IGUAIS = 'S'

		  WHILE (@INDICE <= 11)
		  BEGIN
			IF SUBSTRING(@CPF,@INDICE,1) <> @CPF_TEMP
			  SET @DIGITOS_IGUAIS = 'N'
			SET @INDICE = @INDICE + 1
		  END;

		  --Caso os digitos não sejão todos iguais Começo o calculo do digitos
		  IF @DIGITOS_IGUAIS = 'N' 
		  BEGIN
			--Cálculo do 1º dígito
			SET @SOMA = 0
			SET @INDICE = 1
			WHILE (@INDICE <= 9)
			BEGIN
			  SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@CPF,@INDICE,1)) * (11 - @INDICE);
			  SET @INDICE = @INDICE + 1
			END

			SET @DIG1 = 11 - (@SOMA % 11)

			IF @DIG1 > 9
			  SET @DIG1 = 0;

			-- Cálculo do 2º dígito }
			SET @SOMA = 0
			SET @INDICE = 1
			WHILE (@INDICE <= 10)
			BEGIN
			  SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@CPF,@INDICE,1)) * (12 - @INDICE);
			  SET @INDICE = @INDICE + 1
			END

			SET @DIG2 = 11 - (@SOMA % 11)

			IF @DIG2 > 9
			  SET @DIG2 = 0;

			-- Validando
			IF (@DIG1 = SUBSTRING(@CPF,LEN(@CPF)-1,1)) AND (@DIG2 = SUBSTRING(@CPF,LEN(@CPF),1))
			  SET @RESULTADO = @CPF
			ELSE
				SET @RESULTADO = NULL
		  END
	END
	ELSE
		SET @RESULTADO = @CPF
  RETURN @RESULTADO
END 

/*
SELECT dbo.[VERIFICA_CPF]('00000000000')
*/
GO


