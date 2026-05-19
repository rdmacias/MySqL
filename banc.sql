-- exemple de fitxer sql per a crear una mini base de dades


-- exemple actualitzat per a obligar a treballar amb taules INNODB

drop database BANC;

create database BANC;
use BANC;

create table clients(
  dni varchar(9),
  nom varchar(20) not null,
  cognom1 varchar(20) not null,
  cognom2 varchar(20),
  telf int(9) not null,
  poblacio varchar(25) not null,
  constraint pkclients primary key (dni)
) engine=innodb;




create table comptes (
  num int(10),
  dni_client varchar(9) not null,
  saldo float(10,2) zerofill not null, 
  constraint pk_comtes primary key (num),
  constraint fk_clients foreign key (dni_client) references clients (dni)
) engine=innodb;

