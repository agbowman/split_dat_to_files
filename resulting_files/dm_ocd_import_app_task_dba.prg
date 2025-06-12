CREATE PROGRAM dm_ocd_import_app_task:dba
 FREE SET status
 RECORD status(
   1 qual[*]
     2 exist = i1
 )
 SET stat = alterlist(status->qual,atr->atr_count)
 CALL echo("Importing Application-Task relations into clinical tables...")
 SELECT INTO "nl:"
  at.task_number
  FROM application_task_r at,
   (dummyt d  WITH seq = value(atr->atr_count))
  PLAN (d)
   JOIN (at
   WHERE (at.application_number=atr->atr_list[d.seq].application_number)
    AND (at.task_number=atr->atr_list[d.seq].task_number))
  DETAIL
   status->qual[d.seq].exist = 1
  WITH nocounter
 ;end select
 CALL echo("  Inserting new Application-Task relations into clinical tables...")
 INSERT  FROM application_task_r at,
   (dummyt d  WITH seq = value(atr->atr_count))
  SET at.seq = 1, at.application_number = atr->atr_list[d.seq].application_number, at.task_number =
   atr->atr_list[d.seq].task_number,
   at.updt_dt_tm = cnvtdatetime(curdate,curtime3), at.updt_id = 0.0, at.updt_task = reqinfo->
   updt_task,
   at.updt_cnt = 0, at.updt_applctx = 0
  PLAN (d
   WHERE (status->qual[d.seq].exist=0)
    AND (atr->atr_list[d.seq].deleted_ind != 1))
   JOIN (at)
  WITH nocounter, status(status->qual)
 ;end insert
 COMMIT
END GO
