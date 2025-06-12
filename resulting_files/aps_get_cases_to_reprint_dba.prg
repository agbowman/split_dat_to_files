CREATE PROGRAM aps_get_cases_to_reprint:dba
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
 RECORD temp(
   1 qual[*]
     2 case_query_id = f8
     2 search_type_flag = i2
     2 started_prsnl_id = f8
     2 param_qual[*]
       3 param_name = c20
       3 criteria_type_flag = i2
       3 date_type_flag = i2
       3 beg_value_id = f8
       3 beg_value_disp = c40
       3 beg_value_dt_tm = dq8
       3 end_value_id = f8
       3 end_value_disp = c40
       3 end_value_dt_tm = dq8
       3 negation_ind = i2
       3 source_vocabulary_cd = f8
       3 freetext_query_flag = i2
       3 freetext_query = vc
       3 synoptic_query_flag = i2
       3 synoptic_ccl_query = vc
       3 synoptic_xml_query = vc
     2 accession_qual[*]
       3 accession_nbr = c20
     2 query_result_name = vc
 )
 RECORD reply(
   1 print_qual[*]
     2 print_dir_and_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET index1 = 0
 SET index2 = 0
 SET nbr_to_select = 0
 SET param_cnt = 0
 SET accession_cnt = 0
 SET failed_cnt = 0
 SET nbr_to_select = cnvtint(size(request->qual,5))
 SET stat = alterlist(reply->print_qual,nbr_to_select)
 CALL initresourcesecurity(1)
 SELECT INTO "nl:"
  acq.case_query_id, acqd.case_query_id
  FROM ap_case_query acq,
   ap_case_query_details acqd,
   (dummyt d1  WITH seq = value(nbr_to_select)),
   long_text lt,
   long_text lt2,
   long_text lt3
  PLAN (d1)
   JOIN (acq
   WHERE (request->qual[d1.seq].case_query_id=acq.case_query_id))
   JOIN (acqd
   WHERE acq.case_query_id=acqd.case_query_id)
   JOIN (lt
   WHERE acqd.freetext_long_text_id=lt.long_text_id)
   JOIN (lt2
   WHERE acqd.synoptic_ccl_long_text_id=lt2.long_text_id)
   JOIN (lt3
   WHERE acqd.synoptic_xml_long_text_id=lt3.long_text_id)
  ORDER BY acq.case_query_id
  HEAD REPORT
   cnt = 0
  HEAD acq.case_query_id
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(temp->qual,(cnt+ 9))
   ENDIF
   param_cnt = 0, temp->qual[cnt].case_query_id = acq.case_query_id, temp->qual[cnt].search_type_flag
    = acq.search_type_flag,
   temp->qual[cnt].started_prsnl_id = acq.started_prsnl_id, temp->qual[cnt].query_result_name = acq
   .result_name
  DETAIL
   param_cnt += 1
   IF (mod(param_cnt,10)=1)
    stat = alterlist(temp->qual[cnt].param_qual,(param_cnt+ 9))
   ENDIF
   temp->qual[cnt].param_qual[param_cnt].param_name = acqd.param_name, temp->qual[cnt].param_qual[
   param_cnt].criteria_type_flag = acqd.criteria_type_flag, temp->qual[cnt].param_qual[param_cnt].
   date_type_flag = acqd.date_type_flag,
   temp->qual[cnt].param_qual[param_cnt].beg_value_id = acqd.beg_value_id, temp->qual[cnt].
   param_qual[param_cnt].beg_value_disp = acqd.beg_value_disp, temp->qual[cnt].param_qual[param_cnt].
   beg_value_dt_tm = acqd.beg_value_dt_tm,
   temp->qual[cnt].param_qual[param_cnt].end_value_id = acqd.end_value_id, temp->qual[cnt].
   param_qual[param_cnt].end_value_disp = acqd.end_value_disp, temp->qual[cnt].param_qual[param_cnt].
   end_value_dt_tm = acqd.end_value_dt_tm,
   temp->qual[cnt].param_qual[param_cnt].negation_ind = acqd.negation_ind, temp->qual[cnt].
   param_qual[param_cnt].source_vocabulary_cd = acqd.source_vocabulary_cd, temp->qual[cnt].
   param_qual[param_cnt].freetext_query_flag = acqd.freetext_query_flag
   IF (acqd.freetext_long_text_id != 0.0)
    temp->qual[cnt].param_qual[param_cnt].freetext_query = lt.long_text
   ENDIF
   temp->qual[cnt].param_qual[param_cnt].synoptic_query_flag = acqd.synoptic_query_flag
   IF (acqd.synoptic_ccl_long_text_id != 0.0
    AND acqd.synoptic_xml_long_text_id != 0.0)
    temp->qual[cnt].param_qual[param_cnt].synoptic_ccl_query = lt2.long_text, temp->qual[cnt].
    param_qual[param_cnt].synoptic_xml_query = lt3.long_text
   ENDIF
  FOOT  acq.case_query_id
   stat = alterlist(temp->qual[cnt].param_qual,param_cnt)
  FOOT REPORT
   stat = alterlist(temp->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_CASE_QUERY"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  aqr.query_result_id
  FROM ap_query_result aqr,
   pathology_case pc,
   ap_prefix ap,
   (dummyt d  WITH seq = nbr_to_select)
  PLAN (d)
   JOIN (aqr
   WHERE (aqr.case_query_id=temp->qual[d.seq].case_query_id))
   JOIN (pc
   WHERE pc.accession_nbr=aqr.accession_nbr)
   JOIN (ap
   WHERE ap.prefix_id=pc.prefix_id)
  ORDER BY aqr.case_query_id
  HEAD aqr.case_query_id
   cnt = 0, service_resource_cd = 0.0
  DETAIL
   service_resource_cd = ap.service_resource_cd
   IF (isresourceviewable(service_resource_cd)=true)
    cnt += 1
    IF (mod(cnt,10)=1)
     stat = alterlist(temp->qual[d.seq].accession_qual,(cnt+ 9))
    ENDIF
    temp->qual[d.seq].accession_qual[cnt].accession_nbr = aqr.accession_nbr
   ENDIF
  FOOT  aqr.case_query_id
   stat = alterlist(temp->qual[d.seq].accession_qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_QUERY_RESULT"
  GO TO exit_script
 ELSEIF (getresourcesecuritystatus(1) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(1)
  CALL populateressecstatusblock(1)
  GO TO exit_script
 ENDIF
 FOR (index1 = 1 TO nbr_to_select)
   SET request->report_history_grping = request->report_history_grping
   SET request->report_type = request->report_type
   SET request->started_prsnl_id = temp->qual[index1].started_prsnl_id
   SET request->query_type = temp->qual[index1].search_type_flag
   SET request->illegal_operator_ind = 0
   SET request->query_result_name = temp->qual[index1].query_result_name
   SET param_cnt = cnvtint(size(temp->qual[index1].param_qual,5))
   SET stat = alterlist(request->param_qual,param_cnt)
   FOR (index2 = 1 TO param_cnt)
     SET request->param_qual[index2].param_name = temp->qual[index1].param_qual[index2].param_name
     SET request->param_qual[index2].criteria_type_flag = temp->qual[index1].param_qual[index2].
     criteria_type_flag
     SET request->param_qual[index2].date_type_flag = temp->qual[index1].param_qual[index2].
     date_type_flag
     SET request->param_qual[index2].beg_value_id = temp->qual[index1].param_qual[index2].
     beg_value_id
     SET request->param_qual[index2].beg_value_disp = temp->qual[index1].param_qual[index2].
     beg_value_disp
     SET request->param_qual[index2].beg_value_dt_tm = temp->qual[index1].param_qual[index2].
     beg_value_dt_tm
     SET request->param_qual[index2].end_value_id = temp->qual[index1].param_qual[index2].
     end_value_id
     SET request->param_qual[index2].end_value_disp = temp->qual[index1].param_qual[index2].
     end_value_disp
     SET request->param_qual[index2].end_value_dt_tm = temp->qual[index1].param_qual[index2].
     end_value_dt_tm
     SET request->param_qual[index2].negation_ind = temp->qual[index1].param_qual[index2].
     negation_ind
     SET request->param_qual[index2].source_vocabulary_cd = temp->qual[index1].param_qual[index2].
     source_vocabulary_cd
     SET request->param_qual[index2].freetext_query_flag = temp->qual[index1].param_qual[index2].
     freetext_query_flag
     SET request->param_qual[index2].freetext_query = temp->qual[index1].param_qual[index2].
     freetext_query
     SET request->param_qual[index2].synoptic_query_flag = temp->qual[index1].param_qual[index2].
     synoptic_query_flag
     SET request->param_qual[index2].synoptic_ccl_query = temp->qual[index1].param_qual[index2].
     synoptic_ccl_query
     SET request->param_qual[index2].synoptic_xml_query = temp->qual[index1].param_qual[index2].
     synoptic_xml_query
   ENDFOR
   SET accession_cnt = cnvtint(size(temp->qual[index1].accession_qual,5))
   SET stat = alterlist(request->accession_qual,accession_cnt)
   FOR (index2 = 1 TO accession_cnt)
     SET request->accession_qual[index2].accession_nbr = temp->qual[index1].accession_qual[index2].
     accession_nbr
   ENDFOR
   EXECUTE aps_prt_case_retrieval
   IF ((reply->status_data.status="F"))
    SET failed_cnt += 1
   ELSE
    SET reply->print_qual[(index1 - failed_cnt)].print_dir_and_filename = reply->print_status_data.
    print_dir_and_filename
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->print_qual,(nbr_to_select - failed_cnt))
 IF (failed_cnt=nbr_to_select)
  SET reply->status_data.status = "F"
 ELSEIF (failed_cnt > 0)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
