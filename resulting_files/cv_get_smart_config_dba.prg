CREATE PROGRAM cv_get_smart_config:dba
 IF (validate(reply) != 1)
  RECORD reply(
    1 qual[*]
      2 cv_smart_config_id = f8
      2 tenant_key = vc
      2 facility_cd = f8
      2 vendor_cd = f8
      2 web_url = vc
      2 browser_name = vc
      2 migration_ind = i4
      2 prod_start_date = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE retrievebytenantkey(null) = null
 DECLARE retrievebyfacilitycd(null) = null
 DECLARE retrieveallconfiguration(null) = null
 DECLARE tenantkey = vc WITH protect, constant(nullterm(validate(request->tenant_key,"")))
 DECLARE facilitycd = f8 WITH protect, constant(validate(request->facility_cd,0))
 DECLARE ireccnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 IF (facilitycd=0
  AND tenantkey="")
  CALL retrieveallconfiguration(null)
 ELSE
  IF (facilitycd > 0)
   CALL retrievebyfacilitycd(null)
  ELSEIF (tenantkey != "")
   CALL retrievebytenantkey(null)
  ELSE
   CALL echo("invalid request paramaters")
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE retrievebytenantkey(null)
   SET ireccnt = 0
   SELECT INTO "nl:"
    FROM cv_smart_config csc
    WHERE csc.cv_smart_config_id != 0.00
     AND csc.tenant_key=tenantkey
     AND csc.active_ind=1
    DETAIL
     ireccnt += 1, stat = alterlist(reply->qual,ireccnt), reply->qual[ireccnt].cv_smart_config_id =
     csc.cv_smart_config_id,
     reply->qual[ireccnt].facility_cd = csc.facility_cd, reply->qual[ireccnt].vendor_cd = csc
     .vendor_cd, reply->qual[ireccnt].web_url = csc.launch_url,
     reply->qual[ireccnt].tenant_key = csc.tenant_key, reply->qual[ireccnt].migration_ind = csc
     .migration_ind, reply->qual[ireccnt].browser_name = csc.browser_tflg,
     reply->qual[ireccnt].prod_start_date = csc.product_start_dt_tm
    WITH nocounter
   ;end select
   IF (ireccnt >= 1)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "Z"
   ENDIF
 END ;Subroutine
 SUBROUTINE retrievebyfacilitycd(null)
   SET ireccnt = 0
   SELECT INTO "nl:"
    FROM cv_smart_config csc
    WHERE csc.cv_smart_config_id != 0.00
     AND csc.facility_cd=facilitycd
     AND csc.active_ind=1
    DETAIL
     ireccnt += 1, stat = alterlist(reply->qual,ireccnt), reply->qual[ireccnt].cv_smart_config_id =
     csc.cv_smart_config_id,
     reply->qual[ireccnt].facility_cd = csc.facility_cd, reply->qual[ireccnt].vendor_cd = csc
     .vendor_cd, reply->qual[ireccnt].web_url = csc.launch_url,
     reply->qual[ireccnt].tenant_key = csc.tenant_key, reply->qual[ireccnt].migration_ind = csc
     .migration_ind, reply->qual[ireccnt].browser_name = csc.browser_tflg,
     reply->qual[ireccnt].prod_start_date = csc.product_start_dt_tm
    WITH nocounter
   ;end select
   IF (ireccnt >= 1)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "Z"
   ENDIF
 END ;Subroutine
 SUBROUTINE retrieveallconfiguration(null)
   SET ireccnt = 0
   SELECT INTO "nl:"
    FROM cv_smart_config csc
    WHERE csc.cv_smart_config_id != 0.00
     AND csc.active_ind=1
    DETAIL
     ireccnt += 1, stat = alterlist(reply->qual,ireccnt), reply->qual[ireccnt].cv_smart_config_id =
     csc.cv_smart_config_id,
     reply->qual[ireccnt].facility_cd = csc.facility_cd, reply->qual[ireccnt].vendor_cd = csc
     .vendor_cd, reply->qual[ireccnt].web_url = csc.launch_url,
     reply->qual[ireccnt].tenant_key = csc.tenant_key, reply->qual[ireccnt].migration_ind = csc
     .migration_ind, reply->qual[ireccnt].browser_name = csc.browser_tflg,
     reply->qual[ireccnt].prod_start_date = csc.product_start_dt_tm
    WITH nocounter
   ;end select
   IF (ireccnt >= 1)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "Z"
   ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="Z"))
  CALL cv_log_msg(cv_audit,"No records found for given tenant_key or facility_cd.")
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSEIF ((reply->status_data.status="F"))
  CALL cv_log_msg(cv_error,"SMART app configuration retrieval failed.")
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSEIF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  CALL cv_log_msg(cv_warning,"Unrecognized reply status")
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 CALL cv_log_msg_post("000 05/03/23 SS028138")
END GO
