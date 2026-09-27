/*
============================================================
Título    : Reconciliação de Totais, Encomendas (SalesOrderHeader x SalesOrderDetail)
Descrição : Compara o TotalDue do header de cada encomenda com o total
            recalculado a partir das linhas de detalhe (quantidade,
            preço unitário e desconto), mais frete e impostos.
            Classifica cada encomenda como Reconciliado, Não reconciliado
            ou Sem linhas de detalhe.
Autor     : Joel Coxi
Data      : 2026-09-27
============================================================
*/

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