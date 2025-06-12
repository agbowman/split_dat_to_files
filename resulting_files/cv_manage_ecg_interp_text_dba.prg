CREATE PROGRAM cv_manage_ecg_interp_text:dba
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 interpretation_text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE cur_list_size = i4 WITH protect
 DECLARE loop_cnt = i4 WITH protect
 DECLARE new_list_size = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE nstart = i4 WITH protect
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE idx = i4 WITH protect
 DECLARE errmsg = vc WITH protect
 DECLARE errcode = i4 WITH protect
 SET cur_list_size = size(request->qual,5)
 IF (cur_list_size <= 0)
  CALL cv_log_msg(cv_info,"No items found in request")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF ((request->action=2))
  SELECT
   FROM long_text lt
   WHERE (lt.parent_entity_id=request->qual[1].interpretation_id)
    AND trim(lt.parent_entity_name)="CV_STEP"
   DETAIL
    reply->interpretation_text = lt.long_text
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  CALL echo(errcode)
  IF (errcode != 0)
   CALL cv_log_stat(cv_error,"SELECT","F","LONG_TEXT",errmsg)
   GO TO exit_script
  ENDIF
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 IF ((request->action=1))
  DELETE  FROM long_text lt,
    (dummyt d  WITH seq = value(cur_list_size))
   SET lt.seq = 1
   PLAN (d)
    JOIN (lt
    WHERE (lt.parent_entity_id=request->qual[d.seq].interpretation_id)
     AND trim(lt.parent_entity_name)="CV_STEP")
   WITH nocounter
  ;end delete
  SET errcode = error(errmsg,0)
  IF (errcode != 0)
   CALL cv_log_stat(cv_error,"DELETE","F","LONG_TEXT",errmsg)
   GO TO exit_script
  ENDIF
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 FREE RECORD tmp_interp
 RECORD tmp_interp(
   1 qual[*]
     2 interpretation_text = vc
     2 interpretation_id = f8
     2 action_ind = i2
 )
 SET stat = alterlist(tmp_interp->qual,cur_list_size)
 FOR (qual_idx = 1 TO cur_list_size)
  SET tmp_interp->qual[qual_idx].interpretation_id = request->qual[qual_idx].interpretation_id
  SET tmp_interp->qual[qual_idx].interpretation_text = request->qual[qual_idx].interpretation_text
 ENDFOR
 IF (cur_list_size > 1)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(tmp_interp->qual,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET tmp_interp->qual[idx].interpretation_id = tmp_interp->qual[cur_list_size].interpretation_id
  ENDFOR
 ENDIF
 SELECT
  IF (cur_list_size=1)
   FROM long_text lt
   WHERE trim(lt.parent_entity_name)="CV_STEP"
    AND (lt.parent_entity_id=tmp_interp->qual[1].interpretation_id)
  ELSE
  ENDIF
  INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   long_text lt
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (lt
   WHERE trim(lt.parent_entity_name)="CV_STEP"
    AND expand(idx,nstart,(nstart+ (batch_size - 1)),lt.parent_entity_id,tmp_interp->qual[idx].
    interpretation_id))
  HEAD REPORT
   num = 0
  DETAIL
   index = locateval(num,1,cur_list_size,lt.parent_entity_id,tmp_interp->qual[num].interpretation_id)
   WHILE (index != 0)
    tmp_interp->qual[index].action_ind =
    IF ((tmp_interp->qual[index].interpretation_text=lt.long_text)) 2
    ELSE 1
    ENDIF
    ,index = locateval(num,(index+ 1),cur_list_size,lt.parent_entity_id,tmp_interp->qual[num].
     interpretation_id)
   ENDWHILE
  WITH nocounter
 ;end select
 SET stat = alterlist(tmp_interp->qual,cur_list_size)
 UPDATE  FROM long_text lt,
   (dummyt d  WITH seq = value(cur_list_size))
  SET lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
   cnvtdatetime(sysdate),
   lt.active_status_prsnl_id = reqinfo->updt_id, lt.long_text = tmp_interp->qual[d.seq].
   interpretation_text, lt.updt_applctx = reqinfo->updt_applctx,
   lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->
   updt_id,
   lt.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (tmp_interp->qual[d.seq].action_ind=1))
   JOIN (lt
   WHERE (lt.parent_entity_id=tmp_interp->qual[d.seq].interpretation_id)
    AND trim(lt.parent_entity_name)="CV_STEP")
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode != 0)
  CALL cv_log_stat(cv_error,"UPDATE","F","LONG_TEXT",errmsg)
  GO TO exit_script
 ENDIF
 INSERT  FROM long_text lt,
   (dummyt d  WITH seq = value(cur_list_size))
  SET lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
   cnvtdatetime(sysdate),
   lt.active_status_prsnl_id = reqinfo->updt_id, lt.long_text = tmp_interp->qual[d.seq].
   interpretation_text, lt.long_text_id = seq(long_data_seq,nextval),
   lt.parent_entity_id = tmp_interp->qual[d.seq].interpretation_id, lt.parent_entity_name = "CV_STEP",
   lt.updt_applctx = reqinfo->updt_applctx,
   lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->updt_id,
   lt.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (tmp_interp->qual[d.seq].action_ind=0))
   JOIN (lt)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode != 0)
  CALL cv_log_stat(cv_error,"INSERT","F","LONG_TEXT",errmsg)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="Z"))
  SET reqinfo->commit_ind = 0
  CALL echo("Empty request")
 ELSEIF ((reply->status_data.status="S")
  AND (request->action=0))
  SET reqinfo->commit_ind = 1
  CALL echo("All updates and inserts succeeded")
 ELSEIF ((reply->status_data.status="S")
  AND (request->action=1))
  SET reqinfo->commit_ind = 1
  CALL echo("All deletes succeeded")
 ELSEIF ((reply->status_data.status="S")
  AND (request->action=2))
  SET reqinfo->commit_ind = 1
  CALL echo("Select succeeded")
 ELSE
  CALL echo("CV_MANAGE_ECG_INTERP_TEXT failed")
  CALL echorecord(reply)
 ENDIF
 CALL cv_log_msg_post("MOD 001 04/05/2024 AS043139")
END GO
