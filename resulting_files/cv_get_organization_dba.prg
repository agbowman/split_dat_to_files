CREATE PROGRAM cv_get_organization:dba
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
 DECLARE request_org_idx = i4 WITH protect
 DECLARE request_org_cnt = i4 WITH protect
 DECLARE reply_org_cnt = i4 WITH protect, noconstant(0)
 DECLARE reply_org_idx = i4 WITH protect
 DECLARE nstart = i4 WITH protect
 DECLARE block_size = i4 WITH protect, constant(20)
 DECLARE c_loc_type_facility = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE checkdminfo(dummyval) = null
 DECLARE loaduserorganization(dummyval) = null
 IF (validate(reply) != 1)
  RECORD reply(
    1 sec_org_reltn_ind = i2
    1 sec_confid_ind = i2
    1 organization[*]
      2 organization_id = f8
      2 organization_name = vc
      2 confid_level_seq = i4
      2 auth_org_preference = i4
      2 org_allowed = i4
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
 SUBROUTINE checkdminfo(dummyval)
   IF (validate(ccldminfo->mode,0))
    SET reply->sec_org_reltn_ind = ccldminfo->sec_org_reltn
    SET reply->sec_confid_ind = ccldminfo->sec_confid
   ELSE
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_name IN ("SEC_CONFID", "SEC_ORG_RELTN")
      AND d.info_domain="SECURITY"
     DETAIL
      IF (d.info_name="SEC_ORG_RELTN")
       reply->sec_org_reltn_ind = d.info_number
      ELSE
       reply->sec_confid_ind = d.info_number
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual <= 0)
     CALL cv_log_stat(cv_warning,"SELECT","F","DM_INFO","Unable to determine Security from dm_imfo.")
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE loaduserorganization(dummyval)
   SELECT INTO "nl:"
    tmp_confid_level_seq = uar_get_collation_seq(por.confid_level_cd)
    FROM prsnl_org_reltn por,
     organization o,
     location l
    PLAN (por
     WHERE (por.person_id=request->user_id)
      AND por.active_ind=1
      AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (o
     WHERE o.organization_id=por.organization_id
      AND o.active_ind=1
      AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND o.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (l
     WHERE l.organization_id=o.organization_id
      AND l.location_type_cd=c_loc_type_facility
      AND l.active_ind=1
      AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND l.end_effective_dt_tm > cnvtdatetime(sysdate))
    HEAD REPORT
     reply_org_cnt = 0
    DETAIL
     reply_org_cnt += 1
     IF (mod(reply_org_cnt,10)=1)
      stat = alterlist(reply->organization,(reply_org_cnt+ 9))
     ENDIF
     reply->organization[reply_org_cnt].organization_id = o.organization_id, reply->organization[
     reply_org_cnt].organization_name = o.org_name, reply->organization[reply_org_cnt].org_allowed =
     1,
     reply->organization[reply_org_cnt].auth_org_preference = 1
     IF (tmp_confid_level_seq > 0)
      reply->organization[reply_org_cnt].confid_level_seq = tmp_confid_level_seq
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->organization,reply_org_cnt)
    WITH nocounter
   ;end select
   SET reply->status_data.status = "S"
   CALL cv_log_stat(cv_info,"SELECT","S","CV_GET_ORGANIZATION",
    "Reply contains all active user patient care orgs - LoadUserOrganization")
   GO TO exit_script
 END ;Subroutine
 SET reply->status_data.status = "F"
 CALL checkdminfo(0)
 SET request_org_cnt = size(request->organization,5)
 IF ((reply->sec_org_reltn_ind < 1))
  SELECT INTO "nl:"
   FROM organization o,
    location l
   PLAN (o
    WHERE o.active_ind=1
     AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND o.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (l
    WHERE l.organization_id=o.organization_id
     AND l.location_type_cd=c_loc_type_facility
     AND l.active_ind=1
     AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND l.end_effective_dt_tm > cnvtdatetime(sysdate))
   HEAD REPORT
    reply_org_cnt = 0
   DETAIL
    reply_org_cnt += 1
    IF (mod(reply_org_cnt,10)=1)
     stat = alterlist(reply->organization,(reply_org_cnt+ 9))
    ENDIF
    reply->organization[reply_org_cnt].organization_id = o.organization_id, reply->organization[
    reply_org_cnt].organization_name = o.org_name
   FOOT REPORT
    stat = alterlist(reply->organization,reply_org_cnt)
   WITH nocounter
  ;end select
  IF (reply_org_cnt <= 0)
   CALL cv_log_stat(cv_error,"SELECT","F","CV_GET_ORGANIZATION",
    "No active patient care facilities found in System.")
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
  IF (request_org_cnt <= 0)
   CALL cv_log_stat(cv_info,"SELECT","S","CV_GET_ORGANIZATION",
    "Reply contains all active patient care orgs.")
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
  FOR (request_org_idx = 1 TO request_org_cnt)
   SET reply_org_idx = locateval(reply_org_idx,1,reply_org_cnt,request->organization[request_org_idx]
    .organization_id,reply->organization[reply_org_idx].organization_id)
   WHILE (reply_org_idx != 0)
     SET reply->organization[reply_org_idx].org_allowed = 1
     SET reply->organization[reply_org_idx].auth_org_preference = 1
     SET reply_org_idx = locateval(reply_org_idx,(reply_org_idx+ 1),reply_org_cnt,request->
      organization[request_org_idx].organization_id,reply->organization[reply_org_idx].
      organization_id)
   ENDWHILE
  ENDFOR
  CALL cv_log_stat(cv_info,"SELECT","S","CV_GET_ORGANIZATION",
   "Reply contains all active patient care orgs, orgs in pref flagged.")
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 IF ((request->user_id <= 0.0))
  CALL cv_log_stat(cv_warning,"SELECT","F","CV_GET_ORGANIZATION",
   "No user_id was passed in the request.")
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->organization,request_org_cnt)
 IF (request_org_cnt <= 0)
  CALL loaduserorganization(0)
  GO TO exit_script
 ENDIF
 DECLARE request_org_idx = i2 WITH noconstant(1)
 FOR (request_org_idx = 1 TO size(request->organization,5))
   SELECT INTO "nl:"
    tmp_confid_level_seq = uar_get_collation_seq(por.confid_level_cd)
    FROM prsnl_org_reltn por,
     organization o,
     location l
    PLAN (por
     WHERE (por.person_id=request->user_id)
      AND por.active_ind=1
      AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND por.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND (por.organization_id=request->organization[request_org_idx].organization_id))
     JOIN (o
     WHERE o.organization_id=por.organization_id
      AND o.active_ind=1
      AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND o.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (l
     WHERE l.organization_id=o.organization_id
      AND l.location_type_cd=c_loc_type_facility
      AND l.active_ind=1
      AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND l.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     reply_org_cnt += 1, stat = alterlist(reply->organization,size(request->organization,5)), reply->
     organization[reply_org_cnt].organization_id = o.organization_id,
     reply->organization[reply_org_cnt].organization_name = o.org_name, reply->organization[
     reply_org_cnt].org_allowed = 1, reply->organization[reply_org_cnt].auth_org_preference = 1
     IF (tmp_confid_level_seq > 0)
      reply->organization[reply_org_cnt].confid_level_seq = tmp_confid_level_seq
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 IF (reply_org_cnt <= 0)
  CALL loaduserorganization(0)
  IF (validate(execmsgrtl,999)=999)
   DECLARE execmsgrtl = i2 WITH constant(1), persist
   DECLARE emsglog_commit = i4 WITH constant(0), persist
   DECLARE emsglvl_info = i4 WITH constant(3), persist
   EXECUTE msgrtl
  ENDIF
  DECLARE log_message = vc WITH protect
  DECLARE loghandle = i4 WITH noconstant(0)
  SET loghandle = uar_msgopen("CV_GET_ORGANIZATION")
  CALL uar_msgsetlevel(loghandle,emsglvl_info)
  SET log_message =
  "None of the user's organizations were included in the organizations specified in PreferenceManager"
  CALL uar_msgwrite(loghandle,emsglog_commit,nullterm("CV_GET_ORGANIZATION_NO_INTERSECTION"),
   emsglvl_info,nullterm(log_message))
  CALL uar_msgclose(loghandle)
  GO TO exit_script
 ENDIF
 CALL cv_log_stat(cv_info,"SELECT","S","CV_GET_ORGANIZATION",
  "Reply contains active patient care orgs in both preferencemanager and user organizations.")
 SET reply->status_data.status = "S"
#exit_script
 SET stat = alterlist(reply->organization,reply_org_cnt)
 IF ((reply->status_data.status != "F"))
  IF (reply_org_cnt=0)
   SET reply->status_data.status = "Z"
  ELSEIF (reply_org_cnt > 0)
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 CALL cv_log_msg_post("MOD 009 13/03/17 RR035230")
END GO
