
SELECT *
FROM PortProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortProject.. CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if contacted with Covid in USA
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortProject.. CovidDeaths
WHERE location like '%states%' and continent is NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- shows that percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortProject.. CovidDeaths
WHERE location like '%states%' and continent is NOT NULL
ORDER BY 1,2


-- looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortProject.. CovidDeaths
--WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortProject.. CovidDeaths
--WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- break things down by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortProject.. CovidDeaths
--WHERE location like '%states%'
WHERE continent is NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


-- showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortProject.. CovidDeaths
--WHERE location like '%states%'
WHERE continent is NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


-- global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortProject.. CovidDeaths
--WHERE location like '%states%' 
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2



-- looking at total pop vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccincated
, (RollingPeopleVaccinated/population)*100
From PortProject..CovidDeaths dea
JOIN PortProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3


-- USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccincated
--, (RollingPeopleVaccinated/population)*100
From PortProject..CovidDeaths dea
JOIN PortProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
From PopVsVac



-- Create View to store data for later visuals


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccincated
--, (RollingPeopleVaccinated/population)*100
From PortProject..CovidDeaths dea
JOIN PortProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3


SELECT * 
FROM PercentPopulationVaccinated