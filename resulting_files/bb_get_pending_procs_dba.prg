CREATE PROGRAM bb_get_pending_procs:dba
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
 IF (validate(bb_historical_loaded,1)=1)
  DECLARE bb_historical_loaded = i2 WITH protect, constant(2)
  DECLARE gethistnames(null) = i4
  DECLARE histrecordsstored(lhistrecordsstored=i2(ref)) = i4
  DECLARE loadhistcodevalues(null) = i4
  DECLARE current_name_type_cd = f8 WITH protect, noconstant(0.0)
  DECLARE combine_add_cd = f8 WITH protect, noconstant(0.0)
  DECLARE active_status_cd = f8 WITH protect, noconstant(0.0)
  RECORD rechistnames(
    1 list[*]
      2 person_id = f8
      2 trans_dt_tm = dq8
      2 historical_name = vc
      2 order_id = f8
  )
  SUBROUTINE gethistnames(null)
    DECLARE serrormessage = c132 WITH protect, noconstant(fillstring(132," "))
    DECLARE lerrorflag = i4 WITH protect, noconstant(- (1))
    DECLARE lidx1 = i4 WITH protect, noconstant(- (1))
    DECLARE dcurrentpersonid = f8 WITH protect, noconstant(0.0)
    DECLARE dminute = f8 WITH protect, constant((1/ 1440.0))
    IF (size(rechistnames->list,5) > 0)
     FOR (lidx1 = 1 TO size(rechistnames->list,5))
       SET dcurrentpersonid = rechistnames->list[lidx1].person_id
       SELECT INTO "nl:"
        pc.from_person_id
        FROM person_combine_det pcd,
         person_combine pc
        PLAN (pcd
         WHERE (pcd.entity_id=rechistnames->list[lidx1].order_id)
          AND pcd.entity_name="ORDERS")
         JOIN (pc
         WHERE pc.person_combine_id=pcd.person_combine_id
          AND pc.active_status_cd=active_status_cd
          AND pc.active_status_dt_tm >= cnvtdatetime(rechistnames->list[lidx1].trans_dt_tm)
          AND pc.active_ind=1)
        ORDER BY pc.active_status_dt_tm
        HEAD REPORT
         dcurrentpersonid = pc.from_person_id
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        pnh.name_full
        FROM person_name_hist pnh
        PLAN (pnh
         WHERE pnh.person_id=dcurrentpersonid
          AND pnh.name_type_cd=current_name_type_cd
          AND pnh.transaction_dt_tm <= cnvtdatetime(datetimeadd(rechistnames->list[lidx1].trans_dt_tm,
           dminute))
          AND  NOT ( EXISTS (
         (SELECT
          pcd.entity_id
          FROM person_combine_det pcd
          WHERE pcd.entity_id=pnh.person_name_hist_id
           AND pcd.entity_name="PERSON_NAME_HIST"
           AND pcd.combine_action_cd=combine_add_cd))))
        ORDER BY pnh.transaction_dt_tm DESC
        HEAD REPORT
         rechistnames->list[lidx1].historical_name = pnh.name_full
        WITH nocounter
       ;end select
     ENDFOR
     SET lerrorflag = error(serrormessage,0)
     IF (lerrorflag != 0)
      CALL populate_subeventstatus(build("GetHistNames()"),"F","select",nullterm(cnvtstring(
         serrormessage)))
      RETURN(0)
     ENDIF
    ENDIF
    RETURN(1)
  END ;Subroutine
  SUBROUTINE loadhistcodevalues(null)
    DECLARE current_name_type_mean = c12 WITH protect, constant("CURRENT")
    DECLARE name_type_cs = i4 WITH protect, constant(213)
    DECLARE combine_action_cs = i4 WITH protect, constant(327)
    DECLARE combine_action_add_mean = c12 WITH protect, constant("ADD")
    DECLARE rec_sts_cs = i4 WITH protect, constant(48)
    DECLARE rec_sts_active_mean = c12 WITH protect, constant("ACTIVE")
    DECLARE lexitstatus = i4 WITH protect, noconstant(- (1))
    SET lexitstatus = 1
    SET combine_add_cd = uar_get_code_by("MEANING",combine_action_cs,nullterm(combine_action_add_mean
      ))
    IF (combine_add_cd < 1)
     CALL populate_subeventstatus("LoadHistCodeValues()","F","uar_get_code_by() ",build2(
       "Load meaning ",combine_action_add_mean," from CS",nullterm(cnvtstring(combine_action_cs)),
       " failed with status ",
       nullterm(cnvtstring(combine_add_cd,32,2))))
     SET lexitstatus = 0
    ENDIF
    SET current_name_type_cd = uar_get_code_by("MEANING",name_type_cs,nullterm(current_name_type_mean
      ))
    IF (current_name_type_cd < 1)
     CALL populate_subeventstatus("LoadHistCodeValues()","F","uar_get_code_by() ",build2(
       "Load meaning ",current_name_type_mean," from CS",nullterm(cnvtstring(name_type_cs)),
       " failed with status ",
       nullterm(cnvtstring(current_name_type_cd,32,2))))
     SET lexitstatus = 0
    ENDIF
    SET active_status_cd = uar_get_code_by("MEANING",rec_sts_cs,nullterm(rec_sts_active_mean))
    IF (active_status_cd < 1)
     CALL populate_subeventstatus("LoadHistCodeValues()","F","uar_get_code_by() ",build2(
       "Load meaning ",rec_sts_active_mean," from CS",nullterm(cnvtstring(rec_sts_cs)),
       " failed with status ",
       nullterm(cnvtstring(active_status_cd,32,2))))
     SET lexitstatus = 0
    ENDIF
    RETURN(lexitstatus)
  END ;Subroutine
 ENDIF
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
 RECORD reply(
   1 historical_demog_ind = i2
   1 name_full_formatted = vc
   1 pend_proc_list[*]
     2 service_resource_cd = f8
     2 service_resource_disp = vc
     2 order_mnemonic = vc
     2 report_priority_cd = f8
     2 report_priority_disp = vc
     2 accession_raw = c20
     2 accession_formatted = c20
     2 drawn_dt_tm = dq8
     2 dept_status_cd = f8
     2 dept_status_disp = vc
     2 order_comment_ind = i2
     2 container_location_cd = f8
     2 container_location_disp = vc
     2 received_dt_tm = dq8
     2 historical_name = c40
     2 order_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE activity_type_bb = f8 WITH protect, noconstant(0.0)
 DECLARE activity_type_codeset = i4 WITH protect, constant(106)
 DECLARE activity_type_mean_bb = vc WITH protect, constant("BB")
 DECLARE department_status_codeset = i4 WITH protect, constant(14281)
 DECLARE department_status_in_lab = f8 WITH protect, noconstant(0.0)
 DECLARE department_status_in_process = f8 WITH protect, noconstant(0.0)
 DECLARE dept_status_meaning_in_lab = vc WITH protect, constant("LABINLAB")
 DECLARE dept_status_meaning_in_process = vc WITH protect, constant("LABINPROCESS")
 DECLARE lab_catalog_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE order_status_meaning_ordered = vc WITH protect, constant("ORDERED")
 DECLARE order_status_meaning_inprocess = vc WITH protect, constant("INPROCESS")
 DECLARE order_status_codeset = i4 WITH protect, constant(6004)
 DECLARE order_status_ordered = f8 WITH protect, noconstant(0.0)
 DECLARE order_status_in_process = f8 WITH protect, noconstant(0.0)
 DECLARE cresourcesecstatus = c1 WITH noconstant("")
 DECLARE iserviceresaccess = i2 WITH protect, noconstant(- (1))
 DECLARE icontainerreq = i2 WITH protect, noconstant(- (1))
 DECLARE lerrorflag = i4 WITH protect, noconstant(- (1))
 DECLARE lhistdemogsstored = i2 WITH noconstant(- (1))
 DECLARE lsize = i4 WITH protect, noconstant(- (1))
 DECLARE lstatus = i4 WITH protect, noconstant(- (1))
 DECLARE serrormessage = c132 WITH protect, noconstant(fillstring(132," "))
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM person p
  WHERE (p.person_id=request->person_id)
  DETAIL
   reply->name_full_formatted = p.name_full_formatted
  WITH nocounter
 ;end select
 SET lerrorflag = error(serrormessage,0)
 IF (lerrorflag != 0)
  CALL populate_subeventstatus(build("Set person's full name"),"F","select",nullterm(cnvtstring(
     serrormessage)))
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF (loadhistcodevalues(null)=0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET reply->historical_demog_ind = bbtgethistoricinfopreference(request->facility_cd)
 SET activity_type_bb = uar_get_code_by("MEANING",activity_type_codeset,nullterm(
   activity_type_mean_bb))
 IF (activity_type_bb < 1)
  CALL populate_subeventstatus("Main Block","F","uar_get_code_by() ",build2("Load meaning ",
    activity_type_mean_bb," from CS",nullterm(cnvtstring(activity_type_codeset)),
    " failed with status ",
    nullterm(cnvtstring(activity_type_bb,19,0))))
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET department_status_in_lab = uar_get_code_by("MEANING",department_status_codeset,nullterm(
   dept_status_meaning_in_lab))
 IF (department_status_in_lab < 1)
  CALL populate_subeventstatus("Main Block","F","uar_get_code_by() ",build2("Load meaning ",
    dept_status_meaning_in_lab," from CS",nullterm(cnvtstring(department_status_codeset)),
    " failed with status ",
    nullterm(cnvtstring(department_status_in_lab,19,0))))
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET department_status_in_process = uar_get_code_by("MEANING",department_status_codeset,nullterm(
   dept_status_meaning_in_process))
 IF (department_status_in_process < 1)
  CALL populate_subeventstatus("Main Block","F","uar_get_code_by() ",build2("Load meaning ",
    dept_status_meaning_in_process," from CS",nullterm(cnvtstring(department_status_codeset)),
    " failed with status ",
    nullterm(cnvtstring(department_status_in_process,19,0))))
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET lab_catalog_type_cd = uar_get_code_by("MEANING",6000,"GENERAL LAB")
 IF (lab_catalog_type_cd < 1)
  CALL populate_subeventstatus("Main Block","F","uar_get_code_by() ",build2("Load meaning ",
    "GENERAL LAB"," from CS",nullterm(cnvtstring(6000))," failed with status ",
    nullterm(cnvtstring(lab_catalog_type_cd,19,0))))
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET order_status_ordered = uar_get_code_by("MEANING",order_status_codeset,
  order_status_meaning_ordered)
 IF (order_status_ordered < 1)
  CALL populate_subeventstatus("Main Block","F","uar_get_code_by() ",build2("Load meaning ",
    order_status_meaning_ordered," from CS",nullterm(cnvtstring(order_status_codeset)),
    " failed with status ",
    nullterm(cnvtstring(order_status_ordered,19,0))))
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET order_status_in_process = uar_get_code_by("MEANING",order_status_codeset,
  order_status_meaning_inprocess)
 IF (order_status_in_process < 1)
  CALL populate_subeventstatus("Main Block","F","uar_get_code_by() ",build2("Load meaning ",
    order_status_meaning_inprocess," from CS",nullterm(cnvtstring(order_status_codeset)),
    " failed with status ",
    nullterm(cnvtstring(order_status_in_process,19,0))))
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 CALL initresourcesecurity(true)
 SET cresourcesecstatus = getresourcesecuritystatus(0)
 IF (cresourcesecstatus="F")
  CALL populate_subeventstatus("Check resource sec","F","GetResourceSecurityStatus(0)","F")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ELSEIF (cresourcesecstatus="Z")
  CALL populate_subeventstatus("Check resource sec","Z","GetResourceSecurityStatus()",
   "Z - User does not have access to any service resources.")
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 SET lsize = 0
 SELECT INTO "nl:"
  o.order_mnemonic, aor.accession, formatted_accn = cnvtacc(aor.accession),
  ol.report_priority_cd, osrc.current_location_cd, osrc.in_lab_dt_tm,
  osrc.service_resource_cd, c.drawn_dt_tm, o.order_id
  FROM orders o,
   accession_order_r aor,
   order_laboratory ol,
   order_serv_res_container osrc,
   container c,
   order_comment oc
  PLAN (o
   WHERE (o.person_id=request->person_id)
    AND o.catalog_type_cd=lab_catalog_type_cd
    AND o.order_status_cd IN (order_status_ordered, order_status_in_process)
    AND ((o.activity_type_cd+ 0)=(activity_type_bb+ 0))
    AND o.dept_status_cd IN (department_status_in_lab, department_status_in_process))
   JOIN (aor
   WHERE aor.order_id=o.order_id
    AND aor.primary_flag=0)
   JOIN (ol
   WHERE ol.order_id=aor.order_id)
   JOIN (osrc
   WHERE osrc.order_id=ol.order_id)
   JOIN (c
   WHERE c.container_id=osrc.container_id)
   JOIN (oc
   WHERE (oc.order_id= Outerjoin(o.order_id)) )
  ORDER BY o.order_id, osrc.service_resource_cd, osrc.container_id
  HEAD o.order_id
   iserviceresaccess = 0
  HEAD osrc.service_resource_cd
   icontainerreq = 0
   IF (iserviceresaccess=0)
    IF (isresourceviewable(osrc.service_resource_cd)=true)
     iserviceresaccess = 1, icontainerreq = 1, lsize += 1
     IF (lsize > size(reply->pend_proc_list,5))
      lstatus = alterlist(reply->pend_proc_list,(lsize+ 9))
     ENDIF
    ENDIF
   ENDIF
  HEAD osrc.container_id
   IF (osrc.in_lab_dt_tm > 0
    AND icontainerreq=1)
    icontainerreq = 0, reply->pend_proc_list[lsize].service_resource_cd = osrc.service_resource_cd,
    reply->pend_proc_list[lsize].order_mnemonic = o.order_mnemonic,
    reply->pend_proc_list[lsize].report_priority_cd = ol.report_priority_cd, reply->pend_proc_list[
    lsize].accession_raw = substring(1,20,aor.accession), reply->pend_proc_list[lsize].
    accession_formatted = substring(1,20,formatted_accn),
    reply->pend_proc_list[lsize].drawn_dt_tm = c.drawn_dt_tm, reply->pend_proc_list[lsize].
    dept_status_cd = o.dept_status_cd
    IF (size(trim(oc.rowid),1) > 0)
     reply->pend_proc_list[lsize].order_comment_ind = 1
    ELSE
     reply->pend_proc_list[lsize].order_comment_ind = 0
    ENDIF
    reply->pend_proc_list[lsize].container_location_cd = osrc.current_location_cd, reply->
    pend_proc_list[lsize].received_dt_tm = osrc.in_lab_dt_tm, reply->pend_proc_list[lsize].order_id
     = o.order_id
    IF ((reply->historical_demog_ind=1))
     lstatus = alterlist(rechistnames->list,(lsize+ 9)), rechistnames->list[lsize].person_id =
     request->person_id, rechistnames->list[lsize].trans_dt_tm = c.drawn_dt_tm,
     rechistnames->list[lsize].order_id = o.order_id
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = oc_d
 ;end select
 SET lstatus = error(serrormessage,0)
 IF (lstatus != 0)
  CALL populate_subeventstatus("Get pending procs","F","select",serrormessage)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET lstatus = alterlist(reply->pend_proc_list,lsize)
 SET lstatus = alterlist(rechistnames->list,lsize)
 IF ((reply->historical_demog_ind=1))
  SET lstatus = gethistnames(null)
  IF (lstatus=1)
   SET lsize = size(reply->pend_proc_list,5)
   FOR (lidx = 1 TO lsize)
     SET reply->pend_proc_list[lidx].historical_name = rechistnames->list[lidx].historical_name
   ENDFOR
  ELSE
   CALL populate_subeventstatus(build("Retrieve historical names"),"F","GetHistNames()","0")
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
