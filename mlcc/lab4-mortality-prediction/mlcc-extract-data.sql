with ce as
(
  select
    icustay_id, charttime, itemid, valuenum
  from chartevents
  -- specify what data we want from chartevents
  where itemid in
  (
  211, -- Heart Rate
  618, --	Respiratory Rate
  615 --	Resp Rate (Total)
  )
  -- how did we know heart rates were stored using ITEMID 211? Simple, we looked in D_ITEMS!
  -- Try it for yourself: select * from d_items where lower(label) like '%heart rate%'
)
select
  -- ICUSTAY_ID identifies each unique patient ICU stay
  -- note that if the same person stays in the ICU more than once, each stay would have a *different* ICUSTAY_ID
  -- however, since it's the same person, all those stays would have the same SUBJECT_ID
  ie.icustay_id

  -- this is the outcome of interest: in-hospital mortality
  , max(adm.HOSPITAL_EXPIRE_FLAG) as OUTCOME

  -- this is a case statement - essentially an "if, else" clause
  , min(
      case
        -- if the itemid is 211
        when itemid = 211
          -- then return the actual value stored in VALUENUM
          then valuenum
        -- otherwise, return 'null', which is SQL standard for an empty value
        else null
      -- end the case statement
      end
    ) as HeartRate_Min
    
    -- note we wrapped the above in "min()"
    -- this takes the minimum of all values inside, and *ignores* nulls
    -- by calling this on our case statement, we are ignoring all values except those with ITEMID = 211
    -- since ITEMID 211 are heart rates, we take the minimum of only heart rates

  , max(case when itemid = 211 then valuenum else null end) as HeartRate_Max
  , min(case when itemid in (615,618) then valuenum else null end) as RespRate_Min
  , max(case when itemid in (615,618) then valuenum else null end) as RespRate_Max
from icustays ie

-- join to the admissions table to get hospital outcome
inner join admissions adm
  on ie.hadm_id = adm.hadm_id

-- join to the chartevents table to get the observations
left join ce
  -- match the tables on the patient identifier
  on ie.icustay_id = ce.icustay_id
  -- and require that the observation be made after the patient is admitted to the ICU
  and ce.charttime >= ie.intime
  -- and *before* their admission time + 1 day, i.e. the observation must be made on their first day in the ICU
  and ce.charttime <= ie.intime + interval '1' day
group by ie.icustay_id
order by ie.icustay_id;
