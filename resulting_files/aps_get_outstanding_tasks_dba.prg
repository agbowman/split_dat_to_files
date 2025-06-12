CREATE PROGRAM aps_get_outstanding_tasks:dba
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
   1 task_cnt = i4
   1 task_qual[*]
     2 task_id = f8
 )
 RECORD reply(
   1 ccnt = i4
   1 qual[*]
     2 case_id = f8
     2 patient_alias = c40
     2 person_name = vc
     2 person_id = f8
     2 encntr_id = f8
     2 accession_nbr = c21
     2 comments_long_text_id = f8
     2 comments = vc
     2 prefix_cd = f8
     2 tag_qual[2]
       3 tag_type_flag = i2
       3 tag_separator = c1
     2 spec_ctr = i4
     2 spec_qual[*]
       3 case_specimen_id = f8
       3 case_specimen_tag_cd = f8
       3 spec_descr = vc
       3 spec_tag = c7
       3 spec_seq = i4
       3 s_t_ctr = i4
       3 t_qual[*]
         4 t_task_assay_cd = f8
         4 t_task_assay_disp = vc
         4 t_task_assay_desc = vc
         4 t_comment = vc
         4 t_comments_long_text_id = f8
         4 t_priority_cd = f8
         4 t_priority_disp = c40
         4 t_request_dt_tm = dq8
         4 t_create_inv_flag = i2
         4 t_requestor_name = vc
         4 t_worklist_nbr = i4
         4 t_processing_task_id = f8
         4 t_service_resource_cd = f8
         4 t_service_resource_disp = c40
         4 t_service_resource_desc = vc
         4 t_updt_cnt = i4
         4 t_order_id = f8
         4 t_catalog_cd = f8
         4 t_catalog_disp = vc
         4 t_catalog_desc = vc
       3 s_slide_ctr = i4
       3 slide_qual[*]
         4 sl_origin_modifier = c7
         4 sl_slide_id = f8
         4 sl_tag_cd = f8
         4 sl_tag = c7
         4 sl_seq = i4
         4 s_s_t_ctr = i4
         4 t_qual[*]
           5 t_task_assay_cd = f8
           5 t_task_assay_disp = vc
           5 t_task_assay_desc = vc
           5 t_comment = vc
           5 t_comments_long_text_id = f8
           5 t_priority_cd = f8
           5 t_priority_disp = c40
           5 t_request_dt_tm = dq8
           5 t_create_inv_flag = i2
           5 t_requestor_name = vc
           5 t_worklist_nbr = i4
           5 t_processing_task_id = f8
           5 t_service_resource_cd = f8
           5 t_service_resource_disp = c40
           5 t_service_resource_desc = vc
           5 t_updt_cnt = i4
           5 t_order_id = f8
           5 t_catalog_cd = f8
           5 t_catalog_disp = vc
           5 t_catalog_desc = vc
       3 s_c_ctr = i4
       3 cass_qual[*]
         4 cass_origin_modifier = c7
         4 cass_id = f8
         4 cass_tag = c7
         4 cass_tag_cd = f8
         4 cass_seq = i4
         4 s_c_t_ctr = i4
         4 t_qual[*]
           5 t_task_assay_cd = f8
           5 t_task_assay_disp = vc
           5 t_task_assay_desc = vc
           5 t_comment = vc
           5 t_comments_long_text_id = f8
           5 t_priority_cd = f8
           5 t_priority_disp = c40
           5 t_request_dt_tm = dq8
           5 t_create_inv_flag = i2
           5 t_requestor_name = vc
           5 t_worklist_nbr = i4
           5 t_processing_task_id = f8
           5 t_service_resource_cd = f8
           5 t_service_resource_disp = c40
           5 t_service_resource_desc = vc
           5 t_updt_cnt = i4
           5 t_order_id = f8
           5 t_catalog_cd = f8
           5 t_catalog_disp = vc
           5 t_catalog_desc = vc
         4 s_c_slide_ctr = i4
         4 slide_qual[*]
           5 s_origin_modifier = c7
           5 s_slide_id = f8
           5 s_tag_cd = f8
           5 s_tag = c7
           5 s_seq = i4
           5 s_c_s_t_ctr = i4
           5 t_qual[*]
             6 t_task_assay_cd = f8
             6 t_task_assay_disp = vc
             6 t_task_assay_desc = vc
             6 t_comment = vc
             6 t_comments_long_text_id = f8
             6 t_priority_cd = f8
             6 t_priority_disp = c40
             6 t_request_dt_tm = dq8
             6 t_create_inv_flag = i2
             6 t_requestor_name = vc
             6 t_worklist_nbr = i4
             6 t_processing_task_id = f8
             6 t_service_resource_cd = f8
             6 t_service_resource_disp = c40
             6 t_service_resource_desc = vc
             6 t_updt_cnt = i4
             6 t_order_id = f8
             6 t_catalog_cd = f8
             6 t_catalog_disp = vc
             6 t_catalog_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET current_time = curtime3
 SET error_cnt = 0
 SET spec_ctr = 0
 SET s_slide_ctr = 0
 SET s_c_ctr = 0
 SET s_c_slide_ctr = 0
 SET ccnt = 0
 SET s_t_ctr = 0
 SET s_s_t_ctr = 0
 SET s_c_t_ctr = 0
 SET s_c_s_t_ctr = 0
 SET max_spec_ctr = 0
 SET max_s_slide_ctr = 0
 SET max_s_c_ctr = 0
 SET max_s_c_slide_ctr = 0
 SET max_s_t_ctr = 0
 SET max_s_s_t_ctr = 0
 SET max_s_c_t_ctr = 0
 SET max_s_c_s_t_ctr = 0
 SET task_where = fillstring(500," ")
 DECLARE mrn_alias_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE billing_task_cd = f8 WITH protect, noconstant(0.0)
 DECLARE processing_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ordered_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ap_tag_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE idx3 = i4 WITH protect, noconstant(0)
 DECLARE prefix_where = vc WITH protect, noconstant("")
 DECLARE scontenttablename = vc WITH protect, noconstant("")
 IF ((request->batch_nbr > 0))
  SET task_where = "(pt.status_cd+0 in (ordered_cd, processing_cd))"
 ELSE
  SET task_where = "(pt.status_cd in (ordered_cd, processing_cd))"
 ENDIF
 CALL initresourcesecurity(1)
 SET stat = uar_get_meaning_by_codeset(5801,"APBILLING",1,billing_task_cd)
 IF (billing_task_cd=0)
  CALL handle_errors("SELECT","F","TABLE","CODE_VALUE - APBILLING")
  GO TO exit_script
 ENDIF
 IF ((request->service_resource_cd > 0))
  SET cntr = 0
  SELECT INTO "nl:"
   rg.child_service_resource_cd
   FROM resource_group rg
   WHERE (request->service_resource_cd=rg.parent_service_resource_cd)
    AND rg.active_ind=1
    AND rg.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND rg.end_effective_dt_tm > cnvtdatetime(sysdate)
   HEAD REPORT
    task_where = build(trim(task_where)," and (pt.service_resource_cd in (",request->
     service_resource_cd)
   DETAIL
    cntr += 1, task_where = build(trim(task_where),",",rg.child_service_resource_cd)
   FOOT REPORT
    task_where = build(trim(task_where),"))")
   WITH nocounter
  ;end select
  IF (cntr=0)
   SET task_where = build(trim(task_where),
    " and (request->service_resource_cd = pt.service_resource_cd)")
  ENDIF
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"ORDERED",1,ordered_cd)
 SET stat = uar_get_meaning_by_codeset(1305,"PROCESSING",1,processing_cd)
 IF (ordered_cd=0)
  CALL handle_errors("SELECT","F","TABLE","CODE_VALUE - ORDERED")
  GO TO exit_script
 ENDIF
 IF (processing_cd=0)
  CALL handle_errors("SELECT","F","TABLE","CODE_VALUE - PROCESSING")
  GO TO exit_script
 ENDIF
 IF ((request->task_assay_cd > 0))
  SET task_where = build(trim(task_where)," and (request->task_assay_cd = pt.task_assay_cd)")
 ENDIF
 IF ((request->batch_nbr > 0))
  SET task_where = build(trim(task_where)," and (request->batch_nbr = pt.worklist_nbr)")
 ENDIF
 IF ((request->coded_id_value > 0))
  IF ((request->coded_id_mean="STORAGECOMP"))
   SELECT INTO "nl:"
    si.storage_item_cd
    FROM storage_item si,
     storage_item_description sid
    PLAN (si
     WHERE (si.storage_item_cd=request->coded_id_value))
     JOIN (sid
     WHERE sid.storage_item_description_cd=si.storage_item_description_cd)
    DETAIL
     scontenttablename = cnvtupper(uar_get_code_meaning(sid.content_type_cd))
     IF (scontenttablename="CASESPECIMEN")
      scontenttablename = "CASE_SPECIMEN"
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    CALL handle_errors("SELECT","F","storage_item","Invalid storage item code.")
    GO TO exit_program
   ELSEIF ( NOT (scontenttablename IN ("SLIDE", "CASSETTE", "CASE_SPECIMEN")))
    SET reply->status_data.status = "F"
    CALL handle_errors("SELECT","F","content_type_cd","Invalid compartment content type")
    GO TO exit_program
   ELSEIF (scontenttablename="SLIDE")
    SET task_where = build(trim(task_where)," and (pt.slide_id = sc.content_table_id)")
   ELSEIF (scontenttablename="CASSETTE")
    SET task_where = build(trim(task_where)," and (pt.cassette_id = sc.content_table_id)")
   ELSE
    SET task_where = build(trim(task_where)," and (pt.case_specimen_id = sc.content_table_id)")
   ENDIF
  ELSE
   SET reply->status_data.status = "F"
   CALL handle_errors("INPUT","F","coded_id_mean","Invalid identifier meaning")
   GO TO exit_program
  ENDIF
 ENDIF
 SET m_lresseccheckedcnt = 0
 SET m_lressecfailedcnt = 0
 SELECT INTO "nl:"
  ap.prefix_id
  FROM ap_prefix ap
  WHERE ap.prefix_id > 0.0
   AND ap.active_ind=1
  HEAD REPORT
   first_to_qualify = 1
   IF (size(trim(request->accession_nbr)) > 0)
    prefix_where = "(pc.accession_nbr = request->accession_nbr)"
   ELSE
    prefix_where = "(pt.case_id = pc.case_id)"
   ENDIF
  DETAIL
   IF (isresourceviewable(ap.service_resource_cd)=true)
    IF (first_to_qualify=1)
     prefix_where = build(trim(prefix_where)," and (pc.prefix_id in(",ap.prefix_id), first_to_qualify
      = 0
    ELSE
     prefix_where = build(trim(prefix_where),",",ap.prefix_id)
    ENDIF
   ENDIF
  FOOT REPORT
   prefix_where = build(trim(prefix_where),"))")
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","AP_PREFIX")
  SET reply->status_data.status = "F"
  GO TO exit_program
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(1)
  GO TO exit_program
 ELSEIF (getresourcesecuritystatus(1)="S")
  IF (size(trim(request->accession_nbr)) > 0)
   SET prefix_where = "(pc.accession_nbr = request->accession_nbr)"
  ELSE
   SET prefix_where = "(pt.case_id = pc.case_id)"
  ENDIF
 ENDIF
 SET m_lresseccheckedcnt = 0
 SET m_lressecfailedcnt = 0
 IF ( NOT (validate(temp_ap_tag,0)))
  RECORD temp_ap_tag(
    1 qual[*]
      2 tag_group_id = f8
      2 tag_id = f8
      2 tag_sequence = i4
      2 tag_disp = c7
  )
 ENDIF
 DECLARE aps_get_tags(none) = i4
 SUBROUTINE aps_get_tags(none)
   DECLARE tag_cnt = i4 WITH protect, noconstant(0)
   DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
   DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
   SELECT INTO "nl:"
    ap.tag_id
    FROM ap_tag ap
    WHERE ap.active_ind=1
    ORDER BY ap.tag_group_id, ap.tag_sequence
    HEAD REPORT
     tag_cnt = 0
    DETAIL
     tag_cnt += 1
     IF (tag_cnt > size(temp_ap_tag->qual,5))
      stat = alterlist(temp_ap_tag->qual,(tag_cnt+ 9))
     ENDIF
     temp_ap_tag->qual[tag_cnt].tag_group_id = ap.tag_group_id, temp_ap_tag->qual[tag_cnt].tag_id =
     ap.tag_id, temp_ap_tag->qual[tag_cnt].tag_sequence = ap.tag_sequence,
     temp_ap_tag->qual[tag_cnt].tag_disp = ap.tag_disp
    FOOT REPORT
     stat = alterlist(temp_ap_tag->qual,tag_cnt)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (((error_check != 0) OR (tag_cnt=0)) )
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG"
    SET reply->status_data.status = "Z"
    RETURN(0)
   ENDIF
   RETURN(tag_cnt)
 END ;Subroutine
 SET ap_tag_cnt = aps_get_tags(0)
 IF (ap_tag_cnt=0)
  GO TO exit_program
 ENDIF
 SELECT
  IF ((request->coded_id_value > 0)
   AND (request->coded_id_mean="STORAGECOMP"))
   FROM storage_content sc,
    processing_task pt,
    prsnl p,
    order_catalog oc,
    profile_task_r ptr,
    pathology_case pc
   PLAN (sc
    WHERE (sc.storage_item_cd=request->coded_id_value)
     AND sc.content_table_id > 0
     AND sc.content_table_name=scontenttablename)
    JOIN (pt
    WHERE parser(trim(task_where)))
    JOIN (ptr
    WHERE ptr.task_assay_cd=pt.task_assay_cd
     AND ptr.active_ind=1
     AND ptr.item_type_flag=0
     AND ptr.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND ptr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (oc
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND oc.active_ind=1
     AND oc.activity_subtype_cd != billing_task_cd)
    JOIN (p
    WHERE pt.request_prsnl_id=p.person_id)
    JOIN (pc
    WHERE parser(trim(prefix_where)))
  ELSEIF (size(trim(request->accession_nbr)) > 0)
   FROM processing_task pt,
    prsnl p,
    order_catalog oc,
    profile_task_r ptr,
    pathology_case pc
   PLAN (pc
    WHERE parser(trim(prefix_where)))
    JOIN (pt
    WHERE parser(trim(task_where))
     AND pt.case_id=pc.case_id)
    JOIN (ptr
    WHERE ptr.task_assay_cd=pt.task_assay_cd
     AND ptr.active_ind=1
     AND ptr.item_type_flag=0
     AND ptr.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND ptr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (oc
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND oc.active_ind=1
     AND oc.activity_subtype_cd != billing_task_cd)
    JOIN (p
    WHERE pt.request_prsnl_id=p.person_id)
  ELSE
   FROM processing_task pt,
    prsnl p,
    order_catalog oc,
    profile_task_r ptr,
    pathology_case pc
   PLAN (pt
    WHERE parser(trim(task_where)))
    JOIN (ptr
    WHERE ptr.task_assay_cd=pt.task_assay_cd
     AND ptr.active_ind=1
     AND ptr.item_type_flag=0
     AND ptr.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND ptr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (oc
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND oc.active_ind=1
     AND oc.activity_subtype_cd != billing_task_cd)
    JOIN (p
    WHERE pt.request_prsnl_id=p.person_id)
    JOIN (pc
    WHERE parser(trim(prefix_where)))
  ENDIF
  INTO "nl:"
  pt.case_id, p.name_full_formatted, pt.case_specimen_id,
  pt.case_specimen_tag_id, pt.cassette_id, pt.cassette_tag_id,
  pt.slide_id, pt.slide_tag_id, pt.status_cd,
  pt.request_prsnl_id, pt.task_assay_cd, ncreatespecimen = evaluate(pt.create_inventory_flag,4,1,0),
  ncreateblock = evaluate(pt.create_inventory_flag,1,1,2,0,
   3,1,4,0,0,
   0), ncreateslide = evaluate(pt.create_inventory_flag,1,0,2,1,
   3,1,4,0,0,
   0), ap_tag_spec_idx = locateval(idx1,1,ap_tag_cnt,pt.case_specimen_tag_id,temp_ap_tag->qual[idx1].
   tag_id),
  ap_tag_cass_idx = locateval(idx2,1,ap_tag_cnt,pt.cassette_tag_id,temp_ap_tag->qual[idx2].tag_id),
  ap_tag_slide_idx = locateval(idx3,1,ap_tag_cnt,pt.slide_tag_id,temp_ap_tag->qual[idx3].tag_id)
  ORDER BY pc.accession_nbr, ap_tag_spec_idx, ncreatespecimen DESC,
   ap_tag_cass_idx, pt.cassette_id, ncreateblock DESC,
   ap_tag_slide_idx, pt.slide_id, ncreateslide DESC,
   pt.request_dt_tm
  HEAD REPORT
   spec_ctr = 0, s_slide_ctr = 0, s_c_ctr = 0,
   s_c_slide_ctr = 0, ccnt = 0, s_t_ctr = 0,
   s_s_t_ctr = 0, s_c_t_ctr = 0, s_c_s_t_ctr = 0,
   max_spec_ctr = 0, max_s_slide_ctr = 0, max_s_c_ctr = 0,
   max_s_c_slide_ctr = 0, max_s_t_ctr = 0, max_s_s_t_ctr = 0,
   max_s_c_t_ctr = 0, max_s_c_s_t_ctr = 0, service_resource_cd = 0.0,
   last_case_specimen_id = - (1.0), last_cassette_id = - (1.0), last_slide_id = - (1.0)
  HEAD pc.accession_nbr
   spec_ctr = 0, last_case_specimen_id = - (1.0), last_cassette_id = - (1.0),
   last_slide_id = - (1.0)
  DETAIL
   service_resource_cd = pt.service_resource_cd
   IF (isresourceviewable(service_resource_cd))
    IF (last_case_specimen_id != pt.case_specimen_id)
     last_case_specimen_id = pt.case_specimen_id, last_cassette_id = - (1.0), last_slide_id = - (1.0)
     IF (spec_ctr=0)
      ccnt += 1, stat = alterlist(reply->qual,ccnt), reply->qual[ccnt].case_id = pt.case_id,
      reply->ccnt = ccnt
     ENDIF
     spec_ctr += 1
     IF (spec_ctr > max_spec_ctr)
      max_spec_ctr = spec_ctr
     ENDIF
     stat = alterlist(reply->qual[ccnt].spec_qual,spec_ctr), reply->qual[ccnt].spec_ctr = spec_ctr,
     reply->qual[ccnt].spec_qual[spec_ctr].case_specimen_id = pt.case_specimen_id,
     reply->qual[ccnt].spec_qual[spec_ctr].case_specimen_tag_cd = pt.case_specimen_tag_id, s_c_ctr =
     0
    ENDIF
    IF (last_cassette_id != pt.cassette_id)
     last_cassette_id = pt.cassette_id, last_slide_id = - (1.0)
     IF (pt.cassette_id != 0.0)
      s_c_ctr += 1
      IF (s_c_ctr > max_s_c_ctr)
       max_s_c_ctr = s_c_ctr
      ENDIF
      stat = alterlist(reply->qual[ccnt].spec_qual[spec_ctr].cass_qual,s_c_ctr), reply->qual[ccnt].
      spec_qual[spec_ctr].s_c_ctr = s_c_ctr
     ENDIF
     s_c_slide_ctr = 0, s_slide_ctr = 0
    ENDIF
    IF (last_slide_id != pt.slide_id)
     last_slide_id = pt.slide_id
     IF (pt.cassette_id != 0.00)
      IF (pt.slide_id != 0.00)
       s_c_slide_ctr += 1
       IF (s_c_slide_ctr > max_s_c_slide_ctr)
        max_s_c_slide_ctr = s_c_slide_ctr
       ENDIF
       reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].s_c_slide_ctr = s_c_slide_ctr, stat
        = alterlist(reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual,s_c_slide_ctr
        ), reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].cass_id = pt.cassette_id,
       reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].cass_tag_cd = pt.cassette_tag_id,
       reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].s_slide_id
        = pt.slide_id, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
       s_c_slide_ctr].s_tag_cd = pt.slide_tag_id
      ELSE
       reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].cass_id = pt.cassette_id, reply->
       qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].cass_tag_cd = pt.cassette_tag_id
      ENDIF
     ELSE
      IF (pt.slide_id != 0.00)
       s_slide_ctr += 1
       IF (s_slide_ctr > max_s_slide_ctr)
        max_s_slide_ctr = s_slide_ctr
       ENDIF
       reply->qual[ccnt].spec_qual[spec_ctr].s_slide_ctr = s_slide_ctr, stat = alterlist(reply->qual[
        ccnt].spec_qual[spec_ctr].slide_qual,s_slide_ctr), reply->qual[ccnt].spec_qual[spec_ctr].
       slide_qual[s_slide_ctr].sl_slide_id = pt.slide_id,
       reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].sl_tag_cd = pt.slide_tag_id
      ENDIF
     ENDIF
     s_c_s_t_ctr = 0, s_c_t_ctr = 0, s_s_t_ctr = 0,
     s_t_ctr = 0
    ENDIF
    IF (pt.cassette_id > 0)
     IF (pt.slide_id > 0)
      s_c_s_t_ctr += 1
      IF (s_c_s_t_ctr > max_s_c_s_t_ctr)
       max_s_c_s_t_ctr = s_c_s_t_ctr
      ENDIF
      stat = alterlist(reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
       s_c_slide_ctr].t_qual,s_c_s_t_ctr), reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].
      slide_qual[s_c_slide_ctr].s_c_s_t_ctr = s_c_s_t_ctr, reply->qual[ccnt].spec_qual[spec_ctr].
      cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_task_assay_cd = pt
      .task_assay_cd,
      reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
      s_c_s_t_ctr].t_create_inv_flag = pt.create_inventory_flag, reply->qual[ccnt].spec_qual[spec_ctr
      ].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_comments_long_text_id = pt
      .comments_long_text_id, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
      s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_priority_cd = pt.priority_cd,
      reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
      s_c_s_t_ctr].t_request_dt_tm = pt.request_dt_tm, reply->qual[ccnt].spec_qual[spec_ctr].
      cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_requestor_name = p
      .name_full_formatted, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
      s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_worklist_nbr = pt.worklist_nbr,
      reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
      s_c_s_t_ctr].t_processing_task_id = pt.processing_task_id, reply->qual[ccnt].spec_qual[spec_ctr
      ].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_updt_cnt = pt.updt_cnt,
      reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
      s_c_s_t_ctr].t_order_id = pt.order_id,
      reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
      s_c_s_t_ctr].t_catalog_cd = oc.catalog_cd, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[
      s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_service_resource_cd = pt
      .service_resource_cd
     ELSE
      s_c_t_ctr += 1
      IF (s_c_t_ctr > max_s_c_t_ctr)
       max_s_c_t_ctr = s_c_t_ctr
      ENDIF
      stat = alterlist(reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual,s_c_t_ctr),
      reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].s_c_t_ctr = s_c_t_ctr, reply->qual[
      ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_task_assay_cd = pt
      .task_assay_cd,
      reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_create_inv_flag =
      pt.create_inventory_flag, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[
      s_c_t_ctr].t_comments_long_text_id = pt.comments_long_text_id, reply->qual[ccnt].spec_qual[
      spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_priority_cd = pt.priority_cd,
      reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_requestor_name = p
      .name_full_formatted, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr
      ].t_request_dt_tm = pt.request_dt_tm, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].
      t_qual[s_c_t_ctr].t_worklist_nbr = pt.worklist_nbr,
      reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_updt_cnt = pt
      .updt_cnt, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].
      t_order_id = pt.order_id, reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[
      s_c_t_ctr].t_catalog_cd = oc.catalog_cd,
      reply->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].
      t_service_resource_cd = pt.service_resource_cd, reply->qual[ccnt].spec_qual[spec_ctr].
      cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_processing_task_id = pt.processing_task_id
     ENDIF
    ELSE
     IF (pt.slide_id > 0)
      s_s_t_ctr += 1
      IF (s_s_t_ctr > max_s_s_t_ctr)
       max_s_s_t_ctr = s_s_t_ctr
      ENDIF
      stat = alterlist(reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual,s_s_t_ctr
       ), reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].s_s_t_ctr = s_s_t_ctr, reply
      ->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_task_assay_cd = pt
      .task_assay_cd,
      reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
      t_create_inv_flag = pt.create_inventory_flag, reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[
      s_slide_ctr].t_qual[s_s_t_ctr].t_comments_long_text_id = pt.comments_long_text_id, reply->qual[
      ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_priority_cd = pt
      .priority_cd,
      reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
      t_requestor_name = p.name_full_formatted, reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[
      s_slide_ctr].t_qual[s_s_t_ctr].t_request_dt_tm = pt.request_dt_tm, reply->qual[ccnt].spec_qual[
      spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_worklist_nbr = pt.worklist_nbr,
      reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_updt_cnt = pt
      .updt_cnt, reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
      t_order_id = pt.order_id, reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[
      s_s_t_ctr].t_catalog_cd = oc.catalog_cd,
      reply->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
      t_service_resource_cd = pt.service_resource_cd, reply->qual[ccnt].spec_qual[spec_ctr].
      slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_processing_task_id = pt.processing_task_id
     ELSE
      s_t_ctr += 1
      IF (s_t_ctr > max_s_t_ctr)
       max_s_t_ctr = s_t_ctr
      ENDIF
      stat = alterlist(reply->qual[ccnt].spec_qual[spec_ctr].t_qual,s_t_ctr), reply->qual[ccnt].
      spec_qual[spec_ctr].s_t_ctr = s_t_ctr, reply->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].
      t_task_assay_cd = pt.task_assay_cd,
      reply->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_create_inv_flag = pt
      .create_inventory_flag, reply->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].
      t_comments_long_text_id = pt.comments_long_text_id, reply->qual[ccnt].spec_qual[spec_ctr].
      t_qual[s_t_ctr].t_priority_cd = pt.priority_cd,
      reply->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_requestor_name = p.name_full_formatted,
      reply->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_request_dt_tm = pt.request_dt_tm, reply
      ->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_worklist_nbr = pt.worklist_nbr,
      reply->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_updt_cnt = pt.updt_cnt, reply->qual[
      ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_order_id = pt.order_id, reply->qual[ccnt].
      spec_qual[spec_ctr].t_qual[s_t_ctr].t_catalog_cd = oc.catalog_cd,
      reply->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_service_resource_cd = pt
      .service_resource_cd, reply->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].
      t_processing_task_id = pt.processing_task_id
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
  SET reply->status_data.status = "Z"
  GO TO exit_program
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(0)
  GO TO exit_program
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (max_s_t_ctr > 0)
  SELECT INTO "nl:"
   lt.long_text_id
   FROM (dummyt d  WITH seq = value(reply->ccnt)),
    (dummyt d1  WITH seq = value(max_spec_ctr)),
    (dummyt d2  WITH seq = value(max_s_t_ctr)),
    long_text lt
   PLAN (d)
    JOIN (d1
    WHERE (d1.seq <= reply->qual[d.seq].spec_ctr))
    JOIN (d2
    WHERE (d2.seq <= reply->qual[d.seq].spec_qual[d1.seq].s_t_ctr)
     AND (reply->qual[d.seq].spec_qual[d1.seq].t_qual[d2.seq].t_comments_long_text_id > 0))
    JOIN (lt
    WHERE (reply->qual[d.seq].spec_qual[d1.seq].t_qual[d2.seq].t_comments_long_text_id=lt
    .long_text_id))
   DETAIL
    reply->qual[d.seq].spec_qual[d1.seq].t_qual[d2.seq].t_comment = trim(lt.long_text)
   WITH nocounter
  ;end select
 ENDIF
 IF (max_s_s_t_ctr > 0)
  SELECT INTO "nl:"
   lt.long_text_id
   FROM (dummyt d  WITH seq = value(reply->ccnt)),
    (dummyt d1  WITH seq = value(max_spec_ctr)),
    (dummyt d2  WITH seq = value(max_s_slide_ctr)),
    (dummyt d3  WITH seq = value(max_s_s_t_ctr)),
    long_text lt
   PLAN (d)
    JOIN (d1
    WHERE (d1.seq <= reply->qual[d.seq].spec_ctr))
    JOIN (d2
    WHERE (d2.seq <= reply->qual[d.seq].spec_qual[d1.seq].s_slide_ctr))
    JOIN (d3
    WHERE (d3.seq <= reply->qual[d.seq].spec_qual[d1.seq].slide_qual[d2.seq].s_s_t_ctr)
     AND (reply->qual[d.seq].spec_qual[d1.seq].slide_qual[d2.seq].t_qual[d3.seq].
    t_comments_long_text_id > 0))
    JOIN (lt
    WHERE (reply->qual[d.seq].spec_qual[d1.seq].slide_qual[d2.seq].t_qual[d3.seq].
    t_comments_long_text_id=lt.long_text_id))
   DETAIL
    reply->qual[d.seq].spec_qual[d1.seq].slide_qual[d2.seq].t_qual[d3.seq].t_comment = trim(lt
     .long_text)
   WITH nocounter
  ;end select
 ENDIF
 IF (max_s_c_t_ctr > 0)
  SELECT INTO "nl:"
   lt.long_text_id
   FROM (dummyt d  WITH seq = value(reply->ccnt)),
    (dummyt d1  WITH seq = value(max_spec_ctr)),
    (dummyt d2  WITH seq = value(max_s_c_ctr)),
    (dummyt d3  WITH seq = value(max_s_c_t_ctr)),
    long_text lt
   PLAN (d)
    JOIN (d1
    WHERE (d1.seq <= reply->qual[d.seq].spec_ctr))
    JOIN (d2
    WHERE (d2.seq <= reply->qual[d.seq].spec_qual[d1.seq].s_c_ctr))
    JOIN (d3
    WHERE (d3.seq <= reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].s_c_t_ctr)
     AND (reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].t_qual[d3.seq].
    t_comments_long_text_id > 0))
    JOIN (lt
    WHERE (reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].t_qual[d3.seq].
    t_comments_long_text_id=lt.long_text_id))
   DETAIL
    reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].t_qual[d3.seq].t_comment = trim(lt
     .long_text)
   WITH nocounter
  ;end select
 ENDIF
 IF (max_s_c_s_t_ctr > 0)
  SELECT INTO "nl:"
   lt.long_text_id
   FROM (dummyt d  WITH seq = value(reply->ccnt)),
    (dummyt d1  WITH seq = value(max_spec_ctr)),
    (dummyt d2  WITH seq = value(max_s_c_ctr)),
    (dummyt d3  WITH seq = value(max_s_c_slide_ctr)),
    (dummyt d4  WITH seq = value(max_s_c_s_t_ctr)),
    long_text lt
   PLAN (d)
    JOIN (d1
    WHERE (d1.seq <= reply->qual[d.seq].spec_ctr))
    JOIN (d2
    WHERE (d2.seq <= reply->qual[d.seq].spec_qual[d1.seq].s_c_ctr))
    JOIN (d3
    WHERE (d3.seq <= reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].s_c_slide_ctr))
    JOIN (d4
    WHERE (d4.seq <= reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].slide_qual[d3.seq].
    s_c_s_t_ctr)
     AND (reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].slide_qual[d3.seq].t_qual[d4.seq].
    t_comments_long_text_id > 0))
    JOIN (lt
    WHERE (reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].slide_qual[d3.seq].t_qual[d4.seq].
    t_comments_long_text_id=lt.long_text_id))
   DETAIL
    reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].slide_qual[d3.seq].t_qual[d4.seq].
    t_comment = trim(lt.long_text)
   WITH nocounter
  ;end select
 ENDIF
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_alias_type_cd)
 IF (mrn_alias_type_cd=0)
  CALL handle_errors("SELECT","F","TABLE","CODE_VALUE - MRN")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pc.prefix_id, pr.name_full_formatted
  FROM pathology_case pc,
   (dummyt d  WITH seq = value(reply->ccnt)),
   ap_prefix_tag_group_r aptg_r,
   person pr
  PLAN (d)
   JOIN (pc
   WHERE (reply->qual[d.seq].case_id=pc.case_id))
   JOIN (pr
   WHERE pc.person_id=pr.person_id)
   JOIN (aptg_r
   WHERE pc.prefix_id=aptg_r.prefix_id
    AND aptg_r.tag_type_flag > 1)
  ORDER BY pc.prefix_id, pc.accession_nbr, aptg_r.tag_type_flag
  HEAD REPORT
   tag_ctr = 0
  HEAD pc.prefix_id
   tag_ctr = 0
  DETAIL
   reply->qual[d.seq].accession_nbr = pc.accession_nbr, reply->qual[d.seq].prefix_cd = pc.prefix_id,
   reply->qual[d.seq].person_name = pr.name_full_formatted,
   reply->qual[d.seq].person_id = pc.person_id, reply->qual[d.seq].encntr_id = pc.encntr_id, reply->
   qual[d.seq].comments_long_text_id = pc.comments_long_text_id
   IF (tag_ctr < 2)
    tag_ctr += 1, reply->qual[d.seq].tag_qual[tag_ctr].tag_type_flag = aptg_r.tag_type_flag, reply->
    qual[d.seq].tag_qual[tag_ctr].tag_separator = aptg_r.tag_separator
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","prefix_tag_group_r")
  SET reply->status_data.status = "F"
 ENDIF
 SELECT INTO "nl:"
  lt.long_text_id
  FROM (dummyt d  WITH seq = value(reply->ccnt)),
   long_text lt
  PLAN (d
   WHERE (reply->qual[d.seq].comments_long_text_id > 0))
   JOIN (lt
   WHERE (reply->qual[d.seq].comments_long_text_id=lt.long_text_id))
  DETAIL
   reply->qual[d.seq].comments = trim(lt.long_text)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
  FROM (dummyt d  WITH seq = value(reply->ccnt)),
   encntr_alias ea,
   (dummyt d2  WITH seq = 1)
  PLAN (d
   WHERE (reply->qual[d.seq].encntr_id > 0))
   JOIN (d2)
   JOIN (ea
   WHERE (ea.encntr_id=reply->qual[d.seq].encntr_id)
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   IF ((reply->qual[d.seq].encntr_id=ea.encntr_id))
    reply->qual[d.seq].patient_alias = frmt_mrn
   ELSE
    reply->qual[d.seq].patient_alias = "Unknown"
   ENDIF
  WITH nocounter, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  cs.specimen_description
  FROM case_specimen cs,
   (dummyt d  WITH seq = value(reply->ccnt)),
   (dummyt d1  WITH seq = value(max_spec_ctr))
  PLAN (d)
   JOIN (d1
   WHERE (d1.seq <= reply->qual[d.seq].spec_ctr))
   JOIN (cs
   WHERE (reply->qual[d.seq].spec_qual[d1.seq].case_specimen_id=cs.case_specimen_id))
  DETAIL
   reply->qual[d.seq].spec_qual[d1.seq].spec_descr = cs.specimen_description, ap_tag_spec_idx =
   locateval(idx1,1,ap_tag_cnt,cs.specimen_tag_id,temp_ap_tag->qual[idx1].tag_id)
   IF (ap_tag_spec_idx > 0)
    reply->qual[d.seq].spec_qual[d1.seq].spec_tag = temp_ap_tag->qual[ap_tag_spec_idx].tag_disp,
    reply->qual[d.seq].spec_qual[d1.seq].spec_seq = temp_ap_tag->qual[ap_tag_spec_idx].tag_sequence
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","CASE_SPECIMEN")
  SET reply->status_data.status = "F"
 ENDIF
 IF (max_s_c_ctr > 0)
  SELECT INTO "nl:"
   c.pieces
   FROM cassette c,
    (dummyt d  WITH seq = value(reply->ccnt)),
    (dummyt d1  WITH seq = value(max_spec_ctr)),
    (dummyt d2  WITH seq = value(max_s_c_ctr))
   PLAN (d)
    JOIN (d1
    WHERE (d1.seq <= reply->qual[d.seq].spec_ctr))
    JOIN (d2
    WHERE (d2.seq <= reply->qual[d.seq].spec_qual[d1.seq].s_c_ctr))
    JOIN (c
    WHERE (reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_id=c.cassette_id))
   DETAIL
    ap_tag_cass_idx = locateval(idx2,1,ap_tag_cnt,c.cassette_tag_id,temp_ap_tag->qual[idx2].tag_id)
    IF (ap_tag_cass_idx > 0)
     reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_tag = temp_ap_tag->qual[
     ap_tag_cass_idx].tag_disp, reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_seq =
     temp_ap_tag->qual[ap_tag_cass_idx].tag_sequence
    ENDIF
    reply->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_origin_modifier = c.origin_modifier
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","CASSETTE TAGS, AP_TAG")
   SET reply->status_data.status = "F"
  ENDIF
 ENDIF
 IF (((max_s_slide_ctr > 0) OR (max_s_c_slide_ctr > 0)) )
  SELECT INTO "nl:"
   join_path = decode(s.seq,"S",s1.seq,"S1"," ")
   FROM slide s,
    slide s1,
    (dummyt d1  WITH seq = value(reply->ccnt)),
    (dummyt d2  WITH seq = value(max_spec_ctr)),
    (dummyt d3  WITH seq = value(max_s_slide_ctr)),
    (dummyt d4  WITH seq = value(max_s_c_ctr)),
    (dummyt d5  WITH seq = value(max_s_c_slide_ctr)),
    (dummyt d6  WITH seq = 1),
    (dummyt d7  WITH seq = 1)
   PLAN (d1)
    JOIN (d2
    WHERE (d2.seq <= reply->qual[d1.seq].spec_ctr))
    JOIN (((d3
    WHERE (d3.seq <= reply->qual[d1.seq].spec_qual[d2.seq].s_slide_ctr))
    JOIN (d6)
    JOIN (s
    WHERE (reply->qual[d1.seq].spec_qual[d2.seq].slide_qual[d3.seq].sl_slide_id=s.slide_id))
    ) ORJOIN ((d4
    WHERE (d4.seq <= reply->qual[d1.seq].spec_qual[d2.seq].s_c_ctr))
    JOIN (d5
    WHERE (d5.seq <= reply->qual[d1.seq].spec_qual[d2.seq].cass_qual[d4.seq].s_c_slide_ctr))
    JOIN (d7)
    JOIN (s1
    WHERE (reply->qual[d1.seq].spec_qual[d2.seq].cass_qual[d4.seq].slide_qual[d5.seq].s_slide_id=s1
    .slide_id))
    ))
   DETAIL
    CASE (join_path)
     OF "S":
      ap_tag_slide_idx = locateval(idx3,1,ap_tag_cnt,s.tag_id,temp_ap_tag->qual[idx3].tag_id),
      IF (ap_tag_slide_idx > 0)
       reply->qual[d1.seq].spec_qual[d2.seq].slide_qual[d3.seq].sl_tag = temp_ap_tag->qual[
       ap_tag_slide_idx].tag_disp, reply->qual[d1.seq].spec_qual[d2.seq].slide_qual[d3.seq].sl_seq =
       temp_ap_tag->qual[ap_tag_slide_idx].tag_sequence
      ENDIF
      ,reply->qual[d1.seq].spec_qual[d2.seq].slide_qual[d3.seq].sl_origin_modifier = s
      .origin_modifier
     OF "S1":
      ap_tag_slide_idx = locateval(idx3,1,ap_tag_cnt,s1.tag_id,temp_ap_tag->qual[idx3].tag_id),
      IF (ap_tag_slide_idx > 0)
       reply->qual[d1.seq].spec_qual[d2.seq].cass_qual[d4.seq].slide_qual[d5.seq].s_tag = temp_ap_tag
       ->qual[ap_tag_slide_idx].tag_disp, reply->qual[d1.seq].spec_qual[d2.seq].cass_qual[d4.seq].
       slide_qual[d5.seq].s_seq = temp_ap_tag->qual[ap_tag_slide_idx].tag_sequence
      ENDIF
      ,reply->qual[d1.seq].spec_qual[d2.seq].cass_qual[d4.seq].slide_qual[d5.seq].s_origin_modifier
       = s1.origin_modifier
    ENDCASE
   WITH nocounter, outerjoin = d6, outerjoin = d7
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","SLIDE TAGS, AP_TAG")
   SET reply->status_data.status = "F"
  ENDIF
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_program
 IF (validate(temp_ap_tag,0))
  FREE RECORD temp_ap_tag
 ENDIF
END GO
