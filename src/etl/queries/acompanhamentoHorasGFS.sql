INSERT INTO DW_AT.alice.acompanhamentoHorasGFS
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
ORDER BY
    FORMAT(
        CASE 
            WHEN DAY(dcal.[data]) >= 26 
            THEN DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1))
            ELSE DATEFROMPARTS(YEAR(dcal.[data]), MONTH(dcal.[data]), 1)
        END, 
        'yyyy-MM-01'
    ) DESC,
    duser.nome