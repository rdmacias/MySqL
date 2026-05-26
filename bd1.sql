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


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- entitats
drop database BDPesca;

create database BDPesca;
use BDPesca;

create table zones (
  id_zones int(5),
  nom_massa varchar(25),
  municipi varchar(25), 
  limit_superior varchar(25),
  limit_inferior varchar(25),
  tipus varchar(15) NOT NULL, --es total
  constraint pk_zones primary key (id_zones, nom_massa),
  constraint check_tipus check (tipus IN ("esportiva", "sense_mort", "veda"))
 
) engine=innodb;


create table especies (
  nom_popular varchar(20), 
  nom_cientific varchar(30),
  longitud_mitja float(5,2)  NOT NULL,
  constraint pk_especies check (longitud_mitja >0),
  constraint pk_nom_popular primary key (nom_popular),
  constraint ak_nom_cientific unique (nom_cientific)
) engine=innodb;

create table persona(
  dni char(9), 
  nom varchar(25) NOT NULL,
  constraint pk_persona primary key (dni)
 ) engine=innodb;

create table pescadors (
  dni char(9) ,
  carrer varchar(25) NOT NULL,
  ciutat varchar(25) NOT NULL,
  comunitat varchar(25) NOT NULL,
  constraint pk_pescadors primary key (dni),
  constraint fk_persona foreign key (dni) references persona (dni)
 ) engine=innodb;

  create table funcionaris (
    dni char(9),
    nss char(12) not null,
    sou float(10,2) not null,
    
    constraint pk_funcionaris primary key (dni),
    constraint fk_persona foreign key (dni) references persona (dni),
    constraint ak_nom_cientific unique (nom_cientific)
  )
-------------------------------------------------------------------------------------------------------
 -- interrelacions

create table habitats (
  massa_aigua varchar(25),
  num_zona int(5),
  nom_especie varchar(20),
  index_poblacio int(5),
  constraint pk_habitats primary key (massa_aigua, num_zona, nom_especie),
  constraint fk_zones foreign key (num_zona, massa_aigua) references zones (id_zones, nom_massa),
  constraint fk_especies foreign key (nom_especie) references especies (nom_popular),
) engine=innodb;

-- obligatorietat en els dos sentits (controlar insercions)
delimiter $$
create trigger trg_check_especie_te_habitat
after insert on especies
for each row
begin
  if (select count(*) from habitats 
      where nom_especie = NEW.nom_popular) = 0 then
    signal sqlstate '45000'
    set message_text = 'Aquesta especie no te cap habitat assignat';
  end if;
end$$
delimiter ;

delimiter $$
create trigger trg_check_zona_te_habitat
after insert on zona
for each row
begin
  if (select count(*) from habitats 
      where num_zona = NEW.id_zones
      and massa_aigua = NEW.nom_massa) = 0 then
    signal sqlstate '45000'
    set message_text = 'Aquesta zona no te cap habitat assignat';
  end if;
end$$
delimiter;


create table assignacions(
  funcionari char(9),
  data_inici date,
  num_zona int(5),
  nom_massa varchar(25),
  data_fi date NOT NULL,
  constraint pk_assignacions primary key (funcionari, data_inici, num_zona, nom_massa),
  constraint fk_zones foreign key (num_zona, nom_massa) references zones (id_zones, nom_massa),
  constraint fk_funcionari foreign key (funcionari) references funcionaris (dni),
)

create table permisos(
num_zona int(5),
nom_massa varchar(25) ,
data_vigencia date, 
num_max int(3) NOT NULL,

constraint pk_permisos primary key (num_zona, nom_massa, data_vigencia),
constraint fk_zones foreign key (num_zona, nom_massa) references zones (id_zones, nom_massa),
constraint check_num check (num_max < 50)
)

create table captures(
  num_zona int(5),
  nom_massa varchar(25),
  nom_especie varchar(20),
  num_max int(5) NOT NULL,
  long_min float(5,2) NOT NULL,
  
  constraint pk_captures primary key (num_zona, nom_massa, nom_especie),
  constraint fk_zones foreign key (num_zona, nom_massa) references zones (id_zones, nom_massa),
  constraint fk_especies foreign key (nom_especie) references especies (nom_popular)
)

create table multes(
  funcionari char(9),
  infractor char(9),
  data_multa date,
  num_zona varchar(25),
  nom_massa varchar(25),
  motiu varchar(100),
  import int(5),
  constraint pk_multes primary key (funcionari, infractor, data_multa, num_zona, nom_massa),
  constraint fk_funcionari foreign key (funcionari) references funcionaris (dni),
  constraint fk_pescadors foreign key (pescadors) references pescadors (dni),
  constraint fk_zones foreign key (num_zona, nom_massa) references zones (id_zones, nom_massa),
)

---- -----------------------------------------------
-- INSERCIONS OBLIGATORIES EN ZONA-HABITAT-ESPECIE (l'usuari SEMPRE ha d'usar transacció)
-- -----------------------------------------------

-- Exemple correcte:
--start transaction;

  --insert into especies values ('Lluç', 'Merluccius merluccius', 35.50);
  --insert into zones values (00001, 'Mediterrani', 'Tarragona', '0m', '50m', 'esportiva');
  --insert into habitats values ('Mediterrani', 00001, 'Lluç', 8);

--commit;


-- Si vols afegir una espècie nova, SEMPRE amb el seu habitat:
--start transaction;

  --insert into especies values ('Tonyina', 'Thunnus thynnus', 200.00);
  --insert into habitats values ('Mediterrani', 00001, 'Tonyina', 3);

--commit;


-- Si oblides el habitat → error i res s'insereix:
--start transaction;

  --insert into especies values ('Sardina', 'Sardina pilchardus', 18.00);
  -- si no poses el insert a habitats aquí → els triggers fallen → rollback

--commit;
