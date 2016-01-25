-- In a lot of the code that you will use today, you will need to group values.
-- What does it mean to group values?
-- Say you want my highest heart rate for the day...
-- that's equivalent to saying "I want the max heart rate *group by* ICUSTAY_ID"

-- Imagine you have a table with 2 columns and 5 rows
--  ICUSTAY_ID | HEART RATE
--      1      |    90
--      1      |    73
--      2      |    84
--      2      |    82
--      2      |    81

-- Here we have two ICU stays (#1 and #2). We'd like their highest (maximum) heart rate.

-- If we take the max() of the 2nd column, we now have:
--  5 rows in the first column
--  ?? how many rows in the second column
--  ICUSTAY_ID | max(HEART RATE)
--      1      |    ?
--      1      |    ?
--      2      |    ?
--      2      |    ?
--      2      |    ?

-- The logical answer is we'd want to collapse heart rate by ICUSTAY_ID.
-- I'm interested in each ICU stays highest heart rate - taking the maximum another way (e.g. across patients) doesn't make sense.
-- To do this: we need to tell SQL how to *group* the max value
-- If we say *group by* ICUSTAY_ID, then we tell SQL to group the heart rates according to ICUSTAY_ID

--  ICUSTAY_ID | max(HEART RATE)
--      1      |    90
--      2      |    84

-- In SQL, we specify this by adding in "group by" at the bottom of the query.


-- Let's try it for something simple: let's find the first time a patient entered the ICU
select
  -- ICUSTAY_ID identifies each unique patient ICU stay
  -- note that if the same person stays in the ICU more than once, each stay would have a *different* ICUSTAY_ID
  -- however, since it's the same person, all those stays would have the same SUBJECT_ID
  icustay_id

  -- this is the lowest intime
  -- since 'intime' is a date, the lowest intime is conceptually the same as the earliest intime
  , min(intime) as MinimumINTIME

from icustays ie
group by icustay_id;
