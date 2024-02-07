# Credit_Card_Analysis

## Overview

This project entails analyzing credit card transactions data to extract insights into spending patterns, card usage, and transaction trends. The dataset contains detailed information about credit card transactions, including transaction amounts, dates, cities, card types, and expenditure types.

## Dataset

Create a database called Credit_card

Create a table with [dataset](https://github.com/Tamil-Selvan-R/Credit_Card_Analysis/tree/main/Dataset)


**Credit Card Transactions Dataset**
        Contains information about credit card transactions, including transaction amounts, dates, cities, card types, and expenditure types.

 
 ## Analysis Tasks 
   1. Identify the top 5 cities with the highest spends and their percentage contribution of total credit card spends.
   2. Determine the highest spend month and the amount spent in that month for each card type.
   3. Find transaction details for each card type when it reaches a cumulative total spend of $1,000,000.
   4. Discover the city with the lowest percentage spend for Gold card type.
   5. Print the city, highest_expense_type, and lowest_expense_type.
   6. Find the percentage contribution of spends by females for each expense type.
   7. Determine the card and expense type combination with the highest month over month growth in January 2014.
   8. Identify the city with the highest total spend to total number of transactions ratio during weekends.
   9. Find the city that took the least number of days to reach its 500th transaction after the first transaction in that city.

## SQL Techniques Used for Analysis

**Key SQL Functions/Concepts Utilized:**

 1.  **Window Functions:** SUM() OVER(), RANK(), LAG(), LEAD() for efficient data navigation.
 2.  **Aggregation:** SUM(), COUNT(), GROUP BY, PARTITION BY for summarizing data.
 3.  **String Manipulation:** CONCAT() for string concatenation.
 4.  **Common Table Expressions (CTE):** Used to streamline complex queries.
 5.  **Subqueries:** Filtering data based on specified conditions.

## Project Structure 

   1. **data/:** Contains the dataset for credit card transactions.
   2. **scripts/:** SQL scripts for importing data and performing analysis.
   3. **presentation/:** Presentation slides summarizing key findings.

## Credits

Throughout the development of this project, I have sought information from **Namaste SQL**.

## Conclusion

The project successfully analyzed credit card transactions data, revealing insights into spending patterns, card usage, and transaction trends. These findings can be valuable for financial institutions in understanding customer behavior and improving services.

Happy Coding!
