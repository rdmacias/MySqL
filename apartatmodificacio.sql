-- ============================================================
-- MODIFICACIO
-- ============================================================

-- 4) Augment del 5% del sou dels funcionaris amb mes de 2 assignacions (vigents o no)
update funcionaris
set sou = sou * 1.05
where dni in (
  select funcionari from assignacions
  group by funcionari
  having count(*) > 2
);
