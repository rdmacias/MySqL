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