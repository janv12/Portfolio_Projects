select *
From Portfolio_Project.dbo.CovidDeaths$
order by 3,4
;

--select *
--From Portfolio_Project.dbo.CovidVaccinations$
--order by 3,4;

--select data we are going to use
select location,date, total_cases, new_cases , total_deaths, population
from Portfolio_Project..CovidDeaths$
order by 1,2;

--looking at total cases and total deaths
--shows likelihood of dying if you contract covid in your country
select location,date, total_cases, new_cases , total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths$
where location like 'Nepal'
order by 1,2;

--looking at the total_cases vs population
select location,date, total_cases, new_cases , population, (total_cases/population)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths$
where location like 'Nepal'
order by 1,2;

--looking at countries with highest infection rate compared to population
select location,population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from Portfolio_Project..CovidDeaths$
group by location,population
order by PercentPopulationInfected desc;

--showing countries with highest Death per Population
select location, population,max(cast(total_deaths as int))as TotalDeathCount
from Portfolio_Project..CovidDeaths$
where continent is not null
group by location,population
order by TotalDeathCount desc;

--Lets break things by continent
--showing continent with highest death per population
select continent, max(cast(total_deaths as int))as TotalDeathCount
from Portfolio_Project..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc;

--Global numbers
select sum(new_cases) as total_cases ,sum(cast(new_deaths as int))as total_deaths ,sum(cast(new_deaths as int ))/sum(new_cases)*100 as deathpercentages
from Portfolio_Project..CovidDeaths$
--group by date
where continent is not null
order by 1,2;





select *
from Portfolio_Project..CovidDeaths$ dea
join Portfolio_Project..CovidVaccinations$ vac
 on dea.location = vac.location
  and dea.date = vac.date

  --Looking at Total population vs vaccination
  select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
  ,sum(convert(int ,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
from Portfolio_Project..CovidDeaths$ dea
join Portfolio_Project..CovidVaccinations$ vac
 on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3 

  --use CTE
  with popasvac (continent,location,date,population,new_vacctinations,PeopleVaccinated)
  as
  (
    select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
  ,sum(convert(int ,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
from Portfolio_Project..CovidDeaths$ dea
join Portfolio_Project..CovidVaccinations$ vac
 on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3 
  )
  select *,(PeopleVaccinated/population)*100
  from popasvac


  --Temp table
  drop table if exists #PercentPopulationVaccinated
  create Table #PercentPopulationVaccinated
  (
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccination numeric,
  peopleVaccinated numeric
  )
  Insert into #PercentPopulationVaccinated
   select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
  ,sum(convert(int ,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
from Portfolio_Project..CovidDeaths$ dea
join Portfolio_Project..CovidVaccinations$ vac
 on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3 
  
  select *,(PeopleVaccinated/population)*100
  from #PercentPopulationVaccinated


  --creating view to store data for later visualizaations
  create view PercentPopulationVaccinated as
  select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
  ,sum(convert(int ,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
from Portfolio_Project..CovidDeaths$ dea
join Portfolio_Project..CovidVaccinations$ vac
 on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3 
  

  select *
  from PercentPopulationVaccinated