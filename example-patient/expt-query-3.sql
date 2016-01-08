select de.icustay_id
  , di.label
  , round( (julianday(de.charttime) - julianday(ie.intime))*24, 4) as HOURS
  , de.itemid
  , de.value
  , de.value as valuenum
from icustays ie
inner join outputevents de
    on de.icustay_id = ie.icustay_id
inner join d_items di
    on de.itemid = di.itemid
where de.hadm_id = 103075
order by charttime