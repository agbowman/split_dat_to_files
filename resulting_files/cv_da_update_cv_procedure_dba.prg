CREATE PROGRAM cv_da_update_cv_procedure:dba
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
 DECLARE cv_da_update_cv_procedure_vrsn = vc WITH private, constant("20230425")
 DECLARE mdtdanone = dq8 WITH noconstant(0.0)
 DECLARE mdtdaend = dq8 WITH noconstant(0.0)
 DECLARE msdatablename = vc WITH noconstant("")
 SET mdtdanone = cnvtdatetime("01-JAN-1800 00:00:00.00")
 SET mdtdaend = cnvtdatetime("31-DEC-2100 23:59:59.00")
 SET msdatablename = "CV_PROC"
 DECLARE gen_nbr_error = i4 WITH constant(500)
 DECLARE insert_error = i4 WITH constant(501)
 DECLARE update_error = i4 WITH constant(502)
 DECLARE replace_error = i4 WITH constant(503)
 DECLARE delete_error = i4 WITH constant(504)
 DECLARE undelete_error = i4 WITH constant(505)
 DECLARE remove_error = i4 WITH constant(506)
 DECLARE attribute_error = i4 WITH constant(507)
 DECLARE lock_error = i4 WITH constant(508)
 DECLARE alteredind = i4 WITH noconstant(0)
 IF (trim(cnvtstring(validate(transinfo->trans_dt_tm,0)))="0")
  RECORD transinfo(
    1 trans_dt_tm = dq8
  )
  SET transinfo->trans_dt_tm = cnvtdatetime(sysdate)
 ENDIF
 IF (validate(reply) != 1)
  RECORD reply(
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
 DECLARE i = i4 WITH noconstant(0), protect
 DECLARE blocked = i2 WITH noconstant(0), protect
 SET i = 1
 WHILE (i <= size(request->objarray,5))
   SET blocked = false
   SELECT INTO "nl:"
    c.*
    FROM cv_proc c
    WHERE (c.cv_proc_id=request->objarray[i].cv_proc_id)
    DETAIL
     IF ((validate(request->objarray[i].order_id,c.order_id) != - (0.00001))
      AND validate(request->objarray[i].order_id,c.order_id) != c.order_id)
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].accession_id,c.accession_id) != - (0.00001))
      AND validate(request->objarray[i].accession_id,c.accession_id) != c.accession_id)
      alteredind = 1
     ENDIF
     IF (validate(request->objarray[i].accession,c.accession) != char(128)
      AND validate(request->objarray[i].accession,c.accession) != c.accession)
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].catalog_cd,c.catalog_cd) != - (0.00001))
      AND validate(request->objarray[i].catalog_cd,c.catalog_cd) != c.catalog_cd)
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].order_physician_id,c.order_physician_id) != - (0.00001))
      AND validate(request->objarray[i].order_physician_id,c.order_physician_id) != c
     .order_physician_id)
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].refer_physician_id,c.refer_physician_id) != - (0.00001))
      AND validate(request->objarray[i].refer_physician_id,c.refer_physician_id) != c
     .refer_physician_id)
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].prim_physician_id,c.prim_physician_id) != - (0.00001))
      AND validate(request->objarray[i].prim_physician_id,c.prim_physician_id) != c.prim_physician_id
     )
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].person_id,c.person_id) != - (0.00001))
      AND validate(request->objarray[i].person_id,c.person_id) != c.person_id)
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].encntr_id,c.encntr_id) != - (0.00001))
      AND validate(request->objarray[i].encntr_id,c.encntr_id) != c.encntr_id)
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].proc_status_cd,c.proc_status_cd) != - (0.00001))
      AND validate(request->objarray[i].proc_status_cd,c.proc_status_cd) != c.proc_status_cd)
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].priority_cd,c.priority_cd) != - (0.00001))
      AND validate(request->objarray[i].priority_cd,c.priority_cd) != c.priority_cd)
      alteredind = 1
     ENDIF
     IF (validate(request->objarray[i].reason_for_proc,c.reason_for_proc) != char(128)
      AND validate(request->objarray[i].reason_for_proc,c.reason_for_proc) != c.reason_for_proc)
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].group_event_id,c.group_event_id) != - (0.00001))
      AND validate(request->objarray[i].group_event_id,c.group_event_id) != c.group_event_id)
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].sequence,c.sequence) != - (1))
      AND validate(request->objarray[i].sequence,c.sequence) != c.sequence)
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].phys_group_id,c.phys_group_id) != - (0.00001))
      AND validate(request->objarray[i].phys_group_id,c.phys_group_id) != c.phys_group_id)
      alteredind = 1
     ENDIF
     IF (((validate(request->objarray[i].action_dt_tm,c.action_dt_tm) != 0.0
      AND validate(request->objarray[i].action_dt_tm,c.action_dt_tm) != c.action_dt_tm) OR (validate(
      request->objarray[i].action_dt_tm_null,0)=1)) )
      alteredind = 1
     ENDIF
     IF (((validate(request->objarray[i].request_dt_tm,c.request_dt_tm) != 0.0
      AND validate(request->objarray[i].request_dt_tm,c.request_dt_tm) != c.request_dt_tm) OR (
     validate(request->objarray[i].request_dt_tm_null,0)=1)) )
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].activity_subtype_cd,c.activity_subtype_cd) != - (0.00001))
      AND validate(request->objarray[i].activity_subtype_cd,c.activity_subtype_cd) != c
     .activity_subtype_cd)
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].normalcy_cd,c.normalcy_cd) != - (0.00001))
      AND validate(request->objarray[i].normalcy_cd,c.normalcy_cd) != c.normalcy_cd)
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].stress_ecg_status_cd,c.stress_ecg_status_cd) != - (0.00001))
      AND validate(request->objarray[i].stress_ecg_status_cd,c.stress_ecg_status_cd) != c
     .stress_ecg_status_cd)
      alteredind = 1
     ENDIF
     IF ((validate(request->objarray[i].study_state_cd,c.study_state_cd) != - (0.00001))
      AND validate(request->objarray[i].study_state_cd,c.study_state_cd) != c.study_state_cd)
      alteredind = 1
     ENDIF
     IF ((request->objarray[i].updt_cnt != c.updt_cnt)
      AND (request->objarray[i].updt_cnt != - (99999)))
      blocked = true
     ENDIF
    WITH forupdate(c)
   ;end select
   IF (((curqual=0) OR (blocked=true)) )
    IF (blocked=true)
     CALL cv_log_stat(cv_info,"BLOCKED","F",msdatablename,"")
    ENDIF
    IF (false=checkerror(lock_error))
     RETURN
    ENDIF
   ENDIF
   IF (alteredind > 0)
    UPDATE  FROM cv_proc c
     SET c.order_id =
      IF ((validate(request->objarray[i].order_id,- (0.00001)) != - (0.00001))) validate(request->
        objarray[i].order_id,- (0.00001))
      ELSE c.order_id
      ENDIF
      , c.accession_id =
      IF ((validate(request->objarray[i].accession_id,- (0.00001)) != - (0.00001))) validate(request
        ->objarray[i].accession_id,- (0.00001))
      ELSE c.accession_id
      ENDIF
      , c.accession =
      IF (validate(request->objarray[i].accession,char(128)) != char(128)) validate(request->
        objarray[i].accession,char(128))
      ELSE c.accession
      ENDIF
      ,
      c.catalog_cd =
      IF ((validate(request->objarray[i].catalog_cd,- (0.00001)) != - (0.00001))) validate(request->
        objarray[i].catalog_cd,- (0.00001))
      ELSE c.catalog_cd
      ENDIF
      , c.order_physician_id =
      IF ((validate(request->objarray[i].order_physician_id,- (0.00001)) != - (0.00001))) validate(
        request->objarray[i].order_physician_id,- (0.00001))
      ELSE c.order_physician_id
      ENDIF
      , c.refer_physician_id =
      IF ((validate(request->objarray[i].refer_physician_id,- (0.00001)) != - (0.00001))) validate(
        request->objarray[i].refer_physician_id,- (0.00001))
      ELSE c.refer_physician_id
      ENDIF
      ,
      c.prim_physician_id =
      IF ((validate(request->objarray[i].prim_physician_id,- (0.00001)) != - (0.00001))) validate(
        request->objarray[i].prim_physician_id,- (0.00001))
      ELSE c.prim_physician_id
      ENDIF
      , c.person_id =
      IF ((validate(request->objarray[i].person_id,- (0.00001)) != - (0.00001))) validate(request->
        objarray[i].person_id,- (0.00001))
      ELSE c.person_id
      ENDIF
      , c.encntr_id =
      IF ((validate(request->objarray[i].encntr_id,- (0.00001)) != - (0.00001))) validate(request->
        objarray[i].encntr_id,- (0.00001))
      ELSE c.encntr_id
      ENDIF
      ,
      c.proc_status_cd =
      IF ((validate(request->objarray[i].proc_status_cd,- (0.00001)) != - (0.00001))) validate(
        request->objarray[i].proc_status_cd,- (0.00001))
      ELSE c.proc_status_cd
      ENDIF
      , c.priority_cd =
      IF ((validate(request->objarray[i].priority_cd,- (0.00001)) != - (0.00001))) validate(request->
        objarray[i].priority_cd,- (0.00001))
      ELSE c.priority_cd
      ENDIF
      , c.reason_for_proc =
      IF (validate(request->objarray[i].reason_for_proc,char(128)) != char(128)) validate(request->
        objarray[i].reason_for_proc,char(128))
      ELSE c.reason_for_proc
      ENDIF
      ,
      c.group_event_id =
      IF ((validate(request->objarray[i].group_event_id,- (0.00001)) != - (0.00001))) validate(
        request->objarray[i].group_event_id,- (0.00001))
      ELSE c.group_event_id
      ENDIF
      , c.sequence =
      IF ((validate(request->objarray[i].sequence,- (1)) != - (1))) validate(request->objarray[i].
        sequence,- (1))
      ELSE c.sequence
      ENDIF
      , c.phys_group_id =
      IF ((validate(request->objarray[i].phys_group_id,- (0.00001)) != - (0.00001))) validate(request
        ->objarray[i].phys_group_id,- (0.00001))
      ELSE c.phys_group_id
      ENDIF
      ,
      c.action_dt_tm =
      IF (validate(request->objarray[i].action_dt_tm,0.0) > 0.0) cnvtdatetime(validate(request->
         objarray[i].action_dt_tm,0.0))
      ELSEIF (validate(request->objarray[i].action_dt_tm_null,0)=1) null
      ELSE c.action_dt_tm
      ENDIF
      , c.request_dt_tm =
      IF (validate(request->objarray[i].request_dt_tm,0.0) > 0.0) cnvtdatetime(validate(request->
         objarray[i].request_dt_tm,0.0))
      ELSEIF (validate(request->objarray[i].request_dt_tm_null,0)=1) null
      ELSE c.request_dt_tm
      ENDIF
      , c.activity_subtype_cd =
      IF ((validate(request->objarray[i].activity_subtype_cd,- (0.00001)) != - (0.00001))) validate(
        request->objarray[i].activity_subtype_cd,- (0.00001))
      ELSE c.activity_subtype_cd
      ENDIF
      ,
      c.normalcy_cd =
      IF ((validate(request->objarray[i].normalcy_cd,- (0.00001)) != - (0.00001))) validate(request->
        objarray[i].normalcy_cd,- (0.00001))
      ELSE c.normalcy_cd
      ENDIF
      , c.stress_ecg_status_cd =
      IF ((validate(request->objarray[i].stress_ecg_status_cd,- (0.00001)) != - (0.00001))) validate(
        request->objarray[i].stress_ecg_status_cd,- (0.00001))
      ELSE c.stress_ecg_status_cd
      ENDIF
      , c.study_state_cd =
      IF ((validate(request->objarray[i].study_state_cd,- (0.00001)) != - (0.00001))) validate(
        request->objarray[i].study_state_cd,- (0.00001))
      ELSE c.study_state_cd
      ENDIF
      ,
      c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(transinfo->trans_dt_tm), c.updt_task
       = reqinfo->updt_task,
      c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c.updt_cnt+ 1)
     WHERE (c.cv_proc_id=request->objarray[i].cv_proc_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     IF (false=checkerror(update_error))
      RETURN
     ENDIF
    ELSE
     CALL checkerror(true)
    ENDIF
   ELSE
    CALL checkerror(true)
   ENDIF
   SET i += 1
 ENDWHILE
 SUBROUTINE (checkerror(nfailed=i4) =i2 WITH protect)
   IF (nfailed=true)
    SET reply->status_data.status = "S"
    SET reqinfo->commit_ind = true
    RETURN(true)
   ELSE
    CASE (nfailed)
     OF gen_nbr_error:
      CALL cv_log_stat(cv_error,"GEN_NBR","F",msdatablename,"")
     OF insert_error:
      CALL cv_log_stat(cv_error,"INSERT","F",msdatablename,"")
     OF update_error:
      CALL cv_log_stat(cv_error,"UPDATE","F",msdatablename,"")
     OF replace_error:
      CALL cv_log_stat(cv_error,"REPLACE","F",msdatablename,"")
     OF delete_error:
      CALL cv_log_stat(cv_error,"DELETE","F",msdatablename,"")
     OF undelete_error:
      CALL cv_log_stat(cv_error,"UNDELETE","F",msdatablename,"")
     OF remove_error:
      CALL cv_log_stat(cv_error,"REMOVE","F",msdatablename,"")
     OF attribute_error:
      CALL cv_log_stat(cv_error,"ATTRIBUTE","F",msdatablename,"")
     OF lock_error:
      CALL cv_log_stat(cv_error,"LOCK","F",msdatablename,"")
     ELSE
      CALL cv_log_stat(cv_error,"UNKNOWN","F",msdatablename,"")
    ENDCASE
    SET reqinfo->commit_ind = false
    RETURN(false)
   ENDIF
 END ;Subroutine
#end_program
 CALL cv_log_msg_post("003 19/04/23 AS043139")
END GO
