create table product(
pName varchar(60) not null,
pVersion varchar(20) not null,
pStatus varchar(20),
primary key(pName, pVersion)
);

create table people(
ID integer not null primary key,
name varchar(60) not null,
seniority enum('newbie', 'junior', 'senior')
);

create table components(
cName varchar(60) not null,
cVersion varchar(3) not null,
size varchar(20) not null,
language varchar(20) not null,
cStatus enum('ready', 'usable', 'not-ready'),
ID int(5) references people(ID),
primary key(cName, cVersion)
);

create table build(
pName varchar(60) references product(pName),
pVersion varchar(20) references product(pVersion),
cName varchar(60) references components(cName),
cVersion varchar(3) references components(cVersion),
primary key(pName, pVersion, cName, cVersion)
);

create table peerReview(
ID integer references people(ID),
cName varchar(60) references components(cName),
cVersion varchar(3) references components(cVersion),
date date not null,
score integer not null,
texture_description varchar(100)
);

    