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