/* change: add an integrity constraint phu[city] is a subset of property[area], checked by a trigger */

drop schema if exists covidschema cascade;
create schema covidschema;
set search_path to covidschema;

create table Patient(
	pid integer primary key,
	age integer not null,
	gender text not null,
	check (gender in ('FEMALE', 'MALE', 'TRANSGENDER','OTHER')), 
	check (age >= 20 and age % 10 = 0),
	check (pid >= 0)
);

create table PHU(
	uid integer primary key,
	name text not null,
	address text not null,
	city text not null,
	check (uid >= 0)
);

create table Record(
	rid integer primary key,
	pid integer references Patient(pid) not null,
	date date not null,
	uid integer references PHU(uid) not null,
	check (rid >= 0),
	check (pid >= 0)
);

create table Outcome(
	rid integer references Record(rid) primary key,
	outcome text not null,
	check (outcome in ('recovery', 'death'))
);

create table Exposure(
	rid integer references Record(rid) primary key,
	method text not null,
	check (method in ('outbreak', 'proximity', 'travel'))
);

create table Property(
	address text primary key,
	area text not null,
	price integer not null,
	check (price > 0)
);

/* trigger */
create function RecordProperty() returns trigger as 
$$
BEGIN
	IF NEW.area not in (select city from PHU) THEN
		raise EXCEPTION '% is not allowd to insert, violates integrity constraints', NEW.address;
		INSERT INTO Property VALUES (NEW.address, NEW.area, NEW.price);
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/* before insert to Property, check whther this insertion works */
create trigger PropertyUpdate
before insert on Property
for each row
execute procedure RecordProperty();






