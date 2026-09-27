-- reconciliar_totais_encomenda.sql
-- v1: verifica se o total do cabecalho bate com a soma das linhas
-- Autor: Joel Coxi

WITH OrderHeader AS (
    SELECT 
        A.SalesOrderID
        ,A.TotalDue
        ,A.Freight + A.TaxAmt   AS FreightTaxes
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
    * 
FROM Reconciliation R
WHERE ABS(R.TotalDue - R.TotalCalculado) >= 0.01
    OR R.TotalCalculado IS NULL