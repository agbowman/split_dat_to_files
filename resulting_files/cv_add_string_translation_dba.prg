CREATE PROGRAM cv_add_string_translation:dba
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
 DECLARE nsize = i4 WITH noconstant(0), protect
 DECLARE i = i4 WITH noconstant(0), protect
 DECLARE nfailed = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET nsize = size(request->string_translation,5)
 FOR (i = 1 TO nsize)
   SET nfailed = 0
   IF (((validate(request->string_translation[i].contributor_cd,- (0.00001)) <= 0.0) OR (((validate(
    request->string_translation[i].field_type_cd,- (0.00001)) <= 0.0) OR (((validate(request->
    string_translation[i].cerner_val,char(128))=null) OR (validate(request->string_translation[i].
    contributor_val,char(128))=null)) )) )) )
    CALL cv_log_stat(cv_warning,"INSERT","F","CV_STRING_TRANSLATION","Null value passed")
    SET nfailed = 1
   ENDIF
   IF (nfailed != 1)
    INSERT  FROM cv_string_translation c
     SET c.cv_string_translation_id = seq(card_vas_seq,nextval), c.contributor_cd =
      IF ((validate(request->string_translation[i].contributor_cd,- (0.00001)) != - (0.00001)))
       validate(request->string_translation[i].contributor_cd,- (0.00001))
      ELSE 0.0
      ENDIF
      , c.field_type_cd =
      IF ((validate(request->string_translation[i].field_type_cd,- (0.00001)) != - (0.00001)))
       validate(request->string_translation[i].field_type_cd,- (0.00001))
      ELSE 0.0
      ENDIF
      ,
      c.contributor_val =
      IF (validate(request->string_translation[i].contributor_val,char(128)) != char(128)) validate(
        request->string_translation[i].contributor_val,char(128))
      ELSE ""
      ENDIF
      , c.cerner_val =
      IF (validate(request->string_translation[i].cerner_val,char(128)) != char(128)) validate(
        request->string_translation[i].cerner_val,char(128))
      ELSE ""
      ENDIF
      , c.updt_id = reqinfo->updt_id,
      c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_cnt = 0, c.updt_task = reqinfo->updt_task,
      c.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL cv_log_stat(cv_warning,"INSERT","F","CV_STRING_TRANSLATION","Insert failed")
    ELSE
     SET reply->status_data.status = "S"
     CALL cv_log_stat(cv_warning,"INSERT","S","CV_STRING_TRANSLATION","Insert success")
    ENDIF
   ENDIF
 ENDFOR
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
  CALL cv_log_stat(cv_warning,"INSERT","F","CV_STRING_TRANSLATION","Insert success")
 ELSE
  SET reqinfo->commit_ind = 0
  CALL cv_log_stat(cv_warning,"INSERT","F","CV_STRING_TRANSLATION","Insert failed")
 ENDIF
 CALL cv_log_msg_post("000 07/30/12 TK020431")
END GO
