--SELECT *
--FROM portfolioProject.dbo.covidVacition 

SELECT *
FROM portfolioProject.dbo.covidDeaths
where continent is not null

--Select Data that we are going to be using
Select Location, date,total_cases,new_cases,total_deaths,population

From portfolioProject..covidDeaths
where continent is not null
order by 1,2

-- Looking at Total cases vs Total Deaths
Select Location,date, total_cases,total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
From portfolioProject..covidDeaths

where location like '%states%' and continent is not null

order by 1,2



--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location,date,Population, total_cases, (total_cases/population)*100 as PercentagePopulationInfacted
From portfolioProject..covidDeaths
where location like '%states%' and continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select Location,Population,Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From portfolioProject..covidDeaths
-- where location like '%states%'
where continent is not null
Group by location,population
order by PercentPopulationInfected desc

-- Showing Countries with Higest Death Count per Population
Select location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc 


-- Let's break things down by contient
Select location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc 

-- Showing contintents with the highest death count per population
Select location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc 

--Global deaths
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(Cast
(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From portfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
-- Group By date
order by 1,2


--Looking at Total Population vs Vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int ,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From PortfolioProject..covidDeaths dea
Join portfolioProject.dbo.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as numeric(12,0))) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From PortfolioProject..covidDeaths dea
Join portfolioProject.dbo.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population) *100
From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as numeric(12,0))) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From PortfolioProject..covidDeaths dea
Join portfolioProject.dbo.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeoplevaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as numeric(12,0))) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From PortfolioProject..covidDeaths dea
Join portfolioProject.dbo.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated