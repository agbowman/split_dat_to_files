CREATE PROGRAM cv_get_acronyms:dba
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
 DECLARE loadprovideracronyms(provider_id=f8) = null
 IF (validate(reply) != 1)
  RECORD reply(
    1 acronym[*]
      2 cv_acronym_id = f8
      2 provider_id = f8
      2 acronym_str = vc
      2 replacement_str = vc
      2 collation_seq = i4
      2 updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_msg(cv_error,"Reply doesn't contain status block")
  GO TO exit_script
 ENDIF
 DECLARE ecg_category_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002868,"ECGACRONYM"))
 SET reply->status_data.status = "F"
 CALL loadprovideracronyms(request->provider_id,request->category_cd)
 IF (size(reply->acronym,5) <= 0)
  CALL loadprovideracronyms(0.0,request->category_cd)
 ENDIF
 IF (size(reply->acronym,5) <= 0)
  CALL cv_log_stat(cv_error,"SELECT","F","CV_GET_ACRONYMS",
   "No acronyms found for the specified provider")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE loadprovideracronyms(provider_id,category_cd)
  SELECT INTO "nl:"
   FROM cv_acronym c
   WHERE c.provider_id=provider_id
    AND c.acronym_category_cd=category_cd
   HEAD REPORT
    reply_idx = 0
   DETAIL
    reply_idx += 1
    IF (mod(reply_idx,10)=1)
     stat = alterlist(reply->acronym,(reply_idx+ 9))
    ENDIF
    reply->acronym[reply_idx].cv_acronym_id = c.cv_acronym_id, reply->acronym[reply_idx].provider_id
     = c.provider_id, reply->acronym[reply_idx].acronym_str = c.acronym_str,
    reply->acronym[reply_idx].replacement_str = c.replacement_str, reply->acronym[reply_idx].
    collation_seq = c.collation_seq, reply->acronym[reply_idx].updt_cnt = c.updt_cnt
   FOOT REPORT
    stat = alterlist(reply->acronym,reply_idx)
   WITH nocounter
  ;end select
  IF (category_cd=ecg_category_cd)
   SELECT INTO "nl:"
    FROM cv_acronym c
    WHERE c.provider_id=provider_id
     AND c.acronym_category_cd=0.0
    HEAD REPORT
     reply_idx = size(reply->acronym,5)
    DETAIL
     reply_idx += 1
     IF (mod(reply_idx,10)=1)
      stat = alterlist(reply->acronym,(reply_idx+ 9))
     ENDIF
     reply->acronym[reply_idx].cv_acronym_id = c.cv_acronym_id, reply->acronym[reply_idx].provider_id
      = c.provider_id, reply->acronym[reply_idx].acronym_str = c.acronym_str,
     reply->acronym[reply_idx].replacement_str = c.replacement_str, reply->acronym[reply_idx].
     collation_seq = c.collation_seq, reply->acronym[reply_idx].updt_cnt = c.updt_cnt
    FOOT REPORT
     stat = alterlist(reply->acronym,reply_idx)
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="Z"))
  CALL cv_log_msg(cv_info,"CV_GET_ACRONYMS returned status = 'Z'")
 ELSEIF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_GET_ACRONYMS failed")
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 CALL cv_log_msg_post("MOD 000 10/31/08 AR012547")
END GO
