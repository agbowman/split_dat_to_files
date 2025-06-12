CREATE PROGRAM bb_get_qc_groups:dba
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
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
   1 group_list[*]
     2 group_id = f8
     2 group_name = c40
     2 group_name_key = c40
     2 group_desc = vc
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 service_resource_desc = vc
     2 schedule_cd = f8
     2 schedule_disp = c40
     2 schedule_desc = vc
     2 active_ind = i2
     2 require_validation_ind = i2
     2 updt_cnt = i4
     2 group_xref_list[*]
       3 group_xref_id = f8
       3 related_group_id = f8
     2 group_reagent_lot_list[*]
       3 group_reagent_lot_id = f8
       3 lot_information_id = f8
       3 lot_ident = c40
       3 manufacturer_cd = f8
       3 manufacturer_disp = c40
       3 reagent_cd = f8
       3 reagent_disp = c40
       3 expiration_dt_tm = dq8
       3 display_order = i4
       3 current_ind = i2
       3 related_reagent_id = f8
       3 updt_cnt = i4
       3 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nstatus = i2 WITH noconstant(0), protect
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE nfail = i2 WITH protect, constant(0)
 DECLARE nsuccess = i2 WITH protect, constant(1)
 DECLARE nno_matches = i2 WITH protect, constant(2)
#begin_script
 CALL initresourcesecurity(1)
 SET stat = alterlist(default_service_type_cd->service_type_cd_list,6)
 SET default_service_type_cd->service_type_cd_list[1].service_type_cd = uar_get_code_by("MEANING",223,
  "INSTITUTION")
 SET default_service_type_cd->service_type_cd_list[2].service_type_cd = uar_get_code_by("MEANING",223,
  "DEPARTMENT")
 SET default_service_type_cd->service_type_cd_list[3].service_type_cd = uar_get_code_by("MEANING",223,
  "SECTION")
 SET default_service_type_cd->service_type_cd_list[4].service_type_cd = uar_get_code_by("MEANING",223,
  "SUBSECTION")
 SET default_service_type_cd->service_type_cd_list[5].service_type_cd = uar_get_code_by("MEANING",223,
  "BENCH")
 SET default_service_type_cd->service_type_cd_list[6].service_type_cd = uar_get_code_by("MEANING",223,
  "INSTRUMENT")
 SET reply->status_data.status = "F"
 IF (size(request->group_list,5) > 0)
  SET nstatus = getqcgroupsbyid(0)
 ELSE
  SET nstatus = getallqcgroups(0)
 ENDIF
 IF (nstatus=nno_matches)
  SET reply->status_data.status = "Z"
  CALL subevent_add("SELECT","Z","BB_QC_GROUP","No groups found.")
  GO TO exit_script
 ELSEIF (nstatus=nfail)
  CALL subevent_add("SELECT","F","BB_QC_GROUP","Group query failed.")
  GO TO exit_script
 ENDIF
 SET nstatus = getqcgroupxrefs(0)
 IF (nstatus=nfail)
  CALL subevent_add("SELECT","F","BB_QC_GROUP_XREF","Group xref query failed.")
  GO TO exit_script
 ENDIF
 SET nstatus = getqcreagentlots(0)
 IF (nstatus=nfail)
  CALL subevent_add("SELECT","F","BB_QC_GRP_REAGENT_LOT","Group reagent lot query failed.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 SUBROUTINE (getqcgroupsbyid(no_param=i2(value)) =i2 WITH private)
   DECLARE lgroupcnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(request->group_list,5))),
     bb_qc_group g
    PLAN (d1)
     JOIN (g
     WHERE (g.group_id=request->group_list[d1.seq].group_id)
      AND g.schedule_cd > 0.0
      AND g.group_name != "")
    DETAIL
     IF (isresourceviewable(g.service_resource_cd)=true)
      lgroupcnt += 1
      IF (lgroupcnt > size(reply->group_list,5))
       nstatus = alterlist(reply->group_list,(lgroupcnt+ 10))
      ENDIF
      reply->group_list[lgroupcnt].group_id = g.group_id, reply->group_list[lgroupcnt].group_name = g
      .group_name, reply->group_list[lgroupcnt].group_name_key = g.group_name_key,
      reply->group_list[lgroupcnt].group_desc = g.group_desc, reply->group_list[lgroupcnt].
      service_resource_cd = g.service_resource_cd, reply->group_list[lgroupcnt].schedule_cd = g
      .schedule_cd,
      reply->group_list[lgroupcnt].active_ind = g.active_ind, reply->group_list[lgroupcnt].
      require_validation_ind = g.require_validation_ind, reply->group_list[lgroupcnt].updt_cnt = g
      .updt_cnt
     ENDIF
    FOOT REPORT
     nstatus = alterlist(reply->group_list,lgroupcnt)
    WITH nocounter
   ;end select
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode > 0)
    RETURN(nfail)
   ELSEIF (size(reply->group_list,5) > 0)
    RETURN(nsuccess)
   ELSE
    RETURN(nno_matches)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getallqcgroups(no_param=i2(value)) =i2 WITH private)
   DECLARE lgroupcnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM bb_qc_group g
    PLAN (g
     WHERE g.schedule_cd > 0.0
      AND g.group_name != "")
    DETAIL
     IF (isresourceviewable(g.service_resource_cd)=true)
      lgroupcnt += 1
      IF (lgroupcnt > size(reply->group_list,5))
       nstatus = alterlist(reply->group_list,(lgroupcnt+ 10))
      ENDIF
      reply->group_list[lgroupcnt].group_id = g.group_id, reply->group_list[lgroupcnt].group_name = g
      .group_name, reply->group_list[lgroupcnt].group_name_key = g.group_name_key,
      reply->group_list[lgroupcnt].group_desc = g.group_desc, reply->group_list[lgroupcnt].
      service_resource_cd = g.service_resource_cd, reply->group_list[lgroupcnt].schedule_cd = g
      .schedule_cd,
      reply->group_list[lgroupcnt].active_ind = g.active_ind, reply->group_list[lgroupcnt].
      require_validation_ind = g.require_validation_ind, reply->group_list[lgroupcnt].updt_cnt = g
      .updt_cnt
     ENDIF
    FOOT REPORT
     nstatus = alterlist(reply->group_list,lgroupcnt)
    WITH nocounter
   ;end select
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode > 0)
    RETURN(nfail)
   ELSEIF (size(reply->group_list,5) > 0)
    RETURN(nsuccess)
   ELSE
    RETURN(nno_matches)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getqcgroupxrefs(no_param=i2(value)) =i2 WITH private)
   DECLARE lxrefcnt = i4 WITH noconstant(0), protect
   DECLARE lgroupcnt = i4 WITH noconstant(0), protect
   SET lgroupcnt = size(reply->group_list,5)
   IF (lgroupcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(lgroupcnt)),
      bb_qc_group_xref gr
     PLAN (d1)
      JOIN (gr
      WHERE (gr.group_id=reply->group_list[d1.seq].group_id))
     ORDER BY gr.group_id
     HEAD gr.group_id
      lxrefcnt = 0
     DETAIL
      lxrefcnt += 1
      IF (lxrefcnt > size(reply->group_list[d1.seq].group_xref_list,5))
       nstatus = alterlist(reply->group_list[d1.seq].group_xref_list,(lxrefcnt+ 10))
      ENDIF
      reply->group_list[d1.seq].group_xref_list[lxrefcnt].group_xref_id = gr.group_xref_id, reply->
      group_list[d1.seq].group_xref_list[lxrefcnt].related_group_id = gr.related_group_id
     FOOT  gr.group_id
      nstatus = alterlist(reply->group_list[d1.seq].group_xref_list,lxrefcnt)
     WITH nocounter
    ;end select
   ENDIF
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode > 0)
    RETURN(nfail)
   ELSE
    RETURN(nsuccess)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getqcreagentlots(no_param=i2(value)) =i2 WITH private)
   DECLARE lreagentcnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(reply->group_list,5))),
     bb_qc_grp_reagent_lot rl,
     pcs_lot_information li,
     pcs_lot_definition ld
    PLAN (d1)
     JOIN (rl
     WHERE (rl.group_id=reply->group_list[d1.seq].group_id)
      AND rl.group_reagent_lot_id=rl.prev_group_reagent_lot_id
      AND rl.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND rl.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (li
     WHERE li.lot_information_id=rl.lot_information_id)
     JOIN (ld
     WHERE ld.lot_definition_id=li.lot_definition_id)
    ORDER BY d1.seq
    HEAD d1.seq
     lreagentcnt = 0
    DETAIL
     lreagentcnt += 1
     IF (lreagentcnt > size(reply->group_list[d1.seq].group_reagent_lot_list,5))
      nstatus = alterlist(reply->group_list[d1.seq].group_reagent_lot_list,(lreagentcnt+ 10))
     ENDIF
     reply->group_list[d1.seq].group_reagent_lot_list[lreagentcnt].group_reagent_lot_id = rl
     .group_reagent_lot_id, reply->group_list[d1.seq].group_reagent_lot_list[lreagentcnt].
     lot_information_id = rl.lot_information_id, reply->group_list[d1.seq].group_reagent_lot_list[
     lreagentcnt].lot_ident = li.lot_ident,
     reply->group_list[d1.seq].group_reagent_lot_list[lreagentcnt].manufacturer_cd = ld
     .manufacturer_cd, reply->group_list[d1.seq].group_reagent_lot_list[lreagentcnt].display_order =
     rl.display_order_seq, reply->group_list[d1.seq].group_reagent_lot_list[lreagentcnt].current_ind
      = rl.current_ind,
     reply->group_list[d1.seq].group_reagent_lot_list[lreagentcnt].updt_cnt = rl.updt_cnt, reply->
     group_list[d1.seq].group_reagent_lot_list[lreagentcnt].related_reagent_id = rl
     .related_reagent_id, reply->group_list[d1.seq].group_reagent_lot_list[lreagentcnt].reagent_cd =
     ld.parent_entity_id,
     reply->group_list[d1.seq].group_reagent_lot_list[lreagentcnt].expiration_dt_tm = li.expire_dt_tm,
     reply->group_list[d1.seq].group_reagent_lot_list[lreagentcnt].active_ind = rl.active_ind
    FOOT  d1.seq
     nstatus = alterlist(reply->group_list[d1.seq].group_reagent_lot_list,lreagentcnt)
    WITH nocounter
   ;end select
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode > 0)
    RETURN(nfail)
   ELSE
    RETURN(nsuccess)
   ENDIF
 END ;Subroutine
END GO
