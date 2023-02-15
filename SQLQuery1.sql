-- Analyse Covid-19 Data Explorer from 04/02/2020 to 12/02/2023 source: ourworldindata.org

-- Looking at total cases Vs total deaths
-- Shows likelihood of dying if you contract covid in your country ordered by PercentageOfDeath

Select location, SUM(new_cases) as totalCases, SUM(new_deaths) as totalDeaths, SUM(new_deaths)/SUM(new_cases) as PercentageOfDeath
From PortfolioProject..CovidDeaths
Where continent is not null and location <> 'North Korea'
Group by location
ORDER BY PercentageOfDeath DESC

--Looking at Percentage of infected people per country ordered by Percentage of Infected

Select location, (SUM(new_cases)/population)*100  as PercentageOfInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by PercentageOfInfected DESC

--Same Analyse as before but using MAX function and showing population and total cases

Select location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100  as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by PercentagePopulationInfected DESC

--Showing Countries with the highest death count

Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount, Max(total_deaths/population)*100  as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by TotalDeathCount DESC

-- Showing continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount, Max(total_deaths/population)*100  as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount DESC

-- Global cases count vs deaths count

Select SUM(new_cases) as NewCasesCount, SUM(new_deaths) as NewDeathsCount, SUM(new_deaths)/SUM(new_cases) as PercentageofDeath--total_cases, total_deaths, (total_deaths/total_cases)*100  as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null

-- Looking at Total Population vs Vaccinations (Two differents tables)
-- Using Partition throughout date to get the total of vaccinations

SELECT dea.location, dea.date, population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric(18,0))) OVER (Partition by dea.location order by dea.date) as RollingVaccinations
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null


-- Same Selection statement as before but using CTE

WITH PopVsVac (location, date, population, new_vaccinations, RollingVaccinations)
as
(
SELECT dea.location, dea.date, population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric(18,0))) OVER (Partition by dea.location order by dea.date) as RollingVaccinations
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null
)
SELECT *, (RollingVaccinations/population)*100 as PercentageofVaccinationsPerPeople
From PopVsVac

-- Same Selection statement as before but using TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinations numeric,
)
INSERT INTO #PercentPopulationVaccinated

SELECT dea.location, dea.date, population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric(18,0))) OVER (Partition by dea.location order by dea.date) as RollingVaccinations
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null

SELECT *, (RollingVaccinations/population)*100 as PercentageofVaccinationsPerPeople
From #PercentPopulationVaccinated

-- Same Selection statement as before but creating a view for future visualizations

CREATE View PercentagePopulationVaccinated as 
SELECT dea.location, dea.date, population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric(18,0))) OVER (Partition by dea.location order by dea.date) as RollingVaccinations
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null