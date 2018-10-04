USE [ADMIX_CORP]
GO

/****** Object:  UserDefinedFunction [dbo].[VERIFICA_CPF_MAIOR_16]    Script Date: 04/11/2014 11:18:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- VERIFICAR A DUPLICIDADE DO CPF
CREATE FUNCTION [dbo].[VERIFICA_CPF_MAIOR_16](@DT_NASCIMENTO VARCHAR(255), @CPF VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @RESULTADO BIT;
	
	IF(CONVERT(DATETIME,'20111001') <= GETDATE())
		BEGIN
			IF(ltrim(rtrim(@CPF)) = '' OR REPLICATE('0',11-LEN(ltrim(rtrim(@CPF))))+ltrim(rtrim(@CPF)) = '00000000000') 
				SET @CPF = '0'
			ELSE
				SET @CPF = @CPF
			IF(
				CASE WHEN ROUND( DATEDIFF( MONTH, @DT_NASCIMENTO, GETDATE()) / 12,0) >= 0
				AND ROUND( DATEDIFF( MONTH, @DT_NASCIMENTO, GETDATE()) / 12,0) <= 151
				 THEN ROUND( DATEDIFF( MONTH, @DT_NASCIMENTO, GETDATE()) / 12,0)
				 ELSE 
					CASE WHEN ROUND( DATEDIFF( MONTH, @DT_NASCIMENTO, GETDATE()) / 12,0) < 0
						THEN -1
						ELSE 151 
					END
				END) = 17
				IF( @CPF ) = '0'
					SET @RESULTADO = 0
				ELSE
					SET @RESULTADO = 1
			ELSE
				SET @RESULTADO = 1
		END
		ELSE
			SET @RESULTADO = 1
		
	RETURN @RESULTADO
END


GO


