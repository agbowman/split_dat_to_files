CREATE PROGRAM dm_omf_4
 SET cat4 = 0
 SET cat5 = 0
 SET count = 0
 SET ocode[2] = fillstring(200," ")
 SELECT DISTINCT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning IN ("LBIC", "LBW")
   AND cv.code_set=14629
  DETAIL
   IF (cv.cdf_meaning="LBIC")
    ocode[1] = cnvtstring(cv.code_value)
   ELSE
    ocode[2] = cnvtstring(cv.code_value)
   ENDIF
  WITH nocounter
 ;end select
 SET temp_person = fillstring(20," ")
 SELECT INTO "nl:"
  md.client_id_fl01, md.patient_control_nbr_fl03, md.cover_period_from_fl06,
  md.cover_period_to_fl06, md2.client_id_fl01, md2.patient_control_nbr_fl03,
  md2.cover_period_from_fl06, md2.cover_period_to_fl06, og_1.key2,
  og_2.key2
  FROM ub92_mon_diagnosis md,
   ub92_mon_diagnosis md2,
   omf_groupings og_1,
   omf_groupings og_2
  PLAN (md
   WHERE (md.client_id_fl01=data->client_id)
    AND md.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(
    enddatesstring))
   JOIN (md2
   WHERE md2.client_id_fl01=md.client_id_fl01
    AND md2.patient_control_nbr_fl03=md.patient_control_nbr_fl03
    AND md2.cover_period_from_fl06=md.cover_period_from_fl06
    AND md2.cover_period_to_fl06=md.cover_period_to_fl06)
   JOIN (og_1
   WHERE (og_1.key2=ocode[1])
    AND ((og_1.key1=md.principal_diagnosis_code_fl67) OR (((og_1.key1=md.other_diagnosis_code_1_fl68)
    OR (((og_1.key1=md.other_diagnosis_code_2_fl69) OR (((og_1.key1=md.other_diagnosis_code_3_fl70)
    OR (((og_1.key1=md.other_diagnosis_code_4_fl71) OR (((og_1.key1=md.other_diagnosis_code_5_fl72)
    OR (((og_1.key1=md.other_diagnosis_code_6_fl73) OR (((og_1.key1=md.other_diagnosis_code_7_fl74)
    OR (og_1.key1=md.other_diagnosis_code_8_fl75)) )) )) )) )) )) )) )) )
   JOIN (og_2
   WHERE ((og_2.key1=md2.principal_diagnosis_code_fl67) OR (((og_2.key1=md2
   .other_diagnosis_code_1_fl68) OR (((og_2.key1=md2.other_diagnosis_code_2_fl69) OR (((og_2.key1=md2
   .other_diagnosis_code_3_fl70) OR (((og_2.key1=md2.other_diagnosis_code_4_fl71) OR (((og_2.key1=md2
   .other_diagnosis_code_5_fl72) OR (((og_2.key1=md2.other_diagnosis_code_6_fl73) OR (((og_2.key1=md2
   .other_diagnosis_code_7_fl74) OR (og_2.key1=md2.other_diagnosis_code_8_fl75)) )) )) )) )) )) ))
   )) )
  ORDER BY md.client_id_fl01, md.patient_control_nbr_fl03, md.cover_period_to_fl06,
   md.cover_period_from_fl06, og_2.key2
  DETAIL
   IF (temp_person != md.patient_control_nbr_fl03)
    IF ((og_2.key2=ocode[2]))
     cat5 = (cat5+ 1), insert_flag = 5
    ELSE
     cat4 = (cat4+ 1), insert_flag = 4
    ENDIF
    temp_person = md.patient_control_nbr_fl03
   ELSEIF (insert_flag=4
    AND (og_2.key2=ocode[2]))
    cat4 = (cat5+ 1), cat5 = (cat4 - 1)
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
  SET ooi.indicator_name = "Birth rate for births < 2500 grams"
  WHERE ooi.indicator_id=4
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM omf_outcome_indicator ooi
   SET ooi.indicator_id = 4, ooi.indicator_name = "Birth rate for births < 2500 grams"
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
  WHERE oor.indicator_id=4
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
    oor.indicator_id = 4, oor.reporting_period = cnvtdatetime(startdatesstring), oor.client_id = data
    ->client_id
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
END GO
