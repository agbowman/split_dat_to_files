CREATE PROGRAM dm_check_omf_1
 FREE SET data
 RECORD data(
   1 count = i4
   1 list[*]
     2 ub92_mon_encounter_seq = i4
     2 updt_task = c40
 )
 SET data->count = 0
 SELECT INTO "nl:"
  *
  FROM ub92_mon_encounter me
  WHERE  NOT (me.sex_fl15 IN ("M", "F", "U"))
   AND me.cover_period_to_fl06 BETWEEN cnvtdatetime(startdatesstring) AND cnvtdatetime(enddatesstring
   )
  DETAIL
   data->count = (data->count+ 1)
   IF (mod(data->count,10)=1)
    stat = alterlist(data->list,(data->count+ 9))
   ENDIF
   data->list[data->count].ub92_mon_encounter_seq = me.ub92_mon_encounter_seq, data->list[data->count
   ].updt_task = me.updt_task
  WITH nocounter
 ;end select
 IF (curqual != 0)
  UPDATE  FROM ub92_mon_encounter_error mee,
    (dummyt d  WITH seq = value(data->count))
   SET mee.error_cd = 00101, mee.status_flg = "R", mee.updt_task = data->list[d.seq].updt_task,
    mee.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d)
    JOIN (mee
    WHERE mee.reporting_period=cnvtdatetime(startdatesstring)
     AND (mee.ub92_mon_encounter_seq=data->list[d.seq].ub92_mon_encounter_seq))
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM ub92_mon_encounter_error mee,
     (dummyt d  WITH seq = value(data->count))
    SET mee.error_cd = 00101, mee.reporting_period = cnvtdatetime(startdatesstring), mee.status_flg
      = "R",
     mee.ub92_mon_encounter_seq = data->list[d.seq].ub92_mon_encounter_seq, mee.updt_task = data->
     list[d.seq].updt_task, mee.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (d)
     JOIN (mee)
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
END GO
