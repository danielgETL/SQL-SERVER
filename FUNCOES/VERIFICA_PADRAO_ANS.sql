USE [ADMIX_CORP]
GO

/****** Object:  UserDefinedFunction [dbo].[VERIFICA_PADRAO_ANS]    Script Date: 04/11/2014 11:23:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





--select [dbo].[VERIFICA_PADRAO_ANS] ('aaAGNESSSE MENEGHETTI POSTIGHER')

-- VERIFICAR A DUPLICIDADE DO CPF
CREATE FUNCTION [dbo].[VERIFICA_PADRAO_ANS](@NM_SEGURADO VARCHAR(255))
RETURNS BIT
AS
BEGIN
	DECLARE @RESULTADO BIT;
	DECLARE @NOME VARCHAR(255);
	DECLARE @TAMANHO INT;
	DECLARE @POSICAO INT;
	DECLARE @INDEX INT;
	DECLARE @LETRA_NOME VARCHAR(1);
	DECLARE @CARACTERES_ESPECIAIS VARCHAR(255);

	SET @NOME = LTRIM(RTRIM(@NM_SEGURADO))

	--NOME N�O PODE SER �NICO
	SET @RESULTADO = 1
	IF(CHARINDEX(' ',@NOME,1)) = 0
		SET @RESULTADO = 0;

	--N�O PODE CONTER N�MEROS
	SET @TAMANHO = LEN(@NOME);
	SET @POSICAO = 1;
	WHILE @POSICAO <= @TAMANHO
		BEGIN
			IF ISNUMERIC(SUBSTRING(@NOME,@POSICAO,1)) = 1
				SET @RESULTADO = 0;
			SET @POSICAO = @POSICAO + 1;
		END
	
	--N�O PERMITIR PRIMEIRO NOME ABREVIADO PARA LETRAS DIFERENTES DE D, I, O, U E Y
	IF(CHARINDEX(' ',@NOME,1) = 2)
		IF	LEFT(LEFT(@NOME,CHARINDEX(' ',@NOME,1) - 1),1) <> 'D'
			AND LEFT(LEFT(@NOME,CHARINDEX(' ',@NOME,1) - 1),1) <> 'I'
			AND LEFT(LEFT(@NOME,CHARINDEX(' ',@NOME,1) - 1),1) <> 'O'
			AND LEFT(LEFT(@NOME,CHARINDEX(' ',@NOME,1) - 1),1) <> 'U'
			AND LEFT(LEFT(@NOME,CHARINDEX(' ',@NOME,1) - 1),1) <> 'Y'
			SET @RESULTADO = 0;

	--N�O PERMITIR �LTIMO SOBRENOME NOME ABREVIADO PARA LETRAS DIFERENTES DE D, I, O, U E Y
	IF(CHARINDEX(' ',REVERSE(@NOME),1) = 2)
		BEGIN
			IF	LEFT(RIGHT(@NOME,CHARINDEX(' ',REVERSE(@NOME),1)-1),1) <> 'D'
				AND LEFT(RIGHT(@NOME,CHARINDEX(' ',REVERSE(@NOME),1)-1),1) <> 'I'
				AND LEFT(RIGHT(@NOME,CHARINDEX(' ',REVERSE(@NOME),1)-1),1) <> 'O'
				AND LEFT(RIGHT(@NOME,CHARINDEX(' ',REVERSE(@NOME),1)-1),1) <> 'U'
				AND LEFT(RIGHT(@NOME,CHARINDEX(' ',REVERSE(@NOME),1)-1),1) <> 'Y'
				SET @RESULTADO = 0;
		END
	
	--N�O PERMITIR ESPA�OS DUPLOS ENTRE OS NOMES E SOBRENOMES
	SET @TAMANHO = LEN(@NOME);
	SET @POSICAO = 1;
	SET @INDEX = 0;
	WHILE @POSICAO <= @TAMANHO
		BEGIN
			IF(CHARINDEX(' ',SUBSTRING(@NOME,@POSICAO,1),1)) = 1
				BEGIN
					SET @INDEX = @INDEX + 1;
					IF @INDEX > 1
						BEGIN
							SET @RESULTADO = 0
							BREAK;
						END
				END
				ELSE
					SET @INDEX = 0;
			SET @POSICAO = @POSICAO + 1;
		END


	--N�O PERMITIR QUE O NOME POSSUA AS 3 PRIMEIRAS POSI��ES IGUAIS EX: XXX
		--ALTERADO PARA QUE VERIFIQUE O NOME POR INTEIRO - DATA DA ALTERA��O 19/05/2010
	SET @TAMANHO = LEN(@NOME);
	SET @POSICAO = 1;
	SET @INDEX = 1;
	SET @LETRA_NOME = SUBSTRING(@NOME,@POSICAO,1);
	SET @POSICAO = @POSICAO + 1;

--	WHILE @POSICAO <= 3
--		BEGIN
--			IF(@LETRA_NOME = SUBSTRING(@NOME,@POSICAO,1))
--				SET @INDEX = @INDEX + 1;
--				ELSE
--					BEGIN
--						SET @INDEX = 1;
--						SET @LETRA_NOME = SUBSTRING(@NOME,@POSICAO,1);
--					END
--
--			IF @INDEX > 2
--				BEGIN
--					SET @RESULTADO = 0;
--					BREAK;
--				END
--
--			SET @POSICAO = @POSICAO + 1;
--		END

	WHILE @POSICAO <= @TAMANHO
		BEGIN
			IF(@LETRA_NOME = SUBSTRING(@NOME,@POSICAO,1))
				SET @INDEX = @INDEX + 1;
				ELSE
					BEGIN
						SET @INDEX = 1;
						SET @LETRA_NOME = SUBSTRING(@NOME,@POSICAO,1);
					END

			IF @INDEX > 2
				BEGIN
					SET @RESULTADO = 0;
					BREAK;
				END

			SET @POSICAO = @POSICAO + 1;
		END

	--N�O PERMITIR CARACTERES ESPECIAIS
	SET @CARACTERES_ESPECIAIS = '!#$%�&*()-?:{}][�����������������������������������������������;,*".+=�`~^|:/<>-_@��';
	SET @TAMANHO = LEN(@CARACTERES_ESPECIAIS);
	SET @POSICAO = 1;
	WHILE @POSICAO <= @TAMANHO
		BEGIN
			IF(CHARINDEX(SUBSTRING(@CARACTERES_ESPECIAIS,@POSICAO,1),@NOME,1)) <> 0
				BEGIN
					SET @RESULTADO = 0;
					BREAK;
				END
			SET @POSICAO = @POSICAO + 1;
		END
		
	--NOME DE EXCE��O
	IF(@NOME IN ('NAO INFORMADO', 'NAO DECLARADO'))
		BEGIN
			SET @RESULTADO = 0;
		END
/*		
	IF CONVERT(DATETIME,'20111007') <= GETDATE()
		BEGIN
			--N�O PERMITIR NOME ABREVIADO
			IF dbo.[VERIFICA_NOME_ABREVIADO](@NM_SEGURADO) = 0
				BEGIN
					SET @RESULTADO = 0;
				END
		END
*/
	RETURN @RESULTADO
END

/*
SELECT dbo.VERIFICA_PADRAO_ANS('NAO INFORMADO')

*/







GO


