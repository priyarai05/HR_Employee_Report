show databases;
create database Projects;

USE Projects;
select * from hr;

alter table hr 
change column ï»¿id emp_id varchar(20) NULL;

describe hr;
select birthdate from hr;

set sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
when birthdate like '%-%' then date_format(str_to_date(birthdate,'%d-%m-%Y'),'%Y-%m-%d')
else NULL
END;

alter table hr
modify column birthdate date;

select hire_date from hr;

UPDATE hr
SET hire_date = CASE
when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
when hire_date like '%-%' then date_format(str_to_date(hire_date,'%d-%m-%Y'),'%Y-%m-%d')
else NULL
END;

alter table hr
modify column hire_date date;

select termdate from hr;

UPDATE hr
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
where termdate is NOT NULL and termdate != ' ';

SET sql_mode = 'ALLOW_INVALID_DATES';

alter table hr
modify column termdate date;

describe hr;

alter table hr add column age int;

select * from hr;

update hr
set age = timestampdiff(YEAR,birthdate,curdate());

select birthdate,age from hr;

select min(age) as youngest, max(age) as oldest from hr;
select count(*) from hr where age < 18;

-- Questions
-- 1. What is the gender breakdown of employees in the company?
select gender,count(*) as COUNT from hr where age >= 18 and termdate = '0000-00-00' group by gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
select race, count(*) as COUNT from hr where age >= 18 and termdate = '0000-00-00' group by race order by COUNT DESC;

-- 3. What is the age distribution of employees in the company?
select min(age) as youngest, max(age) as oldest from hr where age >= 18 and termdate = '0000-00-00';

select case
	when age >= 18 and age < 25 then "18-24"
    when age >= 25 and age < 35 then "25-34"
    when age >= 35 and age < 45 then "35-44"
    when age >= 45 and age < 55 then "45-54"
    when age >= 55 and age < 65 then "55-64"
    else '65+'
	end as age_group,count(*) as COUNT
    from hr
    where age >= 18 and termdate = '0000-00-00'
    group by age_group order by age_group;
    
select case
	when age >= 18 and age < 25 then "18-24"
    when age >= 25 and age < 35 then "25-34"
    when age >= 35 and age < 45 then "35-44"
    when age >= 45 and age < 55 then "45-54"
    when age >= 55 and age < 65 then "55-64"
    else '65+'
	end as age_group,gender,count(*) as COUNT
    from hr
    where age >= 18 and termdate = '0000-00-00'
    group by age_group,gender order by age_group,gender;
    
-- 4. How many employees works at headquarters vs remote locations?
select location, count(*) as COUNT from hr where age >= 18 and termdate = '0000-00-00' group by location;

-- 5. What is the average length of employement for employees who have terminated?
select round(avg(datediff(termdate,hire_date)/365),0) as avg_length_employement from hr where age >= 18 and termdate <> '0000-00-00' and termdate <= curdate();

-- 6. How does the gender distribution vary across departments and job titles?
select department,gender,count(*) as COUNT from hr where age >= 18 and termdate = '0000-00-00' 
group by department,gender order by department;

-- 7. What is the distribution of jobs title across the company?
select jobtitle, count(*) as COUNT from hr where age >= 18 and termdate = '0000-00-00'
group by jobtitle order by jobtitle desc;

-- 8. Which department has the highest turnover rate?
select department, total_count, terminated_count, terminated_count/total_count as termination_rate
from (select department, count(*) as total_count,
sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminated_count from hr where age >= 18
group by department) as subquery order by termination_rate desc;

-- 9. What is the distirbution of employee across locations by city and state?
select location_state, count(*) as COUNT from hr where age >= 18 and termdate = '0000-00-00' group by location_state order by COUNT desc;

-- 10. How has the company employee count changed over time based on hire and term dates?
select year, hires, terminations, round(((hires-terminations)/hires)*100,2) as net_change_percent
from (select YEAR(hire_date) as year,count(*) as hires,
sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminations from hr where age >= 18 
group by year) as subquery order by year;

-- select count(termdate) from hr where termdate = '';

-- 11. What is the tenure distribution of each department?
select department, round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure from hr
where age >= 18 and termdate <> '0000-00-00' and termdate <= curdate() group by department;