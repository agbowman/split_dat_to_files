CREATE PROGRAM cqm_get_queueid:dba
 DECLARE program_modification = vc
 SET program_modification = "Jun-15-2000"
 CALL echo(program_modification)
 RECORD reply(
   1 list[*]
     2 queue_id = f8
     2 create_dt_tm = dq8
     2 contributor_id = f8
     2 contributor_refnum = vc
     2 contributor_event_dt_tm = dq8
     2 process_status_flag = i2
     2 priority = i4
     2 create_return_flag = i2
     2 create_return_text = vc
     2 trig_module_identifier = c16
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
     2 message_len = i4
     2 message = gvc
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
 DECLARE renlen = i4
 DECLARE offset = i4
 DECLARE msg_buf = c32000
 SET count = 0
 SET stat = 0
 IF ((request->maxqual=0))
  SET request->maxqual = 10
 ENDIF
 SET tablename = cnvtupper(request->tablename)
 CALL echo(build("tablename:",tablename))
 CALL echo(build("queue_id:",request->queue_id))
 SELECT INTO "nl:"
  FROM (value(tablename) c)
  WHERE (c.queue_id=request->queue_id)
  HEAD REPORT
   retlen = 0, offset = 0
  DETAIL
   count += 1, stat = alterlist(reply->list,count), retlen = 1,
   reply->list[count].queue_id = c.queue_id, reply->list[count].create_dt_tm = cnvtdatetimeutc(c
    .create_dt_tm,2), reply->list[count].contributor_id = c.contributor_id,
   reply->list[count].contributor_refnum = c.contributor_refnum, reply->list[count].
   contributor_event_dt_tm = cnvtdatetimeutc(c.contributor_event_dt_tm,2), reply->list[count].
   process_status_flag = c.process_status_flag,
   reply->list[count].priority = c.priority, reply->list[count].create_return_flag = c
   .create_return_flag, reply->list[count].create_return_text = c.create_return_text,
   reply->list[count].trig_module_identifier = c.trig_module_identifier, reply->list[count].
   trig_create_start_dt_tm = cnvtdatetimeutc(c.trig_create_start_dt_tm,2), reply->list[count].
   trig_create_end_dt_tm = cnvtdatetimeutc(c.trig_create_end_dt_tm,2),
   reply->list[count].active_ind = c.active_ind, reply->list[count].param_list_ind = c.param_list_ind,
   reply->list[count].class = c.class,
   reply->list[count].type = c.type, reply->list[count].subtype = c.subtype, reply->list[count].
   subtype_detail = c.subtype_detail,
   reply->list[count].debug_ind = c.debug_ind, reply->list[count].verbosity_flag = c.verbosity_flag,
   reply->list[count].message_len = c.message_len
   IF (c.message_len > size(c.message))
    offset = 0, retlen = 1
    WHILE (retlen > 0)
      retlen = blobget(msg_buf,offset,c.message)
      IF (retlen > 0)
       IF (retlen=size(msg_buf))
        reply->list[count].message = notrim(concat(reply->list[count].message,msg_buf))
       ELSE
        reply->list[count].message = notrim(concat(reply->list[count].message,substring(1,retlen,
           msg_buf)))
       ENDIF
      ENDIF
      offset += retlen
    ENDWHILE
   ELSE
    offset = 0, retlen = 1, retlen = blobget(msg_buf,offset,c.message),
    reply->list[count].message = notrim(substring(1,retlen,msg_buf))
   ENDIF
   CALL echo(build("message size=",size(reply->list[count].message),",messagelen=",c.message_len)),
   CALL echo(substring(1,100,reply->list[count].message)), reply->list[count].updt_dt_tm =
   cnvtdatetimeutc(c.updt_dt_tm,2),
   reply->list[count].updt_task = c.updt_task, reply->list[count].updt_id = c.updt_id, reply->list[
   count].updt_applctx = c.updt_applctx
  WITH nocounter, rdbarrayfetch = 1, maxqual(c,value(request->maxqual))
 ;end select
 CALL echo(build("count:",count))
 IF (count > 0)
  CALL echo(build("queue_id:",reply->list[1].queue_id))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
