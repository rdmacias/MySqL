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
  data_fi date not null,
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
  import int(5), -- no sé si posar un not null i un check de q sigui sempre major a 0€ sabes ROLAND MIRA ESTO
  constraint pk_multes primary key (funcionari, infractor, data_multa, num_zona, nom_massa),
  constraint fk_multes_funcionaris foreign key (funcionari) references funcionaris (dni),
  constraint fk_multes_pescadors foreign key (infractor) references pescadors (dni),
  constraint fk_multes_zones foreign key (num_zona, nom_massa) references zones (num_zona, nom_massa)
) engine=innodb;

-- ============================================================
-- INSERCIONS
-- Les insercions de zones i especies s'han de fer dins d'una
-- transaccio juntament amb el seu habitat corresponent.
-- ============================================================
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
-- ============================================================

-- Masses d'aigua (zona+habitat en transaccio)
start transaction;
  insert into zones values (00001, 'Riu Ara', 'Broto', '0m', '200m', 'esportiva');
  insert into zones values (00002, 'Riu Ara', 'Boltana', '0m', '150m', 'normal');
  insert into zones values (00003, 'Riu Cinca', 'Ainsa', '0m', '180m', 'veda');
  insert into zones values (00004, 'Riu Cinca', 'Monzon', '0m', '100m', 'sense_mort');
  insert into zones values (00005, 'Riu Noguera', 'Tremp', '0m', '120m', 'normal');

  insert into especies values ('Truita', 'Salmo trutta', 35.00);
  insert into especies values ('Barb', 'Barbus barbus', 40.00);
  insert into especies values ('Anguila', 'Anguilla anguilla', 80.00);
  insert into especies values ('Carpa', 'Cyprinus carpio', 55.00);
  insert into especies values ('Lluc de riu', 'Esox lucius', 70.00);

  insert into habitats values ('Riu Ara', 00001, 'Truita', 80);
  insert into habitats values ('Riu Ara', 00001, 'Barb', 50);
  insert into habitats values ('Riu Ara', 00002, 'Truita', 60);
  insert into habitats values ('Riu Ara', 00002, 'Anguila', 30);
  insert into habitats values ('Riu Cinca', 00003, 'Truita', 40);
  insert into habitats values ('Riu Cinca', 00003, 'Carpa', 70);
  insert into habitats values ('Riu Cinca', 00004, 'Barb', 60);
  insert into habitats values ('Riu Cinca', 00004, 'Anguila', 20);
  insert into habitats values ('Riu Noguera', 00005, 'Truita', 50);
  insert into habitats values ('Riu Noguera', 00005, 'Lluc de riu', 30);
commit;

insert into persones values ('12345678A', 'Aina Aina'); -- dni, nom
insert into persones values ('87654321B', 'Roland Roland');
insert into persones values ('11111111C', 'Eryn Eryn');
insert into persones values ('22222222D', 'Jeon Jungkook');
insert into persones values ('33333333E', 'Kim Namjoon');
insert into persones values ('44444444F', 'Kim Seokjin');
insert into persones values ('55555555G', 'Felix Lee');
insert into persones values ('98765435H', 'Chris Bang');

insert into funcionaris values ('12345678A', '123456789012', 2500.00); -- dni, nss, sou
insert into funcionaris values ('87654321B', '234567890123', 2800.00);
insert into funcionaris values ('11111111C', '345678901234', 2600.00);

insert into pescadors values ('33333333E', 'Carrer Major 1', 'Olot', 'Catalunya'); -- dni, carrer, ciutat, comunitat
insert into pescadors values ('44444444F', 'Carrer Nou 5', 'CastellTerçol', 'Catalunya');
insert into pescadors values ('55555555G', 'Avinguda Central 3', 'Tarragona', 'Aragó');
insert into pescadors values ('22222222D', 'Carrer del Riu 7', 'Valls', 'Catalunya');
insert into pescadors values ('98765435H', 'Carrer Vell 2', 'Espluga de Francolí', 'Catalunya');

-- aquí no sé q fer, si fer que no es puguin posar dates anteriors a la actual o q es puguin guardar dades de abans de q es fes la base de dades, sabes ROLAND MIRA ESTO
insert into assignacions values ('12345678A', '2025-01-10', 00001, 'Riu Ara', '2025-06-10'); -- dni_funcionari, data_inici, num_zona, nom_massa, data_fi
insert into assignacions values ('12345678A', '2025-07-01', 00002, 'Riu Ara', '2025-12-31');
insert into assignacions values ('87654321B', '2025-03-01', 00003, 'Riu Cinca', '2025-09-01');
insert into assignacions values ('11111111C', '2025-01-15', 00004, 'Riu Cinca', '2025-07-15');
insert into assignacions values ('11111111C', '2025-08-01', 00005, 'Riu Noguera', '2025-12-01');
insert into assignacions values ('87654321B', '2026-01-01', 00001, 'Riu Ara', '2026-06-30');

insert into permisos values (00001, 'Riu Ara', '2025-04-01', 20); -- num_zona, nom_massa, data_vigencia, num_max
insert into permisos values (00001, 'Riu Ara', '2025-05-01', 25);
insert into permisos values (00001, 'Riu Ara', '2025-06-01', 30);
insert into permisos values (00002, 'Riu Ara', '2025-04-15', 15);
insert into permisos values (00002, 'Riu Ara', '2025-05-15', 20);
insert into permisos values (00002, 'Riu Ara', '2025-06-15', 18);
insert into permisos values (00004, 'Riu Cinca', '2025-04-01', 10);
-- insert into permisos values (00005, 'Riu Noguera', '2025-05-01', 51); -- t'hauria de donar error esta, ns si posar-la abans o dp
insert into permisos values (00005, 'Riu Noguera', '2025-05-01', 12);

insert into captures values (00001, 'Riu Ara', 'Truita', 5, 25.00); --num_zona, nom_massa, nom_especie, num_max, long_min
insert into captures values (00001, 'Riu Ara', 'Barb', 3, 30.00);
insert into captures values (00002, 'Riu Ara', 'Truita', 4, 20.00);
insert into captures values (00002, 'Riu Ara', 'Anguila', 2, 15.00);
insert into captures values (00005, 'Riu Noguera', 'Truita', 3, 18.00);
insert into captures values (00005, 'Riu Noguera', 'Lluc de riu', 2, 50.00);

insert into multes values ('12345678A', '33333333E', '2025-05-10', 00001, 'Riu Ara', 'Pesca sense permis', 200); -- dni funcionari, dni infractor, data_multa, num_zona, nom_massa, motiu, import
insert into multes values ('12345678A', '44444444F', '2025-06-20', 00001, 'Riu Ara', 'Excedir captures permeses', 150);
insert into multes values ('87654321B', '55555555G', '2025-04-05', 00003, 'Riu Cinca', 'Pesca en zona vedada', 300);
insert into multes values ('11111111C', '33333333E', '2025-07-01', 00005, 'Riu Noguera', 'Talla minima no respectada', 100);
insert into multes values ('11111111C', '22222222D', '2025-08-15', 00004, 'Riu Cinca', 'Pesca sense permis', 200);
insert into multes values ('87654321B', '98765435H', '2025-09-01', 00003, 'Riu Cinca', 'Pesca en zona vedada', 300);

-- ============================================================
-- CONSULTES
-- ============================================================

-- 3a) Funcionaris que no son pescadors i no han posat multes a pescadors de Catalunya
select f.dni, p.nom, f.nss, f.sou -- demana esto dels funcionaris
from funcionaris f
join persones p on f.dni = p.dni -- pq necessito el nom
where f.dni not in (select dni from pescadors)
  and f.dni not in ( -- Que el funcionari no estigui en la taula de multes
    select m.funcionari
    from multes m
    join pescadors pesc on m.infractor = pesc.dni  --mirar que el pescador sigui de Catalunya
    where pesc.comunitat = 'Catalunya'
  );

-- 3b) Especies que habiten simultaneament a totes les masses d'aigua de la comunitat
select e.nom_cientific, e.long_mitja
from especies e
where not exists ( --"NO existeix cap massa d'aigua on NO visqui" és l'equivalent a dir "hi és a totes"
  select distinct nom_massa from zones
  where nom_massa not in ( --llocs on no viu
    select h.massa_aigua --llocs on viu
    from habitats h 
    where h.nom_especie = e.nom_popular
  )
);

-- 3c) Zones amb permisos en almenys 3 dates i que permeten alguna captura < 20cm
select z.num_zona, z.nom_massa, z.municipi, z.tipus
from zones z
where (
  select count(distinct p.data_vigencia)
  from permisos p
  where p.num_zona = z.num_zona and p.nom_massa = z.nom_massa
) >= 3
and exists (
  select 1 from captures c  --SELECT 1 = "busca files però no em passis cap dada, només diguem si n'has trobat alguna" 
  where c.num_zona = z.num_zona and c.nom_massa = z.nom_massa and c.long_min < 20
);

-- 3d) Zones sense veda que concedeixen el nombre maxim de permisos
select p.num_zona, p.nom_massa, p.data_vigencia
from permisos p
join zones z on p.num_zona = z.num_zona and p.nom_massa = z.nom_massa
where z.tipus != 'veda'
  and p.num_max = (
    select max(p2.num_max)
    from permisos p2
    join zones z2 on p2.num_zona = z2.num_zona and p2.nom_massa = z2.nom_massa
    where z2.tipus != 'veda'
  );

-- 3e) Totes les dades de les especies que habiten NOMES al riu Ara
select e.*
from especies e
where e.nom_popular in ( -- especies que estan al Riu Ara
  select nom_especie from habitats where massa_aigua = 'Riu Ara'
)
and e.nom_popular not in ( -- i que no estan a cap altre massa_d'aigua
  select nom_especie from habitats where massa_aigua != 'Riu Ara'
);

-- 3f) Multes en zones sense assignacio activa avui
select p.nom as nom_funcionari, pi.nom as nom_infractor, m.motiu, m.data_multa
from multes m
join persones p on m.funcionari = p.dni -- en multa només tenim el dni del funcionari i infractor, necessitem fer un join pel nom
join persones pi on m.infractor = pi.dni
where not exists (
  select 1 from assignacions a -- mirar si hi ha assignacions en aquesta zona en aquesta data
  where a.num_zona = m.num_zona
    and a.nom_massa = m.nom_massa
    and a.data_inici <= curdate()
    and a.data_fi >= curdate()
);

-- ============================================================
-- MODIFICACIO
-- ============================================================

-- 4) Augment del 5% del sou dels funcionaris amb mes de 2 assignacions (vigents o no)
update funcionaris
set sou = sou * 1.05
where dni in (
  select funcionari from assignacions
  group by funcionari
  having count(*) > 2
);

-- ============================================================
-- ESBORRAT
-- ============================================================

-- 5) Esborrar multes de pescadors amb <= multes que el pescador 98765435H
delete from multes
where infractor in (
  select dni from pescadors
  where (
    select count(*) from multes m2 where m2.infractor = pescadors.dni
  ) <= (
    select count(*) from multes m3 where m3.infractor = '98765435H'
  )
);

-- ============================================================
-- VISTES
-- ============================================================

-- 6a) Persones que son funcionaris i pescadors simultaneament
create view v_funcionaris_pescadors as
select p.dni, p.nom, pe.ciutat
from persones p
join funcionaris f on p.dni = f.dni
join pescadors pe on p.dni = pe.dni;

-- 6b) Especies amb longitud mitjana > 20cm
create view v_especies_grans as
select nom_popular, nom_cientific, long_mitja
from especies
where long_mitja > 20;

