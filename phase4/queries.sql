-- Question 1

-- gender stands for gender of the patients, cases stand for how many
-- cases with that gender.
select gender, count(*) as cases
from patient natural join record
where gender = 'MALE' or gender = 'FEMALE'
group by gender;


select age, gender, count(*) as cases
from patient natural join record
where gender = 'MALE' or gender = 'FEMALE'
group by age, gender
order by age desc, gender;

select age, male*1.0/female as ratio
from
(select age, count(*) as male
from patient
natural join record
where gender = 'MALE'
group by age) as men
natural join
(select age, count(*) as female
from patient
natural join record
where gender = 'FEMALE'
group by age) as women
order by age desc;

select age, gender, count(*) as cases
from patient
natural join record
natural join exposure
where (gender = 'MALE' or gender = 'FEMALE')
and method = 'proximity'
group by age, gender
order by age desc, gender;

select age, male*1.0/female as ratio
from
(select age, count(*) as male
from patient
natural join record
natural join exposure
where gender = 'MALE' and method = 'proximity'
group by age) as men
natural join
(select age, count(*) as female
from patient
natural join record
natural join exposure
where gender = 'FEMALE' and method = 'proximity'
group by age) as women
order by age desc;

select gender, coalesce(outcome, 'unresolved') as outcome, count(*) as cases
from patient
natural join record
natural left join outcome
where gender = 'MALE' or gender = 'FEMALE'
group by gender, outcome
order by gender, outcome;

select age, gender,
sum(
	case
	when outcome = 'recovery'
		then 1
	else 0
	end
)*1.0/count(*) as rate
from patient
natural join record
natural join outcome
where gender = 'MALE' or gender = 'FEMALE'
group by age, gender
order by age, gender;

-- Question 2
DROP VIEW IF EXISTS ageAndExposure1 CASCADE;
create view ageAndExposure1 as
select exposure.method, patient.age, count(*) as cases
from patient natural join record natural join exposure
group by exposure.method, patient.age
ORDER by patient.age DESC;

DROP VIEW IF EXISTS ageAndExposure2 CASCADE;
create view ageAndExposure2 as
select age, sum(cases) as total
from ageAndExposure1
group by age;

/* ratio for method proximity and age 90 equals to 0.027 menas that there 
are 2.7% old people(age 90s) is inflect by proximity method. */ 


-- method represents how patients inflected with covid, age stands for
-- their age group, cases stand for the number of patients with specific age
-- group and specific exposure method, ratio represents the percentage of 
-- patients with a specific age group are inflected with covid by that method. 
-- For example, add together the ratio of proximity, travel, outbreak with 
-- age group of '20', we will get 100%. Where approximately 68% exposure by 
-- proximity, 4.6% exposure by travel, and 27.4% exposure by outbreak.
--

-- people exposure by proximity, ordered by age group
--
select ageAndExposure1.method, ageAndExposure1.age, ageAndExposure1.cases,
ageAndExposure1.cases/ageAndExposure2.total as ratio
from ageAndExposure1 natural join ageAndExposure2
where method = 'proximity';

-- people exposure by travel, ordered by age group
--
select ageAndExposure1.method, ageAndExposure1.age, ageAndExposure1.cases,
ageAndExposure1.cases/ageAndExposure2.total as ratio
from ageAndExposure1 natural join ageAndExposure2
where method = 'travel';

-- people exposure by outbreak, ordered by age group
--
select ageAndExposure1.method, ageAndExposure1.age, ageAndExposure1.cases,
ageAndExposure1.cases/ageAndExposure2.total as ratio
from ageAndExposure1 natural join ageAndExposure2
where method = 'outbreak';

/* in all age groups, most of people is inflect by outbreak */

DROP VIEW IF EXISTS genderAndExposure1 CASCADE;
create view genderAndExposure1 as
select exposure.method, patient.gender, count(*) as cases
from patient natural join record natural join exposure
group by exposure.method, patient.gender
ORDER by gender DESC;

DROP VIEW IF EXISTS genderAndExposure2 CASCADE;
create view genderAndExposure2 as
select gender, sum(cases) as total
from genderAndExposure1
group by gender;

-- method represents how patients inflected with covid, gender stands for
-- their gender, cases stand for the number of patients with specific gender
-- and specific exposure method, ratio represents the percentage of patients
-- with a specific gender are inflected with covid by that method. 
-- For example, add together the ratio of proximity, travel, outbreak with 
-- gender of 'MALE', we will get 100%. Where approximately 51% exposure by 
-- proximity, 7% exposure by travel, and 42% exposure by outbreak.
--

-- people exposure by travel, ordered by gender group
--
select genderAndExposure1.method, genderAndExposure1.gender, 
genderAndExposure1.cases, 
genderAndExposure1.cases/genderAndExposure2.total as ratio
from genderAndExposure1 natural join genderAndExposure2
where method = 'proximity';

-- people exposure by travel, ordered by gender group
--
select genderAndExposure1.method, genderAndExposure1.gender, 
genderAndExposure1.cases, 
genderAndExposure1.cases/genderAndExposure2.total as ratio
from genderAndExposure1 natural join genderAndExposure2
where method = 'travel';

-- people exposure by outbreak, ordered by gender group
--
select genderAndExposure1.method, genderAndExposure1.gender, 
genderAndExposure1.cases, 
genderAndExposure1.cases/genderAndExposure2.total as ratio
from genderAndExposure1 natural join genderAndExposure2
where method = 'outbreak';

-- Question 3
DROP VIEW IF EXISTS sameArea CASCADE;
create view sameArea as
select distinct property.address, property.area, 
property.price, phu.uid
from phu cross join property
where phu.city = property.area;

DROP VIEW IF EXISTS areaPrice CASCADE;
create view areaPrice as
select area, avg(price) as avgPrice, count(*) as numProperty
from sameArea
group by area
order by avgPrice desc;

DROP VIEW IF EXISTS sameCity CASCADE;
create view sameCity as
select record.rid, phu.city
from phu natural join record;

DROP VIEW IF EXISTS cityCases CASCADE;
create view cityCases as
select city, count(*) as cases
from sameCity
group by city;


-- city stands for a city inside Ontario, numproperty stands for how
-- many properties inside this city, and cases stands for the recorded
-- cases.
-- order by price, from rich area(Oakville) to poor area(Cornwall)
--
select cityCases.city, areaPrice.avgPrice, cityCases.cases
from areaPrice cross join cityCases
where areaPrice.area = cityCases.city
order by areaPrice.avgPrice desc;


-- city stands for a city inside Ontario, numproperty stands for how
-- many properties inside this city, and cases stands for the recorded
-- cases.
-- order by price, from rich area to poor area
-- order by number of property, from 1152(Toronto) to 1(Sault Ste.Marie)
select cityCases.city, areaPrice.numProperty, cityCases.cases
from areaPrice cross join cityCases
where areaPrice.area = cityCases.city
order by areaPrice.numProperty desc;


