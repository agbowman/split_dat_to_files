CREATE PROGRAM cp_get_authorized_section:dba
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
 SET log_program_name = "CP_GET_AUTHORIZED_SECTION"
 FREE RECORD option_rec
 RECORD option_rec(
   1 opt_cnt = i4
   1 options[*]
     2 non_i18n_lbl = vc
     2 i18n_lbl = vc
     2 val_cnt = i4
     2 info_domain = vc
     2 info_name = vc
     2 values[*]
       3 i18n_lbl = vc
       3 info_number = f8
 )
 DECLARE initializeoptionrec(null) = null
 DECLARE section_level_info_domain = vc WITH constant("CHARTING SECURITY"), protect
 DECLARE datalevel_override_info_domain = vc WITH constant("DATALEVEL CHART_SERVER"), protect
 DECLARE section_level_auth_val = i4 WITH constant(1), protect
 DECLARE datalevel_override_val = i4 WITH constant(2), protect
 DECLARE section_level_auth_lbl = vc WITH constant("Section level auth"), protect
 DECLARE datalevel_override_lbl = vc WITH constant("Data level priv"), protect
 DECLARE enable_val = f8 WITH constant(1.0), protect
 DECLARE disable_val = f8 WITH constant(0.0), protect
 DECLARE i18nhandle = i4 WITH noconstant(0), protect
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog," ",curcclrev)
 DECLARE chartingsecurityheader = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO1",
   "CHARTING SECURITY"))
 DECLARE sectionlevelauthlabel = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO2",
   "Section level authentication"))
 DECLARE dataleveloverridelabel = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO3",
   "Data level privileges"))
 DECLARE enablelabel = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO4","Enable"))
 DECLARE disablelabel = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO5","Disable"))
 DECLARE helpmenurequest = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO6","Shift/F5 for Help"
   ))
 DECLARE selectoptiontoupdate = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO7",
   "Select option to update"))
 DECLARE exitinglabel = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO8","EXITING"))
 DECLARE selectvaluetocommit = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO9",
   "Select value to commit"))
 DECLARE quitlabel = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INFO10","Quit"))
 DECLARE errinsertupdatedminfo = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR1",
   "Error inserting/updating into DM_INFO"))
 DECLARE errupdateoptionvalues = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ERR2",
   "Incorrect option value selected"))
 SUBROUTINE initializeoptionrec(null)
   IF ((option_rec->opt_cnt=0))
    SET option_rec->opt_cnt = 2
    SET stat = alterlist(option_rec->options,option_rec->opt_cnt)
    SET option_rec->options[1].non_i18n_lbl = section_level_auth_lbl
    SET option_rec->options[1].i18n_lbl = sectionlevelauthlabel
    SET option_rec->options[1].info_domain = section_level_info_domain
    SET option_rec->options[1].info_name = section_level_auth_lbl
    SET option_rec->options[1].val_cnt = 2
    SET stat = alterlist(option_rec->options[1].values,option_rec->options[1].val_cnt)
    SET option_rec->options[1].values[1].i18n_lbl = enablelabel
    SET option_rec->options[1].values[1].info_number = enable_val
    SET option_rec->options[1].values[2].i18n_lbl = disablelabel
    SET option_rec->options[1].values[2].info_number = disable_val
    SET option_rec->options[2].non_i18n_lbl = datalevel_override_lbl
    SET option_rec->options[2].i18n_lbl = dataleveloverridelabel
    SET option_rec->options[2].info_domain = datalevel_override_info_domain
    SET option_rec->options[2].info_name = datalevel_override_lbl
    SET option_rec->options[2].val_cnt = 2
    SET stat = alterlist(option_rec->options[2].values,option_rec->options[1].val_cnt)
    SET option_rec->options[2].values[1].i18n_lbl = enablelabel
    SET option_rec->options[2].values[1].info_number = enable_val
    SET option_rec->options[2].values[2].i18n_lbl = disablelabel
    SET option_rec->options[2].values[2].info_number = disable_val
   ENDIF
 END ;Subroutine
 SUBROUTINE (getoptionvaluebylabel(option_lbl=vc(val)) =i4)
   DECLARE idx = i4 WITH noconstant(0), private
   DECLARE option_idx = i4 WITH noconstant(0), private
   CALL initializeoptionrec(null)
   SET option_idx = locateval(idx,1,option_rec->opt_cnt,option_lbl,option_rec->options[idx].
    non_i18n_lbl)
   IF (option_idx > 0)
    RETURN(getdminfovaluebyoptionindex(option_idx))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getdminfovaluebyoptionindex(option_idx=i4(val)) =f8)
   CALL initializeoptionrec(null)
   FREE RECORD temp_request
   RECORD temp_request(
     1 debug_ind = i2
     1 info_domain = vc
     1 info_name = vc
     1 info_date = dq8
     1 info_char = vc
     1 info_number = f8
     1 info_long_id = f8
   )
   FREE RECORD temp_reply
   RECORD temp_reply(
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
   SET temp_request->info_name = option_rec->options[option_idx].info_name
   SET temp_request->info_domain = option_rec->options[option_idx].info_domain
   EXECUTE dm_get_dm_info  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY","TEMP_REPLY")
   IF ((temp_reply->status_data.status="Z"))
    RETURN(0)
   ELSEIF ((temp_reply->status_data.status != "S"))
    CALL echorecord(temp_reply)
    SET reply->status_data.status = temp_reply->status_data.status
    CALL moverec(temp_reply->status_data.subeventstatus,reply->status_data.subeventstatus)
    GO TO exit_script
   ENDIF
   RETURN(temp_reply->qual[1].info_number)
 END ;Subroutine
 SUBROUTINE (getdminfovalueindexbyoptionindex(option_idx=i4(val)) =i4)
   DECLARE optionvalue = f8 WITH noconstant(0.0), private
   SET optionvalue = getdminfovaluebyoptionindex(option_idx)
   DECLARE idx = i4 WITH noconstant(0), protect
   RETURN(locateval(idx,1,option_rec->options[option_idx].val_cnt,optionvalue,option_rec->options[
    option_idx].values[idx].info_number))
 END ;Subroutine
 RECORD reply(
   1 chart_section[*]
     2 chart_section_desc = vc
     2 chart_section_id = f8
     2 authorized_ind = i2
   1 all_section_authorized_ind = i2
   1 total_section_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getchartingsecurity(null) = i2
 DECLARE getallsections(null) = null
 DECLARE getsectionsbyposition(null) = null
 DECLARE getpositioncodes(null) = null
 DECLARE getnumsectionsinformat(null) = null
 DECLARE security_off = i2 WITH constant(0), protect
 DECLARE security_on = i2 WITH constant(1), protect
 DECLARE chart_sec_ind = i2 WITH noconstant(0), protect
 CALL log_message("Starting script: cp_get_authorized_section",log_level_debug)
 SET reply->status_data.status = "F"
 SET reply->all_section_authorized_ind = 1
 SET chart_sec_ind = getchartingsecurity(null)
 IF (chart_sec_ind=security_off)
  CALL getallsections(null)
 ELSE
  CALL getpositioncodes(null)
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE getpositioncodes(null)
   CALL log_message("GetPositionCodes",log_level_debug)
   RECORD sac_pos(
     1 positions[*]
       2 positioncode = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   DECLARE mode_nhs = i2 WITH protect, constant(1)
   DECLARE error_code = i4 WITH protect, noconstant(0)
   DECLARE error_message = vc WITH protect, noconstant("")
   DECLARE login_type = i4 WITH protect, noconstant(- (1))
   EXECUTE secrtl
   CALL uar_secgetclientlogontype(login_type)
   IF (login_type != mode_nhs)
    SELECT INTO "nl:"
     FROM prsnl p
     WHERE (p.person_id=reqinfo->updt_id)
     DETAIL
      stat = alterlist(sac_pos->positions,1), sac_pos->positions[1].positioncode = p.position_cd
     WITH nocounter
    ;end select
   ELSE
    DECLARE attr_originator_role = i2 WITH protect, constant(5)
    DECLARE sec_status_ok = i2 WITH protect, constant(0)
    DECLARE property_handle = i4 WITH protect, noconstant(0)
    DECLARE status = i2 WITH protect, noconstant(0)
    DECLARE property_name = vc WITH protect, noconstant("")
    DECLARE role_profile_id = vc WITH protect, noconstant("")
    SET property_handle = uar_srvcreateproperty()
    SET status = uar_secgetclientattributesext(attr_originator_role,property_handle)
    IF (status=sec_status_ok)
     SET property_name = uar_srvfirstproperty(property_handle)
     IF (size(property_name)=0)
      SET sac_pos->status_data.status = "F"
      SET sac_pos->status_data.subeventstatus.targetobjectvalue = "Failure loading role property"
     ELSE
      SET role_profile_id = uar_srvgetpropertyptr(property_handle,nullterm(property_name))
      IF (size(role_profile_id)=0)
       SET sac_pos->status_data.status = "F"
       SET sac_pos->status_data.subeventstatus.targetobjectvalue = "Failure getting role profile ID"
      ELSE
       SELECT INTO "nl:"
        FROM prsnl_org_reltn_type prt
        WHERE prt.role_profile=trim(role_profile_id)
         AND prt.active_ind=1
         AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
         AND prt.end_effective_dt_tm > cnvtdatetime(sysdate)
        ORDER BY prt.updt_dt_tm DESC
        HEAD prt.role_profile
         stat = alterlist(sac_pos->positions,1), sac_pos->positions[1].positioncode = prt
         .access_position_cd
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ELSE
     SET sac_pos->status_data.status = "F"
     SET sac_pos->status_data.subeventstatus.targetobjectvalue = concat(
      "Failure getting user role; status code: ",cnvtstring(status))
    ENDIF
    CALL uar_srvdestroyhandle(property_handle)
   ENDIF
   SET error_code = error(error_message,0)
   IF (error_code > 0)
    SET sac_pos->status_data.status = "F"
    SET sac_pos->status_data.subeventstatus.operationname = "Select"
    SET sac_pos->status_data.subeventstatus.operationstatus = "F"
    IF (login_type=mode_nhs)
     SET sac_pos->status_data.subeventstatus.targetobjectname = "PRSNL_ORG_RELTN_TYPE"
    ELSE
     SET sac_pos->status_data.subeventstatus.targetobjectname = "PRSNL"
    ENDIF
    SET sac_pos->status_data.subeventstatus.targetobjectvalue = error_message
   ELSEIF ((sac_pos->status_data.status != "F"))
    IF (curqual=1)
     SET sac_pos->status_data.status = "S"
    ELSE
     SET sac_pos->status_data.status = "Z"
    ENDIF
   ENDIF
   IF (size(sac_pos->positions,5) != 0)
    CALL getsectionsbyposition(null)
   ELSE
    CALL error_and_zero_check(0,"SAC_GET_USER_POSITIONS","EXECUTE",1,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE getallsections(null)
   CALL log_message("In GetAllSections",log_level_debug)
   SELECT DISTINCT INTO "nl:"
    cs.chart_section_id
    FROM chart_form_sects cfs,
     chart_section cs
    PLAN (cfs
     WHERE (cfs.chart_format_id=request->chart_format_id)
      AND cfs.active_ind=1)
     JOIN (cs
     WHERE cs.chart_section_id=cfs.chart_section_id
      AND cs.active_ind=1)
    ORDER BY cfs.cs_sequence_num
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 += 1
     IF (mod(count1,10)=1)
      stat = alterlist(reply->chart_section,(count1+ 9))
     ENDIF
     reply->chart_section[count1].chart_section_desc = cs.chart_section_desc, reply->chart_section[
     count1].chart_section_id = cs.chart_section_id, reply->chart_section[count1].authorized_ind = 1
    FOOT REPORT
     stat = alterlist(reply->chart_section,count1), reply->total_section_cnt = count1
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_SECTION","TABLE",1,1)
 END ;Subroutine
 SUBROUTINE getsectionsbyposition(null)
   CALL log_message("In GetSectionsByPosition",log_level_debug)
   DECLARE idx = i4
   DECLARE idxstart = i4 WITH noconstant(1)
   DECLARE position_count = i4 WITH noconstant(0)
   SET position_count = size(sac_pos->positions,5)
   SELECT DISTINCT INTO "nl:"
    cs.chart_section_id
    FROM chart_form_sects cfs,
     sect_position_reltn spr,
     chart_section cs
    PLAN (cfs
     WHERE (cfs.chart_format_id=request->chart_format_id)
      AND cfs.active_ind=1)
     JOIN (cs
     WHERE cs.chart_section_id=cfs.chart_section_id
      AND cs.active_ind=1)
     JOIN (spr
     WHERE (spr.chart_format_id= Outerjoin(request->chart_format_id))
      AND (spr.chart_section_id= Outerjoin(cs.chart_section_id)) )
    ORDER BY cfs.cs_sequence_num
    HEAD REPORT
     count = 0
    DETAIL
     count += 1
     IF (mod(count,10)=1)
      stat = alterlist(reply->chart_section,(count+ 9))
     ENDIF
     reply->chart_section[count].chart_section_desc = cs.chart_section_desc, reply->chart_section[
     count].chart_section_id = cs.chart_section_id
     IF (locateval(idx,idxstart,position_count,spr.position_cd,sac_pos->positions[idx].positioncode))
      reply->chart_section[count].authorized_ind = 1
     ELSE
      reply->chart_section[count].authorized_ind = 0, reply->all_section_authorized_ind = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->chart_section,count)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"SECT_POSITION_RELTN","TABLE",1,1)
   CALL getnumsectionsinformat(null)
 END ;Subroutine
 SUBROUTINE getnumsectionsinformat(null)
   CALL log_message("In GetNumSectionsInFormat",log_level_debug)
   SELECT
    total_section_cnt = count(*)
    FROM chart_form_sects cfs
    WHERE (cfs.chart_format_id=request->chart_format_id)
     AND cfs.active_ind=1
    DETAIL
     reply->total_section_cnt = total_section_cnt
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_FORM_SECTS","TABLE",1,1)
 END ;Subroutine
 SUBROUTINE getchartingsecurity(null)
   CALL log_message("In GetChartingSecurity",log_level_debug)
   DECLARE option_idx = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE return_val = i2 WITH noconstant(0)
   CALL initializeoptionrec(null)
   SET option_idx = locateval(idx,1,option_rec->opt_cnt,section_level_auth_lbl,option_rec->options[
    idx].non_i18n_lbl)
   SET return_val = getdminfovaluebyoptionindex(option_idx)
   RETURN(return_val)
 END ;Subroutine
#exit_script
 CALL log_message("End of script: cp_get_authorized_section",log_level_debug)
 CALL echorecord(reply)
END GO
