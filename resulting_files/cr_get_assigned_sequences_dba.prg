CREATE PROGRAM cr_get_assigned_sequences:dba
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
 SET log_program_name = "CR_GET_ASSIGNED_SEQUENCES"
 RECORD reply(
   1 prsnl_qual[*]
     2 group_reltn_id = f8
     2 prsnl_id = f8
     2 name_full_formatted = vc
     2 sequence_nbr = i4
   1 org_qual[*]
     2 group_reltn_id = f8
     2 organization_id = f8
     2 organization_name = vc
     2 sequence_nbr = i4
   1 loc_qual[*]
     2 group_reltn_id = f8
     2 location_cd = f8
     2 location_disp = vc
     2 sequence_nbr = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 CALL log_message("Starting script: cr_get_assigned_sequences",log_level_debug)
 IF ((request->debug_ind=1))
  CALL echorecord(request)
 ENDIF
 SELECT INTO "nl:"
  FROM chart_seq_group_reltn csgr,
   prsnl p,
   organization o
  PLAN (csgr
   WHERE (csgr.sequence_group_id=request->sequence_group_id)
    AND csgr.active_ind=1)
   JOIN (p
   WHERE p.person_id=csgr.prsnl_id)
   JOIN (o
   WHERE o.organization_id=csgr.organization_id)
  ORDER BY csgr.sequence_nbr
  HEAD REPORT
   nassigncnt = 0
  DETAIL
   nassigncnt += 1
   IF (csgr.prsnl_id > 0.0)
    IF (nassigncnt > size(reply->prsnl_qual,5))
     stat = alterlist(reply->prsnl_qual,(nassigncnt+ 19))
    ENDIF
    reply->prsnl_qual[nassigncnt].group_reltn_id = csgr.group_reltn_id, reply->prsnl_qual[nassigncnt]
    .prsnl_id = csgr.prsnl_id, reply->prsnl_qual[nassigncnt].name_full_formatted = p
    .name_full_formatted,
    reply->prsnl_qual[nassigncnt].sequence_nbr = csgr.sequence_nbr
   ELSEIF (csgr.organization_id > 0.0)
    IF (nassigncnt > size(reply->org_qual,5))
     stat = alterlist(reply->org_qual,(nassigncnt+ 19))
    ENDIF
    reply->org_qual[nassigncnt].group_reltn_id = csgr.group_reltn_id, reply->org_qual[nassigncnt].
    organization_id = csgr.prsnl_id, reply->org_qual[nassigncnt].organization_name = o.org_name,
    reply->org_qual[nassigncnt].sequence_nbr = csgr.sequence_nbr
   ELSEIF (csgr.location_cd > 0.0)
    IF (nassigncnt > size(reply->loc_qual,5))
     stat = alterlist(reply->loc_qual,(nassigncnt+ 19))
    ENDIF
    reply->loc_qual[nassigncnt].group_reltn_id = csgr.group_reltn_id, reply->loc_qual[nassigncnt].
    location_cd = csgr.location_cd, reply->loc_qual[nassigncnt].sequence_nbr = csgr.sequence_nbr
   ENDIF
  FOOT REPORT
   IF (size(reply->prsnl_qual,5) > 0)
    stat = alterlist(reply->prsnl_qual,nassigncnt)
   ELSEIF (size(reply->org_qual,5) > 0)
    stat = alterlist(reply->org_qual,nassigncnt)
   ELSEIF (size(reply->loc_qual,5) > 0)
    stat = alterlist(reply->loc_qual,nassigncnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (error_message(1) > 0)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  CALL log_message("Zero groups returned.",log_level_debug)
  SET reply->status_data.status = "Z"
 ELSEIF (curqual > 0)
  CALL log_message("Groups successfully returned.",log_level_debug)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL log_message("End of script: cr_get_assigned_sequences",log_level_debug)
 IF ((request->debug_ind=1))
  CALL echorecord(reply)
 ENDIF
END GO
