--Likelihood of deaths
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From dbo.CovidDeaths2
Where location like '%states%'
order by 1,2

--Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location,date,total_cases,population, (total_cases/population)*100 as CovidPercentage
From dbo.CovidDeaths2
Where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select Location,Population,Max(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From dbo.CovidDeaths2
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count
Select Location,MAX(Total_deaths) as TotalDeathCount
from dbo.CovidDeaths2
Where continent is not null
Group By Location
order by TotalDeathCount desc

--by contienent
-- Countries with Highest Death Count
Select Location,MAX(Total_deaths) as TotalDeathCount
from dbo.CovidDeaths2
Where continent is null
Group By Location
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select date,SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(New_Deaths)/Sum(New_Cases)*100 as DeathPercentage
from dbo.CovidDeaths2
Where continent is not null
Group By date
order by 1,2

--Joins
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
,
from dbo.CovidDeaths2 dea
Join dbo.CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
    where dea.continent is not null
order by 2,3


--CTE
With PopVSVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
AS
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated

from dbo.CovidDeaths2 dea
Join dbo.CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
    where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopVSVac

--Creating View to store data
Create View PercentPopulationVAccinated as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
from dbo.CovidDeaths2 dea
Join dbo.CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
    where dea.continent is not null
