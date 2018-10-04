USE [portal_admix]
GO

/****** Object:  UserDefinedFunction [dbo].[FN_CALCULA_IMC]    Script Date: 04/11/2014 11:26:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Script Template
-- =============================================
-- CRIA FUNÇAO PARA CALCULAR IMC
CREATE FUNCTION [dbo].[FN_CALCULA_IMC] 
(
	@VL_PESO DECIMAL(6,3),
	@VL_ALTURA DECIMAL(3,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN

	DECLARE @IMC DECIMAL(10,2);

		SELECT @IMC = CASE WHEN @VL_ALTURA <> 0.00 THEN 
			CONVERT(DECIMAL(10,2), @VL_PESO / (@VL_ALTURA * @VL_ALTURA))
		ELSE 
			CONVERT(DECIMAL(10,2),0)
	END
	RETURN @IMC

END


GO


