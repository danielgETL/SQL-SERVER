
USE [IMS_PREMIO]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_RETORNAHORAS]    Script Date: 7/29/2019 11:11:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[FN_RETORNAHORAS](@SEG INT)
RETURNS VARCHAR (10) 
AS
/*************************************************************************************************
 PROCEDURE FN_RETORNAHORAS
 AUTOR: 
 Data: 25/11/08
 DESCRI플O: FUN플O QUE TRANSFORMA UM VALOR DE SEGUNDOS EM HORAS (FORMATADA COMO 00:00h(s))
 ALTERADO POR: 
 DATA DA ALTERA플O: 
 ALTERA플O: 
**************************************************************************************************/
BEGIN 
    DECLARE @RESULT VARCHAR(10)
    SELECT @RESULT = CASE WHEN (@SEG/3600) >= 0 THEN 
                           RIGHT('0' + CAST(@SEG/3600 AS VARCHAR(3)), 
                                 CASE WHEN LEN(CAST(@SEG/3600 AS VARCHAR(3))) < 3 THEN 2 ELSE 3 END ) 
                          ELSE '00' END+ 'h '+
                     CASE WHEN (@SEG %3600/60) >= 0 THEN 
                           RIGHT('0' + CAST(@SEG %3600/60 AS VARCHAR(2)),2)
                          ELSE '00' END + 'min'
    RETURN(@RESULT)
END

