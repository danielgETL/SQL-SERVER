USE [portal_admix]
GO

/****** Object:  UserDefinedFunction [dbo].[FN_CALCULA_CLASSIFICACAO_IMC]    Script Date: 04/11/2014 11:25:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-------------------------------------
--CRIA FUNCAO CALCULA CLASSIFICACAO
-------------------------------------
CREATE FUNCTION [dbo].[FN_CALCULA_CLASSIFICACAO_IMC] 
(
	@VL_PESO DECIMAL(6,3),
	@VL_ALTURA DECIMAL(3,2)
)
RETURNS VARCHAR(50)
AS
BEGIN

	DECLARE @CLASSIFICACAO_IMC VARCHAR(100)

	SELECT @CLASSIFICACAO_IMC = 
	CASE
		WHEN CONVERT(DECIMAL(10,2),dbo.FN_CALCULA_IMC(@VL_PESO,@VL_ALTURA)) = CONVERT(DECIMAL(10,2),00.0) THEN ''
		WHEN CONVERT(DECIMAL(10,2),dbo.FN_CALCULA_IMC(@VL_PESO,@VL_ALTURA)) < CONVERT(DECIMAL(10,2),18.5) THEN 'Peso Abaixo'
		WHEN CONVERT(DECIMAL(10,2),dbo.FN_CALCULA_IMC(@VL_PESO,@VL_ALTURA)) >= CONVERT(DECIMAL(10,2),18.5) AND CONVERT(DECIMAL(10,2),dbo.FN_CALCULA_IMC(@VL_PESO,@VL_ALTURA)) < CONVERT(DECIMAL(10,2),25.0)  THEN 'Peso Normal'
		WHEN CONVERT(DECIMAL(10,2),dbo.FN_CALCULA_IMC(@VL_PESO,@VL_ALTURA)) >= CONVERT(DECIMAL(10,2),25.0) AND CONVERT(DECIMAL(10,2),dbo.FN_CALCULA_IMC(@VL_PESO,@VL_ALTURA)) < CONVERT(DECIMAL(10,2),30.0)  THEN 'Sobrepeso'
		WHEN CONVERT(DECIMAL(10,2),dbo.FN_CALCULA_IMC(@VL_PESO,@VL_ALTURA)) >= CONVERT(DECIMAL(10,2),30.0) AND CONVERT(DECIMAL(10,2),dbo.FN_CALCULA_IMC(@VL_PESO,@VL_ALTURA)) < CONVERT(DECIMAL(10,2),35.0)  THEN 'Obeso Classe I'
		WHEN CONVERT(DECIMAL(10,2),dbo.FN_CALCULA_IMC(@VL_PESO,@VL_ALTURA)) >= CONVERT(DECIMAL(10,2),35.0) AND CONVERT(DECIMAL(10,2),dbo.FN_CALCULA_IMC(@VL_PESO,@VL_ALTURA)) < CONVERT(DECIMAL(10,2),40.0)  THEN 'Obeso Classe II'
		WHEN CONVERT(DECIMAL(10,2),dbo.FN_CALCULA_IMC(@VL_PESO,@VL_ALTURA)) >= CONVERT(DECIMAL(10,2),40.0) AND CONVERT(DECIMAL(10,2),dbo.FN_CALCULA_IMC(@VL_PESO,@VL_ALTURA)) < CONVERT(DECIMAL(10,2),50.0)  THEN 'Obeso Classe III'
		WHEN CONVERT(DECIMAL(10,2),dbo.FN_CALCULA_IMC(@VL_PESO,@VL_ALTURA)) > CONVERT(DECIMAL(10,2),50.0) THEN 'Obeso Classe IV'
	END
	RETURN @CLASSIFICACAO_IMC

END


GO

