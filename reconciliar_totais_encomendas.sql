-- reconciliar_totais_encomenda.sql
-- v1: verifica se o total do cabecalho bate com a soma das linhas
-- Autor: Joel Coxi
SELECT 
    * 
FROM (
    SELECT 
        A.SalesOrderID
        ,A.TotalDue
        ,(B.TotalDueWithDiscount + A.Freight + A.TaxAmt)               AS TotalCalculado
    FROM Sales.SalesOrderHeader A
        LEFT JOIN (
            SELECT 
                SalesOrderID
                ,SUM(A.OrderQty * (A.UnitPrice * (1 - A.UnitPriceDiscount))) AS TotalDueWithDiscount
            FROM Sales.SalesOrderDetail A
            GROUP BY SalesOrderID
        ) B ON A.SalesOrderID = B.SalesOrderID 
) A
WHERE A.TotalDue <> A.TotalCalculado
    OR A.TotalCalculado IS NULL

--43875
