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