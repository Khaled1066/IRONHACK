-- LEVEL 1

-- Question 1: Number of users with sessions
SELECT u.name, u.surname, count(s.id)
FROM sessions s 
JOIN users u ON s.user_id = u.id
GROUP BY u.name, u.surname;


SELECT Count(distinct u.name)
FROM sessions s 
JOIN users u ON s.user_id = u.id;

-- Question 2: Number of chargers used by user with id 1
SELECT Count(distinct s.charger_id)
FROM sessions s 
JOIN users u ON s.user_id = u.id
WHERE s.user_id = 1;

-- LEVEL 2

-- Question 3: Number of sessions per charger type (AC/DC):
SELECT c.type, Count(s.charger_id)
FROM sessions s
RIGHT JOIN chargers c ON c.id = s.charger_id
GROUP BY c.type;


-- Question 4: Chargers being used by more than one user
SELECT charger_id, count(distinct user_id) AS num_user
FROM sessions
GROUP BY charger_id
HAVING count(distinct user_id) > 1;

-- Question 5: Average session time per charger

SELECT id , AVG(TIMESTAMPDIFF(minute, start_time, end_time)) AS avg_time_min
FROM sessions
GROUP BY id;

-- LEVEL 3

-- Question 6: Full username of users that have used more than one charger in one day (NOTE: for date only consider start_time)
WITH use_per_day AS (
SELECT s.user_id, DATE(start_time) AS days,  count(distinct s.id), COUNT(DISTINCT charger_id)
FROM sessions s
GROUP BY s.user_id, days
HAVING COUNT(DISTINCT charger_id) > 1),

users_full_name AS (
SELECT s.user_id, CONCAT(u.name, ' ', u.surname) AS full_name
FROM sessions s
JOIN users u ON u.id = s.user_id
GROUP BY s.user_id, u.name, u.surname)

SELECT distinct full_name
FROM users_full_name ufn
JOIN use_per_day upd ON ufn.user_id = ufn.user_id;


-- Question 7: Top 3 chargers with longer sessions

SELECT id , charger_id, AVG(TIMESTAMPDIFF(minute, start_time, end_time)) AS avg_time_min
FROM sessions
GROUP BY id, Charger_id
ORDER BY avg_time_min DESC
LIMIT 3;

WITH charger_rankings AS (
 SELECT 
        s.charger_id, 
        AVG(TIMESTAMPDIFF(HOUR, s.start_time, s.end_time)) AS avg_session_duration,
        DENSE_RANK() OVER (ORDER BY AVG(TIMESTAMPDIFF(HOUR, s.start_time, s.end_time)) DESC) AS rank1
    FROM 
        sessions s
    GROUP BY 
        s.charger_id)
        
SELECT 
    charger_id, avg_session_duration
FROM 
    charger_rankings
WHERE 
    rank1 <= 3;


-- Question 8: Average number of users per charger (per charger in general, not per charger_id specifically)
WITH session_counts AS (
SELECT c.type, COUNT(s.user_id) AS session_count
FROM chargers c
JOIN sessions s ON c.id = s.charger_id
GROUP BY c.type)

SELECT type, AVG(session_count)
FROM session_counts
GROUP BY type;


-- Question 9: Top 3 users with more chargers being used
WITH ChargerCounts AS (
	SELECT s.user_id, COUNT(DISTINCT s.charger_id) AS charger_count
	FROM sessions s
	GROUP BY s.user_id),

RankedChargerCounts AS (
	SELECT cc.user_id,
           DENSE_RANK() OVER (ORDER BY charger_count DESC) AS ranked
    FROM ChargerCounts cc)

SELECT rcc.user_id, rcc.ranked
FROM RankedChargerCounts rcc
WHERE rcc.ranked <= 3;


-- LEVEL 4

-- Question 10: Number of users that have used only AC chargers, DC chargers or both
####

WITH users_type AS (  
    SELECT 
        s.user_id, 
        c.type
    FROM 
        sessions s
    JOIN 
        chargers c ON s.charger_id = c.id
),
users_ac AS (
    SELECT 
        ut.user_id
    FROM 
        users_type ut
    GROUP BY 
        ut.user_id
    HAVING 
        COUNT(DISTINCT ut.type) = 1 AND 
        MAX(ut.type) = 'AC'  -- Ensuring the only type is AC
),
users_dc AS (
    SELECT 
        ut.user_id
    FROM 
        users_type ut
    GROUP BY 
        ut.user_id
    HAVING 
        COUNT(DISTINCT ut.type) = 1 AND 
        MAX(ut.type) = 'DC'  -- Ensuring the only type is DC
)

SELECT 
    'AC' AS charger_type, 
    COUNT(user_id) AS user_count
FROM 
    users_ac
UNION ALL
SELECT 
    'DC' AS charger_type, 
    COUNT(user_id) AS user_count
FROM 
    users_dc;
    
SELECT c.type, s.user_id
FROM sessions s
JOIN chargers c ON s.charger_id = c.id
GROUP BY c.type
HAVING COUNT(DISTINCT c.type) = 1
ORDER BY s.user_id;

SELECT 
    s.user_id, 
    MAX(c.type) AS charger_type
FROM 
    sessions s
JOIN 
    chargers c ON s.charger_id = c.id
GROUP BY 
    s.user_id
HAVING 
    COUNT(DISTINCT c.type) = 1;  -- Only users with one distinct charger type


-- Question 11: Monthly average number of users per charger

WITH session_counts AS (
SELECT c.id, COUNT(s.user_id) AS session_count
FROM chargers c
JOIN sessions s ON c.id = s.charger_id
GROUP BY c.id)

SELECT id, AVG(session_count)
FROM session_counts
GROUP BY id;

-- Question 12: Top 3 users per charger (for each charger, number of sessions)

WITH charger_user AS(
	SELECT s.charger_id, s.user_id, COUNT(s.id) AS use_num
	FROM sessions s
	GROUP BY s.charger_id, s.user_id),

RankedChargerPerUser AS (
	SELECT cu.charger_id, 
			cu.user_id,
			DENSE_RANK() OVER (partition by cu.charger_id ORDER BY cu.use_num DESC) AS ranked
	FROM charger_user cu)
    
SELECT rcpu.charger_id, rcpu.user_id, rcpu.ranked
FROM RankedChargerPerUser rcpu
WHERE ranked <= 3
ORDER BY rcpu.charger_id;
    

-- LEVEL 5

-- Question 13: Top 3 users with longest sessions per month (consider the month of start_time)

WITH RankedSessions AS (
		SELECT  s.user_id, 
				s.id ,
				dense_rank() OVER (ORDER BY timestampdiff(hour, s.start_time, s.end_time) DESC) AS diff
		FROM sessions s)

SELECT  rs.user_id, 
    rs.id, 
    rs.diff
FROM 
    RankedSessions rs
WHERE 
    rs.diff <= 3;
    
-- Question 14. Average time between sessions for each charger for each month (consider the month of start_time)

WITH SessionDifferences AS (
    SELECT 
        s.charger_id,
        s.start_time,
        TIMESTAMPDIFF(
            HOUR, 
            LAG(s.start_time) OVER (PARTITION BY s.charger_id ORDER BY s.start_time), 
            s.start_time
        ) AS time_between_sessions,
        DATE_FORMAT(s.start_time, '%Y-%m') AS session_month
    FROM 
        sessions s
)
SELECT 
    sd.charger_id,
    sd.session_month,
    AVG(sd.time_between_sessions) AS avg_time_between_sessions
FROM 
    SessionDifferences sd
WHERE 
    sd.time_between_sessions IS NOT NULL
GROUP BY 
    sd.charger_id, 
    sd.session_month
ORDER BY 
    sd.charger_id, 
    sd.session_month;











