CREATE PROGRAM cqm_insert_queue:dba
 DECLARE program_modification = vc
 SET program_modification = "SEPT-04-2015"
 CALL echo(program_modification)
 CALL echorecord(request)
 RECORD reply(
   1 queue_id = f8
   1 status_data
     2 status = c1
 )
 DECLARE tablename = vc
 DECLARE cdate1 = f8
 DECLARE cdate2 = f8
 DECLARE cdate3 = f8
 DECLARE cdate4 = f8
 DECLARE date1 = f8
 DECLARE date2 = f8
 DECLARE date3 = f8
 DECLARE date4 = f8
 DECLARE dtimestamp = f8 WITH protect, noconstant(0.0)
 DECLARE time1 = c9 WITH public, noconstant(fillstring(9," "))
 SET tablename = cnvtupper(request->tablename)
 SET dtimestamp = cnvtdatetime(sysdate)
 SET time1 = concat(" ",substring(9,2,request->create_dt_tm),":",substring(11,2,request->create_dt_tm
   ),":",
  substring(13,2,request->create_dt_tm))
 SET date1 = cnvtdatetime(concat(format(cnvtdate2(substring(1,8,request->create_dt_tm),"YYYYMMDD"),
    "DD-MMM-YYYY;;q"),time1))
 SET time1 = concat(" ",substring(9,2,request->contributor_event_dt_tm),":",substring(11,2,request->
   contributor_event_dt_tm),":",
  substring(13,2,request->contributor_event_dt_tm))
 SET date2 = cnvtdatetimeutc(concat(format(cnvtdate2(substring(1,8,request->contributor_event_dt_tm),
     "YYYYMMDD"),"DD-MMM-YYYY;;q"),time1),0)
 SET time1 = concat(" ",substring(9,2,request->trig_create_start_dt_tm),":",substring(11,2,request->
   trig_create_start_dt_tm),":",
  substring(13,2,request->trig_create_start_dt_tm))
 SET date3 = cnvtdatetime(concat(format(cnvtdate2(substring(1,8,request->trig_create_start_dt_tm),
     "YYYYMMDD"),"DD-MMM-YYYY;;q"),time1))
 SET time1 = concat(" ",substring(9,2,request->trig_create_end_dt_tm),":",substring(11,2,request->
   trig_create_end_dt_tm),":",
  substring(13,2,request->trig_create_end_dt_tm))
 SET date4 = cnvtdatetime(concat(format(cnvtdate2(substring(1,8,request->trig_create_end_dt_tm),
     "YYYYMMDD"),"DD-MMM-YYYY;;q"),time1))
 CALL echo(build("tablename:",tablename))
 CALL echo(build("contributor_id:",request->contributor_id))
 IF ((request->queue_id=0))
  SELECT INTO "nl:"
   queid = seq(cqm_queue_id_seq,nextval)
   FROM dual
   DETAIL
    request->queue_id = queid
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("queue_id:",request->queue_id))
 SET reply->queue_id = request->queue_id
 IF (tablename="CQM_FSIESO_QUE")
  INSERT  FROM (value(tablename) c)
   SET c.queue_id = request->queue_id, c.contributor_id = request->contributor_id, c.create_dt_tm =
    cnvtdatetime(date1),
    c.contributor_refnum = trim(substring(1,48,request->contributor_refnum)), c
    .contributor_event_dt_tm = cnvtdatetime(date2), c.process_status_flag = request->
    process_status_flag,
    c.priority = request->priority, c.create_return_flag = request->create_return_flag, c
    .create_return_text = trim(cnvtupper(request->create_return_text)),
    c.trig_module_identifier = trim(cnvtupper(request->trig_module_identifier)), c
    .trig_create_start_dt_tm = cnvtdatetime(date3), c.trig_create_end_dt_tm = cnvtdatetime(date4),
    c.active_ind = request->active_ind, c.param_list_ind = request->param_list_ind, c.class = trim(
     cnvtupper(request->class)),
    c.type = trim(cnvtupper(request->type)), c.subtype = trim(cnvtupper(request->subtype)), c
    .subtype_detail = trim(cnvtupper(request->subtype_detail)),
    c.debug_ind = request->debug_ind, c.verbosity_flag = request->verbosity_flag, c.message = request
    ->message,
    c.message_len = request->message_len, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = request->
    updt_id,
    c.updt_task = request->updt_task, c.updt_cnt = 0, c.updt_applctx = request->updt_applctx,
    c.message_sequence = dtimestamp
   WITH notrim, nocounter
  ;end insert
 ELSE
  INSERT  FROM (value(tablename) c)
   SET c.queue_id = request->queue_id, c.contributor_id = request->contributor_id, c.create_dt_tm =
    cnvtdatetime(date1),
    c.contributor_refnum = trim(substring(1,48,request->contributor_refnum)), c
    .contributor_event_dt_tm = cnvtdatetime(date2), c.process_status_flag = request->
    process_status_flag,
    c.priority = request->priority, c.create_return_flag = request->create_return_flag, c
    .create_return_text = trim(cnvtupper(request->create_return_text)),
    c.trig_module_identifier = trim(cnvtupper(request->trig_module_identifier)), c
    .trig_create_start_dt_tm = cnvtdatetime(date3), c.trig_create_end_dt_tm = cnvtdatetime(date4),
    c.active_ind = request->active_ind, c.param_list_ind = request->param_list_ind, c.class = trim(
     cnvtupper(request->class)),
    c.type = trim(cnvtupper(request->type)), c.subtype = trim(cnvtupper(request->subtype)), c
    .subtype_detail = trim(cnvtupper(request->subtype_detail)),
    c.debug_ind = request->debug_ind, c.verbosity_flag = request->verbosity_flag, c.message = request
    ->message,
    c.message_len = request->message_len, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = request->
    updt_id,
    c.updt_task = request->updt_task, c.updt_cnt = 0, c.updt_applctx = request->updt_applctx
   WITH notrim, nocounter
  ;end insert
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo(build("Rows Inserted:",curqual))
END GO
