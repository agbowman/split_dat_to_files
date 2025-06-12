CREATE PROGRAM cv_fetch_locations:dba
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
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 performing_loc[*]
      2 perf_loc_cd = f8
      2 default_ind = i4
      2 cv_device_location_ref_id = f8
      2 cv_device_location_r_id = f8
      2 device_name = vc
  )
 ENDIF
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REPLY","")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF ((request->device_name != null)
  AND (request->user_id != 0))
  CALL fetchandupdate(0)
 ELSEIF ((request->user_id != 0))
  CALL fetchbyloggedinuser(0)
 ELSE
  CALL fetchall(0)
 ENDIF
 SUBROUTINE fetchbyloggedinuser(dummy)
  SELECT INTO "nl:"
   FROM cv_device_location_r c,
    cv_device_location_ref cd
   PLAN (c
    WHERE (c.user_id=request->user_id)
     AND c.default_ind=1
     AND c.active_dev_user_ind=1)
    JOIN (cd
    WHERE cd.cv_device_location_ref_id=c.cv_device_location_ref_id)
   HEAD REPORT
    stat = alterlist(reply->performing_loc,10), count = 0
   DETAIL
    count += 1
    IF (mod(count,10)=1
     AND count > 10)
     stat = alterlist(reply->performing_loc,(count+ 9))
    ENDIF
    reply->performing_loc[count].perf_loc_cd = c.performing_location_cd
   FOOT REPORT
    stat = alterlist(reply->performing_loc,count)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE fetchbydevice(dummy)
  SELECT INTO "nl:"
   FROM cv_device_location_r c,
    cv_device_location_ref cd
   PLAN (cd
    WHERE (cd.device_name=request->device_name)
     AND cd.active_ind=1)
    JOIN (c
    WHERE c.cv_device_location_ref_id=cd.cv_device_location_ref_id)
   HEAD REPORT
    stat = alterlist(reply->performing_loc,10), count = 0
   DETAIL
    count += 1
    IF (mod(count,10)=1
     AND count > 10)
     stat = alterlist(reply->performing_loc,(count+ 9))
    ENDIF
    reply->performing_loc[count].perf_loc_cd = c.performing_location_cd, reply->performing_loc[count]
    .default_ind = c.default_ind, reply->performing_loc[count].cv_device_location_ref_id = c
    .cv_device_location_ref_id,
    reply->performing_loc[count].cv_device_location_r_id = c.cv_device_location_r_id
   FOOT REPORT
    stat = alterlist(reply->performing_loc,count)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE fetchandupdate(dummy)
   CALL fetchbydevice(0)
   DECLARE r_id = f8
   SELECT INTO "nl:"
    FROM cv_device_location_r c,
     cv_device_location_ref cd
    PLAN (cd
     WHERE (cd.device_name=request->device_name)
      AND cd.active_ind=1)
     JOIN (c
     WHERE c.cv_device_location_ref_id=cd.cv_device_location_ref_id
      AND c.default_ind=1)
    DETAIL
     r_id = c.cv_device_location_r_id
    WITH format, nocounter
   ;end select
   IF (curqual != 0)
    UPDATE  FROM cv_device_location_r c
     SET c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->
      updt_task,
      c.updt_applctx = reqinfo->updt_applctx, c.active_dev_user_ind = 1, c.user_id = request->user_id,
      c.updt_cnt = (c.updt_cnt+ 1)
     WHERE c.cv_device_location_r_id=r_id
     WITH nocounter
    ;end update
    IF (curqual > 0)
     SET reply->status_data.status = "S"
    ELSE
     SET reply->status_data.status = "Z"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE fetchall(dummy)
  SELECT INTO "nl:"
   FROM cv_device_location_r c,
    cv_device_location_ref cd
   PLAN (cd
    WHERE cd.active_ind=1)
    JOIN (c
    WHERE c.cv_device_location_ref_id=cd.cv_device_location_ref_id)
   ORDER BY c.cv_device_location_r_id
   HEAD REPORT
    stat = alterlist(reply->performing_loc,10), count = 0
   DETAIL
    count += 1
    IF (mod(count,10)=1
     AND count > 10)
     stat = alterlist(reply->performing_loc,(count+ 9))
    ENDIF
    reply->performing_loc[count].perf_loc_cd = c.performing_location_cd, reply->performing_loc[count]
    .default_ind = c.default_ind, reply->performing_loc[count].cv_device_location_ref_id = c
    .cv_device_location_ref_id,
    reply->performing_loc[count].cv_device_location_r_id = c.cv_device_location_r_id, reply->
    performing_loc[count].device_name = cd.device_name
   FOOT REPORT
    stat = alterlist(reply->performing_loc,count)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"Zero rows retrieved or updated!")
  SET reqinfo->commit_ind = 0
  CALL echorecord(request)
  CALL echorecord(reply)
 ELSE
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_msg_post("MOD 003 05/06/16 PK035073")
END GO
