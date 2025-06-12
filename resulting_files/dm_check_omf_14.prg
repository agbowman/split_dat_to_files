CREATE PROGRAM dm_check_omf_14
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
  WHERE (( NOT (mpp.principal_procedure_date_fl80 BETWEEN cover_period_from_fl06 AND
  cover_period_to_fl06)) OR ((( NOT (mpp.other_procedure_date_1_fl81 BETWEEN cover_period_from_fl06
   AND cover_period_to_fl06)) OR ((( NOT (mpp.other_procedure_date_2_fl81 BETWEEN
  cover_period_from_fl06 AND cover_period_to_fl06)) OR ((( NOT (mpp.other_procedure_date_3_fl81
   BETWEEN cover_period_from_fl06 AND cover_period_to_fl06)) OR ((( NOT (mpp
  .other_procedure_date_4_fl81 BETWEEN cover_period_from_fl06 AND cover_period_to_fl06)) OR ( NOT (
  mpp.other_procedure_date_5_fl81 BETWEEN cover_period_from_fl06 AND cover_period_to_fl06))) )) ))
  )) ))
   AND mpp.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(
   enddatesstring)
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
   SET mee.error_cd = 05401, mee.status_flg = "R", mee.updt_dt_tm = cnvtdatetime(curdate,curtime3),
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
    SET mee.error_cd = 05401, mee.reporting_period = cnvtdatetime(startdatesstring), mee
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
