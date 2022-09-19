SELECT *
FROM covid_deaths  
ORDER BY 3,4

/* SELECT *
FROM covid_vaccinations
ORDER BY 3,4 */

-- Select Data that to be used 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY location, date

-- Total Cases vs Total Deaths in the US
-- Probability of dying depending on the country as well as the date
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_percentage
FROM covid_deaths
-- WHERE location LIKE '%states%'

-- Total Cases vs Population of the country
-- Percentage of population that contracted covid
SELECT location, date, population, total_cases, total_deaths, (total_cases / population) * 100 AS percentage_with_covid
FROM covid_deaths
-- WHERE location LIKE '%states%'
ORDER BY location, date

-- Countries with highest covid contraction rate, compared to the population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 AS percentage_population_infected
FROM covid_deaths
GROUP BY location, population
-- HAVING location LIKE '%serbia%'
ORDER BY percentage_population_infected DESC

-- Countries with highest death count per population
SELECT location, population, MAX(total_deaths) as totaldeathcount, MAX((total_deaths / population)) * 100 AS deaths_per_population
FROM covid_deaths
GROUP BY location, population
-- HAVING location LIKE '%Canada%'
ORDER BY deaths_per_population DESC

-- Looking at deaths per continent
SELECT location, MAX(total_deaths) AS totaldeaths
FROM covid_deaths
WHERE location IN ('Africa','South America','North America','Europe','Asia','World','Oceania')
GROUP BY location
ORDER BY location DESC

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS all_cases, SUM(new_deaths) AS all_deaths, (SUM(new_deaths) / SUM(new_cases)) AS deathpercentage
FROM covid_deaths
GROUP BY date
ORDER BY 1,2


-- Joining Deaths Table with Vaccinations table
-- Total population vs vaccination
-- USING CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS 
(SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM covid_deaths cd 
JOIN covid_vaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / Population)* 100
FROM PopvsVac

-- TEMP TABLE -- 
/*DROP TABLE IF EXISTS PercentPopulationVaccinated
Create TABLE PercentPopulationVaccinated
(
	Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
)
Insert INTO
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as people_vaccinated
FROM covid_deaths cd 
JOIN covid_vaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated / Population)* 100
FROM PercentPopulationVaccinated */

-- Creating view to store data for visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM covid_deaths cd 
JOIN covid_vaccinations cv
	ON cd.location = cv.location 
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL



