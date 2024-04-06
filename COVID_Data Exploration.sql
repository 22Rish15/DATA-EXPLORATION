select * from CovidDeaths
where continent is null

select location,date,population, total_cases, new_cases, total_deaths
from CovidDeaths
order by 1,2

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from CovidDeaths
where location='India'
order by 2

select location, population, max(total_cases) HigestInfectedCount, max((total_cases/population)*100) PercentPopuationInfected
from CovidDeaths
group by location, population
order by 4 desc

select location, population, max(cast(total_deaths as int)) TotalDeathCount
from CovidDeaths
group by location, population
order by TotalDeathCount desc

select location, max(cast(total_deaths as int)) TotalDeathCount
from CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- global data

select date, sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths ,
sum(cast(new_deaths as int))/nullif(sum(new_cases),0)* 100 as deathpercentage -- if denominator is zero
from CovidDeaths
--where continent is not null
group by date
order by date


select date, sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths , sum(cast(new_deaths as int))/sum(new_cases)* 100 deathpercentage
from CovidDeaths
where continent is not null
group by date
order by date

-- accross the world

select sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths , sum(cast(new_deaths as int))/sum(new_cases)* 100 deathpercentage
from CovidDeaths
where continent is not null





select *
from CovidVaccinations


select *
from CovidDeaths cd 
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date


select cd.continent, cd.location,cd.date,population, new_vaccinations,
sum(convert(int,new_vaccinations)) over(partition by cd.location order by cd.location, cd.date) total_vaccinations
from CovidDeaths cd 
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3

-- use cte(common table expression) for population vs total people vaccinated

with PopVsVac (continent,location,date,population,new_vaccinations,total_vaccinated)
as(
select cd.continent, cd.location,cd.date,population, new_vaccinations,
sum(convert(int,new_vaccinations)) over(partition by cd.location order by cd.location, cd.date) total_vaccinated
from CovidDeaths cd 
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)
select *, (total_vaccinated/population)*100
from PopVsVac

-- temp table

drop table if exists #PopVsVac
create table #PopVsVac(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinated numeric
)
insert into #PopVsVac
select cd.continent, cd.location,cd.date,population, new_vaccinations,
sum(convert(int,new_vaccinations)) over(partition by cd.location order by cd.location, cd.date) total_vaccinated
from CovidDeaths cd 
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null

select *, (total_vaccinated/population)*100
from #PopVsVac
order by location, date

-- view

create view PopulationVsTotal_Vacccinations as
select cd.continent, cd.location,cd.date,population, new_vaccinations,
sum(convert(int,new_vaccinations)) over(partition by cd.location order by cd.location, cd.date) total_vaccinated
from CovidDeaths cd 
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null

select *, (total_vaccinated/population)*100
from PopulationVsTotal_Vacccinations
order by 2,3