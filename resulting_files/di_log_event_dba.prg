CREATE PROGRAM di_log_event:dba
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *********  Beginning of Program DI_LOG_EVENT","  *********"),1,0)
 CALL echo("DI_LOG_EVENT. Create record structure.")
 IF ( NOT (validate(request1)))
  RECORD request1(
    1 req[*]
      2 dlg_name = c255
      2 dlg_prsnl_id = f8
      2 encntr_id = f8
      2 person_id = f8
      2 alert_text = vc
      2 override_default_ind = i2
      2 override_reason_cd = f8
      2 override_reason_text = vc
      2 trigger_catalog_id = f8
      2 trigger_entity_name = c32
      2 trigger_order_id = f8
      2 answers[*]
        3 answer_name = c255
      2 actions[*]
        3 action_name = c255
        3 parent_entity_name = c32
        3 parent_entity_id = f8
      2 event_attr[*]
        3 attr_name = c32
        3 attr_value = c255
        3 attr_id = f8
      2 modify_dlg_name = c255
      2 action_flag = i2
  )
 ENDIF
 IF (validate(reply->status_data.status,"Y")="Y"
  AND validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status = c1
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE index = i4
 IF ( NOT (( $1="")))
  CALL echo("Eks_dlg_add_log_event - First argument is not null")
  SET st = alterlist(request1->req,1)
  SET st = alterlist(request1->req[1].answers,1)
  SET st = alterlist(request1->req[1].actions,1)
  SET st = alterlist(request1->req[1].event_attr,1)
  SET request1->req[1].dlg_name =  $1
  SET request1->req[1].dlg_prsnl_id =  $2
  SET request1->req[1].encntr_id =  $3
  SET request1->req[1].person_id =  $4
  SET request1->req[1].alert_text = ""
  SET request1->req[1].override_default_ind = 0
  SET request1->req[1].override_reason_text = ""
  SET request1->req[1].override_reason_cd = 0
  SET request1->req[1].trigger_catalog_id =  $5
  SET request1->req[1].trigger_entity_name =  $6
  SET request1->req[1].trigger_order_id = 0
  SET request1->req[1].answers[1].answer_name = " "
  SET request1->req[1].actions[1].action_name =  $7
  SET request1->req[1].actions[1].parent_entity_name = "EKS_DLG_EVENT"
  SET request1->req[1].actions[1].parent_entity_id = 0
  SET request1->req[1].event_attr[1].attr_name = " "
  SET request1->req[1].event_attr[1].attr_value = " "
  SET request1->req[1].event_attr[1].attr_id = 0
  SET request1->req[1].modify_dlg_name = request1->req[1].dlg_name
  IF (validate(request1->req[1].action_flag))
   SET request1->req[1].action_flag = 0
  ENDIF
 ELSE
  CALL echo("Eks_dlg_add_log_event - First argument is null")
  IF (validate(request->req))
   DECLARE reqcount = i4
   SET reqcount = size(request->req,5)
   SET st = alterlist(request1->req,reqcount)
   FOR (index = 1 TO reqcount)
     SET request1->req[index].dlg_name = request->req[index].dlg_name
     SET request1->req[index].dlg_prsnl_id = request->req[index].dlg_prsnl_id
     SET request1->req[index].encntr_id = request->req[index].encntr_id
     SET request1->req[index].person_id = request->req[index].person_id
     SET request1->req[index].alert_text = request->req[index].alert_text
     SET request1->req[index].override_default_ind = request->req[index].override_default_ind
     SET request1->req[index].override_reason_text = request->req[index].override_reason_text
     SET request1->req[index].override_reason_cd = request->req[index].override_reason_cd
     SET request1->req[index].trigger_catalog_id = request->req[index].trigger_catalog_id
     SET request1->req[index].trigger_entity_name = request->req[index].trigger_entity_name
     SET request1->req[index].trigger_order_id = request->req[index].trigger_order_id
     SET anscount = size(request->req[index].answers,5)
     SET actcount = size(request->req[index].actions,5)
     SET evntcount = size(request->req[index].event_attr,5)
     SET st = alterlist(request1->req[index].answers,anscount)
     SET st = alterlist(request1->req[index].actions,actcount)
     SET st = alterlist(request1->req[index].event_attr,evntcount)
     FOR (i = 1 TO anscount)
       SET request1->req[index].answers[i].answer_name = request->req[index].answers[i].answer_name
     ENDFOR
     FOR (i = 1 TO actcount)
       SET request1->req[index].actions[i].action_name = request->req[index].actions[i].action_name
       SET request1->req[index].actions[i].parent_entity_name = request->req[index].actions[i].
       parent_entity_name
       SET request1->req[index].actions[i].parent_entity_id = request->req[index].actions[i].
       parent_entity_id
     ENDFOR
     FOR (i = 1 TO evntcount)
       SET request1->req[index].event_attr[i].attr_name = request->req[index].event_attr[i].attr_name
       SET request1->req[index].event_attr[i].attr_value = request->req[index].event_attr[i].
       attr_value
       SET request1->req[index].event_attr[i].attr_id = request->req[index].event_attr[i].attr_id
     ENDFOR
     IF (size(trim(request->req[index].modify_dlg_name))=0)
      SET request1->req[index].modify_dlg_name = request1->req[index].dlg_name
     ELSE
      SET request1->req[index].modify_dlg_name = request->req[index].modify_dlg_name
     ENDIF
     IF (validate(request1->req[index].action_flag)
      AND validate(request->req[index].action_flag))
      SET request1->req[index].action_flag = request->req[index].action_flag
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET reply->status = "F"
 SET errmsg = fillstring(255," ")
 SET cnt = 0
 SET tablename = fillstring(255," ")
 DECLARE event_sequence = f8
 DECLARE text_sequence = f8
 DECLARE alert_text_sequence = f8
 DECLARE event_attr_sequence = f8
 DECLARE activestatuscd = f8
 SET event_sequence = 0.0
 SET text_sequence = 0.0
 SET alert_text_sequence = 0.0
 SET event_attr_sequence = 0.0
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,activestatuscd)
 RECORD receventsequence(
   1 count = i2
   1 qual[*]
     2 event_sequence = f8
     2 text_sequence = f8
     2 override_reason_text = vc
     2 alert_text_sequence = f8
     2 alert_text = vc
     2 dlg_name = c255
     2 dlg_prsnl_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 override_default_ind = i2
     2 override_reason_cd = f8
     2 trigger_catalog_id = f8
     2 trigger_entity_name = c32
     2 trigger_order_id = f8
     2 event_attr[*]
       3 eventattrsequence = f8
       3 attr_name = c32
       3 attr_value = c255
       3 attr_id = f8
     2 modify_dlg_name = c255
     2 action_flag = i2
 )
 SET cnteventsequence = 0
 SET stat = alterlist(receventsequence->qual,size(request1->req,5))
 FOR (index = 1 TO size(request1->req,5))
   SET text_sequence = 0.0
   SET alert_text_sequence = 0.0
   SET event_sequence = 0.0
   SET event_attr_sequence = 0.0
   SELECT INTO "nl:"
    es = seq(eks_dlg_event_seq,nextval)
    FROM dual
    DETAIL
     cnteventsequence += 1, receventsequence->qual[cnteventsequence].event_sequence = es
    FOOT REPORT
     receventsequence->count = cnteventsequence
    WITH nocounter
   ;end select
   IF ((request1->req[index].override_reason_text > ""))
    SELECT INTO "nl:"
     ts = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      receventsequence->qual[index].text_sequence = ts
     WITH nocounter
    ;end select
   ENDIF
   IF ((request1->req[index].alert_text > ""))
    SELECT INTO "nl:"
     ts = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      receventsequence->qual[index].alert_text_sequence = ts
     WITH nocounter
    ;end select
   ENDIF
   SET event_attrcnt = size(request1->req[index].event_attr,5)
   SET stat = alterlist(receventsequence->qual[index].event_attr,event_attrcnt)
   FOR (i = 1 TO event_attrcnt)
     SELECT INTO "nl:"
      es = seq(eks_dlg_event_seq,nextval)
      FROM dual
      DETAIL
       receventsequence->qual[index].event_attr[i].eventattrsequence = es
      WITH nocounter
     ;end select
     SET receventsequence->qual[index].event_attr[i].attr_name = trim(request1->req[index].
      event_attr[i].attr_name)
     SET receventsequence->qual[index].event_attr[i].attr_value = trim(request1->req[index].
      event_attr[i].attr_value)
     SET receventsequence->qual[index].event_attr[i].attr_id = request1->req[index].event_attr[i].
     attr_id
   ENDFOR
   SET receventsequence->qual[index].override_reason_text = trim(request1->req[index].
    override_reason_text)
   SET receventsequence->qual[index].alert_text = trim(request1->req[index].alert_text)
   SET receventsequence->qual[index].dlg_name = trim(request1->req[index].dlg_name)
   SET receventsequence->qual[index].dlg_prsnl_id = request1->req[index].dlg_prsnl_id
   SET receventsequence->qual[index].encntr_id = request1->req[index].encntr_id
   SET receventsequence->qual[index].person_id = request1->req[index].person_id
   SET receventsequence->qual[index].override_default_ind = request1->req[index].override_default_ind
   SET receventsequence->qual[index].override_reason_cd = request1->req[index].override_reason_cd
   SET receventsequence->qual[index].trigger_catalog_id = request1->req[index].trigger_catalog_id
   SET receventsequence->qual[index].trigger_entity_name = request1->req[index].trigger_entity_name
   SET receventsequence->qual[index].trigger_order_id = request1->req[index].trigger_order_id
   SET receventsequence->qual[index].modify_dlg_name = request1->req[index].modify_dlg_name
   IF (validate(request1->req[index].action_flag))
    SET receventsequence->qual[index].action_flag = request1->req[index].action_flag
   ELSE
    SET receventsequence->qual[index].action_flag = 0
   ENDIF
   IF (validate(tname,"Y") != "Y"
    AND validate(tname,"Z") != "Z")
    IF (cnvtupper(trim(tname))="EKS_LOG_ACTION_A")
     SET receventsequence->qual[index].action_flag = 5
    ENDIF
   ENDIF
 ENDFOR
 CALL echo("Insert record into long_text table")
 INSERT  FROM long_text lt,
   (dummyt d1  WITH seq = value(receventsequence->count))
  SET lt.long_text_id = receventsequence->qual[d1.seq].text_sequence, lt.updt_cnt = 0, lt.updt_dt_tm
    = cnvtdatetime(sysdate),
   lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
   updt_applctx,
   lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
   cnvtdatetime(sysdate),
   lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "EKS_DLG_EVENT", lt
   .parent_entity_id = receventsequence->qual[d1.seq].event_sequence,
   lt.long_text = receventsequence->qual[d1.seq].override_reason_text
  PLAN (d1
   WHERE d1.seq > 0
    AND trim(receventsequence->qual[d1.seq].override_reason_text) > "")
   JOIN (lt)
  WITH nocounter
 ;end insert
 CALL echo("Insert alert_text into long_text table")
 INSERT  FROM long_text lt,
   (dummyt d1  WITH seq = value(receventsequence->count))
  SET lt.long_text_id = receventsequence->qual[d1.seq].alert_text_sequence, lt.updt_cnt = 0, lt
   .updt_dt_tm = cnvtdatetime(sysdate),
   lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
   updt_applctx,
   lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
   cnvtdatetime(sysdate),
   lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "EKS_DLG_EVENT", lt
   .parent_entity_id = receventsequence->qual[d1.seq].event_sequence,
   lt.long_text = receventsequence->qual[d1.seq].alert_text
  PLAN (d1
   WHERE d1.seq > 0
    AND (receventsequence->qual[d1.seq].alert_text > ""))
   JOIN (lt)
  WITH nocounter
 ;end insert
 CALL echo("Insert a record into eks_dlg_event table")
 INSERT  FROM eks_dlg_event e,
   (dummyt d1  WITH seq = value(receventsequence->count))
  SET e.dlg_event_id = receventsequence->qual[d1.seq].event_sequence, e.dlg_name = receventsequence->
   qual[d1.seq].dlg_name, e.dlg_prsnl_id = receventsequence->qual[d1.seq].dlg_prsnl_id,
   e.encntr_id = receventsequence->qual[d1.seq].encntr_id, e.person_id = receventsequence->qual[d1
   .seq].person_id, e.dlg_dt_tm = cnvtdatetime(sysdate),
   e.override_default_ind = receventsequence->qual[d1.seq].override_default_ind, e.override_reason_cd
    = receventsequence->qual[d1.seq].override_reason_cd, e.long_text_id = receventsequence->qual[d1
   .seq].text_sequence,
   e.trigger_entity_id = receventsequence->qual[d1.seq].trigger_catalog_id, e.trigger_entity_name =
   receventsequence->qual[d1.seq].trigger_entity_name, e.updt_dt_tm = cnvtdatetime(sysdate),
   e.updt_id = reqinfo->updt_id, e.updt_applctx = reqinfo->updt_applctx, e.updt_task = reqinfo->
   updt_task,
   e.trigger_order_id = receventsequence->qual[d1.seq].trigger_order_id, e.active_ind = 1, e
   .active_status_dt_tm = cnvtdatetime(sysdate),
   e.active_status_prsnl_id = reqinfo->updt_id, e.active_status_cd = activestatuscd, e
   .alert_long_text_id = receventsequence->qual[d1.seq].alert_text_sequence,
   e.modify_dlg_name = receventsequence->qual[d1.seq].modify_dlg_name, e.action_flag =
   receventsequence->qual[d1.seq].action_flag
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (e)
  WITH nocounter
 ;end insert
 IF (curqual < 1)
  SET tablename = "EKS_DLG_EVENT"
  GO TO script_err
 ENDIF
 CALL echo("Insert a record into eks_dlg_event_attr table")
 FOR (i = 1 TO receventsequence->count)
  CALL echo(concat("size: ",build(size(receventsequence->qual[i].event_attr,5))))
  IF (size(receventsequence->qual[i].event_attr,5) > 0)
   INSERT  FROM eks_dlg_event_attr attr,
     (dummyt d1  WITH seq = value(size(receventsequence->qual[i].event_attr,5)))
    SET attr.dlg_event_attr_id = receventsequence->qual[i].event_attr[d1.seq].eventattrsequence, attr
     .dlg_event_id = receventsequence->qual[i].event_sequence, attr.attr_name = trim(receventsequence
      ->qual[i].event_attr[d1.seq].attr_name),
     attr.attr_value = trim(receventsequence->qual[i].event_attr[d1.seq].attr_value), attr.active_ind
      = 1, attr.updt_dt_tm = cnvtdatetime(sysdate),
     attr.updt_id = reqinfo->updt_id, attr.updt_applctx = reqinfo->updt_applctx, attr.updt_task =
     reqinfo->updt_task,
     attr.updt_cnt = 0, attr.attr_id = receventsequence->qual[i].event_attr[d1.seq].attr_id
    PLAN (d1
     WHERE d1.seq > 0)
     JOIN (attr)
    WITH nocounter
   ;end insert
  ENDIF
 ENDFOR
#script_err
 CALL echo(concat("EKS_DLG_ADD_LOG_EVENT CURQUAL: ",build(curqual)))
 IF (curqual < 1)
  SET reply->status_data.status = "F"
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = tablename
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  SET reqinfo->commit_ind = 0
  SET errcode = error(errmsg,1)
  CALL echo(concat("EKS_DLG_ADD_LOG_EVENT failed with message: ",errmsg," while inserting into: ",
    tablename))
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo(concat("commit_ind: ",build(reqinfo->commit_ind)))
  COMMIT
 ENDIF
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *********  End of Program eks_dlg_add_log_event","  *********"),1,0)
END GO
