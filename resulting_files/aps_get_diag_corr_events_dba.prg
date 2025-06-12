CREATE PROGRAM aps_get_diag_corr_events:dba
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
 SUBROUTINE (populatesrtypesforsecurity(case_ind=i2) =null)
   IF (case_ind=1)
    SET stat = alterlist(default_service_type_cd->service_type_cd_list,6)
    SET default_service_type_cd->service_type_cd_list[1].service_type_cd = uar_get_code_by("MEANING",
     223,"INSTITUTION")
    SET default_service_type_cd->service_type_cd_list[2].service_type_cd = uar_get_code_by("MEANING",
     223,"DEPARTMENT")
    SET default_service_type_cd->service_type_cd_list[3].service_type_cd = uar_get_code_by("MEANING",
     223,"SECTION")
    SET default_service_type_cd->service_type_cd_list[4].service_type_cd = uar_get_code_by("MEANING",
     223,"SUBSECTION")
    SET default_service_type_cd->service_type_cd_list[5].service_type_cd = uar_get_code_by("MEANING",
     223,"BENCH")
    SET default_service_type_cd->service_type_cd_list[6].service_type_cd = uar_get_code_by("MEANING",
     223,"INSTRUMENT")
   ENDIF
 END ;Subroutine
 RECORD reply(
   1 debug_str = vc
   1 event_qual[*]
     2 event_id = f8
     2 study_id = f8
     2 sys_corr_id = f8
     2 evaluate_case_id = f8
     2 evaluate_accession = c21
     2 correlate_case_id = f8
     2 correlate_accession = c21
     2 init_eval_term_id = f8
     2 init_eval_term_disp = c15
     2 init_discrep_term_id = f8
     2 init_discrep_term_disp = c15
     2 disagree_reason_cd = f8
     2 disagree_reason_disp = c40
     2 investigation_cd = f8
     2 investigation_disp = c40
     2 resolution_cd = f8
     2 resolution_disp = c40
     2 final_eval_term_id = f8
     2 final_eval_term_disp = c15
     2 final_discrep_term_id = f8
     2 final_discrep_term_disp = c15
     2 initiated_prsnl_id = f8
     2 initiated_prsnl_name = vc
     2 initiated_dt_tm = dq8
     2 complete_prsnl_id = f8
     2 complete_prsnl_name = vc
     2 complete_dt_tm = dq8
     2 cancel_prsnl_id = f8
     2 cancel_prsnl_name = vc
     2 cancel_dt_tm = dq8
     2 slide_counts = f8
     2 report_issued_by_prsnl_name = vc
     2 report_issued_by_prsnl_id = f8
     2 assign_to_group_ind = i2
     2 prsnl_group_id = f8
     2 prsnl_group_name = vc
     2 comment = vc
     2 long_text_id = f8
     2 updt_cnt = i4
     2 prsnl_qual[*]
       3 prsnl_id = f8
       3 prsnl_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 DECLARE x = i2 WITH private, noconstant(0)
 DECLARE event_cnt = i2
 DECLARE param_cnt = i2
 DECLARE check_for_unassigned_ind = i2 WITH private, noconstant(0)
 DECLARE check_for_assigned_ind = i2 WITH private, noconstant(0)
 DECLARE date_range_param_cnt = i2 WITH private, noconstant(0)
 DECLARE adce_where = vc WITH private, noconstant(" ")
 DECLARE study_where = vc WITH private, noconstant("1=1")
 DECLARE evaluate_where = vc WITH private, noconstant("1=1")
 DECLARE assigned_where = vc WITH private, noconstant("1=1")
 DECLARE unassigned_where = vc WITH private, noconstant("1=1")
 DECLARE adcp_where = vc WITH private, noconstant("adce.event_id = adcp.event_id")
 DECLARE issued_where = vc WITH private, noconstant("1=1")
 DECLARE complete_where = vc WITH private, noconstant("adce.complete_prsnl_id in (0,null) ")
 DECLARE canceled_where = vc WITH private, noconstant("adce.cancel_prsnl_id in (0,null) ")
 DECLARE initiated_where = vc WITH private, noconstant("1=1")
 DECLARE security_failure_flag = i4 WITH protect, noconstant(0)
 SET beg_value_dt_tm = cnvtdatetime(sysdate)
 SET end_value_dt_tm = cnvtdatetime(sysdate)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 CALL initresourcesecurity(1)
 CALL populatesrtypesforsecurity(1)
 SET param_cnt = cnvtint(size(request->param_qual,5))
 FOR (x = 1 TO param_cnt)
   CASE (trim(request->param_qual[x].param_name))
    OF "STUDY":
     SET study_where = build("adce.study_id = ",request->param_qual[x].param_id)
    OF "EVALUATE_CASE":
     SET evaluate_where = build("adce.case_id = ",request->param_qual[x].param_id)
    OF "PERSON":
     SET evaluate_where = concat(build(
       "adce.case_id IN (select pc.case_id from pathology_case pc where pc.person_id=",request->
       param_qual[x].param_id),")")
    OF "INCLUDE_UNASSIGNED_PERSON":
     SET unassigned_where = "adce.assign_to_group_ind = 0 and adce.prsnl_group_id = 0"
     SET check_for_unassigned_ind = 1
    OF "INCLUDE_UNASSIGNED_GROUP":
     SET unassigned_where = "adce.assign_to_group_ind = 1 and adce.prsnl_group_id = 0"
     SET check_for_unassigned_ind = 1
    OF "PERFORMED_BY_GROUP":
     SET check_for_assigned_ind = 1
     SET assigned_where = build("adce.assign_to_group_ind = 1 and adce.prsnl_group_id = ",request->
      param_qual[x].param_id)
     SET adcp_where = build("adce.event_id = adcp.event_id and adcp.prsnl_group_id = ",request->
      param_qual[x].param_id)
    OF "PERFORMED_BY_PERSON":
     SET check_for_assigned_ind = 1
     SET assigned_where = "adce.assign_to_group_ind = 0 and adce.prsnl_group_id = 0"
     SET adcp_where = build("adce.event_id = adcp.event_id and adcp.prsnl_id = ",request->param_qual[
      x].param_id)
    OF "REPORT_ISSUED_BY":
     SET issued_where = build("adce.report_issued_by_prsnl_id = ",request->param_qual[x].param_id)
    OF "RETURN_COMPLETED":
     SET complete_where = "1=1"
    OF "RETURN_CANCELED":
     SET canceled_where = "1=1"
    OF "INITIATED_FROM_DAY":
     SET date_range_param_cnt += 1
     SET beg_value_dt_tm = request->param_qual[x].param_dt_tm
    OF "INITIATED_TO_DAY":
     SET date_range_param_cnt += 1
     SET end_value_dt_tm = request->param_qual[x].param_dt_tm
   ENDCASE
 ENDFOR
 RECORD dtemp(
   1 beg_of_day = dq8
   1 end_of_day = dq8
   1 beg_of_day_abs = dq8
   1 end_of_day_abs = dq8
   1 beg_of_month = dq8
   1 end_of_month = dq8
   1 beg_of_month_abs = dq8
   1 end_of_month_abs = dq8
 )
 SUBROUTINE change_times(start_date,end_date)
  CALL getstartofday(start_date,0)
  CALL getendofday(end_date,0)
 END ;Subroutine
 SUBROUTINE getstartofdayabs(date_time,date_offset)
  CALL getstartofday(date_time,date_offset)
  SET dtemp->beg_of_day_abs = cnvtdatetimeutc(dtemp->beg_of_day,2)
 END ;Subroutine
 SUBROUTINE getstartofday(date_time,date_offset)
   SET dtemp->beg_of_day = cnvtdatetime((cnvtdate(date_time) - date_offset),0)
 END ;Subroutine
 SUBROUTINE getendofdayabs(date_time,date_offset)
  CALL getendofday(date_time,date_offset)
  SET dtemp->end_of_day_abs = cnvtdatetimeutc(dtemp->end_of_day,2)
 END ;Subroutine
 SUBROUTINE getendofday(date_time,date_offset)
   SET dtemp->end_of_day = cnvtdatetime((cnvtdate(date_time) - date_offset),235959)
 END ;Subroutine
 SUBROUTINE getstartofmonthabs(date_time,month_offset)
  CALL getstartofmonth(date_time,month_offset)
  SET dtemp->beg_of_month_abs = cnvtdatetimeutc(dtemp->beg_of_month,2)
 END ;Subroutine
 SUBROUTINE getstartofmonth(date_time,month_offset)
   DECLARE nyearoffset = i4
   DECLARE nmonthremainder = i4
   DECLARE nbeginningmonth = i4
   IF (((month(date_time)+ month_offset) <= 0))
    IF (mod(((month(date_time)+ month_offset) - 12),12) != 0)
     SET nyearoffset = (((month(date_time)+ month_offset) - 12)/ 12)
    ELSE
     SET nyearoffset = (((month(date_time)+ month_offset) - 11)/ 12)
    ENDIF
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = (12+ nmonthremainder)
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ELSE
    SET nyearoffset = (((month(date_time)+ month_offset) - 1)/ 12)
    SET nmonthremainder = mod((month(date_time)+ month_offset),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = nmonthremainder
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ENDIF
   SET date_string = build("01",format(nbeginningmonth,"##;p0"),(year(date_time)+ nyearoffset))
   SET dtemp->beg_of_month = cnvtdatetime(cnvtdate2(date_string,"ddmmyyyy"),0)
 END ;Subroutine
 SUBROUTINE getendofmonthabs(date_time,month_offset)
  CALL getendofmonth(date_time,month_offset)
  SET dtemp->end_of_month_abs = cnvtdatetimeutc(dtemp->end_of_month,2)
 END ;Subroutine
 SUBROUTINE getendofmonth(date_time,month_offset)
   DECLARE nyearoffset = i4
   DECLARE nmonthremainder = i4
   DECLARE nbeginningmonth = i4
   IF (((month(date_time)+ month_offset) < 0))
    IF (mod(((month(date_time)+ month_offset) - 12),12) != 0)
     SET nyearoffset = (((month(date_time)+ month_offset) - 12)/ 12)
    ELSE
     SET nyearoffset = (((month(date_time)+ month_offset) - 11)/ 12)
    ENDIF
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = (12+ nmonthremainder)
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ELSE
    SET nyearoffset = ((month(date_time)+ month_offset)/ 12)
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = nmonthremainder
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ENDIF
   SET date_string = build("01",format(nbeginningmonth,"##;p0"),(year(date_time)+ nyearoffset))
   SET dtemp->end_of_month = cnvtdatetime((cnvtdate2(date_string,"ddmmyyyy") - 1),235959)
 END ;Subroutine
 IF (date_range_param_cnt=2)
  CALL change_times(beg_value_dt_tm,end_value_dt_tm)
  SET initiated_where = build("adce.initiated_dt_tm between cnvtdatetime(",dtemp->beg_of_day,
   ") and cnvtdatetime(",dtemp->end_of_day,")")
 ENDIF
 IF (check_for_assigned_ind=0
  AND check_for_unassigned_ind=0)
  SET adce_where = study_where
  SET adce_where = concat(adce_where," and ",evaluate_where)
  SET adce_where = concat(adce_where," and ",issued_where)
  SET adce_where = concat(adce_where," and ",initiated_where)
  SET adce_where = concat(adce_where," and ",complete_where)
  SET adce_where = concat(adce_where," and ",canceled_where)
  SET adce_where = concat(adce_where," and ",assigned_where)
  SET reply->debug_str = adce_where
  SELECT INTO "nl:"
   adce.event_id
   FROM ap_dc_event adce,
    ap_dc_event_prsnl adcp,
    (dummyt d  WITH seq = 1),
    prsnl pr1
   PLAN (adce
    WHERE parser(adce_where))
    JOIN (d)
    JOIN (adcp
    WHERE adce.event_id=adcp.event_id)
    JOIN (pr1
    WHERE adcp.prsnl_id=pr1.person_id)
   ORDER BY adce.event_id
   HEAD adce.event_id
    prsnl_cnt = 0, event_cnt += 1
    IF (mod(event_cnt,10)=1)
     stat = alterlist(reply->event_qual,(event_cnt+ 10))
    ENDIF
    reply->event_qual[event_cnt].event_id = adce.event_id
   DETAIL
    IF (adcp.seq != 0)
     prsnl_cnt += 1
     IF (mod(prsnl_cnt,10)=1)
      stat = alterlist(reply->event_qual[event_cnt].prsnl_qual,(prsnl_cnt+ 10))
     ENDIF
     reply->event_qual[event_cnt].prsnl_qual[prsnl_cnt].prsnl_id = pr1.person_id
     IF (pr1.person_id != 0)
      reply->event_qual[event_cnt].prsnl_qual[prsnl_cnt].prsnl_name = pr1.name_full_formatted
     ENDIF
    ENDIF
   FOOT  adce.event_id
    stat = alterlist(reply->event_qual[event_cnt].prsnl_qual,prsnl_cnt)
   WITH nocounter, outerjoin = d
  ;end select
 ENDIF
 IF (check_for_assigned_ind=1)
  SET adce_where = study_where
  SET adce_where = concat(adce_where," and ",evaluate_where)
  SET adce_where = concat(adce_where," and ",issued_where)
  SET adce_where = concat(adce_where," and ",initiated_where)
  SET adce_where = concat(adce_where," and ",complete_where)
  SET adce_where = concat(adce_where," and ",canceled_where)
  SET adce_where = concat(adce_where," and ",assigned_where)
  SET reply->debug_str = adce_where
  SELECT INTO "nl:"
   adce.event_id
   FROM ap_dc_event adce,
    ap_dc_event_prsnl adcp,
    prsnl pr1
   PLAN (adce
    WHERE parser(adce_where))
    JOIN (adcp
    WHERE parser(adcp_where))
    JOIN (pr1
    WHERE adcp.prsnl_id=pr1.person_id)
   ORDER BY adce.event_id
   HEAD adce.event_id
    prsnl_cnt = 0, event_cnt += 1
    IF (mod(event_cnt,10)=1)
     stat = alterlist(reply->event_qual,(event_cnt+ 10))
    ENDIF
    reply->event_qual[event_cnt].event_id = adce.event_id
   DETAIL
    prsnl_cnt += 1
    IF (mod(prsnl_cnt,10)=1)
     stat = alterlist(reply->event_qual[event_cnt].prsnl_qual,(prsnl_cnt+ 10))
    ENDIF
    reply->event_qual[event_cnt].prsnl_qual[prsnl_cnt].prsnl_id = pr1.person_id
    IF (pr1.person_id != 0)
     reply->event_qual[event_cnt].prsnl_qual[prsnl_cnt].prsnl_name = pr1.name_full_formatted
    ENDIF
   FOOT  adce.event_id
    stat = alterlist(reply->event_qual[event_cnt].prsnl_qual,prsnl_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (check_for_unassigned_ind=1)
  SET adce_where = study_where
  SET adce_where = concat(adce_where," and ",evaluate_where)
  SET adce_where = concat(adce_where," and ",issued_where)
  SET adce_where = concat(adce_where," and ",initiated_where)
  SET adce_where = concat(adce_where," and ",complete_where)
  SET adce_where = concat(adce_where," and ",canceled_where)
  SET adce_where = concat(adce_where," and ",unassigned_where)
  SET reply->debug_str = adce_where
  SELECT INTO "nl:"
   adce.event_id
   FROM ap_dc_event adce,
    ap_dc_event_prsnl adcp,
    (dummyt d  WITH seq = 1)
   PLAN (adce
    WHERE parser(adce_where))
    JOIN (d)
    JOIN (adcp
    WHERE parser(adcp_where))
   ORDER BY adce.event_id
   HEAD adce.event_id
    prsnl_cnt = 0, event_cnt += 1
    IF (mod(event_cnt,10)=1)
     stat = alterlist(reply->event_qual,(event_cnt+ 10))
    ENDIF
    reply->event_qual[event_cnt].event_id = adce.event_id
   FOOT  adce.event_id
    stat = alterlist(reply->event_qual[event_cnt].prsnl_qual,prsnl_cnt)
   WITH nocounter, outerjoin = d, dontexist
  ;end select
 ENDIF
 IF (event_cnt > 0)
  SELECT INTO "nl:"
   adce.event_id
   FROM (dummyt d  WITH seq = value(event_cnt)),
    ap_dc_event adce,
    pathology_case pc1,
    pathology_case pc2,
    ap_prefix ap1,
    ap_prefix ap2,
    prsnl_group pg,
    long_text lt,
    prsnl pr2,
    prsnl pr3,
    prsnl pr4,
    prsnl pr5,
    ap_dc_evaluation_term adcet1,
    ap_dc_evaluation_term adcet2,
    ap_dc_discrepancy_term adcdt1,
    ap_dc_discrepancy_term adcdt2
   PLAN (d)
    JOIN (adce
    WHERE (adce.event_id=reply->event_qual[d.seq].event_id))
    JOIN (pg
    WHERE adce.prsnl_group_id=pg.prsnl_group_id)
    JOIN (pc1
    WHERE adce.case_id=pc1.case_id)
    JOIN (ap1
    WHERE pc1.prefix_id=ap1.prefix_id)
    JOIN (pc2
    WHERE adce.correlate_case_id=pc2.case_id)
    JOIN (ap2
    WHERE pc2.prefix_id=ap2.prefix_id)
    JOIN (adcet1
    WHERE adce.init_eval_term_id=adcet1.evaluation_term_id)
    JOIN (adcdt1
    WHERE adce.init_discrep_term_id=adcdt1.discrepancy_term_id)
    JOIN (adcet2
    WHERE adce.final_eval_term_id=adcet2.evaluation_term_id)
    JOIN (adcdt2
    WHERE adce.final_discrep_term_id=adcdt2.discrepancy_term_id)
    JOIN (pr2
    WHERE adce.initiated_prsnl_id=pr2.person_id)
    JOIN (pr3
    WHERE adce.complete_prsnl_id=pr3.person_id)
    JOIN (pr4
    WHERE adce.cancel_prsnl_id=pr4.person_id)
    JOIN (pr5
    WHERE adce.report_issued_by_prsnl_id=pr5.person_id)
    JOIN (lt
    WHERE adce.long_text_id=lt.long_text_id)
   HEAD REPORT
    access_to_resource_ind = 0, service_resource_cd = 0.0, failed_event_cnt = 0
   DETAIL
    IF ((request->skip_resource_security_ind=0))
     m_nressecind = true
    ELSE
     m_nressecind = false
    ENDIF
    access_to_resource_ind = 1
    IF (pc1.case_id != 0)
     service_resource_cd = ap1.service_resource_cd
     IF (isresourceviewable(service_resource_cd)=false)
      access_to_resource_ind = 0, security_failure_flag = ncase_sec_msg_type
     ENDIF
    ENDIF
    m_nressecind = true
    IF (pg.prsnl_group_id != 0)
     IF (isresourceviewable(pg.service_resource_cd)=false)
      access_to_resource_ind = 0
      IF (security_failure_flag=0)
       security_failure_flag = ncorr_group_sec_msg_type
      ENDIF
     ENDIF
    ENDIF
    IF (access_to_resource_ind=1)
     reply->event_qual[d.seq].sys_corr_id = adce.sys_corr_id, reply->event_qual[d.seq].study_id =
     adce.study_id, reply->event_qual[d.seq].evaluate_case_id = pc1.case_id
     IF (pc1.case_id != 0)
      reply->event_qual[d.seq].evaluate_accession = pc1.accession_nbr
     ENDIF
     reply->event_qual[d.seq].correlate_case_id = pc2.case_id
     IF (pc2.case_id != 0)
      reply->event_qual[d.seq].correlate_accession = pc2.accession_nbr
     ENDIF
     reply->event_qual[d.seq].init_eval_term_id = adcet1.evaluation_term_id
     IF (adcet1.evaluation_term_id != 0)
      reply->event_qual[d.seq].init_eval_term_disp = adcet1.display
     ENDIF
     reply->event_qual[d.seq].init_discrep_term_id = adcdt1.discrepancy_term_id
     IF (adcdt1.discrepancy_term_id != 0)
      reply->event_qual[d.seq].init_discrep_term_disp = adcdt1.display
     ENDIF
     reply->event_qual[d.seq].final_eval_term_id = adcet2.evaluation_term_id
     IF (adcet2.evaluation_term_id != 0)
      reply->event_qual[d.seq].final_eval_term_disp = adcet2.display
     ENDIF
     reply->event_qual[d.seq].final_discrep_term_id = adcdt2.discrepancy_term_id
     IF (adcdt2.discrepancy_term_id != 0)
      reply->event_qual[d.seq].final_discrep_term_disp = adcdt2.display
     ENDIF
     reply->event_qual[d.seq].initiated_prsnl_id = pr2.person_id
     IF (pr2.person_id != 0)
      reply->event_qual[d.seq].initiated_prsnl_name = pr2.name_full_formatted
     ENDIF
     reply->event_qual[d.seq].disagree_reason_cd = adce.disagree_reason_cd, reply->event_qual[d.seq].
     investigation_cd = adce.investigation_cd, reply->event_qual[d.seq].resolution_cd = adce
     .resolution_cd,
     reply->event_qual[d.seq].initiated_dt_tm = cnvtdatetime(adce.initiated_dt_tm), reply->
     event_qual[d.seq].complete_dt_tm = cnvtdatetime(adce.complete_dt_tm), reply->event_qual[d.seq].
     cancel_dt_tm = cnvtdatetime(adce.cancel_dt_tm),
     reply->event_qual[d.seq].complete_prsnl_id = pr3.person_id
     IF (pr3.person_id != 0)
      reply->event_qual[d.seq].complete_prsnl_name = pr3.name_full_formatted
     ENDIF
     reply->event_qual[d.seq].cancel_prsnl_id = pr4.person_id
     IF (pr4.person_id != 0)
      reply->event_qual[d.seq].cancel_prsnl_name = pr4.name_full_formatted
     ENDIF
     reply->event_qual[d.seq].slide_counts = adce.slide_counts, reply->event_qual[d.seq].
     report_issued_by_prsnl_id = pr5.person_id
     IF (pr5.person_id != 0)
      reply->event_qual[d.seq].report_issued_by_prsnl_name = pr5.name_full_formatted
     ENDIF
     reply->event_qual[d.seq].assign_to_group_ind = adce.assign_to_group_ind, reply->event_qual[d.seq
     ].updt_cnt = adce.updt_cnt, reply->event_qual[d.seq].long_text_id = adce.long_text_id
     IF (adce.long_text_id != 0)
      reply->event_qual[d.seq].comment = lt.long_text
     ENDIF
     reply->event_qual[d.seq].prsnl_group_id = pg.prsnl_group_id
     IF (pg.prsnl_group_id != 0)
      reply->event_qual[d.seq].prsnl_group_name = pg.prsnl_group_name
     ENDIF
    ELSE
     reply->event_qual[d.seq].event_id = 0, failed_event_cnt += 1
    ENDIF
   FOOT REPORT
    IF (failed_event_cnt=event_cnt)
     reply->status_data.status = "Z"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->event_qual,event_cnt)
 IF ((reply->status_data.status="Z"))
  SET reply->status_data.status = getresourcesecuritystatus(1)
  CALL populateressecstatusblock(security_failure_flag)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
