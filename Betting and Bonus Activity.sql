WITH ExpandedBonus AS (
    -- This CTE expands the bonus table to include all user segments
    SELECT
        BONUS_NAME,
        BONUS_AMOUNT,
        BONUS_THRESHOLD,
        BONUS_START_DATE,
        BONUS_END_DATE,
        USER_SEGMENT
    FROM betting_data.bonus
    WHERE USER_SEGMENT != 'ALL'

    UNION ALL

    SELECT
        BONUS_NAME,
        BONUS_AMOUNT,
        BONUS_THRESHOLD,
        BONUS_START_DATE,
        BONUS_END_DATE,
        'player' AS USER_SEGMENT
    FROM betting_data.bonus
    WHERE USER_SEGMENT = 'ALL'

    UNION ALL

    SELECT
        BONUS_NAME,
        BONUS_AMOUNT,
        BONUS_THRESHOLD,
        BONUS_START_DATE,
        BONUS_END_DATE,
        'VIP' AS USER_SEGMENT
    FROM betting_data.bonus
    WHERE USER_SEGMENT = 'ALL'
),

QualifiedBets AS (
    -- This CTE identifies all bets that qualify for a bonus
    SELECT
        a.date,
        u.USER_TYPE,
        u.User_ID,
        a.amount,
        b.BONUS_NAME,
        b.BONUS_AMOUNT,
        b.BONUS_THRESHOLD,
        b.BONUS_START_DATE,
        b.BONUS_END_DATE,

        -- Handle grouping logic for bonuses
        CASE
            WHEN b.BONUS_NAME = 'Welcome Bonus' THEN 'welcome_window'
            ELSE DATE_FORMAT(b.BONUS_START_DATE, '%Y-%m')
        END AS BONUS_PERIOD_KEY,

        ROW_NUMBER() OVER (
            PARTITION BY
                u.User_ID,
                b.BONUS_NAME,
                CASE
                    WHEN b.BONUS_NAME = 'Welcome Bonus' THEN 'welcome_window'
                    ELSE DATE_FORMAT(b.BONUS_START_DATE, '%Y-%m')
                END
            ORDER BY a.date
        ) AS bonus_usage_rank
    FROM
        betting_data.actions a
    INNER JOIN betting_data.users u
        ON a.user_id = u.user_id
    INNER JOIN ExpandedBonus b
        ON u.user_type = b.user_segment
        AND a.date BETWEEN b.BONUS_START_DATE AND b.BONUS_END_DATE
        AND a.amount >= b.BONUS_THRESHOLD
    WHERE
        a.ACTION_TYPE = 'bet'
),

FilteredQualifiedBets AS (
    -- This CTE selects only one bonus per bonus name per month (or bonus period)
    SELECT *
    FROM QualifiedBets
    WHERE bonus_usage_rank = 1
),

RankedQualifiedBets AS (
    -- This CTE ranks multiple bonuses for a single bet, picking the highest one
    SELECT
        date,
        user_type,
        user_id,
        amount,
        bonus_name,
        bonus_amount AS bonus_payout,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, date, amount
            ORDER BY bonus_amount DESC, bonus_name ASC
        ) AS bonus_rank
    FROM FilteredQualifiedBets
),

BonusPayouts AS (
    -- This CTE aggregates the final bonus payouts per user per day
    SELECT
        date,
        user_id,
        SUM(bonus_payout) AS total_bonus_payout,
        -- Use GROUP_CONCAT to list all bonuses a user might have received on the same day
        GROUP_CONCAT(bonus_name SEPARATOR ', ') AS bonus_names
    FROM RankedQualifiedBets
    WHERE bonus_rank = 1
    GROUP BY date, user_id
)

-- The final query combines all user activity with the bonus payouts
SELECT
    a.DATE,
    u.User_ID,
    u.USER_TYPE,
    SUM(CASE WHEN a.action_type = 'bet' THEN 1 ELSE 0 END) AS no_of_bets_placed,
    SUM(CASE WHEN a.ACTION_TYPE = 'deposit' THEN a.AMOUNT ELSE 0 END) AS deposit_amount,
    SUM(CASE WHEN a.ACTION_TYPE = 'bet' THEN a.AMOUNT ELSE 0 END) AS bet_amount,
    SUM(CASE WHEN a.ACTION_TYPE = 'bet_win' THEN a.AMOUNT ELSE 0 END) AS bet_won_amount,
    SUM(CASE WHEN a.ACTION_TYPE = 'withdrawal' THEN a.AMOUNT ELSE 0 END) AS withdrawal_amount,
    COALESCE(b.total_bonus_payout, 0) AS total_bonus_payout,
    b.bonus_names
FROM betting_data.users u
LEFT JOIN betting_data.actions a
    ON u.User_ID = a.USER_ID
LEFT JOIN BonusPayouts b
    ON u.User_ID = b.user_id
    AND a.DATE = b.date
GROUP BY
    a.DATE,
    u.User_ID,
    u.USER_TYPE,
    b.total_bonus_payout,
    b.bonus_names

ORDER BY
    a.DATE, u.User_ID;
