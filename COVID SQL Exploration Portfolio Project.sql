/*

To be used for a Tableau project

*/

-- 1.

SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not NULL
order by 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not NULL
order by 1,2


-- Calculate Total Cases vs. Total Deaths
-- Display likelihood of dying if you contract COVID-19 in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
Where location like '%states%'
order by 1,2


-- Display Total Cases vs. Population
-- Shows percentage of population which got COVID-19

SELECT location, date, population, total_cases, (total_cases/population)*100 as PopulationWithCovid
FROM PortfolioProject.dbo.CovidDeaths$
Where location like '%states%'
order by 1,2


-- Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCountry, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
GROUP BY location, population
order by PercentPopulationInfected desc


-- Look at countires with highest death count per population

SELECT location, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
WHERE continent is not NULL
GROUP BY location
order by TotalDeathCount desc


-- Continent now

SELECT location, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
WHERE continent is NULL
GROUP BY location
order by TotalDeathCount desc


-- Showing continents with the highest death count

SELECT continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
WHERE continent is not NULL
GROUP BY continent
order by TotalDeathCount desc


-- Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinatedByDate
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



-- USE CTE

WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinatedByDate)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinatedByDate
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (PeopleVaccinatedByDate/Population)*100 
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinatedByDate numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinatedByDate
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (PeopleVaccinatedByDate/Population)*100 
FROM #PercentPopulationVaccinated


-- Creating Several Views to store data for later visualizations

-- Percentage of Population Vaccinated per location

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinatedByDate
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

-- Total # of COVID Deaths per continent
CREATE VIEW TotalDeathsPerContinent as
SELECT location, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
WHERE continent is NULL
GROUP BY location
--order by TotalDeathCount desc

-- Total deaths per country 
CREATE VIEW TotalDeathsPerCountry as
SELECT location, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
WHERE continent is not NULL
GROUP BY location
--order by TotalDeathCount desc

--Chance of dying in US from COVID by date
CREATE VIEW DeathPercentageUnitedStates as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
Where location like '%states%'
--order by 1,2

--Global numbers of COVID-19



--SELECT * FROM
--PercentPopulationVaccinated

