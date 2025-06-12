CREATE PROGRAM cv_get_facilities:dba
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
 DECLARE request_org_pad = i4 WITH protect
 DECLARE reply_org_cnt = i4 WITH protect
 DECLARE reply_org_idx = i4 WITH protect
 DECLARE nstart = i4 WITH protect
 DECLARE block_size = i4 WITH protect, constant(20)
 DECLARE c_loc_type_facility = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE loaduserfacilities(dummyval) = null
 RECORD request(
   1 logged_user_id = f8
 )
 IF (validate(reply) != 1)
  RECORD reply(
    1 sec_org_reltn_ind = i2
    1 sec_confid_ind = i2
    1 organization[*]
      2 organization_id = f8
      2 organization_name = vc
      2 confid_level_seq = i4
      2 org_allowed = i4
      2 location_disp = vc
      2 location_cd = f8
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
 SUBROUTINE loaduserfacilities(dummyval)
   SELECT INTO "nl:"
    tmp_confid_level_seq = uar_get_collation_seq(por.confid_level_cd)
    FROM prsnl_org_reltn por,
     organization o,
     location l
    PLAN (por
     WHERE (por.person_id=request->logged_user_id)
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
     reply_org_cnt].organization_name = o.org_name, reply->organization[reply_org_cnt].location_disp
      = uar_get_code_display(l.location_cd),
     reply->organization[reply_org_cnt].location_cd = l.location_cd
    FOOT REPORT
     stat = alterlist(reply->organization,reply_org_cnt)
    WITH nocounter
   ;end select
   CALL cv_log_stat(cv_info,"SELECT","S","CV_GET_FACILITIES",
    "Reply contains all active facilities available for the logged in user - LoadUserFacilities")
   GO TO exit_script
 END ;Subroutine
 IF (request_org_cnt <= 0)
  CALL loaduserfacilities(0)
  GO TO exit_script
 ENDIF
#exit_script
 SET stat = alterlist(reply->organization,reply_org_cnt)
 IF ((reply->status_data.status != "F"))
  IF (reply_org_cnt=0)
   SET reply->status_data.status = "Z"
  ELSEIF (reply_org_cnt > 0)
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 CALL cv_log_msg_post("MOD 000 10/15/15 RR033108")
END GO
