


IF OBJECT_ID ('tempdb..#TMP_TB_VENDEDOR') IS NOT NULL
BEGIN
DROP TABLE #TMP_TB_VENDEDOR
END

IF OBJECT_ID ('tempdb..#TMP_TB_VENDAS') IS NOT NULL
BEGIN
DROP TABLE #TMP_TB_VENDAS
END

IF OBJECT_ID ('tempdb..#TMP_TB_VENDEDOR_RESULT') IS NOT NULL
BEGIN
DROP TABLE #TMP_TB_VENDEDOR_RESULT
END


 
CREATE TABLE #TMP_TB_VENDEDOR (
	ID_VENDEDOR		INT
	, NM_VENDEDOR	VARCHAR(150)
	, UF_ESTADO		VARCHAR(10)
	, FL_STATUS		VARCHAR(10)
)
INSERT INTO #TMP_TB_VENDEDOR 
SELECT '1','Vendedor 1','SP','0' UNION ALL
SELECT '2','Vendedor 2','SP','0'


CREATE TABLE #TMP_TB_VENDAS (
	ID_VENDA		INT
	, ID_VENDEDOR	INT
	, VL_VENDA		VARCHAR(50)
	, DT_VENDA		DATETIME
)
INSERT INTO #TMP_TB_VENDAS
SELECT 3 , '1', 56.00   , GETDATE() UNION ALL
SELECT 4 , '1', 89.00   , GETDATE() UNION ALL
SELECT 13 ,'1', 167.00  , GETDATE() UNION ALL
SELECT 14 ,'1', 427.00  , GETDATE() UNION ALL
SELECT 33 ,'1', 200.00  , GETDATE() UNION ALL
SELECT 34 ,'1', 375.00  , GETDATE() UNION ALL
SELECT 38 ,'1', 1045.00 , GETDATE() UNION ALL
SELECT 5 , '2', 546.00  , GETDATE() UNION ALL
SELECT 6 , '2', 768.00  , GETDATE() UNION ALL
SELECT 7 , '2', 120.00  , GETDATE()



SELECT   
 ROW_NUMBER() OVER(ORDER BY ID_VENDA ASC) AS SEQ 
,B.ID_VENDEDOR   
,ID_VENDA   
,A.NM_VENDEDOR AS NOME_VENDEDOR   
,VL_VENDA AS VALOR_VENDA_R$   
,CONVERT(NUMERIC(15,2),0.00) AS ACUMULADO   
INTO #TMP_TB_VENDEDOR_RESULT_APPLY  
FROM #TMP_TB_VENDEDOR A   
INNER JOIN #TMP_TB_VENDAS B   
ON(A.ID_VENDEDOR = B.ID_VENDEDOR)   
WHERE A.FL_STATUS = 0   
ORDER BY 3,1         






SELECT 
    A.*
	,X.Acumulado
FROM #TMP_TB_VENDEDOR_RESULT_APPLY A
     CROSS APPLY
(
    SELECT SUM(CONVERT(DECIMAL(10,2),[VALOR_VENDA_R$])) AS Acumulado
    FROM #TMP_TB_VENDEDOR_RESULT_APPLY B
    WHERE A.SEQ >= B.SEQ
          AND A.ID_VENDEDOR = B.ID_VENDEDOR
) X
ORDER BY A.ID_VENDEDOR, 
         A.SEQ;

