/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From [SqlProjectDatabase].[dbo].[Covid Deaths]
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From [SqlProjectDatabase].[dbo].[Covid Deaths]
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country


Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [SqlProjectDatabase].[dbo].[Covid Deaths]
Where location='india'
and continent is not null 
order by 1,2

--Total cases vs population
-- shows percentage of population got infected
select location,date,total_cases,population,(total_cases/population)*100 as PercentagePopulationInfected
from [SqlProjectDatabase].[dbo].[Covid Deaths]
--where location ='india'
order by 2

--Looking at how the infection rate is compare to population
select location,population,max(total_cases) as highestifectioncount,max((total_cases/population)*100) as PercentagePopulationInfected
from [SqlProjectDatabase].[dbo].[Covid Deaths]
group by location,population
order by PercentagePopulationInfected desc

-- Looking at countries with highest death count per population

-- select * from [SqlProjectDatabase].[dbo].[Covid Deaths] where continent is null

select location,max(total_deaths) as TotalDeathcount
from [SqlProjectDatabase].[dbo].[Covid Deaths]
where continent is not null
group by location
order by TotalDeathcount desc

--Let's breaking things down by continent
-- showing continents with highest deathcount per population
select continent,max(total_deaths) as TotalDeathcount
from [SqlProjectDatabase].[dbo].[Covid Deaths]
where continent is not null
group by continent
order by TotalDeathcount desc

--Global Numbers
select date,sum(new_cases) as Total_cases,sum(new_deaths) as Total_deaths,sum(new_deaths)/sum(new_cases)*100 as Deathpercentage
from [SqlProjectDatabase].[dbo].[Covid Deaths]
where continent is not null
group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine



With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [SqlProjectDatabase].[dbo].[Covid Deaths] dea
Join [SqlProjectDatabase].[dbo].[Covid Vaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists PercentagePopulationVaccinated
create table PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [SqlProjectDatabase].[dbo].[Covid Deaths] dea
Join [SqlProjectDatabase].[dbo].[Covid Vaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [SqlProjectDatabase].[dbo].[Covid Deaths] dea
Join [SqlProjectDatabase].[dbo].[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 