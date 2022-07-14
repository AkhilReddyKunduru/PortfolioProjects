

--Checking if import job is successful for Covid Deaths file
Select * 
From PortfolioProject1..CovidDeaths
Where continent is not null
Order by 3,4


--Checking if import job is successful for Covid Vaccinations file

Select * 
From PortfolioProject1..CovidVaccinations
Order by 3,4


-- Starting by selecting the required fields from dataset

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Order by 1,2



-- Now, we have some awareness around data quality and let's work into finding Total Cases Vs Total Deaths in United States
-- Calculating percentage to undertsand the probability of death, if contracted the covid virus

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death%'
From PortfolioProject1..CovidDeaths
Where location like '%states%'
Order by 1,2


--Let's work into finding Total Cases Vs Total Population
--Finding the percentage of population contracted with Covid-19 in US

Select location, date, population, total_cases, (total_cases/population)*100 as 'Population_affect%'
From PortfolioProject1..CovidDeaths
Where location like '%states%'
Order by 2


--Finding highest infected country by population

Select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as 'Population_affect%'
From PortfolioProject1..CovidDeaths
Group by location, population 
Order by [Population_affect%] desc

--Countries with Highest death count

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


--LOOKING FROM 30,000 feet

Select  continent,  Max(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Totol_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by date
Order by 1,2


--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject1..coviddeaths dea
join portfolioproject1..covidvaccinations vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject1..coviddeaths dea
join portfolioproject1..covidvaccinations vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac

--Use Temp Table

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject1..coviddeaths dea
join portfolioproject1..covidvaccinations vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
Where dea.continent is not null

Select *,(RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated

--Creating views for visualization

Create View  PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject1..coviddeaths dea
join portfolioproject1..covidvaccinations vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
Where dea.continent is not null


--Checking view

Select *
From PercentPopulationVaccinated













