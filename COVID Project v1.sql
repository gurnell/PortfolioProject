Select *
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations$
--order by 3,4

--select the data

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
order by 1,2

--total cases vs total deaths
--likelihood of someone dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
where Location = 'Kenya'
order by 1,2

--total cases vs population
--what percentage of the poplation has contracted covid

Select Location, date, total_cases, population, (total_cases/population) * 100 as PopulationPercentageInfected
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
--where Location like '%Kenya%'
order by 1,2

--countries with highest infection rate compared to population
Select Location, MAX(total_cases) as max_infection, population, MAX(total_cases/population) * 100 as PopulationPercentageInfected
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
--where Location like '%Kenya%'
group by Location, population
order by PopulationPercentageInfected desc

--countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
--where Location like '%Kenya%'
group by Location
order by total_death_count desc



--BREAKING DOWN BY CONTINENT

--continents with highest death counts

Select continent, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
--where Location like '%Kenya%'
group by continent
order by total_death_count desc


--GLONAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
--where Location = 'Kenya'
where continent is not null
order by 1,2

Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
--where Location = 'Kenya'
where continent is not null
group by date
order by 1,2

--total population vs vaccinations

Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM (CONVERT (int, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ d
Join PortfolioProject.dbo.CovidVaccinations$ v
   On d.location = v.location
   and d.date = v.date
where d.continent is not null
order by 2,3


--USE CTE 

With PopVsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated) as 
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM (CONVERT (int, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ d
Join PortfolioProject.dbo.CovidVaccinations$ v
   On d.location = v.location
   and d.date = v.date
where d.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopVsVac


--TEMP TABLE

DROP Table if exists #PercentRollingVaccinated
Create Table #PercentRollingVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentRollingVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM (CONVERT (int, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ d
Join PortfolioProject.dbo.CovidVaccinations$ v
   On d.location = v.location
   and d.date = v.date
--where d.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentRollingVaccinated

    
--create Views for later visualizations

CREATE VIEW PercentRollingVaccinated as 
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM (CONVERT (int, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ d
Join PortfolioProject.dbo.CovidVaccinations$ v
   On d.location = v.location
   and d.date = v.date
where d.continent is not null
--order by 2,3

Select * 
From  PercentRollingVaccinated


--global numbers view

Create View GlobalNumbers as
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
--where Location = 'Kenya'
where continent is not null
--order by 1,2