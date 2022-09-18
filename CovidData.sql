Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


--Looking at Total Cases Vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location='India' 
and continent is not null
Order by 1,2


--Looking at Total Cases Vs Population
--Shows what percentage of people got Covid

Select Location, date,Population, total_cases,  (total_cases/Population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location='India'
Where continent is not null
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location,Population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location='India'
Where continent is not null
Group by Location,Population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location,MAX(cast(Total_deaths AS int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location='India'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

Select continent,MAX(cast(Total_deaths AS int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location='India'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) AS total_cases,SUM(cast(new_deaths AS int)) AS total_deaths,
SUM(cast(new_deaths AS int))/SUM(New_cases)* 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location='India' 
Where continent is not null
--Group by date
Order by 1,2


--Looking at Total Population Vs Vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location
     and dea.date=vac.date
Where dea.continent is not null
Order by 2,3

--CTE

With PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
As
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location
     and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
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
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location
     and dea.date=vac.date
--Where dea.continent is not null
--Order by 2,3
Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location
     and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
