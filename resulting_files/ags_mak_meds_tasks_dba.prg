CREATE PROGRAM ags_mak_meds_tasks:dba
 CALL echo("***")
 CALL echo("***   BEG AGS_MAK_MEDS_TASKS")
 CALL echo("***")
 DECLARE min_batch_id = f8 WITH public, noconstant(0.0)
 DECLARE max_batch_id = f8 WITH public, noconstant(0.0)
 DECLARE temp_batch_id = f8 WITH public, noconstant(0.0)
 DECLARE batch_size = i4 WITH public, constant(5000)
 DECLARE max_task_size = i4 WITH public, noconstant(1000000)
 IF ((data_info->task_size > 0))
  SET max_task_size = data_info->task_size
 ENDIF
 FREE RECORD item
 RECORD item(
   1 qual_knt = i4
   1 qual[*]
     2 ags_task_id = f8
     2 ags_job_id = f8
     2 task_type = c30
     2 batch_program = vc
     2 batch_start_id = f8
     2 batch_end_id = f8
     2 batch_size = i4
 )
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "BEG >> AGS_MAK_MEDS_TASKS"
 CALL echo("***")
 CALL echo("***   Find MEDS Batch Id Values")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  little_id = min(o.ags_meds_data_id), big_id = max(o.ags_meds_data_id)
  FROM ags_meds_data o
  PLAN (o
   WHERE (o.ags_job_id=data_info->ags_job_id)
    AND o.status="LOADING")
  FOOT REPORT
   min_batch_id = little_id, max_batch_id = big_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "GET BATCH_ID VALUES"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("GET MEDS BATCH_ID VALUES :: Select Error :: ",trim(
    serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build("***   AGS_MEDS_DATA min_batch_id :",min_batch_id))
 CALL echo(build("***   AGS_MEDS_DATA max_batch_id :",max_batch_id))
 CALL echo("***")
 CALL echo("***")
 CALL echo("***   Create MEDS Tasks")
 CALL echo("***")
 WHILE (min_batch_id <= max_batch_id
  AND min_batch_id >= 1)
   IF (((min_batch_id+ max_task_size) < max_batch_id))
    SET temp_batch_id = (min_batch_id+ max_task_size)
   ELSE
    SET temp_batch_id = max_batch_id
   ENDIF
   SET item->qual_knt = (item->qual_knt+ 1)
   SET stat = alterlist(item->qual,item->qual_knt)
   SET item->qual[item->qual_knt].ags_job_id = data_info->ags_job_id
   SET item->qual[item->qual_knt].task_type = "MEDS"
   SET item->qual[item->qual_knt].batch_start_id = min_batch_id
   SET item->qual[item->qual_knt].batch_end_id = temp_batch_id
   SET item->qual[item->qual_knt].batch_size = batch_size
   SET item->qual[item->qual_knt].batch_program = "ags_load_meds"
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    num = seq(gs_seq,nextval)
    FROM dual
    DETAIL
     item->qual[item->qual_knt].ags_task_id = cnvtreal(num)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = gen_nbr_error
    SET table_name = "GET NEW AGS_TASK_ID"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("GET NEW AGS_TASK_ID :: Script Failure :: ",trim(
      serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   SET min_batch_id = (temp_batch_id+ 1)
 ENDWHILE
 CALL echorecord(item)
 IF ((item->qual_knt < 1))
  SET failed = input_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "No MEDS tasks found"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Insert Tasks")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 INSERT  FROM ags_task t,
   (dummyt d  WITH seq = value(item->qual_knt))
  SET t.ags_task_id = item->qual[d.seq].ags_task_id, t.ags_job_id = item->qual[d.seq].ags_job_id, t
   .task_type = item->qual[d.seq].task_type,
   t.batch_program = item->qual[d.seq].batch_program, t.batch_start_id = item->qual[d.seq].
   batch_start_id, t.batch_end_id = item->qual[d.seq].batch_end_id,
   t.batch_size = item->qual[d.seq].batch_size, t.status = "LOADING", t.status_dt_tm = cnvtdatetime(
    curdate,curtime3)
  PLAN (d
   WHERE d.seq > 0)
   JOIN (t
   WHERE 1=1)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = insert_error
  SET table_name = "AGS_TASK"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("INSERT AGS_TASK ITEMS :: Insert Error :: ",trim(serrmsg
    ))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 COMMIT
 CALL echo("***")
 CALL echo("***   Update MEDS Data to WAITING")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_meds_data o
  SET o.status = "WAITING", o.status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (o
   WHERE (o.ags_job_id=data_info->ags_job_id)
    AND o.status="LOADING")
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET failed = update_error
  SET table_name = "AGS_MEDS_DATA"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("UPDATE AGS_MEDS_DATA ITEMS :: Update Error :: ",trim(
    serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 COMMIT
#exit_script
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> AGS_MAK_MEDS_TASKS"
 CALL echo("***")
 CALL echo("***   END AGS_MAK_MEDS_TASKS")
 CALL echo("***")
 SET script_ver = "002 01/20/06"
END GO
