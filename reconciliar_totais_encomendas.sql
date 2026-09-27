-- reconciliar_totais_encomenda.sql
-- v1: verifica se o total do cabecalho bate com a soma das linhas
-- Autor: Joel Coxi

SELECT 
    A.SalesOrderID
    ,A.TotalDue
    ,B.TotalDueWithDiscount                 AS TotalCalculado
FROM Sales.SalesOrderHeader A
    LEFT JOIN (
        SELECT 
            SalesOrderID
            ,SUM(A.OrderQty * (A.UnitPrice * (1 - A.UnitPriceDiscount))) AS TotalDueWithDiscount
        FROM Sales.SalesOrderDetail A
        GROUP BY SalesOrderID
    ) B ON A.SalesOrderID = B.SalesOrderID 
WHERE A.TotalDue <> B.TotalDueWithDiscount
    OR B.TotalDueWithDiscount IS NULL

--43875
