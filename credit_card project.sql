-- Query 1: Top 5 cities with the highest spends and their percentage contribution of total credit card spends
WITH cte_top_cities AS (
    SELECT
        DISTINCT city,
        SUM(CAST(amount AS DECIMAL(18,2))) OVER (PARTITION BY city) AS sum_city,
        SUM(CAST(amount AS DECIMAL(18,2))) OVER () AS total_amount
    FROM
        [dbo].[credit_card_transcations]
)
SELECT 
    TOP 5 city,
    sum_city,
    total_amount,
    CONCAT(CAST((sum_city / NULLIF(total_amount,0)) * 100 AS NUMERIC(10,2)), '%') AS percentage_contribution
FROM 
    cte_top_cities
ORDER BY 
    sum_city DESC;

-- Query 2: Highest spend month and amount spent in that month for each card type
WITH cte_highest_spend AS (
    SELECT
        DISTINCT YEAR(transaction_date) AS year_transaction,
        MONTH(transaction_date) AS month_transaction, 
        card_type,
        SUM(CAST(amount AS BIGINT)) AS total_spent_month
    FROM 
        [dbo].[credit_card_transcations]
    GROUP BY 
        YEAR(transaction_date),
        MONTH(transaction_date), 
        card_type
)
SELECT 
    *
FROM 
    (SELECT 
        *, 
        RANK() OVER(PARTITION BY card_type ORDER BY total_spent_month DESC) AS rn 
    FROM 
        cte_highest_spend) a
WHERE 
    rn = 1;

-- Query 3: Transaction details for each card type when it reaches a cumulative of 1000000 total spends
WITH cte_cumulative_spends AS (
    SELECT 
        *, 
        SUM(CAST(amount AS BIGINT)) OVER (PARTITION BY card_type ORDER BY transaction_date, transaction_id) AS total_spent
    FROM 
        [dbo].[credit_card_transcations]
)
SELECT 
    *
FROM 
    (SELECT 
        *, 
        RANK() OVER (PARTITION BY card_type ORDER BY total_spent) AS rn
    FROM 
        cte_cumulative_spends
    WHERE 
        total_spent >= 1000000) a
WHERE 
    rn = 1;

-- Query 4: City with the lowest percentage spend for Gold card type
WITH cte_city_spends AS (
    SELECT 
        DISTINCT city, 
        card_type,
        SUM(CAST(amount AS NUMERIC(18,4))) OVER (PARTITION BY card_type, city) AS total_spent,
        SUM(CAST(amount AS NUMERIC(18,4))) OVER (PARTITION BY card_type) AS sum_amount
    FROM 
        [dbo].[credit_card_transcations]
    WHERE 
        card_type = 'Gold'
)
SELECT 
    TOP 1 *
FROM 
    (SELECT 
        *, 
        (total_spent / sum_amount) * 100 AS percentage_contribution
    FROM 
        cte_city_spends) a
ORDER BY 
    percentage_contribution;


-- Query 5: City, highest_expense_type, and lowest_expense_type
WITH cte_city_expenses AS (
    SELECT  
        city, 
        exp_type,
        SUM(CAST(amount AS NUMERIC(18,0))) AS total_amount
    FROM 
        [dbo].[credit_card_transcations]
    GROUP BY 
        city, 
        exp_type
)
SELECT 
    city,
    MAX(CASE WHEN rn_low = 1 THEN exp_type END) AS lowest_exp_type,
    MAX(CASE WHEN rn_high = 1 THEN exp_type END) AS highest_exp_type
FROM 
    (SELECT 
        *, 
        RANK() OVER(PARTITION BY city ORDER BY total_amount DESC) AS rn_low,
        RANK() OVER(PARTITION BY city ORDER BY total_amount ASC) AS rn_high
    FROM 
        cte_city_expenses) a
GROUP BY 
    city;


-- Query 6: Percentage contribution of spends by females for each expense type
WITH cte_female_spends AS (
    SELECT 
        Gender,
        SUM(CASE WHEN exp_type = 'Grocery' AND gender ='f' THEN CAST(amount AS BIGINT) END) AS sum_of_grocery,
        SUM(CASE WHEN exp_type = 'Food' AND gender ='f' THEN CAST(amount AS BIGINT) END) AS sum_of_Food,
        SUM(CASE WHEN exp_type = 'Travel' AND gender ='f' THEN CAST(amount AS BIGINT) END) AS sum_of_Travel,
        SUM(CASE WHEN exp_type = 'Entertainment' AND gender ='f' THEN CAST(amount AS BIGINT) END) AS sum_of_Entertainment,
        SUM(CASE WHEN exp_type = 'Fuel' AND gender ='f' THEN CAST(amount AS BIGINT) END) AS sum_of_Fuels,
        SUM(CASE WHEN exp_type = 'Bills' AND gender ='f' THEN CAST(amount AS BIGINT) END) AS sum_of_Bills,
        SUM(CAST(amount AS BIGINT)) AS total
    FROM
        [dbo].[credit_card_transcations]
    WHERE
        gender = 'f'
    GROUP BY
        Gender
)
SELECT  
    Gender, 
    CONCAT(CAST(sum_of_grocery * 1.0 / total * 100 AS NUMERIC(18,2)), '%') AS Grocery,
    CONCAT(CAST(sum_of_food * 1.0 / total * 100 AS NUMERIC(18,2)), '%') AS Food,
    CONCAT(CAST(sum_of_travel * 1.0 / total * 100 AS NUMERIC(18,2)), '%') AS Travel,
    CONCAT(CAST(sum_of_entertainment * 1.0 / total * 100 AS NUMERIC(18,2)), '%') AS Entertainment,
    CONCAT(CAST(sum_of_fuels * 1.0 / total * 100 AS NUMERIC(18,2)), '%') AS Fuels,
    CONCAT(CAST(sum_of_bills * 1.0 / total * 100 AS NUMERIC(18,2)), '%') AS Bills,
    CONCAT(CAST(total / total * 100 AS NUMERIC(18,2)), '%') AS Total_Amount
FROM 
    cte_female_spends;


-- Query 7: Card and expense type combination with highest month over month growth in Jan-2014
WITH cte_monthly_growth AS (
    SELECT 
        card_type, 
        exp_type, 
        DATEPART(YEAR, transaction_date) AS yt,
        DATEPART(MONTH, transaction_date) AS mt,
        SUM(amount) AS total_spend
    FROM 
        credit_card_transcations
    GROUP BY 
        card_type, 
        exp_type, 
        DATEPART(YEAR, transaction_date), 
        DATEPART(MONTH, transaction_date)
)
SELECT  
    TOP 1 *, 
    (total_spend - prev_month_spend) AS mom_growth
FROM 
    (
        SELECT 
            *,
            LAG(total_spend, 1) OVER(PARTITION BY card_type, exp_type ORDER BY yt, mt) AS prev_month_spend
        FROM 
            cte_monthly_growth
    ) A
WHERE 
    prev_month_spend IS NOT NULL AND yt = 2014 AND mt = 1
ORDER BY 
    mom_growth DESC;

-- Query 8: City with the highest total spend to total number of transactions ratio during weekends
SELECT 
    TOP 1 city, 
    SUM(amount) * 1.0 / COUNT(1) AS ratio
FROM 
    credit_card_transcations
WHERE 
    DATEPART(WEEKDAY, transaction_date) IN (1,7)
GROUP BY 
    city
ORDER BY 
    ratio DESC;


-- Query 9: City that took the least number of days to reach its 500th transaction after the first transaction in that city
WITH cte_transaction_dates AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER(PARTITION BY city ORDER BY transaction_date, transaction_id) AS rn
    FROM 
        credit_card_transcations
)
SELECT 
    TOP 1 city, 
    DATEDIFF(DAY, MIN(transaction_date), MAX(transaction_date)) AS datediff1
FROM 
    cte_transaction_dates
WHERE 
    rn = 1 OR rn = 500
GROUP BY 
    city
HAVING 
    COUNT(1) = 2
ORDER BY 
    datediff1;
