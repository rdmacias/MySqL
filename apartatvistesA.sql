-- ============================================================
-- VISTES
-- ============================================================

-- 6a) Persones que son funcionaris i pescadors simultaneament
create view v_funcionaris_pescadors as
select p.dni, p.nom, pe.ciutat
from persones p
join funcionaris f on p.dni = f.dni
join pescadors pe on p.dni = pe.dni;