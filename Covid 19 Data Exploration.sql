/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--COVID DEATHS
SELECT * FROM CovidDeaths
WHERE 
	continent is NOT NULL 
ORDER BY 3, 4


--COVID VACCINATIONS
select *
FROM CovidVaccinations
WHERE 
	continent is NOT NULL 
ORDER BY 3, 4


--Select Data that we are going to be using
SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM 
	CovidDeaths
WHERE 
	continent is NOT NULL
ORDER BY 1,2

--Loking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT
	location,
	date, 
	total_cases, 
	total_deaths, 
	(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM
	CovidDeaths
WHERE 
	location LIKE '%Canada%'
	AND continent is NOT NULL
ORDER BY 
	1,2 DESC


--Loking at Total Cases vs Population

--Shows what percentage of population got covid on daily bases (datewise)


-- Looking at countries with highest covid infection compared to population(Shows what percentage of population got covid)
SELECT 
	location, 
	population, 
	MAX(cast(Total_cases as bigint)) as HighestInfectionRate, 
	MAX(total_cases/population)* 100 as PercentageOfPopulationInfected
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY
	location, population
ORDER BY
	PercentageOfPopulationInfected desc

-- Looking at countries with highest covid infection compared to population(Shows what percentage of population got covid By date)
--Countries with high infection rate by Month/Year (--)
SELECT 
	date,
	location, 
	population, 
	MAX(Total_cases) as HighestInfectionRate, 
	MAX(total_cases/population)* 100 as PercentageOfPopulationInfected
from CovidDeaths
where continent is NOT NULL
GROUP BY
	date,location, population
ORDER BY
	PercentageOfPopulationInfected desc
	

--Showing Total cases and Total number of death of each Country 
SELECT
	continent,
	location AS Country, 
	MAX(CAST(total_cases AS BIGINT)) AS Total_cases,
	MAX(cast (total_deaths as bigint)) as Total_Number_Of_Deaths
FROM CovidDeaths
WHERE 
	continent is NOT NULL
GROUP BY 
	continent, 
	location
ORDER BY Total_cases DESC;



--Showing Countries with Highest Number Of Deaths
SELECT
	location, 
	MAX(cast (total_deaths as bigint)) as Total_Number_Of_Death
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY Total_Number_Of_Death desc




--LETS BREAK THINGS DOWN BY CONTINENT
--Showing Continent with highest number of death

WITH contdeath(location, continent,Total_Number_Of_Death)
AS
(
	SELECT
		location,
		continent,
		MAX(cast (total_deaths as bigint)) as Total_Number_Of_Death
	FROM CovidDeaths
	WHERE continent is NOT NULL 
	GROUP BY continent, location
)
SELECT 
	continent,
	SUM(Total_Number_Of_Death) as TotalDeaths
	FROM contdeath
	GROUP BY continent
	order by TotalDeaths desc



--Showing what percentage of the population of each Continent died

WITH popcontdeath (continent, Total_Population, Total_Number_Of_Death)
AS
(
    SELECT
        continent,
        MAX(CAST(population AS BIGINT)) AS Total_Population,
        MAX(CAST(total_deaths AS BIGINT)) AS Total_Number_Of_Death
    FROM CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY continent
)
SELECT
    continent,
    SUM(Total_Population) AS Total_Population,
    SUM(Total_Number_Of_Death) AS TotalDeaths,
    (SUM(Total_Number_Of_Death) * 100.0) / SUM(Total_Population) AS Percentage_Of_Population_Dead
FROM popcontdeath
GROUP BY continent
ORDER BY TotalDeaths DESC;




--COVID DEATH GLOBAL NUMBERS

WITH globaldeath (location, continent, Total_cases, Total_Number_Of_Death)
AS
(
    SELECT
        location,
		continent,
        MAX(CAST(total_cases AS BIGINT)) AS Total_cases,
        MAX(CAST(total_deaths AS BIGINT)) AS Total_Number_Of_Death
    FROM CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY continent, location
)
SELECT
    SUM(Total_cases) AS Total_cases,
    SUM(Total_Number_Of_Death) AS TotalDeaths,
    (SUM(Total_Number_Of_Death) * 100.0) / SUM(Total_cases) AS Death_Percentage
FROM globaldeath




--Looking at Covid Vaccination

--Total Number People Vaccinated by Continent(Number of people that have taken at least one dose of the vaccination)
--and Total Number of People Fully Vaccinated by Continent(Number of people that have taken complete  dose of the vaccination)


WITH continentvaccine 
	(continent, 
	Total_People_Vacinated_per_country,
	Total_People_fully_vaccinated_per_country) 
	AS
(
	SELECT 
		continent,
		max(cast (people_vaccinated as bigint)) as Total_People_Vacinated_per_country,
		max(cast (people_fully_vaccinated as bigint)) as Total_People_fully_vaccinated_per_country
	FROM CovidVaccinations
	WHERE continent is NOT NULL
	GROUP BY continent
)
SELECT 
	continent,
	SUM(Total_People_Vacinated_per_country) as Total_People_Vacinated,
	SUM(Total_People_fully_vaccinated_per_country) as Total_People_fully_vaccinated
FROM  continentvaccine
GROUP BY continent
ORDER BY Total_People_Vacinated DESC 


--Total Number People Vaccinated by country(Number of people that have taken at least one dose of the vaccination)
--and Total Number of People Fully Vaccinated by country(Number of people that have taken complete  dose of the vaccination)
WITH countryvaccination 
	(location, 
	Total_People_Vacinated_per_country,
	Total_People_fully_vaccinated_per_country) 
	AS
(
	SELECT 
		location,
		max(cast (people_vaccinated as bigint)) as Total_People_Vacinated_per_country,
		max(cast (people_fully_vaccinated as bigint)) as Total_People_fully_vaccinated_per_country
	FROM CovidVaccinations
	WHERE continent is NOT NULL
	GROUP BY location
)
SELECT 
	location,
	SUM(Total_People_Vacinated_per_country) as Total_People_Vacinated,
	SUM(Total_People_fully_vaccinated_per_country) as Total_People_fully_vaccinated
FROM  countryvaccination
GROUP BY location
ORDER BY Total_People_Vacinated DESC 


--Total People Vaccinated Globally (Number of people that have taken at least one dose of the vaccination)
-- AND Number of People Fully Vaccinated Globally
WITH globalvaccination 
(location, 
Total_People_Vacinated,
Total_People_fully_vaccinated) 
AS
(
	SELECT 
		location,
		max(cast (people_vaccinated as bigint)) as Total_People_Vacinated,
		max(cast (people_fully_vaccinated as bigint)) as Total_People_fully_vaccinated
	FROM CovidVaccinations 
	WHERE continent is NOT NULL
	GROUP BY location
)
SELECT 
	sum(Total_People_Vacinated) as Total_People_Vacinated_Globally,
	sum(Total_People_fully_vaccinated) as Total_People_fully_vaccinated_Globally 
FROM  globalvaccination
ORDER BY Total_People_Vacinated_Globally DESC




-- Looking at Percentage of Population of People Partially Vaccinated and Fully Vaccinated 


--Percentage of Population of People Vaccinated by country(Number of people that have taken at least one dose of the vaccination)
--and Percentage of the Population of People Fully Vaccinated by country(Number of people that have taken complete  dose of the vaccination)
WITH PercPopVac 
	(location, 
	Total_Population,
	Total_People_Vacinated_per_country,
	Total_People_fully_vaccinated_per_country) 
	AS
(
	SELECT 
		d.location,
		max(population) as Total_Population,
		max(cast (people_vaccinated as bigint)) as Total_People_Vacinated_per_country,
		max(cast (people_fully_vaccinated as bigint)) as Total_People_fully_vaccinated_per_country
	FROM CovidVaccinations v
	FULL JOIN CovidDeaths d
	ON v.location = d.location
	WHERE d.continent is NOT NULL
	GROUP BY d.location
)
SELECT 
	location,
	SUM(Total_Population) as Total_Population,
	SUM(Total_People_Vacinated_per_country) as Total_People_Vacinated,
	SUM(Total_People_fully_vaccinated_per_country) as Total_People_fully_vaccinated,
	(SUM(Total_People_Vacinated_per_country)* 100)/SUM(Total_Population) AS Percentage_Of_People_Vacinated,
	(SUM(Total_People_fully_vaccinated_per_country)* 100) /SUM(Total_Population) AS Percentage_Of_People_fully_vaccinated
FROM  PercPopVac
GROUP BY location
ORDER BY Total_People_Vacinated DESC


--Percentage of Population of the People Vaccinated Globally (Number of people that have taken at least one dose of the vaccination)
-- AND Percentage of Population of the People Fully Vaccinated Globally
WITH PercPopVac 
(location, 
Total_Population,
Total_People_Vaccinated,
Total_People_fully_vaccinated) 
AS
(
    SELECT 
        d.location,
        MAX(population) AS Total_Population,
        MAX(CAST(people_vaccinated AS BIGINT)) AS Total_People_Vaccinated,
        MAX(CAST(people_fully_vaccinated AS BIGINT)) AS Total_People_fully_vaccinated
    FROM CovidVaccinations v
    JOIN CovidDeaths d ON v.location = d.location
    WHERE d.continent IS NOT NULL
    GROUP BY d.location
)
SELECT 
    SUM(Total_Population) AS Total_Population,
    SUM(Total_People_Vaccinated) AS Total_People_Vaccinated_Globally,
    SUM(Total_People_fully_vaccinated) AS Total_People_fully_vaccinated_Globally,
    (SUM(Total_People_Vaccinated) * 100.0) / SUM(Total_Population) AS Percentage_of_People_Vaccinated_Globally,
    (SUM(Total_People_fully_vaccinated) * 100.0) / SUM(Total_Population) AS Percentage_of_People_fully_vaccinated_Globally
FROM PercPopVac
ORDER BY Total_People_Vaccinated_Globally DESC;




