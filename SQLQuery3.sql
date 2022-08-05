select * from PortfolioProject..coviddeaths
select * from PortfolioProject..covidvaccinations

select location,date,total_cases,new_cases,population
from PortfolioProject..coviddeaths
order by 1,2

-- Total deaths/Total Cases (D Percentage)

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as d_percentage
from PortfolioProject..coviddeaths
where location = 'India'
order by 1,2


--Looking at Total Cases vs Popultion

select location,date,total_cases,population,(total_cases/population)*100 as Case_Percentage
from PortfolioProject..coviddeaths
where location = 'India'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location,population,Max(total_cases)as Highest_infection,Max((total_cases/population))*100 as PopulationPercent_Infected
from PortfolioProject..coviddeaths
group by location,population
order by PopulationPercent_Infected Desc

--Showing Death Count where continent is not null

select location,Max(cast(total_deaths as int))as D_Count
from PortfolioProject..coviddeaths
where continent is not null
group by location
order by D_Count Desc


--Showing the data accross Continents

select continent,Max(cast(total_deaths as int))as D_Count
from PortfolioProject..coviddeaths
where continent is not null
group by continent
order by D_Count Desc 

--Showing the data accross Continents where it is null

select location,Max(cast(total_deaths as int))as D_Count
from PortfolioProject..coviddeaths
where continent is null
group by location
order by D_Count Desc

--Global Numbers

select date,SUM(new_cases) as Total_Cases,SUM(cast(total_deaths as int))Total_Deaths, SUM(cast(total_deaths as int))/SUM(new_cases)*100 as d_percentageglobal
from PortfolioProject..coviddeaths
where continent is not null
group by date
order by 1,2

--Joining two tables
--Looking at total population vs Vaccination
--Using CTE

WITH PopvsVac (continent, location, date,population, new_vaccinations,Rollingpeople_vaccinated)
(
select d.continent, d.location, d.date,d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as int)) over(partition by d.location order by d.location,d.date) as Rollingpeople_vaccinated
from PortfolioProject..coviddeaths as d
join PortfolioProject..covidvaccinations as v
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3

)

Select *, (Rollingpeople_vaccinated/population)*100 
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeople_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as Rollingpeople_vaccinated
--, (Rollingpeople_vaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date

Select *, (Rollingpeople_vaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as Rollingpeople_vaccinated
--, (Rollingpeople_vaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 

select * from PercentPopulationVaccinated

