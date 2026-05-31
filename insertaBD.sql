-- insertaBD.sql
-- Joc de proves per a BDPesca
-- NOTA: Els triggers d'obligatorietat de zones i especies es creen al final
--       d'aquest fitxer, despres de les insercions inicials, per evitar que
--       saltin durant la carrega massiva de dades.

use BDPesca;

-- ============================================================
-- ZONES i ESPECIES (sense triggers d'obligatorietat actius)
-- ============================================================

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
insert into especies values ('Dory', 'Paracanthurus hepatus', 15.00);

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
insert into habitats values ('Riu Ara', 00001, 'Dory', 40);

-- ============================================================
-- PERSONES, FUNCIONARIS i PESCADORS
-- ============================================================

insert into persones values ('12345678A', 'Aina Aina');
insert into persones values ('87654321B', 'Roland Roland');
insert into persones values ('11111111C', 'Eryn Eryn');
insert into persones values ('22222222D', 'Jeon Jungkook');
insert into persones values ('33333333E', 'Kim Namjoon');
insert into persones values ('44444444F', 'Kim Seokjin');
insert into persones values ('55555555G', 'Felix Lee');
insert into persones values ('66666666I', 'Hyunjin Joan');
insert into persones values ('77777777J', 'Taylor Swift'); -- tant funcionari com pescador
insert into persones values ('98765435H', 'Chris Bang');

insert into funcionaris values ('12345678A', '123456789012', 2500.00);
insert into funcionaris values ('87654321B', '234567890123', 2800.00);
insert into funcionaris values ('11111111C', '345678901234', 2600.00);
insert into funcionaris values ('66666666I', '456789012345', 2200.00);
insert into funcionaris values ('77777777J', '567890123456', 3000.00);

insert into pescadors values ('33333333E', 'Carrer Major 1', 'Olot', 'Catalunya');
insert into pescadors values ('44444444F', 'Carrer Nou 5', 'Castelltersol', 'Catalunya');
insert into pescadors values ('55555555G', 'Avinguda Central 3', 'Tarragona', 'Arago');
insert into pescadors values ('22222222D', 'Carrer del Riu 7', 'Valls', 'Catalunya');
insert into pescadors values ('98765435H', 'Carrer Vell 2', 'Espluga de Francoli', 'Catalunya');
insert into pescadors values ('77777777J', 'Carrer Doble 1', 'Zaragoza', 'Arago');

-- ============================================================
-- ASSIGNACIONS
-- ============================================================

insert into assignacions values ('12345678A', '2025-01-10', 00001, 'Riu Ara', '2025-06-10');
insert into assignacions values ('12345678A', '2025-07-01', 00002, 'Riu Ara', '2025-12-31');
insert into assignacions values ('87654321B', '2025-03-01', 00003, 'Riu Cinca', '2025-09-01');
insert into assignacions values ('11111111C', '2025-01-15', 00004, 'Riu Cinca', '2025-07-15');
insert into assignacions values ('11111111C', '2025-08-01', 00005, 'Riu Noguera', '2025-12-01');
insert into assignacions values ('11111111C', '2026-02-01', 00002, 'Riu Ara', '2026-08-01');
insert into assignacions values ('87654321B', '2026-01-01', 00001, 'Riu Ara', '2026-06-30');

-- ============================================================
-- PERMISOS (trigger trg_permisos_tipus actiu: no es permet veda)
-- ============================================================

insert into permisos values (00001, 'Riu Ara', '2025-04-01', 20);
insert into permisos values (00001, 'Riu Ara', '2025-05-01', 25);
insert into permisos values (00001, 'Riu Ara', '2025-06-01', 30);
insert into permisos values (00002, 'Riu Ara', '2025-04-15', 15);
insert into permisos values (00002, 'Riu Ara', '2025-05-15', 20);
insert into permisos values (00002, 'Riu Ara', '2025-06-15', 18);
insert into permisos values (00004, 'Riu Cinca', '2025-04-01', 10);
insert into permisos values (00005, 'Riu Noguera', '2025-05-01', 12);

-- ============================================================
-- CAPTURES (trigger trg_captures_restriccions actiu)
-- ============================================================

insert into captures values (00001, 'Riu Ara', 'Truita', 5, 25.00);
insert into captures values (00001, 'Riu Ara', 'Barb', 3, 30.00);
insert into captures values (00002, 'Riu Ara', 'Truita', 4, 20.00);
insert into captures values (00002, 'Riu Ara', 'Anguila', 2, 15.00);
insert into captures values (00005, 'Riu Noguera', 'Truita', 3, 18.00);
insert into captures values (00005, 'Riu Noguera', 'Lluc de riu', 2, 50.00);

-- ============================================================
-- MULTES
-- ============================================================

insert into multes values ('12345678A', '33333333E', '2025-05-10', 00001, 'Riu Ara', 'Pesca sense permis', 200);
insert into multes values ('12345678A', '44444444F', '2025-06-20', 00001, 'Riu Ara', 'Excedir captures permeses', 150);
insert into multes values ('87654321B', '55555555G', '2025-04-05', 00003, 'Riu Cinca', 'Pesca en zona vedada', 300);
insert into multes values ('11111111C', '33333333E', '2025-07-01', 00005, 'Riu Noguera', 'Talla minima no respectada', 100);
insert into multes values ('11111111C', '22222222D', '2025-08-15', 00004, 'Riu Cinca', 'Pesca sense permis', 200);
insert into multes values ('87654321B', '98765435H', '2025-09-01', 00003, 'Riu Cinca', 'Pesca en zona vedada', 300);

-- ============================================================
-- TRIGGERS D'OBLIGATORIETAT (creats despres de les insercions)
-- A partir d'aqui, qualsevol nova especie o zona ha de tenir habitat
-- ============================================================

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
