CREATE PROGRAM cv_save_device_location:dba
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
 FREE RECORD adddevicelocation
 RECORD adddevicelocation(
   1 objarray[*]
     2 cv_device_location_ref_id = f8
     2 cv_device_location_r_id = f8
     2 device_name = vc
     2 performing_location = f8
     2 default_ind = i2
 )
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
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REPLY","")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","")
  GO TO exit_script
 ENDIF
 SUBROUTINE (deleterow(ref_id=f8,r_id=f8) =null WITH protect)
  SELECT INTO "nl:"
   FROM cv_device_location_r r
   WHERE r.cv_device_location_ref_id=ref_id
   WITH nocounter
  ;end select
  IF (curqual > 1)
   DELETE  FROM cv_device_location_r r
    WHERE r.cv_device_location_r_id=r_id
   ;end delete
  ELSEIF (curqual=1)
   DELETE  FROM cv_device_location_r r
    WHERE r.cv_device_location_r_id=r_id
   ;end delete
   DELETE  FROM cv_device_location_ref ref
    WHERE ref.cv_device_location_ref_id=ref_id
   ;end delete
  ELSE
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 DECLARE ndeletesize = i4 WITH constant(size(request->deletedevicelocation,5)), protect
 DECLARE cv_device_location_ref_id = f8
 IF (ndeletesize > 0)
  FOR (nrowidx = 1 TO ndeletesize)
    CALL deleterow(request->deletedevicelocation[nrowidx].cv_device_location_ref_id,request->
     deletedevicelocation[nrowidx].cv_device_location_r_id)
  ENDFOR
 ENDIF
 DECLARE nupdatesize = i4 WITH constant(size(request->updtdevicelocation,5)), protect
 DECLARE ndevicealtered = i4 WITH noconstant(0)
 IF (nupdatesize > 0)
  FOR (nrowidx = 1 TO nupdatesize)
   SELECT INTO "nl:"
    FROM cv_device_location_ref c
    WHERE (c.cv_device_location_ref_id=request->updtdevicelocation[nrowidx].cv_device_location_ref_id
    )
    DETAIL
     IF (validate(request->updtdevicelocation[nrowidx].device_name,c.device_name) != char(128)
      AND validate(request->updtdevicelocation[nrowidx].device_name,c.device_name) != c.device_name)
      ndevicealtered = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (ndevicealtered > 0)
    CALL deleterow(request->updtdevicelocation[nrowidx].cv_device_location_ref_id,request->
     updtdevicelocation[nrowidx].cv_device_location_r_id)
    SET statforadd = alterlist(adddevicelocation->objarray,5)
    SET adddevicelocation->objarray[nrowidx].device_name = request->updtdevicelocation[nrowidx].
    device_name
    SET adddevicelocation->objarray[nrowidx].performing_location = request->updtdevicelocation[
    nrowidx].location_cd
    SET adddevicelocation->objarray[nrowidx].default_ind = request->updtdevicelocation[nrowidx].
    default_ind
    IF (size(adddevicelocation->objarray,5) > 0)
     CALL cv_log_msg(cv_debug,"ADDING to CV_DEVICE_LOCATION...")
     EXECUTE cv_da_add_device_location  WITH replace("REQUEST",adddevicelocation), replace("REPLY",
      reply)
     IF ((reply->status_data.status != "S"))
      CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"CV_DA_ADD_DEVICE_LOCATION","")
      GO TO exit_script
     ENDIF
    ELSE
     CALL cv_log_msg(cv_info,"Nothing to ADD to cv_device_location_ref and cv_device_location_r")
    ENDIF
   ELSE
    UPDATE  FROM cv_device_location_r cd
     SET cd.default_ind =
      IF ((validate(request->updtdevicelocation[nrowidx].default_ind,- (1)) != - (1))) validate(
        request->updtdevicelocation[nrowidx].default_ind,- (1))
      ELSE cd.default_ind
      ENDIF
      , cd.performing_location_cd =
      IF ((validate(request->updtdevicelocation[nrowidx].location_cd,- (0.00001)) != - (0.00001)))
       validate(request->updtdevicelocation[nrowidx].location_cd,- (0.00001))
      ELSE cd.performing_location_cd
      ENDIF
      , cd.updt_id = reqinfo->updt_id,
      cd.updt_dt_tm = cnvtdatetime(sysdate), cd.updt_task = reqinfo->updt_task, cd.updt_applctx =
      reqinfo->updt_applctx,
      cd.updt_cnt = (cd.updt_cnt+ 1), cd.user_id =
      IF ((validate(request->updtdevicelocation[nrowidx].user_id,- (0.00001)) != - (0.00001)))
       validate(request->updtdevicelocation[nrowidx].user_id,- (0.00001))
      ELSE cd.user_id
      ENDIF
      , cd.active_dev_user_ind =
      IF ((request->updtdevicelocation[nrowidx].default_ind=1)
       AND (request->updtdevicelocation[nrowidx].user_id != null)) request->updtdevicelocation[
       nrowidx].default_ind
      ELSE 0
      ENDIF
     WHERE (cd.cv_device_location_r_id=request->updtdevicelocation[nrowidx].cv_device_location_r_id)
     WITH nocounter
    ;end update
   ENDIF
  ENDFOR
 ENDIF
 DECLARE naddsize = i4 WITH constant(size(request->adddevicelocation,5)), protect
 IF (naddsize > 0)
  SET stat = alterlist(adddevicelocation->objarray,naddsize)
  FOR (nrowidx = 1 TO naddsize)
    SET adddevicelocation->objarray[nrowidx].device_name = request->adddevicelocation[nrowidx].
    device_name
    SET adddevicelocation->objarray[nrowidx].performing_location = request->adddevicelocation[nrowidx
    ].location_cd
    SET adddevicelocation->objarray[nrowidx].default_ind = request->adddevicelocation[nrowidx].
    default_ind
  ENDFOR
  IF (size(adddevicelocation->objarray,5) > 0)
   CALL cv_log_msg(cv_debug,"ADDING to CV_DEVICE_LOCATION...")
   EXECUTE cv_da_add_device_location  WITH replace("REQUEST",adddevicelocation), replace("REPLY",
    reply)
   IF ((reply->status_data.status != "S"))
    CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"cv_da_add_device_location","")
    GO TO exit_script
   ENDIF
  ELSE
   CALL cv_log_msg(cv_info,"Nothing to ADD to cv_device_location_ref and cv_device_location_r")
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_SAVE_DEVICE_LOCATION FAILED!")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_msg_post("MOD 000 03/06/16 PK035073")
END GO
