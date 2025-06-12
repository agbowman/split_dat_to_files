CREATE PROGRAM cqm_upd_queue:dba
 DECLARE program_modification = vc
 SET program_modification = "Mar-15-2001"
 CALL echo(program_modification)
 CALL echorecord(request)
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE tablename = vc
 DECLARE date1 = f8
 DECLARE date2 = f8
 DECLARE date3 = f8
 DECLARE date4 = f8
 DECLARE time1 = c9 WITH public, noconstant(fillstring(9," "))
 DECLARE pro_not_empty = i2
 DECLARE pro_empty = i2
 SET pro_not_empty = 0
 SET pro_empty = - (1)
 SET tablename = cnvtupper(request->tablename)
 SET time1 = concat(" ",substring(9,2,request->contributor_event_dt_tm),":",substring(11,2,request->
   contributor_event_dt_tm),":",
  substring(13,2,request->contributor_event_dt_tm))
 SET date2 = cnvtdatetime(concat(format(cnvtdate2(substring(1,8,request->contributor_event_dt_tm),
     "YYYYMMDD"),"DD-MMM-YYYY;;q"),time1))
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
 IF (size(request->message)=0)
  SET request->indqueuemessage = pro_empty
 ENDIF
 UPDATE  FROM (value(tablename) c)
  SET c.contributor_id =
   IF ((request->indqueuecontributorid=pro_not_empty)) request->contributor_id
   ELSE c.contributor_id
   ENDIF
   , c.contributor_refnum =
   IF ((request->indqueuecontributorrefnum=pro_not_empty)) request->contributor_refnum
   ELSE c.contributor_refnum
   ENDIF
   , c.contributor_event_dt_tm =
   IF ((request->indqueuecontributoreventdttm=pro_not_empty)) cnvtdatetime(date2)
   ELSE c.contributor_event_dt_tm
   ENDIF
   ,
   c.process_status_flag =
   IF ((request->indqueueprocessstatusflag=pro_not_empty)) request->process_status_flag
   ELSE c.process_status_flag
   ENDIF
   , c.priority =
   IF ((request->indqueuepriority=pro_not_empty)) request->priority
   ELSE c.priority
   ENDIF
   , c.create_return_flag =
   IF ((request->indqueuecreatereturnflag=pro_not_empty)) request->create_return_flag
   ELSE c.create_return_flag
   ENDIF
   ,
   c.create_return_text =
   IF ((request->indqueuecreatereturntext=pro_not_empty)) cnvtupper(request->create_return_text)
   ELSE c.create_return_text
   ENDIF
   , c.trig_module_identifier = cnvtupper(request->trig_module_identifier), c.trig_create_start_dt_tm
    =
   IF ((request->indqueuetriggercreatestartdttm=pro_not_empty)) cnvtdatetime(date3)
   ELSE c.trig_create_start_dt_tm
   ENDIF
   ,
   c.trig_create_end_dt_tm =
   IF ((request->indqueuetriggercreateenddttm=pro_not_empty)) cnvtdatetime(date4)
   ELSE c.trig_create_end_dt_tm
   ENDIF
   , c.active_ind = request->active_ind, c.param_list_ind = request->param_list_ind,
   c.class = cnvtupper(request->class), c.type = cnvtupper(request->type), c.subtype = cnvtupper(
    request->subtype),
   c.subtype_detail = cnvtupper(request->subtype_detail), c.debug_ind = request->debug_ind, c
   .verbosity_flag = request->verbosity_flag,
   c.message_len =
   IF ((request->indqueuemessagelen=pro_not_empty)) request->message_len
   ELSE c.message_len
   ENDIF
   , c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = request->updt_id,
   c.updt_task = request->updt_task, c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = request->
   updt_applctx
  WHERE (c.queue_id=request->queue_id)
  WITH nocounter
 ;end update
 IF ((request->indqueuemessage=pro_not_empty)
  AND size(request->message) > 0)
  UPDATE  FROM (value(tablename) c)
   SET c.message = request->message
   WHERE (c.queue_id=request->queue_id)
   WITH notrim, nocounter
  ;end update
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo(build("Rows Updated:",curqual))
END GO
