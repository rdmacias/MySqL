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

-- BDPesca - Practica 3
-- Simplificacio: no es creen taules per Dates ni Masses_Aigua

drop database if exists BDPesca;
create database BDPesca;
use BDPesca;

-- ============================================================
-- ENTITATS
-- ============================================================

create table zones (
  num_zona int(5) zerofill not null,
  nom_massa varchar(25) not null,
  municipi varchar(25),
  limit_superior varchar(25),
  limit_inferior varchar(25),
  tipus varchar(15) not null,
  constraint pk_zones primary key (num_zona, nom_massa),
  constraint check_tipus check (tipus in ('esportiva', 'sense_mort', 'veda', 'normal'))
) engine=innodb;

create table especies (
  nom_popular varchar(20) not null,
  nom_cientific varchar(30),
  long_mitja float(5,2) not null,
  constraint pk_especies primary key (nom_popular),
  constraint ak_nom_cientific unique (nom_cientific), -- ak == alternative key
  constraint check_long_mitja check (long_mitja > 0)
) engine=innodb;

create table persones (
  dni char(9),
  nom varchar(25) not null,
  constraint pk_persones primary key (dni)
) engine=innodb;

create table pescadors (
  dni char(9),
  carrer varchar(25) not null,
  ciutat varchar(25) not null,
  comunitat varchar(25) not null,
  constraint pk_pescadors primary key (dni),
  constraint fk_pescadors_persones foreign key (dni) references persones (dni)
) engine=innodb;

create table funcionaris (
  dni char(9),
  nss char(12) not null,
  sou float(10,2) not null,
  constraint pk_funcionaris primary key (dni),
  constraint fk_funcionaris_persones foreign key (dni) references persones (dni),
  constraint ak_funcionaris_nss unique (nss)
) engine=innodb;

-- ============================================================
-- INTERRELACIONS
-- ============================================================

create table habitats (
  massa_aigua varchar(25) not null,
  num_zona int(5) zerofill not null,
  nom_especie varchar(20) not null,
  index_poblacio int(5),
  constraint pk_habitats primary key (massa_aigua, num_zona, nom_especie),
  constraint fk_habitats_zones foreign key (num_zona, massa_aigua) references zones (num_zona, nom_massa),
  constraint fk_habitats_especies foreign key (nom_especie) references especies (nom_popular)
) engine=innodb;

-- Obligatorietat: tota especie ha de tenir almenys un habitat
delimiter $$
create trigger trg_especie_te_habitat
after insert on especies
for each row
begin
  if (select count(*) from habitats where nom_especie = NEW.nom_popular) = 0 then
    signal sqlstate '45000'
    set message_text = 'Aquesta especie no te cap habitat assignat';
  end if;
end$$
delimiter ;

-- Obligatorietat: tota zona ha de tenir almenys un habitat
delimiter $$
create trigger trg_zona_te_habitat
after insert on zones
for each row
begin
  if (select count(*) from habitats
      where num_zona = NEW.num_zona and massa_aigua = NEW.nom_massa) = 0 then
    signal sqlstate '45000'
    set message_text = 'Aquesta zona no te cap habitat assignat';
  end if;
end$$
delimiter ;

create table assignacions (
  funcionari char(9),
  data_inici date,
  num_zona int(5) zerofill,
  nom_massa varchar(25),
  data_fi date,
  constraint pk_assignacions primary key (funcionari, data_inici, num_zona, nom_massa),
  constraint fk_assignacions_zones foreign key (num_zona, nom_massa) references zones (num_zona, nom_massa),
  constraint fk_assignacions_funcionaris foreign key (funcionari) references funcionaris (dni)
) engine=innodb;

create table permisos (
  num_zona int(5) zerofill,
  nom_massa varchar(25),
  data_vigencia date,
  num_max int(3) not null,
  constraint pk_permisos primary key (num_zona, nom_massa, data_vigencia),
  constraint fk_permisos_zones foreign key (num_zona, nom_massa) references zones (num_zona, nom_massa),
  constraint check_num_max check (num_max < 50)
) engine=innodb;

-- Permisos nomes en zones: sense_mort, normal, esportiva (zona de veda no pot tenir permisos)
delimiter $$
create trigger trg_permisos_tipus
before insert on permisos
for each row
begin
  declare v_tipus varchar(15);
  select tipus into v_tipus from zones
  where num_zona = NEW.num_zona and nom_massa = NEW.nom_massa;
  if v_tipus = 'veda' then
    signal sqlstate '45000'
    set message_text = 'No es poden concedir permisos en zones de veda';
  end if;
end$$
delimiter ;

create table captures (
  num_zona int(5) zerofill,
  nom_massa varchar(25),
  nom_especie varchar(20),
  num_max int(5) not null,
  long_min float(5,2) not null,
  constraint pk_captures primary key (num_zona, nom_massa, nom_especie),
  constraint fk_captures_zones foreign key (num_zona, nom_massa) references zones (num_zona, nom_massa),
  constraint fk_captures_especies foreign key (nom_especie) references especies (nom_popular)
) engine=innodb;

-- Captures nomes en zones normal/esportiva; long_min no pot superar long_mitja de l'especie
delimiter $$
create trigger trg_captures_restriccions
before insert on captures
for each row
begin
  declare v_tipus varchar(15);
  declare v_long_mitja float(5,2);
  select tipus into v_tipus from zones              -- agafem el tipus de zona que és, i mirem que sigui normal o esportiva
  where num_zona = NEW.num_zona and nom_massa = NEW.nom_massa;
  if v_tipus not in ('normal', 'esportiva') then
    signal sqlstate '45000'
    set message_text = 'Les captures nomes son permeses en zones normal o esportiva';
  end if;
  -- Garantir que no existeixen captures permeses amb longitud mínima per sobre de la longitud mitja de l’espècie en estat adult
  select long_mitja into v_long_mitja from especies -- anem a especie i agafem la seva longitud mitja
  where nom_popular = NEW.nom_especie;
  if NEW.long_min > v_long_mitja then 
    signal sqlstate '45000'
    set message_text = 'La longitud minima no pot superar la longitud mitja de l especie adulta';
  end if;
end$$
delimiter ;

create table multes (
  funcionari char(9),
  infractor char(9),
  data_multa date,
  num_zona int(5) zerofill,
  nom_massa varchar(25),
  motiu varchar(100),
  import float(5,2) not null check (import > 0),
  constraint pk_multes primary key (funcionari, infractor, data_multa, num_zona, nom_massa),
  constraint fk_multes_funcionaris foreign key (funcionari) references funcionaris (dni),
  constraint fk_multes_pescadors foreign key (infractor) references pescadors (dni),
  constraint fk_multes_zones foreign key (num_zona, nom_massa) references zones (num_zona, nom_massa)
) engine=innodb;



