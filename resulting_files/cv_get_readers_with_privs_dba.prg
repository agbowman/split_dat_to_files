CREATE PROGRAM cv_get_readers_with_privs:dba
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
    1 qual[*]
      2 name = vc
      2 value = f8
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
 SET reply->status_data.status = "F"
 IF (validate(request) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","")
  GO TO exit_script
 ENDIF
 DECLARE proc_idx = i4 WITH protect, noconstant(0)
 FREE RECORD get_privs_req
 RECORD get_privs_req(
   1 privs[*]
     2 privilege_cd = f8
   1 person_id = f8
   1 position_cd = f8
 )
 FREE RECORD get_privs_rep
 RECORD get_privs_rep(
   1 prsnl[*]
     2 person_id = f8
     2 position_cd = f8
     2 name_full_formatted = vc
     2 privs[*]
       3 privilege_id = f8
       3 privilege_cd = f8
       3 privilege_disp = vc
       3 privilege_desc = vc
       3 privilege_mean = vc
       3 priv_value_cd = f8
       3 priv_value_disp = vc
       3 priv_value_desc = vc
       3 priv_value_mean = vc
       3 exceptionlist[*]
         4 privilegeexceptionid = f8
         4 exception_type_cd = f8
         4 exception_type_disp = vc
         4 exception_type_desc = vc
         4 exception_type_mean = vc
         4 exceptionid = f8
         4 exceptionentityname = vc
         4 eventsetname = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FOR (proc_idx = 1 TO size(request->qual,5))
  SET stat = alterlist(get_privs_req->privs,proc_idx)
  SET get_privs_req->privs[proc_idx].privilege_cd = uar_get_code_by("MEANING",6016,request->qual[
   proc_idx].value)
 ENDFOR
 EXECUTE cv_get_privs  WITH replace("REQUEST",get_privs_req), replace("REPLY",get_privs_rep)
 FOR (proc_idx = 1 TO size(get_privs_rep->prsnl,5))
   SET stat = alterlist(reply->qual,proc_idx)
   SET reply->qual[proc_idx].value = get_privs_rep->prsnl[proc_idx].person_id
   SET reply->qual[proc_idx].name = get_privs_rep->prsnl[proc_idx].name_full_formatted
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL cv_log_msg_post("001 03/04/2009 SM013857")
END GO
