CREATE PROGRAM dm_get_dm_info:dba
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
 SET log_program_name = "DM_GET_DM_INFO"
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 qual[*]
      2 info_domain = vc
      2 info_name = vc
      2 info_date = dq8
      2 info_char = vc
      2 info_number = f8
      2 info_long_id = f8
      2 updt_applctx = f8
      2 updt_task = i4
      2 updt_dt_tm = dq8
      2 updt_cnt = i4
      2 updt_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE where_clause = vc WITH noconstant(""), protect
 DECLARE found_item = i2 WITH noconstant(0), protect
 DECLARE personnel_logical_domain_id = f8 WITH noconstant(0.0)
 SET reply->status_data.status = "F"
 CALL log_message("Starting script: dm_get_dm_info",log_level_debug)
 IF ((request->debug_ind=1))
  CALL echorecord(request)
 ENDIF
 IF (size(trim(request->info_name)) > 0)
  CALL buildwhereclause(build("d.info_name = '",request->info_name,"'"))
 ENDIF
 IF (size(trim(request->info_domain)) > 0)
  CALL buildwhereclause(build("d.info_domain = '",request->info_domain,"'"))
 ENDIF
 IF (size(trim(request->info_char)) > 0)
  CALL buildwhereclause(build("d.info_char = '",request->info_char,"'"))
 ENDIF
 IF ((request->info_date > 0))
  CALL buildwhereclause(build("d.info_date = cnvtdatetime(",request->info_date,")"))
 ENDIF
 IF ((request->info_number > 0))
  CALL buildwhereclause(build("d.info_number = ",request->info_number))
 ENDIF
 IF ((request->info_long_id > 0))
  CALL buildwhereclause(build("d.info_long_id = ",request->info_long_id))
 ENDIF
 IF (validate(request->logical_domain_ind,0)=1)
  SELECT INTO "nl:"
   p.logical_domain_id
   FROM prsnl p
   WHERE (p.person_id=reqinfo->updt_id)
   DETAIL
    personnel_logical_domain_id = p.logical_domain_id
   WITH nocounter
  ;end select
  CALL buildwhereclause(build("d.info_domain_id = ",personnel_logical_domain_id))
 ENDIF
 IF ((request->debug_ind=1))
  CALL echo(where_clause)
 ENDIF
 IF (found_item=0)
  CALL log_message("No valid elements selected for query.",log_level_debug)
  SET reply->status_data.status = "Z"
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE parser(where_clause)
  ORDER BY d.updt_dt_tm DESC, d.updt_cnt DESC
  HEAD REPORT
   x = 0
  DETAIL
   x += 1
   IF (mod(x,10)=1)
    stat = alterlist(reply->qual,(x+ 9))
   ENDIF
   reply->qual[x].info_name = d.info_name, reply->qual[x].info_domain = d.info_domain, reply->qual[x]
   .info_char = d.info_char,
   reply->qual[x].info_date = d.info_date, reply->qual[x].info_number = d.info_number, reply->qual[x]
   .info_long_id = d.info_long_id,
   reply->qual[x].updt_applctx = d.updt_applctx, reply->qual[x].updt_task = d.updt_task, reply->qual[
   x].updt_dt_tm = d.updt_dt_tm,
   reply->qual[x].updt_cnt = d.updt_cnt, reply->qual[x].updt_id = d.updt_id
  FOOT REPORT
   stat = alterlist(reply->qual,x)
  WITH nocounter
 ;end select
 IF (error_message(1) > 0)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  CALL log_message("Zero dm_info rows returned.",log_level_debug)
  SET reply->status_data.status = "Z"
 ELSE
  CALL log_message("Dm_info rows successfully returned.",log_level_debug)
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE (buildwhereclause(selement=vc(val)) =null)
  IF (found_item=0)
   SET where_clause = build(selement)
   SET found_item = 1
  ELSE
   SET where_clause = concat(where_clause," and ",selement)
  ENDIF
  RETURN
 END ;Subroutine
#exit_script
 CALL log_message("End of script: dm_get_dm_info",log_level_debug)
 IF ((request->debug_ind=1))
  CALL echorecord(reply)
 ENDIF
END GO
