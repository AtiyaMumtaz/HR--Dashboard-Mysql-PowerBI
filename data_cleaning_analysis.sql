-- Data Cleaning Queries
create database projects;
use projects;
select * from hr;
-- change name of id column to make it convenient
alter table hr change column ï»¿id emp_id varchar(20) null;
describe hr;
-- changing all the dates in same format
select birthdate from hr;
set sql_safe_updates=0;

-- BIRTHDATE COLOUMN

update hr set birthdate = case 
			when birthdate like'%/%' then date_format(str_to_date(birthdate, '%m/%d/%Y'),'%Y-%m-%d')
			when birthdate like'%-%' then date_format(str_to_date(birthdate, '%m-%d-%Y'),'%Y-%m-%d')
			else null
			end;

-- adjusting birthyear wrt to current year
UPDATE hr
SET birthdate = DATE_SUB(birthdate, INTERVAL 100 YEAR)
WHERE YEAR(birthdate) > YEAR(CURDATE());
SELECT birthdate
FROM hr;
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;
select * from hr; -- to check the update

-- HIRE DATE COLOUMN

-- select hire_date from hr where hire_date not like '%/%' and hire_date not like '%-%';

update hr set hire_date = case 
						when hire_date like'%/%' then date_format(str_to_date(hire_date, '%m/%d/%Y'),'%Y-%m-%d')
                        when hire_date like'%-%' then date_format(str_to_date(hire_date, '%m-%d-%Y'),'%Y-%m-%d')
						else null
                        end;
select hire_date from hr;
alter table hr 
modify column hire_date DATE;
select * from hr;

-- TERMDATE COLOUMN
update hr 
set termdate = date(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != '';

UPDATE hr
SET termdate = NULL
WHERE termdate = '';

select termdate from hr;

alter table hr
modify column termdate DATE;

describe hr;

-- Add Age column 

ALTER TABLE hr ADD COLUMN age INT;
UPDATE hr
SET  age = timestampdiff(YEAR, birthdate, curdate());

select birthdate, age from hr;

select min(age) as youngest, max(age) as eldest from hr;

select count(*) from hr where age<18; -- count 0

-- DATA ANALYSIS QUESTIONS

-- Q1: WHAT IS THE GENDER BREAKDOWN OF THE COMPANY?
SELECT gender, count(*) AS count from hr
	where age>18 and termdate is null
    group by gender;

-- Q2: WHAT IS THE RACE/ETHNICITY BREAKDOWN OF EMPLOYEES IN THE COMPANY?
select race, count(*) as count from hr
where age>18 and termdate is null
group by race order by count(*) desc;

-- Q3 WHAT IS THE AGE DISTRIBUTION OF EMPLOYEES IN THE COMPANY?
 select 
 min(age) as youngest,
 max(age) as eldest 
 from hr
 where age>18 and termdate is null;
 
 SELECT 
    CASE 
        WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
        ELSE '65+'
    END AS age_group, 
    COUNT(*) AS count
FROM hr 
WHERE age >= 18 
AND termdate IS NULL
GROUP BY age_group
ORDER BY age_group;

-- AGE AND GENDER DISTRIBUTION
SELECT 
    CASE 
        WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
        ELSE '65+'
    END AS age_group, gender,
    COUNT(*) AS count
FROM hr 
WHERE age >= 18 
AND termdate IS NULL
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- Q4 HOW MANY EMPLOYEES WORK AT HEADQUATER VERSUS REMOTE LOCATION?
select location, count(*) as count 
from hr
WHERE age >= 18 
AND termdate IS NULL
group by location;

-- Q5 WHAT IS THE AVERAGE LENGTH OF EMPLOYMENT FOR EMPLOYEES WHO HAVE BEEN TERMINTAED?
SELECT 
    round(AVG(DATEDIFF(termdate, hire_date)) / 365,0) AS avg_length_of_employment
FROM hr
WHERE termdate <= CURDATE() 
AND termdate IS NOT NULL;

-- Q6 HOW DOES GENDER DISTRIBUTION VARY ACCROSS DEPARTMENTS AND JOB TITLES?
select department, gender, count(*) as count
from hr
WHERE age >= 18 
AND termdate IS NULL
group by department, gender
order by department;

-- Q7 DISTRIBUTION OF GROUP TITLES ACCROSS THE COMPANY?
select jobtitle, count(*) as count 
from hr 
where termdate is null 
group by jobtitle
order by jobtitle desc;

-- Q8 WHICH DEPARTMENT HAS THE HIGHEST TURNOVER RATE?
select department, total_count, terminated_count, terminated_count/total_count as termination_rate
from ( select department, count(*) as total_count, sum(case when termdate is not null and termdate<=curdate() then 1 else 0 end) as terminated_count
from hr group by department) as subquery
order by termination_rate desc;

-- Q9 WHAT IS THE DISTRIBUTION OF EMPLOYEES ACCROSS LOCATION BY CITY AND STATE?
select location_state, count(*) as count
from hr
where termdate is null
group by location_state 
order by count desc;

-- Q10 HOW HAS THE COMPANY'S EMPLOYEE COUNT CHANGED OVER TIME BASED ON HIRE AND TERM DATES?
select 
year,
hires,
terminations,
hires-terminations as net_change,
round((hires-terminations)/ hires * 100, 2) as net_change_percent
from (select year(hire_date) as year,
count(*) as hires,
sum(case 
	when termdate is not null and termdate<=curdate() then 1 else 0 end) as terminations
    from hr 
    group by year(hire_date)) as subquerry
    order by  year asc;

-- Q11 WHAT IS THE TENURE DISTRIBUTION FOR EACH DEPARTMENT?
select department, round ( avg (datediff(termdate, hire_date)/365),0) as avg_tenure
from hr
where termdate <=curdate() and termdate is not null
group by department;
