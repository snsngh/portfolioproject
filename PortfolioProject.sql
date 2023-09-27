select *
from CovidDeath
order by 3,4

--select *
--from CovidVaccination
--order by 3,4

--select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeath
where total_cases is not null
order by 1,2

--looking at total cases vs total death 

select location, date, total_cases, total_deaths, (cast (total_deaths as numeric) /total_cases ) *100 as DeathPercentage
from portfolioProject..CovidDeath
where total_cases is not null
--and location like 'sudan%'
order by 1,2

-- lookin at the total_cases vs population 
-- shows what precentage of population got covid 
 
select location, date, population,total_cases, population, (total_cases /population ) *100 as PercentPopulationInfected
from portfolioProject..CovidDeath
where total_cases is not null
--and location like 'sudan%'
order by 1,2

-- Looking At Countries With Highes Infection Rate Compared To Population  


select location, population, max (total_cases) HighestInfectionCount,  max((total_cases  /population )) *100 as PercentPopulationInfected
from portfolioProject..CovidDeath
where total_cases is not null
--and location like 'sudan%'
group by location, population
order by 4 desc

--showing countries with highest Death Count Per Population

select location, max (cast(total_deaths as int)) TotalDeathCount
from portfolioProject..CovidDeath
--where total_cases is not null
--and location like 'sudan%'
where continent is not null
group by location
order by 2 desc 

--Showing Continent With Highest Death Count Per Population 

select continent , max (cast(total_deaths as int)) TotalDeathCount
from portfolioProject..CovidDeath
--where total_cases is not null
--and location like 'sudan%'
where continent is not null
group by continent
order by 2 desc


--Global Number

create table #Global_table4  (
Date datetime,
Totalcases float,
TotalDeath float,

)

insert into #Global_table4 
select  Date, sum (new_cases) TotalCases,sum(new_deaths) TotalDeath --sum(new_deaths)/sum (new_cases)  *100 as DeathPercentage
from portfolioProject..CovidDeath
--where total_cases is not null
where continent is not null
--and location like 'qatar%'
group by date
order by 1,2

select *
from #Global_table4

select  Date, TotalCases, TotalDeath ,(TotalDeath/TotalCases) *100 as DeathPercentage
from #Global_table4

order by 1,2

--Looking at Total Populatiton vs vaccination


select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
sum(cast(new_vaccinations as numeric))over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioProject..CovidDeath dea
join portfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte 

with PepVsVac ( continent, location, date, population, new_vaccination, RollingPeopleVaccinated )
as
(
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
sum(cast(new_vaccinations as numeric))over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioProject..CovidDeath dea
join portfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/population)* 100
from PepVsVac

create view RollingPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
sum(cast(new_vaccinations as numeric))over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioProject..CovidDeath dea
join portfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select* 
from RollingPeopleVaccinated