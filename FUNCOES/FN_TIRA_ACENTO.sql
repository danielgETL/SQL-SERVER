USE [DB_ADMIX_IN]
GO

/****** Object:  UserDefinedFunction [dbo].[FN_TIRA_ACENTO]    Script Date: 04/11/2014 11:10:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--SELECT [dbo].[FN_PORTALADMIX_TIRA_ACENTO]('DAKSD º')

CREATE FUNCTION [dbo].[FN_TIRA_ACENTO](@pStr varchar(2000))
Returns varchar(2000)
as
Begin 
	Declare @Retorno varchar(2000);
	Set @pStr = replace(@pStr,'´',' ');
	Set @pStr = replace(@pStr,CHAR(149),' ');
	Set @pStr = replace(@pStr,'º',' ');
	
	Set @Retorno = @pStr collate sql_latin1_general_cp1251_cs_as --SQL_Latin1_General_CP437_CI_AS  -- ESTE COLLATE NAO RETIRA º : - > sql_latin1_general_cp1251_cs_as;
	Set @Retorno = replace ( replace(@Retorno,'É','E'),'Ç','C')
	Set @Retorno = replace(@Retorno,'''',' ');
    Set @Retorno = replace(@Retorno,'"',' ');
	Set @Retorno = replace(@Retorno,'.','');
	Set @Retorno = replace(@Retorno,'/','');
	Set @Retorno = replace(@Retorno,',','');
	Set @Retorno = replace(@Retorno,'-','');
	Set @Retorno = replace(@Retorno,';','');
	Set @Retorno = replace(@Retorno,'(','');
	Set @Retorno = replace(@Retorno,')','');
	Set @Retorno = replace(@Retorno,'+','');
	Set @Retorno = replace(@Retorno,':','');
	Set @Retorno = rtrim(ltrim(@Retorno));
	Set @Retorno = UPPER(@Retorno);
--    while charindex('.',@Retorno,1) <> 0 
--			and (isnumeric(substring(@Retorno,charindex('.',@Retorno,1)-1,1))=0 or isnumeric(substring(@Retorno,charindex('.',@Retorno,1)+1,1))=0)
--	begin
--		Set @Retorno = replace(@Retorno,'.',' ')
--	end
--	while charindex(',',@Retorno,1) <> 0 
--			and (isnumeric(substring(@Retorno,charindex(',',@Retorno,1)-1,1))=0 or isnumeric(substring(@Retorno,charindex(',',@Retorno,1)+1,1))=0)
--	begin
--		Set @Retorno = replace(@Retorno,',',' ')
--	end
	while charindex('  ',@Retorno,1) <> 0
	begin
		Set @Retorno = replace(@Retorno,'  ',' ')
    end

	
	Return @Retorno;
End




GO


