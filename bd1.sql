-- exemple de fitxer sql per a crear una mini base de dades

-- sobre l'exemple d'una prova curta exer 11 La cultura del vi
-- crearem la BD corresponent a les entitats VARIETAT, VI i la 
-- interrelació CUPATGE

-- exemple actualitzat per a obligar a treballar amb taules INNODB


--varchar(25) limit real de longitud.   --int(5) limit de visualitzacio
--zerofill per a que els numeros es mostrin amb zeros a l'esquerra.  --auto_increment per a que el valor s'incrementi automàticament cada cop que s'insereix un nou registre
-- autoincrement només es pot utilitzar en una columna que sigui clau primària o que tingui un índex únic.  --constraint per a definir restriccions com claus primàries o foranes. 
 --primary key per a definir la clau primària d'una taula.  
 --foreign key per a definir una clau forana que fa referència a una altra taula. 
  --engine=innodb per a especificar el motor de base de dades InnoDB, que suporta transaccions i claus foranes.

drop database BDPesca;

create database BDPesca;
use BDPesca;

create table zones (
  id_zones int(5) zerofill not null
  nom_massa varchar(25) not null,
  municipi varchar(25),
  limit_superior varchar(25),
  limit_inferior varchar(25),
  tipus varchar(15), not null, --es total
  constraint pk_zones primary key (id_zones, nom_massa),
  constraint check_tipus check (tipus in ("esportiva", "sense_mort", "veda"))
 
) engine=innodb;


create table especies (
  nom_popular varchar(20) not null,
  nom_cientific varchar(30),
  longitud_mitja float(5,2) not null,
  constraint pk_especies check (longitud_mitja >0),
  constraint pk_nom_popular primary key (nom_popular)
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
 

