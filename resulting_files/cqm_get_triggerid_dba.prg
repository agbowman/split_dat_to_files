CREATE PROGRAM cqm_get_triggerid:dba
 DECLARE program_modification = vc
 SET program_modification = "MAR-02-2000"
 CALL echo(program_modification)
 CALL echorecord(request)
 RECORD reply(
   1 list[*]
     2 trigger_id = f8
     2 queue_id = f8
     2 listener_id = f8
     2 create_dt_tm = dq8
     2 process_start_dt_tm = dq8
     2 process_stop_dt_tm = dq8
     2 schedule_dt_tm = dq8
     2 priority = i4
     2 active_ind = i2
     2 number_of_retries = i4
     2 last_retry_dt_tm = dq8
     2 process_status_flag = i2
     2 trigger_status_text = vc
     2 completion_sequence_id = f8
     2 l_r_process_status_flag = i2
     2 l_r_trigger_status_text = vc
     2 debug_ind = i2
     2 verbosity_flag = i2
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = f8
   1 status_data
     2 status = c1
 )
 DECLARE count = i4
 DECLARE stat = i2
 DECLARE tablename = vc
 SET count = 0
 SET stat = 0
 SET tablename = cnvtupper(request->tablename)
 CALL echo(build("tablename:",tablename))
 CALL echo(build("trigger_id:",request->trigger_id))
 SELECT INTO "nl:"
  FROM (value(tablename) c)
  WHERE (c.trigger_id=request->trigger_id)
  DETAIL
   count += 1, stat = alterlist(reply->list,count), reply->list[count].trigger_id = c.trigger_id,
   reply->list[count].queue_id = c.queue_id, reply->list[count].listener_id = c.listener_id, reply->
   list[count].create_dt_tm = cnvtdatetimeutc(c.create_dt_tm,2),
   reply->list[count].process_start_dt_tm = cnvtdatetimeutc(c.process_start_dt_tm,2), reply->list[
   count].schedule_dt_tm = cnvtdatetimeutc(c.schedule_dt_tm,2), reply->list[count].priority = c
   .priority,
   reply->list[count].active_ind = c.active_ind, reply->list[count].number_of_retries = c
   .number_of_retries, reply->list[count].last_retry_dt_tm = cnvtdatetimeutc(c.last_retry_dt_tm,2),
   reply->list[count].process_status_flag = c.process_status_flag, reply->list[count].
   trigger_status_text = c.trigger_status_text, reply->list[count].completion_sequence_id = c
   .completion_sequence_id,
   reply->list[count].l_r_process_status_flag = c.l_r_process_status_flag, reply->list[count].
   l_r_trigger_status_text = c.l_r_trigger_status_text, reply->list[count].debug_ind = c.debug_ind,
   reply->list[count].verbosity_flag = c.verbosity_flag, reply->list[count].updt_dt_tm =
   cnvtdatetimeutc(c.updt_dt_tm,2), reply->list[count].updt_task = c.updt_task,
   reply->list[count].updt_id = c.updt_id, reply->list[count].updt_applctx = c.updt_applctx
  WITH nocounter
 ;end select
 CALL echo(build("count:",count))
 IF (count > 0)
  CALL echo(build("trigger_id:",reply->list[1].trigger_id))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
