
Select *
From PortfolioProject..CovidDeaths
--Where continent Is Not NULL
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- SELECT TO DEAL WITH

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Total cases Vs Total death
--Likelihood of death in africa

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
From PortfolioProject..CovidDeaths
Where location Like 'a%ca'
Order by 1,2

--Total Cases Vs Population
--Shows percentage of population 

Select location, date, total_cases, population, (total_cases/population) * 100 as population_percentage
From PortfolioProject..CovidDeaths
--Where location Like 'a%ca'
Order by 1,2

--Getting country with highest infection rate

Select location, max(total_cases) as highest_infection_count, population, Max(total_cases/population) * 100 as max_population_percentage
From PortfolioProject..CovidDeaths
Group by location, population
Order by 4 Desc

--Showing Highest death count with location

Select location, max(total_cases) as highest_infection_count, Max(Cast(total_deaths as int)) as total_death_count, Max(total_deaths/total_cases) * 100 as max_death_percentage
From PortfolioProject..CovidDeaths
Where Continent is not Null
Group by location, population
Order by 3 Desc

--Breaking down by continent
--Showing Continent with highest death count

--Select location, Max(Cast(total_deaths as int)) as total_death_count
--From PortfolioProject..CovidDeaths
--Where Continent is Null
--Group by location
--Order by 2 Desc


Select continent, Max(Cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where Continent is not Null
Group by continent
Order by 2 Desc

--Global Numbers


Select date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_death, (SUM(Cast(new_deaths as int))/Sum(new_cases)) * 100 as death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_death, (SUM(Cast(new_deaths as int))/Sum(new_cases)) * 100 as death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2


--Joining Both Tables

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at total vaccination Vs population

Select dea.continent, vac.location, vac.date, dea.population, vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by vac.location Order by vac.location, vac.date) as
rolling_people_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
Order by 2, 3

--It is impossible to make use of the data rolling_pople_vaccinated just created, hence we use a CTE or a TEMPT TABLE

--Using a CTE

With pop_vac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(

Select dea.continent, vac.location, vac.date, dea.population, vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by vac.location Order by vac.location, vac.date) as
rolling_people_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
--Order by can not be in a CTE
--Order by 2, 3

)
Select *, (rolling_people_vaccinated/population) * 100
From pop_vac

--TEMP TABLE

DROP Table if exists #percentagre_population_vaccinated
Create Table #percentagre_population_vaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
Insert into #percentagre_population_vaccinated
	Select dea.continent, vac.location, vac.date, dea.population, vac.new_vaccinations
	--value exceeded the range that is supported by the int data type
	, Sum(Convert(bigint, vac.new_vaccinations)) OVER (Partition by vac.location Order by vac.location, vac.date) as
	rolling_people_vaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not Null
	Order by 2, 3


Select *, (rolling_people_vaccinated/population) * 100
From #percentagre_population_vaccinated


--Creating view to store data for later visualization

Create View TotalDeathsCountPerContinent as

Select continent, Max(Cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where Continent is not Null
Group by continent
--Order by 2 Desc

Select *
From TotalDeathsCountPerContinent