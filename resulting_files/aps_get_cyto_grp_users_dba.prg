CREATE PROGRAM aps_get_cyto_grp_users:dba
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
   1 group_qual[*]
     2 group_name = vc
     2 group_id = f8
     2 active_ind = i2
     2 user_qual[*]
       3 name = vc
       3 person_id = f8
       3 active_ind = i2
       3 role_mean = vc
       3 pgr_active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 prsnl_qual[*]
     2 prsnl_id = f8
     2 role_mean = vc
 )
#script
 DECLARE nresourceviewable = i2 WITH protect, noconstant(0)
 DECLARE cytotech_cd = f8 WITH protected, noconstant(0.0)
 DECLARE pathologist_cd = f8 WITH protected, noconstant(0.0)
 DECLARE resident_cd = f8 WITH protected, noconstant(0.0)
 DECLARE prsnl_group_type_code_set = i4 WITH protect, constant(357)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 CALL initresourcesecurity(1)
 CALL populatesrtypesforsecurity(1)
 SET stat = uar_get_meaning_by_codeset(prsnl_group_type_code_set,"CYTOTECH",1,cytotech_cd)
 IF (cytotech_cd=0.0)
  SET error_cnt += 1
  CALL handle_errors("SELECT","F","CODE_VALUE","CANNOT GET CYTOTECH CODE VALUE")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(prsnl_group_type_code_set,"PATHOLOGIST",1,pathologist_cd)
 IF (pathologist_cd=0.0)
  SET error_cnt += 1
  CALL handle_errors("SELECT","F","CODE_VALUE","CANNOT GET PATHOLOGIST CODE VALUE")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(prsnl_group_type_code_set,"PATHRESIDENT",1,resident_cd)
 IF (resident_cd=0.0)
  SET error_cnt += 1
  CALL handle_errors("SELECT","F","CODE_VALUE","CANNOT GET RESIDENT CODE VALUE")
  GO TO exit_script
 ENDIF
 SET cnt = 0
 SELECT INTO "nl:"
  pgr.person_id, csl.slide_limit, prsnl_group_type_mean = uar_get_code_meaning(pg.prsnl_group_type_cd
   )
  FROM prsnl_group pg,
   prsnl_group_reltn pgr,
   dummyt d,
   cyto_screening_limits csl,
   cyto_screening_security css,
   dummyt d1
  PLAN (pg
   WHERE pg.prsnl_group_type_cd IN (cytotech_cd, pathologist_cd, resident_cd)
    AND pg.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pg.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pgr
   WHERE pg.prsnl_group_id=pgr.prsnl_group_id)
   JOIN (d)
   JOIN (((csl
   WHERE pgr.person_id=csl.prsnl_id
    AND pg.prsnl_group_type_cd=cytotech_cd)
   JOIN (css
   WHERE csl.prsnl_id=css.prsnl_id)
   ) ORJOIN ((d1
   WHERE d1.seq=1
    AND ((pg.prsnl_group_type_cd=pathologist_cd) OR (pg.prsnl_group_type_cd=resident_cd)) )
   ))
  ORDER BY pgr.person_id
  HEAD pgr.person_id
   cnt += 1,
   CALL echo(build(pgr.person_id,": ",pg.prsnl_group_name,": ",csl.slide_limit,
    " "))
   IF (mod(cnt,10)=1)
    stat = alterlist(temp->prsnl_qual,(cnt+ 9))
   ENDIF
   temp->prsnl_qual[cnt].prsnl_id = pgr.person_id, temp->prsnl_qual[cnt].role_mean =
   prsnl_group_type_mean
  DETAIL
   IF ((temp->prsnl_qual[cnt].role_mean != "CYTOTECH")
    AND pgr.active_ind=1)
    temp->prsnl_qual[cnt].role_mean = prsnl_group_type_mean
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->prsnl_qual,cnt)
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pg.prsnl_group_name, pg.prsnl_group_id, pgr.prsnl_group_reltn_id,
  p.person_id, p.name_full_formatted
  FROM code_value cv,
   prsnl_group pg,
   prsnl_group_reltn pgr,
   prsnl p,
   (dummyt d  WITH seq = value(cnt))
  PLAN (cv
   WHERE cv.cdf_meaning="CYTORPTGRP")
   JOIN (pg
   WHERE pg.prsnl_group_type_cd=cv.code_value
    AND pg.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pg.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pgr
   WHERE pg.prsnl_group_id=pgr.prsnl_group_id)
   JOIN (p
   WHERE pgr.person_id=p.person_id)
   JOIN (d
   WHERE (temp->prsnl_qual[d.seq].prsnl_id=p.person_id))
  ORDER BY pg.prsnl_group_name, p.name_full_formatted
  HEAD REPORT
   gcnt = 0, service_resource_cd = 0.0
  HEAD pg.prsnl_group_name
   service_resource_cd = pg.service_resource_cd, ucnt = 0
   IF (isresourceviewable(service_resource_cd)=true)
    nresourceviewable = 1, gcnt += 1
    IF (mod(gcnt,10)=1)
     stat = alterlist(reply->group_qual,(gcnt+ 9))
    ENDIF
    reply->group_qual[gcnt].group_name = pg.prsnl_group_name, reply->group_qual[gcnt].group_id = pg
    .prsnl_group_id, reply->group_qual[gcnt].active_ind = pg.active_ind
   ELSE
    nresourceviewable = 0
   ENDIF
  HEAD p.name_full_formatted
   IF (nresourceviewable=1)
    ucnt += 1
    IF (mod(ucnt,10)=1)
     stat = alterlist(reply->group_qual[gcnt].user_qual,(ucnt+ 9))
    ENDIF
    reply->group_qual[gcnt].user_qual[ucnt].name = p.name_full_formatted, reply->group_qual[gcnt].
    user_qual[ucnt].person_id = p.person_id, reply->group_qual[gcnt].user_qual[ucnt].active_ind = p
    .active_ind,
    reply->group_qual[gcnt].user_qual[ucnt].role_mean = temp->prsnl_qual[d.seq].role_mean, reply->
    group_qual[gcnt].user_qual[ucnt].pgr_active_ind = pgr.active_ind
   ENDIF
  DETAIL
   IF (pgr.active_ind=1
    AND nresourceviewable=1)
    reply->group_qual[gcnt].user_qual[ucnt].pgr_active_ind = pgr.active_ind
   ENDIF
  FOOT  pg.prsnl_group_name
   IF (ucnt > 0)
    stat = alterlist(reply->group_qual[gcnt].user_qual,ucnt)
   ENDIF
  FOOT REPORT
   IF (gcnt > 0)
    stat = alterlist(reply->group_qual,gcnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","PRSNL_GROUP")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSEIF (getresourcesecuritystatus(0)="F")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(0)
  GO TO end_script
 ENDIF
 GO TO exit_script
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
#exit_script
 IF (error_cnt > 0)
  CALL echo("<<<<< ROLLBACK <<<<<")
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_script
END GO
