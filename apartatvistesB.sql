-- 6b) Especies amb longitud mitjana > 20cm
create view v_especies_grans as
select nom_popular, nom_cientific, long_mitja
from especies
where long_mitja > 20;
