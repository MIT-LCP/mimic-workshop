select ie.icustay_id
  , di.label
  , round( (julianday(de.charttime) - julianday(ie.intime))*24, 4) as Hours
  , de.itemid
  , de.value
  , de.valuenum
from icustays ie
inner join labevents de 
    on de.hadm_id = ie.hadm_id
inner join d_labitems di
    on de.itemid = di.itemid
where de.hadm_id = 103075
order by charttime