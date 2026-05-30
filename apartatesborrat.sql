

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
