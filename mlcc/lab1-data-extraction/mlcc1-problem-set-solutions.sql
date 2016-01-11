
-- Staging table #1: CHARTEVENTS
with ce as
(
  select adm.hadm_id
  , min(case when itemid in (211,220045) then valuenum else null end) as HeartRate_Min
  , max(case when itemid in (211,220045)  then valuenum else null end) as HeartRate_Max
  , min(case when itemid in (456,52,6702,443,220052,220181,225312) then valuenum else null end) as MeanBP_Min
  , max(case when itemid in (456,52,6702,443,220052,220181,225312)  then valuenum else null end) as MeanBP_Max
  , min(case when itemid in (615,618,220210,224690)  then valuenum else null end) as RespRate_Min
  , max(case when itemid in (615,618,220210,224690)  then valuenum else null end) as RespRate_Max
  from admissions adm
  left join chartevents chart
    on adm.hadm_id = chart.hadm_id
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
    group by adm.hadm_id
)
-- Staging table #3: LABEVENTS
, le as
(
  select adm.hadm_id
  , min(case when itemid = 50885 then valuenum else null end) as BILIRUBIN_min
  , max(case when itemid = 50885 then valuenum else null end) as BILIRUBIN_max
  , min(case when itemid = 50912 then valuenum else null end) as CREATININE_min
  , max(case when itemid = 50912 then valuenum else null end) as CREATININE_max
  , min(case when itemid in (50809,50931) then valuenum else null end) as GLUCOSE_min
  , max(case when itemid in (50809,50931) then valuenum else null end) as GLUCOSE_max
  , min(case when itemid in (50811,51222) then valuenum else null end) as HEMOGLOBIN_min
  , max(case when itemid in (50811,51222) then valuenum else null end) as HEMOGLOBIN_max
  , min(case when itemid in (50824,50983) then valuenum else null end) as SODIUM_min
  , max(case when itemid in (50824,50983) then valuenum else null end) as SODIUM_max
  , min(case when itemid in (51300,51301) then valuenum else null end) as WBC_min
  , max(case when itemid in (51300,51301) then valuenum else null end) as WBC_max

    from admissions adm

    left join labevents lab
      on adm.subject_id = lab.subject_id and adm.hadm_id = lab.hadm_id
      and lab.charttime >= adm.admittime and lab.charttime <= adm.dischtime
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
    group by adm.hadm_id
)

-- Staging table #2: GCS
-- Because we need to add together GCS components, we do it seperately from chartevents
-- This lets us group together the components by their CHARTTIME
-- Then we can add together components measured at the same time
, gcs_stg as
(
  select adm.hadm_id, chart.charttime
  , max(case when itemid in (723,223900) then valuenum else null end) as GCSVerbal
  , max(case when itemid in (454,223901) then valuenum else null end) as GCSMotor
  , max(case when itemid in (184,220739) then valuenum else null end) as GCSEyes
  from admissions adm
  left join chartevents chart
    on adm.hadm_id = chart.hadm_id
    and chart.itemid in
    (
      723, -- GCSVerbal
      454, -- GCSMotor
      184, -- GCSEyes
      223900, -- GCS - Verbal Response
      223901, -- GCS - Motor Response
      220739 -- GCS - Eye Opening
    )
  group by adm.hadm_id, chart.charttime
)
-- Aggregate table #2: GCS
, gcs as
(
  SELECT gcs_stg.hadm_id
  , min(GCSVerbal + GCSMotor + GCSEyes) as GCS_Min
  , max(GCSVerbal + GCSMotor + GCSEyes) as GCS_Max
  FROM gcs_stg
  group by gcs_stg.hadm_id
)

SELECT adm.hadm_id
, adm.HOSPITAL_EXPIRE_FLAG -- whether the patient died within the hospital
, round( (julianday(adm.admittime) - julianday(pat.dob))/365.24, 4) as Age

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
, GLUCOSE_min
, GLUCOSE_max
, HEMOGLOBIN_min
, HEMOGLOBIN_max
, SODIUM_min
, SODIUM_max
, WBC_min
, WBC_max

FROM admissions adm
inner join patients pat
  on adm.subject_id = pat.subject_id
left join ce
  on adm.hadm_id = ce.hadm_id
left join gcs
  on adm.hadm_id = gcs.hadm_id
left join le
  on adm.hadm_id = le.hadm_id
