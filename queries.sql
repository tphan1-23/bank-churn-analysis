-- Bank churn analysis (SQLite). Table: customers, loaded from data/churn_clean.csv
-- Load: python -c "import pandas as pd,sqlite3; pd.read_csv('data/churn_clean.csv').to_sql('customers', sqlite3.connect('churn.db'), index=False, if_exists='replace')"

-- Q1. Overall churn rate
SELECT ROUND(AVG(Exited)*100, 2) AS churn_pct FROM customers;

-- Q2. Churn by geography
SELECT Geography, COUNT(*) AS customers, ROUND(AVG(Exited)*100, 2) AS churn_pct
FROM customers GROUP BY Geography ORDER BY churn_pct DESC;

-- Q3. Churn by age group
SELECT AgeGroup, COUNT(*) AS customers, ROUND(AVG(Exited)*100, 2) AS churn_pct
FROM customers GROUP BY AgeGroup ORDER BY churn_pct DESC;

-- Q4. Churn by number of products
SELECT NumOfProducts, COUNT(*) AS customers, ROUND(AVG(Exited)*100, 2) AS churn_pct
FROM customers GROUP BY NumOfProducts ORDER BY NumOfProducts;

-- Q5. Churn by active-member status
SELECT IsActiveMember, COUNT(*) AS customers, ROUND(AVG(Exited)*100, 2) AS churn_pct
FROM customers GROUP BY IsActiveMember;

-- Q6. High-value customers at risk: top balance tier, inactive
SELECT COUNT(*) AS customers, ROUND(AVG(Exited)*100, 2) AS churn_pct,
       ROUND(SUM(CASE WHEN Exited = 1 THEN Balance END)/1e6, 2) AS balance_lost_millions
FROM customers WHERE BalanceTier = 'Top' AND IsActiveMember = 0;

-- Q7. CTE: each Geography x AgeGroup x Activity segment vs the overall rate
WITH overall AS (SELECT AVG(Exited)*100 AS overall_pct FROM customers),
seg AS (
  SELECT Geography, AgeGroup, IsActiveMember, COUNT(*) AS customers, AVG(Exited)*100 AS churn_pct
  FROM customers GROUP BY Geography, AgeGroup, IsActiveMember
  HAVING COUNT(*) >= 100
)
SELECT Geography, AgeGroup, IsActiveMember, customers,
       ROUND(churn_pct, 1) AS churn_pct,
       ROUND(churn_pct - overall_pct, 1) AS pts_vs_overall,
       ROUND(churn_pct / overall_pct, 2) AS times_overall
FROM seg, overall ORDER BY churn_pct DESC LIMIT 10;
