USE [DB_ADMIX_IN]
GO

/****** Object:  UserDefinedFunction [dbo].[VERIFICA_REGRAS_VIGENCIA]    Script Date: 04/11/2014 11:11:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  
/*    
Descrição:          
Função que valida a data de vigência, seguindo os parametros da tabela SRVDV_SQL_PRD.PORTAL_ADMIX.dbo.SMC_AD_PARAMETRO          
  
Parâmetros:  
@TITULAR = 1 - TITULAR / 0 - DEPENDENTE          
@TP_MOVIMENTACAO = 1 - Inclusão / 0 - Cancelamento          
@ID_ESTIPULANTE = Id da Estipulante          
@DT_EVENTO = Data para comparar, pode ser a Data de Admissão,          
data de Nascimento do dependente ou data de casamento.   
@DT_VIGENCIA = Data de Vigência a ser validada.   
@TP_DEPENDENTE = 0 - Outros  
1 - Filho(a)  
2 - Conjugue        
Resultado        

Retorno "xxxxx" -> Data Vigência Inválida e retorna a msg de erro        
Retorno "" -> Data Vigência Válida        

select dbo.VERIFICA_REGRAS_VIGENCIA(1,1,4300184,'20131111','2013-08-01 23:59:59',null,null,null,0,1)  
select dbo.VERIFICA_REGRAS_VIGENCIA(1,1,1711790,'20130701','20130801',null,1,null,0,1)  
  
sp_helptext [PR_SMC_AD_VERIFICA_REGRAS_VIGENCIA]  
[PR_SMC_AD_VERIFICA_REGRAS_VIGENCIA] @TITULAR=1,@TP_MOVIMENTACAO=1,@ID_ESTIPULANTE=1711790,@DT_EVENTO='2010-07-01',@DT_VIGENCIA='2010-08-01',@FL_RETROATIVO_OPERADORA=1  
[PR_SMC_AD_VERIFICA_REGRAS_VIGENCIA] 1,1,1712237,'2010-08-05','2010-08-10',null          
[PR_SMC_AD_VERIFICA_REGRAS_VIGENCIA] 0,1,1712237,'2010-08-15','2010-08-05',1          
[PR_SMC_AD_VERIFICA_REGRAS_VIGENCIA] 0,1,1712239,'2010-08-15','2010-08-05',0          
*/          
  
CREATE FUNCTION [dbo].[VERIFICA_REGRAS_VIGENCIA]      
(      
 @TITULAR BIT,      
 @TP_MOVIMENTACAO TINYINT,      
 @ID_ESTIPULANTE BIGINT,      
 @DT_EVENTO DATETIME = NULL,      
 @DT_VIGENCIA DATETIME,      
 @TP_DEPENDENTE TINYINT = NULL,      
 @FL_RETROATIVO_OPERADORA BIT = 0,      
 @DIAS_RETROATIVO INT = NULL,      
 @FL_ADM BIT = 0,      
 @ID_TIPO_MOVIMENTACAO INT = 0      
)  
RETURNS VARCHAR(500)      
AS    
BEGIN    
  
/*      
SELECT * FROM SRVDV_SQL_PRD.PORTAL_ADMIX.dbo.SMC_AD_PARAMETRO where NR_DIAS_RETRO_ATUAL_TIT = -1 AND CD_CONTRATO = '1558'      
      
UPDATE SRVDV_SQL_PRD.PORTAL_ADMIX.dbo.SMC_AD_PARAMETRO SET NR_DIAS_RETRO_ATUAL_TIT = -1 WHERE ID_PARAMETRO = 359      
UPDATE SRVDV_SQL_PRD.PORTAL_ADMIX.dbo.SMC_AD_PARAMETRO SET NR_DIAS_RETRO_ATUAL_TIT = 0 WHERE ID_PARAMETRO = 358      
      
SELECT OP.DS_OPERADORA_HOTSITE,E.ID_OPERADORA,P.*      
FROM SRVDV_SQL_PRD.PORTAL_ADMIX.dbo.SMC_AD_PARAMETRO P      
INNER JOIN SRVDV_SQL_PRD.PORTAL_ADMIX.dbo.AD_ESTIPULANTE E ON E.ID_PAPEL_RELACIONAMENTO = P.ID_ESTIPULANTE      
INNER JOIN AD_OPERADORA_PORTAL OP ON OP.ID_PAPEL_RELACIONAMENTO = E.ID_OPERADORA      
WHERE      
OP.ID_PAPEL_RELACIONAMENTO = 1700557 -- SEGUROS UNIMED      
AND P.FL_VISUALIZA_ADM = 1  -- CONTRATOS ADM      
  
select * from usuario where nomeUsuario like '%Priscila%'  
select * from SRVDV_SQL_PRD.PORTAL_ADMIX.dbo.SMC_AD_PARAMETRO where cd_contrato= '70633'  
UPDATE SRVDV_SQL_PRD.PORTAL_ADMIX.dbo.SMC_AD_PARAMETRO      
SET FL_DT_DIA = NULL      
, FL_ULTIMO_DIA = 1      
WHERE ID_ESTIPULANTE = 4571774 AND TP_MOVIMENTACAO = 0      
  
select * from SRVDV_SQL_PRD.PORTAL_ADMIX.dbo.SMC_AD_PARAMETRO where cd_contrato like '87'  
  
*/      
--DECLARE @TESTE int  
--  
--SET @TESTE = 1  
--  
--DECLARE @TITULAR BIT,          
--@TP_MOVIMENTACAO TINYINT,          
--@ID_ESTIPULANTE BIGINT,          
--@DT_EVENTO DATETIME,          
--@DT_VIGENCIA DATETIME,          
--@TP_DEPENDENTE TINYINT,        
--@FL_RETROATIVO_OPERADORA BIT,        
--@DIAS_RETROATIVO INT,    
--@FL_ADM BIT,    
--@ID_TIPO_MOVIMENTACAO INT    
--  
--SET @TITULAR = 1  
--SET @TP_MOVIMENTACAO = 0  
--SET @ID_ESTIPULANTE = 3425053  
--SET @DT_EVENTO = '20140130'  
--SET @DT_VIGENCIA = '20140129'  
--  
----SET @TP_DEPENDENTE = 2  
--SET @FL_RETROATIVO_OPERADORA = 0  
----SET @DIAS_RETROATIVO = 60 --Bradesco inc = 90 can= 90 /  seguros unimed inc = 180 can=180 / metlife inc=30 can=30  
--SET @FL_ADM = 0  
--SET @ID_TIPO_MOVIMENTACAO = 10  
  
  
  
DECLARE @ID_OPERADORA BIGINT    
DECLARE @RETURN_MSG VARCHAR(500)          
DECLARE @DATA_ATUAL DATETIME          
DECLARE @NR_DIAS_APOS INT          
DECLARE @DEFAULT_APOS INT          
DECLARE @DT_APOS DATETIME          
  
DECLARE @NR_DIAS_RETRO INT          
DECLARE @DEFAULT_RETRO INT          
DECLARE @DT_RETRO DATETIME          
  
DECLARE @TP_CONTRATO TINYINT          
DECLARE @DT_INICIO_VIGENCIA DATETIME          
  
DECLARE @FL_DT_DIA BIT -- Indica que a vigencia deve ser para o primeiro dia do mês        
DECLARE @FL_ULTIMO_DIA BIT -- Indica que a vigencia deve ser para o último dia do mês        
  
DECLARE @FL_VISUALIZA_ADM BIT    
  
DECLARE @ID_TIPO_COPARTICIPACAO INT  
  
SET @DEFAULT_APOS = 30  
SET @DEFAULT_RETRO = 30  
SET @RETURN_MSG = ''  
  
IF (@FL_RETROATIVO_OPERADORA IS NULL) SET @FL_RETROATIVO_OPERADORA = 0  
      
IF (@TITULAR = 0 AND @TP_DEPENDENTE IS NULL) SET @TP_DEPENDENTE = 0          
      
SET @DATA_ATUAL = CONVERT(VARCHAR,GETDATE(),112) --Formata o getdate para pegar somente a data sem as horas          
      
--VARIAVEIS PARA COMPOR A MSG          
DECLARE @MSG_DATA_A_COMPARAR VARCHAR(20) -- Indica qual data está baseada (atual,admissão, Nascimento ou casamento)          
SET @MSG_DATA_A_COMPARAR = 'Data Atual'          
      
--**********************************************************************************          
-- RECUPERA A DATA DE INICIO DE VIGÊNCIA          
--**********************************************************************************          
IF (@TP_MOVIMENTACAO = 1)          
BEGIN          
  
SET @DT_INICIO_VIGENCIA = ( SELECT CAST(YEAR(DT_INICIO_VIGENCIA_OPERADORA)AS VARCHAR) + '-' + CAST(MONTH(DT_INICIO_VIGENCIA_OPERADORA)AS VARCHAR) + '-' + CAST(DAY(DT_INICIO_VIGENCIA_OPERADORA)AS VARCHAR)          
FROM SRVDV_SQL_PRD.PORTAL_ADMIX.dbo.AD_ESTIPULANTE          
WHERE ID_PAPEL_RELACIONAMENTO = @ID_ESTIPULANTE)          
  
IF (NOT @DT_INICIO_VIGENCIA IS NULL)  
IF (@DT_INICIO_VIGENCIA <= ('2009-11-01')) SET @DEFAULT_APOS = 60  
  
END  
  
--NO CASO DE OUTROS NÃO PASSA A DATA A COMPARAR ENTÃO SETA A DATA ATUAL          
IF (@DT_EVENTO IS NULL) SET @DT_EVENTO = @DATA_ATUAL          
  
--**********************************************************************************          
-- RECUPERA OS PARAMETROS (DE ACORDO COM O TIPO, INCLUSÃO OU CANCELAMENTO)          
--**********************************************************************************       
  
SELECT   
@TP_CONTRATO =   
CASE  
 WHEN ISNULL(E.ID_TIPO_CONTRATO,2) = 1 THEN 2  
 WHEN ISNULL(E.ID_TIPO_CONTRATO,2) = 2 THEN 1  
 WHEN ISNULL(E.ID_TIPO_CONTRATO,2) = 3 THEN 3  
END   
FROM SRVDV_SQL_PRD.PORTAL_ADMIX.dbo.SMC_AD_PARAMETRO P  
INNER JOIN SRVDV_SQL_PRD.PORTAL_ADMIX.dbo.AD_ESTIPULANTE E ON E.ID_PAPEL_RELACIONAMENTO = P.ID_ESTIPULANTE    
WHERE P.ID_ESTIPULANTE = @ID_ESTIPULANTE AND TP_MOVIMENTACAO = @TP_MOVIMENTACAO          
    
  
     
SELECT        
 @FL_DT_DIA = ISNULL(FL_DT_DIA,0),        
 @FL_ULTIMO_DIA = ISNULL(FL_ULTIMO_DIA,0),        
-- @TP_CONTRATO = TP_CONTRATO,          
 @NR_DIAS_APOS =         
ISNULL(CASE @TITULAR        
 WHEN 1 THEN --Titular          
  CASE @TP_CONTRATO          
   WHEN 1 THEN          
    CASE @TP_MOVIMENTACAO          
     WHEN 1 THEN -- INCLUSÃO          
      ISNULL(NR_DIAS_APOS_ADMISSAO,@DEFAULT_APOS) -- Compulsório          
     ELSE -- CANCELAMENTO          
      ISNULL(NR_DIAS_APOS_ATUAL,@DEFAULT_APOS) -- Compulsório          
    END          
   WHEN 2 THEN ISNULL(NR_DIAS_APOS_ATUAL,@DEFAULT_APOS) -- Adesão          
   WHEN 3 THEN ISNULL(NR_DIAS_APOS_ADMISSAO,@DEFAULT_APOS) -- Híbrido          
  END          
 WHEN 0 THEN --Dependente          
  CASE @TP_CONTRATO          
   WHEN 1 THEN --Compulsório          
    CASE @TP_MOVIMENTACAO         
     WHEN 1 THEN -- INCLUSÃO          
      CASE @TP_DEPENDENTE          
       WHEN 0 THEN -- Outros          
        ISNULL(NR_DIAS_APOS_OUTROS,@DEFAULT_APOS)          
       WHEN 1 THEN -- Filho(a)          
        ISNULL(NR_DIAS_APOS_NASCIMENTO,@DEFAULT_APOS)          
       WHEN 2 THEN -- Conjugue          
        ISNULL(NR_DIAS_APOS_CASAMENTO,@DEFAULT_APOS)          
      END          
     ELSE          
      ISNULL(NR_DIAS_APOS_ATUAL,@DEFAULT_APOS)        
     END         
   WHEN 2 THEN ISNULL(NR_DIAS_APOS_ATUAL,@DEFAULT_APOS) -- Adesão          
   WHEN 3 THEN ISNULL(NR_DIAS_APOS_ATUAL,@DEFAULT_APOS) -- Híbrido          
  END          
 END,0),        
        
 @NR_DIAS_RETRO =        
   ISNULL(CASE @TITULAR          
      WHEN 1 THEN ISNULL(NR_DIAS_RETRO_ATUAL_TIT,@DEFAULT_RETRO) --Titular          
      WHEN 0 THEN ISNULL(NR_DIAS_RETRO_ATUAL_DEP,@DEFAULT_RETRO) --Dependente          
   END,0),    
 @FL_VISUALIZA_ADM = FL_VISUALIZA_ADM,  
 @ID_OPERADORA = E.ID_OPERADORA,  
 @ID_TIPO_COPARTICIPACAO = ISNULL(E.ID_TIPO_COPARTICIPACAO,0)  
FROM SRVDV_SQL_PRD.PORTAL_ADMIX.dbo.SMC_AD_PARAMETRO P  
INNER JOIN SRVDV_SQL_PRD.PORTAL_ADMIX.dbo.AD_ESTIPULANTE E ON E.ID_PAPEL_RELACIONAMENTO = P.ID_ESTIPULANTE    
WHERE P.ID_ESTIPULANTE = @ID_ESTIPULANTE AND TP_MOVIMENTACAO = @TP_MOVIMENTACAO          
    
  
          
--Compulsório          
IF (@TP_CONTRATO = 1)          
 IF (@TP_MOVIMENTACAO = 1)          
  SET @DT_APOS = (SELECT DATEADD(D,@NR_DIAS_APOS,@DT_EVENTO))          
 ELSE          
  SET @DT_APOS = (SELECT DATEADD(D,@NR_DIAS_APOS,@DATA_ATUAL))          
          
          
--Adesão          
IF (@TP_CONTRATO = 2)          
 SET @DT_APOS = (SELECT DATEADD(D,@NR_DIAS_APOS,@DATA_ATUAL))          
        
        
--Híbrido          
IF (@TP_CONTRATO = 3)          
BEGIN          
        
 IF (@TITULAR = 1)        
  IF (@TP_MOVIMENTACAO = 1)        
   SET @DT_APOS = (SELECT DATEADD(D,@NR_DIAS_APOS,@DT_EVENTO))          
  ELSE          
   SET @DT_APOS = (SELECT DATEADD(D,@NR_DIAS_APOS,@DATA_ATUAL))          
          
 IF (@TITULAR = 0)          
  SET @DT_APOS = (SELECT DATEADD(D,@NR_DIAS_APOS,@DATA_ATUAL))          
END        
          
          
IF @FL_RETROATIVO_OPERADORA = 1        
BEGIN        
 SET @NR_DIAS_RETRO = (ISNULL(@DIAS_RETROATIVO,@DEFAULT_RETRO))  
 SET @DT_RETRO = (SELECT DATEADD(D,-@NR_DIAS_RETRO,@DATA_ATUAL))         
END        
ELSE        
BEGIN         
 --SETA A DATA LIMITE RETROATIVA          
 SET @DT_RETRO = (SELECT DATEADD(D,-@NR_DIAS_RETRO,@DATA_ATUAL))          
END        
        
        
        
--Verificar se for ADM SET @TP_CONTRATO = 2        
--IF(@FL_VISUALIZA_ADM = 1)      
--BEGIN      
 --Contratos ADM tratados como adesão    
--SET @TP_CONTRATO = 2  
--END    
      
    
IF (@TITULAR = 1 AND @TP_CONTRATO<>2)          
BEGIN          
 IF (@TP_MOVIMENTACAO = 1) SET @MSG_DATA_A_COMPARAR = 'Data de Admissão'          
 IF (@TP_MOVIMENTACAO = 0) SET @MSG_DATA_A_COMPARAR = 'Data Atual'          
END          
ELSE          
BEGIN          
 IF (@TP_MOVIMENTACAO = 1)          
 BEGIN          
  IF (@TP_DEPENDENTE = 1 AND @TP_CONTRATO=1) SET @MSG_DATA_A_COMPARAR = 'Data de Nascimento'          
  IF (@TP_DEPENDENTE = 2 AND @TP_CONTRATO=1) SET @MSG_DATA_A_COMPARAR = 'Data de Casamento'          
 END          
 ELSE          
  SET @MSG_DATA_A_COMPARAR = 'Data Atual'          
END          
    
  
  
  
 DECLARE @VERIF_REGRAS_COMUNS BIT    
 SET @VERIF_REGRAS_COMUNS = 1 -- parametro criado para possivelmente não verificar as regras comuns caso as novas regras sobreponham a mesma    
    
  
 --IF(@FL_VISUALIZA_ADM = 1 AND @FL_RETROATIVO_OPERADORA = 0)  
IF(@FL_VISUALIZA_ADM = 1)  
 BEGIN  
  --=========================================================================================================================  
  --VERIFICA NOVAS REGRAS E SE ENCONTRAR A REGRA NAO VERIFICA AS "REGRAS COMUNS" SETANDO @VERIF_REGRAS_COMUNS = 0    
  --=========================================================================================================================  
  
  DECLARE @DT_PRIMEIRO_DIA VARCHAR(8),  @DT_ULTIMO_DIA VARCHAR(8), @DT_MES_SEGUINTE VARCHAR(8), @DT_VIGENCIA_MES_ATUAL VARCHAR(8), @DT_HOJE VARCHAR(8)   
     
  SET @DT_VIGENCIA_MES_ATUAL = (SELECT CAST(YEAR(@DT_VIGENCIA) AS VARCHAR) + RIGHT('0' + CAST(MONTH(@DT_VIGENCIA) AS VARCHAR),2) + '01')    
     
  --primeiro dia do mês    
  SET @DT_PRIMEIRO_DIA = (SELECT CAST(YEAR(GETDATE()) AS VARCHAR) + RIGHT('0' + CAST(MONTH(GETDATE()) AS VARCHAR),2) + '01')    
     
  SET @DT_MES_SEGUINTE = (SELECT CAST(YEAR(DATEADD(M,1,GETDATE())) AS VARCHAR) + RIGHT('0' + CAST(MONTH(DATEADD(M,1,GETDATE())) AS VARCHAR),2) + '01')    
  
  --último dia do mês    
  DECLARE @DT_ULTIMO AS DATETIME   
  set @DT_ULTIMO = (SELECT dateadd(d,-1, dateadd(m,1,(SELECT CAST(YEAR(GETDATE()) AS VARCHAR)  + RIGHT('0' + CAST(MONTH(GETDATE()) AS VARCHAR),2) + '01'))))    
  SET @DT_ULTIMO_DIA = (SELECT CAST(YEAR(@DT_ULTIMO) AS VARCHAR) + RIGHT('0' + CAST(MONTH(@DT_ULTIMO) AS VARCHAR),2) + RIGHT('0' + CAST(DAY(@DT_ULTIMO) AS VARCHAR),2))  
  
  SET @DT_HOJE = (SELECT CAST(YEAR(getdate()) AS VARCHAR) + RIGHT('0' + CAST(MONTH(getdate()) AS VARCHAR),2) + RIGHT('0' + CAST(DAY(getdate()) AS VARCHAR),2))  
  
  
 --Para movimentações de Cancelamento ADM (Operadora), verificar cooparticipação  
 IF (@ID_TIPO_MOVIMENTACAO IN(10,11) AND (@ID_TIPO_COPARTICIPACAO > 0 AND @FL_ADM = 0) )  
 BEGIN  
  
  --Se tiver coopart (0-sem,1-Revertido para a Operadora,2-Revertido para a Empresa,3-Mista) AD_TIPO_COPARTICIPACAO  
  --Os cancelamento podem ser com data imediata ou futura  
  IF (@FL_RETROATIVO_OPERADORA = 0 AND CAST(@DT_VIGENCIA AS DATETIME) < CAST(@DT_HOJE AS DATETIME))  
   SET @RETURN_MSG = 'Data de Vigência válida apenas para datas imediatas ou futuras'  
  
 END  
 ELSE  
 BEGIN  
     
   --==============================================    
    --1700557 - SEGUROS UNIMED    
   --==============================================    
    IF (@ID_OPERADORA = 1700557)    
    BEGIN    
      
     SET @VERIF_REGRAS_COMUNS = 0  
      
     -- INCLUSAO DE GRUPO = 1 | INCLUSÃO DEP = 2    
     IF(@ID_TIPO_MOVIMENTACAO IN(1,2))  
     BEGIN    
    --Primeiro dia do mês  
    IF (DAY(@DT_VIGENCIA) > 1)    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês'  
    -- Primeiro dia do mês atual quando não tem o flag retroativo  
    IF (@FL_RETROATIVO_OPERADORA = 0 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_PRIMEIRO_DIA AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês a partir do mês atual'    
    -- se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
  
     END  
      
     --ALT SUB = 6 | ALT PLANO = 8    
     IF (@ID_TIPO_MOVIMENTACAO IN(6,8))  
     BEGIN  
  
    --Primeiro dia do mês seguinte(s)    
    IF (DAY(@DT_VIGENCIA) > 1)    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia a partir do mês seguinte'    
      
    IF(CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_MES_SEGUINTE AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia a partir do mês seguinte'    
  
     END  
  
  
     --CANCELAMENTO GRUPO FAMILIAR = 10 | CANCELAMENTO DE DEPENDENTE = 11    
     IF (@ID_TIPO_MOVIMENTACAO IN(10,11))  
     BEGIN  
  
    --Último dia do mês  
    IF (MONTH(@DT_VIGENCIA) = MONTH(DATEADD(DAY,1,@DT_VIGENCIA)))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês'  
  
    IF (@FL_RETROATIVO_OPERADORA = 0 AND @DT_VIGENCIA < CAST(@DT_ULTIMO_DIA AS DATETIME))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês a partir do mês atual'  
  
    --Se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
  
     END  
      
    END    
      
   --==================================================================================================    
    --1697978 - BRADESCO SAUDE | 1711616 - BRADESCO VIDA E PREVIDENCIA | 1728759 - BRADESCO DENTAL    
   --==================================================================================================    
    IF (@ID_OPERADORA IN(1697978 ,1728759 ,1711616))    
    BEGIN    
      
     SET @VERIF_REGRAS_COMUNS = 0    
      
     -- INCLUSAO DE GRUPO = 1 | INCLUSÃO DEP = 2    
     IF(@FL_ADM= 1 AND @ID_TIPO_MOVIMENTACAO IN(1,2))    
     BEGIN    
    --Primeiro dia do mês  
    IF (DAY(@DT_VIGENCIA) > 1)    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês'  
    -- Primeiro dia do mês atual quando não tem o flag retroativo  
    IF (@FL_RETROATIVO_OPERADORA = 0 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_PRIMEIRO_DIA AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês a partir do mês atual'    
    -- se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida até ' + CAST(@NR_DIAS_RETRO AS VARCHAR) + ' dia(s) retroativo(s) da data atual'  
  
     END  
  
  
     -- INCLUSAO DE GRUPO = 1 | INCLUSÃO DEP = 2    
     IF(@FL_ADM=0 AND @ID_TIPO_MOVIMENTACAO IN(1,2))  
     BEGIN  
    --Data imediata ou futura (Operadora)  
    IF (@FL_RETROATIVO_OPERADORA = 0 AND CAST(@DT_VIGENCIA AS DATETIME) < CAST(@DT_HOJE AS DATETIME))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para datas imediatas ou futuras'  
    -- se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
  
     END  
  
     --ALT SUB = 6 | ALT PLANO = 8    
     IF (@ID_TIPO_MOVIMENTACAO IN(6,8) OR ((@ID_TIPO_MOVIMENTACAO IN (10,11) AND @FL_ADM = 0 )))    
     BEGIN    
   --Primeiro dia do mês seguinte(s)    
   IF (DAY(@DT_VIGENCIA) > 1)    
    SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia a partir do mês seguinte'    
   ELSE    
    IF(@FL_RETROATIVO_OPERADORA = 0  AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_MES_SEGUINTE AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia a partir do mês seguinte'    
           
   --SET @VERIF_REGRAS_COMUNS = 0    
     END    
      
     --CANCELAMENTO GRUPO FAMILIAR = 10 | CANCELAMENTO DE DEPENDENTE = 11    
     IF(@FL_ADM = 1 AND @ID_TIPO_MOVIMENTACAO IN(10,11))    
     BEGIN  
  
    --Último dia do mês  
    IF (MONTH(@DT_VIGENCIA) = MONTH(DATEADD(DAY,1,@DT_VIGENCIA)))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês'  
  
    IF (@FL_RETROATIVO_OPERADORA = 0 AND @DT_VIGENCIA < CAST(@DT_ULTIMO_DIA AS DATETIME))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês a partir do mês atual'  
  
    --Se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
  
     END    
      
    END    
      
   --==================================================================================================    
    -- 1698005 - METLIFE | 1698003 - METLIFE VIDA E PREVIDENCIA    
   --==================================================================================================    
    IF (@ID_OPERADORA IN(1698005,1698003))    
    BEGIN    
      
     SET @VERIF_REGRAS_COMUNS = 0    
      
     -- INCLUSAO DE GRUPO = 1 | INCLUSÃO DEP = 2    
     IF(@FL_ADM= 1 AND @ID_TIPO_MOVIMENTACAO IN(1,2))    
     BEGIN  
    --Primeiro dia do mês  
    IF (DAY(@DT_VIGENCIA) > 1)    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês'  
    -- Primeiro dia do mês atual quando não tem o flag retroativo  
    IF (@FL_RETROATIVO_OPERADORA = 0 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_PRIMEIRO_DIA AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês a partir do mês atual'    
    -- se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
  
     END    
  
     -- INCLUSAO DE GRUPO = 1 | INCLUSÃO DEP = 2    
     IF(@FL_ADM=0 AND @ID_TIPO_MOVIMENTACAO IN(1,2))  
     BEGIN  
    --Data imediata ou futura (Operadora)  
    IF (@FL_RETROATIVO_OPERADORA = 0 AND CAST(@DT_VIGENCIA AS DATETIME) < CAST(@DT_HOJE AS DATETIME))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para datas imediatas ou futuras'  
    -- se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
     END  
      
     --ALT SUB = 6 | ALT PLANO = 8    
     IF(@ID_TIPO_MOVIMENTACAO IN(6,8))    
     BEGIN    
   --Primeiro dia do mês seguinte(s)    
   IF (DAY(@DT_VIGENCIA) > 1)    
    SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia a partir do mês seguinte'    
   ELSE    
    IF(CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_MES_SEGUINTE AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia a partir do mês seguinte'    
           
     END    
      
     --CANCELAMENTO GRUPO FAMILIAR = 10 | CANCELAMENTO DE DEPENDENTE = 11    
     IF (@ID_TIPO_MOVIMENTACAO IN(10,11))    
     BEGIN    
    --Último dia do mês  
    IF (MONTH(@DT_VIGENCIA) = MONTH(DATEADD(DAY,1,@DT_VIGENCIA)))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês'  
  
    IF (@FL_RETROATIVO_OPERADORA = 0 AND @DT_VIGENCIA < CAST(@DT_ULTIMO_DIA AS DATETIME))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês a partir do mês atual'  
  
    --Se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
  
     END    
      
    END    
      
   --==================================================================================================    
    --1697999 - MARITIMA    
   --==================================================================================================    
    IF (@ID_OPERADORA = 1697999)    
    BEGIN    
      
     SET @VERIF_REGRAS_COMUNS = 0    
      
     -- INCLUSAO DE GRUPO = 1 | INCLUSÃO DEP = 2    
     IF(@FL_ADM= 1 AND @ID_TIPO_MOVIMENTACAO IN(1,2))    
     BEGIN    
    --Primeiro dia do mês  
    IF (DAY(@DT_VIGENCIA) > 1)    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês'  
    -- Primeiro dia do mês atual quando não tem o flag retroativo  
    IF (CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_PRIMEIRO_DIA AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês a partir do mês atual'    
    -- se for retroativo, validar dentro do periodo  
    --IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
    -- SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
  
     END    
      
     -- INCLUSAO DE GRUPO = 1 | INCLUSÃO DEP = 2    
     IF(@FL_ADM=0 AND @ID_TIPO_MOVIMENTACAO IN(1,2))  
     BEGIN  
    --Data imediata ou futura (Operadora)  
    IF (CAST(@DT_VIGENCIA AS DATETIME) < CAST(@DT_HOJE AS DATETIME))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para datas imediatas ou futuras'  
     END  
  
     --ALT SUB = 6 | ALT PLANO = 8    
     IF(@ID_TIPO_MOVIMENTACAO IN(6,8))    
     BEGIN    
   --Primeiro dia do mês seguinte(s)    
   IF (DAY(@DT_VIGENCIA) > 1)    
    SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia a partir do mês seguinte'    
   ELSE    
    IF(CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_MES_SEGUINTE AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia a partir do mês seguinte'    
      
     END    
      
     --CANCELAMENTO GRUPO FAMILIAR = 10 | CANCELAMENTO DE DEPENDENTE = 11    
     IF (@ID_TIPO_MOVIMENTACAO IN(10,11))    
     BEGIN  
    --Último dia do mês  
    IF (MONTH(@DT_VIGENCIA) = MONTH(DATEADD(DAY,1,@DT_VIGENCIA)))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês'  
  
    IF (@FL_RETROATIVO_OPERADORA = 0 AND @DT_VIGENCIA < CAST(@DT_ULTIMO_DIA AS DATETIME))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês a partir do mês atual'  
  
    --Se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
  
     END    
      
    END    
      
   --==================================================================================================    
    -- 1697994 - INTERMEDICA | 1700578 - INTERMEDICA - PE    
   --==================================================================================================    
    IF (@ID_OPERADORA IN(1697994,1700578))    
    BEGIN    
      
     SET @VERIF_REGRAS_COMUNS = 0    
      
     --INCLUSÃO DE GRUPO = 1 | INCLUSÃO DEP = 2 | ALT SUB = 6 | ALT PLANO = 8    
     IF(@ID_TIPO_MOVIMENTACAO IN(1,2,6,8))    
     BEGIN  
  
    -- Primeiro dia do mês atual quando não tem o flag retroativo  
    IF (CAST(@DT_VIGENCIA AS DATETIME) < CAST(@DT_HOJE AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para vigências imediatas ou futuras'    
    -- se for retroativo, validar dentro do periodo  
    --IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
    -- SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
      
     END    
      
     --CANCELAMENTO GRUPO FAMILIAR = 10 | CANCELAMENTO DE DEPENDENTE = 11    
     IF (@ID_TIPO_MOVIMENTACAO IN(10,11))    
     BEGIN    
    --Último dia do mês  
    IF (MONTH(@DT_VIGENCIA) = MONTH(DATEADD(DAY,1,@DT_VIGENCIA)))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês'  
  
    IF (@FL_RETROATIVO_OPERADORA = 0 AND @DT_VIGENCIA < CAST(@DT_ULTIMO_DIA AS DATETIME))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês a partir do mês atual'  
  
    --Se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
  
     END    
      
    END    
      
   --==================================================================================================    
    -- 1700567 - FARMASEG    
   --==================================================================================================    
    IF (@ID_OPERADORA = 1700567)    
    BEGIN    
      
     SET @VERIF_REGRAS_COMUNS = 0    
      
     -- INCLUSAO DE GRUPO = 1 | INCLUSÃO DEP = 2    
     IF(@FL_ADM= 1 AND @ID_TIPO_MOVIMENTACAO IN(1,2))    
     BEGIN    
    --Primeiro dia do mês  
    IF (DAY(@DT_VIGENCIA) > 1)    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês'  
    -- Primeiro dia do mês atual quando não tem o flag retroativo  
    IF (@FL_RETROATIVO_OPERADORA = 0 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_PRIMEIRO_DIA AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês a partir do mês atual'    
    -- se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
  
     END    
      
     -- INCLUSAO DE GRUPO = 1 | INCLUSÃO DEP = 2    
     IF(@FL_ADM=0 AND @ID_TIPO_MOVIMENTACAO IN(1,2))  
     BEGIN  
    --Data imediata ou futura (Operadora)  
    IF (@FL_RETROATIVO_OPERADORA = 0 AND CAST(@DT_VIGENCIA AS DATETIME) < CAST(@DT_HOJE AS DATETIME))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para datas imediatas ou futuras'  
    -- se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
     END  
  
     --ALT SUB = 6 | ALT PLANO = 8    
     IF(@ID_TIPO_MOVIMENTACAO IN(6,8))    
     BEGIN    
   --Primeiro dia do mês seguinte(s)    
   IF (DAY(@DT_VIGENCIA) > 1)    
    SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia a partir do mês seguinte'    
   ELSE    
    IF(CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_MES_SEGUINTE AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia a partir do mês seguinte'    
      
     END    
      
     --CANCELAMENTO GRUPO FAMILIAR = 10 | CANCELAMENTO DE DEPENDENTE = 11    
     IF (@ID_TIPO_MOVIMENTACAO IN(10,11))    
     BEGIN    
   --Último dia do mês    
  --    IF (MONTH(@DT_VIGENCIA) = MONTH(DATEADD(DAY,1,@DT_VIGENCIA)))    
  --     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês'    
    IF(@FL_RETROATIVO_OPERADORA = 0 AND @DT_VIGENCIA < CONVERT(CHAR,GETDATE(),112))   
     SET @RETURN_MSG = 'Data de Vigência válida somente a partir do dia atual'  
  
    --Se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida até ' + CAST(@NR_DIAS_RETRO AS VARCHAR) + ' dia(s) retroativo(s) da data atual'  
  
     END    
    END    
      
   --==================================================================================================    
    -- 2327305 alterado para 5478288 - ALLIANZ SEGUROS  
   --==================================================================================================    
    --IF (@ID_OPERADORA = 2327305)  
    IF (@ID_OPERADORA = 5478288)  
    BEGIN    
      
     SET @VERIF_REGRAS_COMUNS = 0    
      
     -- INCLUSAO DE GRUPO = 1 | INCLUSÃO DEP = 2    
     IF(@ID_TIPO_MOVIMENTACAO IN(1,2))    
     BEGIN    
    --Primeiro dia do mês  
    IF (DAY(@DT_VIGENCIA) > 1)    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês'  
    -- Primeiro dia do mês atual quando não tem o flag retroativo  
    IF (@FL_RETROATIVO_OPERADORA = 0 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_PRIMEIRO_DIA AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês a partir do mês atual'    
    -- se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
  
     END    
      
      
     --ALT SUB = 6 | ALT PLANO = 8    
     IF(@ID_TIPO_MOVIMENTACAO IN(6,8))    
     BEGIN    
   --Primeiro dia do mês seguinte(s)    
   IF (DAY(@DT_VIGENCIA) > 1)    
    SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia a partir do mês seguinte'    
   ELSE    
    IF(CAST(@DT_VIGENCIA_MES_ATUAL AS DATETIME) < CAST(@DT_MES_SEGUINTE AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia a partir do mês seguinte'    
      
     END    
      
     --CANCELAMENTO GRUPO FAMILIAR = 10 | CANCELAMENTO DE DEPENDENTE = 11    
     IF (@ID_TIPO_MOVIMENTACAO IN(10,11))    
     BEGIN    
    --Último dia do mês  
    IF (MONTH(@DT_VIGENCIA) = MONTH(DATEADD(DAY,1,@DT_VIGENCIA)))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês'  
  
    IF (@FL_RETROATIVO_OPERADORA = 0 AND @DT_VIGENCIA < CAST(@DT_ULTIMO_DIA AS DATETIME))  
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês a partir do mês atual'  
  
    --Se for retroativo, validar dentro do periodo  
    IF (@FL_RETROATIVO_OPERADORA = 1 AND CAST(@DT_VIGENCIA AS DATETIME) < CAST(@DT_RETRO AS DATETIME))    
     SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês no período de ' + cast(@NR_DIAS_RETRO AS varchar) + ' dias'  
  
     END    
          
    END    
 END  
 --=========================================================================================================================    
 END    
    
    
    
    
--Se o contrato é diferente de ADESÃO, verifica as regras    
IF (@TP_CONTRATO<>2 AND @VERIF_REGRAS_COMUNS = 1)  
BEGIN        
    
  IF (@DT_VIGENCIA < @DT_RETRO)  
  BEGIN          
   IF (@NR_DIAS_RETRO >0 AND (@FL_RETROATIVO_OPERADORA = 0 OR @TP_MOVIMENTACAO = 0))  
    --SET @RETURN_MSG = 'Data de Vigência com menos de ' + CAST(@NR_DIAS_RETRO AS VARCHAR) + ' dias da Data Atual'          
    SET @RETURN_MSG = 'Data de Vigência válida até ' + CAST(@NR_DIAS_RETRO AS VARCHAR) + ' dia(s) retroativo(s) da data atual'          
   ELSE          
    --SET @RETURN_MSG = 'Data de Vigência menor que a Data Atual'          
 IF (@FL_RETROATIVO_OPERADORA = 0 OR @TP_MOVIMENTACAO = 0)  
 BEGIN  
  IF (@NR_DIAS_RETRO = 0)  
   SET @RETURN_MSG = 'Data de Vigência válida a partir da Data Atual'          
  ELSE          
   SET @RETURN_MSG = 'Data de Vigência válida a partir de ' + CAST(ABS(@NR_DIAS_RETRO)AS VARCHAR) + ' dia(s) após a Data Atual'          
 END  
  END    
            
  IF (@DT_VIGENCIA > @DT_APOS AND (@FL_RETROATIVO_OPERADORA = 0 OR @TP_MOVIMENTACAO = 0))  
   SET @RETURN_MSG = 'Data de Vigência com mais de ' + CAST(@NR_DIAS_APOS AS VARCHAR) + ' dias da ' + @MSG_DATA_A_COMPARAR          
  
  
  IF (@RETURN_MSG = '' AND @FL_DT_DIA = 1 AND DAY(@DT_VIGENCIA)<>1 AND (@FL_RETROATIVO_OPERADORA = 0 OR @TP_MOVIMENTACAO = 0))  
   SET @RETURN_MSG = 'Data de Vigência válida apenas para o primeiro dia do mês'    
          
  IF (@RETURN_MSG = '' AND @FL_ULTIMO_DIA = 1 AND MONTH(@DT_VIGENCIA) = MONTH(DATEADD(DAY,1,@DT_VIGENCIA)) AND (@FL_RETROATIVO_OPERADORA = 0 OR @TP_MOVIMENTACAO = 0))  
   SET @RETURN_MSG = 'Data de Vigência válida apenas para o último dia do mês'    
     
END    
  
--SELECT @ID_TIPO_COPARTICIPACAO,@TP_CONTRATO tp_contrato,@ID_OPERADORA operadora,@DT_RETRO data_retro,@RETURN_MSG msg  ,@NR_DIAS_RETRO dias_retro  
  
  
RETURN @RETURN_MSG          
END   

GO


