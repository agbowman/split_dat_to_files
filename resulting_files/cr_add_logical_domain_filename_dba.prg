CREATE PROGRAM cr_add_logical_domain_filename:dba
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = h WITH protect, noconstant(0)
 DECLARE crsl_msg_level = h WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("CLINRPT SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=crsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=crsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     SET reply->status_data.status = "F"
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",serrmsg,logmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET reply->status_data.status = "Z"
    CALL populate_subeventstatus(opname,"Z","No records qualified",logmsg)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(reply->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "CR_ADD_LOGICAL_DOMAIN_FILENAME"
 DECLARE new_schema = i2 WITH noconstant(0)
 DECLARE previous_setup_script_run_status = i2 WITH noconstant(0)
 DECLARE previous_setup_script_run_exists = i2 WITH noconstant(0)
 DECLARE multi_tenant = i2 WITH noconstant(0)
 DECLARE dist_logically_domained = i2 WITH noconstant(0)
 DECLARE new_mask_id = f8 WITH noconstant(0.0)
 DECLARE check_mask_id = f8 WITH noconstant(0.0)
 FREE RECORD logical_domain_rec
 RECORD logical_domain_rec(
   1 qual[*]
     2 logical_domain_id = f8
 )
 FREE RECORD cr_mask_rec
 RECORD cr_mask_rec(
   1 qual[*]
     2 mask_text = vc
 )
 FREE RECORD operation_info_rec
 RECORD operation_info_rec(
   1 qual[*]
     2 operation_id = f8
     2 logical_domain_id = f8
     2 mask_text = vc
 )
 SELECT INTO "nl:"
  dm.info_number
  FROM dm_info dm
  WHERE dm.info_name="Enable Logical Domain XR Dist"
   AND dm.info_domain="CLINICAL REPORTING XR"
  DETAIL
   dist_logically_domained = dm.info_number
  WITH nocounter
 ;end select
 CALL log_message(build2("dist_logical_domain: ",dist_logically_domained),log_level_debug)
 SELECT INTO "nl:"
  dm.info_number
  FROM dm_info dm
  WHERE dm.info_name="XR_FILENAME_MASK_MODULE_LAUNCH"
   AND dm.info_domain="CLINICAL REPORTING XR"
  DETAIL
   previous_setup_script_run_status = dm.info_number
  WITH nocounter
 ;end select
 SET previous_setup_script_run_exists = curqual
 CALL log_message(build2("previous_readme_status :",previous_setup_script_run_status),log_level_debug
  )
 CALL log_message(build2("previous_readme_exists :",previous_setup_script_run_exists),log_level_debug
  )
 SELECT INTO "nl:"
  ld.logical_domain_id
  FROM logical_domain ld
  WHERE ld.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 1)
  SET multi_tenant = 1
 ENDIF
 CALL log_message(build2("multi_tenant:",multi_tenant),log_level_debug)
 IF (multi_tenant=1
  AND previous_setup_script_run_status=0)
  IF (dist_logically_domained=0
   AND previous_setup_script_run_exists=0)
   INSERT  FROM dm_info dm
    SET dm.info_domain = "CLINICAL REPORTING XR", dm.info_name = "XR_FILENAME_MASK_MODULE_LAUNCH", dm
     .info_number = 0,
     dm.info_domain_id = 0, dm.updt_id = reqinfo->updt_id, dm.updt_applctx = reqinfo->updt_applctx,
     dm.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
  ELSE
   SELECT INTO "nl:"
    ld.logical_domain_id
    FROM logical_domain ld
    WHERE ld.logical_domain_id != 0
     AND ld.active_ind=1
    HEAD REPORT
     count = 0
    DETAIL
     stat = alterlist(logical_domain_rec->qual,(count+ 1)), count += 1, logical_domain_rec->qual[
     count].logical_domain_id = ld.logical_domain_id
    WITH nocounter
   ;end select
   CALL echorecord(logical_domain_rec)
   CALL echo(build("curqual: ",curqual))
   SELECT DISTINCT INTO "nl:"
    cm.cr_mask_text
    FROM cr_mask cm
    HEAD REPORT
     count = 0
    DETAIL
     stat = alterlist(cr_mask_rec->qual,(count+ 1)), count += 1, cr_mask_rec->qual[count].mask_text
      = cm.cr_mask_text
    WITH nocounter
   ;end select
   CALL echorecord(cr_mask_rec)
   FOR (x = 1 TO size(logical_domain_rec->qual,5))
     FOR (y = 1 TO size(cr_mask_rec->qual,5))
      SET check_mask_id = getnewcrmaskid(logical_domain_rec->qual[x].logical_domain_id,cr_mask_rec->
       qual[y].mask_text)
      IF (check_mask_id=0)
       INSERT  FROM cr_mask cm
        SET cm.cr_mask_id = seq(reference_seq,nextval), cm.cr_mask_text = cr_mask_rec->qual[y].
         mask_text, cm.logical_domain_id = logical_domain_rec->qual[x].logical_domain_id,
         cm.publish_ind = 1, cm.default_ind = 0, cm.updt_cnt = 0,
         cm.updt_dt_tm = cnvtdatetime(sysdate), cm.updt_id = reqinfo->updt_id, cm.updt_applctx =
         reqinfo->updt_applctx,
         cm.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
      ENDIF
     ENDFOR
   ENDFOR
   SELECT DISTINCT INTO "nl:"
    cop.charting_operations_id, cop.param, cop.logical_domain_id,
    cm.cr_mask_text
    FROM charting_operations cop,
     cr_mask cm
    PLAN (cop)
     JOIN (cm
     WHERE cop.param=cnvtstring(cm.cr_mask_id)
      AND cop.active_ind=1
      AND cop.param_type_flag=23)
    HEAD REPORT
     count = 0
    DETAIL
     stat = alterlist(operation_info_rec->qual,(count+ 1)), count += 1, operation_info_rec->qual[
     count].logical_domain_id = cop.logical_domain_id,
     operation_info_rec->qual[count].operation_id = cop.charting_operations_id, operation_info_rec->
     qual[count].mask_text = cm.cr_mask_text
    WITH nocounter
   ;end select
   FOR (x = 1 TO size(operation_info_rec->qual,5))
    SET new_mask_id = getnewcrmaskid(operation_info_rec->qual[x].logical_domain_id,operation_info_rec
     ->qual[x].mask_text)
    UPDATE  FROM charting_operations cop
     SET cop.param = cnvtstring(new_mask_id), cop.updt_cnt = 0, cop.updt_dt_tm = cnvtdatetime(sysdate
       ),
      cop.updt_id = reqinfo->updt_id, cop.updt_applctx = reqinfo->updt_applctx, cop.updt_task =
      reqinfo->updt_task
     WHERE (cop.charting_operations_id=operation_info_rec->qual[x].operation_id)
      AND cop.param_type_flag=23
     WITH nocounter
    ;end update
   ENDFOR
   IF (previous_setup_script_run_exists=0)
    INSERT  FROM dm_info dm
     SET dm.info_domain = "CLINICAL REPORTING XR", dm.info_name = "XR_FILENAME_MASK_MODULE_LAUNCH",
      dm.info_number = 1,
      dm.info_domain_id = 0, dm.updt_id = reqinfo->updt_id, dm.updt_applctx = reqinfo->updt_applctx,
      dm.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info dm
     SET dm.info_number = 1, dm.updt_id = reqinfo->updt_id, dm.updt_applctx = reqinfo->updt_applctx,
      dm.updt_task = reqinfo->updt_task
     WHERE dm.info_domain="CLINICAL REPORTING XR"
      AND dm.info_name="XR_FILENAME_MASK_MODULE_LAUNCH"
     WITH nocounter
    ;end update
   ENDIF
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = 1
 SUBROUTINE (getnewcrmaskid(logical_domain_id=f8,mask_text=vc) =f8 WITH protect)
   DECLARE new_mask = f8
   SELECT INTO "nl:"
    cm.cr_mask_id
    FROM cr_mask cm
    WHERE cm.cr_mask_text=mask_text
     AND cm.logical_domain_id=logical_domain_id
    DETAIL
     new_mask = cm.cr_mask_id
    WITH nocounter
   ;end select
   RETURN(new_mask)
 END ;Subroutine
#exit_script
END GO
