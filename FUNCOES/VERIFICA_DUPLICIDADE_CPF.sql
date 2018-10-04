USE [ADMIX_CORP]
GO

/****** Object:  UserDefinedFunction [dbo].[VERIFICA_DUPLICIDADE_CPF]    Script Date: 04/11/2014 11:20:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











-- VERIFICAR A DUPLICIDADE DO CPF
CREATE FUNCTION [dbo].[VERIFICA_DUPLICIDADE_CPF](@CPF VARCHAR(11), @ID_CARGA INT, @OPERADORA VARCHAR(3), @PRODUTO VARCHAR(3))
RETURNS BIT
AS
BEGIN
	DECLARE	@QUERY VARCHAR(255);
	DECLARE	@RETURN BIT;

	IF(ISNUMERIC(@CPF) = 1)
		IF(	
			SELECT COUNT(1)
			FROM DB_ADMIX_IN.dbo.ADMIX_MOV 
			WHERE ID_LOG_RECEPCAO = @ID_CARGA
			AND RIGHT('00' + TP_REGISTRO,2) = '01'
			AND FL_CONSISTENCIA IS NULL
			AND ISNUMERIC(CD_CPF) = 1
			AND RIGHT(REPLICATE('0',11) + LTRIM(RTRIM(CD_CPF)),11) = RIGHT(REPLICATE('0',11) + LTRIM(RTRIM(@CPF)),11)
			AND CD_OPERADORA_MOVIMENTACAO = @OPERADORA
			AND CD_PRODUTO = @PRODUTO
			GROUP BY CD_CPF
			HAVING COUNT(1) > 1
		) > 0
			SET @RETURN=0;
			ELSE 
				SET @RETURN=1;
		ELSE
			SET @RETURN=1;

	RETURN @RETURN;
END 


GO


