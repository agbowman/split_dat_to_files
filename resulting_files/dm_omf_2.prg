CREATE PROGRAM dm_omf_2
 SET cat4 = 0
 SET cat5 = 0
 SET count = 0
 SET ocode[6] = fillstring(200," ")
 SELECT DISTINCT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning IN ("CMRP", "NDPLD", "COLD", "OLDC", "CPC",
  "CSC")
   AND cv.code_set=14629
  DETAIL
   IF (cv.cdf_meaning="CMRP")
    ocode[1] = cnvtstring(cv.code_value)
   ELSEIF (cv.cdf_meaning="NDPLD")
    ocode[2] = cnvtstring(cv.code_value)
   ELSEIF (cv.cdf_meaning="COLD")
    ocode[3] = cnvtstring(cv.code_value)
   ELSEIF (cv.cdf_meaning="OLDC")
    ocode[4] = cnvtstring(cv.code_value)
   ELSEIF (cv.cdf_meaning="CPC")
    ocode[5] = cnvtstring(cv.code_value)
   ELSE
    ocode[6] = cnvtstring(cv.code_value)
   ENDIF
  WITH nocounter
 ;end select
 SET temp_person = fillstring(20," ")
 SELECT DISTINCT INTO "nl:"
  md.client_id_fl01, md.patient_control_nbr_fl03, md.cover_period_from_fl06,
  md.cover_period_to_fl06, mpp.client_id_fl01, mpp.patient_control_nbr_fl03,
  mpp.cover_period_from_fl06, mpp.cover_period_to_fl06, og_d.key1,
  og_d.key2, og_p.key1, og_p.key2
  FROM ub92_mon_diagnosis md,
   ub92_mon_proc_phys mpp,
   omf_groupings og_d,
   omf_groupings og_p
  PLAN (md
   WHERE (md.client_id_fl01=data->client_id)
    AND md.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(
    enddatesstring))
   JOIN (mpp
   WHERE mpp.client_id_fl01=md.client_id_fl01
    AND mpp.patient_control_nbr_fl03=md.patient_control_nbr_fl03
    AND mpp.cover_period_from_fl06=md.cover_period_from_fl06
    AND mpp.cover_period_to_fl06=md.cover_period_to_fl06)
   JOIN (og_d
   WHERE og_d.key2 IN (ocode[1], ocode[2], ocode[3], ocode[4], ocode[5])
    AND ((og_d.key1=md.principal_diagnosis_code_fl67) OR (((og_d.key1=md.other_diagnosis_code_1_fl68)
    OR (((og_d.key1=md.other_diagnosis_code_2_fl69) OR (((og_d.key1=md.other_diagnosis_code_3_fl70)
    OR (((og_d.key1=md.other_diagnosis_code_4_fl71) OR (((og_d.key1=md.other_diagnosis_code_5_fl72)
    OR (((og_d.key1=md.other_diagnosis_code_6_fl73) OR (((og_d.key1=md.other_diagnosis_code_7_fl74)
    OR (og_d.key1=md.other_diagnosis_code_8_fl75)) )) )) )) )) )) )) )) )
   JOIN (og_p
   WHERE ((og_p.key1=mpp.principal_procedure_code_fl80) OR (((og_p.key1=mpp
   .other_procedure_code_1_fl81) OR (((og_p.key1=mpp.other_procedure_code_2_fl81) OR (((og_p.key1=mpp
   .other_procedure_code_3_fl81) OR (((og_p.key1=mpp.other_procedure_code_4_fl81) OR (og_p.key1=mpp
   .other_procedure_code_5_fl81)) )) )) )) )) )
  ORDER BY md.client_id_fl01, md.patient_control_nbr_fl03, md.cover_period_from_fl06,
   md.cover_period_to_fl06, og_d.key1, og_p.key1
  HEAD md.patient_control_nbr_fl03
   insert_flag = 4
  DETAIL
   IF ((og_p.key2=ocode[6]))
    insert_flag = 5
   ENDIF
  FOOT  md.patient_control_nbr_fl03
   IF (insert_flag=4)
    cat4 = (cat4+ 1)
   ELSE
    cat5 = (cat5+ 1)
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
  SET ooi.indicator_name = "C-section rate"
  WHERE ooi.indicator_id=2
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM omf_outcome_indicator ooi
   SET ooi.indicator_id = 2, ooi.indicator_name = "C-section rate"
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
  WHERE oor.indicator_id=2
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
    oor.indicator_id = 2, oor.reporting_period = cnvtdatetime(startdatesstring), oor.client_id = data
    ->client_id
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
END GO
