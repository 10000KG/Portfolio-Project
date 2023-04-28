select * 
from PorfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- Select Data that we are going to the using 

Select Location, Date,total_cases,new_cases,total_deaths, population
From PorfolioProject..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dyng if you contract covid in your country
Select Location, Date,total_cases,total_deaths,  (cast(total_deaths as float) /total_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths
where location like 'vietnam'
and continent is not null
Order by 1,2


-- Long at Total Cases vs Population
-- shows what percentage of population got Covid 

Select Location, Date, population, total_cases, (cast(total_cases as float) /population)*100 as PercentPopulationInfected
From PorfolioProject..CovidDeaths
--where location like 'vietnam'
Order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount
, MAX((cast(total_cases as float) /population))*100 as PercentPopulationInfected
From PorfolioProject..CovidDeaths
--where location like 'vietnam'
Group by Location, population
Order by 4 desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
--where location like 'vietnam'
where continent is not null
Group by Location
Order by 2 desc

-- LEST'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count fer population

Select	continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
--where location like 'vietnam'
where continent is not null
Group by continent
Order by 2 desc



-- GLOBAL NUMBERS

Select sum(new_cases) as total_cases,Sum(cast(new_deaths as int)) as total_deaths
,sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 DeathPercent
From PorfolioProject..CovidDeaths
where continent is not null
--Group by date
Order by 1,2



-- looking at Total Population vs Vaccinations

select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/population*100
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVacinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


-- USE CTE 

With PopvsVac(Continent, Location, Date, Population,New_Vacconations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/population*100
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVacinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/population*100
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVacinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store dât for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/population*100
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVacinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3


select *
From PercentPopulationVaccinated