CREATE PROGRAM dm_omf_1
 SET cat4 = 0
 SET cat5 = 0
 SET count = 0
 SET datelimit = (cnvtdatetime("03-jun-1997") - cnvtdatetime("01-jun-1997"))
 SET ocode = fillstring(200," ")
 SET kount = 1
 SELECT DISTINCT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="PIAA"
   AND cv.code_set=14629
  DETAIL
   ocode = cnvtstring(cv.code_value)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  mpp.client_id_fl01, mpp.patient_control_nbr_fl03, mpp.cover_period_from_fl06,
  mpp.cover_period_to_fl06, mpp.principal_procedure_date_fl80, mpp.other_procedure_date_1_fl81,
  mpp.other_procedure_date_2_fl81, mpp.other_procedure_date_3_fl81, mpp.other_procedure_date_4_fl81,
  mpp.other_procedure_date_5_fl81, p_time = datetimecmp(cnvtdatetime(mpp.cover_period_to_fl06),
   cnvtdatetime(mpp.principal_procedure_date_fl80)), 1_time = datetimecmp(cnvtdatetime(mpp
    .cover_period_to_fl06),cnvtdatetime(mpp.other_procedure_date_1_fl81)),
  2_time = datetimecmp(cnvtdatetime(mpp.cover_period_to_fl06),cnvtdatetime(mpp
    .other_procedure_date_2_fl81)), 3_time = datetimecmp(cnvtdatetime(mpp.cover_period_to_fl06),
   cnvtdatetime(mpp.other_procedure_date_3_fl81)), 4_time = datetimecmp(cnvtdatetime(mpp
    .cover_period_to_fl06),cnvtdatetime(mpp.other_procedure_date_4_fl81)),
  5_time = datetimecmp(cnvtdatetime(mpp.cover_period_to_fl06),cnvtdatetime(mpp
    .other_procedure_date_5_fl81)), me.client_id_fl01, me.patient_control_nbr_fl03,
  me.cover_period_from_fl06, me.cover_period_to_fl06, me.pat_status_fl22,
  og.key1, og.key2
  FROM ub92_mon_proc_phys mpp,
   ub92_mon_encounter me,
   omf_groupings og
  PLAN (mpp
   WHERE (mpp.client_id_fl01=data->client_id)
    AND mpp.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(
    enddatesstring))
   JOIN (me
   WHERE (me.client_id_fl01=data->client_id)
    AND me.patient_control_nbr_fl03=mpp.patient_control_nbr_fl03
    AND me.cover_period_from_fl06=mpp.cover_period_from_fl06
    AND me.cover_period_to_fl06=mpp.cover_period_to_fl06
    AND me.pat_status_fl22 != null)
   JOIN (og
   WHERE og.key2=ocode
    AND ((og.key1=mpp.principal_procedure_code_fl80) OR (((og.key1=mpp.other_procedure_code_1_fl81)
    OR (((og.key1=mpp.other_procedure_code_2_fl81) OR (((og.key1=mpp.other_procedure_code_3_fl81) OR
   (((og.key1=mpp.other_procedure_code_4_fl81) OR (og.key1=mpp.other_procedure_code_5_fl81)) )) ))
   )) )) )
  ORDER BY mpp.ub92_mon_proc_phys_seq, og.key1
  DETAIL
   col 0
   IF (mpp.principal_procedure_code_fl80=og.key1)
    IF (p_time <= 2)
     IF (me.pat_status_fl22 BETWEEN 20 AND 29)
      cat5 = (cat5+ 1)
     ELSE
      cat4 = (cat4+ 1)
     ENDIF
    ENDIF
   ELSEIF (mpp.other_procedure_code_1_fl81=og.key1)
    IF (1_time <= 2)
     IF (me.pat_status_fl22 BETWEEN 20 AND 29)
      cat5 = (cat5+ 1)
     ELSE
      cat4 = (cat4+ 1)
     ENDIF
    ENDIF
   ELSEIF (mpp.other_procedure_code_2_fl81=og.key1)
    IF (2_time <= 2)
     IF (me.pat_status_fl22 BETWEEN 20 AND 29)
      cat5 = (cat5+ 1)
     ELSE
      cat4 = (cat4+ 1)
     ENDIF
    ENDIF
   ELSEIF (mpp.other_procedure_code_3_fl81=og.key1)
    IF (3_time <= 2)
     IF (me.pat_status_fl22 BETWEEN 20 AND 29)
      cat5 = (cat5+ 1)
     ELSE
      cat4 = (cat4+ 1)
     ENDIF
    ENDIF
   ELSEIF (mpp.other_procedure_code_4_fl81=og.key1)
    IF (4_time <= 2)
     IF (me.pat_status_fl22 BETWEEN 20 AND 29)
      cat5 = (cat5+ 1)
     ELSE
      cat4 = (cat4+ 1)
     ENDIF
    ENDIF
   ELSEIF (mpp.other_procedure_code_5_fl81=og.key1)
    IF (5_time <= 2)
     IF (me.pat_status_fl22 BETWEEN 20 AND 29)
      cat5 = (cat5+ 1)
     ELSE
      cat4 = (cat4+ 1)
     ENDIF
    ENDIF
   ENDIF
   p_time, col 5, 1_time,
   col 10, 2_time, col 15,
   3_time, col 20, 4_time,
   col 25, 5_time, row + 1
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
  SET ooi.indicator_name = "Mortality rate for anesthesia administration"
  WHERE ooi.indicator_id=1
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM omf_outcome_indicator ooi
   SET ooi.indicator_id = 1, ooi.indicator_name = "Mortality rate for anesthesia administration"
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
  WHERE oor.indicator_id=1
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
    oor.indicator_id = 1, oor.reporting_period = cnvtdatetime(startdatesstring), oor.client_id = data
    ->client_id
   WITH nocounter
  ;end insert
 ENDIF
#end_prg
 COMMIT
END GO
