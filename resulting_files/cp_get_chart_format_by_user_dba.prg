CREATE PROGRAM cp_get_chart_format_by_user:dba
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
 SET log_program_name = "CP_GET_CHART_FORMAT_BY_USER"
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
   1 qual[*]
     2 chart_format_desc = vc
     2 chart_format_id = f8
   1 chart_sec_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getchartingsecurity(null) = i2
 DECLARE getallformats(null) = null
 DECLARE getformatsbyuser(null) = null
 DECLARE getorganizations(null) = null
 DECLARE security_off = i2 WITH constant(0), protect
 DECLARE security_on = i2 WITH constant(1), protect
 DECLARE get_orgs_failed = i2 WITH constant(0), protect
 DECLARE get_orgs_successful = i2 WITH constant(1), protect
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE stat = i4 WITH noconstant(0)
 CALL log_message("Starting script: cp_get_chart_format_by_user",log_level_debug)
 SET reply->status_data.status = "F"
 SET reply->chart_sec_ind = getchartingsecurity(null)
 IF ((reply->chart_sec_ind=security_off))
  CALL getallformats(null)
 ELSE
  CALL getorganizations(null)
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE getorganizations(null)
   CALL log_message("In GetOrganizations",log_level_debug)
   IF (validate(_sacrtl_org_inc_,99999)=99999)
    DECLARE _sacrtl_org_inc_ = i2 WITH constant(1)
    RECORD sac_org(
      1 organizations[*]
        2 organization_id = f8
        2 confid_cd = f8
        2 confid_level = i4
    )
    EXECUTE secrtl
    EXECUTE sacrtl
    DECLARE orgcnt = i4 WITH protected, noconstant(0)
    DECLARE secstat = i2
    DECLARE logontype = i4 WITH protect, noconstant(- (1))
    DECLARE dynamic_org_ind = i4 WITH protect, noconstant(- (1))
    DECLARE dcur_trustid = f8 WITH protect, noconstant(0.0)
    DECLARE dynorg_enabled = i4 WITH constant(1)
    DECLARE dynorg_disabled = i4 WITH constant(0)
    DECLARE logontype_nhs = i4 WITH constant(1)
    DECLARE logontype_legacy = i4 WITH constant(0)
    DECLARE confid_cnt = i4 WITH protected, noconstant(0)
    RECORD confid_codes(
      1 list[*]
        2 code_value = f8
        2 coll_seq = f8
    )
    CALL uar_secgetclientlogontype(logontype)
    CALL echo(build("logontype:",logontype))
    IF (logontype != logontype_nhs)
     SET dynamic_org_ind = dynorg_disabled
    ENDIF
    IF (logontype=logontype_nhs)
     SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
       DECLARE scur_trust = vc
       DECLARE pref_val = vc
       DECLARE is_enabled = i4 WITH constant(1)
       DECLARE is_disabled = i4 WITH constant(0)
       SET scur_trust = cnvtstring(dtrustid)
       SET scur_trust = concat(scur_trust,".00")
       IF ( NOT (validate(pref_req,0)))
        RECORD pref_req(
          1 write_ind = i2
          1 delete_ind = i2
          1 pref[*]
            2 contexts[*]
              3 context = vc
              3 context_id = vc
            2 section = vc
            2 section_id = vc
            2 subgroup = vc
            2 entries[*]
              3 entry = vc
              3 values[*]
                4 value = vc
        )
       ENDIF
       IF ( NOT (validate(pref_rep,0)))
        RECORD pref_rep(
          1 pref[*]
            2 section = vc
            2 section_id = vc
            2 subgroup = vc
            2 entries[*]
              3 pref_exists_ind = i2
              3 entry = vc
              3 values[*]
                4 value = vc
          1 status_data
            2 status = c1
            2 subeventstatus[1]
              3 operationname = c25
              3 operationstatus = c1
              3 targetobjectname = c25
              3 targetobjectvalue = vc
        )
       ENDIF
       SET stat = alterlist(pref_req->pref,1)
       SET stat = alterlist(pref_req->pref[1].contexts,2)
       SET stat = alterlist(pref_req->pref[1].entries,1)
       SET pref_req->pref[1].contexts[1].context = "organization"
       SET pref_req->pref[1].contexts[1].context_id = scur_trust
       SET pref_req->pref[1].contexts[2].context = "default"
       SET pref_req->pref[1].contexts[2].context_id = "system"
       SET pref_req->pref[1].section = "workflow"
       SET pref_req->pref[1].section_id = "UK Trust Security"
       SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
       EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
       IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
        RETURN(is_enabled)
       ELSE
        RETURN(is_disabled)
       ENDIF
     END ;Subroutine
     DECLARE hprop = i4 WITH protect, noconstant(0)
     DECLARE tmpstat = i2
     DECLARE spropname = vc
     DECLARE sroleprofile = vc
     SET hprop = uar_srvcreateproperty()
     SET tmpstat = uar_secgetclientattributesext(5,hprop)
     SET spropname = uar_srvfirstproperty(hprop)
     SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
     SELECT INTO "nl:"
      FROM prsnl_org_reltn_type prt,
       prsnl_org_reltn por
      PLAN (prt
       WHERE prt.role_profile=sroleprofile
        AND prt.active_ind=1
        AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (por
       WHERE (por.organization_id= Outerjoin(prt.organization_id))
        AND (por.person_id= Outerjoin(prt.prsnl_id))
        AND (por.active_ind= Outerjoin(1))
        AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
        AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
      ORDER BY por.prsnl_org_reltn_id
      DETAIL
       orgcnt = 1, secstat = alterlist(sac_org->organizations,1), user_person_id = prt.prsnl_id,
       sac_org->organizations[1].organization_id = prt.organization_id, sac_org->organizations[1].
       confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
       sac_org->organizations[1].confid_level =
       IF (confid_cd > 0) confid_cd
       ELSE 0
       ENDIF
      WITH maxrec = 1
     ;end select
     SET dcur_trustid = sac_org->organizations[1].organization_id
     SET dynamic_org_ind = getdynamicorgpref(dcur_trustid)
     CALL uar_srvdestroyhandle(hprop)
    ENDIF
    IF (dynamic_org_ind=dynorg_disabled)
     SET confid_cnt = 0
     SELECT INTO "NL:"
      c.code_value, c.collation_seq
      FROM code_value c
      WHERE c.code_set=87
      DETAIL
       confid_cnt += 1
       IF (mod(confid_cnt,10)=1)
        secstat = alterlist(confid_codes->list,(confid_cnt+ 9))
       ENDIF
       confid_codes->list[confid_cnt].code_value = c.code_value, confid_codes->list[confid_cnt].
       coll_seq = c.collation_seq
      WITH nocounter
     ;end select
     SET secstat = alterlist(confid_codes->list,confid_cnt)
     SELECT DISTINCT INTO "nl:"
      FROM prsnl_org_reltn por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.active_ind=1
       AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
      HEAD REPORT
       IF (orgcnt > 0)
        secstat = alterlist(sac_org->organizations,100)
       ENDIF
      DETAIL
       orgcnt += 1
       IF (mod(orgcnt,100)=1)
        secstat = alterlist(sac_org->organizations,(orgcnt+ 99))
       ENDIF
       sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
       orgcnt].confid_cd = por.confid_level_cd
      FOOT REPORT
       secstat = alterlist(sac_org->organizations,orgcnt)
      WITH nocounter
     ;end select
     SELECT INTO "NL:"
      FROM (dummyt d1  WITH seq = value(orgcnt)),
       (dummyt d2  WITH seq = value(confid_cnt))
      PLAN (d1)
       JOIN (d2
       WHERE (sac_org->organizations[d1.seq].confid_cd=confid_codes->list[d2.seq].code_value))
      DETAIL
       sac_org->organizations[d1.seq].confid_level = confid_codes->list[d2.seq].coll_seq
      WITH nocounter
     ;end select
    ELSEIF (dynamic_org_ind=dynorg_enabled)
     DECLARE nhstrustchild_org_org_reltn_cd = f8
     SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
     SELECT INTO "nl:"
      FROM org_org_reltn oor
      PLAN (oor
       WHERE oor.organization_id=dcur_trustid
        AND oor.active_ind=1
        AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
        AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
      HEAD REPORT
       IF (orgcnt > 0)
        secstat = alterlist(sac_org->organizations,10)
       ENDIF
      DETAIL
       IF (oor.related_org_id > 0)
        orgcnt += 1
        IF (mod(orgcnt,10)=1)
         secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
        ENDIF
        sac_org->organizations[orgcnt].organization_id = oor.related_org_id
       ENDIF
      FOOT REPORT
       secstat = alterlist(sac_org->organizations,orgcnt)
      WITH nocounter
     ;end select
    ELSE
     CALL echo(build("Unexpected login type: ",dynamimc_org_ind))
    ENDIF
   ENDIF
   IF (size(sac_org->organizations,5) != 0)
    CALL getformatsbyuser(null)
   ELSE
    CALL error_and_zero_check(0,"SAC_GET_USER_ORGANIZATIONS","EXECUTE",1,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE getformatsbyuser(null)
   CALL log_message("In GetFormatsByUser",log_level_debug)
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE org_cnt = i2 WITH public, noconstant(0)
   SET org_cnt = size(sac_org->organizations,5)
   SET noptimizedtotal = (ceil((cnvtreal(org_cnt)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(sac_org->organizations,noptimizedtotal)
   FOR (i = (org_cnt+ 1) TO noptimizedtotal)
     SET sac_org->organizations[i].organization_id = sac_org->organizations[org_cnt].organization_id
   ENDFOR
   SELECT DISTINCT INTO "nl:"
    cf.chart_format_id
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_format cf,
     format_org_reltn fo
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (fo
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),fo.organization_id,sac_org->organizations[
      idx].organization_id,
      bind_cnt)
      AND fo.active_ind=1)
     JOIN (cf
     WHERE cf.chart_format_id=fo.chart_format_id
      AND cf.active_ind=1)
    ORDER BY cnvtupper(cf.chart_format_desc)
    HEAD REPORT
     count = 0
    DETAIL
     count += 1
     IF (mod(count,10)=1)
      stat = alterlist(reply->qual,(count+ 9))
     ENDIF
     reply->qual[count].chart_format_desc = cf.chart_format_desc, reply->qual[count].chart_format_id
      = cf.chart_format_id
    FOOT REPORT
     stat = alterlist(reply->qual,count)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_FORMAT","TABLE",1,1)
 END ;Subroutine
 SUBROUTINE getallformats(null)
   CALL log_message("In GetAllFormats",log_level_debug)
   SELECT DISTINCT INTO "nl:"
    cf.chart_format_id
    FROM chart_format cf
    WHERE cf.chart_format_id > 0
     AND cf.active_ind=1
    ORDER BY cnvtupper(cf.chart_format_desc)
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 += 1
     IF (mod(count1,10)=1)
      stat = alterlist(reply->qual,(count1+ 9))
     ENDIF
     reply->qual[count1].chart_format_desc = cf.chart_format_desc, reply->qual[count1].
     chart_format_id = cf.chart_format_id
    FOOT REPORT
     stat = alterlist(reply->qual,count1)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_FORMAT","TABLE",1,1)
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
 CALL log_message("End of script: cp_get_chart_format_by_user",log_level_debug)
 CALL echorecord(reply)
END GO
