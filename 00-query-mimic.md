
# Introduction to the MIMIC database

## What is the MIMIC Critical Care Database?

MIMIC-III is an freely available relational database developed by the MIT Lab for Computational Physiology, comprising deidentified health data associated with >40,000 critical care patients. It includes demographics, vital signs, laboratory tests, medications, and more. MIMIC-III is used widely around the world in academic research, education, and industry. For further information, see: https://mimic.physionet.org/

## Workshop overview

During the workshop, you will:

* Learn about MIMIC-III, the publicly accessible critical care database
* Create a local version of MIMIC-III with a small sample of patients using the Firefox SQLite Plugin
* Explore the patient data using SQL
* Plot and analyse the data using Python
* Get inspiration for future research projects

## Set up a mini version of MIMIC-III on your computer

* MIMIC-III contains over 40,000 patients, but for the workshop we will be working with a subset of 9 patients.
* To create the database on your computer, you will need to install Firefox and the Firefox SQLite Manager Add-on. Open Firefox, select "Add-ons" from the Tools menu, and then install SQLite Manager.
* After restarting Firefox, select "SQLite Manager" from the tools menu. In SQLite Manager, click "Connect Database" in the menu, and select the "data/mimicdata.sqlite" database file.

## Start exploring the data with SQL

SQL stands for "structured query language". It is the standard language used for querying relational databases, which are databases comprising of several tables linked together by IDs.

TIP: queries are generally constructed using the following syntax:

```sql
SELECT <columns>  
FROM <table>  
WHERE <constraints>;
```

### Select all of the columns ('*') from the patients table

```sql
SELECT *  
FROM patients;
```

### Select all of the columns ('*') from the patients table where the patient is female

```sql
SELECT * 
FROM patients 
WHERE gender = 'F';
```

### Select all of the columns ('*') from the patients table for a single patient

```sql
SELECT * 
FROM patients 
WHERE subject_id = 40080;
```

## More example queries

### Combine the admissions and patients table using their common link, `subject_id`

```sql
SELECT *
FROM patients
INNER JOIN admissions
ON patients.subject_id = admissions.subject_id;
```

### Subselect rows using the where clause

Here we select only the female ('F') patients.

```sql
SELECT *
FROM patients
INNER JOIN admissions
ON patients.subject_id = admissions.subject_id
WHERE gender = 'F';
```

### Select a single patient by specifying their `subject_id`

Note that we need to specify which table the `subject_id` is sourced from (`patients.subject_id`). 
This is because there are two `subject_id` columns: one from patients and the other from admissions.
SQL will not know which table to choose from, so you must specify it.

```sql
SELECT *
FROM patients
INNER JOIN admissions
ON patients.subject_id = admissions.subject_id
WHERE gender = 'F'
AND patients.subject_id = 40080;
```

### Select only data from the patients table

We can use the table name with a wild card (*) to specify all columns from that table.

```sql
SELECT patients.*
FROM patients
INNER JOIN admissions
ON patients.subject_id = admissions.subject_id
WHERE gender = 'F'
AND patients.subject_id = 40080;
```

### Select only data from the admissions table

Similarly, we can select only the columns in the admissions table.

```sql
SELECT admissions.*
FROM patients
INNER JOIN admissions
ON patients.subject_id = admissions.subject_id
WHERE gender = 'F'
AND patients.subject_id = 40080;
```

### Select single columns from a table

Instead of using the wild card, we can specify the columns we would like (in this case, DOB).

```sql
SELECT patients.DOB, admissions.*
FROM patients
INNER JOIN admissions
ON patients.subject_id = admissions.subject_id
WHERE gender = 'F'
AND patients.subject_id = 40080;
```

### Using aliases for convenience

Typing out admissions and patients over and over can be tedious. SQL allows aliases to be defined.
Aliases are simply short hand for the full table name. An alias is defined by writing a word after the table name appears in either the FROM or JOIN clause.
For example, we have defined the alias 'pat' for patients, and the alias 'adm' for admissions.
Now, when we select from these tables, we use the alias name, *not* the table name.

```sql
SELECT pat.DOB, adm.*
FROM patients pat
INNER JOIN admissions adm
ON pat.subject_id = adm.subject_id
WHERE gender = 'F'
AND pat.subject_id = 40080;
```

### Select data for the same patient from chartevents

```sql
SELECT *
FROM chartevents
WHERE subject_id = 40080;
```

### Define an alias for chartevents and select data from it

```sql
SELECT ce.*
FROM chartevents ce
WHERE subject_id = 40080;
```

### Join to the d_items table to get a description of what the observations in chartevents are

```sql
SELECT ce.*, di.label
FROM chartevents ce
INNER JOIN d_items di
ON ce.itemid = di.itemid
WHERE subject_id = 40080;
```
