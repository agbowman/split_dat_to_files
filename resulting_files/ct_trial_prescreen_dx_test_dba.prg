CREATE PROGRAM ct_trial_prescreen_dx_test:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Execution Mode:" = "",
  "Evaluation Start Date" = curdate,
  "Evaluation End Date" = curdate,
  "Encounter types to be considered:" = 0,
  "Facility to be evaluated:" = 0,
  "Protocols to be Considered:" = "",
  "Gender" = 0.000000,
  "Age Qualifier" = 0.000000,
  "Age 1 (years)" = 0,
  "Age 2 (years)" = 0,
  "Race" = 0.000000,
  "Ethnicity" = 0.000000,
  "Terminology Codes" = "0.000000",
  "Codes" = "",
  "icd9DefaultHidden" = 0,
  "Evaluation By:" = 0
  WITH outdev, execmode, startdate,
  enddate, encntrtypecd, facilitycd,
  triggername, gender, qualifier,
  age1, age2, race,
  ethnicity, terminology, codes,
  icd9defaulthidden, evalby
 DECLARE order_by = i2 WITH protect, constant(0)
 DECLARE test_only = i2 WITH protect, constant(1)
 EXECUTE ct_trial_prescreen_dx  $OUTDEV,  $EXECMODE,  $STARTDATE,
  $ENDDATE,  $ENCNTRTYPECD,  $FACILITYCD,
  $TRIGGERNAME, order_by,  $GENDER,
  $QUALIFIER,  $AGE1,  $AGE2,
  $RACE,  $ETHNICITY,  $TERMINOLOGY,
  $CODES,  $ICD9DEFAULTHIDDEN, test_only,
  $EVALBY
 SET last_mod = "003"
 SET mod_date = "Dec 14, 2017"
END GO
