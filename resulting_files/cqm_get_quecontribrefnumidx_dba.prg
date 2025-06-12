CREATE PROGRAM cqm_get_quecontribrefnumidx:dba
 DECLARE program_modification = vc
 SET program_modification = "Mar-01-2000"
 CALL echo(program_modification)
 CALL echorecord(request)
 RECORD reply(
   1 list[*]
     2 trigger_id = f8
     2 listener_id = f8
     2 queue_id = f8
     2 create_dt_tm = dq8
     2 contributor_id = f8
     2 contributor_refnum = vc
     2 contributor_event_dt_tm = dq8
     2 process_status_flag = i2
     2 priority = i4
     2 create_return_flag = i2
     2 create_return_text = vc
     2 trig_module_identifier = vc
     2 trig_create_start_dt_tm = dq8
     2 trig_create_end_dt_tm = dq8
     2 active_ind = i2
     2 param_list_ind = i2
     2 class = vc
     2 type = vc
     2 subtype = vc
     2 subtype_detail = vc
     2 debug_ind = i2
     2 verbosity_flag = i2
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = f8
     2 message_len = i4
   1 status_data
     2 status = c1
 )
 DECLARE count = i4
 DECLARE stat = i2
 DECLARE quetablename = vc
 DECLARE trigtablename = vc
 SET count = 0
 SET stat = 0
 SET quetablename = cnvtupper(request->quetablename)
 SET trigtablename = cnvtupper(request->trigtablename)
 IF ((request->maxqual=0))
  SET request->maxqual = 10
 ENDIF
 CALL echo(build("queTableName:",quetablename))
 CALL echo(build("trigTableName:",trigtablename))
 CALL echo(build("contributor_id:",request->contributor_id))
 CALL echo(build("Request refnum:",request->contributor_refnum))
 IF ((request->listener_id > 0))
  SELECT INTO "nl:"
   FROM (value(quetablename) q),
    (value(trigtablename) t)
   WHERE (q.contributor_id=request->contributor_id)
    AND (request->contributor_id > 0)
    AND q.contributor_refnum=patstring(request->contributor_refnum)
    AND (request->contributor_refnum != " ")
    AND q.queue_id=t.queue_id
    AND (t.listener_id=request->listener_id)
    AND (q.queue_id >= request->queue_id)
    AND q.queue_id != 0
   DETAIL
    count += 1, stat = alterlist(reply->list,count), reply->list[count].trigger_id = t.trigger_id,
    reply->list[count].listener_id = t.listener_id, reply->list[count].create_dt_tm = cnvtdatetime(t
     .create_dt_tm), reply->list[count].debug_ind = t.debug_ind,
    reply->list[count].verbosity_flag = t.verbosity_flag, reply->list[count].updt_dt_tm =
    cnvtdatetime(t.updt_dt_tm), reply->list[count].updt_task = t.updt_task,
    reply->list[count].updt_id = t.updt_id, reply->list[count].updt_applctx = t.updt_applctx, reply->
    list[count].process_status_flag = t.process_status_flag,
    reply->list[count].active_ind = t.active_ind, reply->list[count].priority = t.priority, reply->
    list[count].queue_id = q.queue_id,
    reply->list[count].contributor_id = q.contributor_id, reply->list[count].contributor_refnum = q
    .contributor_refnum, reply->list[count].contributor_event_dt_tm = cnvtdatetime(q
     .contributor_event_dt_tm),
    reply->list[count].create_return_flag = q.create_return_flag, reply->list[count].
    create_return_text = q.create_return_text, reply->list[count].trig_module_identifier = q
    .trig_module_identifier,
    reply->list[count].trig_create_start_dt_tm = cnvtdatetime(q.trig_create_start_dt_tm), reply->
    list[count].trig_create_end_dt_tm = cnvtdatetime(q.trig_create_end_dt_tm), reply->list[count].
    param_list_ind = q.param_list_ind,
    reply->list[count].class = q.class, reply->list[count].type = q.type, reply->list[count].subtype
     = q.subtype,
    reply->list[count].subtype_detail = q.subtype_detail
   WITH nocounter, maxqual(q,value(request->maxqual))
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (value(quetablename) q)
   WHERE (q.contributor_id=request->contributor_id)
    AND (request->contributor_id > 0)
    AND q.contributor_refnum=patstring(request->contributor_refnum)
    AND (request->contributor_refnum != " ")
    AND (q.queue_id >= request->queue_id)
    AND q.queue_id != 0
   DETAIL
    count += 1, stat = alterlist(reply->list,count), reply->list[count].queue_id = q.queue_id,
    reply->list[count].contributor_id = q.contributor_id, reply->list[count].contributor_refnum = q
    .contributor_refnum, reply->list[count].contributor_event_dt_tm = cnvtdatetime(q
     .contributor_event_dt_tm),
    reply->list[count].create_return_flag = q.create_return_flag, reply->list[count].
    create_return_text = q.create_return_text, reply->list[count].trig_module_identifier = q
    .trig_module_identifier,
    reply->list[count].trig_create_start_dt_tm = cnvtdatetime(q.trig_create_start_dt_tm), reply->
    list[count].trig_create_end_dt_tm = cnvtdatetime(q.trig_create_end_dt_tm), reply->list[count].
    param_list_ind = q.param_list_ind,
    reply->list[count].class = q.class, reply->list[count].type = q.type, reply->list[count].subtype
     = q.subtype,
    reply->list[count].subtype_detail = q.subtype_detail
   WITH nocounter, maxqual(q,value(request->maxqual))
  ;end select
 ENDIF
 CALL echo(build("count:",count))
 IF (count > 0)
  CALL echo(build("queue_id:",reply->list[1].queue_id))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
