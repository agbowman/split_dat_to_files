CREATE PROGRAM cv_upd_proc_stress_ecg_status:dba
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
 DECLARE stress_ecg_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE update_count = i4 WITH protect, noconstant(0.0)
 FREE RECORD updaterequest
 RECORD updaterequest(
   1 objarray[*]
     2 cv_proc_id = f8
     2 stress_ecg_status_cd = f8
     2 updt_cnt = i4
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM cv_proc c
  WHERE (c.cv_proc_id=request->cv_proc_id)
  DETAIL
   stress_ecg_status_cd = c.stress_ecg_status_cd, update_count = c.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET stat = alterlist(updaterequest->objarray,1)
  SET updaterequest->objarray[1].cv_proc_id = request->cv_proc_id
  SET updaterequest->objarray[1].stress_ecg_status_cd = request->stress_ecg_status_cd
  SET updaterequest->objarray[1].updt_cnt = update_count
  IF ((stress_ecg_status_cd != request->stress_ecg_status_cd))
   EXECUTE cv_da_upt_cv_proc  WITH replace("REQUEST",updaterequest), replace("REPLY",reply)
   IF ((reply->status_data.status != "S"))
    CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"CV_DA_UPT_CV_PROC","")
    IF ((reqdata->loglevel >= cv_debug))
     CALL echorecord(updaterequest)
    ENDIF
    GO TO exit_script
   ENDIF
  ELSE
   CALL cv_log_msg(cv_info,"stress_ecg_status_cd is same for the proc_id. No need of updating.")
  ENDIF
  SET reply->status_data.status = "S"
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
  CALL cv_log_msg(cv_error,"curqual is 0 for the proc_id")
 ENDIF
#exit_script
 IF ((reply->status_data.status="S")
  AND (reqinfo->commit_ind=1))
  COMMIT
 ELSE
  CALL cv_log_msg(cv_error,"cv_upd_proc_stress_ecg_status did not update the Stress ECG Status")
  IF ((reqdata->loglevel >= cv_debug))
   CALL echorecord(request)
   CALL echorecord(reply)
  ENDIF
 ENDIF
 CALL cv_log_msg_post("000 26/03/18 VJ043510")
END GO
