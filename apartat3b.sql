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