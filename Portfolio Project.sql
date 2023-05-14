-- data explorition to show all the data 
SELECT * 
FROM [PortfolioProject ]..CovidDeaths 
where continent is not null 

--select the data that we going to use 

select location, date, total_cases, new_cases, total_deaths, population
from [PortfolioProject ]..CovidDeaths
where continent is not null 
order by 1,2

-- looking at total cases vs total deat 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeatPrecentage
from [PortfolioProject ]..CovidDeaths
where location like '%sudan%' and continent is not null 
order by 1,2


-- looking at total cases vs population 
-- what precentage of population have gaten covid 
select location, date, population, total_cases, (total_cases/population)*100 as TotalCasesPrecentage 
from [PortfolioProject ]..CovidDeaths
where continent is not null 
order by 1,2 

-- showing  for countries with higthest infection rade compered to population 
select location, population, max(total_cases) as HigthestInfectionCount,max((total_cases/population))*100 as PrecentPopulationInfaction 
from [PortfolioProject ]..CovidDeaths
where continent is not null 
group by location,population
order by PrecentPopulationInfaction desc 


-- showing countries with higthest death count or population 
select location, max(cast(total_deaths as int)) as TotalDeathCount
from [PortfolioProject ]..CovidDeaths
where continent is not null 
group by location
order by TotalDeathCount desc 


-- LET'S BREAK THE THINGS DOWN BY CONTINENT 
-- showing continent with higthest death count per population 
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [PortfolioProject ]..CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc 


-- GLOBAL NUMBERS 
select date, sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int ))/sum(new_cases))*100 as TotalDeathPrecentage 
from [PortfolioProject ]..CovidDeaths
where continent is not null 
group by date  
order by 1,2 


-- looking for new vaccination vs populaion 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPepoleVaccinated 
from [PortfolioProject ]..CovidDeaths dea
join [PortfolioProject ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
order by 2,3


-- USING CTE 
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPepoleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPepoleVaccinated 
from [PortfolioProject ]..CovidDeaths dea
join [PortfolioProject ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3
)

select *, (RollingPepoleVaccinated/population)*100 PrecentegePepoleVaccinated  
from PopvsVac


-- USING TEMP TABLE 

DROP TABLE IF EXISTS #PrecentegePopulationVaccinated
CREATE TABLE #PrecentegePopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime ,
population numeric ,
new_vaccinations numeric ,
RollingPepoleVaccinated numeric 
)


INSERT INTO #PrecentegePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPepoleVaccinated 
from [PortfolioProject ]..CovidDeaths dea
join [PortfolioProject ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
--where dea.continent is not null 


SELECT *, (RollingPepoleVaccinated/population)*100 PrecentegePepoleVaccinated  
FROM #PrecentegePopulationVaccinated


-- creating a view for later virsualization 

create view PrecentegePopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPepoleVaccinated 
from [PortfolioProject ]..CovidDeaths dea
join [PortfolioProject ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3
