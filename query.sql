SELECT
    (quantity * price) AS total_amount
FROM
    orders
WHERE
    total_amount BETWEEN 2000000 AND 5000000;

