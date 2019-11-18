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
number integer not null primary key,
cName varchar(60) not null,
cVersion varchar(3) not null,
size varchar(20) not null,
language enum('C','C++','C#','Java','PHP', 'Python', 'assembly'),
cStatus enum('ready', 'usable', 'not-ready'),
Owner integer references people(ID)
);

drop table if exists build;
create table build(
pName varchar(60) references product(pName),
pVersion varchar(20) references product(pVersion),
cNumber integer references components(number),
primary key(pName, pVersion, cNumber)
);

drop table if exists peerReview;
create table peerReview(
cNum integer references components(number),
date date not null,
byWho integer references people(ID),
score integer not null,
texture_description varchar(500),
primary key(byWho,cNum,date)
);

drop trigger if exists check_id;
DELIMITER //
create trigger check_id before insert on people for each row
begin
	if(new.ID not between 10000 AND 99999) then
    SIGNAL SQLSTATE '45000'
    SET MYSQL_ERRNO = 30001, MESSAGE_TEXT = 'ID must be 5-digit';
    end if;
end //
DELIMITER ;

drop trigger if exists get_score;
Delimiter //
create trigger get_score after insert on peerReview for each row
begin
	if(new.score between 91 and 100) then
		update components
		set cStatus = 'ready'
		where number = new.cNum;
	elseif(new.score between 75 and 90) then
		update components
		set cStatus = 'usable'
        where number = new.cNum;
	elseif(new.score between 1 and 75) then
		update components 
        set cStatus = 'not-ready'
		where number = new.cNum;
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

insert into components (number,cName,cVersion,size,language,Owner) values
(1,'Keyboard Driver','K11','1200','C',10100),
(2,'Touch Screen Driver','A01','4000','C++',10100),
(3,'Dbase Interface','D00','2500','C++',10200),
(4,'Dbase Interface','D01','2500','C++',10300),
(5,'Chart generator','C11','6500','Java',10200),
(6,'Pen driver','P01','3575','C',10700),
(7,'Math unit','A01','5000','C',10200),
(8,'Math unit','A02','3500','Java',10200);

insert into build values
('Excel','2010',1),
('Excel','2010',3),
('Excel','2015',1),
('Excel','2015',4),
('Excel','2015',6),
('Excel','2018bata',1),
('Excel','2018bata',2),
('Excel','2018bata',5),
('Excel','secret',1),
('Excel','secret',2),
('Excel','secret',5),
('Excel','secret',8);

insert into peerReview values
(1,'2012-02-14',10100,100,'legacy code which is already approved'),
(2,'2019-06-01',10200,95,'initial release ready for usage'),
(3,'2012-02-22',10100,55,'too many hard coded parameters, the software must be more maintainable and configurable because we want to use this in other products.'),
(3,'2012-02-24',10100,78,'improved, but only handles DB2 format'),
(3,'2012-02-26',10100,95,'Okay,handles DB3 format.'),
(3,'2012-02-28',10100,100,'okay, fixed input flexibility routine'),
(4,'2013-05-01',10200,100,'Okay, ready for use'),
(6,'2019-07-15',10300,80,'Okay, ready for beta testing'),
(7,'2016-06-10',10100,90,'almost ready, potential buffer overflow'),
(8,'2016-06-15',10100,70,'Accuracy problems!'),
(8,'2016-06-30',10100,100,'Okay problems fixed'),
(8,'2016-11-02',10700,100,'re-review for new employee to gain experience in the process.');

select * from components;