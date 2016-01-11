
-- Staging table #1: CHARTEVENTS
with ce_stg as
(
  select ie.icustay_id
  , case
      when itemid in (211,220045) then 1 -- HeartRate
      when itemid in (456,52,6702,443,220052,220181,225312) then 4 -- MeanBP
      when itemid in (615,618,220210,224690) then 5 -- RespRate
      else null end as VitalID
  , valuenum
  from icustays ie
  left join chartevents chart
    on ie.subject_id = chart.subject_id and ie.hadm_id = chart.hadm_id and ie.icustay_id = chart.icustay_id
    and chart.charttime >= ie.intime and chart.charttime <= date(ie.intime,'+1 day')
    and chart.itemid in
    (
    -- HEART RATE
    211, --"Heart Rate"
    220045, --"Heart Rate"

    -- MEAN BLOOD PRESSURE
    456, --"NBP Mean"
    52, --"Arterial BP Mean"
    6702, --	Arterial BP Mean #2
    443, --	Manual BP Mean(calc)
    220052, --"Arterial Blood Pressure mean"
    220181, --"Non Invasive Blood Pressure mean"
    225312, --"ART BP mean"

    -- RESPIRATORY RATE
    618,--	Respiratory Rate
    615,--	Resp Rate (Total)
    220210,--	Respiratory Rate
    224690 --	Respiratory Rate (Total)
    )
)
-- Aggregate table #1: CHARTEVENTS
, ce as
(
  SELECT ce_stg.icustay_id
  , min(case when VitalID = 1 then valuenum else null end) as HeartRate_Min
  , max(case when VitalID = 1 then valuenum else null end) as HeartRate_Max
  , min(case when VitalID = 4 then valuenum else null end) as MeanBP_Min
  , max(case when VitalID = 4 then valuenum else null end) as MeanBP_Max
  , min(case when VitalID = 5 then valuenum else null end) as RespRate_Min
  , max(case when VitalID = 5 then valuenum else null end) as RespRate_Max
  FROM ce_stg
  group by ce_stg.icustay_id
)

-- Staging table #2: GCS
-- Because we need to add together GCS components, we do it seperately from chartevents
, gcs_stg as
(
  select ie.icustay_id, chart.charttime
  , max(case when itemid in (723,223900) then valuenum else null end) as GCSVerbal
  , max(case when itemid in (454,223901) then valuenum else null end) as GCSMotor
  , max(case when itemid in (184,220739) then valuenum else null end) as GCSEyes
  from icustays ie
  left join chartevents chart
    on ie.subject_id = chart.subject_id and ie.hadm_id = chart.hadm_id and ie.icustay_id = chart.icustay_id
    and chart.charttime >= ie.intime and chart.charttime <= date(ie.intime,'+1 day')
    and chart.itemid in
    (
      723, -- GCSVerbal
      454, -- GCSMotor
      184, -- GCSEyes
      223900, -- GCS - Verbal Response
      223901, -- GCS - Motor Response
      220739 -- GCS - Eye Opening
    )
  group by ie.icustay_id, chart.charttime
)
-- Aggregate table #2: GCS
, gcs as
(
  SELECT gcs_stg.icustay_id
  , min(GCSVerbal + GCSMotor + GCSEyes) as GCS_Min
  , max(GCSVerbal + GCSMotor + GCSEyes) as GCS_Max
  FROM gcs_stg
  group by gcs_stg.icustay_id
)
-- Staging table #3: LABEVENTS
, le_stg as
(
  select ie.icustay_id
    -- here we assign labels to ITEMIDs
    -- this also fuses together multiple ITEMIDs containing the same data
    , case
          when itemid = 50885 then 'BILIRUBIN'
          when itemid = 50912 then 'CREATININE'
          when itemid = 50809 then 'GLUCOSE'
          when itemid = 50931 then 'GLUCOSE'
          when itemid = 50811 then 'HEMOGLOBIN'
          when itemid = 51222 then 'HEMOGLOBIN'
          when itemid = 50824 then 'SODIUM'
          when itemid = 50983 then 'SODIUM'
          when itemid = 51300 then 'WBC'
          when itemid = 51301 then 'WBC'
        else null
      end as label
    , valuenum

    from icustays ie

    left join labevents lab
      on ie.subject_id = lab.subject_id and ie.hadm_id = lab.hadm_id
      and lab.charttime >= date(ie.intime,'-6 hour') and lab.charttime <= date(ie.intime,'+1 day')
      and lab.ITEMID in
      (
        -- comment is: LABEL | CATEGORY | FLUID | NUMBER OF ROWS IN LABEVENTS
        50885, -- BILIRUBIN, TOTAL | CHEMISTRY | BLOOD | 238277
        50912, -- CREATININE | CHEMISTRY | BLOOD | 797476
        50931, -- GLUCOSE | CHEMISTRY | BLOOD | 748981
        50809, -- GLUCOSE | BLOOD GAS | BLOOD | 196734
        51222, -- HEMOGLOBIN | HEMATOLOGY | BLOOD | 752523
        50811, -- HEMOGLOBIN | BLOOD GAS | BLOOD | 89712
        50983, -- SODIUM | CHEMISTRY | BLOOD | 808489
        50824, -- SODIUM, WHOLE BLOOD | BLOOD GAS | BLOOD | 71503
        51301, -- WHITE BLOOD CELLS | HEMATOLOGY | BLOOD | 753301
        51300  -- WBC COUNT | HEMATOLOGY | BLOOD | 2371
      )
      and lab.valuenum is not null and lab.valuenum > 0 -- lab values cannot be 0 and cannot be negative
)

-- Aggregate table #3: LABEVENTS
, le as
(
  select
    le_stg.icustay_id

    , min(case when label = 'BILIRUBIN' then valuenum else null end) as BILIRUBIN_min
    , max(case when label = 'BILIRUBIN' then valuenum else null end) as BILIRUBIN_max
    , min(case when label = 'CREATININE' then valuenum else null end) as CREATININE_min
    , max(case when label = 'CREATININE' then valuenum else null end) as CREATININE_max
    , min(case when label = 'HEMOGLOBIN' then valuenum else null end) as HEMOGLOBIN_min
    , max(case when label = 'HEMOGLOBIN' then valuenum else null end) as HEMOGLOBIN_max
    , min(case when label = 'SODIUM' then valuenum else null end) as SODIUM_min
    , max(case when label = 'SODIUM' then valuenum else null end) as SODIUM_max
    , min(case when label = 'WBC' then valuenum else null end) as WBC_min
    , max(case when label = 'WBC' then valuenum else null end) as WBC_max

  from le_stg
  group by le_stg.icustay_id
)

SELECT ie.icustay_id
, adm.HOSPITAL_EXPIRE_FLAG -- whether the patient died within the hospital
, round( (julianday(ie.intime) - julianday(pat.dob))/365.24, 4) as Age

, HeartRate_Min
, HeartRate_Max
, MeanBP_Min
, MeanBP_Max
, RespRate_Min
, RespRate_Max

, GCS_Min
, GCS_Max

, BILIRUBIN_min
, BILIRUBIN_max
, CREATININE_min
, CREATININE_max
, HEMOGLOBIN_min
, HEMOGLOBIN_max
, SODIUM_min
, SODIUM_max
, WBC_min
, WBC_max

FROM icustays ie
inner join admissions adm
  on ie.hadm_id = adm.hadm_id
inner join patients pat
  on ie.subject_id = pat.subject_id
left join ce
  on ie.icustay_id = ce.icustay_id
left join gcs
  on ie.icustay_id = gcs.icustay_id
left join le
  on ie.icustay_id = le.icustay_id
