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