CREATE PROGRAM aps_get_case_info:dba
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
 RECORD reply(
   1 case_id = f8
   1 encntr_id = f8
   1 accession_nbr = c21
   1 blob_bitmap = i4
   1 case_collect_dt_tm = dq8
   1 case_received_dt_tm = dq8
   1 responsible_pathologist_id = f8
   1 responsible_pathologist_name = vc
   1 responsible_resident_id = f8
   1 responsible_resident_name = vc
   1 requesting_physician_id = f8
   1 requesting_physician_name = vc
   1 requesting_physician_reltn_qual[*]
     2 prsnl_reltn_activity_id = f8
     2 prsnl_reltn_id = f8
     2 updt_cnt = i4
   1 comments_long_text_id = f8
   1 comments = vc
   1 c_lt_updt_cnt = i4
   1 order_loc_building_cd = f8
   1 order_loc_building_disp = c40
   1 order_loc_facility_cd = f8
   1 order_loc_facility_disp = c40
   1 order_loc_nurse_unit_cd = f8
   1 order_loc_nurse_unit_disp = c40
   1 updt_cnt = i4
   1 person_id = f8
   1 patient_name = vc
   1 primary_alias = vc
   1 birth_dt_tm = dq8
   1 birth_tz = i4
   1 age = vc
   1 deceased_dt_tm = dq8
   1 sex_cd = f8
   1 sex_disp = c40
   1 sex_desc = c60
   1 sex_mean = c12
   1 organization_id = f8
   1 organization = vc
   1 location_cd = f8
   1 location_disp = c40
   1 loc_facility_cd = f8
   1 loc_facility_disp = c40
   1 loc_building_cd = f8
   1 loc_building_disp = c40
   1 loc_nurse_unit_cd = f8
   1 loc_nurse_unit_disp = c40
   1 loc_room_cd = f8
   1 loc_room_disp = c40
   1 loc_bed_cd = f8
   1 loc_bed_disp = c40
   1 admit_doc = vc
   1 admit_doc_id = f8
   1 chr_ind = i2
   1 facility_accn_prefix_cd = f8
   1 origin_flag = i2
   1 rpt_qual[*]
     2 report_id = f8
     2 report_sequence = i4
     2 blob_bitmap = i4
     2 catalog_cd = f8
     2 short_description = c50
     2 responsible_pathologist_id = f8
     2 responsible_pathologist_name = vc
     2 responsible_resident_id = f8
     2 responsible_resident_name = vc
     2 editing_prsnl_name = vc
     2 processing_location_cd = f8
     2 processing_location_disp = c40
     2 request_priority_cd = f8
     2 request_priority_disp = c40
     2 request_dt_tm = dq8
     2 comments_long_text_id = f8
     2 comments = vc
     2 status_cd = f8
     2 status_disp = c40
     2 status_desc = c60
     2 status_mean = c12
     2 cancel_cd = f8
     2 cancel_disp = c40
     2 last_task_assay_cd = f8
     2 cancelable_ind = i2
     2 primary_ind = i2
     2 order_id = f8
     2 updt_cnt = i4
     2 cr_updt_cnt = i4
     2 lt_comm_updt_cnt = i4
     2 hold_cd = f8
     2 hold_disp = c40
   1 spec_qual[*]
     2 case_specimen_id = f8
     2 specimen_tag_cd = f8
     2 specimen_tag_display = c7
     2 specimen_tag_group_cd = f8
     2 specimen_tag_sequence = i4
     2 specimen_type_cd = f8
     2 specimen_type_disp = c40
     2 specimen_description = vc
     2 special_comments = vc
     2 spec_comments_long_text_id = f8
     2 spec_lt_updt_cnt = i4
     2 processing_task_id = f8
     2 task_comments = vc
     2 task_comments_long_text_id = f8
     2 task_lt_updt_cnt = i4
     2 collect_dt_tm = dq8
     2 received_dt_tm = dq8
     2 processing_location_cd = f8
     2 processing_location_disp = c40
     2 request_priority_cd = f8
     2 request_priority_disp = c40
     2 received_fixative_cd = f8
     2 received_fixative_disp = c40
     2 frozen_report_id = f8
     2 adequacy_reason_cd = f8
     2 adequacy_reason_disp = c40
     2 status_cd = f8
     2 status_disp = c40
     2 status_desc = c60
     2 status_mean = c12
     2 cancel_cd = f8
     2 cancel_disp = c40
     2 order_id = f8
     2 updt_cnt = i4
     2 pt_updt_cnt = i4
     2 catalog_cd = f8
   1 prompt_qual[*]
     2 task_assay_cd = f8
     2 long_text_id = f8
     2 long_text = vc
     2 active_ind = i2
     2 updt_cnt = i4
     2 lt_updt_cnt = i4
   1 phys_qual[*]
     2 physician_name = vc
     2 physician_id = f8
     2 reltn_qual[*]
       3 prsnl_reltn_activity_id = f8
       3 prsnl_reltn_id = f8
       3 updt_cnt = i4
   1 nomen_entity_qual[*]
     2 nomen_entity_reltn_id = f8
     2 diagnosis_code = c50
     2 nomenclature_id = f8
     2 diagnosis_desc = vc
     2 diag_priority = i4
   1 source_of_smear_cd = f8
   1 received_smear_ind = i2
   1 attend_doc = vc
   1 attend_doc_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(reltn_get_req,0)))
  RECORD reltn_get_req(
    1 qual[*]
      2 prsnl_id = f8
      2 parent_entity_id = f8
      2 parent_entity_name = c30
      2 entity_type_id = f8
      2 entity_type_name = c30
      2 person_id = f8
      2 encntr_id = f8
      2 order_id = f8
      2 accession_nbr = c20
  )
 ENDIF
 IF ( NOT (validate(reltn_get_rep,0)))
  RECORD reltn_get_rep(
    1 qual[*]
      2 prsnl_reltn[*]
        3 prsnl_reltn_activity_id = f8
        3 prsnl_id = f8
        3 parent_entity_id = f8
        3 parent_entity_name = c30
        3 entity_type_id = f8
        3 entity_type_name = c30
        3 prsnl_reltn_id = f8
        3 person_id = f8
        3 encntr_id = f8
        3 accession_nbr = c20
        3 order_id = f8
        3 usage_nbr = i4
        3 updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(ppr_action_max,0)))
  DECLARE ppr_action_max = i2 WITH public, constant(65535)
  DECLARE ppr_action_none = i2 WITH public, constant(0)
  DECLARE ppr_action_add = i2 WITH public, constant(1)
  DECLARE ppr_action_del = i2 WITH public, constant(2)
  DECLARE ppr_action_chg = i2 WITH public, constant(4)
  DECLARE ppr_action_ina = i2 WITH public, constant(8)
  DECLARE ppr_action_parent_chg = i2 WITH public, constant(16)
  DECLARE ppr_action_chld_chg = i2 WITH public, constant(32)
  DECLARE ppr_action_both_chg = i2 WITH public, constant(64)
  DECLARE ppr_action_del_no_id = i2 WITH public, constant(128)
  DECLARE ppr_hnauser_directoryon = i2 WITH public, constant(1)
  DECLARE ppr_hnauser_securityon = i2 WITH public, constant(2)
  DECLARE ppr_null_date = vc WITH public, constant("31-DEC-2100 23:59:59")
  DECLARE ppr_seq_name = vc WITH public, constant("PATIENT_PRIVACY_SEQ")
  SUBROUTINE (add_dm_info(domain=vc(value),name=vc(value),val_number=f8(value),val_char=vc(value),
   val_date=q8(value)) =i2)
    EXECUTE gm_dm_info2388_def "I"
    SUBROUTINE (gm_i_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
      DECLARE stat = i2 WITH protect, noconstant(0)
      IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
       SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
       IF (stat=0)
        CALL echo("can not expand request structure")
        RETURN(0)
       ENDIF
      ENDIF
      CASE (cnvtlower(icol_name))
       OF "info_number":
        SET gm_i_dm_info2388_req->qual[iqual].info_number = ival
        SET gm_i_dm_info2388_req->info_numberi = 1
       OF "info_long_id":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_i_dm_info2388_req->qual[iqual].info_long_id = ival
        SET gm_i_dm_info2388_req->info_long_idi = 1
       ELSE
        CALL echo("invalid column name passed")
        RETURN(0)
      ENDCASE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (gm_i_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
      DECLARE stat = i2 WITH protect, noconstant(0)
      IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
       SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
       IF (stat=0)
        CALL echo("can not expand request structure")
        RETURN(0)
       ENDIF
      ENDIF
      CASE (cnvtlower(icol_name))
       OF "info_date":
        SET gm_i_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
        SET gm_i_dm_info2388_req->info_datei = 1
       OF "updt_dt_tm":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_i_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
        SET gm_i_dm_info2388_req->updt_dt_tmi = 1
       ELSE
        CALL echo("invalid column name passed")
        RETURN(0)
      ENDCASE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (gm_i_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) =i2)
      DECLARE stat = i2 WITH protect, noconstant(0)
      IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
       SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
       IF (stat=0)
        CALL echo("can not expand request structure")
        RETURN(0)
       ENDIF
      ENDIF
      CASE (cnvtlower(icol_name))
       OF "info_domain":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_i_dm_info2388_req->qual[iqual].info_domain = ival
        SET gm_i_dm_info2388_req->info_domaini = 1
       OF "info_name":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_i_dm_info2388_req->qual[iqual].info_name = ival
        SET gm_i_dm_info2388_req->info_namei = 1
       OF "info_char":
        SET gm_i_dm_info2388_req->qual[iqual].info_char = ival
        SET gm_i_dm_info2388_req->info_chari = 1
       ELSE
        CALL echo("invalid column name passed")
        RETURN(0)
      ENDCASE
      RETURN(1)
    END ;Subroutine
    SET gm_i_dm_info2388_req->allow_partial_ind = 0
    SET gm_i_dm_info2388_req->info_numberi = 1
    SET gm_i_dm_info2388_req->info_domaini = 1
    SET gm_i_dm_info2388_req->info_namei = 1
    SET gm_i_dm_info2388_req->info_chari = 1
    SET stat = alterlist(gm_i_dm_info2388_req->qual,1)
    SET gm_i_dm_info2388_req->qual[1].info_domain = domain
    SET gm_i_dm_info2388_req->qual[1].info_name = name
    SET gm_i_dm_info2388_req->qual[1].info_number = val_number
    SET gm_i_dm_info2388_req->qual[1].info_char = val_char
    IF (val_date > 0)
     SET gm_i_dm_info2388_req->info_datei = 1
     SET gm_i_dm_info2388_req->qual[1].info_date = val_date
    ENDIF
    EXECUTE gm_i_dm_info2388  WITH replace("REQUEST","GM_I_DM_INFO2388_REQ"), replace("REPLY",
     "GM_I_DM_INFO2388_REP")
    IF ((gm_i_dm_info2388_rep->status_data.status="S"))
     FREE RECORD gm_i_dm_info2388_req
     FREE RECORD gm_i_dm_info2388_rep
     RETURN(0)
    ELSE
     FREE RECORD gm_i_dm_info2388_req
     FREE RECORD gm_i_dm_info2388_rep
     RETURN(1)
    ENDIF
  END ;Subroutine
  SUBROUTINE (upt_dm_info(domain=vc(value),name=vc(value),val_number=f8(value),val_char=vc(value),
   val_date=q8(value)) =i2)
    EXECUTE gm_dm_info2388_def "U"
    SUBROUTINE (gm_u_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
      DECLARE stat = i2 WITH protect, noconstant(0)
      IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
       SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
       IF (stat=0)
        CALL echo("can not expand request structure")
        RETURN(0)
       ENDIF
      ENDIF
      CASE (cnvtlower(icol_name))
       OF "info_number":
        IF (null_ind=1)
         SET gm_u_dm_info2388_req->info_numberf = 2
        ELSE
         SET gm_u_dm_info2388_req->info_numberf = 1
        ENDIF
        SET gm_u_dm_info2388_req->qual[iqual].info_number = ival
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->info_numberw = 1
        ENDIF
       OF "info_long_id":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_u_dm_info2388_req->info_long_idf = 1
        SET gm_u_dm_info2388_req->qual[iqual].info_long_id = ival
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->info_long_idw = 1
        ENDIF
       ELSE
        CALL echo("invalid column name passed")
        RETURN(0)
      ENDCASE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (gm_u_dm_info2388_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
      DECLARE stat = i2 WITH protect, noconstant(0)
      IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
       SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
       IF (stat=0)
        CALL echo("can not expand request structure")
        RETURN(0)
       ENDIF
      ENDIF
      CASE (cnvtlower(icol_name))
       OF "updt_cnt":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_u_dm_info2388_req->updt_cntf = 1
        SET gm_u_dm_info2388_req->qual[iqual].updt_cnt = ival
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->updt_cntw = 1
        ENDIF
       ELSE
        CALL echo("invalid column name passed")
        RETURN(0)
      ENDCASE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (gm_u_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
      DECLARE stat = i2 WITH protect, noconstant(0)
      IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
       SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
       IF (stat=0)
        CALL echo("can not expand request structure")
        RETURN(0)
       ENDIF
      ENDIF
      CASE (cnvtlower(icol_name))
       OF "info_date":
        IF (null_ind=1)
         SET gm_u_dm_info2388_req->info_datef = 2
        ELSE
         SET gm_u_dm_info2388_req->info_datef = 1
        ENDIF
        SET gm_u_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->info_datew = 1
        ENDIF
       OF "updt_dt_tm":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_u_dm_info2388_req->updt_dt_tmf = 1
        SET gm_u_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->updt_dt_tmw = 1
        ENDIF
       ELSE
        CALL echo("invalid column name passed")
        RETURN(0)
      ENDCASE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (gm_u_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
      DECLARE stat = i2 WITH protect, noconstant(0)
      IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
       SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
       IF (stat=0)
        CALL echo("can not expand request structure")
        RETURN(0)
       ENDIF
      ENDIF
      CASE (cnvtlower(icol_name))
       OF "info_domain":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_u_dm_info2388_req->info_domainf = 1
        SET gm_u_dm_info2388_req->qual[iqual].info_domain = ival
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->info_domainw = 1
        ENDIF
       OF "info_name":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_u_dm_info2388_req->info_namef = 1
        SET gm_u_dm_info2388_req->qual[iqual].info_name = ival
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->info_namew = 1
        ENDIF
       OF "info_char":
        IF (null_ind=1)
         SET gm_u_dm_info2388_req->info_charf = 2
        ELSE
         SET gm_u_dm_info2388_req->info_charf = 1
        ENDIF
        SET gm_u_dm_info2388_req->qual[iqual].info_char = ival
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->info_charw = 1
        ENDIF
       ELSE
        CALL echo("invalid column name passed")
        RETURN(0)
      ENDCASE
      RETURN(1)
    END ;Subroutine
    SET gm_u_dm_info2388_req->allow_partial_ind = 0
    SET gm_u_dm_info2388_req->force_updt_ind = 1
    SET gm_u_dm_info2388_req->info_charf = 1
    SET gm_u_dm_info2388_req->info_numberf = 1
    SET gm_u_dm_info2388_req->info_domainw = 1
    SET gm_u_dm_info2388_req->info_namew = 1
    SET stat = alterlist(gm_u_dm_info2388_req->qual,1)
    SET gm_u_dm_info2388_req->qual[1].info_domain = domain
    SET gm_u_dm_info2388_req->qual[1].info_name = name
    SET gm_u_dm_info2388_req->qual[1].info_char = val_char
    SET gm_u_dm_info2388_req->qual[1].info_number = val_number
    IF (val_date > 0)
     SET gm_u_dm_info2388_req->info_datef = 1
     SET gm_u_dm_info2388_req->qual[1].info_date = val_date
    ENDIF
    EXECUTE gm_u_dm_info2388  WITH replace("REQUEST","GM_U_DM_INFO2388_REQ"), replace("REPLY",
     "GM_U_DM_INFO2388_REP")
    IF ((gm_u_dm_info2388_rep->status_data.status="S"))
     FREE RECORD gm_u_dm_info2388_req
     FREE RECORD gm_u_dm_info2388_rep
     RETURN(0)
    ELSE
     FREE RECORD gm_u_dm_info2388_req
     FREE RECORD gm_u_dm_info2388_rep
     RETURN(1)
    ENDIF
  END ;Subroutine
  SUBROUTINE (ens_dm_info(domain=vc(value),name=vc(value),val_number=f8(value),val_char=vc(value),
   val_date=q8(value)) =i2)
    DECLARE row_exists_ind = i2 WITH protected, noconstant(0)
    DECLARE success_ind = i2 WITH protected, noconstant(0)
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain=domain
      AND d.info_name=name
     DETAIL
      row_exists_ind = 1
     WITH nocounter
    ;end select
    IF (row_exists_ind=1)
     SET success_ind = upt_dm_info(domain,name,val_number,val_char,val_date)
    ELSE
     SET success_ind = add_dm_info(domain,name,val_number,val_char,val_date)
    ENDIF
    RETURN(success_ind)
  END ;Subroutine
  SUBROUTINE (convert_id_to_string(id=f8(value),digit_cnt=i4(value)) =vc)
    DECLARE id_str = vc WITH private, noconstant("")
    DECLARE id_len = i4 WITH private, noconstant(0)
    DECLARE decimal_pos = i4 WITH private, noconstant(0)
    DECLARE idx = i4 WITH private, noconstant(0)
    SET id_str = trim(cnvtstring(id))
    SET id_len = size(id_str)
    IF (id_len > 0)
     SET decimal_pos = findstring(".",id_str)
     IF (decimal_pos > 0)
      SET id_str = substring(1,(decimal_pos - 1),id_str)
     ENDIF
     IF (digit_cnt > 0)
      SET id_str = concat(id_str,".")
      FOR (idx = 1 TO digit_cnt)
        SET id_str = concat(id_str,"0")
      ENDFOR
     ENDIF
    ENDIF
    RETURN(id_str)
  END ;Subroutine
  SUBROUTINE (ppr_column_exists(stable=vc(value),scolumn=vc(value)) =i4)
    DECLARE ce_flag = i4 WITH public, noconstant(0)
    DECLARE stablename = vc WITH public, noconstant(" ")
    DECLARE scolumnname = vc WITH public, noconstant(" ")
    SET ce_flag = 0
    SET stablename = cnvtupper(stable)
    SET scolumnname = cnvtupper(scolumn)
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stablename
      AND l.attr_name=scolumnname
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      ce_flag = 1
     WITH nocounter
    ;end select
    RETURN(ce_flag)
  END ;Subroutine
  SUBROUTINE (directory_status(nhnausermode=i4) =i2)
   IF (nhnausermode=0)
    RETURN(0)
   ELSEIF (nhnausermode < 0)
    RETURN(- (1))
   ELSE
    IF (((nhnausermode - ppr_hnauser_securityon) >= 0))
     SET nhnausermode -= ppr_hnauser_securityon
    ENDIF
    IF (((nhnausermode - ppr_hnauser_directoryon) >= 0))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
  END ;Subroutine
  SUBROUTINE (security_status(nhnausermode=i4) =i2)
   IF (nhnausermode=0)
    RETURN(0)
   ELSEIF (nhnausermode < 0)
    RETURN(- (1))
   ELSE
    IF (((nhnausermode - ppr_hnauser_securityon) >= 0))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
  END ;Subroutine
 ENDIF
#script
 DECLARE nprsnlcnt = i4 WITH protect, noconstant(0)
 DECLARE dconsultphystypeid = f8 WITH protect, noconstant(0.0)
 DECLARE dorderphystypeid = f8 WITH protect, noconstant(0.0)
 DECLARE nmaxreltncnt = i4 WITH protect, noconstant(0)
 DECLARE nprsnlreltncheckprg = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET verified_status_cd = 0.0
 SET prefix_cd = 0.0
 SET nomen_entity_cnt = 0
 SET accn_icd9_cd = 0.0
 SET pc_where = fillstring(25," ")
 SET stat = uar_get_meaning_by_codeset(333,"CONSULTDOC",1,dconsultphystypeid)
 SET stat = uar_get_meaning_by_codeset(333,"ORDERDOC",1,dorderphystypeid)
 IF (checkprg("PPR_GET_PRSNL_RELTN_ACT") > 0)
  SET nprsnlreltncheckprg = 1
 ENDIF
 CALL initresourcesecurity(1)
 IF ((request->return_historical_ind=0))
  SET pc_where = "pc.origin_flag = 0"
 ELSE
  SET pc_where = "1 = 1"
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"VERIFIED",1,verified_status_cd)
 SET stat = alterlist(reply->rpt_qual,1)
 SET stat = alterlist(reply->spec_qual,1)
 SET stat = alterlist(reply->phys_qual,1)
 SET stat = alterlist(reply->prompt_qual,1)
 SELECT INTO "nl:"
  join_path = decode(cr.seq,"R",cs.seq,"S",cp.seq,
   "P"," "), rt_exists = decode(rt.seq,"Y","N"), pt_exists = decode(pt.seq,"Y","N"),
  t_tag_group_id = decode(t.seq,t.tag_group_id,0.0), t_tag_sequence = decode(t.seq,t.tag_sequence,0),
  pc.case_id
  FROM pathology_case pc,
   prsnl p1,
   prsnl p2,
   prsnl p5,
   ap_prefix ap,
   (dummyt d1  WITH seq = 1),
   case_report cr,
   report_task rt,
   service_directory sd,
   prefix_report_r prr,
   prsnl p3,
   prsnl p4,
   prsnl p6,
   (dummyt d2  WITH seq = 1),
   case_specimen cs,
   ap_tag t,
   processing_task pt,
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   (dummyt d5  WITH seq = 1),
   case_provider cp,
   prsnl pr,
   orders o
  PLAN (pc
   WHERE (request->accession_nbr=pc.accession_nbr)
    AND pc.cancel_cd IN (null, 0)
    AND parser(trim(pc_where)))
   JOIN (p1
   WHERE pc.responsible_pathologist_id=p1.person_id)
   JOIN (p2
   WHERE pc.responsible_resident_id=p2.person_id)
   JOIN (p5
   WHERE pc.requesting_physician_id=p5.person_id)
   JOIN (ap
   WHERE ap.prefix_id=pc.prefix_id)
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (cr
   WHERE pc.case_id=cr.case_id)
   JOIN (sd
   WHERE cr.catalog_cd=sd.catalog_cd)
   JOIN (prr
   WHERE pc.prefix_id=prr.prefix_id
    AND cr.catalog_cd=prr.catalog_cd)
   JOIN (d4
   WHERE 1=d4.seq)
   JOIN (rt
   WHERE cr.report_id=rt.report_id)
   JOIN (p3
   WHERE rt.responsible_pathologist_id=p3.person_id)
   JOIN (p4
   WHERE rt.responsible_resident_id=p4.person_id)
   JOIN (p6
   WHERE rt.editing_prsnl_id=p6.person_id)
   ) ORJOIN ((((d2
   WHERE 1=d2.seq)
   JOIN (cs
   WHERE pc.case_id=cs.case_id)
   JOIN (t
   WHERE cs.specimen_tag_id=t.tag_id)
   JOIN (d5
   WHERE 1=d5.seq)
   JOIN (pt
   WHERE cs.case_specimen_id=pt.case_specimen_id
    AND 4=pt.create_inventory_flag)
   JOIN (o
   WHERE pt.order_id=o.order_id)
   ) ORJOIN ((d3
   WHERE 1=d3.seq)
   JOIN (cp
   WHERE pc.case_id=cp.case_id)
   JOIN (pr
   WHERE cp.physician_id=pr.person_id)
   )) ))
  ORDER BY t_tag_group_id, t_tag_sequence
  HEAD REPORT
   rpt_cnt = 0, spec_cnt = 0, phys_cnt = 0,
   service_resource_cd = ap.service_resource_cd
   IF (isresourceviewable(service_resource_cd)=true)
    reply->case_id = pc.case_id, reply->encntr_id = pc.encntr_id, reply->accession_nbr = pc
    .accession_nbr,
    reply->blob_bitmap = pc.blob_bitmap, prefix_cd = pc.prefix_id, reply->case_collect_dt_tm =
    cnvtdatetime(pc.case_collect_dt_tm),
    reply->case_received_dt_tm = cnvtdatetime(pc.case_received_dt_tm), reply->
    responsible_pathologist_id = pc.responsible_pathologist_id, reply->responsible_pathologist_name
     = trim(p1.name_full_formatted),
    reply->responsible_resident_id = pc.responsible_resident_id, reply->requesting_physician_id = pc
    .requesting_physician_id, reply->order_loc_building_cd = pc.loc_building_cd,
    reply->order_loc_facility_cd = pc.loc_facility_cd, reply->order_loc_nurse_unit_cd = pc
    .loc_nurse_unit_cd, reply->comments_long_text_id = pc.comments_long_text_id,
    reply->updt_cnt = pc.updt_cnt, reply->responsible_resident_name = trim(p2.name_full_formatted),
    reply->requesting_physician_name = trim(p5.name_full_formatted),
    reply->person_id = pc.person_id, reply->chr_ind = pc.chr_ind, reply->origin_flag = pc.origin_flag,
    reply->source_of_smear_cd = pc.source_of_smear_cd, reply->received_smear_ind = pc
    .received_smear_ind
   ENDIF
  DETAIL
   IF (getresourcesecuritystatus(0)="S")
    CASE (join_path)
     OF "R":
      rpt_cnt += 1,stat = alterlist(reply->rpt_qual,rpt_cnt),reply->rpt_qual[rpt_cnt].report_id = cr
      .report_id,
      reply->rpt_qual[rpt_cnt].report_sequence = cr.report_sequence,reply->rpt_qual[rpt_cnt].
      catalog_cd = cr.catalog_cd,reply->rpt_qual[rpt_cnt].request_dt_tm = cr.request_dt_tm,
      reply->rpt_qual[rpt_cnt].status_cd = cr.status_cd,reply->rpt_qual[rpt_cnt].cancel_cd = cr
      .cancel_cd,reply->rpt_qual[rpt_cnt].primary_ind = prr.primary_ind,
      reply->rpt_qual[rpt_cnt].cr_updt_cnt = cr.updt_cnt,reply->rpt_qual[rpt_cnt].short_description
       = sd.short_description,reply->rpt_qual[rpt_cnt].blob_bitmap = cr.blob_bitmap,
      IF (rt_exists="Y")
       reply->rpt_qual[rpt_cnt].responsible_pathologist_id = rt.responsible_pathologist_id, reply->
       rpt_qual[rpt_cnt].responsible_pathologist_name = trim(p3.name_full_formatted), reply->
       rpt_qual[rpt_cnt].responsible_resident_id = rt.responsible_resident_id,
       reply->rpt_qual[rpt_cnt].responsible_resident_name = trim(p4.name_full_formatted)
       IF (p6.person_id != 0.0)
        reply->rpt_qual[rpt_cnt].editing_prsnl_name = trim(p6.name_full_formatted)
       ENDIF
       reply->rpt_qual[rpt_cnt].processing_location_cd = rt.service_resource_cd, reply->rpt_qual[
       rpt_cnt].request_priority_cd = rt.priority_cd, reply->rpt_qual[rpt_cnt].last_task_assay_cd =
       rt.last_task_assay_cd,
       reply->rpt_qual[rpt_cnt].comments_long_text_id = rt.comments_long_text_id, reply->rpt_qual[
       rpt_cnt].order_id = rt.order_id, reply->rpt_qual[rpt_cnt].updt_cnt = rt.updt_cnt,
       reply->rpt_qual[rpt_cnt].hold_cd = rt.hold_cd
      ENDIF
     OF "S":
      spec_cnt += 1,stat = alterlist(reply->spec_qual,spec_cnt),reply->spec_qual[spec_cnt].
      case_specimen_id = cs.case_specimen_id,
      reply->spec_qual[spec_cnt].specimen_tag_cd = cs.specimen_tag_id,reply->spec_qual[spec_cnt].
      specimen_type_cd = cs.specimen_cd,reply->spec_qual[spec_cnt].specimen_description = trim(cs
       .specimen_description),
      reply->spec_qual[spec_cnt].spec_comments_long_text_id = cs.spec_comments_long_text_id,reply->
      spec_qual[spec_cnt].collect_dt_tm = cnvtdatetime(cs.collect_dt_tm),reply->spec_qual[spec_cnt].
      received_dt_tm = cnvtdatetime(cs.received_dt_tm),
      reply->spec_qual[spec_cnt].updt_cnt = cs.updt_cnt,reply->spec_qual[spec_cnt].
      received_fixative_cd = cs.received_fixative_cd,reply->spec_qual[spec_cnt].frozen_report_id = cs
      .frozen_report_id,
      reply->spec_qual[spec_cnt].adequacy_reason_cd = cs.inadequacy_reason_cd,reply->spec_qual[
      spec_cnt].cancel_cd = cs.cancel_cd,reply->spec_qual[spec_cnt].specimen_tag_group_cd =
      t_tag_group_id,
      reply->spec_qual[spec_cnt].specimen_tag_sequence = t_tag_sequence,reply->spec_qual[spec_cnt].
      specimen_tag_display = t.tag_disp,
      IF (pt.order_id=0)
       reply->spec_qual[spec_cnt].catalog_cd = ap.order_catalog_cd
      ELSE
       reply->spec_qual[spec_cnt].catalog_cd = o.catalog_cd
      ENDIF
      ,
      IF (pt_exists="Y")
       reply->spec_qual[spec_cnt].status_cd = pt.status_cd, reply->spec_qual[spec_cnt].
       processing_location_cd = pt.service_resource_cd, reply->spec_qual[spec_cnt].
       request_priority_cd = pt.priority_cd,
       reply->spec_qual[spec_cnt].order_id = pt.order_id, reply->spec_qual[spec_cnt].pt_updt_cnt = pt
       .updt_cnt, reply->spec_qual[spec_cnt].task_comments_long_text_id = pt.comments_long_text_id,
       reply->spec_qual[spec_cnt].processing_task_id = pt.processing_task_id
      ELSE
       reply->spec_qual[spec_cnt].status_cd = verified_status_cd
      ENDIF
     OF "P":
      phys_cnt += 1,stat = alterlist(reply->phys_qual,phys_cnt),reply->phys_qual[phys_cnt].
      physician_name = trim(pr.name_full_formatted),
      reply->phys_qual[phys_cnt].physician_id = cp.physician_id
    ENDCASE
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->rpt_qual,rpt_cnt), stat = alterlist(reply->spec_qual,spec_cnt), stat =
   alterlist(reply->phys_qual,phys_cnt)
  WITH nocounter, outerjoin = d4, outerjoin = d5
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(1)
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt,
   (dummyt d1  WITH seq = value(size(reply->spec_qual,5)))
  PLAN (d1
   WHERE (reply->spec_qual[d1.seq].task_comments_long_text_id > 0))
   JOIN (lt
   WHERE (lt.long_text_id=reply->spec_qual[d1.seq].task_comments_long_text_id)
    AND lt.parent_entity_name="PROCESSING_TASK"
    AND (lt.parent_entity_id=reply->spec_qual[d1.seq].processing_task_id))
  DETAIL
   reply->spec_qual[d1.seq].task_comments = trim(lt.long_text), reply->spec_qual[d1.seq].
   task_lt_updt_cnt = lt.updt_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt,
   (dummyt d1  WITH seq = value(size(reply->rpt_qual,5)))
  PLAN (d1
   WHERE (reply->rpt_qual[d1.seq].comments_long_text_id > 0))
   JOIN (lt
   WHERE (lt.long_text_id=reply->rpt_qual[d1.seq].comments_long_text_id))
  DETAIL
   reply->rpt_qual[d1.seq].comments = trim(lt.long_text), reply->rpt_qual[d1.seq].lt_comm_updt_cnt =
   lt.updt_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt,
   (dummyt d1  WITH seq = value(size(reply->spec_qual,5)))
  PLAN (d1
   WHERE (reply->spec_qual[d1.seq].spec_comments_long_text_id > 0))
   JOIN (lt
   WHERE (lt.long_text_id=reply->spec_qual[d1.seq].spec_comments_long_text_id)
    AND lt.parent_entity_name="CASE_SPECIMEN"
    AND (lt.parent_entity_id=reply->spec_qual[d1.seq].case_specimen_id))
  DETAIL
   reply->spec_qual[d1.seq].special_comments = trim(lt.long_text), reply->spec_qual[d1.seq].
   spec_lt_updt_cnt = lt.updt_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lt.long_text_id
  FROM long_text lt
  WHERE (lt.long_text_id=reply->comments_long_text_id)
   AND lt.parent_entity_name="PATHOLOGY_CASE"
   AND (lt.parent_entity_id=reply->case_id)
   AND (reply->comments_long_text_id > 0)
  DETAIL
   reply->comments = trim(lt.long_text), reply->c_lt_updt_cnt = lt.updt_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lt.long_text_id
  FROM ap_prompt_test apt,
   long_text lt
  PLAN (apt
   WHERE (reply->case_id=apt.accession_id))
   JOIN (lt
   WHERE lt.long_text_id=apt.long_text_id)
  HEAD REPORT
   prompt_cnt = 0
  DETAIL
   prompt_cnt += 1, stat = alterlist(reply->prompt_qual,prompt_cnt), reply->prompt_qual[prompt_cnt].
   task_assay_cd = apt.task_assay_cd,
   reply->prompt_qual[prompt_cnt].long_text_id = lt.long_text_id, reply->prompt_qual[prompt_cnt].
   long_text = lt.long_text, reply->prompt_qual[prompt_cnt].active_ind = apt.active_ind,
   reply->prompt_qual[prompt_cnt].updt_cnt = apt.updt_cnt, reply->prompt_qual[prompt_cnt].lt_updt_cnt
    = lt.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->prompt_qual,prompt_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ris.catalog_cd
  FROM (dummyt d  WITH seq = value(cnvtint(size(reply->rpt_qual,5)))),
   code_value cv,
   report_inproc_status ris
  PLAN (d)
   JOIN (cv
   WHERE (reply->rpt_qual[d.seq].status_cd=cv.code_value)
    AND cv.cdf_meaning IN ("IN PROCESS", "COMPLETED"))
   JOIN (ris
   WHERE (reply->rpt_qual[d.seq].catalog_cd=ris.catalog_cd)
    AND (reply->rpt_qual[d.seq].last_task_assay_cd=ris.task_assay_cd))
  DETAIL
   reply->rpt_qual[d.seq].cancelable_ind = ris.cancelable_ind
  WITH nocounter
 ;end select
 SET request->person_id = reply->person_id
 SET request->encounter_id = reply->encntr_id
 EXECUTE aps_get_person_info
 SET stat = uar_get_meaning_by_codeset(23549,"ACCNICD9",1,accn_icd9_cd)
 SELECT INTO "nl:"
  ner.nomenclature_id
  FROM nomen_entity_reltn ner,
   nomenclature n
  PLAN (ner
   WHERE ner.parent_entity_name="ACCESSION"
    AND (ner.parent_entity_id=reply->case_id)
    AND ner.active_ind=1
    AND ner.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND ner.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ner.reltn_type_cd=accn_icd9_cd)
   JOIN (n
   WHERE n.nomenclature_id=ner.nomenclature_id)
  ORDER BY ner.priority
  HEAD REPORT
   nomen_entity_cnt = 0
  DETAIL
   nomen_entity_cnt += 1, stat = alterlist(reply->nomen_entity_qual,nomen_entity_cnt), reply->
   nomen_entity_qual[nomen_entity_cnt].nomen_entity_reltn_id = ner.nomen_entity_reltn_id,
   reply->nomen_entity_qual[nomen_entity_cnt].nomenclature_id = n.nomenclature_id, reply->
   nomen_entity_qual[nomen_entity_cnt].diagnosis_code = n.source_identifier, reply->
   nomen_entity_qual[nomen_entity_cnt].diagnosis_desc = n.source_string,
   reply->nomen_entity_qual[nomen_entity_cnt].diag_priority = ner.priority
  FOOT REPORT
   stat = alterlist(reply->nomen_entity_qual,nomen_entity_cnt)
  WITH nocounter
 ;end select
 IF (nprsnlreltncheckprg=1)
  SET stat = alterlist(reltn_get_req->qual,10)
  SET reltn_get_req->qual[1].prsnl_id = reply->requesting_physician_id
  SET reltn_get_req->qual[1].accession_nbr = reply->accession_nbr
  SET reltn_get_req->qual[1].entity_type_name = "CODE_VALUE"
  SET reltn_get_req->qual[1].entity_type_id = dorderphystypeid
  SET reltn_get_req->qual[1].parent_entity_name = "ACCESSION"
  SET reltn_get_req->qual[1].parent_entity_id = reply->case_id
  SET nprsnlcnt = 1
  IF (size(reply->phys_qual,5) > 0)
   SELECT INTO "nl:"
    d1.*
    FROM (dummyt d1  WITH seq = value(size(reply->phys_qual,5)))
    PLAN (d1)
    ORDER BY d1.seq
    DETAIL
     nprsnlcnt += 1
     IF (mod(nprsnlcnt,10)=1)
      stat = alterlist(reltn_get_req->qual,(nprsnlcnt+ 9))
     ENDIF
     reltn_get_req->qual[nprsnlcnt].prsnl_id = reply->phys_qual[d1.seq].physician_id, reltn_get_req->
     qual[nprsnlcnt].accession_nbr = reply->accession_nbr, reltn_get_req->qual[nprsnlcnt].
     entity_type_name = "CODE_VALUE",
     reltn_get_req->qual[nprsnlcnt].entity_type_id = dconsultphystypeid, reltn_get_req->qual[
     nprsnlcnt].parent_entity_name = "ACCESSION", reltn_get_req->qual[nprsnlcnt].parent_entity_id =
     reply->case_id
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist(reltn_get_req->qual,nprsnlcnt)
  EXECUTE ppr_get_prsnl_reltn_act  WITH replace("REQUEST","RELTN_GET_REQ"), replace("REPLY",
   "RELTN_GET_REP")
  IF ((reltn_get_rep->status_data.status="S"))
   SELECT INTO "nl:"
    d1.seq
    FROM (dummyt d1  WITH seq = value(size(reltn_get_rep->qual,5)))
    PLAN (d1)
    DETAIL
     IF (size(reltn_get_rep->qual[d1.seq].prsnl_reltn,5) > nmaxreltncnt)
      nmaxreltncnt = size(reltn_get_rep->qual[d1.seq].prsnl_reltn,5)
     ENDIF
    WITH nocounter
   ;end select
   SET nprsnlcnt = 0
   IF (size(reltn_get_rep->qual[1].prsnl_reltn,5) > 0)
    SELECT INTO "nl:"
     d1.seq
     FROM (dummyt d1  WITH seq = value(size(reltn_get_rep->qual[1].prsnl_reltn,5)))
     PLAN (d1)
     DETAIL
      nprsnlcnt += 1, stat = alterlist(reply->requesting_physician_reltn_qual,nprsnlcnt), reply->
      requesting_physician_reltn_qual[nprsnlcnt].prsnl_reltn_activity_id = reltn_get_rep->qual[1].
      prsnl_reltn[d1.seq].prsnl_reltn_activity_id,
      reply->requesting_physician_reltn_qual[nprsnlcnt].prsnl_reltn_id = reltn_get_rep->qual[1].
      prsnl_reltn[d1.seq].prsnl_reltn_id, reply->requesting_physician_reltn_qual[nprsnlcnt].updt_cnt
       = reltn_get_rep->qual[1].prsnl_reltn[d1.seq].updt_cnt
     WITH nocounter
    ;end select
   ENDIF
   IF (nmaxreltncnt > 0)
    SELECT INTO "nl:"
     d1.seq
     FROM (dummyt d1  WITH seq = value(size(reltn_get_rep->qual,5))),
      (dummyt d2  WITH seq = value(nmaxreltncnt))
     PLAN (d1
      WHERE d1.seq > 1)
      JOIN (d2
      WHERE d2.seq <= size(reltn_get_rep->qual[d1.seq].prsnl_reltn,5))
     ORDER BY d1.seq
     HEAD d1.seq
      nprsnlcnt = 0
     DETAIL
      nprsnlcnt += 1, stat = alterlist(reply->phys_qual[(d1.seq - 1)].reltn_qual,nprsnlcnt), reply->
      phys_qual[(d1.seq - 1)].reltn_qual[nprsnlcnt].prsnl_reltn_activity_id = reltn_get_rep->qual[d1
      .seq].prsnl_reltn[d2.seq].prsnl_reltn_activity_id,
      reply->phys_qual[(d1.seq - 1)].reltn_qual[nprsnlcnt].prsnl_reltn_id = reltn_get_rep->qual[d1
      .seq].prsnl_reltn[d2.seq].prsnl_reltn_id, reply->phys_qual[(d1.seq - 1)].reltn_qual[nprsnlcnt].
      updt_cnt = reltn_get_rep->qual[d1.seq].prsnl_reltn[d2.seq].updt_cnt
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
#exit_script
 FREE RECORD reltn_get_rep
 FREE RECORD reltn_get_req
END GO
