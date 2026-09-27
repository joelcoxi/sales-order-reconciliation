-- reconciliar_totais_encomenda.sql
-- v1: verifica se o total do cabecalho bate com a soma das linhas
-- Autor: Joel Coxi

WITH OrderHeader AS (
    SELECT 
        A.SalesOrderID
        ,A.TotalDue
        ,ISNULL(A.Freight, 0) + ISNULL(A.TaxAmt, 0)   AS FreightTaxes
        ,A.[Status]
    FROM Sales.SalesOrderHeader A
    WHERE A.[Status] = 5
),
OrderDetail AS (
    SELECT 
        B.SalesOrderID
        ,SUM(B.OrderQty * (B.UnitPrice * (1 - B.UnitPriceDiscount))) AS TotalDueWithDiscount
    FROM Sales.SalesOrderDetail B
    GROUP BY B.SalesOrderID
),
Reconciliation AS (
    SELECT
        A.SalesOrderID
        ,A.TotalDue
        ,B.TotalDueWithDiscount + A.FreightTaxes AS TotalCalculado
        ,A.[Status]
    FROM OrderHeader A
        LEFT JOIN OrderDetail B ON A.SalesOrderID = B.SalesOrderID
)
SELECT 
    R.*
    ,R.TotalDue - R.TotalCalculado  AS Delta 
    ,CASE WHEN R.TotalCalculado IS NULL 
        THEN 'Sem linhas de detalhe'
     ELSE
        CASE
            WHEN ABS(R.TotalDue - R.TotalCalculado) >= 0.01
            THEN 'Não reconciliado'
            ELSE 'Reconciliado'
        END  
    END                           AS StatusReconciliacao
FROM Reconciliation R