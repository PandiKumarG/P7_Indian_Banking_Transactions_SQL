/*
Q1. Transaction Channel and Type Performance Analysis

Business Requirement:
The bank wants to evaluate the operational reliability of different transaction channels and transaction types. 
Analyze transaction records to identify which channel and transaction-type combinations experience higher transaction failure rates.

Expected Output Columns:
1. channel
2. transaction_type
3. total_transactions
4. successful_transactions
5. failed_transactions
6. pending_transactions
7. reversed_transactions
8. failure_percentage
Mandatory SQL Concepts:
- GROUP BY
- Aggregate Functions (COUNT)
- Conditional Aggregation
- Common Table Expression (CTE)
- CASE WHEN
- ROUND
Additional Requirements:
- Consider all transaction records.
- Calculate failure percentage as:
\[
\text{Failure Percentage} =
\frac{\text{Failed Transactions}}{\text{Total Transactions}}\times 100
\]

- Group the results by both channel and transaction_type.
- Sort the results by failure percentage in descending order.
Business Objective: Identify transaction channels and types with comparatively higher failure rates so the bank can investigate operational issues and improve transaction reliability.
*/

WITH classify_transaction AS (
    SELECT
        channel,
        transaction_type,
        COUNT(transaction_id) AS total_transactions,
        COUNT(
            CASE
                WHEN transaction_status = 'Success' THEN 1
            END
        ) AS successful_transactions, 
        COUNT(
            CASE 
                WHEN transaction_status = 'Failed' THEN 1
            END
        ) AS failed_transactions,
        COUNT(
            CASE
                WHEN transaction_status = 'Pending' THEN 1
            END
        ) AS pending_transactions,
        COUNT(
            CASE
                WHEN transaction_status = 'Reversed' THEN 1
            END
        ) AS reversed_transactions
    FROM project_7_indian_banking_transactions
    GROUP BY channel, transaction_type
)

SELECT
    channel,
    transaction_type,
    total_transactions,
    successful_transactions,
    failed_transactions,
    pending_transactions,
    reversed_transactions,
    ROUND((CAST(failed_transactions AS NUMERIC) / total_transactions) * 100, 2) AS failure_percentage
FROM classify_transaction
ORDER BY failure_percentage DESC;

/*
Q2. Identifying High-Value Debit Transactions Across States

Business Requirement:
The bank wants to identify the highest-value successful debit transactions in each state. 
Analyze transaction records to identify the top five highest-value debit transactions per state for transaction monitoring.

Expected Output Columns:
1. state
2. transaction_id
3. customer_id
4. transaction_date
5. transaction_type
6. channel
7. amount
8. transaction_rank

Mandatory SQL Concepts:
- Window Functions (DENSE_RANK)
- PARTITION BY
- ORDER BY
- WHERE
- SELECT

Additional Requirements:
- Consider only transactions where transaction_direction = 'Debit'.
- Consider only transactions where transaction_status = 'Success'.
- Rank transactions separately within each state based on amount in descending order.
- Display the top five distinct transaction amount ranks in each state.
- If multiple transactions have the same amount, assign them the same rank.
- Sort the final output by state and transaction rank.
*/

WITH transaction_rank_calc AS (
    SELECT
        "state",
        transaction_id,
        customer_id,
        transaction_date,
        transaction_type,
        channel,
        transaction_amount,
        DENSE_RANK() OVER (
            PARTITION BY "state"
            ORDER BY transaction_amount DESC
        ) AS transaction_rank
    FROM project_7_indian_banking_transactions
    WHERE transaction_direction = 'Debit' AND transaction_status = 'Success'
),

rank_filtering AS (
    SELECT
        "state",
        transaction_id,
        customer_id,
        transaction_date,
        transaction_type,
        channel,
        transaction_amount,
        transaction_rank
    FROM transaction_rank_calc
    WHERE transaction_rank <= 5
)

SELECT
    "state",
    transaction_id,
    customer_id,
    transaction_date,
    transaction_type,
    channel,
    transaction_amount,
    transaction_rank
FROM rank_filtering
ORDER BY "state", transaction_rank

/*
Q3. Regional Transaction Activity Analysis

Business Requirement:
The bank wants to understand how transaction activity varies across different geographical regions of India. 
Analyze monthly transaction activity by region to identify regional differences in transaction volume and transaction value.

Expected Output Columns:
1. region
2. transaction_month
3. total_transactions
4. total_transaction_amount
5. credit_transactions
6. debit_transactions
7. total_credit_amount
8. total_debit_amount
Mandatory SQL Concepts:
- INNER JOIN
- GROUP BY
- Aggregate Functions (COUNT, SUM)
- Date/Time Functions (DATE_TRUNC)
- Conditional Aggregation
Additional Requirements:
- Create a supplementary table named state_region_mapping.
- Table structure:
Column	Data type
state	VARCHAR
region	VARCHAR

- Map each state in the primary dataset to its corresponding Indian geographical region.
- Join the primary transaction table with the supplementary table using state.
- Group the results by region and calendar month.
- Include both credit and debit transactions.
- Sort the output by region and transaction month in ascending order.
Business Objective: Understand regional transaction activity and monthly changes in credit and debit volumes to support geographical business planning.
*/

CREATE TABLE state_region_mapping (
    "state" VARCHAR(20) NOT NULL,
    "region" VARCHAR(20) NOT NULL
)

INSERT INTO state_region_mapping ("state", "region")
VALUES
    ('Maharashtra', 'West'),
    ('Gujarat', 'West'),
    ('Rajasthan', 'North'),
    ('Uttar Pradesh', 'North'),
    ('Punjab', 'North'),
    ('Tamil Nadu', 'South'),
    ('Karnataka', 'South'),
    ('Telangana', 'South'),
    ('West Bengal', 'East'),
    ('Assam', 'Northeast')

SELECT * FROM state_region_mapping

WITH aggregation_calc_on_groups AS(
    SELECT
        supp_tab.region AS region,
        SUBSTRING(CAST(DATE_TRUNC('month', TO_DATE(transaction_date, 'MM/DD/YYYY')) AS TEXT), 1, 7) AS transaction_month,
        COUNT(transaction_id) AS total_transactions,
        SUM(transaction_amount) AS total_transaction_amount,
        COUNT(
            CASE
                WHEN transaction_direction = 'Credit' THEN 1
            END 
        ) AS credit_transactions,
        COUNT(
            CASE
                WHEN transaction_direction = 'Debit' THEN 1
            END 
        ) AS debit_transactions,
        SUM(
            CASE
                WHEN transaction_direction = 'Credit' THEN transaction_amount
            END
        ) AS total_credit_amount,
        SUM(
            CASE
                WHEN transaction_direction = 'Debit' THEN transaction_amount
            END
        ) AS total_debit_amount
    FROM project_7_indian_banking_transactions AS main_tab
    INNER JOIN state_region_mapping AS supp_tab
        ON main_tab."state" = supp_tab.state
    GROUP BY supp_tab.region, SUBSTRING(CAST(DATE_TRUNC('month', TO_DATE(transaction_date, 'MM/DD/YYYY')) AS TEXT), 1, 7)
)

SELECT 
    region,
    transaction_month,
    total_transactions,
    total_transaction_amount,
    credit_transactions,
    debit_transactions,
    total_credit_amount,
    total_debit_amount
FROM aggregation_calc_on_groups
ORDER BY region ASC, transaction_month ASC

/*
Q4(a) – Identifying Above-Average Loan Types

Business Requirement:
The bank wants to identify loan types whose total EMI obligations are higher than the 
average total EMI obligation across all loan types.

Expected Output Columns:
1. loan_type
2. total_borrowers
3. total_emi
Mandatory SQL Concepts:
- Subquery
- GROUP BY
- Aggregate Functions (COUNT, SUM)
- HAVING
Additional Requirements:
- Consider only records where has_loan = 1.
- Exclude Unknown loan types.
- Count distinct borrowers for each loan type.
- Display only loan types whose total EMI exceeds the average total EMI obligation across loan types.
- Sort by total_emi in descending order.
*/

SELECT 
    loan_type,
    COUNT(DISTINCT customer_id) AS total_borrowers,
    SUM(emi_amount) AS total_emi
FROM project_7_indian_banking_transactions
WHERE has_loan = 1 AND loan_type IS NOT NULL
GROUP BY loan_type
HAVING SUM(emi_amount) > (
    SELECT 
        AVG(total_emi_by_loan_type)
    FROM (
        SELECT
            SUM(emi_amount) AS total_emi_by_loan_type
        FROM project_7_indian_banking_transactions
        WHERE has_loan = 1 AND loan_type IS NOT NULL
        GROUP BY loan_type
    )
)

/*
Q4(b) – Classifying Borrowers by Credit Score

Business Requirement:
The bank wants to classify borrowers into credit-score categories to understand the credit profile of its loan customers.

Expected Output Columns:
1. credit_score_category
2. total_borrowers

Mandatory SQL Concepts:
- CASE WHEN
- GROUP BY
- Aggregate Functions (COUNT)

Additional Requirements:
- Consider only records where has_loan = 1.
- Classify borrowers into these categories:
  - High: Credit score 750 or above.
  - Medium: Credit score from 650 to 749.
  - Low: Credit score below 650.
- Count distinct borrowers in each category.

Intermediate concept: Conditional classification using CASE WHEN.
*/

WITH classify_credit_score AS (
    SELECT
        credit_score,
        customer_id,
        CASE 
            WHEN credit_score >= 750 THEN 'High'
            WHEN credit_score >= 650 THEN 'Medium'
            ELSE 'Low'
        END AS credit_score_category
    FROM project_7_indian_banking_transactions
    WHERE has_loan = 1 
),

count_calc AS (
    SELECT
        credit_score_category,
        COUNT(DISTINCT customer_id) AS total_borrowers
    FROM classify_credit_score
    GROUP BY credit_score_category
)

SELECT 
    credit_score_category,
    total_borrowers
FROM count_calc
ORDER BY  total_borrowers ASC;


