--Ensure the both of the tables are uploaded effectively
select*
from [Portfolio Project(Covid-19)]..coviddeaths$
where continent is not null
order by 3,4

select*
from [Portfolio Project(Covid-19)]..coviidvaccinations$
order by 3,4

--Selecting data to be used 
select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project(Covid-19)]..coviddeaths$
order by 1,2

--Total Cases vs Total Deaths 
--Likelihhod of dying if you contract covid in a specific country 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage 
from [Portfolio Project(Covid-19)]..coviddeaths$
where location like '%states%'
order by 1,2

--Total Cases vs Population 
--Display percentage of population with a postive case of covid
select location, date, total_cases, population, (total_cases/population)*100 as positivetest 
from [Portfolio Project(Covid-19)]..coviddeaths$
where location like '%states%'
order by 1,2

--Countries with the highest infection rate
select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
from [Portfolio Project(Covid-19)]..coviddeaths$
Group by location, population
order by PercentPopulationInfected desc

--Countries with the highest death count per population 
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project(Covid-19)]..coviddeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

--Countries with the highest death count per population broken down by continents
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project(Covid-19)]..coviddeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers
select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project(Covid-19)]..coviddeaths$
where continent is not null
--group by date
order by 1,2

--Total Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project(Covid-19)]..coviddeaths$ dea
join [Portfolio Project(Covid-19)]..coviidvaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Using CTE
with PopulationVSVaccination (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project(Covid-19)]..coviddeaths$ dea 
join [Portfolio Project(Covid-19)]..coviidvaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select*, (RollingPeopleVaccinated/population)*100
from PopulationVSVaccination

--TEMP Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric,
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project(Covid-19)]..coviddeaths$ dea 
join [Portfolio Project(Covid-19)]..coviidvaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visulaization 
drop view if exists PercentPopulationVaccinated
go
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project(Covid-19)]..coviddeaths$ dea 
join [Portfolio Project(Covid-19)]..coviidvaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select*  
from PercentPopulationVaccinated