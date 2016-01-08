-- This script exports data for a single patient from a PostgreSQL instance of MIMIC-III to CSV.
-- You may need to change the paths to match your local system.
-- You may also need to set the PostgreSQL search path to the schema with MIMIC-III.

-- This version extracts data for

  -- This script exports data for a single patient from a PostgreSQL instance of MIMIC-III to CSV.
  -- You may need to change the paths to match your local system.
  -- You may also need to set the PostgreSQL search path to the schema with MIMIC-III.

  -- CHARTED DATA
  Copy (
    select ie.icustay_id
        , di.label
        , round(extract(EPOCH from (de.charttime-ie.intime)) :: NUMERIC / 360,4) as HOURS
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
  ) To '/data/mimic3/example-patient-chartevents.csv' With CSV HEADER;


  -- LAB DATA
  Copy (
    select ie.icustay_id
      , di.label
      , round(extract(EPOCH from (de.charttime-ie.intime)) :: NUMERIC / 360,4) as HOURS
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
  ) To '/data/mimic3/example-patient-labevents.csv' With CSV HEADER;


  -- OUTPUT DATA
  Copy (
    select de.icustay_id
      , di.label
      , round(extract(EPOCH from (de.charttime-ie.intime)) :: NUMERIC / 360,4) as HOURS
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
  ) To '/data/mimic3/example-patient-outputevents.csv' With CSV HEADER;


  -- INPUT DATA
  Copy (
    select de.icustay_id
      , di.label
      , round(extract(EPOCH from (de.charttime-ie.intime)) :: NUMERIC / 360,4) as HOURS
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
  ) To '/data/mimic3/example-patient-inputevents.csv' With CSV HEADER;
