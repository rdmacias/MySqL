-- 3e) Totes les dades de les especies que habiten NOMES al riu Ara
select e.*
from especies e
where e.nom_popular in ( -- especies que estan al Riu Ara
  select nom_especie from habitats where massa_aigua = 'Riu Ara'
)
and e.nom_popular not in ( -- i que no estan a cap altre massa_d'aigua
  select nom_especie from habitats where massa_aigua != 'Riu Ara'
);