# FIND TEAMS THAT REACHED PLAYOFFS AFTER LOSING FIRST GROUP MATCH AT WORLD CUP

DROP PROCEDURE IF EXISTS PLAYOFFS;
DELIMITER $$
CREATE PROCEDURE PLAYOFFS(TOURNAMENT_YEAR INT)
BEGIN
	WITH T1 AS
	(SELECT DATE,home_team,away_team,home_score,away_score
	FROM results 
	WHERE tournament='FIFA WORLD CUP' AND YEAR(DATE)=TOURNAMENT_YEAR
	UNION 
	SELECT DATE,AWAY_team,HOME_team,AWAY_score,HOME_score
	FROM results
	WHERE tournament='FIFA WORLD CUP' AND YEAR(DATE)=TOURNAMENT_YEAR)
	,T2 AS
	(SELECT T1.*, ROW_NUMBER() OVER(PARTITION BY HOME_TEAM ORDER BY DATE, HOME_TEAM) AS RN
	FROM T1)
	,T3 AS
	(SELECT DISTINCT HOME_TEAM 
	FROM T2
	WHERE RN=1 AND HOME_SCORE<AWAY_SCORE)

	, T4 AS
	(SELECT home_team, HOME_MATCHES+AWAY_MATCHES AS TOTAL_MATCHES
	FROM
	(SELECT HOME_TEAM, COUNT(HOME_TEAM) AS HOME_MATCHES
	FROM results R
	WHERE tournament='FIFA WORLD CUP' AND YEAR(DATE)=TOURNAMENT_YEAR
	GROUP BY HOME_TEAM) A
	LEFT JOIN
	(SELECT AWAY_TEAM, COUNT(AWAY_TEAM) AS AWAY_MATCHES
	FROM results R
	WHERE tournament='FIFA WORLD CUP' AND YEAR(DATE)=TOURNAMENT_YEAR
	GROUP BY AWAY_TEAM) B
	ON A.HOME_TEAM=B.AWAY_TEAM)
	SELECT *
	FROM T4
	WHERE TOTAL_MATCHES>3 AND HOME_TEAM IN (SELECT HOME_TEAM FROM T3);
END$$

CALL  PLAYOFFS(1990);