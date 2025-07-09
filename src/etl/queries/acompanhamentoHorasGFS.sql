   
-- ************************************* Acompanhamento de Horas da Fabrica de Software *********************************************

-- Scrip de Criação da Tabela
CREATE TABLE DW_AT.alice.acompanhamentoHorasGFS (
    nome VARCHAR(100) NOT NULL,
    totalHorasTrabalhadas DECIMAL(10, 2) NOT NULL,
    totalHorasMes INT NOT NULL,
    percentualProdutividade DECIMAL(10, 2) NOT NULL,
    variacaoProdutividade DECIMAL(10, 2) NOT NULL, -- Pode ser negativo ou positivo
    categoriaProdutividade VARCHAR(50) NOT NULL,
    indiceTendencia VARCHAR(50) NOT NULL,
    mesAno DATE NOT NULL,
    nomeMes VARCHAR(20) NOT NULL,
    ano INT NOT NULL,
    CONSTRAINT PK_acompanhamentoHorasGFS PRIMARY KEY (mesAno, nome)
);    
    
-- Scrip de Extração e Inserção de Dados
WITH ProdutividadeDados AS (
    SELECT
        UPPER('Operações') AS processo,
        UPPER('Produtividade - GFS') AS indicador,
        duser.nome,
        CAST(SUM(f.completedwork) AS NUMERIC(10, 2)) AS totalHorasTrabalhadas,
        CAST(COALESCE(r.totalHorasMes, 0) AS INT) AS totalHorasMes,
        FORMAT(
            CASE
                WHEN DAY(dcal.[data]) >= 26
                THEN DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1))
                ELSE DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1)
            END,
            'yyyy-MM-01'
        ) AS mesAno,
        dc.nomemes,
        dc.ano
    FROM
        analytic.fatoworkitems f
    INNER JOIN analytic.dimuser duser
        ON duser.skdimuser = f.skdimuserresponsavel
        AND duser.versaotual = 1
        AND duser.ativo IS NULL
        AND duser.[local] IN ('Desenvolvimento', 'Infra')
        AND duser.gestao IS NULL
    LEFT JOIN analytic.dimcalendario dcal
        ON dcal.skdimcalendario = f.skcalendarclosed
        AND dcal.fimdesemana = 0
    LEFT JOIN (
        SELECT
            duser.nome,
            SUM(f.finalcapacity) AS totalHorasMes,
            FORMAT(
                CASE
                    WHEN DAY(dcal.[data]) >= 26
                    THEN DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1))
                    ELSE DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1)
                END,
                'yyyy-MM-01'
            ) AS data
        FROM
            analytic.fatoiterationcapacity f
        INNER JOIN analytic.dimuser duser
            ON duser.skdimuser = f.skdimuser
            AND duser.versaotual = 1
            AND duser.ativo IS NULL
            AND duser.[local] IN ('Desenvolvimento', 'Infra')
        INNER JOIN analytic.dimcalendario dcal
            ON dcal.skdimcalendario = f.skcalendarsprintdate
            AND dcal.fimdesemana = 0
        GROUP BY
            duser.nome,
            FORMAT(
                CASE
                    WHEN DAY(dcal.[data]) >= 26
                    THEN DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1))
                    ELSE DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1)
                END,
                'yyyy-MM-01'
            )
    ) AS r
        ON r.nome = duser.nome
        AND r.data = FORMAT(
            CASE
                WHEN DAY(dcal.[data]) >= 26
                THEN DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1))
                ELSE DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1)
            END,
            'yyyy-MM-01'
        )
    LEFT JOIN analytic.dimcalendario dc ON
        dc.[data] = FORMAT(
            CASE
                WHEN DAY(dcal.[data]) >= 26
                THEN DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1))
                ELSE DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1)
            END,
            'yyyy-MM-01'
        )
    WHERE FORMAT(
            CASE
                WHEN DAY(dcal.[data]) >= 26
                THEN DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1))
                ELSE DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1)
            END,
            'yyyy-MM-01'
        ) IS NOT NULL
    GROUP BY
        duser.nome,
        dc.nomemes,
        dc.ano,
        r.totalHorasMes,
        FORMAT(
            CASE
                WHEN DAY(dcal.[data]) >= 26
                THEN DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1))
                ELSE DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1)
            END,
            'yyyy-MM-01'
        )
),
ProdutividadeCalculada AS (
    SELECT
        processo,
        indicador,
        nome,
        totalHorasTrabalhadas,
        totalHorasMes,
        -- Calcula percentualProdutividade, evitando divisão por zero
        ROUND(COALESCE((totalHorasTrabalhadas / NULLIF(totalHorasMes, 0)) * 100, 0), 2) AS percentualProdutividade,
        mesAno,
        nomemes,
        ano
    FROM
        ProdutividadeDados
),
ProdutividadeComVariacao AS (
    SELECT
        processo,
        indicador,
        nome,
        totalHorasTrabalhadas,
        totalHorasMes,
        percentualProdutividade,
        -- Calcula VariacaoProdutividade usando o percentual já calculado
        (percentualProdutividade - LAG(percentualProdutividade, 1, 0) OVER (PARTITION BY nome ORDER BY mesAno)) AS VariacaoProdutividade,
        -- Categoria de Produtividade
        CASE
            WHEN percentualProdutividade >= 90 THEN 'Excelente'
            WHEN percentualProdutividade >= 80 THEN 'Atingiu Meta'
            WHEN percentualProdutividade >= 70 THEN 'Perto da Meta'
            ELSE 'Abaixo da Meta'
        END AS CategoriaProdutividade,
        mesAno,
        nomemes,
        ano
    FROM
        ProdutividadeCalculada
)
INSERT INTO DW_AT.alice.acompanhamentoHorasGFS(
nome,
totalHorasTrabalhadas,
totalHorasMes,
percentualProdutividade,
variacaoProdutividade,
categoriaProdutividade,
indiceTendencia,
mesAno,
nomeMes,
ano
)
SELECT
    nome,
    totalHorasTrabalhadas,
    totalHorasMes,
    percentualProdutividade,
    variacaoProdutividade,
    categoriaProdutividade,
    -- Indicação de Tendência
    CASE
        WHEN VariacaoProdutividade > 5 THEN 'Melhora Significativa' -- Aumento acima de 5 pontos percentuais
        WHEN VariacaoProdutividade >= 0.1 AND VariacaoProdutividade <= 5 THEN 'Melhora Leve' -- Aumento entre 0.1 e 5 pontos percentuais
        WHEN VariacaoProdutividade < -5 THEN 'Piora Significativa' -- Queda acima de 5 pontos percentuais
        WHEN VariacaoProdutividade <= -0.1 AND VariacaoProdutividade >= -5 THEN 'Piora Leve' -- Queda entre 0.1 e 5 pontos percentuais
        ELSE 'Estável' -- Variação muito pequena (entre -0.1 e 0.1) ou zero
    END AS indiceTendencia,
    mesAno,
    nomemes,
    ano
FROM
    ProdutividadeComVariacao
ORDER BY
    mesAno DESC,
    nome;