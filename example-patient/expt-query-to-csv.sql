-- This script exports data for a single patient from a PostgreSQL instance of MIMIC-III to CSV.
-- You may need to change the paths to match your local system.
-- You may also need to set the PostgreSQL search path to the schema with MIMIC-III.

-- This version extracts data for

-- CHARTED DATA
Copy (
  select ie.icustay_id
    , round(extract(EPOCH from (de.charttime-ie.intime)) :: NUMERIC / 360,4) as HOURS
      , de.itemid
      , de.value
      , de.valuenum
      , de.valueuom
      , di.label
  from icustays ie
  inner join chartevents de
    on ie.icustay_id = de.icustay_id
  inner join d_items di
    on de.itemid = di.itemid
  where ie.hadm_id = 185409
  order by charttime
) To '/data/mimic3/example-patient-chartevents.csv' With CSV HEADER;


-- LAB DATA
Copy (
select ie.icustay_id
  , round(extract(EPOCH from (de.charttime-ie.intime)) :: NUMERIC / 360,4) as HOURS
  , de.itemid
  , de.value
  , de.valuenum
  , de.valueuom
  , di.label

  from mimiciii.labevents de
  inner join mimiciii.d_labitems di
  on de.itemid = di.itemid
  inner join mimiciii.icustays ie
  on de.hadm_id = ie.hadm_id and de.charttime between ie.intime and ie.outtime
where de.hadm_id = 185409
order by charttime
) To '/data/mimic3/example-patient-labevents.csv' With CSV HEADER;

-- INPUT DATA
Copy (
select de.icustay_id
  , round(extract(EPOCH from (de.starttime-ie.intime)) :: NUMERIC / 360,4) as HOURS_START
  , round(extract(EPOCH from (de.endtime-ie.intime)) :: NUMERIC / 360,4) as HOURS_END
  , de.itemid
  , de.amount
  , de.amountuom
  , de.rate
  , de.rateuom
  , de.linkorderid
  , di.label
  from mimiciii.inputevents_mv de

  inner join mimiciii.d_items di
  on de.itemid = di.itemid

  inner join mimiciii.icustays ie
  on de.icustay_id = ie.icustay_id

where de.hadm_id = 185409
order by starttime, endtime
) To '/data/mimic3/example-patient-inputevents.csv' With CSV HEADER;


-- OUTPUT DATA
Copy (
select de.icustay_id
  , round(extract(EPOCH from (de.charttime-ie.intime)) :: NUMERIC / 360,4) as HOURS
  , de.itemid

  , de.value
  , de.valueuom
  , di.label
  from mimiciii.outputevents de

  inner join mimiciii.d_items di
  on de.itemid = di.itemid

  inner join mimiciii.icustays ie
  on de.icustay_id = ie.icustay_id

where de.hadm_id = 185409
order by charttime
) To '/data/mimic3/example-patient-outputevents.csv' With CSV HEADER;


-- PROCEDURE DATA
Copy (
select de.icustay_id
  , round(extract(EPOCH from (de.starttime-ie.intime)) :: NUMERIC / 360,4) as HOURS_START
  , round(extract(EPOCH from (de.endtime-ie.intime)) :: NUMERIC / 360,4) as HOURS_END
  , de.itemid
  , de.value
  , de.valueuom
  , de.linkorderid
  , di.label
  from mimiciii.procedureevents_mv de

  inner join mimiciii.d_items di
  on de.itemid = di.itemid

  inner join mimiciii.icustays ie
  on de.icustay_id = ie.icustay_id

where de.hadm_id = 185409
order by starttime
) To '/data/mimic3/example-patient-procedureevents.csv' With CSV HEADER;


--
-- -- NOTE DATA - wasn't exported, just copy pasted the discharge summary
-- select
--   round(extract(EPOCH from (de.charttime-ie.intime)) :: NUMERIC / 360,4) as Hours
--   , de.* from mimiciii.noteevents de
--
--   inner join mimiciii.icustays ie
--   on de.hadm_id = ie.hadm_id and de.charttime between ie.intime and ie.outtime
--
-- where de.hadm_id = 185409
-- order by charttime, chartdate;
