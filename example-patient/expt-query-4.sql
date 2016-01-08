select de.icustay_id
  , di.label
  , round( (julianday(de.charttime) - julianday(ie.intime))*24, 4) as HOURS
  , de.itemid
  , de.amount
  , de.amountuom
  , de.rate
  , de.rateuom
from icustays ie
inner join inputevents_cv de
    on de.icustay_id = ie.icustay_id
inner join d_items di
    on de.itemid = di.itemid
where de.hadm_id = 103075
order by charttime