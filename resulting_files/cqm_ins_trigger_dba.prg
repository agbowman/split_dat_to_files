CREATE PROGRAM cqm_ins_trigger:dba
 DECLARE program_modification = vc
 SET program_modification = "Feb-18-2010"
 CALL echo(program_modification)
 CALL echorecord(request)
 IF (validate(reply->trigger_id)=0)
  RECORD reply(
    1 trigger_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE tablename = vc
 DECLARE date1 = f8
 DECLARE date2 = f8
 DECLARE date3 = f8
 DECLARE date4 = f8
 DECLARE date5 = f8
 DECLARE dtimestamp = f8 WITH protect, noconstant(0.0)
 SET dtimestamp = cnvtdatetime(sysdate)
 DECLARE time1 = c9 WITH public, noconstant(fillstring(9," "))
 IF ((request->trigger_id=0))
  SELECT INTO "nl:"
   trigid = seq(cqm_trigger_id_seq,nextval)
   FROM dual
   DETAIL
    request->trigger_id = trigid
   WITH nocounter
  ;end select
 ENDIF
 SET reply->trigger_id = request->trigger_id
 SET tablename = cnvtupper(request->tablename)
 SET time1 = concat(" ",substring(9,2,request->create_dt_tm),":",substring(11,2,request->create_dt_tm
   ),":",
  substring(13,2,request->create_dt_tm))
 SET date1 = cnvtdatetime(concat(format(cnvtdate2(substring(1,8,request->create_dt_tm),"YYYYMMDD"),
    "DD-MMM-YYYY;;q"),time1))
 SET time1 = concat(" ",substring(9,2,request->process_start_dt_tm),":",substring(11,2,request->
   process_start_dt_tm),":",
  substring(13,2,request->process_start_dt_tm))
 SET date2 = cnvtdatetime(concat(format(cnvtdate2(substring(1,8,request->process_start_dt_tm),
     "YYYYMMDD"),"DD-MMM-YYYY;;q"),time1))
 SET time1 = concat(" ",substring(9,2,request->process_stop_dt_tm),":",substring(11,2,request->
   process_stop_dt_tm),":",
  substring(13,2,request->process_stop_dt_tm))
 SET date3 = cnvtdatetime(concat(format(cnvtdate2(substring(1,8,request->process_stop_dt_tm),
     "YYYYMMDD"),"DD-MMM-YYYY;;q"),time1))
 SET time1 = concat(" ",substring(9,2,request->schedule_dt_tm),":",substring(11,2,request->
   schedule_dt_tm),":",
  substring(13,2,request->schedule_dt_tm))
 SET date4 = cnvtdatetime(concat(format(cnvtdate2(substring(1,8,request->schedule_dt_tm),"YYYYMMDD"),
    "DD-MMM-YYYY;;q"),time1))
 SET time1 = concat(" ",substring(9,2,request->last_retry_dt_tm),":",substring(11,2,request->
   last_retry_dt_tm),":",
  substring(13,2,request->last_retry_dt_tm))
 SET date5 = cnvtdatetime(concat(format(cnvtdate2(substring(1,8,request->last_retry_dt_tm),"YYYYMMDD"
     ),"DD-MMM-YYYY;;q"),time1))
 IF (((tablename="CQM_FSIESO_TR_1") OR (tablename="CQM_OENINTERFACE_TR_1")) )
  INSERT  FROM (value(tablename) c)
   SET c.trigger_id = request->trigger_id, c.queue_id = request->queue_id, c.listener_id = request->
    listener_id,
    c.create_dt_tm = cnvtdatetime(date1), c.process_start_dt_tm = cnvtdatetime(date2), c
    .process_stop_dt_tm = cnvtdatetime(date3),
    c.schedule_dt_tm = cnvtdatetime(date4), c.priority = request->priority, c.active_ind = request->
    active_ind,
    c.number_of_retries = request->number_of_retries, c.last_retry_dt_tm = cnvtdatetime(date5), c
    .process_status_flag = request->process_status_flag,
    c.trigger_status_text = cnvtupper(request->trigger_status_text), c.completion_sequence_id =
    request->completion_sequence_id, c.l_r_process_status_flag = request->l_r_process_status_flag,
    c.l_r_trigger_status_text = cnvtupper(request->l_r_trigger_status_text), c.debug_ind = request->
    debug_ind, c.verbosity_flag = request->verbosity_flag,
    c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = request->updt_task, c.updt_cnt = 0,
    c.updt_id = request->updt_id, c.updt_applctx = request->updt_applctx, c.message_sequence =
    dtimestamp
   WITH nocounter
  ;end insert
 ELSE
  INSERT  FROM (value(tablename) c)
   SET c.trigger_id = request->trigger_id, c.queue_id = request->queue_id, c.listener_id = request->
    listener_id,
    c.create_dt_tm = cnvtdatetime(date1), c.process_start_dt_tm = cnvtdatetime(date2), c
    .process_stop_dt_tm = cnvtdatetime(date3),
    c.schedule_dt_tm = cnvtdatetime(date4), c.priority = request->priority, c.active_ind = request->
    active_ind,
    c.number_of_retries = request->number_of_retries, c.last_retry_dt_tm = cnvtdatetime(date5), c
    .process_status_flag = request->process_status_flag,
    c.trigger_status_text = cnvtupper(request->trigger_status_text), c.completion_sequence_id =
    request->completion_sequence_id, c.l_r_process_status_flag = request->l_r_process_status_flag,
    c.l_r_trigger_status_text = cnvtupper(request->l_r_trigger_status_text), c.debug_ind = request->
    debug_ind, c.verbosity_flag = request->verbosity_flag,
    c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = request->updt_task, c.updt_cnt = 0,
    c.updt_id = request->updt_id, c.updt_applctx = request->updt_applctx
   WITH nocounter
  ;end insert
 ENDIF
 CALL echo(build("rows inserted:",curqual))
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
