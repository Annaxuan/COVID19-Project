-- CSC343 Project.
-- Authors: Chayim Lowen and Wenxuan Sun.
-- Schema for the project.

drop schema if exists covidschema cascade;  
create schema covidschema;  
set search_path to covidschema;  

-- An Ontarian that test positive for covid-19. 
create table Patient(  
    pid integer primary key,  
    -- The id of the patient.
    age integer not null,  
    -- the age group of the patient.
    gender text not null,  
    -- the gender of the patient.
    check (gender in ('FEMALE', 'MALE', 'TRANSGENDER','OTHER')),   
    check (age >= 10 and age % 10 = 0),  
    check (pid >= 0)  
);  

-- A piece of real estate in Ontario.
create table Property(  
    address text primary key,  
    -- The address of the estate.
    area text not null,  
    -- The area where the estate is located.
    price integer not null,  
    -- The sale price of the estate.
    check (price >= 0)  
);  

-- An Ontarian public health unit.
create table PHU(  
    uid integer primary key,  
    -- The id of the public health unit.
    name text not null,  
    -- The name of the public health unit.
    city text not null, 
    -- The city where the public health unit is located.
    postalCode text not null,  
    -- The postal code of the public health unit.
    check (uid >= 0)  
);  

-- A record of a certain Ontarian is reported or discovered 
-- their illness at a certain health unit.
create table Record(  
    rid integer primary key,  
    -- The id of the record.
    pid integer references Patient(pid) not null, 
    -- The if of the patient. 
    date date not null,  
    -- The date of the reported or discovered date.
    uid integer references PHU(uid) not null,  
    -- The public health unit that record this case.
    check (rid >= 0),  
    check (pid >= 0)  
);  

-- A known outcome of a certain Covid-19 case.
create table Outcome(  
    rid integer references Record(rid) primary key,  
    -- The id of the record.
    outcome text not null,  
    -- The outcome of the record.
    check (outcome in ('recovery', 'death'))  
);  

-- The suspicion that the patient in a certain case was 
-- infected with Covid-19 by certain means.
create table Exposure(  
    rid integer references Record(rid) primary key,  
    -- The id of the record.
    method text not null,  
    -- The suspected means.
    check (method in ('outbreak', 'proximity', 'travel'))  
);  
 
 
-- A trigger.
create function RecordPHU() returns trigger as   
$$  
BEGIN  
    IF NEW.city not in (select area from Property) THEN  
       raise EXCEPTION '% is not allowd to insert, violates integrity constraints', NEW.name;  
       INSERT INTO Property VALUES (NEW.uid, NEW.name, NEW.city, NEW.postalCode);  
    END IF;  
    RETURN NEW;  
END;  
$$ LANGUAGE plpgsql;  
  
-- Before insert to phu, check whether this violet the integrity constraint 
-- that phu[city] is a subset of property[area].
create trigger PHUUpdate  
before insert on PHU  
for each row  
execute procedure RecordPHU();  
