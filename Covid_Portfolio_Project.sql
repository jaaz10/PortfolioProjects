# Created a database
create database sql_workbench;

# Entered into the database 
use sql_workbench;

# numeric_functions
select abs(-50);
select mod(10,4) as remainder;
select mod(50.6,2) as remainder;

# power
select power(10,3);

# square root
select sqrt(144);

# find the greatest num within a range of num
select greatest(2, 5, 18, 6, 12);

# find the least num within a range of num
select least(2, 5, 18, 6, 12);

# truncates a num to the specified num of decimal places
select truncate (22.897,1); 

# used to round a num to a specified num of decimal places, if not specified it rounds to nearest int
select round(22.897); # no specs
select round(22.897,1); # w/ specs

# Students table
create table students
(stu_id int primary key,
stu_name varchar(25),
age int, gender char(1), doa date, city varchar(20));

# Insert records
insert into students values
(101, "Joseph", 20, "M", "2016-11-23", "Chicago"),
(102, "Jill", 20, "F", "2016-11-23", "Chicago"),
(103, "John", 19, "M", "2016-11-23", "Chicago"),
(104, "Jackie", 22, "F", "2016-11-23", "Chicago"),
(105, "Jake", 21, "M", "2016-11-23", "Chicago");

# return all records in a table
select * from students;

# select specific cols
select stu_name, age, city from students;

# Where Clause helps filter spec records based on certain condition(s)
select * from students where age = '19';
# And Operator
select * from students where gender = 'F' and age = '20';
# Or Operator
select * from students where city = 'Chicago' or city = 'Houston';
select * from students where not city = 'Chicago';

# Group By
select city, count(stu_id) as total_students
from students group by city;

# Having Clause
select city, count(stu_id) as total_students
from students group by city
having count(stu_id) > 3;

# Order By Clause used to filter the records based on particular order (asc or desc)
select * from students order by age asc;

# String Functions
select upper('usa') as upper_case;
select lower('USA') as lower_case;
select lcase('USA') as lower_case;
select character_length('Chicago') as total_length;
select stu_name, char_length(stu_name) as total_length
from students;

# Concat adds two or more expressions together
select concat("Chicago"," is"," in the USA") as merged;
select stu_id, stu_name, concat(stu_name, " ", age) as name_age
from students;

# Reverse Function returns string with the chars in reverse order
select reverse('Chicago');
select reverse(stu_name) from students;

# Replace Function replaces all occurences of a substring within a string, within a new substring
select replace("Apple is a vegetable", "vegetable", "fruit");

# Left_Trim Function removes the leading space char from a string passed as an argument
# RTrim removes trailing spaces
select length(trim("  Chicago  "));
select trim("  Chicago   ");

# Position Function returns the position of the first occurence of a substring in a string
select position('fruit' in 'orange is a fruit') as name;

# Ascii Function returns the ascii value for the specific char
select ascii('a');
select ascii('4');

####################################

select * from coviddeaths
where continent is not null
order by 3,4;

-- select * from CovidVaccinations
-- order by 3,4;

-- Select Data I am using
select date, county, state, fips, cases, deaths
from usCounties
order by 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in specified country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location like '%mexico%'
and continent is not null
order by 1,2;

-- Total Cases vs Population
-- Shows what percentage of population got Covid
select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from coviddeaths
where Location like '%mexico%'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population
select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from coviddeaths
Group by Location, Population
order by PercentPopulationInfected desc;

-- Showing Countries with Highest Death Count per Population
select Location, MAX(cast(Total_deaths as signed)) as TotalDeathCount
from coviddeaths
where continent is not null
Group by Location
order by TotalDeathCount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with highest death count per population
select continent, MAX(cast(Total_deaths as signed)) as TotalDeathCount
from coviddeaths
where continent is not null
Group by continent
order by TotalDeathCount desc;

-- Global Numbers
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(New_cases)*100 as DeathPercentage
from coviddeaths
where continent is not null
group by date
order by 1,2;

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(New_cases)*100 as DeathPercentage
from coviddeaths
where continent is not null
-- group by date
order by 1,2;

-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- USE CTE
with PopvsVac (continent, Location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac;

-- TEMP TABLE
-- DROP Table if exists #PercentPopulationVaccinated
create temporary table PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

####################################################

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated;

####################################################


-- Creating view to store data for later visualization
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select * 
from PercentPopulationVaccinated



