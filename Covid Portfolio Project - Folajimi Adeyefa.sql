SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths 
 -- Shows the likelyhood of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- Looking at the Total Cases vs Population 
-- Shows what percentage of population got Covid

SELECT location, date, Population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
-- Where location like '%states%'
ORDER BY 1, 2


-- Looking at Countries with highest Infection rate compared to Population 

SELECT location, Population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population)) *100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
GROUP BY Location, Population
ORDER BY 4 DESC

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL  
GROUP BY Location
ORDER BY 2 DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT 


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL  
GROUP BY continent
ORDER BY 2 DESC


-- showing the continents with the highest death count per population 

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL  
GROUP BY continent
ORDER BY 2 DESC


-- GLOBAL NUMBERS 

SELECT  SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage 
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL 
--GROUP BY date 
ORDER BY 1, 2



-- Looking at Total Population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, CONVERT(int, vac.new_vaccinations),
SUM(CONVERT(bigint, vac.new_vaccinations) ) OVER (Partition BY dea.location ORDER BY dea.location, dea.Date) 
AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2, 3


-- USE CTE

WITH PopvsVac (Continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations) ) OVER (Partition BY dea.location ORDER BY dea.location, dea.Date) 
AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



--TEMP TABLE


DROP TABLE IF exists  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations) ) OVER (Partition BY dea.location ORDER BY dea.location, dea.Date) 
AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM  #PercentPopulationVaccinated



-- Creating View to store data for later visualization 


CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations) ) OVER (Partition BY dea.location ORDER BY dea.location, dea.Date) 
AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2, 3


SELECT *
FROM PercentPopulationVaccinatedd

