select location, date, total_cases, new_cases, total_deaths, population
	from Covid_Death
	order by 1, 2

--total cases vs. total deaths

Select location, date, total_cases, total_deaths, round((total_deaths/total_cases) * 100, 2) as PercentageDeath
	from Covid_Death
	where location like '%State%'
	order by 1, 2

--total cases vs. population

select location, date, population, total_cases, round((total_cases/population) * 100, 2) as PercentageCases
from Covid_Death
where location like '%States%'
order by 1,2

--Highest Infection rate

select location, population, max(total_cases) as Max_Cases, round(max(total_cases/population) * 100, 2) as PercentageCases
from Covid_Death
Group by Location, population
Order by PercentageCases desc

--Highest Death Rate

select location, population, max(Cast(total_deaths as int)) as Total_Death_Count
from Covid_Death
where continent is not null
Group by Location, population
Order by Total_Death_Count desc

--break things down by continent
select continent, max(Cast(total_deaths as int)) as Total_Death_Count
from Covid_Death
where continent is not null
Group by location
Order by Total_Death_Count desc

--Continent with the highest death count per population
select location, population, max(Cast(total_deaths as int)) as Total_Death_Count, Round(Max(total_deaths/population) * 100, 2) as Death_Percentage
from Covid_Death
where continent is null
Group by location, population
Order by Total_Death_Count desc

--global number

Select sum(new_cases) as Global_Total_New_Cases
, sum(cast(new_deaths as int)) as Global_Total_New_Deaths
, round(sum(cast(new_deaths as int))/sum(new_cases) * 100, 2) as New_Deaths_per_New_Cases
	from Covid_Death
	where continent is not null
	order by 1,2

--total population vs. vaccination
with PopvsVac (continenet, location, date, population, new_vaccinations, Rolling_Vaccinations)
as
(Select Death.continent, Death.location, Death.date, population, Vacs.new_vaccinations
, sum(cast(Vacs.new_vaccinations as int)) over (partition by Death.location order by Death.location, Death.date) as Rolling_Vaccinations
	from Covid_Death Death
		join Covid_Vac Vacs
		on
		Death.Location = Vacs.Location
		and  Death.Date = Vacs.Date
		where Death.continent is not null)
	select *, Round((Rolling_Vaccinations/population *100), 2)
	from PopvsVac

--Temp Table
Create Table PercentPopulationVaccinated(
	continent nvarchar(250),
	location nvarchar(250),
	date datetime,
	population numeric,
	New_vaccinations numeric,
	Rolling_Vaccination numeric)

insert into PercentPopulationVaccinated
Select Death.continent, Death.location, Death.date, population, Vacs.new_vaccinations
, sum(cast(Vacs.new_vaccinations as int)) over (partition by Death.location order by Death.location, Death.date) as Rolling_Vaccinations
	from Covid_Death Death
		join Covid_Vac Vacs
		on
		Death.Location = Vacs.Location
		and  Death.Date = Vacs.Date
		where Death.continent is not null

select *, (Rolling_Vaccination/Population *100)
from PercentPopulationVaccinated

--Create View for visualization

Create view PercentPopulation_Vaccinated as
Select Death.continent, Death.location, Death.date, population, Vacs.new_vaccinations
, sum(cast(Vacs.new_vaccinations as int)) over (partition by Death.location order by Death.location, Death.date) as Rolling_Vaccinations
	from Covid_Death Death
		join Covid_Vac Vacs
		on
		Death.Location = Vacs.Location
		and  Death.Date = Vacs.Date
		where Death.continent is not null