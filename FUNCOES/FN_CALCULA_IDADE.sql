USE [DB_ADMIX_IN]
GO

/****** Object:  UserDefinedFunction [dbo].[FN_CALCULA_IDADE]    Script Date: 04/11/2014 11:07:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[FN_CALCULA_IDADE] (
    @DataNascimento DateTime,
    @DataParametro DateTime
)
RETURNS int
AS
BEGIN
    DECLARE @Result int;

    SELECT @Result = datediff(yy, @DataNascimento, @DataParametro) -
        (case WHEN (datepart(m, @DataNascimento) > datepart(m, @DataParametro)) OR
            (datepart(m, @DataNascimento) = datepart(m, @DataParametro) AND
                datepart(d, @DataNascimento) > datepart(d, @DataParametro))
            THEN 1
            ELSE 0
        end) 
    RETURN @Result 
END

GO


