CREATE PROGRAM bbt_get_orders_by_accn:dba
 RECORD reply(
   1 person_id = f8
   1 encntr_id = f8
   1 qual[*]
     2 order_id = f8
     2 order_mnemonic = vc
     2 status_flag = i2
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 order_status_cd = f8
     2 order_status_disp = vc
     2 order_status_mean = c12
     2 order_comment_ind = i2
     2 activity_type = c12
     2 updt_cnt = i4
     2 bb_processing_cd = f8
     2 bb_processing_disp = vc
     2 bb_processing_mean = c12
     2 bb_default_phases_cd = f8
     2 total_xm_cnt = i4
     2 drawn_dt_tm = dq8
     2 drawn_username = c25
     2 phase_grp_cd = f8
     2 phase_grp_disp = vc
     2 container_serv_res_cnt = i4
     2 container_serv_res[*]
       3 specimen_id = f8
       3 container_id = f8
       3 order_serv_res_upd_cnt = i4
       3 service_resource_cd = f8
       3 service_resource_disp = vc
       3 cell_cnt = i4
       3 cells[*]
         4 order_id = f8
         4 order_cell_id = f8
         4 cell_cd = f8
         4 cell_disp = vc
         4 cell_mean = c12
         4 product_id = f8
         4 bb_result_id = f8
         4 order_cell_updt_cnt = i4
       3 products_cnt = i4
       3 products[*]
         4 product_id = f8
         4 bb_result_id = f8
         4 product_event_id = f8
         4 updt_cnt = i4
       3 assays_cnt = i4
       3 assays[*]
         4 task_assay_cd = f8
         4 sequence = i4
         4 pending_ind = i2
         4 order_phase_id = f8
       3 expiration_dt_tm = dq8
     2 last_update_provider_id = f8
     2 spec_flex_ind = i2
     2 order_encntr_facility_cd = f8
     2 testing_facility_cd = f8
     2 activity_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_rsrc_security(
   1 l_cnt = i4
   1 list[*]
     2 service_resource_cd = f8
     2 viewable_srvc_rsrc_ind = i2
   1 security_enabled = i2
 )
 RECORD default_service_type_cd(
   1 service_type_cd_list[*]
     2 service_type_cd = f8
 )
 DECLARE nres_sec_failed = i2 WITH protect, constant(0)
 DECLARE nres_sec_passed = i2 WITH protect, constant(1)
 DECLARE nres_sec_err = i2 WITH protect, constant(2)
 DECLARE nres_sec_msg_type = i2 WITH protect, constant(0)
 DECLARE ncase_sec_msg_type = i2 WITH protect, constant(1)
 DECLARE ncorr_group_sec_msg_type = i2 WITH protect, constant(2)
 DECLARE sres_sec_error_msg = c23 WITH protect, constant("RESOURCE SECURITY ERROR")
 DECLARE sres_sec_failed_msg = c24 WITH protect, constant("RESOURCE SECURITY FAILED")
 DECLARE scase_sec_failed_msg = c20 WITH protect, constant("CASE SECURITY FAILED")
 DECLARE scorr_group_sec_failed_msg = c24 WITH protect, constant("CORR GRP SECURITY FAILED")
 DECLARE m_nressecind = i2 WITH protect, noconstant(0)
 DECLARE m_sressecstatus = c1 WITH protect, noconstant("S")
 DECLARE m_nressecapistatus = i2 WITH protect, noconstant(0)
 DECLARE m_nressecerrorind = i2 WITH protect, noconstant(0)
 DECLARE m_lressecfailedcnt = i4 WITH protect, noconstant(0)
 DECLARE m_lresseccheckedcnt = i4 WITH protect, noconstant(0)
 DECLARE m_nressecalterstatus = i2 WITH protect, noconstant(0)
 DECLARE m_lressecstatusblockcnt = i4 WITH protect, noconstant(0)
 DECLARE m_ntaskgrantedind = i2 WITH protect, noconstant(0)
 DECLARE m_sfailedmsg = c25 WITH protect
 DECLARE m_bresourceapicalled = i2 WITH protect, noconstant(0)
 SET temp_rsrc_security->l_cnt = 0
 SUBROUTINE (initresourcesecurity(resource_security_ind=i2) =null)
   IF (resource_security_ind=1)
    SET m_nressecind = true
   ELSE
    SET m_nressecind = false
   ENDIF
 END ;Subroutine
 SUBROUTINE (isresourceviewable(service_resource_cd=f8) =i2)
   DECLARE srvc_rsrc_idx = i4 WITH protect, noconstant(0)
   DECLARE l_srvc_rsrc_pos = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET m_lresseccheckedcnt += 1
   IF (m_nressecind=false)
    RETURN(true)
   ENDIF
   IF (m_nressecerrorind=true)
    RETURN(false)
   ENDIF
   IF (service_resource_cd=0)
    RETURN(true)
   ENDIF
   IF (m_bresourceapicalled=true)
    IF ((temp_rsrc_security->security_enabled=1)
     AND size(temp_rsrc_security->list,5)=0)
     SET m_nressecapistatus = nres_sec_failed
    ELSEIF ((temp_rsrc_security->security_enabled=0)
     AND size(temp_rsrc_security->list,5)=0)
     SET m_nressecapistatus = nres_sec_passed
    ELSEIF ((temp_rsrc_security->l_cnt > 0))
     SET l_srvc_rsrc_pos = locateval(srvc_rsrc_idx,1,temp_rsrc_security->l_cnt,service_resource_cd,
      temp_rsrc_security->list[srvc_rsrc_idx].service_resource_cd)
     IF (l_srvc_rsrc_pos > 0)
      IF ((temp_rsrc_security->list[l_srvc_rsrc_pos].viewable_srvc_rsrc_ind=1))
       SET m_nressecapistatus = nres_sec_passed
      ELSE
       SET m_nressecapistatus = nres_sec_failed
      ENDIF
     ELSE
      SET m_nressecapistatus = nres_sec_failed
     ENDIF
    ENDIF
   ELSE
    RECORD request_3202551(
      1 prsnl_id = f8
      1 explicit_ind = i4
      1 debug_ind = i4
      1 service_type_cd_list[*]
        2 service_type_cd = f8
    )
    RECORD reply_3202551(
      1 security_enabled = i2
      1 service_resource_list[*]
        2 service_resource_cd = f8
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET request_3202551->prsnl_id = reqinfo->updt_id
    IF (size(default_service_type_cd->service_type_cd_list,5) > 0)
     SET stat = alterlist(request_3202551->service_type_cd_list,size(default_service_type_cd->
       service_type_cd_list,5))
     FOR (idx = 1 TO size(default_service_type_cd->service_type_cd_list,5))
       SET request_3202551->service_type_cd_list[idx].service_type_cd = default_service_type_cd->
       service_type_cd_list[idx].service_type_cd
     ENDFOR
    ELSE
     SET stat = alterlist(request_3202551->service_type_cd_list,5)
     SET request_3202551->service_type_cd_list[1].service_type_cd = uar_get_code_by("MEANING",223,
      "SECTION")
     SET request_3202551->service_type_cd_list[2].service_type_cd = uar_get_code_by("MEANING",223,
      "SUBSECTION")
     SET request_3202551->service_type_cd_list[3].service_type_cd = uar_get_code_by("MEANING",223,
      "BENCH")
     SET request_3202551->service_type_cd_list[4].service_type_cd = uar_get_code_by("MEANING",223,
      "INSTRUMENT")
     SET request_3202551->service_type_cd_list[5].service_type_cd = uar_get_code_by("MEANING",223,
      "DEPARTMENT")
    ENDIF
    EXECUTE msvc_get_prsnl_svc_resources  WITH replace("REQUEST",request_3202551), replace("REPLY",
     reply_3202551)
    SET m_bresourceapicalled = true
    IF ((reply_3202551->status_data.status != "S"))
     SET m_nressecapistatus = nres_sec_err
    ELSEIF ((reply_3202551->security_enabled=1)
     AND size(reply_3202551->service_resource_list,5)=0)
     SET temp_rsrc_security->security_enabled = 1
     SET m_nressecapistatus = nres_sec_failed
    ELSEIF ((reply_3202551->security_enabled=0)
     AND size(reply_3202551->service_resource_list,5)=0)
     SET temp_rsrc_security->security_enabled = 0
     SET m_nressecapistatus = nres_sec_passed
    ELSE
     SET temp_rsrc_security->l_cnt = size(reply_3202551->service_resource_list,5)
     SET temp_rsrc_security->security_enabled = reply_3202551->security_enabled
     IF ((temp_rsrc_security->l_cnt > 0))
      SET stat = alterlist(temp_rsrc_security->list,temp_rsrc_security->l_cnt)
      FOR (idx = 1 TO size(reply_3202551->service_resource_list,5))
       SET temp_rsrc_security->list[idx].service_resource_cd = reply_3202551->service_resource_list[
       idx].service_resource_cd
       SET temp_rsrc_security->list[idx].viewable_srvc_rsrc_ind = 1
      ENDFOR
     ENDIF
     SET l_srvc_rsrc_pos = locateval(srvc_rsrc_idx,1,temp_rsrc_security->l_cnt,service_resource_cd,
      temp_rsrc_security->list[srvc_rsrc_idx].service_resource_cd)
     IF (l_srvc_rsrc_pos > 0)
      IF ((temp_rsrc_security->list[l_srvc_rsrc_pos].viewable_srvc_rsrc_ind=1))
       SET m_nressecapistatus = nres_sec_passed
      ELSE
       SET m_nressecapistatus = nres_sec_failed
      ENDIF
     ELSE
      SET m_nressecapistatus = nres_sec_failed
     ENDIF
    ENDIF
   ENDIF
   CASE (m_nressecapistatus)
    OF nres_sec_passed:
     RETURN(true)
    OF nres_sec_failed:
     SET m_lressecfailedcnt += 1
     RETURN(false)
    ELSE
     SET m_nressecerrorind = true
     RETURN(false)
   ENDCASE
 END ;Subroutine
 SUBROUTINE (getresourcesecuritystatus(fail_all_ind=i2) =c1)
  IF (m_nressecerrorind=true)
   SET m_sressecstatus = "F"
  ELSEIF (m_lresseccheckedcnt > 0
   AND m_lresseccheckedcnt=m_lressecfailedcnt)
   SET m_sressecstatus = "Z"
  ELSEIF (fail_all_ind=1
   AND m_lressecfailedcnt > 0)
   SET m_sressecstatus = "Z"
  ELSE
   SET m_sressecstatus = "S"
  ENDIF
  RETURN(m_sressecstatus)
 END ;Subroutine
 SUBROUTINE (populateressecstatusblock(message_type=i2) =null)
   IF (((m_sressecstatus="S") OR (validate(reply->status_data.status,"-1")="-1")) )
    RETURN
   ENDIF
   SET m_lressecstatusblockcnt = size(reply->status_data.subeventstatus,5)
   IF (m_lressecstatusblockcnt=1
    AND trim(reply->status_data.subeventstatus[1].operationname)="")
    SET m_ressecalterstatus = 0
   ELSE
    SET m_lressecstatusblockcnt += 1
    SET m_nressecalterstatus = alter(reply->status_data.subeventstatus,m_lressecstatusblockcnt)
   ENDIF
   CASE (message_type)
    OF ncase_sec_msg_type:
     SET m_sfailedmsg = scase_sec_failed_msg
    OF ncorr_group_sec_msg_type:
     SET m_sfailedmsg = scorr_group_sec_failed_msg
    ELSE
     SET m_sfailedmsg = sres_sec_failed_msg
   ENDCASE
   CASE (m_sressecstatus)
    OF "F":
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationname =
     sres_sec_error_msg
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationstatus = "F"
    OF "Z":
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationname = m_sfailedmsg
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationstatus = "Z"
   ENDCASE
 END ;Subroutine
 SUBROUTINE (istaskgranted(task_number=i4) =i2)
   SET m_ntaskgrantedind = false
   SELECT INTO "nl:"
    FROM application_group ag,
     task_access ta
    PLAN (ag
     WHERE (ag.position_cd=reqinfo->position_cd)
      AND ag.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ag.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (ta
     WHERE ta.app_group_cd=ag.app_group_cd
      AND ta.task_number=task_number)
    DETAIL
     m_ntaskgrantedind = true
    WITH nocounter
   ;end select
   RETURN(m_ntaskgrantedind)
 END ;Subroutine
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   DECLARE code_set = i4
   DECLARE cdf_meaning = c12
   DECLARE code_cnt = i4
   DECLARE code_value = f8
   SET code_set = sub_code_set
   SET cdf_meaning = sub_cdf_meaning
   SET code_cnt = 1
   SET sub_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,code_value)
   IF (stat=0)
    IF (code_cnt != 1)
     SET code_value = 0
    ENDIF
   ELSE
    SET code_value = 0
   ENDIF
   RETURN(code_value)
 END ;Subroutine
 DECLARE log_program_name = vc WITH protect, noconstant(curprog)
 IF (validate(glbsl_def,999)=999)
  CALL echo("Declaring GLBSL_DEF")
  DECLARE glbsl_def = i2 WITH protect, constant(1)
  DECLARE log_override_ind = i2 WITH protect, noconstant(0)
  SET log_override_ind = 0
  DECLARE log_level_error = i2 WITH protect, noconstant(0)
  DECLARE log_level_warning = i2 WITH protect, noconstant(1)
  DECLARE log_level_audit = i2 WITH protect, noconstant(2)
  DECLARE log_level_info = i2 WITH protect, noconstant(3)
  DECLARE log_level_debug = i2 WITH protect, noconstant(4)
  DECLARE hsys = h WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
  CALL uar_syscreatehandle(hsys,sysstat)
  DECLARE lglbslsubeventcnt = i4 WITH protect, noconstant(0)
  DECLARE iglbslloggingstat = i2 WITH protect, noconstant(0)
  DECLARE lglbslsubeventsize = i4 WITH protect, noconstant(0)
  DECLARE iglbslloglvloverrideind = i2 WITH protect, noconstant(0)
  DECLARE sglbsllogtext = vc WITH protect, noconstant("")
  DECLARE sglbsllogevent = vc WITH protect, noconstant("")
  DECLARE iglbslholdloglevel = i2 WITH protect, noconstant(0)
  DECLARE iglbslerroroccured = i2 WITH protect, noconstant(0)
  DECLARE lglbsluarmsgwritestat = i4 WITH protect, noconstant(0)
  DECLARE glbsl_info_domain = vc WITH protect, constant("PATHNET SCRIPT LOGGING")
  DECLARE glbsl_logging_on = c1 WITH protect, constant("L")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=glbsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=glbsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET iglbslloglvloverrideind = 0
   SET sglbsllogtext = ""
   SET sglbsllogevent = ""
   SET sglbsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iglbslholdloglevel = loglvl
   ELSE
    IF (glbsl_msg_level < loglvl)
     SET iglbslholdloglevel = glbsl_msg_level
     SET iglbslloglvloverrideind = 1
    ELSE
     SET iglbslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iglbslloglvloverrideind=1)
    SET sglbsllogevent = "ScriptOverride"
   ELSE
    CASE (iglbslholdloglevel)
     OF log_level_error:
      SET sglbsllogevent = "ScriptError"
     OF log_level_warning:
      SET sglbsllogevent = "ScriptWarning"
     OF log_level_audit:
      SET sglbsllogevent = "ScriptAudit"
     OF log_level_info:
      SET sglbsllogevent = "ScriptInfo"
     OF log_level_debug:
      SET sglbsllogevent = "ScriptDebug"
    ENDCASE
   ENDIF
   SET lglbsluarmsgwritestat = uar_msgwrite(glbsl_msg_default,0,nullterm(sglbsllogevent),
    iglbslholdloglevel,nullterm(sglbsllogtext))
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET iglbslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET iglbslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(iglbslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationstatus))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectvalue))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt += 1
     SET iglbslloggingstat = alter(reply->status_data.subeventstatus,lglbslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF (validate(bbt_get_pref_def,999)=999)
  DECLARE bbt_get_pref_def = i2 WITH protect, constant(1)
  RECORD prefvalues(
    1 prefs[*]
      2 value = vc
  )
  RECORD flexspectransparams(
    1 params[*]
      2 index = i4
      2 transfusionstartrange = i4
      2 transfusionendrange = i4
      2 specimenexpiration = i4
  )
  RECORD encounterlocations(
    1 locs[*]
      2 encfacilitycd = f8
  )
  DECLARE pref_level_bb = i2 WITH public, constant(1)
  DECLARE pref_level_flex = i2 WITH public, constant(2)
  DECLARE flex_spec_group = vc WITH protect, constant("flexible specimen")
  DECLARE pref_flex_spec_yes = vc WITH protect, constant("YES")
  DECLARE pref_flex_spec_no = vc WITH protect, constant("NO")
  DECLARE prefentryexists = i2 WITH protect, noconstant(0)
  DECLARE statbbpref = i2 WITH protect, noconstant(0)
 ENDIF
 SUBROUTINE (bbtgetencounterlocations(facility_code=f8(value),level_flag=i2(value)) =i2)
   DECLARE index = i2 WITH protect, noconstant(0)
   DECLARE loccnt = i2 WITH protect, noconstant(0)
   DECLARE prefcount = i2 WITH protect, noconstant(0)
   DECLARE flexprefentry = vc WITH protect, constant("patient encounter locations")
   SET statbbpref = initrec(encounterlocations)
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    flexprefentry)
   IF ((statbbpref=- (1)))
    IF (prefentryexists=1)
     RETURN(1)
    ELSE
     RETURN(- (1))
    ENDIF
   ENDIF
   SET prefcount = size(prefvalues->prefs,5)
   IF (prefcount=0)
    RETURN(1)
   ENDIF
   FOR (index = 1 TO prefcount)
     IF (cnvtreal(prefvalues->prefs[index].value) > 0.0)
      SET loccnt += 1
      IF (size(encounterlocations->locs,5) < loccnt)
       SET stat = alterlist(encounterlocations->locs,(loccnt+ 9))
      ENDIF
      SET encounterlocations->locs[loccnt].encfacilitycd = cnvtreal(prefvalues->prefs[index].value)
     ENDIF
   ENDFOR
   SET stat = alterlist(encounterlocations->locs,loccnt)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (bbtgethistoricinfopreference(facility_code=f8(value)) =i2)
   DECLARE historical_demog_ind = i2 WITH protect, noconstant(0)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("print historical demographics")
   DECLARE code_set = i4 WITH protect, constant(20790)
   DECLARE historycd = f8 WITH protect, constant(uar_get_code_by("MEANING",code_set,"HISTORY"))
   IF ((historycd=- (1)))
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value_extension cve
    WHERE cve.code_value=historycd
     AND cve.field_name="OPTION"
     AND cve.code_set=code_set
    DETAIL
     IF (trim(cve.field_value,3)="1")
      historical_demog_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (historical_demog_ind=0)
    RETURN(0)
   ENDIF
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="Yes"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetcustompacklistpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("custom packing list program name")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetrequiredcourierdispenseassignpreference(facility_code=f8(value)) =i2)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("require dispense courier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetrequiredcourierreturnproductspreference(facility_code=f8(value)) =i2)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("require return courier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetinterfaceddevicespreference(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("uses interfaced devices")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetbbtestingfacility(facility_code=f8(value)) =f8)
   RETURN(bbtgetflexspectestingfacility(facility_code))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspectestingfacility(facility_code=f8(value)) =f8)
   DECLARE prefentry = vc WITH protect, constant("transfusion service facility")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF ((((statbbpref=- (1))) OR (size(prefvalues->prefs,5) > 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(prefvalues->prefs,5)=1)
    IF (size(trim(prefvalues->prefs[1].value)) > 0)
     SET strlogmessage = build("PrefEntry- ",prefentry,":",prefvalues->prefs[1].value,
      ",Facility Code:",
      facility_code)
     CALL log_message(strlogmessage,log_level_debug)
     RETURN(cnvtreal(trim(prefvalues->prefs[1].value,3)))
    ELSE
     RETURN(0.0)
    ENDIF
   ELSE
    RETURN(0.0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecenableflexexpiration(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("enable flex expiration")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF ((((statbbpref=- (1))) OR (size(prefvalues->prefs,5) > 1)) )
    SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
    CALL log_message(strlogmessage,log_level_error)
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(prefvalues->prefs,5)=1)
    IF ((prefvalues->prefs[1].value="1"))
     RETURN(1)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecdefclinsigantibodyparams(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("def clin sig antibody params")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmalloexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("xm allogeneic expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmautoexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("xm autologous expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecmaxspecexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("max specimen expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecclinsigantibodiesexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("clin sig antibodies exp units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecextendtransfoverride(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend transf override")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ELSEIF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_no))
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspeccalcposttransfspecsfromdawndt(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("calc post transf specs from drawn dt")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ELSEIF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_no))
     RETURN(0)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecexpunittypemean(facility_code=f8(value)) =c12)
   DECLARE prefentry = vc WITH protect, constant("flex spec expiration unit type")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(trim(prefvalues->prefs[1].value,3))
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmtagsprinter(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("xm tags printer")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(trim(prefvalues->prefs[1].value))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecexceptionrptprinter(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("exception rpt printer")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(trim(prefvalues->prefs[1].value))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspectransfusionparameters(facility_code=f8(value)) =i2)
   DECLARE index = i2 WITH protect, noconstant(0)
   DECLARE prefcount = i2 WITH protect, noconstant(0)
   DECLARE strposhold = i2 WITH protect, noconstant(0)
   DECLARE strprevposhold = i2 WITH protect, noconstant(0)
   DECLARE strsize = i2 WITH protect, noconstant(0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE maxparamitems = i2 WITH protect, constant(4)
   DECLARE prefentry = vc WITH protect, constant("transfusion parameters")
   SET statbbpref = initrec(flexspectransparams)
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   SET prefcount = size(prefvalues->prefs,5)
   IF (((statbbpref != 1) OR (prefcount < 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET statbbpref = alterlist(flexspectransparams->params,prefcount)
   FOR (index = 1 TO prefcount)
     SET strsize = 0
     SET strsize = size(prefvalues->prefs[index].value)
     SET strposhold = findstring(",",prefvalues->prefs[index].value)
     SET flexspectransparams->params[index].index = cnvtint(substring(1,(strposhold - 1),prefvalues->
       prefs[index].value))
     SET strprevposhold = strposhold
     SET strposhold = findstring(",",prefvalues->prefs[index].value,(strprevposhold+ 1))
     SET flexspectransparams->params[index].transfusionstartrange = cnvtint(substring((strprevposhold
       + 1),((strposhold - strprevposhold) - 1),prefvalues->prefs[index].value))
     SET strprevposhold = strposhold
     SET strposhold = findstring(",",prefvalues->prefs[index].value,(strprevposhold+ 1))
     SET flexspectransparams->params[index].transfusionendrange = cnvtint(substring((strprevposhold+
       1),((strposhold - strprevposhold) - 1),prefvalues->prefs[index].value))
     SET flexspectransparams->params[index].specimenexpiration = cnvtint(substring((strposhold+ 1),(
       strsize - strposhold),prefvalues->prefs[index].value))
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getbbpreference(sfacilityctx=vc,spositionctx=vc,suserctx=vc,ssubgroup=vc,sprefentry=vc
  ) =i2)
   DECLARE success_ind = i2 WITH protect, noconstant(0)
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hgroup2 = i4 WITH protect, noconstant(0)
   DECLARE hsubgroup = i4 WITH protect, noconstant(0)
   DECLARE hsubgroup2 = i4 WITH protect, noconstant(0)
   DECLARE hval = i4 WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE hentry = i4 WITH protect, noconstant(0)
   DECLARE idxentry = i4 WITH protect, noconstant(0)
   DECLARE idxattr = i4 WITH protect, noconstant(0)
   DECLARE idxval = i4 WITH protect, noconstant(0)
   DECLARE subgroupcount = i4 WITH protect, noconstant(0)
   DECLARE namelen = i4 WITH protect, noconstant(255)
   DECLARE entryname = c255 WITH protect, noconstant(fillstring(255," "))
   DECLARE entrycount = i4 WITH protect, noconstant(0)
   DECLARE attrcount = i4 WITH protect, noconstant(0)
   DECLARE valcount = i4 WITH protect, noconstant(0)
   DECLARE valname = c255 WITH protect, noconstant(fillstring(255," "))
   DECLARE subgroupexists = i2 WITH protect, noconstant(0)
   EXECUTE prefrtl
   SET statbbpref = initrec(prefvalues)
   SET prefentryexists = 0
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    CALL log_message("Bad hPref, try logging in",log_level_error)
    RETURN(- (1))
   ENDIF
   SET statbbpref = uar_prefaddcontext(hpref,"default","system")
   IF (statbbpref != 1)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad default context",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (size(nullterm(sfacilityctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"facility",nullterm(sfacilityctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad facility context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (size(nullterm(spositionctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"position",nullterm(spositionctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad position context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (size(nullterm(suserctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"user",nullterm(suserctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad user context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbpref = uar_prefsetsection(hpref,"module")
   IF (statbbpref != 1)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad section",log_level_error)
    RETURN(- (1))
   ENDIF
   SET hgroup = uar_prefcreategroup()
   SET statbbpref = uar_prefsetgroupname(hgroup,"blood bank")
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad group name",log_level_error)
    RETURN(- (1))
   ENDIF
   SET statbbpref = uar_prefaddgroup(hpref,hgroup)
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error adding group",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (size(nullterm(ssubgroup)) > 0)
    SET subgroupexists = 1
    SET hsubgroup = uar_prefaddsubgroup(hgroup,nullterm(ssubgroup))
    IF (hsubgroup <= 0)
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Error adding sub group",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbpref = uar_prefperform(hpref)
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error performing preference query",log_level_error)
    RETURN(- (1))
   ENDIF
   SET hsection = uar_prefgetsectionbyname(hpref,"module")
   SET hgroup2 = uar_prefgetgroupbyname(hsection,"blood bank")
   IF (subgroupexists=1)
    SET hsubgroup2 = uar_prefgetsubgroup(hgroup2,0)
    IF (hsubgroup2 <= 0)
     CALL uar_prefdestroysection(hsection)
     CALL uar_prefdestroygroup(hgroup2)
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Error obtaining sub group",log_level_error)
     RETURN(- (1))
    ENDIF
    SET hgroup2 = hsubgroup2
   ENDIF
   SET entrycount = 0
   SET statbbpref = uar_prefgetgroupentrycount(hgroup2,entrycount)
   IF (statbbpref != 1)
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroygroup(hgroup2)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error getting group entry count",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (entrycount <= 0)
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroygroup(hgroup2)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Preferences not found",log_level_error)
    RETURN(0)
   ENDIF
   FOR (idxentry = 0 TO (entrycount - 1))
     SET hentry = uar_prefgetgroupentry(hgroup2,idxentry)
     SET namelen = 255
     SET entryname = fillstring(255," ")
     SET statbbpref = uar_prefgetentryname(hentry,entryname,namelen)
     IF (statbbpref != 1)
      CALL uar_prefdestroyentry(hentry)
      CALL uar_prefdestroysection(hsection)
      CALL uar_prefdestroygroup(hgroup2)
      CALL uar_prefdestroygroup(hgroup)
      CALL uar_prefdestroyinstance(hpref)
      CALL log_message("Error getting entry name",log_level_error)
      RETURN(- (1))
     ENDIF
     IF (nullterm(entryname)=nullterm(sprefentry))
      SET prefentryexists = 1
      SET attrcount = 0
      SET statbbpref = uar_prefgetentryattrcount(hentry,attrcount)
      IF (((statbbpref != 1) OR (attrcount=0)) )
       CALL uar_prefdestroyentry(hentry)
       CALL uar_prefdestroysection(hsection)
       CALL uar_prefdestroygroup(hgroup2)
       CALL uar_prefdestroygroup(hgroup)
       CALL uar_prefdestroyinstance(hpref)
       CALL log_message("Bad entryAttrCount",log_level_error)
       RETURN(- (1))
      ENDIF
      FOR (idxattr = 0 TO (attrcount - 1))
        SET hattr = uar_prefgetentryattr(hentry,idxattr)
        DECLARE attrname = c255
        SET namelen = 255
        SET statbbpref = uar_prefgetattrname(hattr,attrname,namelen)
        IF (nullterm(attrname)="prefvalue")
         SET valcount = 0
         SET statbbpref = uar_prefgetattrvalcount(hattr,valcount)
         SET idxval = 0
         SET statbbpref = alterlist(prefvalues->prefs,valcount)
         FOR (idxval = 0 TO (valcount - 1))
           SET valname = fillstring(255," ")
           SET namelen = 255
           SET hval = uar_prefgetattrval(hattr,valname,namelen,idxval)
           SET prefvalues->prefs[(idxval+ 1)].value = nullterm(valname)
         ENDFOR
         IF (hattr > 0)
          CALL uar_prefdestroyattr(hattr)
         ENDIF
         IF (hentry > 0)
          CALL uar_prefdestroyentry(hentry)
         ENDIF
         IF (hsection > 0)
          CALL uar_prefdestroysection(hsection)
         ENDIF
         IF (hgroup2 > 0)
          CALL uar_prefdestroygroup(hgroup2)
         ENDIF
         IF (hgroup > 0)
          CALL uar_prefdestroygroup(hgroup)
         ENDIF
         IF (hpref > 0)
          CALL uar_prefdestroyinstance(hpref)
         ENDIF
         RETURN(1)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (hattr > 0)
    CALL uar_prefdestroyattr(hattr)
   ENDIF
   IF (hentry > 0)
    CALL uar_prefdestroyentry(hentry)
   ENDIF
   IF (hsection > 0)
    CALL uar_prefdestroysection(hsection)
   ENDIF
   IF (hgroup2 > 0)
    CALL uar_prefdestroygroup(hgroup2)
   ENDIF
   IF (hgroup > 0)
    CALL uar_prefdestroygroup(hgroup)
   ENDIF
   IF (hpref > 0)
    CALL uar_prefdestroyinstance(hpref)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetxmtagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("crossmatch tag program name")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetcomponenttagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("component tag program name")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetemergencytagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("emergency tag program name")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexfilterbyfacility(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("filter specimens by facility")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtdispgetproductorderassocpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("associate to prod orders on dispense")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN("")
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecahgxmatch(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("ahg crossmatch")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetaborhdiscrepancy(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("abo discrepancy")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecneonatedaysdefined(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("neonate day spec override")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexexpiredspecimenexpirationovrd(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend expired specimen expiration")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetdisponcurrentaborh(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("dispense based on current aborh")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetdisponsecondaborh(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("dispense based on two aborh")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetflexexpiredspecimenneonatedischarge(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend neonate specimen discharge")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtcorrectcommentpromptpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("result comment prompt")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN("")
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE bbtprintdispenseencounteridentifier(facility_code)
   DECLARE prefentry = vc WITH protect, constant("print dispense encounter identifier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetsamplevalidityorderspreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("sample validity qualifying orders")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE strpref = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) < 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   FOR (index = 1 TO size(prefvalues->prefs,5))
     IF (strpref="")
      SET strpref = concat(strpref,prefvalues->prefs[index].value)
     ELSE
      SET strpref = concat(strpref,",",prefvalues->prefs[index].value)
     ENDIF
   ENDFOR
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",strpref,",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(strpref)
 END ;Subroutine
 SUBROUTINE bbtgetbbidtagpreference(facility_code)
   DECLARE prefentry = vc WITH protect, constant("disp bbid 2d tags")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetprodtagverifypreference(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("product tag verification")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 RECORD flex_param_out(
   1 testing_facility_cd = f8
   1 flex_on_ind = i2
   1 flex_param = i4
   1 allo_param = i4
   1 auto_param = i4
   1 anti_flex_ind = i2
   1 anti_param = i4
   1 max_spec_validity = i4
   1 expiration_unit_type_mean = c12
   1 max_transfusion_end_range = i4
   1 transfusion_flex_params[*]
     2 index = i4
     2 start_range = i4
     2 end_range = i4
     2 flex_param = i4
   1 extend_trans_ovrd_ind = i2
   1 calc_trans_drawn_dt_ind = i2
   1 neonate_age = i4
 )
 RECORD flex_patient_out(
   1 person_id = f8
   1 encntr_id = f8
   1 anti_exist_ind = i2
   1 transfusion[*]
     2 transfusion_dt_tm = dq8
     2 critical_dt_tm = dq8
 )
 RECORD flex_codes(
   1 codes_loaded_ind = i2
   1 transfused_state_cd = f8
   1 blood_product_cd = f8
 )
 RECORD flex_max_out(
   1 max_expire_dt_tm = dq8
   1 max_expire_flag = i2
 )
 FREE SET facilityinfo
 RECORD facilityinfo(
   1 facilities[*]
     2 testing_facility_cd = f8
     2 flex_on_ind = i2
     2 flex_param = i4
     2 allo_param = i4
     2 auto_param = i4
     2 anti_flex_ind = i2
     2 anti_param = i4
     2 max_spec_validity = i4
     2 expiration_unit_type_mean = c12
     2 max_transfusion_end_range = i4
     2 transfusion_flex_params[*]
       3 index = i4
       3 start_range = i4
       3 end_range = i4
       3 flex_param = i4
     2 extend_trans_ovrd_ind = i2
     2 calc_trans_drawn_dt_ind = i2
     2 extend_expired_specimen = i2
     2 neonate_age = i4
     2 load_flex_params = i2
     2 extend_neonate_disch_spec = i2
 )
 DECLARE getcriticaldtstms() = i2
 DECLARE getflexcodesbycdfmeaning() = i2
 DECLARE statbbcalcflex = i2 WITH protect, noconstant(0)
 DECLARE ntrans_flag = i2 WITH protect, constant(1)
 DECLARE nanti_flag = i2 WITH protect, constant(2)
 DECLARE nneonate_flag = i2 WITH protect, constant(3)
 DECLARE nmax_param_flag = i2 WITH protect, constant(4)
 SET flex_param_out->testing_facility_cd = - (1)
 SUBROUTINE (loadflexparams(encntrfacilitycd=f8(value)) =i2)
   DECLARE prefcount = i2 WITH protect, noconstant(0)
   DECLARE prefindex = i2 WITH protect, noconstant(0)
   DECLARE testingfacilitycd = f8 WITH protect, noconstant(0.0)
   SET testingfacilitycd = bbtgetflexspectestingfacility(encntrfacilitycd)
   IF ((testingfacilitycd=- (1)))
    CALL log_message("Error getting transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF ((flex_param_out->testing_facility_cd=testingfacilitycd))
    RETURN(1)
   ENDIF
   SET statbbcalcflex = initrec(flex_param_out)
   SET statbbcalcflex = initrec(flex_patient_out)
   SET flex_param_out->flex_on_ind = bbtgetflexspecenableflexexpiration(testingfacilitycd)
   CASE (flex_param_out->flex_on_ind)
    OF 0:
     RETURN(0)
    OF - (1):
     CALL log_message("Error getting flex on preference.",log_level_error)
     RETURN(- (1))
   ENDCASE
   SET flex_param_out->allo_param = bbtgetflexspecxmalloexpunits(testingfacilitycd)
   IF ((flex_param_out->allo_param=- (1)))
    CALL log_message("Error getting flex param preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->auto_param = bbtgetflexspecxmautoexpunits(testingfacilitycd)
   IF ((flex_param_out->auto_param=- (1)))
    CALL log_message("Error getting auto param pref.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->anti_flex_ind = bbtgetflexspecdefclinsigantibodyparams(testingfacilitycd)
   IF ((flex_param_out->anti_flex_ind=- (1)))
    CALL log_message("Error getting anti_flex_ind.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->anti_param = bbtgetflexspecclinsigantibodiesexpunits(testingfacilitycd)
   IF ((flex_param_out->anti_param=- (1)))
    CALL log_message("Error getting anti_param.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->max_spec_validity = bbtgetflexspecmaxspecexpunits(testingfacilitycd)
   IF ((flex_param_out->max_spec_validity=- (1)))
    CALL log_message("Error getting max spec validity preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->expiration_unit_type_mean = bbtgetflexspecexpunittypemean(testingfacilitycd)
   IF (size(flex_param_out->expiration_unit_type_mean,1) <= 0)
    CALL log_message("Error getting expiration unit type preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (bbtgetflexspectransfusionparameters(testingfacilitycd)=1)
    SET prefcount = size(flexspectransparams->params,5)
    SET statbbcalcflex = alterlist(flex_param_out->transfusion_flex_params,prefcount)
    FOR (prefindex = 1 TO prefcount)
      SET flex_param_out->transfusion_flex_params[prefindex].index = flexspectransparams->params[
      prefindex].index
      SET flex_param_out->transfusion_flex_params[prefindex].start_range = flexspectransparams->
      params[prefindex].transfusionstartrange
      SET flex_param_out->transfusion_flex_params[prefindex].end_range = flexspectransparams->params[
      prefindex].transfusionendrange
      SET flex_param_out->transfusion_flex_params[prefindex].flex_param = flexspectransparams->
      params[prefindex].specimenexpiration
      IF ((flexspectransparams->params[prefindex].transfusionendrange > flex_param_out->
      max_transfusion_end_range))
       SET flex_param_out->max_transfusion_end_range = flexspectransparams->params[prefindex].
       transfusionendrange
      ENDIF
    ENDFOR
   ELSE
    CALL log_message("Error getting transfusion flex params.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->extend_trans_ovrd_ind = bbtgetflexspecextendtransfoverride(testingfacilitycd)
   IF ((flex_param_out->extend_trans_ovrd_ind=- (1)))
    CALL log_message("Error getting extend_trans_ovrd_ind.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->calc_trans_drawn_dt_ind = bbtgetflexspeccalcposttransfspecsfromdawndt(
    testingfacilitycd)
   IF ((flex_param_out->calc_trans_drawn_dt_ind=- (1)))
    CALL log_message("Error getting calc_trans_drawn_dt_ind.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->neonate_age = bbtgetflexspecneonatedaysdefined(testingfacilitycd)
   IF ((flex_param_out->neonate_age=- (1)))
    CALL log_message("Error getting neonate days defined.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->testing_facility_cd = testingfacilitycd
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (loadflexpatient(personid=f8(value),encntrid=f8(value)) =i2)
   DECLARE current_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,0))
   DECLARE transfusioncount = i4 WITH protect, noconstant(0)
   DECLARE earliesttransfusionenddttm = dq8 WITH protect, noconstant(0.0)
   SET statbbcalcflex = initrec(flex_patient_out)
   IF ((flex_param_out->anti_flex_ind=1))
    SELECT
     IF (encntrid > 0.0)
      FROM person_antibody pa,
       transfusion_requirements tr
      PLAN (pa
       WHERE pa.encntr_id=encntrid
        AND pa.active_ind=1)
       JOIN (tr
       WHERE tr.requirement_cd=pa.antibody_cd
        AND tr.significance_ind=1)
     ELSE
      FROM person_antibody pa,
       transfusion_requirements tr
      PLAN (pa
       WHERE pa.person_id=personid
        AND pa.active_ind=1)
       JOIN (tr
       WHERE tr.requirement_cd=pa.antibody_cd
        AND tr.significance_ind=1)
     ENDIF
     INTO "nl:"
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET flex_patient_out->anti_exist_ind = 1
    ENDIF
   ENDIF
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (((2 * flex_param_out->max_transfusion_end_range) < flex_param_out->max_spec_validity))
    SET earliesttransfusionenddttm = datetimeadd(current_dt_tm,- ((flex_param_out->
     max_transfusion_end_range+ flex_param_out->max_spec_validity)))
   ELSE
    SET earliesttransfusionenddttm = datetimeadd(current_dt_tm,- ((2 * flex_param_out->
     max_transfusion_end_range)))
   ENDIF
   SELECT INTO "nl:"
    FROM transfusion t,
     product p,
     product_index pi,
     product_category pc,
     product_event pe
    PLAN (t
     WHERE t.person_id=personid
      AND t.active_ind=1)
     JOIN (p
     WHERE p.product_id=t.product_id
      AND (p.product_class_cd=flex_codes->blood_product_cd)
      AND p.active_ind=1)
     JOIN (pi
     WHERE pi.product_cd=p.product_cd
      AND pi.active_ind=1)
     JOIN (pc
     WHERE pc.product_cat_cd=pi.product_cat_cd
      AND pc.active_ind=1)
     JOIN (pe
     WHERE pe.product_id=p.product_id
      AND (pe.event_type_cd=flex_codes->transfused_state_cd)
      AND pe.event_dt_tm >= cnvtdatetime(earliesttransfusionenddttm)
      AND ((encntrid > 0.0
      AND pe.encntr_id=encntrid) OR (encntrid=0.0))
      AND pe.active_ind=1)
    ORDER BY pe.event_dt_tm DESC
    HEAD REPORT
     transfusioncount = 0
    HEAD pe.event_dt_tm
     row + 0
    DETAIL
     IF (pi.autologous_ind=0)
      IF (pc.xmatch_required_ind=1)
       transfusioncount += 1
       IF (transfusioncount > size(flex_patient_out->transfusion,5))
        statbbcalcflex = alterlist(flex_patient_out->transfusion,(transfusioncount+ 9))
       ENDIF
       flex_patient_out->transfusion[transfusioncount].transfusion_dt_tm = pe.event_dt_tm
      ENDIF
     ENDIF
    FOOT  pe.event_dt_tm
     row + 0
    FOOT REPORT
     statbbcalcflex = alterlist(flex_patient_out->transfusion,transfusioncount)
    WITH nocounter
   ;end select
   SET flex_patient_out->person_id = personid
   SET flex_patient_out->encntr_id = encntrid
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getcriticaldtstms(null)
   DECLARE criticalrange = i4 WITH protect, noconstant(0)
   DECLARE transfusionflexparamscount = i4 WITH protect, noconstant(0)
   DECLARE transfusionflexparamsindex = i4 WITH protect, noconstant(0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET transfusionflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   FOR (transfusionflexparamsindex = 1 TO transfusionflexparamscount)
     IF ((flex_param_out->transfusion_flex_params[transfusionflexparamsindex].index=1))
      SET criticalrange = flex_param_out->transfusion_flex_params[transfusionflexparamsindex].
      end_range
      SET transfusionflexparamsindex = transfusionflexparamscount
     ENDIF
   ENDFOR
   SET transcount = size(flex_patient_out->transfusion,5)
   FOR (transindex = 1 TO transcount)
     IF (trim(flex_param_out->expiration_unit_type_mean)="D")
      SET flex_patient_out->transfusion[transindex].critical_dt_tm = datetimeadd(cnvtdatetime(
        cnvtdate(flex_patient_out->transfusion[transindex].transfusion_dt_tm),235959),criticalrange)
     ELSE
      SET flex_patient_out->transfusion[transindex].critical_dt_tm = datetimeadd(flex_patient_out->
       transfusion[transindex].transfusion_dt_tm,criticalrange)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getflexcodesbycdfmeaning(null)
   DECLARE bb_inventory_states_cs = i4 WITH protect, constant(1610)
   DECLARE transfused_state_mean = c12 WITH protect, constant("7")
   DECLARE product_class_cs = i4 WITH protect, constant(1606)
   DECLARE blood_product_mean = c12 WITH protect, constant("BLOOD")
   SET statbbcalcflex = initrec(flex_codes)
   SET flex_codes->codes_loaded_ind = 0
   SET flex_codes->transfused_state_cd = uar_get_code_by("MEANING",bb_inventory_states_cs,nullterm(
     transfused_state_mean))
   IF ((flex_codes->transfused_state_cd <= 0.0))
    CALL log_message("Error getting transfused state cd.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_codes->blood_product_cd = uar_get_code_by("MEANING",product_class_cs,nullterm(
     blood_product_mean))
   IF ((flex_codes->blood_product_cd <= 0.0))
    CALL log_message("Error getting blood product cd.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_codes->codes_loaded_ind = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getflexexpiration(personid=f8(value),encntrid=f8(value),drawndttm=dq8(value),
  encntrfacilitycd=f8(value),disregarddefaultind=i2(value)) =dq8)
   DECLARE expiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE paramdttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   DECLARE transdttmdrawndttmdiff = i4 WITH protect, noconstant(0)
   DECLARE transflexparamscount = i2 WITH protect, noconstant(0)
   DECLARE transflexparamsindex = i2 WITH protect, noconstant(0)
   DECLARE recalccriticaldttmind = i2 WITH protect, noconstant(0)
   DECLARE prevtestingfaccdhold = f8 WITH protect, noconstant(0.0)
   DECLARE usecritind = i2 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET prevtestingfaccdhold = flex_param_out->testing_facility_cd
   IF (loadflexparams(encntrfacilitycd) != 1)
    CALL log_message("Error loading flex params.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF ((prevtestingfaccdhold != flex_param_out->testing_facility_cd))
    SET recalccriticaldttmind = 1
   ENDIF
   IF ((((flex_patient_out->person_id != personid)) OR ((flex_patient_out->encntr_id != encntrid))) )
    IF (loadflexpatient(personid,encntrid) != 1)
     CALL log_message("Error loading patient info.",log_level_error)
     RETURN(- (1))
    ENDIF
    SET recalccriticaldttmind = 1
   ENDIF
   IF (recalccriticaldttmind=1)
    IF (getcriticaldtstms(null) != 1)
     CALL log_message("Error loading critical dates/times.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (disregarddefaultind=1)
    IF ((flex_patient_out->anti_exist_ind=1))
     SET flex_param_out->flex_param = flex_param_out->anti_param
    ELSE
     SET flex_param_out->flex_param = - (1)
    ENDIF
   ELSE
    SET flex_param_out->flex_param = flex_param_out->allo_param
    IF ((flex_patient_out->anti_exist_ind=1))
     IF ((flex_param_out->anti_param < flex_param_out->flex_param))
      SET flex_param_out->flex_param = flex_param_out->anti_param
     ENDIF
    ENDIF
   ENDIF
   IF ((flex_param_out->flex_param != - (1)))
    IF (trim(flex_param_out->expiration_unit_type_mean)="D")
     SET expiredttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->flex_param
      )
    ELSE
     SET expiredttm = datetimeadd(drawndttm,flex_param_out->flex_param)
    ENDIF
   ENDIF
   SET transcount = size(flex_patient_out->transfusion,5)
   SET transflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   FOR (transindex = 1 TO transcount)
     SET usecritind = 0
     IF ((drawndttm < flex_patient_out->transfusion[transindex].transfusion_dt_tm))
      SET usecritind = 1
     ELSEIF ((drawndttm < flex_patient_out->transfusion[transindex].critical_dt_tm))
      IF ((flex_param_out->calc_trans_drawn_dt_ind=0))
       SET usecritind = 1
      ENDIF
     ENDIF
     IF (usecritind=1)
      IF ((((expiredttm > flex_patient_out->transfusion[transindex].critical_dt_tm)) OR (expiredttm=
      0.0)) )
       SET expiredttm = flex_patient_out->transfusion[transindex].critical_dt_tm
      ENDIF
     ELSE
      SET transdttmdrawndttmdiff = ceil(datetimediff(drawndttm,flex_patient_out->transfusion[
        transindex].transfusion_dt_tm))
      FOR (transflexparamsindex = 1 TO transflexparamscount)
        IF ((transdttmdrawndttmdiff >= flex_param_out->transfusion_flex_params[transflexparamsindex].
        start_range)
         AND (transdttmdrawndttmdiff <= flex_param_out->transfusion_flex_params[transflexparamsindex]
        .end_range))
         IF (trim(flex_param_out->expiration_unit_type_mean)="D")
          SET paramdttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->
           transfusion_flex_params[transflexparamsindex].flex_param)
         ELSE
          SET paramdttm = datetimeadd(drawndttm,flex_param_out->transfusion_flex_params[
           transflexparamsindex].flex_param)
         ENDIF
         IF (((expiredttm > paramdttm) OR (expiredttm=0.0)) )
          SET expiredttm = paramdttm
         ENDIF
         SET transflexparamsindex = transflexparamscount
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   RETURN(expiredttm)
 END ;Subroutine
 SUBROUTINE (getflexmaxexpiration(personid=f8(value),encntrid=f8(value),drawndttm=dq8(value),
  encntrfacilitycd=f8(value)) =i2)
   DECLARE expiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE paramdttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   DECLARE transdttmdrawndttmdiff = i4 WITH protect, noconstant(0)
   DECLARE transflexparamscount = i2 WITH protect, noconstant(0)
   DECLARE transflexparamsindex = i2 WITH protect, noconstant(0)
   DECLARE recalccriticaldttmind = i2 WITH protect, noconstant(0)
   DECLARE prevtestingfaccdhold = f8 WITH protect, noconstant(0.0)
   DECLARE usecritind = i2 WITH protect, noconstant(0)
   DECLARE maxparamexpiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transexpiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE nantiparamind = i2 WITH protect, noconstant(0)
   DECLARE ntransparamind = i2 WITH protect, noconstant(0)
   DECLARE calcflexparam = i4 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbcalcflex = initrec(flex_max_out)
   SET prevtestingfaccdhold = flex_param_out->testing_facility_cd
   IF (loadflexparams(encntrfacilitycd) != 1)
    CALL log_message("Error loading flex params.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF ((prevtestingfaccdhold != flex_param_out->testing_facility_cd))
    SET recalccriticaldttmind = 1
   ENDIF
   IF ((((flex_patient_out->person_id != personid)) OR ((flex_patient_out->encntr_id != encntrid))) )
    IF (loadflexpatient(personid,encntrid) != 1)
     CALL log_message("Error loading patient info.",log_level_error)
     RETURN(- (1))
    ENDIF
    SET recalccriticaldttmind = 1
   ENDIF
   IF (recalccriticaldttmind=1)
    IF (getcriticaldtstms(null) != 1)
     CALL log_message("Error loading critical dates/times.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET calcflexparam = flex_param_out->max_spec_validity
   IF ((flex_patient_out->anti_exist_ind=1))
    IF ((flex_param_out->anti_param < calcflexparam))
     SET calcflexparam = flex_param_out->anti_param
     SET nantiparamind = 1
    ENDIF
   ENDIF
   IF (trim(flex_param_out->expiration_unit_type_mean)="D")
    SET maxparamexpiredttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),calcflexparam)
   ELSE
    SET maxparamexpiredttm = datetimeadd(drawndttm,calcflexparam)
   ENDIF
   SET transcount = size(flex_patient_out->transfusion,5)
   SET transflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   SET transexpiredttm = maxparamexpiredttm
   FOR (transindex = 1 TO transcount)
     SET usecritind = 0
     IF ((drawndttm < flex_patient_out->transfusion[transindex].transfusion_dt_tm))
      SET usecritind = 1
     ELSEIF ((drawndttm < flex_patient_out->transfusion[transindex].critical_dt_tm))
      IF ((flex_param_out->calc_trans_drawn_dt_ind=0))
       SET usecritind = 1
      ENDIF
     ENDIF
     IF (usecritind=1)
      IF ((transexpiredttm > flex_patient_out->transfusion[transindex].critical_dt_tm))
       SET transexpiredttm = flex_patient_out->transfusion[transindex].critical_dt_tm
       SET ntransparamind = 1
      ENDIF
     ELSE
      SET transdttmdrawndttmdiff = ceil(datetimediff(drawndttm,flex_patient_out->transfusion[
        transindex].transfusion_dt_tm))
      FOR (transflexparamsindex = 1 TO transflexparamscount)
        IF ((transdttmdrawndttmdiff >= flex_param_out->transfusion_flex_params[transflexparamsindex].
        start_range)
         AND (transdttmdrawndttmdiff <= flex_param_out->transfusion_flex_params[transflexparamsindex]
        .end_range))
         IF (trim(flex_param_out->expiration_unit_type_mean)="D")
          SET paramdttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->
           transfusion_flex_params[transflexparamsindex].flex_param)
         ELSE
          SET paramdttm = datetimeadd(drawndttm,flex_param_out->transfusion_flex_params[
           transflexparamsindex].flex_param)
         ENDIF
         IF (transexpiredttm > paramdttm)
          SET transexpiredttm = paramdttm
          SET ntransparamind = 1
         ENDIF
         SET transflexparamsindex = transflexparamscount
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (ntransparamind=1)
    IF ((flex_param_out->extend_trans_ovrd_ind=0))
     SET flex_max_out->max_expire_dt_tm = cnvtdatetime(transexpiredttm)
     SET flex_max_out->max_expire_flag = ntrans_flag
    ELSE
     SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
     IF (nantiparamind=0)
      SET flex_max_out->max_expire_flag = nmax_param_flag
     ELSE
      SET flex_max_out->max_expire_flag = nanti_flag
     ENDIF
    ENDIF
   ELSEIF (nantiparamind=1)
    SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
    SET flex_max_out->max_expire_flag = nanti_flag
   ELSE
    SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
    SET flex_max_out->max_expire_flag = nmax_param_flag
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getflexexpirationforperson(personid=f8(value),encntrid=f8(value),drawndttm=dq8(value),
  encntrfacilitycd=f8(value),disregarddefaultind=i2(value)) =dq8)
   DECLARE expiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE paramdttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   DECLARE transdttmdrawndttmdiff = i4 WITH protect, noconstant(0)
   DECLARE transflexparamscount = i2 WITH protect, noconstant(0)
   DECLARE transflexparamsindex = i2 WITH protect, noconstant(0)
   DECLARE recalccriticaldttmind = i2 WITH protect, noconstant(0)
   DECLARE prevtestingfaccdhold = f8 WITH protect, noconstant(0.0)
   DECLARE usecritind = i2 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET prevtestingfaccdhold = flex_param_out->testing_facility_cd
   IF ((prevtestingfaccdhold != flex_param_out->testing_facility_cd))
    SET recalccriticaldttmind = 1
   ENDIF
   IF ((((flex_patient_out->person_id != personid)) OR ((flex_patient_out->encntr_id != encntrid))) )
    IF (loadflexpatient(personid,encntrid) != 1)
     CALL log_message("Error loading patient info.",log_level_error)
     RETURN(- (1))
    ENDIF
    SET recalccriticaldttmind = 1
   ENDIF
   IF (recalccriticaldttmind=1)
    IF (getcriticaldtstms(null) != 1)
     CALL log_message("Error loading critical dates/times.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (disregarddefaultind=1)
    IF ((flex_patient_out->anti_exist_ind=1))
     SET flex_param_out->flex_param = flex_param_out->anti_param
    ELSE
     SET flex_param_out->flex_param = - (1)
    ENDIF
   ELSE
    SET flex_param_out->flex_param = flex_param_out->allo_param
    IF ((flex_patient_out->anti_exist_ind=1))
     IF ((flex_param_out->anti_param < flex_param_out->flex_param))
      SET flex_param_out->flex_param = flex_param_out->anti_param
     ENDIF
    ENDIF
   ENDIF
   IF ((flex_param_out->flex_param != - (1)))
    IF (trim(flex_param_out->expiration_unit_type_mean)="D")
     SET expiredttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->flex_param
      )
    ELSE
     SET expiredttm = datetimeadd(drawndttm,flex_param_out->flex_param)
    ENDIF
   ENDIF
   SET transcount = size(flex_patient_out->transfusion,5)
   SET transflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   FOR (transindex = 1 TO transcount)
     SET usecritind = 0
     IF ((drawndttm < flex_patient_out->transfusion[transindex].transfusion_dt_tm))
      SET usecritind = 1
     ELSEIF ((drawndttm < flex_patient_out->transfusion[transindex].critical_dt_tm))
      IF ((flex_param_out->calc_trans_drawn_dt_ind=0))
       SET usecritind = 1
      ENDIF
     ENDIF
     IF (usecritind=1)
      IF ((((expiredttm > flex_patient_out->transfusion[transindex].critical_dt_tm)) OR (expiredttm=
      0.0)) )
       SET expiredttm = flex_patient_out->transfusion[transindex].critical_dt_tm
      ENDIF
     ELSE
      SET transdttmdrawndttmdiff = ceil(datetimediff(drawndttm,flex_patient_out->transfusion[
        transindex].transfusion_dt_tm))
      FOR (transflexparamsindex = 1 TO transflexparamscount)
        IF ((transdttmdrawndttmdiff >= flex_param_out->transfusion_flex_params[transflexparamsindex].
        start_range)
         AND (transdttmdrawndttmdiff <= flex_param_out->transfusion_flex_params[transflexparamsindex]
        .end_range))
         IF (trim(flex_param_out->expiration_unit_type_mean)="D")
          SET paramdttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->
           transfusion_flex_params[transflexparamsindex].flex_param)
         ELSE
          SET paramdttm = datetimeadd(drawndttm,flex_param_out->transfusion_flex_params[
           transflexparamsindex].flex_param)
         ENDIF
         IF (((expiredttm > paramdttm) OR (expiredttm=0.0)) )
          SET expiredttm = paramdttm
         ENDIF
         SET transflexparamsindex = transflexparamscount
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   RETURN(expiredttm)
 END ;Subroutine
 SUBROUTINE (getflexmaxexpirationforperson(personid=f8(value),encntrid=f8(value),drawndttm=dq8(value),
  encntrfacilitycd=f8(value)) =i2)
   DECLARE expiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE paramdttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   DECLARE transdttmdrawndttmdiff = i4 WITH protect, noconstant(0)
   DECLARE transflexparamscount = i2 WITH protect, noconstant(0)
   DECLARE transflexparamsindex = i2 WITH protect, noconstant(0)
   DECLARE recalccriticaldttmind = i2 WITH protect, noconstant(0)
   DECLARE prevtestingfaccdhold = f8 WITH protect, noconstant(0.0)
   DECLARE usecritind = i2 WITH protect, noconstant(0)
   DECLARE maxparamexpiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transexpiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE nantiparamind = i2 WITH protect, noconstant(0)
   DECLARE ntransparamind = i2 WITH protect, noconstant(0)
   DECLARE calcflexparam = i4 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbcalcflex = initrec(flex_max_out)
   SET prevtestingfaccdhold = flex_param_out->testing_facility_cd
   IF ((prevtestingfaccdhold != flex_param_out->testing_facility_cd))
    SET recalccriticaldttmind = 1
   ENDIF
   IF ((((flex_patient_out->person_id != personid)) OR ((flex_patient_out->encntr_id != encntrid))) )
    IF (loadflexpatient(personid,encntrid) != 1)
     CALL log_message("Error loading patient info.",log_level_error)
     RETURN(- (1))
    ENDIF
    SET recalccriticaldttmind = 1
   ENDIF
   IF (recalccriticaldttmind=1)
    IF (getcriticaldtstms(null) != 1)
     CALL log_message("Error loading critical dates/times.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET calcflexparam = flex_param_out->max_spec_validity
   IF ((flex_patient_out->anti_exist_ind=1))
    IF ((flex_param_out->anti_param < calcflexparam))
     SET calcflexparam = flex_param_out->anti_param
     SET nantiparamind = 1
    ENDIF
   ENDIF
   IF (trim(flex_param_out->expiration_unit_type_mean)="D")
    SET maxparamexpiredttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),calcflexparam)
   ELSE
    SET maxparamexpiredttm = datetimeadd(drawndttm,calcflexparam)
   ENDIF
   SET transcount = size(flex_patient_out->transfusion,5)
   SET transflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   SET transexpiredttm = maxparamexpiredttm
   FOR (transindex = 1 TO transcount)
     SET usecritind = 0
     IF ((drawndttm < flex_patient_out->transfusion[transindex].transfusion_dt_tm))
      SET usecritind = 1
     ELSEIF ((drawndttm < flex_patient_out->transfusion[transindex].critical_dt_tm))
      IF ((flex_param_out->calc_trans_drawn_dt_ind=0))
       SET usecritind = 1
      ENDIF
     ENDIF
     IF (usecritind=1)
      IF ((transexpiredttm > flex_patient_out->transfusion[transindex].critical_dt_tm))
       SET transexpiredttm = flex_patient_out->transfusion[transindex].critical_dt_tm
       SET ntransparamind = 1
      ENDIF
     ELSE
      SET transdttmdrawndttmdiff = ceil(datetimediff(drawndttm,flex_patient_out->transfusion[
        transindex].transfusion_dt_tm))
      FOR (transflexparamsindex = 1 TO transflexparamscount)
        IF ((transdttmdrawndttmdiff >= flex_param_out->transfusion_flex_params[transflexparamsindex].
        start_range)
         AND (transdttmdrawndttmdiff <= flex_param_out->transfusion_flex_params[transflexparamsindex]
        .end_range))
         IF (trim(flex_param_out->expiration_unit_type_mean)="D")
          SET paramdttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->
           transfusion_flex_params[transflexparamsindex].flex_param)
         ELSE
          SET paramdttm = datetimeadd(drawndttm,flex_param_out->transfusion_flex_params[
           transflexparamsindex].flex_param)
         ENDIF
         IF (transexpiredttm > paramdttm)
          SET transexpiredttm = paramdttm
          SET ntransparamind = 1
         ENDIF
         SET transflexparamsindex = transflexparamscount
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (ntransparamind=1)
    IF ((flex_param_out->extend_trans_ovrd_ind=0))
     SET flex_max_out->max_expire_dt_tm = cnvtdatetime(transexpiredttm)
     SET flex_max_out->max_expire_flag = ntrans_flag
    ELSE
     SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
     IF (nantiparamind=0)
      SET flex_max_out->max_expire_flag = nmax_param_flag
     ELSE
      SET flex_max_out->max_expire_flag = nanti_flag
     ENDIF
    ENDIF
   ELSEIF (nantiparamind=1)
    SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
    SET flex_max_out->max_expire_flag = nanti_flag
   ELSE
    SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
    SET flex_max_out->max_expire_flag = nmax_param_flag
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getflexspecimenparams(facilityindex=i4(value),enc_facility_cd=f8(value),addreadind=i2(
   value),appkey=c10(value)) =null)
   DECLARE transparamscount = i4 WITH protect, noconstant(0)
   SET facilityinfo->facilities[facilityindex].load_flex_params = 1
   IF (addreadind=1)
    IF ((loadflexparams(enc_facility_cd)=- (1)))
     SET facilityinfo->facilities[facilityindex].load_flex_params = - (1)
     CALL log_message("Error loading flex params.",log_level_error)
    ENDIF
    SET facilityinfo->facilities[facilityindex].testing_facility_cd = flex_param_out->
    testing_facility_cd
    SET facilityinfo->facilities[facilityindex].flex_on_ind = flex_param_out->flex_on_ind
    SET facilityinfo->facilities[facilityindex].flex_param = flex_param_out->flex_param
    SET facilityinfo->facilities[facilityindex].allo_param = flex_param_out->allo_param
    SET facilityinfo->facilities[facilityindex].auto_param = flex_param_out->auto_param
    SET facilityinfo->facilities[facilityindex].anti_flex_ind = flex_param_out->anti_flex_ind
    SET facilityinfo->facilities[facilityindex].anti_param = flex_param_out->anti_param
    SET facilityinfo->facilities[facilityindex].max_spec_validity = flex_param_out->max_spec_validity
    SET facilityinfo->facilities[facilityindex].expiration_unit_type_mean = flex_param_out->
    expiration_unit_type_mean
    SET facilityinfo->facilities[facilityindex].max_transfusion_end_range = flex_param_out->
    max_transfusion_end_range
    SET facilityinfo->facilities[facilityindex].extend_trans_ovrd_ind = flex_param_out->
    extend_trans_ovrd_ind
    SET facilityinfo->facilities[facilityindex].calc_trans_drawn_dt_ind = flex_param_out->
    calc_trans_drawn_dt_ind
    SET facilityinfo->facilities[facilityindex].neonate_age = flex_param_out->neonate_age
    SET transparamscount = size(flex_param_out->transfusion_flex_params,5)
    SET stat = alterlist(facilityinfo->facilities[facilityindex].transfusion_flex_params,
     transparamscount)
    FOR (x_idx = 1 TO transparamscount)
      SET facilityinfo->facilities[facilityindex].transfusion_flex_params[x_idx].index =
      flex_param_out->transfusion_flex_params[x_idx].index
      SET facilityinfo->facilities[facilityindex].transfusion_flex_params[x_idx].start_range =
      flex_param_out->transfusion_flex_params[x_idx].start_range
      SET facilityinfo->facilities[facilityindex].transfusion_flex_params[x_idx].end_range =
      flex_param_out->transfusion_flex_params[x_idx].end_range
      SET facilityinfo->facilities[facilityindex].transfusion_flex_params[x_idx].flex_param =
      flex_param_out->transfusion_flex_params[x_idx].flex_param
    ENDFOR
    IF (trim(appkey)="AVAILSPECS")
     SET facilityinfo->facilities[facilityindex].extend_expired_specimen =
     bbtgetflexexpiredspecimenexpirationovrd(facilityinfo->facilities[facilityindex].
      testing_facility_cd)
     SET facilityinfo->facilities[facilityindex].extend_neonate_disch_spec =
     bbtgetflexexpiredspecimenneonatedischarge(facilityinfo->facilities[facilityindex].
      testing_facility_cd)
    ENDIF
   ELSE
    SET flex_param_out->testing_facility_cd = facilityinfo->facilities[facilityindex].
    testing_facility_cd
    SET flex_param_out->flex_on_ind = facilityinfo->facilities[facilityindex].flex_on_ind
    SET flex_param_out->flex_param = facilityinfo->facilities[facilityindex].flex_param
    SET flex_param_out->allo_param = facilityinfo->facilities[facilityindex].allo_param
    SET flex_param_out->auto_param = facilityinfo->facilities[facilityindex].auto_param
    SET flex_param_out->anti_flex_ind = facilityinfo->facilities[facilityindex].anti_flex_ind
    SET flex_param_out->anti_param = facilityinfo->facilities[facilityindex].anti_param
    SET flex_param_out->max_spec_validity = facilityinfo->facilities[facilityindex].max_spec_validity
    SET flex_param_out->expiration_unit_type_mean = facilityinfo->facilities[facilityindex].
    expiration_unit_type_mean
    SET flex_param_out->max_transfusion_end_range = facilityinfo->facilities[facilityindex].
    max_transfusion_end_range
    SET flex_param_out->extend_trans_ovrd_ind = facilityinfo->facilities[facilityindex].
    extend_trans_ovrd_ind
    SET flex_param_out->calc_trans_drawn_dt_ind = facilityinfo->facilities[facilityindex].
    calc_trans_drawn_dt_ind
    SET flex_param_out->neonate_age = facilityinfo->facilities[facilityindex].neonate_age
    SET transparamscount = size(facilityinfo->facilities[facilityindex].transfusion_flex_params,5)
    SET stat = alterlist(flex_param_out->transfusion_flex_params,transparamscount)
    FOR (x_idx = 1 TO transparamscount)
      SET flex_param_out->transfusion_flex_params[x_idx].index = facilityinfo->facilities[
      facilityindex].transfusion_flex_params[x_idx].index
      SET flex_param_out->transfusion_flex_params[x_idx].start_range = facilityinfo->facilities[
      facilityindex].transfusion_flex_params[x_idx].start_range
      SET flex_param_out->transfusion_flex_params[x_idx].end_range = facilityinfo->facilities[
      facilityindex].transfusion_flex_params[x_idx].end_range
      SET flex_param_out->transfusion_flex_params[x_idx].flex_param = facilityinfo->facilities[
      facilityindex].transfusion_flex_params[x_idx].flex_param
    ENDFOR
   ENDIF
 END ;Subroutine
#script
 DECLARE serrormsg = c255
 SET nerrorstatus = error(serrormsg,1)
 DECLARE targetobjectname = c25
 DECLARE targetobjectvalue = c255
 SET count1 = 0
 SET activity_type_codeset = 106
 SET activity_type_bb_cdf = "BB"
 SET order_status_codeset = 6004
 SET dept_status_codeset = 14281
 SET dept_status_labinlab_cdf = "LABINLAB"
 SET dept_status_labinprocess_cdf = "LABINPROCESS"
 SET order_status_canceled_cdf = "CANCELED"
 SET order_status_deleted_cdf = "DELETED"
 SET order_status_discontinued_cdf = "DISCONTINUED"
 SET order_status_ordered_cdf = "ORDERED"
 SET order_status_inprocess_cdf = "INPROCESS"
 SET product_states_codeset = 1610
 SET in_progress_cdf = "16"
 SET crossmatch_cdf = "3"
 DECLARE order_status_canceled_cd = f8
 DECLARE order_status_deleted_cd = f8
 DECLARE order_status_discontinued_cd = f8
 DECLARE order_status_ordered_cd = f8
 DECLARE order_status_inprocess_cd = f8
 DECLARE dept_status_labinlab_cd = f8
 DECLARE dept_status_labinprocess_cd = f8
 DECLARE in_progress_cd = f8
 DECLARE crossmatch_cd = f8
 DECLARE bb_activity_cd = f8
 DECLARE qual_cnt = i4
 DECLARE max_cntr_cnt = i4
 DECLARE qual_idx = i4 WITH protect, noconstant(0)
 DECLARE container_serv_res_cnt = i4 WITH protect, noconstant(0)
 DECLARE container_serv_res_idx = i4 WITH protect, noconstant(0)
 DECLARE operation_name = c25 WITH noconstant(fillstring(25," "))
 DECLARE srs_granted = i2 WITH noconstant(false)
 DECLARE order_found = i2 WITH noconstant(false)
 DECLARE service_resource_cd = f8 WITH noconstant(0.0)
 DECLARE lexception_type_cs = i4 WITH protect, constant(14072)
 DECLARE smsbos_cdf = c5 WITH protect, constant("MSBOS")
 DECLARE exception_msbos_cd = f8 WITH protect, noconstant(0.0)
 CALL initresourcesecurity(validate(request->resource_security_ind,0))
 SET reply->status_data.status = "F"
 SET serrormsg = ""
 SET nerrorstatus = error(serrormsg,1)
 IF (get_processing_code_values(0)=0)
  GO TO exit_script
 ENDIF
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus > 0)
  CALL add_reply_status_event("F","Get processing Code Values","F","_cd fields",
   "CCL Error retrieving processing code values")
  GO TO exit_script
 ENDIF
 SET serrormsg = ""
 SET nerrorstatus = error(serrormsg,1)
 SELECT INTO "nl:"
  aor.seq, aor.accession, aor.order_id,
  cat_seq =
  IF ((request->cat_cnt > 0)) request->catlist[d_cat.seq].sequence
  ELSE 0
  ENDIF
  , o.order_status_cd, o.dept_status_cd,
  o.catalog_cd, o.order_mnemonic"####################", sd.bb_processing_cd,
  osrc.service_resource_cd, osrc.container_id, c.drawn_dt_tm";;f",
  c.specimen_id, pnl.username
  FROM accession_order_r aor,
   (dummyt d_cat  WITH seq = value(request->cat_cnt)),
   orders o,
   service_directory sd,
   encounter e,
   order_serv_res_container osrc,
   container c,
   prsnl pnl,
   bb_exception be
  PLAN (aor
   WHERE (aor.accession=request->accession)
    AND aor.primary_flag=0)
   JOIN (d_cat)
   JOIN (o
   WHERE o.order_id=aor.order_id
    AND  NOT (o.order_status_cd IN (order_status_canceled_cd, order_status_discontinued_cd,
   order_status_deleted_cd))
    AND o.activity_type_cd=bb_activity_cd
    AND (((request->cat_cnt=0)) OR ((request->cat_cnt > 0)
    AND (o.catalog_cd=request->catlist[d_cat.seq].catalog_cd))) )
   JOIN (sd
   WHERE sd.catalog_cd=o.catalog_cd
    AND sd.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (osrc
   WHERE osrc.order_id=o.order_id)
   JOIN (be
   WHERE (be.order_id= Outerjoin(o.order_id))
    AND (be.exception_type_cd= Outerjoin(exception_msbos_cd))
    AND (be.override_reason_cd= Outerjoin(0.0))
    AND (be.active_ind= Outerjoin(1)) )
   JOIN (c
   WHERE c.container_id=osrc.container_id)
   JOIN (pnl
   WHERE pnl.person_id=c.drawn_id)
  ORDER BY cat_seq, o.orig_order_dt_tm, o.order_id,
   osrc.service_resource_cd, osrc.container_id
  HEAD REPORT
   stat = alterlist(reply->qual,3), reply->person_id = o.person_id, reply->encntr_id = o.encntr_id,
   qual_cnt = 0, cntr_cnt = 0
  HEAD o.orig_order_dt_tm
   row + 0
  HEAD o.order_id
   srs_granted = false, service_resource_cd = osrc.service_resource_cd, srs_granted =
   isresourceviewable(service_resource_cd),
   order_found = true
   IF (srs_granted=true
    AND be.order_id=0.00)
    qual_cnt += 1
    IF (mod(qual_cnt,3)=1
     AND qual_cnt != 1)
     stat = alterlist(reply->qual,(qual_cnt+ 2))
    ENDIF
    reply->qual[qual_cnt].order_id = o.order_id, reply->qual[qual_cnt].order_mnemonic = o
    .order_mnemonic, reply->qual[qual_cnt].catalog_cd = o.catalog_cd,
    reply->qual[qual_cnt].catalog_type_cd = o.catalog_type_cd, reply->qual[qual_cnt].order_status_cd
     = o.order_status_cd, reply->qual[qual_cnt].activity_type = activity_type_bb_cdf,
    reply->qual[qual_cnt].activity_type_cd = o.activity_type_cd, reply->qual[qual_cnt].updt_cnt = o
    .updt_cnt, reply->qual[qual_cnt].order_comment_ind = o.order_comment_ind,
    reply->qual[qual_cnt].bb_processing_cd = sd.bb_processing_cd, reply->qual[qual_cnt].
    bb_default_phases_cd = sd.bb_default_phases_cd, reply->qual[qual_cnt].last_update_provider_id = o
    .last_update_provider_id,
    reply->qual[qual_cnt].order_encntr_facility_cd = e.loc_facility_cd, cntr_cnt = 0
   ELSE
    IF (be.order_id > 0.00)
     order_found = false
    ENDIF
   ENDIF
  HEAD osrc.service_resource_cd
   IF (srs_granted=true
    AND order_found=true)
    cntr_cnt += 1, stat = alterlist(reply->qual[qual_cnt].container_serv_res,cntr_cnt), reply->qual[
    qual_cnt].container_serv_res_cnt = cntr_cnt,
    reply->qual[qual_cnt].status_flag = - (1)
   ENDIF
  HEAD osrc.container_id
   IF (srs_granted=true
    AND order_found=true)
    chk_osrc_status_flag = 0
    IF (osrc.status_flag=1
     AND ((o.order_status_cd=order_status_ordered_cd
     AND o.dept_status_cd != dept_status_labinlab_cd) OR (o.order_status_cd=order_status_inprocess_cd
     AND o.dept_status_cd != dept_status_labinlab_cd
     AND o.dept_status_cd != dept_status_labinprocess_cd)) )
     chk_osrc_status_flag = 0
    ELSE
     chk_osrc_status_flag = osrc.status_flag
    ENDIF
    IF ((((reply->qual[qual_cnt].status_flag=- (1))) OR ((((reply->qual[qual_cnt].status_flag != 1)
     AND chk_osrc_status_flag=1) OR ((reply->qual[qual_cnt].status_flag=0)
     AND chk_osrc_status_flag=2)) ))
     AND osrc.in_lab_dt_tm > 0)
     reply->qual[qual_cnt].container_serv_res[cntr_cnt].container_id = osrc.container_id, reply->
     qual[qual_cnt].container_serv_res[cntr_cnt].order_serv_res_upd_cnt = osrc.updt_cnt, reply->qual[
     qual_cnt].container_serv_res[cntr_cnt].service_resource_cd = osrc.service_resource_cd,
     reply->qual[qual_cnt].container_serv_res[cntr_cnt].specimen_id = c.specimen_id, reply->qual[
     qual_cnt].status_flag = chk_osrc_status_flag, reply->qual[qual_cnt].drawn_dt_tm = c.drawn_dt_tm
     IF (c.drawn_id > 0)
      reply->qual[qual_cnt].drawn_username = pnl.username
     ENDIF
    ENDIF
   ENDIF
  FOOT  o.order_id
   IF (srs_granted=true
    AND order_found=true)
    IF (cntr_cnt > max_cntr_cnt)
     max_cntr_cnt = cntr_cnt
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,qual_cnt)
  WITH nocounter
 ;end select
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus > 0)
  CALL add_reply_status_event("F","Select Orders","F","reply->qual",
   "CCL Error retrieving orders/containers associated with reqeust Accession #")
  GO TO exit_script
 ENDIF
 IF (getresourcesecuritystatus(0)="F")
  CALL populateressecstatusblock(0)
  SET reply->status_data.status = getresourcesecuritystatus(0)
  GO TO exit_script
 ENDIF
 IF (qual_cnt > 0)
  SET serrormsg = ""
  SET nerrorstatus = error(serrormsg,1)
  SELECT
   IF (validate(request->retrieve_only_current_phase_ind,0)=1)
    PLAN (d_o)
     JOIN (d_cntr
     WHERE (d_cntr.seq <= reply->qual[d_o.seq].container_serv_res_cnt))
     JOIN (((ptr
     WHERE (ptr.catalog_cd=reply->qual[d_o.seq].catalog_cd)
      AND ptr.active_ind=1)
     ) ORJOIN ((((op
     WHERE (op.order_id=reply->qual[d_o.seq].order_id)
      AND op.active_ind=1)
     JOIN (pg
     WHERE pg.phase_group_cd=op.phase_grp_cd
      AND pg.active_ind=1)
     ) ORJOIN ((((pe
     WHERE (pe.order_id=reply->qual[d_o.seq].order_id)
      AND pe.event_type_cd=in_progress_cd)
     ) ORJOIN ((((oc
     WHERE (oc.order_id=reply->qual[d_o.seq].order_id))
     ) ORJOIN ((seo
     WHERE (seo.specimen_id=reply->qual[d_o.seq].container_serv_res[d_cntr.seq].specimen_id)
      AND seo.active_ind=1)
     )) )) )) ))
   ELSE
    PLAN (d_o)
     JOIN (d_cntr
     WHERE (d_cntr.seq <= reply->qual[d_o.seq].container_serv_res_cnt))
     JOIN (((ptr
     WHERE (ptr.catalog_cd=reply->qual[d_o.seq].catalog_cd)
      AND ptr.active_ind=1)
     ) ORJOIN ((((op
     WHERE (op.order_id=reply->qual[d_o.seq].order_id))
     JOIN (pg
     WHERE pg.phase_group_cd=op.phase_grp_cd
      AND pg.active_ind=1)
     ) ORJOIN ((((pe
     WHERE (pe.order_id=reply->qual[d_o.seq].order_id)
      AND pe.event_type_cd=in_progress_cd)
     ) ORJOIN ((((oc
     WHERE (oc.order_id=reply->qual[d_o.seq].order_id))
     ) ORJOIN ((seo
     WHERE (seo.specimen_id=reply->qual[d_o.seq].container_serv_res[d_cntr.seq].specimen_id)
      AND seo.active_ind=1)
     )) )) )) ))
   ENDIF
   INTO "nl:"
   order_id = reply->qual[d_o.seq].order_id, container_id = reply->qual[d_o.seq].container_serv_res[
   d_cntr.seq].container_id, table_ind = decode(oc.seq,"oc",pe.seq,"pe",op.seq,
    "op",ptr.seq,"ptr",seo.seq,"seo",
    "xxx"),
   ptr.task_assay_cd, op.order_phase_id, op.phase_group_cd,
   pg.task_assay_cd, pe.product_id, pe.product_event_id,
   oc.cell_cd, sort_id = decode(oc.seq,oc.order_cell_id,pe.seq,pe.product_event_id,op.seq,
    pg.task_assay_cd,ptr.seq,ptr.task_assay_cd,0.0)
   FROM (dummyt d_o  WITH seq = value(qual_cnt)),
    (dummyt d_cntr  WITH seq = value(max_cntr_cnt)),
    profile_task_r ptr,
    bb_order_phase op,
    product_event pe,
    phase_group pg,
    bb_order_cell oc,
    bb_spec_expire_ovrd seo
   ORDER BY order_id, container_id, table_ind,
    sort_id
   HEAD order_id
    total_xm_cnt = 0
   HEAD container_id
    assay_cnt = 0, stat = alterlist(reply->qual[d_o.seq].container_serv_res[d_cntr.seq].assays,5),
    product_cnt = 0,
    stat = alterlist(reply->qual[d_o.seq].container_serv_res[d_cntr.seq].products,5), cell_cnt = 0,
    stat = alterlist(reply->qual[d_o.seq].container_serv_res[d_cntr.seq].cells,3)
   HEAD table_ind
    reply->qual[d_o.seq].phase_grp_cd = op.phase_grp_cd
   DETAIL
    IF (((table_ind="ptr") OR (table_ind="op")) )
     assay_cnt += 1
     IF (mod(assay_cnt,5)=1
      AND assay_cnt != 1)
      stat = alterlist(reply->qual[d_o.seq].container_serv_res[d_cntr.seq].assays,(assay_cnt+ 4))
     ENDIF
     stat = alterlist(reply->qual[d_o.seq].container_serv_res[d_cntr.seq].assays,assay_cnt), reply->
     qual[d_o.seq].container_serv_res[d_cntr.seq].assays_cnt = assay_cnt
     IF (table_ind="ptr")
      reply->qual[d_o.seq].container_serv_res[d_cntr.seq].assays[assay_cnt].task_assay_cd = ptr
      .task_assay_cd, reply->qual[d_o.seq].container_serv_res[d_cntr.seq].assays[assay_cnt].sequence
       = ptr.sequence, reply->qual[d_o.seq].container_serv_res[d_cntr.seq].assays[assay_cnt].
      pending_ind = ptr.pending_ind
     ELSEIF (table_ind="op")
      reply->qual[d_o.seq].container_serv_res[d_cntr.seq].assays[assay_cnt].task_assay_cd = pg
      .task_assay_cd, reply->qual[d_o.seq].container_serv_res[d_cntr.seq].assays[assay_cnt].
      order_phase_id = op.order_phase_id, reply->qual[d_o.seq].container_serv_res[d_cntr.seq].assays[
      assay_cnt].sequence = pg.sequence,
      reply->qual[d_o.seq].container_serv_res[d_cntr.seq].assays[assay_cnt].pending_ind = pg
      .required_ind
     ENDIF
    ELSEIF (table_ind="pe")
     total_xm_cnt += 1, product_cnt += 1
     IF (mod(product_cnt,5)=1
      AND product_cnt != 1)
      stat = alterlist(reply->qual[d_o.seq].container_serv_res[d_cntr.seq].products,(product_cnt+ 4))
     ENDIF
     reply->qual[d_o.seq].container_serv_res[d_cntr.seq].products_cnt = product_cnt, reply->qual[d_o
     .seq].container_serv_res[d_cntr.seq].products[product_cnt].product_id = pe.product_id, reply->
     qual[d_o.seq].container_serv_res[d_cntr.seq].products[product_cnt].product_event_id = pe
     .product_event_id,
     reply->qual[d_o.seq].container_serv_res[d_cntr.seq].products[product_cnt].updt_cnt = pe.updt_cnt,
     reply->qual[d_o.seq].container_serv_res[d_cntr.seq].products[product_cnt].bb_result_id = pe
     .bb_result_id
    ELSEIF (table_ind="oc")
     cell_cnt += 1
     IF (mod(cell_cnt,3)=1
      AND cell_cnt != 3)
      stat = alterlist(reply->qual[d_o.seq].container_serv_res[d_cntr.seq].cells,(cell_cnt+ 2))
     ENDIF
     reply->qual[d_o.seq].container_serv_res[d_cntr.seq].cell_cnt = cell_cnt, reply->qual[d_o.seq].
     container_serv_res[d_cntr.seq].cells[cell_cnt].order_id = order_id, reply->qual[d_o.seq].
     container_serv_res[d_cntr.seq].cells[cell_cnt].order_cell_id = oc.order_cell_id,
     reply->qual[d_o.seq].container_serv_res[d_cntr.seq].cells[cell_cnt].cell_cd = oc.cell_cd, reply
     ->qual[d_o.seq].container_serv_res[d_cntr.seq].cells[cell_cnt].product_id = oc.product_id, reply
     ->qual[d_o.seq].container_serv_res[d_cntr.seq].cells[cell_cnt].bb_result_id = oc.bb_result_id,
     reply->qual[d_o.seq].container_serv_res[d_cntr.seq].cells[cell_cnt].order_cell_updt_cnt = oc
     .updt_cnt
    ELSEIF (table_ind="seo")
     IF ((reply->qual[d_o.seq].activity_type=activity_type_bb_cdf))
      IF (seo.specimen_id > 0.0
       AND seo.active_ind=1)
       reply->qual[d_o.seq].container_serv_res[d_cntr.seq].expiration_dt_tm = seo
       .new_spec_expire_dt_tm
      ENDIF
     ENDIF
    ENDIF
   FOOT  container_id
    stat = alterlist(reply->qual[d_o.seq].container_serv_res[d_cntr.seq].assays,assay_cnt), stat =
    alterlist(reply->qual[d_o.seq].container_serv_res[d_cntr.seq].products,product_cnt), stat =
    alterlist(reply->qual[d_o.seq].container_serv_res[d_cntr.seq].cells,cell_cnt)
   FOOT  order_id
    reply->qual[d_o.seq].total_xm_cnt = total_xm_cnt
   WITH nocounter
  ;end select
  SET nerrorstatus = error(serrormsg,0)
  IF (nerrorstatus > 0)
   CALL add_reply_status_event("F","Select Assays","F","reply->qual",
    "CCL Error retrieving task/assays, phases, products and cells for orders")
   GO TO exit_script
  ENDIF
  SET qual_cnt = size(reply->qual,5)
  FOR (qual_idx = 1 TO qual_cnt)
    IF ((loadflexparams(reply->qual[qual_idx].order_encntr_facility_cd)=- (1)))
     CALL add_reply_status_event("F","Load Flex Params","F","flex_param_out",
      "CCL Error loading flex params")
     GO TO exit_script
    ENDIF
    SET reply->qual[qual_idx].testing_facility_cd = flex_param_out->testing_facility_cd
    SET reply->qual[qual_idx].spec_flex_ind = flex_param_out->flex_on_ind
    IF ((reply->qual[qual_idx].activity_type=activity_type_bb_cdf)
     AND (flex_param_out->flex_on_ind=1))
     SET container_serv_res_cnt = size(reply->qual[qual_idx].container_serv_res,5)
     FOR (container_serv_res_idx = 1 TO container_serv_res_cnt)
       IF ((reply->qual[qual_idx].container_serv_res[container_serv_res_idx].expiration_dt_tm=0.0))
        SET reply->qual[qual_idx].container_serv_res[container_serv_res_idx].expiration_dt_tm =
        getflexexpiration(reply->person_id,0.0,reply->qual[qual_idx].drawn_dt_tm,reply->qual[qual_idx
         ].order_encntr_facility_cd,0)
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  SET reply->status_data.status = "S"
 ELSE
  IF (order_found=true)
   SET operation_name = "RESOURCE SECURITY FAILED"
  ELSE
   SET operation_name = "No orders found."
  ENDIF
  CALL add_reply_status_event("Z",operation_name,"Z","ORDERS","No orders returned.")
 ENDIF
 GO TO exit_script
 DECLARE get_processing_code_values(0) = i2
 SUBROUTINE get_processing_code_values(sub_dummy)
   DECLARE success_ind = i2
   SET success_ind = 0
   SET order_status_canceled_cd = get_code_value(order_status_codeset,order_status_canceled_cdf)
   SET order_status_deleted_cd = get_code_value(order_status_codeset,order_status_deleted_cdf)
   SET order_status_discontinued_cd = get_code_value(order_status_codeset,
    order_status_discontinued_cdf)
   SET order_status_ordered_cd = get_code_value(order_status_codeset,order_status_ordered_cdf)
   SET order_status_inprocess_cd = get_code_value(order_status_codeset,order_status_inprocess_cdf)
   SET dept_status_labinlab_cd = get_code_value(dept_status_codeset,dept_status_labinlab_cdf)
   SET dept_status_labinprocess_cd = get_code_value(dept_status_codeset,dept_status_labinprocess_cdf)
   SET in_progress_cd = get_code_value(product_states_codeset,in_progress_cdf)
   SET crossmatch_cd = get_code_value(product_states_codeset,crossmatch_cdf)
   SET bb_activity_cd = get_code_value(activity_type_codeset,activity_type_bb_cdf)
   SET exception_msbos_cd = uar_get_code_by("MEANING",lexception_type_cs,nullterm(smsbos_cdf))
   IF (0.0 IN (order_status_canceled_cd, order_status_discontinued_cd, order_status_deleted_cd,
   order_status_ordered_cd, order_status_inprocess_cd,
   dept_status_labinlab_cd, dept_status_labinprocess_cd, in_progress_cd, crossmatch_cd,
   bb_activity_cd,
   exception_msbos_cd))
    SET success_ind = 0
    SET targetobjectname = ""
    SET targetobjectvalue = ""
    CASE (0.0)
     OF order_status_canceled_cd:
      SET targetobjectname = "order_status_canceled_cd"
      SET targetobjectvalue = "Unable to retrieve Cancelled Order Status code value"
     OF order_status_discontinued_cd:
      SET targetobjectname = "order_status_discontinued_cd"
      SET targetobjectvalue = "Unable to retrieve Discontinued Order Status code value"
     OF order_status_deleted_cd:
      SET targetobjectname = "order_status_deleted_cd"
      SET targetobjectvalue = "Unable to retrieve Deleted Order Status code value"
     OF order_status_ordered_cd:
      SET targetobjectname = "order_status_ordered_cd"
      SET targetobjectvalue = "Unable to retrieve Ordered Order Status code value"
     OF order_status_inprocess_cd:
      SET targetobjectname = "order_status_inprocess_cd"
      SET targetobjectvalue = "Unable to retrieve InProcess Order Status code value"
     OF dept_status_labinlab_cd:
      SET targetobjectname = "dept_status_labinlab_cd"
      SET targetobjectvalue = "Unable to retrieve LabInLab Department Status code value"
     OF dept_status_labinprocess_cd:
      SET targetobjectname = "dept_status_labinprocess_cd"
      SET targetobjectvalue = "Unable to retrieve LabInProcess Department Status code value"
     OF in_progress_cd:
      SET targetobjectname = "in_progress_cd"
      SET targetobjectvalue = "Unable to retrieve InProgress Product State code value"
     OF crossmatch_cd:
      SET targetobjectname = "crossmatch_cd"
      SET targetobjectvalue = "Unable to retrieve Crossmatched Product State code value"
     OF bb_activity_cd:
      SET targetobjectname = "bb_activity_cd"
      SET targetobjectvalue = "Unable to retrieve Blood Bank (BB) Activity Type code value"
     OF exception_msbos_cd:
      SET targetobjectname = "exception_msbos_cd"
      SET targetobjectvalue =
      "Unable to retrieve Blood Bank Exception Type code value for CDF_MEANING = MSBOS"
     ELSE
      SET reply->status_data.subeventstatus[1].targetobjectname = "Unknown"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Unidentified error retrieving processing code values"
    ENDCASE
    CALL add_reply_status_event("F","uar_get_meaning_by_codeset","F",targetobjectname,
     targetobjectvalue)
   ELSE
    SET success_ind = 1
   ENDIF
   RETURN(success_ind)
 END ;Subroutine
 SUBROUTINE add_reply_status_event(sub_scriptstatus,sub_operationname,sub_operationstatus,
  sub_targetobjectname,sub_targetobjectvalue)
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,count1)
   ENDIF
   SET reply->status_data.status = sub_scriptstatus
   SET reply->status_data.subeventstatus[count1].operationname = sub_operationname
   SET reply->status_data.subeventstatus[count1].operationstatus = sub_operationstatus
   SET reply->status_data.subeventstatus[count1].targetobjectname = sub_targetobjectname
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_targetobjectvalue
   RETURN
 END ;Subroutine
#exit_script
END GO
