/*
1) Exercise
The database contains details of companions, and the episodes each appeared in:
Use this to list the names of the companions who haven't featured in any episodes.
You should find there's one of them, but we won't spoil the surprise by saying who it is!
Create a query based on the companions table, with an outer join to the episode companion table.
*/

-- First, let's check the tables to understand what kind of data we have
SELECT TOP 3 * FROM tblCompanion

SELECT TOP 3 * FROM tblEpisodeCompanion

-- To do so, we need to join two tables and see who doesn't have CompanionID in tblEpisodeCompanion,
-- which means this person hasn't appeared in any of the listed episodes
SELECT * FROM tblCompanion c
LEFT JOIN tblEpisodeCompanion ec
	ON c.CompanionId = ec.CompanionId
WHERE ec.CompanionId IS NULL

-- It appears that Sarah Jane Smith hasn't appeared in any of the episodes. Poor girl!

/*
2) Create a query which lists out all of the events in the tblEvent table which happened after
the last one for country 21 (International) took place.
*/

SELECT
	e.EventName
	,e.EventDate
	,c.CountryName
FROM tblEvent e
LEFT JOIN tblCountry c
	ON c.CountryID = e.CountryID -- join this to get the name of the country, not only its ID
WHERE e.EventDate > (
	SELECT MAX(EventDate)
	FROM tblEvent
	WHERE CountryID = 21
	)
ORDER BY e.EventDate DESC;


/*
3) Exercise 
Write a query which lists out countries which have more than 8 events,
using a correlated subquery rather than HAVING. That is: list the names of countries from the countries table
where for each country the number of events matching the country's id is more than 8.
*/

SELECT
	c.CountryName
FROM tblCountry c
WHERE 8 < ( -- we'll check if number of events > 8
	SELECT
		COUNT(e.EventID)
	FROM tblEvent e
	WHERE c.CountryID = e.CountryID -- link CountryID of events and countries
	)

/*
4) Exercise
The aim of this exercise is to show the number of events whose descriptions contain the words this and/or that:

To do this you can find all events whose EventDetails column contains the word this or that respectively, using the LIKE keyword.
In a single query solution you would have to use a CASE expression to determine the value of IfThis and IfThat,
then group by the same CASE expression.
This is messy, and makes it hard to make subsequent changes to your expression (as you have to do it in two places).
*/

WITH ThisAndThat AS (
	SELECT
		CASE WHEN EventDetails LIKE '%this%' THEN 1 ELSE 0 END AS IfThis
		,CASE WHEN EventDetails LIKE '%that%' THEN 1 ELSE 0 END AS IfThat
	FROM tblEvent e
	)

SELECT
	tat.IfThis
	,tat.IfThat
	,COUNT(*) AS 'Number of events'
FROM ThisAndThat tat
GROUP BY IfThis, IfThat

/*
If you get this working and still have spare time, try changing or extending your query to show the 3 events
whose details contain both this and that:
*/

WITH ThisAndThat AS (
	SELECT
		CASE WHEN EventDetails LIKE '%this%' 
			AND EventDetails LIKE '%that%'
				THEN e.EventID
		END AS both
	FROM tblEvent e
	)

SELECT
	e.EventName
	,e.EventDetails
FROM tblEvent e
LEFT JOIN ThisAndThat tat ON e.EventID = tat.both
WHERE tat.both IS NOT NULL


/*
5) The aim of this exercise is to list out all the continents which have:
• At least 3 countries; but also
• At most 10 events. It's worth noting that there are many ways to solve this in SQL,
but as is so often the case CTEs seem to give the most intuitive approach.
*/

WITH ManyCountries AS (
	SELECT
		ctt.ContinentID AS Countries_ContinentID
		,ctt.ContinentName AS Countries_ContinentName
	FROM tblContinent ctt
	WHERE 3 < (
		SELECT
			COUNT(c.CountryID)
		FROM tblCountry c
		WHERE c.ContinentID = ctt.ContinentID
		GROUP BY c.ContinentID
		)
),

FewEvents AS (
	SELECT
		ctt.ContinentID AS Events_ContinentID
		,ctt.ContinentName AS Events_ContinentName
	FROM tblContinent ctt
	WHERE 10 >= (
		SELECT
			COUNT(e.EventID)
		FROM tblEvent e
		LEFT JOIN tblCountry c ON c.CountryID = e.CountryID
		WHERE ctt.ContinentID = c.ContinentID
		GROUP BY c.ContinentID
		)
)

SELECT * FROM ManyCountries mc
LEFT JOIN FewEvents fe ON mc.Countries_ContinentID = fe.Events_ContinentID
WHERE (mc.Countries_ContinentID IS NOT NULL) AND (fe.Events_ContinentID IS NOT NULL)
-- And it's Africa!


/*
6) The aim of this exercise is to count the number of events by a column called Era which you'll calculate,
without including this calculation twice:
To do this, you can do the calculation in two bites, using a CTE to hold the intermediate stage.
*/

WITH CTE_era AS (
	SELECT
		CASE
			WHEN YEAR(e.EventDate) < 1900 THEN '19th century and earlier'
			WHEN YEAR(e.EventDate) < 2000 THEN '20th century'
			ELSE '21 century'
			END AS Era
		,e.EventID
	FROM tblEvent e
)

SELECT
	e.Era AS Era
	,COUNT(e.EventID) AS 'Number of events'
FROM CTE_era e
GROUP BY Era


/*
7) Exercise !!! Before you can do this exercise, you'll need to download and unzip this file
Create a query to show for each episode the series number, year and episode id:
Now store this in a CTE, and pivot it to show the number of episodes by year and series number for the first 5 series:
*/

WITH CTE_episode AS (
	SELECT
		YEAR(e.EpisodeDate) AS EpisodeYear
		,e.SeriesNumber AS SeriesNumber
		,e.EpisodeId AS EpisodeId
	FROM tblEpisode e
)

SELECT * FROM CTE_episode AS et
PIVOT(
		COUNT(EpisodeId)
		FOR SeriesNumber IN ([1], [2], [3], [4], [5])
) AS p