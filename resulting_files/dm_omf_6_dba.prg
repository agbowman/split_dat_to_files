CREATE PROGRAM dm_omf_6:dba
 SET cat4 = 0
 SET cat5 = 0
 SET count = 0
 SET len_stay[1] = 0.0
 SET datelimit = (cnvtdatetime("03-jun-1997") - cnvtdatetime("02-jun-1997"))
 SET ocode[2] = fillstring(200," ")
 SELECT DISTINCT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning IN ("PTCAC", "PTCAPC")
   AND cv.code_set=14629
  DETAIL
   IF (cv.cdf_meaning="CABGC")
    ocode[1] = cnvtstring(cv.code_value)
   ELSE
    ocode[2] = cnvtstring(cv.code_value)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  mpp.*, og.*, me.*
  FROM ub92_mon_proc_phys mpp,
   ub92_mon_encounter me,
   omf_groupings og
  PLAN (mpp
   WHERE (mpp.client_id_fl01=data->client_id)
    AND mpp.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(
    enddatesstring))
   JOIN (me
   WHERE me.client_id_fl01=mpp.client_id_fl01
    AND me.patient_control_nbr_fl03=mpp.patient_control_nbr_fl03
    AND me.cover_period_from_fl06=mpp.cover_period_from_fl06
    AND me.cover_period_to_fl06=mpp.cover_period_to_fl06
    AND  NOT (me.pat_status_fl22 IN (2, 7, 20, 21, 22,
   23, 24, 25, 26, 27,
   28, 29)))
   JOIN (og
   WHERE og.key2 IN (ocode[1], ocode[2])
    AND ((og.key1=mpp.principal_procedure_code_fl80) OR (((og.key1=mpp.other_procedure_code_1_fl81)
    OR (((og.key1=mpp.other_procedure_code_2_fl81) OR (((og.key1=mpp.other_procedure_code_3_fl81) OR
   (((og.key1=mpp.other_procedure_code_4_fl81) OR (og.key1=mpp.other_procedure_code_5_fl81)) )) ))
   )) )) )
  DETAIL
   count = (count+ 1), stat = memrealloc(len_stay,count,"f8"), temp_date = cnvtdatetime(
    "31-dec-2200 23:59:59.59")
   IF (og.key1=mpp.principal_procedure_code_fl80
    AND mpp.principal_procedure_date_fl80 < temp_date)
    temp_date = mpp.principal_procedure_date_fl80
   ENDIF
   IF (og.key1=mpp.other_procedure_code_1_fl81
    AND mpp.other_procedure_date_1_fl81 < temp_date)
    temp_date = mpp.other_procedure_date_1_fl81
   ENDIF
   IF (og.key1=mpp.other_procedure_code_2_fl81
    AND mpp.other_procedure_date_2_fl81 < temp_date)
    temp_date = mpp.other_procedure_date_2_fl81
   ENDIF
   IF (og.key1=mpp.other_procedure_code_3_fl81
    AND mpp.other_procedure_date_3_fl81 < temp_date)
    temp_date = mpp.other_procedure_date_3_fl81
   ENDIF
   IF (og.key1=mpp.other_procedure_code_4_fl81
    AND mpp.other_procedure_date_4_fl81 < temp_date)
    temp_date = mpp.other_procedure_date_4_fl81
   ENDIF
   IF (og.key1=mpp.other_procedure_code_5_fl81
    AND mpp.other_procedure_date_5_fl81 < temp_date)
    temp_date = mpp.other_procedure_date_5_fl81
   ENDIF
   numer = (cnvtdatetime(mpp.cover_period_to_fl06) - cnvtdatetime(temp_date)), len_stay[count] =
   cnvtreal((numer/ datelimit))
   IF ((len_stay[count] > 365))
    temp_string = concat("Patient ",trim(mpp.patient_control_nbr_fl03)), temp2 = concat(temp_string,
     " shows a procedure date of more than a year before discharge date."),
    CALL echo(temp2)
   ENDIF
  WITH nocounter
 ;end select
 SET num_cases = count
 IF (curqual != 0)
  SET sorted[1] = 0.0
  SET stat = memrealloc(sorted,count,"f8")
  SET kount = 0
  SELECT INTO "nl:"
   x = len_stay[d.seq]
   FROM (dummyt d  WITH seq = value(count))
   ORDER BY x
   DETAIL
    kount = (kount+ 1), sorted[kount] = x
   WITH nocounter
  ;end select
  SET median = 0.0
  SET maximum = 0.0
  SET minimum = 0.0
  SET mean = 0.0
  SET std_dev = 0.0
  IF (mod(count,2)=1)
   SET median = ((sorted[(count/ 2)]+ sorted[((count/ 2)+ 1)])/ 2)
  ELSE
   SET median = sorted[((count/ 2)+ 1)]
  ENDIF
  SET maximum = sorted[count]
  SET minimum = sorted[1]
  SET sum_days = sorted[1]
  SET kount = 0
  FOR (kount = 2 TO count)
    SET sum_days = (sum_days+ sorted[kount])
  ENDFOR
  SET mean = (cnvtreal(sum_days)/ cnvtreal(count))
  SET variance = 0.0
  SET std_dev = 0.0
  FOR (kount = 1 TO count)
    SET variance = (variance+ ((mean - sorted[count]) * (mean - sorted[count])))
  ENDFOR
  SET std_dev = exp((0.5 * log((variance/ cnvtreal((count - 1))))))
 ELSE
  SET median = 0.0
  SET maximum = 0.0
  SET minimum = 0.0
  SET mean = 0.0
  SET std_dev = 0.0
 ENDIF
 UPDATE  FROM omf_outcome_indicator ooi
  SET ooi.indicator_name = "Days from PTCA surgery to discharge"
  WHERE ooi.indicator_id=6
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM omf_outcome_indicator ooi
   SET ooi.indicator_id = 6, ooi.indicator_name = "Days from PTCA surgery to discharge"
   WITH nocounter
  ;end insert
 ENDIF
 UPDATE  FROM omf_outcome_continuous omf
  SET omf.total_cases = data->num_patients, omf.number_of_cases = count, omf.observed_mean = mean,
   omf.observed_median = median, omf.observed_maximum = cnvtint(maximum), omf.observed_minimum =
   cnvtint(minimum),
   omf.observed_standard_deviation = std_dev, omf.updt_dt_tm = cnvtdatetime(curdate,curtime3), omf
   .updt_id = reqinfo->updt_id,
   omf.updt_applctx = reqinfo->updt_applctx, omf.updt_task = reqinfo->updt_task, omf.updt_cnt = (omf
   .updt_cnt+ 1)
  WHERE omf.indicator_id=6
   AND omf.reporting_period=cnvtdatetime(startdatesstring)
   AND (omf.client_id=data->client_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM omf_outcome_continuous omf
   SET omf.indicator_id = 6, omf.reporting_period = cnvtdatetime(startdatesstring), omf.client_id =
    data->client_id,
    omf.total_cases = data->num_patients, omf.observed_mean = mean, omf.observed_median = median,
    omf.number_of_cases = count, omf.observed_maximum = cnvtint(maximum), omf.observed_minimum =
    cnvtint(minimum),
    omf.observed_standard_deviation = std_dev, omf.updt_dt_tm = cnvtdatetime(curdate,curtime3), omf
    .updt_id = reqinfo->updt_id,
    omf.updt_applctx = reqinfo->updt_applctx, omf.updt_task = reqinfo->updt_task, omf.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
END GO
