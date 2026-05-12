-- exemple de fitxer sql per a crear una mini base de dades

-- sobre l'exemple d'una prova curta exer 11 La cultura del vi
-- crearem la BD corresponent a les entitats VARIETAT, VI i la 
-- interrelació CUPATGE

-- exemple actualitzat per a obligar a treballar amb taules INNODB

drop database BD1;

create database BD1;
use BD1;

create table vi (
  codi int(5) zerofill not null auto_increment,
  nom varchar(25),
  constraint pk_vi primary key (codi)
) engine=innodb;

insert into vi(nom) values ('Castell del Remei 2000');
insert into vi(nom) values ('Les Terrasses 2007');
insert into vi(nom) values ('Gran Coronas 2005');
insert into vi(nom) values ('Perlat 2007');
insert into vi(nom) values ('Castell del Remei 1780');


create table varietat (
  nom varchar(20) not null,
  descripcio varchar(30),
  constraint pk_varietat primary key (nom)
) engine=innodb;

insert into varietat(nom) values ('Garnatxa');
insert into varietat(nom) values ('Carinyena');
insert into varietat(nom) values ('Syrah');
insert into varietat(nom) values ('Tempranillo');
insert into varietat(nom) values ('Merlot');
insert into varietat(nom) values ('Monestrell');
insert into varietat(nom) values ('Cabernet Sauvignon');
  
  
create table cupatge (
  codi int(5) zerofill not null,
  nom varchar(20) not null,
  proporcio int(3) not null,
  constraint pk_cupatge primary key (codi, nom),
  constraint fk_cupatge_vi foreign key (codi) references vi(codi),
  constraint cupatge_varietat foreign key (nom) references varietat(nom)
) engine=innodb;

insert into cupatge(codi, nom, proporcio) values (1, 'Cabernet Sauvignon', 30);
insert into cupatge(codi, nom, proporcio) values (1, 'Merlot', 30);
insert into cupatge(codi, nom, proporcio) values (1, 'Tempranillo', 40);
insert into cupatge(codi, nom, proporcio) values (2, 'Carinyena', 60);
insert into cupatge(codi, nom, proporcio) values (2, 'Garnatxa',30);
insert into cupatge(codi, nom, proporcio) values (2, 'Cabernet Sauvignon', 10);
insert into cupatge(codi, nom, proporcio) values (3, 'Cabernet Sauvignon', 85);
insert into cupatge(codi, nom, proporcio) values (3, 'Tempranillo', 15);
insert into cupatge(codi, nom, proporcio) values (4, 'Carinyena', 50);
insert into cupatge(codi, nom, proporcio) values (4, 'Garnatxa', 30);
insert into cupatge(codi, nom, proporcio) values (4, 'Syrah', 20);
insert into cupatge(codi, nom, proporcio) values (5, 'Garnatxa', 30);
insert into cupatge(codi, nom, proporcio) values (5, 'Tempranillo', 40);
insert into cupatge(codi, nom, proporcio) values (5, 'Cabernet Sauvignon', 30);
 

