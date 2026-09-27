# sales-order-reconciliation

Script de reconciliação entre o total registado no cabeçalho de uma encomenda e o total recalculado a partir das suas linhas de detalhe, com tratamento explícito de casos onde a reconciliação não é directa (arredondamento, ausência de detalhe).

## O que faz

Compara o valor total de cada encomenda (`TotalDue`, no cabeçalho) com o valor recalculado a partir das linhas de detalhe, e classifica cada uma como reconciliada, não reconciliada, ou sem dados suficientes para reconciliar.

## Porque existe

Numa base de vendas típica, o valor total de uma encomenda existe em duas frentes que deviam sempre bater certo, o cabeçalho (`SalesOrderHeader`), que já traz o total final incluindo frete e impostos, e o detalhe (`SalesOrderDetail`), uma linha por artigo vendido, com quantidade, preço e desconto. Reconciliar os dois é a forma de apanhar erros de cálculo, actualizações incompletas, ou inconsistências entre sistemas, o mesmo tipo de verificação que aplico regularment, entre sistemas core e camadas analíticas.

Três decisões técnicas sustentam o resultado:

- **Tolerância de 0,01**, para não marcar como discrepância o ruído normal de arredondamento em valores monetários, em vez de exigir igualdade exacta.
- **`ISNULL` aplicado na origem** (`Freight`, `TaxAmt`), para que um valor nulo nesses campos nunca seja confundido com ausência de linhas de detalhe, dois problemas com causas diferentes, que exigem respostas diferentes.
- **Estado próprio para "sem linhas de detalhe"**, em vez de excluir essas encomendas do resultado ou de as classificar por engano como reconciliadas. Um relatório de reconciliação que esconde os casos que não conseguiu avaliar é mais perigoso do que um que os mostra em aberto.

## Como correr

- **Motor**: SQL Server (T-SQL), com CTEs e `ISNULL`, compatível com SQL Server 2012 em diante.
- **Base de dados**: base de exemplo AdventureWorks (`AdventureWorks2019` ou mais recente), tabelas `Sales.SalesOrderHeader` e `Sales.SalesOrderDetail`.
- **Execução**: abre `reconciliar_totais_encomendas.sql` num cliente como o SQL Server Management Studio ou o Azure Data Studio, liga-te a uma instância com a AdventureWorks restaurada, e corre o script completo.
- **Resultado esperado**: uma linha por encomenda com estado enviado (`Status = 5`), com as colunas `TotalDue`, `TotalCalculado`, `Delta` e `StatusReconciliacao`, esta última com um de três valores, `Reconciliado`, `Não reconciliado` ou `Sem linhas de detalhe`.

---

**Joel Coxi** · [LinkedIn](https://www.linkedin.com/in/joel-coxi)