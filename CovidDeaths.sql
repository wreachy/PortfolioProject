SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPecentage
FROM CovidDeaths
WHERE location LIKE '%tia'
ORDER BY 1,2

SELECT location,date,total_cases,population,(total_cases/population)*100 AS PopulationPecentage
FROM CovidDeaths
WHERE location LIKE '%states'
ORDER BY 1,2

SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PopulationPecentageInfected
FROM CovidDeaths
GROUP BY location,Population
ORDER BY PopulationPecentageInfected DESC

SELECT location,MAX(total_deaths) AS MaxDeaths,population,MAX(total_deaths/population)*100 AS HighestDeathCountPercentage
FROM CovidDeaths
WHERE continent is not Null
GROUP BY location,Population
ORDER BY HighestDeathCountPercentage DESC

SELECT location,MAX(total_deaths) AS MaxContinentDeaths,population,MAX(total_deaths/population)*100 AS HighestDeathCountPercentage 
FROM CovidDeaths
WHERE continent is Null
GROUP BY location,population
ORDER BY HighestDeathCountPercentage  DESC

SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated,
dea.population
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL 
ORDER BY 2,3


WITH PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL AND dea.continent = 'Africa' 
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM PopvsVac
