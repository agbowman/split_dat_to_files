CREATE PROGRAM cv_check_enc_access:dba
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
 DECLARE alwayscallvalidateencounters = i2 WITH constant(1)
 DECLARE encntr_idx = i4 WITH protect
 DECLARE prev_reqinfo_updt_id = f8 WITH protect
 DECLARE unique_encntr_count = i4 WITH protect, noconstant(0)
 IF (validate(reply) != 1)
  RECORD reply(
    1 encounter[*]
      2 encntr_id = f8
      2 access_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 CALL echo(build2("size(request->encounter,5) = ",size(request->encounter,5)))
 DECLARE needtocalldcpchckvalidencounters(null) = i2
 EXECUTE dcp_gen_cve_recs  WITH replace("CVE_REQUEST",cve_request), replace("CVE_REPLY",cve_reply)
 SET stat = alterlist(cve_request->encntrs,size(request->encounter,5))
 SELECT INTO "nl:"
  req_encntr_id = request->encounter[d.seq].encntr_id
  FROM (dummyt d  WITH seq = size(request->encounter,5))
  ORDER BY req_encntr_id
  HEAD REPORT
   unique_encntr_count = 0
  HEAD req_encntr_id
   unique_encntr_count += 1, cve_request->encntrs[unique_encntr_count].encntr_id = request->
   encounter[d.seq].encntr_id, cve_request->encntrs[unique_encntr_count].person_id = request->
   encounter[d.seq].person_id
  FOOT REPORT
   stat = alterlist(cve_request->encntrs,unique_encntr_count)
  WITH nocounter
 ;end select
 IF (needtocalldcpchckvalidencounters(null)=1)
  CALL echo(build2("setting reqinfo->updt_id = ",request->prsnl_id))
  SET prev_reqinfo_updt_id = reqinfo->updt_id
  SET reqinfo->updt_id = request->prsnl_id
  EXECUTE dcp_chck_valid_encounters  WITH replace("REQUEST",cve_request), replace("REPLY",cve_reply)
  CALL echo(build2("restoring reqinfo->updt_id to ",prev_reqinfo_updt_id))
  SET reqinfo->updt_id = prev_reqinfo_updt_id
  SET stat = alterlist(reply->encounter,size(cve_reply->encntrs,5))
  FOR (encntr_idx = 1 TO size(cve_reply->encntrs,5))
   SET reply->encounter[encntr_idx].encntr_id = cve_reply->encntrs[encntr_idx].encntr_id
   IF ((cve_reply->encntrs[encntr_idx].secure_ind=0))
    SET reply->encounter[encntr_idx].access_ind = 1
   ELSE
    SET reply->encounter[encntr_idx].access_ind = 0
   ENDIF
  ENDFOR
 ELSE
  SET stat = alterlist(reply->encounter,size(request->encounter,5))
  FOR (encntr_idx = 1 TO size(request->encounter,5))
   SET reply->encounter[encntr_idx].encntr_id = request->encounter[encntr_idx].encntr_id
   SET reply->encounter[encntr_idx].access_ind = 1
  ENDFOR
 ENDIF
 IF ((reply->status_data.status != "F"))
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE needtocalldcpchckvalidencounters(null)
   IF (alwayscallvalidateencounters=1)
    CALL echo("returning true from NeedToCallDcpChckValidEncounters - security_level is unknown")
    RETURN(true)
   ENDIF
   EXECUTE dts_get_org_security  WITH replace("REPLY",dgos_reply)
   IF ((dgos_reply->org_security_on=1)
    AND (dgos_reply->confid_security_on=1))
    SET cve_request->security_flag = 2
   ELSEIF ((dgos_reply->org_security_on=1)
    AND (dgos_reply->confid_security_on=0))
    SET cve_request->security_flag = 1
   ELSE
    SET cve_request->security_flag = 0
    CALL echo(build2("returning false from NeedToCallDcpChckValidEncounters - security_level = ",0))
    RETURN(false)
   ENDIF
   CALL echo(build2("returning true from NeedToCallDcpChckValidEncounters - security_level = ",
     cve_request->security_flag))
   RETURN(true)
 END ;Subroutine
#exit_script
 CALL cv_log_msg_post("001 08/01/08 FE2417 ")
END GO
