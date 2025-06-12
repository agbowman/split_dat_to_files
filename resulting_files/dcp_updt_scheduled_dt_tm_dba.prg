CREATE PROGRAM dcp_updt_scheduled_dt_tm:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 RECORD scheduledtasksrec(
   1 task_list[*]
     2 task_id = f8
     2 scheduled_dt_tm = dq8
     2 task_status_cd = f8
 )
 DECLARE taskcount = i4 WITH noconstant(0)
 DECLARE task_class_scheduled = f8 WITH noconstant(0.0)
 DECLARE task_status_pending = f8 WITH noconstant(0.0)
 DECLARE task_type_endorse = f8 WITH noconstant(0.0)
 DECLARE task_type_phonemsg = f8 WITH noconstant(0.0)
 DECLARE task_type_saveddoc = f8 WITH noconstant(0.0)
 DECLARE task_type_consult = f8 WITH noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set IN (79, 6025, 6026)
    AND cv.cdf_meaning IN ("PENDING", "SCH", "ENDORSE", "PHONE MSG", "SAVED DOC",
   "ORDER"))
  DETAIL
   CASE (cv.cdf_meaning)
    OF "PENDING":
     task_status_pending = cv.code_value
    OF "SCH":
     task_class_scheduled = cv.code_value
    OF "ENDORSE":
     task_type_endorse = cv.code_value
    OF "PHONE MSG":
     task_type_phonemsg = cv.code_value
    OF "SAVED DOC":
     task_type_saveddoc = cv.code_value
    OF "ORDER":
     task_type_consult = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (task_class_scheduled=0)
  CALL echo("Failed to load task status PENDING")
  GO TO exit_script
 ENDIF
 IF (task_status_pending=0)
  CALL echo("Failed to load task status PENDING")
  GO TO exit_script
 ENDIF
 IF (task_type_endorse=0)
  CALL echo("Failed to load task type ENDORSE")
  GO TO exit_script
 ENDIF
 IF (task_type_phonemsg=0)
  CALL echo("Failed to load task type PHONE MSG")
  GO TO exit_script
 ENDIF
 IF (task_type_saveddoc=0)
  CALL echo("Failed to load task type SAVED DOC")
  GO TO exit_script
 ENDIF
 IF (task_type_consult=0)
  CALL echo("Failed to load task type CONSULT")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM task_activity ta
  PLAN (ta
   WHERE ta.task_dt_tm > datetimeadd(cnvtdatetime(curdate,curtime3),- (3))
    AND  NOT (ta.task_type_cd IN (task_type_endorse, task_type_phonemsg, task_type_saveddoc,
   task_type_consult))
    AND ta.task_class_cd=task_class_scheduled
    AND ta.order_id > 0
    AND ta.scheduled_dt_tm=null)
  HEAD REPORT
   taskcount = 0
  DETAIL
   taskcount = (taskcount+ 1)
   IF (taskcount > size(scheduledtasksrec->task_list,5))
    stat = alterlist(scheduledtasksrec->task_list,(taskcount+ 100))
   ENDIF
   scheduledtasksrec->task_list[taskcount].task_id = ta.task_id, scheduledtasksrec->task_list[
   taskcount].scheduled_dt_tm = ta.task_dt_tm, scheduledtasksrec->task_list[taskcount].task_status_cd
    = ta.task_status_cd
  FOOT REPORT
   stat = alterlist(scheduledtasksrec->task_list,taskcount)
  WITH nocounter
 ;end select
 IF (taskcount=0)
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS - No tasks to update"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(taskcount)),
   task_action tac
  PLAN (d)
   JOIN (tac
   WHERE (tac.task_id=scheduledtasksrec->task_list[d.seq].task_id)
    AND (scheduledtasksrec->task_list[d.seq].task_status_cd != task_status_pending)
    AND tac.task_dt_tm != null)
  ORDER BY tac.task_id, tac.updt_dt_tm DESC
  HEAD tac.task_id
   scheduledtasksrec->task_list[d.seq].scheduled_dt_tm = tac.task_dt_tm
  DETAIL
   donothing = 0
  FOOT  tac.task_id
   donothing = 0
  WITH nocounter
 ;end select
 DECLARE curqualtotal = i4 WITH noconstant(0)
 DECLARE commitpass = i4 WITH noconstant(1)
 DECLARE maxcommit = i4 WITH constant(5000)
 DECLARE numberofcommits = i4 WITH constant(ceil((cnvtreal(taskcount)/ cnvtreal(maxcommit))))
 DECLARE startindex = i4 WITH noconstant(0)
 DECLARE endindex = i4 WITH noconstant(0)
 FOR (commitpass = 1 TO numberofcommits)
   SET startindex = (endindex+ 1)
   IF (commitpass=numberofcommits)
    SET endindex = taskcount
   ELSE
    SET endindex = (maxcommit * commitpass)
   ENDIF
   UPDATE  FROM task_activity ta,
     (dummyt d  WITH seq = value(taskcount))
    SET ta.scheduled_dt_tm = cnvtdatetime(scheduledtasksrec->task_list[d.seq].scheduled_dt_tm), ta
     .updt_applctx = 0, ta.updt_cnt = (ta.updt_cnt+ 1),
     ta.updt_dt_tm = cnvtdatetime(curdate,curtime3), ta.updt_id = 0, ta.updt_task = 0
    PLAN (d
     WHERE d.seq >= startindex
      AND d.seq <= endindex)
     JOIN (ta
     WHERE (ta.task_id=scheduledtasksrec->task_list[d.seq].task_id))
    WITH nocounter
   ;end update
   SET curqualtotal = (curqualtotal+ curqual)
   COMMIT
 ENDFOR
 DECLARE errmsg = c132
 SET errmsg = fillstring(132," ")
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAILURE - Errors were encountered while updating the ",
   "task_activity table with its scheduled_dt_tm.")
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = concat("SUCCESS - All scheduled tasks on the task_activity table were ",
   "successfully updated with their scheduled_dt_tm.")
 ENDIF
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echo("")
  CALL echo("*******************************************************************************")
  CALL echo(readme_data->message)
  CALL echo("*******************************************************************************")
  CALL echo("")
 ENDIF
END GO
