SELECT
    *,
    CASE WHEN total_amount > 4000000 THEN
        'Nguy hiểm'
    ELSE
        'Bình thường'
    END AS alert_level
FROM
    orders
WHERE
    total_amount BETWEEN 2000000 AND 5000000
    AND status <> 'CANCELLED'
    AND (note LIKE '%gấp%'
        OR user_id IS NULL)
ORDER BY
    total_amount DESC
LIMIT 20 OFFSET 40;

