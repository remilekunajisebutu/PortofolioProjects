
--Data exploration
select * from [dbo].[covidDeaths]
order by 3,4

select location, continent, date, total_cases,new_cases,total_deaths, population 
from [dbo].[covidDeaths]



--Showing percentage of death rate
select location, date, total_cases,new_cases,total_deaths, (total_deaths/total_cases) *100 as deathpercentage
from [dbo].[covidDeaths]

--Showing percentage of death rate in the US
select location, date, total_cases,new_cases,total_deaths, (total_deaths/total_cases) *100 as deathpercentage
from [dbo].[covidDeaths]
where location like '%states%' 
order by 1,2

--Showing percentage of death rate in the US
select location, date, total_cases,new_cases,total_deaths, (total_deaths/total_cases) *100 as deathpercentage
from [dbo].[covidDeaths]
where location = 'Nigeria'
order by 1,2

--Showing Countries with highest infection rate compared to population
select location, population,  max(total_cases) as highestinfectioncount,max((total_deaths/total_cases)) *100 as populationinfectedpercentage
from [dbo].[covidDeaths]
where continent is not null
group by location, population
order by populationinfectedpercentage desc

--Showing Countries with highest death rate per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from [dbo].[covidDeaths]
where continent is not null
group by location
order by totaldeathcount desc


--Showing Continents with highest death rate per population
select continent, max(cast(total_deaths as int)) as totaldeathcount
from [dbo].[covidDeaths]
where continent is not null
group by continent
order by totaldeathcount desc


--GLOBAL NUMBERS

--showing percentage of death per day across the world
select date,sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, sum(new_deaths)/sum(new_cases) * 100 as deathpercentage
from [dbo].[covidDeaths]
where new_deaths is not null and new_cases is not null and new_deaths <> 0 and new_cases <> 0 and continent is not null
group by date
order by 1,2

--showing total_cases, new cases and percentage of death across the world
select sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, sum(new_deaths)/sum(new_cases) * 100 as deathpercentage
from [dbo].[covidDeaths]
where new_deaths is not null and new_cases is not null and new_deaths <> 0 and new_cases <> 0 and continent is not null
--group by date
order by 1,2

--USE CTE

With popvsvac(continent,location,date,population, new_vaccinations, rollingpeoplevaccinated)
as (
select deaths.continent,deaths.location,deaths.date,deaths.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by deaths.location order by deaths.location, deaths.date) as rollingPeopleVaccinated
from [dbo].[covidDeaths] deaths
join [dbo].[covidVaccinations] vac
on deaths.location = vac.location
and deaths.date = vac.date
where deaths.continent is not null 
and vac.new_vaccinations is not null
--order by 2,3
)

select * , (rollingpeoplevaccinated/population)*100 
from popvsvac
order by 2,3

--TEMP TABLE
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population float,
new_vaccinations float,
rollingPeopleVaccinated float
)

insert into #percentpopulationvaccinated
select deaths.continent,deaths.location,deaths.date,deaths.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by deaths.location order by deaths.location, deaths.date) as rollingPeopleVaccinated
from [dbo].[covidDeaths] deaths
join [dbo].[covidVaccinations] vac
on deaths.location = vac.location
and deaths.date = vac.date
--where deaths.continent is not null 
--and vac.new_vaccinations is not null


select * , (rollingpeoplevaccinated/population)*100 
from #percentpopulationvaccinated
order by 2,3

--creating view to store data for visualizations
create view percentpopulationvaccinated as 
select deaths.continent,deaths.location,deaths.date,deaths.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by deaths.location order by deaths.location, deaths.date) as rollingPeopleVaccinated
from [dbo].[covidDeaths] deaths
join [dbo].[covidVaccinations] vac
on deaths.location = vac.location
and deaths.date = vac.date
where deaths.continent is not null 
and vac.new_vaccinations is not null
--order by 2,3


create view percentofdeathsperday as 
--showing percentage of death per day across the world
select date,sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths, sum(new_deaths)/sum(new_cases) * 100 as deathpercentage
from [dbo].[covidDeaths]
where new_deaths is not null and new_cases is not null and new_deaths <> 0 and new_cases <> 0 and continent is not null
group by date
--order by 1,2

create view highestdateperpopulation as
--Showing Countries with highest death rate per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from [dbo].[covidDeaths]
where continent is not null
group by location
--order by totaldeathcount desc




