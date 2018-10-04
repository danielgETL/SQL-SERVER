USE [ADMIX_CORP]
GO

/****** Object:  UserDefinedFunction [dbo].[FN_VALIDA_DNV]    Script Date: 04/11/2014 11:13:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FN_VALIDA_DNV](@CD_DNV VARCHAR(11)) 
RETURNS BIT
AS 
BEGIN 
DECLARE @vOrigemDNV VARCHAR(11)
DECLARE @vDNV VARCHAR(11)
DECLARE @vDNV_10 VARCHAR(11)
DECLARE @vResultadoDNV VARCHAR(11)
DECLARE @vResto int
DECLARE @vSoma int
DECLARE @vDigito int
DECLARE @vValidado BIT


--SELECT dbo.FN_VALIDA_DNV ('NASCIDO VIVO INVALIDO')

-------------------------------------------------------------------------------------------------------
-- VALIDAR --------------------------------------------------------------------------------------------
IF ISNUMERIC(@CD_DNV) = 1
	BEGIN
		SET @vOrigemDNV = @CD_DNV
		SET @vDNV = RIGHT(REPLICATE('0',11) + LTRIM(RTRIM(@vOrigemDNV)),11)
		SET @vDNV_10 = LEFT(@vDNV,10)


		/*
		PESO - 3 2 9 8 7 6 5 4 3 2
		*/
		SET @vSoma =	(SUBSTRING(@vDNV_10,1,1) * 3)
						+ (SUBSTRING(@vDNV_10,2,1) * 2)
						+ (SUBSTRING(@vDNV_10,3,1) * 9)
						+ (SUBSTRING(@vDNV_10,4,1) * 8)
						+ (SUBSTRING(@vDNV_10,5,1) * 7)
						+ (SUBSTRING(@vDNV_10,6,1) * 6)
						+ (SUBSTRING(@vDNV_10,7,1) * 5)
						+ (SUBSTRING(@vDNV_10,8,1) * 4)
						+ (SUBSTRING(@vDNV_10,9,1) * 3)
						+ (SUBSTRING(@vDNV_10,10,1) * 2)
		SET @vResto = @vSoma%11	

		SET @vResto = CASE 
						WHEN @vSoma%11 = 10 OR @vSoma%11 = 11 THEN 0
						ELSE @vSoma%11
						END	
						
		SET @vDigito = CASE 
						 WHEN @vResto IN (0,1) THEN 0
						 ELSE 11-@vResto
						 END
						

		SET @vResultadoDNV = CONVERT(VARCHAR,@vDNV_10) + CONVERT(VARCHAR, @vDigito)

		IF @vDNV = @vResultadoDNV
			SET @vValidado = 1
			ELSE
				SET @vValidado = 0
	END
	ELSE
		SET @vValidado = 0
	
SET @vValidado = 1

RETURN @vValidado 
END 

GO


