/*
A Look into the effects of Covid 19 
Skills used: Joins, CTE's, Temp Tables, Creating Views, Aggregate Functions, Converting Data Types, Windows Functions
*/


select *
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4 

select *
from [Portfolio Project]..CovidVaccinations
where continent is not null
order by 3,4 

-- Look at the data we are going to use 

select location, date, population,total_cases,new_cases,total_deaths
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases Vs Total Deaths in Costa Rica
-- Shows likelyhood of dying if you contract covid in Costa Rica
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [Portfolio Project]..CovidDeaths
where location like '%Costa%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population in Costa Rica was infected with Covid

select location, date, population, total_cases,(total_cases/population)*100 as Death_Percentage
from [Portfolio Project]..CovidDeaths
where location like '%Costa%'
order by 1,2


-- Looking at countries with Highest Infection Rate compared to Population

select location, population, Max(total_cases) as Highest_Infection_Count, Max((total_cases/population))*100 as Percent_Poulation_Infected
from [Portfolio Project]..CovidDeaths
Group by location, population
order by Percent_Poulation_infected desc

--- Showing Countries with Highest Death Count per Population

select location, Max(cast(Total_Deaths as int)) as Total_Death_Count
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location
order by Total_Death_Count desc

--Showing continents with the highest death count per population

select continent, Max(cast(Total_Deaths as int)) as Total_Death_Count
from [Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by Total_Death_Count desc

-- Global Numbers 

select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Looking at total Population vs Vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, Sum(convert(bigint,vax.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vax
on dea.location = vax.location
and dea.date = vax.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac(continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, Sum(convert(bigint,vax.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vax
on dea.location = vax.location
and dea.date = vax.date
where dea.continent is not null
)

select *, (Rolling_People_Vaccinated/population) * 100
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, Sum(convert(bigint,vax.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vax
on dea.location = vax.location
and dea.date = vax.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, Sum(convert(bigint,vax.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vax
on dea.location = vax.location
and dea.date = vax.date
where dea.continent is not null
