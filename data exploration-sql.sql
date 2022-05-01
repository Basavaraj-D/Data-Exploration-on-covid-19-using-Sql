Select *
From coviddeaths
Where continent is not null
Order by location,date

-- selecting the data that will be most useful for analysis

Select location,date,population,total_cases,new_cases,total_deaths
From coviddeaths
Where continent is not null
Order By location,date

-- let us see the death percentage against total cases
-- likelihood of dying by covid19 in a particular country

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 As 'death %'
From coviddeaths
Where continent is not null
Order By location,date

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 As 'death %'
From coviddeaths
Where location in ('India')
Order By location,date

-- let us see total_cases against the population

Select location,date,total_cases,population,(total_cases/population) As 'Population %'
From coviddeaths
Where continent is not null
Order By location,date

-- Infection rate against the population

Select location,MAX(total_cases) as 'max case count',population,MAX((total_cases/population)) As 'Highcases %'
From coviddeaths
Where continent is not null
Group by population,location
Order By 'Highcases %' DESC

-- Highest death count vs population
-- since total_deaths is a varchar we will convert it into an int
-- highest death count vs continent

Select location,population,MAX(cast(total_deaths as int)) as 'max death count'
From coviddeaths
Where continent is not null
Group by population,location
Order By 'max death count' DESC

Select location,MAX(cast(total_deaths as int)) as 'maxdeath continent'
From coviddeaths
Where continent is null
Group by location
Order By 'maxdeath continent' DESC

-- across the globe record of new_cases and new_deaths each day
-- convert new_deaths varchar into int

Select date,SUM(new_cases) As Ncases,SUM(cast(new_deaths as int)) as Ndeaths,
      SUM(cast(new_deaths as int)) / SUM((new_cases))*100 as 'Ncases Vs Ndeaths'
From coviddeaths
Where continent is not null
Group by date
Order By 1,2

Select SUM(new_cases) As Ncases,SUM(cast(new_deaths as int)) as Ndeaths,
      SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as 'Ncases Vs Ndeaths'
From coviddeaths
Order By 1,2


-- let us see the vaccinations

Select *
From covidvaccinations
Order BY location

-- let us do a join of both coviddeaths and covidvaccinations
-- taking a look at new_vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vacci.new_vaccinations
From coviddeaths dea
Join covidvaccinations vacci
	On dea.location = vacci.location
	and dea.date = vacci.date
Where dea.continent is not null
Order by location,date
 
-- total vaccinations over population using CTE

With PopvsVac (continent,location,date,population,new_vaccinations,Rollingvaccination)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vacci.new_vaccinations
	,SUM(cast(vacci.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,
	 dea.date) AS Rollingvaccination
From coviddeaths dea
Join covidvaccinations vacci
	On dea.location = vacci.location
	and dea.date = vacci.date
Where dea.continent is not null
)
Select *, (Rollingvaccination/population)*100 AS Vaccpercentage
From PopvsVac

-- Creating a Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccination numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vacci.new_vaccinations
	,SUM(cast(vacci.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,
	 dea.date) AS Rollingvaccination
From coviddeaths dea
Join covidvaccinations vacci
	On dea.location = vacci.location
	and dea.date = vacci.date
-- Where dea.continent is not null

Select *, (Rollingvaccination/population)*100 AS Vaccpercentage
From #PercentPopulationVaccinated

-- Create a View

Go
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vacci.new_vaccinations
	,SUM(cast(vacci.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,
	 dea.date) AS Rollingvaccination
From coviddeaths dea
Join covidvaccinations vacci
	On dea.location = vacci.location
	and dea.date = vacci.date
Where dea.continent is not null
