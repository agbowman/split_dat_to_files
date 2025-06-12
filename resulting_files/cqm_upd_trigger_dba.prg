CREATE PROGRAM cqm_upd_trigger:dba
 DECLARE program_modification = vc
 SET program_modification = "MAR-14-2001"
 CALL echo(program_modification)
 CALL echorecord(request)
 RECORD reply(
   1 status_data
     2 status = vc
 )
 DECLARE tablename = vc
 DECLARE date1 = f8
 DECLARE date2 = f8
 DECLARE date3 = f8
 DECLARE date4 = f8
 DECLARE date5 = f8
 DECLARE time1 = c9 WITH public, noconstant(fillstring(9," "))
 SET tablename = cnvtupper(request->tablename)
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
 UPDATE  FROM (value(tablename) c)
  SET c.trigger_id = request->trigger_id, c.queue_id = request->queue_id, c.listener_id = request->
   listener_id,
   c.process_start_dt_tm = cnvtdatetime(date2), c.process_stop_dt_tm = cnvtdatetime(date3), c
   .schedule_dt_tm = cnvtdatetime(date4),
   c.priority = request->priority, c.active_ind = request->active_ind, c.number_of_retries = request
   ->number_of_retries,
   c.last_retry_dt_tm = cnvtdatetime(date5), c.process_status_flag = request->process_status_flag, c
   .trigger_status_text = cnvtupper(request->trigger_status_text),
   c.completion_sequence_id = request->completion_sequence_id, c.l_r_process_status_flag = request->
   l_r_process_status_flag, c.l_r_trigger_status_text = cnvtupper(request->l_r_trigger_status_text),
   c.debug_ind = request->debug_ind, c.verbosity_flag = request->verbosity_flag, c.updt_dt_tm =
   cnvtdatetime(sysdate),
   c.updt_task = request->updt_task, c.updt_id = request->updt_id, c.updt_cnt = (c.updt_cnt+ 1),
   c.updt_applctx = request->updt_applctx
  WHERE (c.trigger_id=request->trigger_id)
  WITH nocounter
 ;end update
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  CALL echo(build("rows updated:",curqual))
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
