select ie.icustay_id
    , di.label
    , round( (julianday(de.charttime) - julianday(ie.intime))*24, 4) as Hours
    , de.itemid
    , de.value
    , de.valuenum
from icustays ie
inner join chartevents de
  on ie.icustay_id = de.icustay_id 
inner join d_items di
on de.itemid = di.itemid
where ie.hadm_id = 103075
order by charttime