with pvt as
(
  select ie.subject_id, ie.hadm_id, ie.icustay_id, ie.intime
  , case
    when itemid in (456,52,6702,443,220052,220181,225312) then 1 -- MeanBP
    when itemid in (615,618) then 2 -- RespRate

    when itemid in (723,223900) then 10 -- GCSVerbal
    when itemid in (454,223901) then 11 -- GCSMotor
    when itemid in (184,220739) then 12 -- GCSEyes
    else null end as VitalID
  , valuenum
  from icustays ie
  left join chartevents ce
  on ie.subject_id = ce.subject_id and ie.hadm_id = ce.hadm_id and ie.icustay_id = ce.icustay_id
  and ce.charttime >= ie.intime and ce.charttime <= date(ie.intime,'+1 day')
  where ce.itemid in
  (
 723, -- GCSVerbal
 454, -- GCSMotor
 184, -- GCSEyes

 223900, -- GCS - Verbal Response
 223901, -- GCS - Motor Response
 220739, -- GCS - Eye Opening
  618, --	Respiratory Rate
  615, --	Resp Rate (Total)
  456, --"NBP Mean"
  52, --"Arterial BP Mean"
  6702, --	Arterial BP Mean #2
  443, --	Manual BP Mean(calc)
  220052, --"Arterial Blood Pressure mean"
  220181, --"Non Invasive Blood Pressure mean"
  225312 --"ART BP mean"
  )
)
SELECT pvt.icustay_id
, adm.HOSPITAL_EXPIRE_FLAG -- whether the patient died within the hospital
, round( (julianday(pvt.intime) - julianday(pat.dob))/365.24, 4) as Age
, min(case when VitalID = 1 then valuenum else null end) as MeanBP_Min
, max(case when VitalID = 2 then valuenum else null end) as RespRate_Max
FROM pvt
inner join patients pat
on pvt.subject_id = pat.subject_id
inner join admissions adm
on pvt.hadm_id = adm.hadm_id
group by pvt.icustay_id, pvt.hadm_id, adm.HOSPITAL_EXPIRE_FLAG, pvt.intime, pat.dob
order by pvt.icustay_id;
