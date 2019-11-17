drop table if exists product;
create table product(
pName varchar(60) not null,
pVersion varchar(20) not null,
primary key(pName, pVersion)
);

drop table if exists people;
create table people(
ID integer not null primary key,
name varchar(60) not null,
hireDate date not null,
seniority varchar(6),
Mgr integer references people(ID)
);

drop table if exists components;
create table components(
cName varchar(60) not null,
cVersion varchar(3) not null,
size varchar(20) not null,
language enum('C','C++','C#','Java','PHP', 'Python', 'assembly'),
cStatus enum('ready', 'usable', 'not-ready'),
Owner integer references people(ID),
primary key(cName, cVersion)
);

drop table if exists build;
create table build(
pName varchar(60) references product(pName),
pVersion varchar(20) references product(pVersion),
cName varchar(60) references components(cName),
cVersion varchar(3) references components(cVersion),
primary key(pName, pVersion, cName, cVersion)
);

drop table if exists peerReview;
create table peerReview(
byWho integer references people(ID),
cName varchar(60) references components(cName),
cVersion varchar(3) references components(cVersion),
date date not null,
score integer not null,
texture_description varchar(500)
);

DELIMITER //
create trigger check_id before insert on people for each row
begin
	if(new.ID not between 10000 AND 99999) then
    SIGNAL SQLSTATE '45000'
    SET MYSQL_ERRNO = 30001, MESSAGE_TEXT = 'ID must be 5-digit';
    end if;
end //
DELIMITER ;

Delimiter //
create trigger get_score after insert on peerReview for each row
begin
	if(new.score between 91 and 100) then
		update components c
		set c.status = 'ready'
		where c.cName = new.cName AND c.cVersion = new.cVersion;
	elseif(new.score between 75 and 90) then
		update components c
		set c.status = 'usable'
        where c.cName = new.cName AND c.cVersion = new.cVersion;
	elseif(new.score between 1 and 75) then
		update components c
        set c.status = 'not-ready'
		where c.cName = new.cName AND c.cVersion = new.cVersion;
	else
		SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 30001, MESSAGE_TEXT = 'Your input is out of range';
	end if;
end //
Delimiter ;

drop trigger if exists get_seniority;
Delimiter //
	create trigger get_seniority before insert on people for each row
    begin
		DECLARE datediff int;
		set datediff = DATEDIFF(CURRENT_DATE(), new.hireDate);
		if(datediff < 365) then
            set new.seniority = 'newbie';
		elseif(datediff between 365 and 1824) then
            set new.seniority = 'junior';
		elseif(datediff > 1825) then
            set new.seniority = 'senior';
		end if;
	end //
Delimiter ;

insert into product values
('Excel','2010'),
('Excel','2015'),
('Excel','2018bata'),
('Excel','secret');

insert into people (ID,name,hireDate,Mgr) values
(10100,'Employee-1','1984-11-08',null),
(10200,'Employee-2','1994-11-08',10100),
(10300,'Employee-3','2004-11-08',10200),
(10400,'Employee-4','2013-11-01',10200),
(10500,'Employee-5','2017-11-01',10400),
(10600,'Employee-6','2017-11-01',10400),
(10700,'Employee-7','2018-11-01',10400),
(10800,'Employee-8','2019-11-01',10200);