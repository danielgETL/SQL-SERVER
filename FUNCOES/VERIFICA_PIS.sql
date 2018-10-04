USE [ADMIX_CORP]
GO

/****** Object:  UserDefinedFunction [dbo].[VERIFICA_PIS]    Script Date: 04/11/2014 11:24:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[VERIFICA_PIS](@PIS VARCHAR(50))
RETURNS VARCHAR(50)
AS
BEGIN
  DECLARE @INDICE INT,
          @SOMA INT,
          @DIG INT,
          --@DIG2 INT,
          @PIS_TEMP VARCHAR(11),
          @DIGITOS_IGUAIS CHAR(1),
          @RESULTADO VARCHAR(11),
		  @FTAP VARCHAR(10),
		  @RESTO INT

          
  SET @PIS = LTRIM(RTRIM(UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@PIS,'.','')
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

   IF LEN(@PIS) > 11
      RETURN NULL;

   IF ISNUMERIC(@PIS)=0
      RETURN NULL;

  SET @PIS = RIGHT('00000000000' + @PIS,11)

  SET @RESULTADO = NULL

  SET @PIS_TEMP = SUBSTRING(@PIS,1,1)

  SET @INDICE = 1
  SET @DIGITOS_IGUAIS = 'S'

  WHILE (@INDICE <= 11)
  BEGIN
    IF SUBSTRING(@PIS,@INDICE,1) <> @PIS_TEMP
      SET @DIGITOS_IGUAIS = 'N'
    SET @INDICE = @INDICE + 1
  END;

  --Caso os digitos não sejão todos iguais Começo o calculo do digitos
  IF @DIGITOS_IGUAIS = 'N' 
  BEGIN
    --Cálculo do 1º dígito
	SET @FTAP = '3298765432'
    SET @SOMA = 0
    SET @INDICE = 1
    WHILE (@INDICE <= 10)
    BEGIN
      SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@PIS,@INDICE,1)) * CONVERT(INT,SUBSTRING(@FTAP,@INDICE,1));
      SET @INDICE = @INDICE + 1
    END

	SET @RESTO = CONVERT(INT, @Soma % 11)

	IF @RESTO <> 0
	   SET @RESTO = 11 - @RESTO;

	SET @DIG = CONVERT(INT,SUBSTRING(@PIS,11,1))
	IF @RESTO <> @DIG
	   SET @RESULTADO = NULL;
	   ELSE
		  SET @RESULTADO = @PIS;

  END
  RETURN @RESULTADO
END 




GO


