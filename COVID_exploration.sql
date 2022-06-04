-- COVID Deaths and Vaccination queries
-- data origin: https://ourworldindata.org/covid-deaths
-- Warming up, preparing the environment:
--- data about deaths...
SELECT *
FROM `outroprojeto-349922.Covid_files.Deaths` 
order by 3,4
LIMIT 100

-- data about vaccination
SELECT *
FROM `outroprojeto-349922.Covid_files.Vaccination`
order by 1,2

-- Tables are looking good for starting.
-- DATA EXPLORATION
--- Firts question: Total cases vs. Total Deaths (Mortality), and Contamination Rate

SELECT date, location,total_deaths,total_cases, (total_deaths/total_cases)*100 as MortalityPercent, (total_cases/population)*100 as ContaminationPercent 
FROM `outroprojeto-349922.Covid_files.Deaths` 
where location like "%Brazil%"
group by date, location, total_deaths, total_cases, population
order by date desc

-- Highest Mortality and Contamination percentages.

SELECT date, location,population, MAX(total_deaths) as MaxDeaths, MAX(total_cases) as MaxCases, MAX((total_deaths/total_cases))*100 as Max_MortalityPercent, MAX((total_cases/population))*100 as Max_ContaminationPercent 
FROM `outroprojeto-349922.Covid_files.Deaths` 
--where location like "%Brazil%"
where continent is not null
group by date, location, total_deaths, total_cases, population
order by date desc

-- Organizing by continent
SELECT continent, MAX(total_deaths) as TotalDeaths_count
FROM `outroprojeto-349922.Covid_files.Deaths` 
where continent is not null
group by continent
order by 1

--alternativelly... whith this dataset...
SELECT continent, MAX(total_deaths) as TotalDeaths_count
FROM `outroprojeto-349922.Covid_files.Deaths` 
where continent is not null
group by continent
order by 1

-- Global numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM `outroprojeto-349922.Covid_files.Deaths` 
where continent is not null 
group by date
order by 1,4 


-- AND HOW ABOUT VACCINATIONS?

SELECT *
FROM `outroprojeto-349922.Covid_files.Vaccination` 
--where continent is not null 
--group by date
order by 1 

-- PUTTING DATA TOGUETER

SELECT*
FROM `outroprojeto-349922.Covid_files.Deaths` as dea
JOIN `outroprojeto-349922.Covid_files.Vaccination` as vac
  on dea.date = vac.date 
  and dea.location = vac.location


-- Vaccination vs. total population

-- partitioning by Location
SELECT dea.continent, dea.location, dea.date, CAST(dea.population as int), (vac.new_vaccinations)
, SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccination
FROM `outroprojeto-349922.Covid_files.Deaths` as dea
JOIN `outroprojeto-349922.Covid_files.Vaccination` as vac
  on dea.date = vac.date 
  and dea.location = vac.location
where dea.continent is not null
order by 2,3

-- using a CTE - Common Table Expression (CTE)
WITH PopvsVac 
AS 
(
  SELECT dea.continent, dea.location, dea.date, CAST(dea.population as int), (vac.new_vaccinations)
  , SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccination
  FROM `outroprojeto-349922.Covid_files.Deaths` as dea
  JOIN `outroprojeto-349922.Covid_files.Vaccination` as vac
    on dea.date = vac.date 
    and dea.location = vac.location
    where dea.continent is not null
--order by 2,3
)

SELECT*
FROM PopvsVac





-- How many people have been fully vaccinated?

SELECT dea.date, dea.location, dea.population, vac.people_fully_vaccinated, vac.people_vaccinated, (vac.people_fully_vaccinated/dea.population)*100 as ImmunizationPercentage
FROM `outroprojeto-349922.Covid_files.Deaths` as dea
JOIN `outroprojeto-349922.Covid_files.Vaccination` as vac
  on dea.date = vac.date 
  and dea.location = vac.location
where dea.continent is not null
group by dea.location, dea.date, dea.population, vac.people_fully_vaccinated, vac.people_vaccinated
order by 2,3


-- How is the relation between Vaccination and the number of new deaths?



-- CREATE view TO LATER DATA VIZ
CREATE OR REPLACE VIEW Covid_files.nova_view as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM `outroprojeto-349922.Covid_files.Deaths` as dea
JOIN `outroprojeto-349922.Covid_files.Vaccination` as vac
on dea.date = vac.date 
and dea.location = vac.location
--where dea.continent is not null
--order by 2,3

