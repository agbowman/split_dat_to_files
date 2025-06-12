CREATE PROGRAM bhs_eks_pco_metrics:dba
 FREE RECORD t_record
 RECORD t_record(
   1 date = dq8
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
 )
 SET t_record->date = cnvtdatetime(curdate,curtime3)
 SET t_record->start_dt_tm = datetimefind(t_record->date,"D","B","B")
 SET t_record->end_dt_tm = datetimefind(t_record->date,"D","E","E")
 DECLARE eid = f8
 DECLARE pid = f8
 DECLARE userid = f8
 DECLARE on_table = i2
 SET eid = trigger_encntrid
 SET pid = trigger_personid
 SET userid = reqinfo->updt_id
 SELECT INTO "nl:"
  FROM bhs_pco_daily_statistics p
  PLAN (p
   WHERE p.encounter_id=eid
    AND p.person_id=pid
    AND p.phys_id=userid
    AND p.create_dt_tm >= cnvtdatetime(t_record->start_dt_tm)
    AND p.create_dt_tm <= cnvtdatetime(t_record->end_dt_tm))
  DETAIL
   on_table = 1
  WITH nocounter
 ;end select
 IF (on_table=0)
  INSERT  FROM bhs_pco_daily_statistics p
   SET p.encounter_id = eid, p.person_id = pid, p.phys_id = userid
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
 SET retval = 100
END GO
