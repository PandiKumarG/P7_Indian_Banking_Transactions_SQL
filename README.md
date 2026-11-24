# Project 7 – Indian Banking Transactions Analysis using SQL

## Project Overview
This project focuses on analyzing Indian banking transaction data using PostgreSQL. The objective is to explore transaction performance, high-value debit transactions, regional transaction trends, and loan portfolio patterns to derive meaningful business insights.

## Dataset Description
- **Dataset:** Indian Banking Transactions 2019–2024
- **Total Records:** 550,000
- **Total Columns:** 18
- **Database:** PostgreSQL

The dataset contains information about customer transactions, account types, transaction amounts, transaction channels, geographical locations, credit scores, and loan details.

## Business Requirements

The project addresses the following analytical requirements:

**1. Transaction Channel and Type Performance Analysis**
- Evaluate transaction performance across different channels and transaction types.
- Analyze successful, failed, pending, and reversed transactions.
- Calculate transaction failure percentages.

**2. Identifying High-Value Debit Transactions Across States**
- Identify the top five distinct high-value transaction ranks within each state.
- Focus on successful debit transactions.
- Apply window functions to rank transactions.

**3. Regional Transaction Activity Analysis**
- Analyze monthly transaction activity across geographical regions.
- Compare transaction volumes and values for credit and debit transactions.
- Use a supplementary state-to-region mapping table.

**4. Loan Portfolio Analysis**

**Q4(a) – Identifying Above-Average Loan Types**
- Calculate total EMI obligations for each loan type.
- Identify loan types whose total EMI exceeds the average of the loan-type-wise total EMI values.

**Q4(b) – Classifying Borrowers by Credit Score**
- Classify borrowers into High, Medium, and Low credit-score categories.
- Analyze the number of borrowers in each category.

## Key SQL Concepts Applied
- SQL Fundamentals and Aggregate Functions
- Common Table Expressions (CTEs)
- Subqueries and Nested Subqueries
- INNER JOIN
- Window Functions (DENSE_RANK)
- Conditional Aggregation
- CASE WHEN
- Date and Time Functions
- GROUP BY and HAVING
- Data Type Conversion and Formatting

## Project Files
- `project_7_indian_banking_transactions.sql` – SQL queries developed to address the business requirements.
- `P7_Indian_Banking_Transactions_SQL_Documentation.txt` – Project documentation covering the dataset and analytical requirements.

## Tools and Technologies
- PostgreSQL
- SQL
- GitHub

## Project Objective
To strengthen practical SQL skills by solving business-oriented analytical problems using banking transaction data and applying fundamental and intermediate SQL concepts to derive meaningful insights.
