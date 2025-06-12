CREATE PROGRAM dm_check_omf_11
 FREE SET data
 RECORD data(
   1 count = i4
   1 list[*]
     2 ub92_mon_proc_phys_seq = i4
     2 updt_task = c40
 )
 SET data->count = 0
 SELECT INTO "nl:"
  *
  FROM ub92_mon_proc_phys mpp
  WHERE mpp.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(
   enddatesstring)
   AND ((mpp.principal_procedure_code_fl80 != null
   AND substring(3,1,mpp.principal_procedure_code_fl80) != ".") OR (((mpp.other_procedure_code_1_fl81
   != null
   AND substring(3,1,mpp.other_procedure_code_1_fl81) != ".") OR (((mpp.other_procedure_code_2_fl81
   != null
   AND substring(3,1,mpp.other_procedure_code_2_fl81) != ".") OR (((mpp.other_procedure_code_3_fl81
   != null
   AND substring(3,1,mpp.other_procedure_code_3_fl81) != ".") OR (((mpp.other_procedure_code_4_fl81
   != null
   AND substring(3,1,mpp.other_procedure_code_4_fl81) != ".") OR (mpp.other_procedure_code_5_fl81 !=
  null
   AND substring(3,1,mpp.other_procedure_code_5_fl81) != ".")) )) )) )) ))
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
   SET mee.error_cd = 9902, mee.status_flg = "W", mee.updt_dt_tm = cnvtdatetime(curdate,curtime3),
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
    SET mee.error_cd = 09902, mee.reporting_period = cnvtdatetime(startdatesstring), mee
     .ub92_mon_proc_phys_seq = data->list[d.seq].ub92_mon_proc_phys_seq,
     mee.status_flg = "W", mee.updt_dt_tm = cnvtdatetime(curdate,curtime3), mee.updt_task = data->
     list[d.seq].updt_task
    PLAN (d)
     JOIN (mee)
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
END GO
