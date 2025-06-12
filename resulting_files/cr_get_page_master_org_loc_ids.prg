CREATE PROGRAM cr_get_page_master_org_loc_ids
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
 SET log_program_name = "CR_GET_PAGE_MASTER_ORG_LOC_IDS"
 CALL log_message("Starting script: cr_get_page_master_org_loc_ids",log_level_debug)
 FREE RECORD reply
 RECORD reply(
   1 org_ids[*]
     2 id = f8
     2 name = vc
   1 loc_ids[*]
     2 id = f8
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD names
 RECORD names(
   1 qual[*]
     2 name_key = vc
     2 name = vc
 )
 DECLARE retrieveorgids(null) = null
 DECLARE retrievelocids(null) = null
 DECLARE lnumoforgs = i4 WITH noconstant(0)
 DECLARE lnumoflocs = i4 WITH noconstant(0)
 SET lnumoforgs = size(request->org_names,5)
 SET lnumoflocs = size(request->loc_names,5)
 SET reply->status_data.status = "F"
 IF (lnumoforgs > 0)
  CALL echo("size of orgs")
  CALL echo(lnumoforgs)
  SET stat = alterlist(names->qual,lnumoforgs)
  FOR (lforcount = 1 TO lnumoforgs)
   SET names->qual[lforcount].name_key = trim(cnvtupper(cnvtalphanum(request->org_names[lforcount].
      name)),3)
   SET names->qual[lforcount].name = request->org_names[lforcount].name
  ENDFOR
  CALL retrieveorgids(null)
  SET stat = alterlist(names->qual,0)
 ENDIF
 IF (lnumoflocs > 0)
  CALL echo("size of locs")
  CALL echo(lnumoflocs)
  SET stat = alterlist(names->qual,lnumoflocs)
  FOR (lforcount = 1 TO lnumoflocs)
   SET names->qual[lforcount].name_key = trim(cnvtupper(cnvtalphanum(request->loc_names[lforcount].
      name)),3)
   SET names->qual[lforcount].name = request->loc_names[lforcount].name
  ENDFOR
  CALL retrievelocids(null)
  SET stat = alterlist(names->qual,0)
 ENDIF
 SUBROUTINE retrieveorgids(null)
   CALL log_message("Entered RetrieveOrgIds subroutine.",log_level_debug)
   DECLARE lidx = i4
   DECLARE counter = i4
   DECLARE pos = i4
   DECLARE num = i4 WITH noconstant(0), public
   SELECT DISTINCT INTO "nl:"
    org.org_name
    FROM organization org,
     org_type_reltn otr,
     code_value cv
    PLAN (org
     WHERE org.active_ind=1
      AND expand(lidx,1,lnumoforgs,org.org_name_key,names->qual[lidx].name_key))
     JOIN (otr
     WHERE otr.organization_id=org.organization_id)
     JOIN (cv
     WHERE cv.code_value=otr.org_type_cd
      AND ((cv.cdf_meaning="FACILITY") OR (cv.cdf_meaning="CLIENT"
      AND cv.code_set=278)) )
    ORDER BY org.org_name
    HEAD REPORT
     stat = alterlist(reply->org_ids,5), counter = 0
    HEAD org.org_name
     pos = locateval(num,1,size(names->qual,5),org.org_name,names->qual[num].name)
     IF (pos > 0)
      counter += 1
      IF (mod(counter,5)=1)
       stat = alterlist(reply->org_ids,(counter+ 4))
      ENDIF
      reply->org_ids[counter].id = org.organization_id, reply->org_ids[counter].name = org.org_name,
      BREAK
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->org_ids,counter)
    WITH nocounter
   ;end select
   CALL log_message("Exiting RetrieveOrgIds subroutine.",log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievelocids(null)
   CALL log_message("Entered RetrieveLocIds subroutine.",log_level_debug)
   DECLARE lidx = i4
   DECLARE counter = i4
   DECLARE pos = i4
   DECLARE num = i4 WITH noconstant(0), public
   SELECT DISTINCT INTO "nl:"
    cv.display
    FROM location loc,
     code_value cv
    PLAN (loc
     WHERE loc.active_ind=1)
     JOIN (cv
     WHERE loc.location_cd=cv.code_value
      AND cv.code_set=220
      AND cv.cdf_meaning="LAB"
      AND expand(lidx,1,lnumoflocs,cv.display_key,names->qual[lidx].name_key))
    ORDER BY cv.display
    HEAD REPORT
     stat = alterlist(reply->loc_ids,5), counter = 0
    HEAD cv.display
     pos = locateval(num,1,size(names->qual,5),cv.display,names->qual[num].name)
     IF (pos > 0)
      counter += 1
      IF (mod(counter,5)=1)
       stat = alterlist(reply->loc_ids,(counter+ 4))
      ENDIF
      reply->loc_ids[counter].id = loc.location_cd, reply->loc_ids[counter].name = cv.display, BREAK
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->loc_ids,counter)
    WITH nocounter
   ;end select
   CALL log_message("Exiting RetrieveLocIds subroutine.",log_level_debug)
 END ;Subroutine
 IF (size(reply->org_ids,5)=0
  AND size(reply->loc_ids,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL log_message("End of script: cr_get_page_master_org_loc_ids",log_level_debug)
 CALL echorecord(reply)
END GO
