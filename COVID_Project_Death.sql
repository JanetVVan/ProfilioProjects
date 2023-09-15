SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM 
--PortfolioProject.dbo.CovidVaccinations
--ORDER BY
--3,4

SELECT location, date,total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths = death_percentage
-- likelihood of dying if contract covid in the uk 
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100  AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%kingdom%'
ORDER BY 1,2

-- Total Cases vs Population
-- Percentage of population got covid in the uk
SELECT location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100  AS population_infected_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%kingdom%'
ORDER BY 1,2

-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100  AS population_infected_percentage
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location,population
ORDER BY population_infected_percentage DESC

-- Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS total_deaths_count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_deaths_count DESC

--  Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) AS total_deaths_count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_deaths_count DESC


-- Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2


SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM pop_vs_vac


-- Temp table

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated