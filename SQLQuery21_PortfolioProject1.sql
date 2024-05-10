SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not Null
ORDER BY 3, 4
--SELECT *
--FROM PortfolioProject..CovidVacinations
--ORDER BY 3,4

--Selecting Data that is to be used
Select Location, date, total_cases, New_cases, Total_deaths, Population
From PortfolioProject..CovidDeaths
Where continent is not Null
Order By 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, Date, Total_cases, Total_deaths, (cast(Total_deaths as float)/Total_cases)*100 as PercentageDeaths /* for some reason nvarchar and int data types cannot be used with the division operator*/
From PortfolioProject..CovidDeaths
Where location like '%Nigeria%' and continent is not Null
Order By 1, 2

-- Looking at the Total Cases vs Populations
-- Shows what percentage of population got Covid
Select Location, Date, Total_cases, population, (Total_cases/ Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Nigeria%' and continent is not Null
Order By 1, 2

-- Looking at Countries with Highest Infection Rate Compared to Population
Select Location, Population, Max(cast(Total_cases as int)) as HighestInfectionCount, Max(cast(Total_cases as float)/cast(Population as float))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Where continent is not Null
Group by Location, population
Order by PercentPopulationInfected desc

-- Showing Countries with Highgest Death Count per Population
Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not Null
Group by Location
Order By TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENTS

--Showing continents with the highest death count

Select continent, location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is Null and location not like '%income%'
Group by continent, location
Order By TotalDeathCount desc

-- GLOBAL NUMBERS
Select date, Sum(new_cases) as total_cases,  Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as NewDeathPercentPerDay
from portfolioProject..CovidDeaths
Where continent is not null
Group By date
Having Sum(new_cases) <> 0
order by 1,2


-- Looking at Total Population vs Vaccinations
-- USE CTE
With PropvsVac (Continent, Location , Date, Population, New_vaccinations, RollingPeopleVaccinated )
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(CAST(vac.new_vaccinations AS FLOAT)) OVER(PARTITION BY dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated /* ordering by two columns in a partition some how allows you to perform a cummulative calcualation*/
--,(RollingPeopleVaccinated/population)*100 cant use a column just created directly in the same select statement
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order By 2, 3 /* order by can't be in a cte*/
)

Select *, RollingPeopleVaccinated/(Population)*100
From PropvsVac


-- TEMP TABLE
Drop Table if Exists #precentPopulationVaccinated /*deletes table if the table exist when we want to recreate the table after modification*/
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(CAST(vac.new_vaccinations AS FLOAT)) OVER(PARTITION BY dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated /* ordering by two columns in a partition some how allows you to perform a cummulative calcualation*/
--,(RollingPeopleVaccinated/population)*100 cant use a column just created directly in the same select statement
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order By 2, 3 /* order by can't be in a cte*/

Select *, RollingPeopleVaccinated/(Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later Visulization
Create view PercentPopulationVaccinated as /*feels like this error doesn't matter*/
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(CAST(vac.new_vaccinations AS FLOAT)) OVER(PARTITION BY dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated /* ordering by two columns in a partition some how allows you to perform a cummulative calcualation*/
--,(RollingPeopleVaccinated/population)*100 cant use a column just created directly in the same select statement
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
