CREATE PROGRAM dm_check_omf_9
 FREE SET data
 RECORD data(
   1 count = i4
   1 list[*]
     2 ub92_mon_proc_phys_seq = i4
     2 updt_task = c40
 )
 SET data->count = 0
 SET kount = 0
 SET ocode[9] = fillstring(10," ")
 SELECT INTO "nl:"
  *
  FROM code_value cv
  WHERE cv.cdf_meaning IN ("CMPP", "NDPLD", "COLD", "OLDC", "CSC",
  "HCSC", "FCC", "PFBCC", "MASTEC")
  DETAIL
   kount = (kount+ 1), ocode[kount] = cnvtstring(cv.code_value)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  mpp.client_id_fl01, mpp.patient_control_nbr_fl03, mpp.cover_period_to_fl06,
  mpp.cover_period_from_fl06, me.sex_fl15
  FROM ub92_mon_proc_phys mpp,
   ub92_mon_encounter me,
   omf_groupings og
  PLAN (mpp
   WHERE mpp.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(
    enddatesstring))
   JOIN (og
   WHERE og.key2 IN (ocode[1], ocode[2], ocode[3], ocode[4], ocode[5],
   ocode[6], ocode[7], ocode[8], ocode[9])
    AND ((og.key1=mpp.principal_procedure_code_fl80) OR (((og.key1=mpp.other_procedure_code_1_fl81)
    OR (((og.key1=mpp.other_procedure_code_2_fl81) OR (((og.key1=mpp.other_procedure_code_2_fl81) OR
   (((og.key1=mpp.other_procedure_code_2_fl81) OR (og.key1=mpp.other_procedure_code_2_fl81)) )) ))
   )) )) )
   JOIN (me
   WHERE me.client_id_fl01=mpp.client_id_fl01
    AND me.patient_control_nbr_fl03=mpp.patient_control_nbr_fl03
    AND me.cover_period_from_fl06=mpp.cover_period_from_fl06
    AND me.cover_period_to_fl06=mpp.cover_period_to_fl06
    AND me.sex_fl15="M")
  ORDER BY mpp.client_id_fl01, mpp.patient_control_nbr_fl03, mpp.cover_period_to_fl06,
   mpp.cover_period_from_fl06, me.sex_fl15
  DETAIL
   data->count = (data->count+ 1)
   IF (mod(data->count,10)=1)
    stat = alterlist(data->list,(data->count+ 9))
   ENDIF
   data->list[data->count].ub92_mon_proc_phys_seq = mpp.ub92_mon_proc_phys_seq, data->list[data->
   count].updt_task = mpp.updt_task
  WITH nocounter
 ;end select
 IF (curqual != 0)
  UPDATE  FROM ub92_mon_proc_phys_error mee,
    (dummyt d  WITH seq = value(data->count))
   SET mee.error_cd = 01408, mee.status_flg = "R", mee.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    mee.updt_task = data->list[d.seq].updt_task
   PLAN (d)
    JOIN (mee
    WHERE mee.reporting_period=cnvtdatetime(startdatesstring)
     AND (mee.ub92_mon_proc_phys_seq=data->list[d.seq].ub92_mon_proc_phys_seq))
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM ub92_mon_proc_phys_error mee,
     (dummyt d  WITH seq = value(data->count))
    SET mee.error_cd = 01408, mee.reporting_period = cnvtdatetime(startdatesstring), mee
     .ub92_mon_proc_phys_seq = data->list[d.seq].ub92_mon_proc_phys_seq,
     mee.status_flg = "R", mee.updt_dt_tm = cnvtdatetime(curdate,curtime3), mee.updt_task = data->
     list[d.seq].updt_task
    PLAN (d)
     JOIN (mee)
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
END GO
