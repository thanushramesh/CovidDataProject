--select the data we will be using
SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Finding Total Cases vs Total Deaths :\
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2

-- Shows liklihood of dying if you contact corona-virus in your country (taken the example of the United States here)
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'United States' 
order by 1,2

--We are looking at Total Cases vs Population, to see what percentage of population got covid.
SELECT location,date, total_cases, population, (total_cases/population)*100 AS PopulationInfectedPercent
from PortfolioProject..CovidDeaths
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(CAST(total_cases as int)) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Calculating the Numbers from across the world
Select SUM(new_cases) as cases_in_total, SUM(cast(new_deaths as int)) as deaths_in_total, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
order by 1,2

-- Comparing Total Population vs Vaccination
-- It shows the number of people that have taken the vaccinations compared to the entire population of that country 	 
select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations,
sum(convert(int, new_vaccinations)) over ( partition by deaths.location order by deaths.location, deaths.date) as Total_Population_Vaccinated
from PortfolioProject..CovidDeaths as Deaths
join PortfolioProject..CovidVaccinations as Vaccinations
on Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
where Deaths.continent is not null 
order by 2,3

-- Using CTE to perform Calculations on Partition By in previous query

With PopulationvsVaccination (Continent, Location, Date, Population, New_Vaccinations, Total_Population_Vaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as Total_Population_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as deaths
Join PortfolioProject..CovidVaccinations as vaccinations
	On deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null 

)
Select *, (Total_Population_Vaccinated/Population)*100 as Percent_of_People_Vaccinated 
From PopulationvsVaccination




-- Creating View for data visualization later
CREATE VIEW PercentPopulationVaccinatedView
 AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations,
	SUM(convert(int,vaccination.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.Date) as RollingPeopleVaccinated
FROM CovidDeaths AS deaths
JOIN CovidVaccinations AS vaccination
	ON deaths.location = vaccination.location
	AND deaths.date = vaccination.date
WHERE deaths.continent IS NOT NULL

