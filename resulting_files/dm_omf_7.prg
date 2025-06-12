CREATE PROGRAM dm_omf_7
 SET cat4 = 0
 SET cat5 = 0
 SET count = 0
 SET ocode[2] = fillstring(200," ")
 SELECT DISTINCT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning IN ("CABGC", "CABGEC")
   AND cv.code_set=14629
  ORDER BY cv.cdf_meaning
  DETAIL
   IF (cv.cdf_meaning="CABGC")
    ocode[1] = cnvtstring(cv.code_value)
   ELSE
    ocode[2] = cnvtstring(cv.code_value)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  mpp.client_id_fl01, mpp.patient_control_nbr_fl03, mpp.cover_period_to_fl06,
  mpp.cover_period_from_fl06, og.key2, me.pat_status_fl22
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
    AND me.cover_period_to_fl06=mpp.cover_period_to_fl06)
   JOIN (og
   WHERE og.key2 IN (ocode[1], ocode[2])
    AND ((og.key1=mpp.principal_procedure_code_fl80) OR (((og.key1=mpp.other_procedure_code_1_fl81)
    OR (((og.key1=mpp.other_procedure_code_2_fl81) OR (((og.key1=mpp.other_procedure_code_3_fl81) OR
   (((og.key1=mpp.other_procedure_code_4_fl81) OR (og.key1=mpp.other_procedure_code_5_fl81)) )) ))
   )) )) )
  DETAIL
   IF (me.pat_status_fl22 BETWEEN 20 AND 29)
    cat5 = (cat5+ 1)
   ELSE
    cat4 = (cat4+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SET denom = (cat4+ cat5)
 SET numer = cat5
 IF (denom=0)
  SET rate = 0.0
 ELSE
  SET rate = (cnvtreal(numer)/ cnvtreal(denom))
 ENDIF
 UPDATE  FROM omf_outcome_indicator ooi
  SET ooi.indicator_name = "Mortality rate for CABG"
  WHERE ooi.indicator_id=7
  WITH nocounter, dontcare = mppe, dontcare = mee
 ;end update
 IF (curqual=0)
  INSERT  FROM omf_outcome_indicator ooi
   SET ooi.indicator_id = 7, ooi.indicator_name = "Mortality rate for CABG"
   WITH nocounter
  ;end insert
 ENDIF
 UPDATE  FROM omf_outcome_rate oor
  SET oor.total_cases = data->num_patients, oor.numerator_value = numer, oor.denominator_value =
   denom,
   oor.observed_rate = rate, oor.updt_dt_tm = cnvtdatetime(curdate,curtime3), oor.updt_id = reqinfo->
   updt_id,
   oor.updt_applctx = reqinfo->updt_applctx, oor.updt_task = reqinfo->updt_task, oor.updt_cnt = (oor
   .updt_cnt+ 1)
  WHERE oor.indicator_id=7
   AND oor.reporting_period=cnvtdatetime(startdatesstring)
   AND (oor.client_id=data->client_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM omf_outcome_rate oor
   SET oor.total_cases = data->num_patients, oor.numerator_value = numer, oor.denominator_value =
    denom,
    oor.observed_rate = rate, oor.updt_dt_tm = cnvtdatetime(curdate,curtime3), oor.updt_id = reqinfo
    ->updt_id,
    oor.updt_applctx = reqinfo->updt_applctx, oor.updt_task = reqinfo->updt_task, oor.updt_cnt = 0,
    oor.indicator_id = 7, oor.reporting_period = cnvtdatetime(startdatesstring), oor.client_id = data
    ->client_id
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
END GO
