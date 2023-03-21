

Select *
From CovidDeaths
Where continent is not null 
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths for specific country

Select Location, date, total_cases,total_deaths, (cast(total_deaths as int)/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%pakistan%'
and continent is not null 
order by 1,2


-- Percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
order by 1,2


-- Countries with Highest number of cases compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Pakistan total death counts

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where location like '%pakistan%'
and continent is not null 
Group by Location
order by TotalDeathCount desc




-- Highest no of deaths per continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null 
Group by continent
order by TotalDeathCount desc



-- Total Cases vs Deaths Globally

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2



-- Rolling total of vaacination country wise

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as bigint)) OVER (Partition by cd.Location Order by cd.location, cd.date) as RollingPeopleVaccinated
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cv.continent is not null
--and cd.location like '%pakistan%'
order by RollingPeopleVaccinated desc




-- Percentage of vaccinated people country wise

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as bigint)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
)

Select *,(RollingPeopleVaccinated/Population)*100 as VaccinationRate
From PopvsVac order by VaccinationRate



-- Percentage of vacinations vs total population using temp table.

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
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store rolling total of vaacination country wise

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 

