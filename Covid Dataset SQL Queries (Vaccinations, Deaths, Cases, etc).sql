Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
order by 1,2

--Total Cases vs Total Deaths
--Shows likelyhood of dying in Ireland if you get covid
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Ireland'
order by 1,2

--Total Cases Vs Population (Ireland)
Select Location, date, total_cases, population, (total_cases/population)*100 as PopPercentageIreland
From PortfolioProject..CovidDeaths
Where location like 'Ireland'
order by 1,2


--Countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationPercentageInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by PopulationPercentageInfected desc

--Countries with highest Death Count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

----Continents with death counts per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
 Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 where continent is not null
 Group By date
 Order By 1,2


 -- Total population Vs Vaccinations
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2 ,3

-- CTE (Common Table Expression)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2 ,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Create View GlobalNumber as
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 where continent is not null
 Group By date
 
