select
  -- ICUSTAY_ID identifies each unique patient ICU stay
  -- note that if the same person stays in the ICU more than once, each stay would have a *different* ICUSTAY_ID
  ie.icustay_id

  -- this is the outcome of interest: in-hospital mortality
  , max(adm.HOSPITAL_EXPIRE_FLAG) as OUTCOME

  -- let's read this statement inside out. first, the case statement says:
  --  if the ITEMID = 211, then output the numeric value
  --  otherwise, set it to NULL
  -- that means that there are *only* heart rate values within the brackets
  -- next, we take the minimum - min() - which ignores NULLs
  -- as a result, we get the minimum heart rate value, which we define "as HeartRate_Min"

  -- how did we know heart rates were stored using ITEMID 211? Simple, we looked in D_ITEMS!
  -- Try it for yourself: select * from d_items where lower(label) like '%heart rate%'

  , min(case when itemid = 211 then valuenum else null end) as HeartRate_Min
  , max(case when itemid = 211 then valuenum else null end) as HeartRate_Max
  , min(case when itemid in (615,618) then valuenum else null end) as RespRate_Min
  , max(case when itemid in (615,618) then valuenum else null end) as RespRate_Max
from icustays ie
-- join to the admissions table to get hospital outcome
inner join admissions adm
  on ie.hadm_id = adm.hadm_id

-- join to the chartevents table to get the observations
left join chartevents ce
  -- match the tables on the patient identifier
  on ie.icustay_id = ce.icustay_id
  -- and require that the observation be made after the patient is admitted to the ICU
  and ce.charttime >= ie.intime
  -- and *before* their admission time + 1 day, i.e. the observation must be made on their first day in the ICU
  and ce.charttime <= date(ie.intime,'+1 day')

  -- finally, only look at heart rate/respiratory rate observations
  and ce.itemid in
  (
  211, -- Heart Rate
  618, --	Respiratory Rate
  615 --	Resp Rate (Total)
  )

-- Note above that we take the max() and min() of some columns
-- Imagine you have a table with 2 columns and 10 rows
-- If we take the max() of the 2nd column, we now have:
--  10 rows in the first column
--  1 row in the second column (the max value)
-- How does the second column correspond to the first?
-- Should we copy that 1 row to all 10 rows?
-- We need to tell SQL how to *group* the max value

-- The below line states "group everything by icustay_id"
-- That means that we take the max( HEART RATE ) grouped by ICUSTAY_ID
-- or, normal words, we take the maximum heart rate for each patient's ICU stay
group by ie.icustay_id
order by ie.icustay_id;
