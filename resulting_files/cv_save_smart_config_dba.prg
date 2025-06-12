CREATE PROGRAM cv_save_smart_config:dba
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
 DECLARE operationsmanager(null) = null
 DECLARE irecsize = i4 WITH protect, noconstant(0)
 DECLARE gen_nbr_error = i4 WITH constant(500)
 DECLARE insert_error = i4 WITH constant(501)
 DECLARE update_error = i4 WITH constant(502)
 DECLARE replace_error = i4 WITH constant(503)
 DECLARE delete_error = i4 WITH constant(504)
 DECLARE undelete_error = i4 WITH constant(505)
 DECLARE remove_error = i4 WITH constant(506)
 DECLARE attribute_error = i4 WITH constant(507)
 DECLARE lock_error = i4 WITH constant(508)
 DECLARE msdatablename = vc WITH noconstant("")
 SET reply->status_data.status = "F"
 SET msdatablename = "CV_SMART_CONFIG"
 CALL operationsmanager(null)
 SUBROUTINE operationsmanager(null)
   DECLARE iloop = i4
   SET irecsize = size(request->qual,5)
   SET iloop = 0
   FOR (iloop = 1 TO irecsize)
     IF ((request->qual[iloop].update_flag=1))
      CALL insertconfiguration(iloop)
     ELSEIF ((request->qual[iloop].update_flag=2))
      CALL updateconfiguration(iloop)
     ELSEIF ((request->qual[iloop].update_flag=3))
      CALL deleteconfiguration(iloop)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (insertconfiguration(iloc=i4) =null)
   CALL echo("InsertConfiguration")
   DECLARE dcvsmartconfigid = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    nextseqnum = seq(card_vas_seq,nextval)
    FROM dual
    DETAIL
     dcvsmartconfigid = nextseqnum
    WITH nocounter
   ;end select
   INSERT  FROM cv_smart_config csc
    SET csc.cv_smart_config_id = dcvsmartconfigid, csc.tenant_key = trim(request->qual[iloc].
      tenant_key), csc.facility_cd = request->qual[iloc].facility_cd,
     csc.vendor_cd = request->qual[iloc].vendor_cd, csc.launch_url = trim(request->qual[iloc].web_url
      ), csc.browser_tflg = trim(request->qual[iloc].browser_name),
     csc.migration_ind = request->qual[iloc].migration_ind, csc.product_start_dt_tm = cnvtdatetime(
      request->qual[iloc].prod_start_date), csc.active_ind = 1,
     csc.updt_cnt = 0, csc.updt_dt_tm = cnvtdatetime(sysdate), csc.updt_task = reqinfo->updt_task,
     csc.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    IF (false=checkerror(insert_error))
     RETURN
    ENDIF
   ELSE
    CALL checkerror(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE (updateconfiguration(iloc=i4) =null)
   CALL echo("UpdateConfiguration")
   UPDATE  FROM cv_smart_config csc
    SET csc.tenant_key = trim(request->qual[iloc].tenant_key), csc.facility_cd = request->qual[iloc].
     facility_cd, csc.vendor_cd = request->qual[iloc].vendor_cd,
     csc.launch_url = trim(request->qual[iloc].web_url), csc.browser_tflg = trim(request->qual[iloc].
      browser_name), csc.migration_ind = request->qual[iloc].migration_ind,
     csc.product_start_dt_tm = cnvtdatetime(request->qual[iloc].prod_start_date), csc.active_ind = 1,
     csc.updt_cnt = (csc.updt_cnt+ 1),
     csc.updt_dt_tm = cnvtdatetime(sysdate), csc.updt_task = reqinfo->updt_task, csc.updt_applctx =
     reqinfo->updt_applctx
    WHERE (csc.cv_smart_config_id=request->qual[iloc].cv_smart_config_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    IF (false=checkerror(update_error))
     RETURN
    ENDIF
   ELSE
    CALL checkerror(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE (deleteconfiguration(iloc=i4) =null)
   CALL echo("DeleteConfiguration")
   SELECT INTO "nl:"
    FROM cv_smart_config csc
    WHERE (csc.cv_smart_config_id=request->qual[iloc].cv_smart_config_id)
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL checkerror(true)
   ELSEIF (curqual > 0)
    DELETE  FROM cv_smart_config csc
     WHERE (csc.cv_smart_config_id=request->qual[iloc].cv_smart_config_id)
     WITH nocounter
    ;end delete
    COMMIT
    IF (curqual=0)
     IF (false=checkerror(delete_error))
      RETURN
     ENDIF
    ELSE
     CALL checkerror(true)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (checkerror(nfailed=i4) =i2)
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
#exit_script
END GO
