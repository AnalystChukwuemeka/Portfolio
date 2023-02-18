   /* covid Data Exploration

1. Total cases per continent/location
2. Total cases by date
3. Total death by continent/location
4. Total cases Vs Total deaths per location
5. Total testing/ cases recording - rate of detection
6. Total vacination by continent / Location
7. Vacination vs new cases - Effectiveness of vacines in reducing new cases
8. Vacination vs new death - impact of vacines in preventing new deaths
9. Hospital Admission/Death by Location - Does getting to hospital reduce death count
8. ICU/death by location - Did More ICU centres impact death rate
9. Age vs cases - Which age range were more infected
10. Age Vs death - Which age range died
11. Previous health conditions Vs Cases
12. 11. Previous health conditions Vs death
13. Rate of infection and death by population size

*/

select *
from MyPortfolio..covidcases
where continent is not null
order by 3,4

-- 1. Total Cases By Countries

select location as Country, Sum(new_cases) as Total_Cases
from MyPortfolio..covidcases
where continent is not null
Group by location
order by Total_Cases desc

-- Total infection by Months - Determining peak infection period

select Max(date) as date, location as Country, sum(new_cases) as Total_cases
from MyPortfolio..covidcases
where continent is not null
Group by MONTH(date), location
order by Total_cases desc

-- Percentage of infection by population per country

select location as Country, Max(population) as population, Sum(new_cases) as Total_Cases, (Sum(new_cases)/Max(population))*100 as Infection_Rate
from MyPortfolio..covidcases
where continent is not null
Group by location
order by Total_Cases desc


-- 3. Total Deaths By Countries

select location as Country, Sum(cast(new_deaths as int)) as Total_Deaths
from MyPortfolio..covidcases
where continent is not null
Group by location
order by Total_deaths desc


-- Total Deaths by Months - Determining peak Death period

select Max(date) as date, location as Country, sum(cast(new_deaths as int)) as Total_deaths
from MyPortfolio..covidcases
where continent is not null
Group by MONTH(date),location
order by Total_deaths desc

-- Percentage of deaths by population per country

select location as Country, Max(population) as population, Sum(cast(new_deaths as int)) as Total_deaths, (Sum(cast(new_deaths as int))/Max(population))*100 as Death_Rate
from MyPortfolio..covidcases
where continent is not null
Group by location
order by Total_deaths desc


-- Percentage of death/cases by population per country

select location as Country, Sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_deaths, (Sum(cast(new_deaths as int))/Sum(new_cases))*100 as Infection_Rate
from MyPortfolio..covidcases
where continent is not null
Group by location
order by Total_Cases desc


-- Vaccination Rate per country
Select location, Max(population) as population, sum(cast(new_vaccinations as bigint)) as Total_vaccinated
From MyPortfolio..coviddata_vac
where continent is not null 
and new_vaccinations is not null
group by location
order by population desc

--Testing rate per country

Select location, Max(population) as population, sum(cast(new_tests as bigint)) as Total_tested
From MyPortfolio..coviddata_vac
where continent is not null 
and new_tests is not null
group by location
order by population desc

--Impact of vaccination on infection, has vaccination reduced infection

WITH casesvac (continent, country, Date, population, new_cases, rolling_new_cases, new_vaccinations, rolling_new_vaccinations)
as
(
select cases.continent, cases.location, cases.date ,cases.population, cases.new_cases, sum(convert(bigint,cases.new_cases)) OVER (partition by cases.location order by cases.date, cases.location ROWS UNBOUNDED PRECEDING ) as RollingNewCases,
vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by cases.location order by cases.location, cases.date ROWS UNBOUNDED PRECEDING) as RollingNewVaccinations
from
MyPortfolio..covidcases cases
join 
MyPortfolio..coviddata_vac vac
	on cases.location = vac.location
	and cases.date = vac.date
where cases.continent is not null

)
select country, Date, population, rolling_new_cases, rolling_new_vaccinations,(rolling_new_cases/population)*100 as percentageIncreaseInCases,
(rolling_new_vaccinations/population)*100 as percentageIncreaseInVaccinations
from casesvac
order by population desc

--Impact of vaccination on death rate, has vaccination reduced death

WITH casesvac (continent, country, Date, population, new_deaths, rolling_new_deaths, new_vaccinations, rolling_new_vaccinations)
as
(
select cases.continent, cases.location, cases.date ,cases.population, cases.new_deaths, sum(convert(bigint,cases.new_deaths)) OVER (partition by cases.location order by cases.date, cases.location ROWS UNBOUNDED PRECEDING ) as RollingNewDeaths,
vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by cases.location order by cases.location, cases.date ROWS UNBOUNDED PRECEDING) as RollingNewVaccinations
from
MyPortfolio..covidcases cases
join 
MyPortfolio..coviddata_vac vac
	on cases.location = vac.location
	and cases.date = vac.date
where cases.continent is not null

)
select country, Date, population, rolling_new_deaths, rolling_new_vaccinations,(rolling_new_deaths/population)*100 as percentageIncreaseInDeaths,
(rolling_new_vaccinations/population)*100 as percentageIncreaseInVaccinations
from casesvac
order by population desc


-- CREATE VIEWS FOR VISUALIZATIONS
create view vaccination_to_newcases as

WITH casesvac (continent, country, Date, population, new_cases, rolling_new_cases, new_vaccinations, rolling_new_vaccinations)
as
(
select cases.continent, cases.location, cases.date ,cases.population, cases.new_cases, sum(convert(bigint,cases.new_cases)) OVER (partition by cases.location order by cases.date, cases.location ROWS UNBOUNDED PRECEDING ) as RollingNewCases,
vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by cases.location order by cases.location, cases.date ROWS UNBOUNDED PRECEDING) as RollingNewVaccinations
from
MyPortfolio..covidcases cases
join 
MyPortfolio..coviddata_vac vac
	on cases.location = vac.location
	and cases.date = vac.date
where cases.continent is not null

)
select country, Date, population, rolling_new_cases, rolling_new_vaccinations,(rolling_new_cases/population)*100 as percentageIncreaseInCases,
(rolling_new_vaccinations/population)*100 as percentageIncreaseInVaccinations
from casesvac



create view vaccination_to_deaths as
WITH casesvac (continent, country, Date, population, new_deaths, rolling_new_deaths, new_vaccinations, rolling_new_vaccinations)
as
(
select cases.continent, cases.location, cases.date ,cases.population, cases.new_deaths, sum(convert(bigint,cases.new_deaths)) OVER (partition by cases.location order by cases.date, cases.location ROWS UNBOUNDED PRECEDING ) as RollingNewDeaths,
vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by cases.location order by cases.location, cases.date ROWS UNBOUNDED PRECEDING) as RollingNewVaccinations
from
MyPortfolio..covidcases cases
join 
MyPortfolio..coviddata_vac vac
	on cases.location = vac.location
	and cases.date = vac.date
where cases.continent is not null

)
select country, Date, population, rolling_new_deaths, rolling_new_vaccinations,(rolling_new_deaths/population)*100 as percentageIncreaseInDeaths,
(rolling_new_vaccinations/population)*100 as percentageIncreaseInVaccinations
from casesvac


create view VaccinationToDeaths as
select cases.continent, cases.location, cases.date ,cases.population, cases.new_deaths, sum(convert(bigint,cases.new_deaths)) OVER (partition by cases.location order by cases.date, cases.location ROWS UNBOUNDED PRECEDING ) as RollingNewDeaths,
vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by cases.location order by cases.location, cases.date ROWS UNBOUNDED PRECEDING) as RollingNewVaccinations
from
MyPortfolio..covidcases cases
join 
MyPortfolio..coviddata_vac vac
	on cases.location = vac.location
	and cases.date = vac.date
where cases.continent is not null