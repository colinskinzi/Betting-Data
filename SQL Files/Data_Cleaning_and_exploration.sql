SELECT * FROM betting_data.users;

-- ##Adjusting the Date coumn to my SQL syntax, by creating a backup for the date column. ##
ALTER TABLE USERS
ADD COLUMN USER_CREATION_DATE_OLD VARCHAR(20);
UPDATE USERS
SET USER_CREATION_DATE_OLD = USER_CREATION_DATE;

-- ##converting the date for mySQL format
UPDATE USERS
SET USER_CREATION_DATE = STR_TO_DATE(USER_CREATION_DATE, '%d/%m/%Y');

-- ##converting the column type
ALTER TABLE USERS
MODIFY COLUMN USER_CREATION_DATE DATE;

-- ##deleting the backup.  
ALTER TABLE USERS
DROP COLUMN USER_CREATION_DATE_OLD;


-- ##Checking for DUPLICATES using a CTE
with duplicates as
(
select *,
row_number() over(
partition by user_id, user_type, user_creation_date) as row_num
from betting_data.users
)
select * from duplicates
where row_num > 1;


-- ##I Repeat the process for all data sets( BONUS AND ACTIONS)

SELECT * FROM betting_data.bonus;

-- ##creating a backup for the date column. 
ALTER TABLE BONUS
ADD COLUMN BONUS_START_DATE_OLD VARCHAR(20);
UPDATE BONUS
SET BONUS_START_DATE_OLD = BONUS_START_DATE;

-- ##converting the date for mySQL format
UPDATE BONUS
SET BONUS_START_DATE = STR_TO_DATE(BONUS_START_DATE, '%d/%m/%Y');

-- ##converting the column type
ALTER TABLE BONUS
MODIFY COLUMN BONUS_START_DATE DATE;

##deleting he backup.  
ALTER TABLE BONUS
DROP COLUMN BONUS_START_DATE_OLD;

SELECT * FROM betting_data.actions;

-- ##Since there are different date formats in Actions Data, I use a STR_TO_DATE TO change mySQL FORMAT
SELECT 
  DATE,
  STR_TO_DATE(DATE, '%d/%m/%Y') AS parsed_1,
  STR_TO_DATE(DATE, '%Y-%m-%d') AS parsed_2
  FROM ACTIONS
LIMIT 20;

UPDATE ACTIONS
SET DATE = STR_TO_DATE(DATE, '%d/%m/%Y')
WHERE DATE LIKE '__/__/____';

UPDATE ACTIONS
SET DATE = STR_TO_DATE(DATE, '%Y-%m-%d')
WHERE DATE LIKE '____-__-__';

-- ##Checking for invalid dates.
SELECT COUNT(*) AS invalid_dates
FROM ACTIONS
WHERE STR_TO_DATE(DATE, '%Y-%m-%d') IS NULL
  AND DATE IS NOT NULL;

-- ##creating a backup for the date column. 
ALTER TABLE ACTIONS
ADD COLUMN DATE_OLD VARCHAR(20);
UPDATE ACTIONS
SET DATE_OLD = DATE;

-- ##converting the date for mySQL format
UPDATE ACTIONS
SET DATE = STR_TO_DATE(DATE, '%Y-%m-%d');

-- ##converting the column type
ALTER TABLE ACTIONS
MODIFY COLUMN DATE DATE;

-- ##deleting the backup.  
ALTER TABLE ACTIONS
DROP COLUMN DATE_OLD;
