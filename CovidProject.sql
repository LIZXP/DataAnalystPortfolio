-----------------------------------------------------------------------------------------------------------------
--LOOKING AT TOTAL CASES VS TOTAL DEATHS AND ADD R VALUE
--This will show the reprodiction rate and likelihood of dying if you contract covid in Canada

Select
	location,
	date,
	total_cases,
	new_cases,
	reproduction_rate as r_value,
	total_deaths,
	format((total_deaths/total_cases),'P') as DeathPercentage
From
	[Covid Project]..CovidDeath
Where location like '%anad%'
Order by 1,2

-------------------------------------------------------------------------------------------------------------------
--ADD TOTAL CASES VS TOTAL POPULATION
--Shows the percentage of population got covid

Select
	location,
	date,
	total_cases,
	new_cases,
	reproduction_rate as r_value,
	population,
	format((total_deaths/total_cases),'P') as DeathPercentage,
	format((total_cases/population),'P2') as Populationcovid_percent
From
	[Covid Project]..CovidDeath
Where location like '%anad%'
Order by 1,2


------------------------------------------------------------------------------------------------------------------
--Looking at countries with Highest Infection Rate Compared to Population

Select
	location,
	MAX(total_cases) as highestinfectioncount,
	population,
	Max(format((total_cases/population),'P5')) as Populationcovid_percent
From
	[Covid Project]..CovidDeath
where continent is not null
Group by location,population
Order by Populationcovid_percent DESC


-------------------------------------------------------------------------------------------------------------------
--Showing the Countries With Highest Death Count Per Population

Select
	location,
	MAX(Cast(total_deaths as int)) as highestDeathCount,
	population,
	Max(format((total_deaths/population),'P3')) as CovidDeathPopulation_percent
From
	[Covid Project]..CovidDeath
where continent is not null
Group by location,population
Order by highestDeathCount DESC


-------------------------------------------------------------------------------------------------------------------
--Showing continent with the highest death count per population

select location, Max(CAST(total_deaths as int)) as TotalDeathCount
From [Covid Project]..CovidDeath
where continent is null
	and not location = 'International'
	and not location = 'World'
Group by location
order by TotalDeathCount desc


---------------------------------------------------------------------------------------------------------------------
--Global Numbers

Select
	SUM(new_cases) as total_cases,
	SUM(cast(new_deaths as int)) as Total_deaths,
	format(SUM(cast(new_deaths as int))/SUM(new_cases),'P') as Death_case_percentage
From[Covid Project]..CovidDeath
Where continent is not null
Order by 1,2


----------------------------------------------------------------------------------------------------------------------
--Looking at Total Population VS Vaccinations

select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	    dea.date) as SumPeopleVaccinated
from [Covid Project]..CovidDeath dea
join [Covid Project]..CovidVacc vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

------------------------------------------------------------------------------------------------------------------------
--Using CTE To Get New Vaccinated Increase Trent

With PPV (continent,location,date,population, new_vaccinations, SumPeopleVaccinated)
as
(
select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	    dea.date) as SumPeopleVaccinated
from [Covid Project]..CovidDeath dea
join [Covid Project]..CovidVacc vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select 
	*,
	FORMAT(SumPeopleVaccinated/population,'P2') as NewVaccinatedIncreaseTrent
from PPV
where new_vaccinations is not null
	  and SumPeopleVaccinated is not null
order by 1,2,3


-----------------------------------------------------------------------------------------------------------------------
--Using another way TEMP TABLE To Get New Vaccinated Increase Trent


DROP Table if exists #PPV
Create Table #PPV
(
continenet nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
SumPeopleVaccinated numeric
)
Insert into #PPV
select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	    dea.date) as SumPeopleVaccinated
from [Covid Project]..CovidDeath dea
join [Covid Project]..CovidVacc vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select 
	*,
	FORMAT(SumPeopleVaccinated/population,'P2') as NewVaccinatedIncreaseTrent
from #PPV
where new_vaccinations is not null
	  and SumPeopleVaccinated is not null
order by 1,2,3


-----------------------------------------------------------------------------------------------------------------------
--Creating View for later visualizations

Create View PopvaccinatedVSCasesRvalue as
select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	dea.new_cases,
	dea.reproduction_rate as r_value,
	dea.new_deaths,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	    dea.date) as SumPeopleVaccinated,
	SUM(CONVERT(int,dea.new_cases)) OVER (Partition by dea.location ORDER BY dea.location,
	    dea.date) as SumNewCases
from [Covid Project]..CovidDeath dea
join [Covid Project]..CovidVacc vac
	on dea.location = vac.location
	and dea.date = vac.date
where 
	dea.continent is not null
	and dea.location='Canada'
	or dea.location='United Kingdom'
	or dea.location='United States'
	or dea.location='India'
	or dea.location='Israel'
