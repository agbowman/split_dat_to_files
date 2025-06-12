CREATE PROGRAM dm_check_omf_12
 FREE SET data
 RECORD data(
   1 count = i4
   1 list[*]
     2 ub92_mon_diagnosis_seq = i4
     2 updt_task = c40
 )
 SET data->count = 0
 SELECT INTO "nl:"
  *
  FROM ub92_mon_diagnosis md
  WHERE md.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(
   enddatesstring)
   AND ((md.principal_diagnosis_code_fl67 != null
   AND substring(3,1,md.principal_diagnosis_code_fl67) != ".") OR (((md.other_diagnosis_code_1_fl68
   != null
   AND substring(3,1,md.other_diagnosis_code_1_fl68) != ".") OR (((md.other_diagnosis_code_2_fl69 !=
  null
   AND substring(3,1,md.other_diagnosis_code_2_fl69) != ".") OR (((md.other_diagnosis_code_3_fl70 !=
  null
   AND substring(3,1,md.other_diagnosis_code_3_fl70) != ".") OR (((md.other_diagnosis_code_4_fl71 !=
  null
   AND substring(3,1,md.other_diagnosis_code_4_fl71) != ".") OR (((md.other_diagnosis_code_5_fl72 !=
  null
   AND substring(3,1,md.other_diagnosis_code_5_fl72) != ".") OR (((md.other_diagnosis_code_6_fl73 !=
  null
   AND substring(3,1,md.other_diagnosis_code_6_fl73) != ".") OR (((md.other_diagnosis_code_7_fl74 !=
  null
   AND substring(3,1,md.other_diagnosis_code_7_fl74) != ".") OR (md.other_diagnosis_code_8_fl75 !=
  null
   AND substring(3,1,md.other_diagnosis_code_8_fl75) != ".")) )) )) )) )) )) )) ))
  DETAIL
   data->count = (data->count+ 1)
   IF (mod(data->count,10)=1)
    stat = alterlist(data->list,(data->count+ 9))
   ENDIF
   data->list[data->count].ub92_mon_diagnosis_seq = md.ub92_mon_diagnosis_seq, data->list[data->count
   ].updt_task = md.updt_task
  WITH nocounter
 ;end select
 IF (curqual != 0)
  UPDATE  FROM ub92_mon_diagnosis_error mee,
    (dummyt d  WITH seq = value(data->count))
   SET mee.error_cd = 09903, mee.status_flg = "W", mee.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    mee.updt_task = data->list[d.seq].updt_task
   PLAN (d)
    JOIN (mee
    WHERE mee.reporting_period=cnvtdatetime(startdatesstring)
     AND (mee.ub92_mon_diagnosis_seq=data->list[d.seq].ub92_mon_diagnosis_seq))
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM ub92_mon_diagnosis_error mee,
     (dummyt d  WITH seq = value(data->count))
    SET mee.error_cd = 09903, mee.reporting_period = cnvtdatetime(startdatesstring), mee
     .ub92_mon_diagnosis_seq = data->list[d.seq].ub92_mon_diagnosis_seq,
     mee.status_flg = "W", mee.updt_dt_tm = cnvtdatetime(curdate,curtime3), mee.updt_task = data->
     list[d.seq].updt_task
    PLAN (d)
     JOIN (mee)
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
END GO
