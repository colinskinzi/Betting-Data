# Betting Data Analysis**

This document outlines the analysis process and key findings from the betting data.

-----

## **1. Data Sources**

The analysis used three datasets:

  * **`USERS.csv`**: Contains user demographics.
  * **`ACTIONS.csv`**: Records all user actions like `betting` and `deposits`.
  * **`BONUS.csv`**: Lists bonus details.

The data is linked by the **`USER_ID`**.

-----

## **2. Data Preparation and Cleaning**

The first step was cleaning and standardizing the data using SQL queries from [Data Cleaning SQL File](Betting_Data/Data%20Cleaning%20and%20exploration.sql). 
The main task was to fix inconsistent date formats.

  * **Date Standardization**: `DATE` columns had mixed formats. The `STR_TO_DATE()` function was used to convert all dates to a standard `YYYY-MM-DD` format.
  * **Duplicate Check**: A CTE was used to find and remove any duplicate user records.

-----

## **3. Data Analysis: Deriving Insights with SQL**

The core analysis used a complex SQL query from [Betting and Bonus Activity SQL File](Betting%20and%20Bonus%20Activity.sql). 
This query joins the clean data to calculate key metrics. It uses a series of CTEs for a logical process:

  * **`ExpandedBonus`**: This CTE handled the "ALL" user segment, creating separate records for 'player' and 'VIP'.
  * **`QualifiedBets`**: This CTE identified every bet that met bonus criteria based on date and amount.
  * **`BonusPayouts`**: This CTE calculated the final bonus payout for each user per day.
  * **Final Query**: The final query joins all data to produce a detailed report. It includes metrics like:
      * `no_of_bets_placed`
      * `deposit_amount`
      * `bet_amount`
      * `bet_won_amount`
      * `withdrawal_amount`
      * `total_bonus_payout`


## **4. 📊 Visualization and Reporting**

The project's final output is a Power BI dashboard, saved as:

  [PowerBI Dashboard](Betting%20Data%202024.pbix).

Dispalyed as: 
  [Betting data and Bonus data Dashboard](Gamdon_Dash.png) 

This dashboard visualizes the key metrics and insights. Please open the file to view the reports.


## **5🔧 Tools & Technologies

| Tool        | Purpose                                |
|-------------|----------------------------------------|
| **MySQL**   | Data preparation, cleaning & analysis  |
| **PowerBI** | Data modeling, visualize & dashboards  |
