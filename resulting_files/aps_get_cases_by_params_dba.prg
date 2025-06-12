CREATE PROGRAM aps_get_cases_by_params:dba
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
   1 call_post_script_flag = i2
   1 call_qualify_on_ces = i2
   1 qual[*]
     2 accession_nbr = c20
     2 qualify_ind = i2
     2 report_qual[*]
       3 report_id = f8
       3 event_id = f8
       3 verify_ind = i2
   1 select_qual[*]
     2 text = vc
   1 synoptic_query = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD accession(
   1 qual[*]
     2 accession_nbr = c20
     2 qualify_ind = i2
     2 report_qual[*]
       3 report_id = f8
       3 event_id = f8
       3 verify_ind = i2
 )
 RECORD image_code(
   1 qual[*]
     2 code = f8
   1 report_qual[*]
     2 catalog_cd = f8
   1 task_assay_qual[*]
     2 task_assay_cd = f8
 )
 RECORD code(
   1 qual[*]
     2 code = f8
   1 report_qual[*]
     2 catalog_cd = f8
   1 task_assay_qual[*]
     2 task_assay_cd = f8
 )
 RECORD task_assay(
   1 qual[*]
     2 task_assay_cd = f8
 )
 RECORD temp(
   1 qual[*]
     2 accession_nbr = c20
     2 birth_dt_tm = dq8
     2 case_collect_dt_tm = dq8
     2 report_qual[*]
       3 report_id = f8
       3 event_id = f8
       3 verify_ind = i2
     2 age_check_qual[*]
       3 beg_date_str = vc
       3 end_date_str = vc
 )
 RECORD temp_indexes(
   1 qual[*]
     2 i = i2
 )
 RECORD scd_stories(
   1 qual[*]
     2 scd_story_id = f8
 )
 DECLARE cclsql_to_number(p1) = f8
 DECLARE code_set_value = i4 WITH protect, noconstant(0)
 DECLARE image_code_set = i4 WITH protect, noconstant(0)
 DECLARE acr_nema_cd = f8 WITH protect, noconstant(0.0)
 DECLARE deleted_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE canceled_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE verified_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE corrected_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ver_in_proc_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cor_in_proc_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE catalog_code_set = i2 WITH protect, constant(200)
 DECLARE ap_query_result_ind = i2 WITH protect, noconstant(0)
 DECLARE pathology_case_ind = i2 WITH protect, noconstant(0)
 DECLARE person_ind = i2 WITH protect, noconstant(0)
 DECLARE case_specimen_ind = i2 WITH protect, noconstant(0)
 DECLARE encounter_ind = i2 WITH protect, noconstant(0)
 DECLARE case_report_ind = i2 WITH protect, noconstant(0)
 DECLARE prefix_report_r_ind = i2 WITH protect, noconstant(0)
 DECLARE person_race_ind = i2 WITH protect, noconstant(0)
 DECLARE person_ethnicgrp_ind = i2 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE z = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE rpt_cnt = i4 WITH protect, noconstant(0)
 DECLARE accn_cnt = i4 WITH protect, noconstant(0)
 DECLARE code_cnt = i4 WITH protect, noconstant(0)
 DECLARE max_rpt_cnt = i4 WITH protect, noconstant(0)
 DECLARE image_code_cnt = i4 WITH protect, noconstant(0)
 DECLARE task_assay_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_indexes_cnt = i4 WITH protect, noconstant(0)
 DECLARE report_qual_cnt = i4 WITH protect, noconstant(0)
 DECLARE reply_cnt = i4 WITH protect, noconstant(0)
 DECLARE age_check_cnt = i4 WITH protect, noconstant(0)
 DECLARE image_report_qual_cnt = i4 WITH protect, noconstant(0)
 DECLARE task_assay_image_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_accprefix = vc WITH protect, noconstant("")
 DECLARE temp_casetype = vc WITH protect, noconstant("")
 DECLARE temp_reqphys = vc WITH protect, noconstant("")
 DECLARE temp_resppath = vc WITH protect, noconstant("")
 DECLARE temp_respresi = vc WITH protect, noconstant("")
 DECLARE temp_coldate = vc WITH protect, noconstant("")
 DECLARE temp_verdate = vc WITH protect, noconstant("")
 DECLARE temp_verid = vc WITH protect, noconstant("")
 DECLARE temp_ethnicgroup = vc WITH protect, noconstant("")
 DECLARE temp_gender = vc WITH protect, noconstant("")
 DECLARE temp_military = vc WITH protect, noconstant("")
 DECLARE temp_race = vc WITH protect, noconstant("")
 DECLARE temp_species = vc WITH protect, noconstant("")
 DECLARE temp_birthdate = vc WITH protect, noconstant("")
 DECLARE temp_agecurdate = vc WITH protect, noconstant("")
 DECLARE temp_client = vc WITH protect, noconstant("")
 DECLARE temp_specimen = vc WITH protect, noconstant("")
 DECLARE temp_queryresult = vc WITH protect, noconstant("")
 DECLARE temp_prefixids = vc WITH protect, noconstant("")
 DECLARE case_where = vc WITH protect, noconstant("")
 DECLARE person_where = vc WITH protect, noconstant("")
 DECLARE person_race_where = vc WITH protect, noconstant("")
 DECLARE report_where = vc WITH protect, noconstant("")
 DECLARE coldate_where = vc WITH protect, noconstant("")
 DECLARE person_ethnicgrp_where = vc WITH protect, noconstant("")
 DECLARE pc_image_ind = c28 WITH protect, constant("pc.blob_bitmap in (1, 3, 7)")
 DECLARE cr_image_ind = c28 WITH protect, constant("cr.blob_bitmap in (1, 3, 7)")
 DECLARE pc_image_ind_or_cr_image_ind = c58 WITH protect, constant(
  "cr.blob_bitmap in (1, 3, 7) or pc.blob_bitmap in (1, 3, 7)")
 DECLARE join_cr = c23 WITH protect, constant("pc.case_id = cr.case_id")
 DECLARE report_cancel = vc WITH protect, noconstant("")
 DECLARE report_verified = vc WITH protect, noconstant("")
 DECLARE report_corrected = vc WITH protect, noconstant("")
 DECLARE report_verinproc = vc WITH protect, noconstant("")
 DECLARE report_corinproc = vc WITH protect, noconstant("")
 DECLARE report_status = vc WITH protect, noconstant("")
 DECLARE join_type = i2 WITH protect, noconstant(0)
 DECLARE criteria_exists = i2 WITH protect, noconstant(0)
 DECLARE report_level_search = i2 WITH protect, noconstant(0)
 DECLARE image_search_type_flag = i2 WITH protect, noconstant(0)
 DECLARE synoptic_query_flag = i2 WITH protect, noconstant(0)
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE select_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_value = i4 WITH protect, noconstant(0)
 DECLARE temp_idx = i2 WITH protect, noconstant(0)
 DECLARE or_string = c5 WITH protect, constant(" or (")
 DECLARE and_string = c5 WITH protect, constant(" and ")
 DECLARE between_string = c9 WITH protect, constant(" between ")
 DECLARE greater_than_string = c3 WITH protect, constant(" > ")
 DECLARE temp_string = vc WITH protect, noconstant("")
 DECLARE ccstrdate1 = vc WITH protect, noconstant("")
 DECLARE ccstrdate2 = vc WITH protect, noconstant("")
 SET acreturndate = cnvtdatetime(sysdate)
 SET val_dt_tm1 = cnvtdatetime(sysdate)
 SET val_dt_tm2 = cnvtdatetime(sysdate)
 DECLARE synopticstoryidcount = i4 WITH protect, noconstant(0)
 DECLARE synopticcclquery = vc WITH protect, noconstant("")
 DECLARE synopticunwantedsyncodepos = i4 WITH protect, noconstant(0)
 DECLARE synopticquerysize = i4 WITH protect, noconstant(0)
 DECLARE synopticquerycurpos = i4 WITH protect, noconstant(1)
 DECLARE synopticquerycodecopyendpos = i4 WITH protect, noconstant(0)
 DECLARE synopticquerycodecopytemp = vc WITH protect, noconstant("")
 DECLARE synoptictempstringinsertsize = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE ierrcode = i4 WITH protect, noconstant(0)
 DECLARE istatusblockcnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET ierrcode = error(serrmsg,1)
 SET reqinfo->commit_ind = 0
 SET reply->status_data.status = "F"
 CALL initresourcesecurity(1)
 SUBROUTINE (addtostatusblock(sstatus=vc,sopname=vc,sopstatus=vc,stargetobjname=vc,stargetobjvalue=vc
  ) =i2)
   IF (sstatus > "")
    SET reply->status_data.status = sstatus
   ENDIF
   SET istatusblockcnt += 1
   IF (istatusblockcnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,istatusblockcnt)
   ENDIF
   SET reply->status_data.subeventstatus[istatusblockcnt].operationname = sopname
   SET reply->status_data.subeventstatus[istatusblockcnt].operationstatus = sopstatus
   SET reply->status_data.subeventstatus[istatusblockcnt].targetobjectname = stargetobjname
   SET reply->status_data.subeventstatus[istatusblockcnt].targetobjectvalue = stargetobjvalue
   CALL echo(build("ScriptError:",sstatus,":",sopname,":",
     sopstatus,":",stargetobjname,":",stargetobjvalue))
 END ;Subroutine
 SUBROUTINE (checkforerror(sstatus=vc,sopname=vc,sopstatus=vc,stargetobjname=vc) =i2)
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode > 0)
    WHILE (ierrcode > 0)
     CALL addtostatusblock(sstatus,sopname,sopstatus,stargetobjname,serrmsg)
     SET ierrcode = error(serrmsg,0)
    ENDWHILE
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE apscalcdatetime(acstartdttm,acyr,acmonth,acday)
   SET acenddatetime = cnvtdatetime(sysdate)
   SET acfldiffdays = datetimediff(acenddatetime,acstartdttm)
   SET acdiffdays = (round(acfldiffdays,0)+ acday)
   SET acreturndate = cnvtagedatetime(cnvtint(acyr),cnvtint(acmonth),0,cnvtint(acdiffdays))
 END ;Subroutine
 DECLARE buildmultiwhere(bmworigwhere,bmwtablefield,bmwitemvalue) = c500
 SUBROUTINE buildmultiwhere(bmworigwhere,bmwtablefield,bmwitemvalue)
  IF (textlen(trim(bmworigwhere))=0)
   SET temp_string = build(trim(bmwtablefield)," in (",bmwitemvalue,")")
  ELSE
   SET bmworigwhere = substring(1,(textlen(trim(bmworigwhere)) - 1),bmworigwhere)
   SET temp_string = build(trim(bmworigwhere),",",bmwitemvalue,")")
  ENDIF
  RETURN(temp_string)
 END ;Subroutine
 DECLARE builddynwhere(bdwwhere,bdwtemp_param) = c500
 SUBROUTINE builddynwhere(bdwwhere,bdwtemp_param)
  IF (textlen(trim(bdwwhere))=0)
   SET temp_string = build("(",trim(bdwtemp_param),")")
  ELSE
   SET temp_string = concat(trim(bdwwhere),and_string,"(",trim(bdwtemp_param),")")
  ENDIF
  RETURN(temp_string)
 END ;Subroutine
 DECLARE buildmultidate(bmdorigwhere,bmdtablefield,bmdindex) = c500
 SUBROUTINE buildmultidate(bmdorigwhere,bmdtablefield,bmdindex)
   DECLARE ndateoption = i2 WITH private, noconstant(1)
   IF (bmdtablefield="p.abs_birth_dt_tm")
    SET ndateoption = 0
   ENDIF
   CASE (request->param_qual[bmdindex].date_type_flag)
    OF 2:
     SET temp_value = request->param_qual[bmdindex].beg_value_id
     SET val_dt_tm2 = cnvtagedatetime(0,0,0,temp_value)
     SET temp_value = request->param_qual[bmdindex].end_value_id
     SET val_dt_tm1 = cnvtagedatetime(0,0,0,temp_value)
    OF 3:
     SET temp_value = request->param_qual[bmdindex].beg_value_id
     SET val_dt_tm2 = cnvtagedatetime(0,temp_value,0,0)
     SET temp_value = request->param_qual[bmdindex].end_value_id
     SET val_dt_tm1 = cnvtagedatetime(0,temp_value,0,0)
    OF 4:
     SET temp_value = request->param_qual[bmdindex].beg_value_id
     SET val_dt_tm2 = cnvtagedatetime(temp_value,0,0,0)
     SET temp_value = request->param_qual[bmdindex].end_value_id
     SET val_dt_tm1 = cnvtagedatetime(temp_value,0,0,0)
   ENDCASE
   SET ccstrdate1 = build(format(cnvtdatetime(val_dt_tm1),"dd-mmm-yyyy;;d")," 00:00:00")
   SET ccstrdate2 = build(format(cnvtdatetime(val_dt_tm2),"dd-mmm-yyyy;;d")," 23:59:59")
   IF (textlen(trim(bmdorigwhere))=0)
    SET temp_string = concat("(",trim(bmdtablefield),between_string,"cnvtdatetimeutc(","'",
     trim(ccstrdate1),"',",build(ndateoption),")",and_string,
     "cnvtdatetimeutc(","'",trim(ccstrdate2),"',",build(ndateoption),
     "))")
   ELSE
    SET temp_string = concat(trim(bmdorigwhere),or_string,trim(bmdtablefield),between_string,
     "cnvtdatetimeutc(",
     "'",trim(ccstrdate1),"',",build(ndateoption),")",
     and_string,"cnvtdatetimeutc(","'",trim(ccstrdate2),"',",
     build(ndateoption),"))")
   ENDIF
   RETURN(temp_string)
 END ;Subroutine
 DECLARE builddateselection(bdstablefield,bdsindex) = c500
 SUBROUTINE builddateselection(bdstablefield,bdsindex)
   DECLARE ndateoption = i2 WITH private, noconstant(1)
   IF (bdstablefield="p.abs_birth_dt_tm")
    SET ndateoption = 0
   ENDIF
   CASE (request->param_qual[bdsindex].date_type_flag)
    OF 1:
     SET val_dt_tm1 = cnvtdatetime(request->param_qual[bdsindex].beg_value_dt_tm)
     SET val_dt_tm2 = cnvtdatetime(request->param_qual[bdsindex].end_value_dt_tm)
     SET ccstrdate1 = build(format(cnvtdatetime(val_dt_tm1),"dd-mmm-yyyy;;d")," 00:00:00")
     SET ccstrdate2 = build(format(cnvtdatetime(val_dt_tm2),"dd-mmm-yyyy;;d")," 23:59:59")
     SET temp_string = concat(trim(bdstablefield),between_string,"cnvtdatetimeutc(","'",trim(
       ccstrdate1),
      "',",build(ndateoption),")",and_string,"cnvtdatetimeutc(",
      "'",trim(ccstrdate2),"',",build(ndateoption),")")
    OF 2:
     SET temp_value = request->param_qual[bdsindex].beg_value_id
     SET val_dt_tm1 = cnvtagedatetime(0,0,0,temp_value)
     SET ccstrdate1 = build(format(cnvtdatetime(val_dt_tm1),"dd-mmm-yyyy;;d")," 00:00:00")
     SET temp_string = concat(trim(bdstablefield),greater_than_string,"cnvtdatetimeutc(","'",trim(
       ccstrdate1),
      "',",build(ndateoption),")")
    OF 3:
     SET temp_value = request->param_qual[bdsindex].beg_value_id
     SET val_dt_tm1 = cnvtagedatetime(0,temp_value,0,0)
     SET ccstrdate1 = build(format(cnvtdatetime(val_dt_tm1),"dd-mmm-yyyy;;d")," 00:00:00")
     SET temp_string = concat(trim(bdstablefield),greater_than_string,"cnvtdatetimeutc(","'",trim(
       ccstrdate1),
      "',",build(ndateoption),")")
    OF 4:
     SET temp_value = request->param_qual[bdsindex].beg_value_id
     SET val_dt_tm1 = cnvtagedatetime(temp_value,0,0,0)
     SET ccstrdate1 = build(format(cnvtdatetime(val_dt_tm1),"dd-mmm-yyyy;;d")," 00:00:00")
     SET temp_string = concat(trim(bdstablefield),greater_than_string,"cnvtdatetimeutc(","'",trim(
       ccstrdate1),
      "',",build(ndateoption),")")
   ENDCASE
   RETURN(temp_string)
 END ;Subroutine
 SUBROUTINE (buildselect(bstext=vc) =null)
   SET select_cnt += 1
   IF (mod(select_cnt,10)=1)
    SET stat = alterlist(reply->select_qual,(select_cnt+ 9))
   ENDIF
   SET reply->select_qual[select_cnt].text = trim(bstext)
 END ;Subroutine
 SUBROUTINE (populatetemprec(ptrdummy=i2) =null)
   CALL buildselect("accn_cnt = accn_cnt + 1")
   CALL buildselect("if (mod(accn_cnt, 10) = 1)")
   CALL buildselect("  stat = alterlist(temp->qual, accn_cnt + 9)")
   CALL buildselect("endif")
   CALL buildselect("temp->qual[accn_cnt].accession_nbr = pc.accession_nbr")
   IF (temp_indexes_cnt > 0)
    IF (curutc=1)
     CALL buildselect("temp->qual[accn_cnt].birth_dt_tm = p.abs_birth_dt_tm")
    ELSE
     CALL buildselect("temp->qual[accn_cnt].birth_dt_tm = p.birth_dt_tm")
    ENDIF
    CALL buildselect("temp->qual[accn_cnt].case_collect_dt_tm = pc.case_collect_dt_tm")
   ENDIF
 END ;Subroutine
 SUBROUTINE (parseselect(psdummy=i2) =null)
  SET stat = alterlist(reply->select_qual,select_cnt)
  FOR (y = 1 TO select_cnt)
    CALL parser(reply->select_qual[y].text)
  ENDFOR
 END ;Subroutine
#script
 SET stat = uar_get_meaning_by_codeset(23,"ACRNEMA",1,acr_nema_cd)
 IF (stat=1)
  CALL addtostatusblock("F","UAR","F","ACRNEMA","uar_get_meaning_by_codeset failed")
  GO TO script_error
 ENDIF
 SET stat = uar_get_meaning_by_codeset(48,"DELETED",1,deleted_status_cd)
 IF (stat=1)
  CALL addtostatusblock("F","UAR","F","DELETED","uar_get_meaning_by_codeset failed")
  GO TO script_error
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"CANCEL",1,canceled_status_cd)
 IF (stat=1)
  CALL addtostatusblock("F","UAR","F","CANCEL","uar_get_meaning_by_codeset failed")
  GO TO script_error
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"VERIFIED",1,verified_status_cd)
 IF (stat=1)
  CALL addtostatusblock("F","UAR","F","VERIFIED","uar_get_meaning_by_codeset failed")
  GO TO script_error
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"CORRECTED",1,corrected_status_cd)
 IF (stat=1)
  CALL addtostatusblock("F","UAR","F","CORRECTED","uar_get_meaning_by_codeset failed")
  GO TO script_error
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"CSIGNINPROC",1,ver_in_proc_status_cd)
 IF (stat=1)
  CALL addtostatusblock("F","UAR","F","CSIGNINPROC","uar_get_meaning_by_codeset failed")
  GO TO script_error
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"CORRECTINPRC",1,cor_in_proc_status_cd)
 IF (stat=1)
  CALL addtostatusblock("F","UAR","F","CORRECTINPRC","uar_get_meaning_by_codeset failed")
  GO TO script_error
 ENDIF
 SET cnt = size(request->param_qual,5)
 FOR (x = 1 TO cnt)
   CASE (trim(request->param_qual[x].param_name))
    OF "CASE_ACCPREFIX":
     SET temp_accprefix = buildmultiwhere(trim(temp_accprefix),"pc.prefix_id",cnvtstring(request->
       param_qual[x].beg_value_id,32,2))
    OF "CASE_CASETYPE":
     SET temp_casetype = buildmultiwhere(trim(temp_casetype),"pc.case_type_cd",cnvtstring(request->
       param_qual[x].beg_value_id,32,2))
    OF "CASE_COLDATE":
     SET temp_coldate = builddateselection("pc.case_collect_dt_tm",x)
    OF "CASE_IMAGEANYLEVEL":
     SET image_search_type_flag = 1
    OF "CASE_IMAGECASELEVEL":
     IF (((image_search_type_flag=3) OR (image_search_type_flag=4)) )
      SET image_search_type_flag = 4
     ELSEIF (((image_search_type_flag=5) OR (image_search_type_flag=6)) )
      SET image_search_type_flag = 6
     ELSE
      SET image_search_type_flag = 2
     ENDIF
    OF "CASE_IMAGETASKASSAY":
     IF (((image_search_type_flag=2) OR (image_search_type_flag=4)) )
      SET image_search_type_flag = 4
     ELSE
      SET image_search_type_flag = 3
     ENDIF
     SET image_code_cnt += 1
     IF (mod(image_code_cnt,10)=1)
      SET stat = alterlist(image_code->qual,(image_code_cnt+ 9))
     ENDIF
     SET image_code->qual[image_code_cnt].code = request->param_qual[x].beg_value_id
    OF "CASE_IMAGEUSEDEFAULT":
     IF (((image_search_type_flag=2) OR (image_search_type_flag=6)) )
      SET image_search_type_flag = 6
     ELSE
      SET image_search_type_flag = 5
     ENDIF
    OF "CASE_REQPHYS":
     SET temp_reqphys = buildmultiwhere(trim(temp_reqphys),"pc.requesting_physician_id",cnvtstring(
       request->param_qual[x].beg_value_id,32,2))
    OF "CASE_RESPPATH":
     SET temp_resppath = buildmultiwhere(trim(temp_resppath),"pc.responsible_pathologist_id",
      cnvtstring(request->param_qual[x].beg_value_id,32,2))
    OF "CASE_RESPRESI":
     SET temp_respresi = buildmultiwhere(trim(temp_respresi),"pc.responsible_resident_id",cnvtstring(
       request->param_qual[x].beg_value_id,32,2))
    OF "CASE_TASKASSAY":
     SET code_cnt += 1
     IF (mod(code_cnt,10)=1)
      SET stat = alterlist(code->qual,(code_cnt+ 9))
     ENDIF
     SET code->qual[code_cnt].code = request->param_qual[x].beg_value_id
    OF "CASE_VERDATE":
     SET temp_verdate = builddateselection("cr.status_dt_tm",x)
    OF "CASE_VERID":
     SET temp_verid = buildmultiwhere(trim(temp_verid),"cr.status_prsnl_id",cnvtstring(request->
       param_qual[x].beg_value_id,32,2))
    OF "CASE_CLIENT":
     SET temp_client = buildmultiwhere(trim(temp_client),"e.organization_id",cnvtstring(request->
       param_qual[x].beg_value_id,32,2))
    OF "CASE_SPECIMEN":
     SET temp_specimen = buildmultiwhere(trim(temp_specimen),"cs.specimen_cd",cnvtstring(request->
       param_qual[x].beg_value_id,32,2))
    OF "CASE_QUERYRESULT":
     SET temp_queryresult = buildmultiwhere(trim(temp_queryresult),"aqr.case_query_id",cnvtstring(
       request->param_qual[x].beg_value_id,32,2))
    OF "PATIENT_AGECOLDATE":
     SET temp_indexes_cnt += 1
     IF (mod(temp_indexes_cnt,10)=1)
      SET stat = alterlist(temp_indexes->qual,(temp_indexes_cnt+ 9))
     ENDIF
     SET temp_indexes->qual[temp_indexes_cnt].i = x
    OF "PATIENT_AGECURDATE":
     IF (curutc=1)
      SET temp_agecurdate = buildmultidate(trim(temp_agecurdate),"p.abs_birth_dt_tm",x)
     ELSE
      SET temp_agecurdate = buildmultidate(trim(temp_agecurdate),"p.birth_dt_tm",x)
     ENDIF
    OF "PATIENT_BIRTHDATE":
     IF (curutc=1)
      SET temp_birthdate = builddateselection("p.abs_birth_dt_tm",x)
     ELSE
      SET temp_birthdate = builddateselection("p.birth_dt_tm",x)
     ENDIF
    OF "PATIENT_ETHNICGROUP":
     SET temp_ethnicgroup = buildmultiwhere(trim(temp_ethnicgroup),"pcvr2.code_value",cnvtstring(
       request->param_qual[x].beg_value_id,32,2))
    OF "PATIENT_GENDER":
     SET temp_gender = buildmultiwhere(trim(temp_gender),"p.sex_cd",cnvtstring(request->param_qual[x]
       .beg_value_id,32,2))
    OF "PATIENT_MILITARY":
     SET temp_military = buildmultiwhere(trim(temp_military),"p.vet_military_status_cd",cnvtstring(
       request->param_qual[x].beg_value_id,32,2))
    OF "PATIENT_RACE":
     SET temp_race = buildmultiwhere(trim(temp_race),"pcvr1.code_value",cnvtstring(request->
       param_qual[x].beg_value_id,32,2))
    OF "PATIENT_SPECIES":
     SET temp_species = buildmultiwhere(trim(temp_species),"p.species_cd",cnvtstring(request->
       param_qual[x].beg_value_id,32,2))
    OF "CRITERIA_DIAGCODE1":
     SET criteria_exists = 1
    OF "CRITERIA_DIAGCODE2":
     SET criteria_exists = 1
    OF "CRITERIA_DIAGCODE3":
     SET criteria_exists = 1
    OF "CRITERIA_DIAGCODE4":
     SET criteria_exists = 1
    OF "CRITERIA_DIAGCODE5":
     SET criteria_exists = 1
    OF "CRITERIA_FREETEXT":
     SET criteria_exists = 1
    OF "CRITERIA_INTERNAL":
     SET criteria_exists = 1
    OF "CRITERIA_SYNOPTIC":
     SET synoptic_query_flag = request->param_qual[x].synoptic_query_flag
     SET synopticcclquery = request->param_qual[x].synoptic_ccl_query
   ENDCASE
 ENDFOR
 IF (textlen(trim(temp_accprefix))=0)
  SET temp_accprefix = "pc.prefix_id != 0.0"
 ENDIF
 SELECT INTO "nl:"
  FROM ap_prefix pc
  PLAN (pc
   WHERE parser(temp_accprefix))
  DETAIL
   service_resource_cd = pc.service_resource_cd
   IF (isresourceviewable(service_resource_cd)=true)
    IF (textlen(trim(temp_prefixids))=0)
     temp_prefixids = cnvtstring(pc.prefix_id,32,2)
    ELSE
     temp_prefixids = build(trim(temp_prefixids),",",cnvtstring(pc.prefix_id,32,2))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  IF (getresourcesecuritystatus(0) != "S")
   SET istatusblockcnt += 1
   SET reply->status_data.status = getresourcesecuritystatus(0)
   CALL populateressecstatusblock(1)
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET temp_accprefix = ""
 SET temp_accprefix = buildmultiwhere(trim(temp_accprefix),"pc.prefix_id",temp_prefixids)
 SET reply->call_qualify_on_ces = criteria_exists
 SET stat = alterlist(temp_indexes->qual,temp_indexes_cnt)
 SET stat = alterlist(code->qual,code_cnt)
 SET code_set_value = uar_get_code_set(code->qual[1].code)
 IF (code_set_value=catalog_code_set)
  SET report_qual_cnt = code_cnt
  SET stat = alterlist(code->report_qual,report_qual_cnt)
  FOR (x = 1 TO report_qual_cnt)
    SET code->report_qual[x].catalog_cd = code->qual[x].code
  ENDFOR
  SELECT INTO "nl:"
   ptr.task_assay_cd
   FROM profile_task_r ptr,
    (dummyt d  WITH seq = value(code_cnt))
   PLAN (d)
    JOIN (ptr
    WHERE (ptr.catalog_cd=code->report_qual[d.seq].catalog_cd)
     AND ptr.active_ind=1
     AND cnvtdatetime(sysdate) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
   DETAIL
    task_assay_cnt += 1
    IF (mod(task_assay_cnt,10)=1)
     stat = alterlist(code->task_assay_qual,(task_assay_cnt+ 9))
    ENDIF
    code->task_assay_qual[task_assay_cnt].task_assay_cd = ptr.task_assay_cd
   WITH nocounter
  ;end select
  SET stat = alterlist(code->task_assay_qual,task_assay_cnt)
 ELSE
  SET task_assay_cnt = code_cnt
  SET stat = alterlist(code->task_assay_qual,task_assay_cnt)
  FOR (x = 1 TO task_assay_cnt)
    SET code->task_assay_qual[x].task_assay_cd = code->qual[x].code
  ENDFOR
  SELECT INTO "nl:"
   ptr.catalog_cd
   FROM (dummyt d  WITH seq = value(task_assay_cnt)),
    profile_task_r ptr
   PLAN (d)
    JOIN (ptr
    WHERE (ptr.task_assay_cd=code->task_assay_qual[d.seq].task_assay_cd)
     AND ptr.active_ind=1)
   DETAIL
    report_qual_cnt += 1
    IF (mod(report_qual_cnt,10)=1)
     stat = alterlist(code->report_qual,(report_qual_cnt+ 9))
    ENDIF
    code->report_qual[report_qual_cnt].catalog_cd = ptr.catalog_cd
   WITH nocounter
  ;end select
  SET stat = alterlist(code->report_qual,report_qual_cnt)
 ENDIF
 IF (image_code_cnt != 0)
  SET stat = alterlist(image_code->qual,image_code_cnt)
  SET image_code_set = uar_get_code_set(image_code->qual[1].code)
  IF (image_code_set=catalog_code_set)
   SET image_report_qual_cnt = image_code_cnt
   SET stat = alterlist(image_code->report_qual,image_report_qual_cnt)
   FOR (x = 1 TO image_report_qual_cnt)
     SET image_code->report_qual[x].catalog_cd = image_code->qual[x].code
   ENDFOR
   SELECT INTO "nl:"
    ptr.task_assay_cd
    FROM profile_task_r ptr,
     (dummyt d  WITH seq = value(image_report_qual_cnt))
    PLAN (d)
     JOIN (ptr
     WHERE (ptr.catalog_cd=image_code->report_qual[d.seq].catalog_cd)
      AND ptr.active_ind=1)
    DETAIL
     task_assay_image_cnt += 1
     IF (mod(task_assay_image_cnt,10)=1)
      stat = alterlist(image_code->task_assay_qual,(task_assay_image_cnt+ 9))
     ENDIF
     image_code->task_assay_qual[task_assay_image_cnt].task_assay_cd = ptr.task_assay_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(image_code->task_assay_qual,task_assay_image_cnt)
  ELSE
   SET task_assay_image_cnt = image_code_cnt
   SET stat = alterlist(image_code->task_assay_qual,task_assay_image_cnt)
   FOR (x = 1 TO task_assay_image_cnt)
     SET image_code->task_assay_qual[x].task_assay_cd = image_code->qual[x].code
   ENDFOR
   SELECT INTO "nl:"
    ptr.catalog_cd
    FROM (dummyt d  WITH seq = value(task_assay_image_cnt)),
     profile_task_r ptr
    PLAN (d)
     JOIN (ptr
     WHERE (ptr.task_assay_cd=image_code->task_assay_qual[d.seq].task_assay_cd)
      AND ptr.active_ind=1)
    DETAIL
     image_report_qual_cnt += 1
     IF (mod(image_report_qual_cnt,10)=1)
      stat = alterlist(image_code->report_qual,(image_report_qual_cnt+ 9))
     ENDIF
     image_code->report_qual[image_report_qual_cnt].catalog_cd = ptr.catalog_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(image_code->report_qual,image_report_qual_cnt)
  ENDIF
 ENDIF
 IF (((image_search_type_flag=5) OR (image_search_type_flag=6)) )
  SET task_assay_image_cnt = task_assay_cnt
  SET stat = alterlist(image_code->task_assay_qual,task_assay_cnt)
  FOR (x = 1 TO task_assay_cnt)
    SET image_code->task_assay_qual[x].task_assay_cd = code->task_assay_qual[x].task_assay_cd
  ENDFOR
 ENDIF
 IF (textlen(trim(temp_accprefix)) != 0)
  SET case_where = builddynwhere(case_where,temp_accprefix)
 ENDIF
 IF (textlen(trim(temp_casetype)) != 0)
  SET case_where = builddynwhere(case_where,temp_casetype)
 ENDIF
 IF (textlen(trim(temp_reqphys)) != 0)
  SET case_where = builddynwhere(case_where,temp_reqphys)
 ENDIF
 IF (textlen(trim(temp_resppath)) != 0)
  SET case_where = builddynwhere(case_where,temp_resppath)
 ENDIF
 IF (textlen(trim(temp_respresi)) != 0)
  SET case_where = builddynwhere(case_where,temp_respresi)
 ENDIF
 IF (textlen(trim(temp_coldate)) != 0)
  SET case_where = builddynwhere(case_where,temp_coldate)
 ENDIF
 IF (textlen(trim(temp_ethnicgroup)) != 0)
  SET person_ethnicgrp_where = builddynwhere(person_ethnicgrp_where,temp_ethnicgroup)
 ENDIF
 IF (textlen(trim(temp_gender)) != 0)
  SET person_where = builddynwhere(person_where,temp_gender)
 ENDIF
 IF (textlen(trim(temp_military)) != 0)
  SET person_where = builddynwhere(person_where,temp_military)
 ENDIF
 IF (textlen(trim(temp_race)) != 0)
  SET person_race_where = builddynwhere(person_race_where,temp_race)
 ENDIF
 IF (textlen(trim(temp_species)) != 0)
  SET person_where = builddynwhere(person_where,temp_species)
 ENDIF
 IF (textlen(trim(temp_birthdate)) != 0)
  SET person_where = builddynwhere(person_where,temp_birthdate)
 ENDIF
 IF (textlen(trim(temp_agecurdate)) != 0)
  SET person_where = builddynwhere(person_where,temp_agecurdate)
 ENDIF
 IF (temp_indexes_cnt > 0)
  SET person_where = builddynwhere(person_where,"1 = 1")
 ENDIF
 IF (textlen(trim(person_where)) != 0)
  SET person_ind = 1
 ENDIF
 IF (textlen(trim(person_race_where)) != 0)
  SET person_ind = 1
  SET person_race_ind = 1
 ENDIF
 IF (textlen(trim(person_ethnicgrp_where)) != 0)
  SET person_ind = 1
  SET person_ethnicgrp_ind = 1
 ENDIF
 SET report_where = builddynwhere(report_where,join_cr)
 SET report_cancel = concat("cr.status_cd != ",cnvtstring(canceled_status_cd,32,2))
 IF (textlen(trim(temp_verdate))=0
  AND textlen(trim(temp_verid))=0)
  SET report_where = builddynwhere(report_where,report_cancel)
 ELSE
  SET report_status = buildmultiwhere(report_status,"cr.status_cd",verified_status_cd)
  SET report_status = buildmultiwhere(report_status,"cr.status_cd",corrected_status_cd)
  SET report_status = buildmultiwhere(report_status,"cr.status_cd",ver_in_proc_status_cd)
  SET report_status = buildmultiwhere(report_status,"cr.status_cd",cor_in_proc_status_cd)
  SET report_where = builddynwhere(report_where,report_status)
 ENDIF
 IF (textlen(trim(temp_verid)) != 0)
  SET report_where = builddynwhere(report_where,temp_verid)
 ENDIF
 IF (textlen(trim(temp_verdate)) != 0)
  SET report_where = builddynwhere(report_where,temp_verdate)
 ENDIF
 CASE (image_search_type_flag)
  OF 1:
   SET report_where = builddynwhere(report_where,pc_image_ind_or_cr_image_ind)
  OF 2:
   SET case_where = builddynwhere(case_where,pc_image_ind)
  OF 3:
   IF (report_qual_cnt=image_report_qual_cnt)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(report_qual_cnt)),
      (dummyt d2  WITH seq = value(image_report_qual_cnt))
     PLAN (d1)
      JOIN (d2
      WHERE (code->report_qual[d1.seq].catalog_cd=image_code->report_qual[d2.seq].catalog_cd))
     WITH nocounter
    ;end select
   ENDIF
   IF (curqual=report_qual_cnt)
    SET report_where = builddynwhere(report_where,cr_image_ind)
   ENDIF
  OF 4:
   IF (report_qual_cnt=image_report_qual_cnt)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(report_qual_cnt)),
      (dummyt d2  WITH seq = value(image_report_qual_cnt))
     PLAN (d1)
      JOIN (d2
      WHERE (code->report_qual[d1.seq].catalog_cd=image_code->report_qual[d2.seq].catalog_cd))
     WITH nocounter
    ;end select
   ENDIF
   IF (curqual=report_qual_cnt)
    SET report_where = builddynwhere(report_where,cr_image_ind)
   ENDIF
   SET case_where = builddynwhere(case_where,pc_image_ind)
  OF 5:
   SET report_where = builddynwhere(report_where,cr_image_ind)
  OF 6:
   SET report_where = builddynwhere(report_where,cr_image_ind)
   SET case_where = builddynwhere(case_where,pc_image_ind)
 ENDCASE
 IF (textlen(trim(case_where)) != 0)
  SET pathology_case_ind = 1
 ENDIF
 IF (textlen(trim(temp_queryresult)) != 0)
  SET ap_query_result_ind = 1
 ENDIF
 IF (textlen(trim(temp_client)) != 0)
  SET encounter_ind = 1
 ENDIF
 IF (textlen(trim(temp_specimen)) != 0)
  SET case_specimen_ind = 1
 ENDIF
 CALL buildselect("select into 'nl:'")
 CALL buildselect("pc.case_id")
 IF (person_ind=1)
  CALL buildselect(",p.person_id")
 ENDIF
 CALL buildselect("from")
 IF (ap_query_result_ind=1)
  CALL buildselect("ap_query_result aqr,")
 ENDIF
 CALL buildselect("pathology_case pc")
 IF (person_ind=1)
  CALL buildselect(",person p")
 ENDIF
 IF (person_race_ind=1)
  CALL buildselect(",person_code_value_r pcvr1")
 ENDIF
 IF (person_ethnicgrp_ind=1)
  CALL buildselect(",person_code_value_r pcvr2")
 ENDIF
 IF (case_specimen_ind=1)
  CALL buildselect(",case_specimen cs")
 ENDIF
 IF (encounter_ind=1)
  CALL buildselect(",encounter e")
 ENDIF
 CALL buildselect(",case_report cr")
 IF (ap_query_result_ind=1)
  CALL buildselect("plan aqr where")
  CALL buildselect(temp_queryresult)
  CALL buildselect("join pc where")
  CALL buildselect("(pc.accession_nbr = aqr.accession_nbr)")
  IF (pathology_case_ind=1)
   CALL buildselect("and")
   CALL buildselect(case_where)
  ENDIF
 ELSE
  CALL buildselect("plan pc")
  IF (pathology_case_ind=1)
   CALL buildselect("where")
   CALL buildselect(case_where)
  ENDIF
 ENDIF
 IF (person_ind=1)
  CALL buildselect("join p where")
  CALL buildselect("pc.person_id = p.person_id")
  IF (textlen(trim(person_where)) != 0)
   CALL buildselect("and ")
   CALL buildselect(person_where)
  ENDIF
 ENDIF
 IF (person_race_ind=1)
  CALL buildselect("join pcvr1 where")
  CALL buildselect(person_race_where)
  CALL buildselect("and (pcvr1.person_id = p.person_id)")
 ENDIF
 IF (person_ethnicgrp_ind=1)
  CALL buildselect("join pcvr2 where")
  CALL buildselect(person_ethnicgrp_where)
  CALL buildselect("and (pcvr2.person_id = p.person_id)")
 ENDIF
 IF (case_specimen_ind=1)
  CALL buildselect("join cs where")
  CALL buildselect(temp_specimen)
  CALL buildselect("and (pc.case_id = cs.case_id)")
 ENDIF
 IF (encounter_ind=1)
  CALL buildselect("join e where")
  CALL buildselect(temp_client)
  CALL buildselect("and (pc.encntr_id = e.encntr_id)")
 ENDIF
 CALL buildselect("join cr where")
 CALL buildselect(report_where)
 CALL buildselect("order pc.case_id")
 CALL buildselect(",cr.report_id")
 CALL buildselect("head report")
 CALL buildselect("  max_rpt_cnt = 0")
 CALL buildselect("head pc.case_id")
 CALL buildselect("accn_cnt = accn_cnt + 1")
 CALL buildselect("if (mod(accn_cnt, 10) = 1)")
 CALL buildselect("  stat = alterlist(temp->qual, accn_cnt + 9)")
 CALL buildselect("endif")
 CALL buildselect("temp->qual[accn_cnt].accession_nbr = pc.accession_nbr")
 IF (temp_indexes_cnt > 0)
  IF (curutc=1)
   CALL buildselect("temp->qual[accn_cnt].birth_dt_tm = p.abs_birth_dt_tm")
  ELSE
   CALL buildselect("temp->qual[accn_cnt].birth_dt_tm = p.birth_dt_tm")
  ENDIF
  CALL buildselect("temp->qual[accn_cnt].case_collect_dt_tm = pc.case_collect_dt_tm")
 ENDIF
 CALL buildselect("stat = alterlist(temp->qual[accn_cnt]->age_check_qual, temp_indexes_cnt)")
 CALL buildselect("for (temp_idx = 1 to temp_indexes_cnt)")
 CALL buildselect("  case (request->param_qual[temp_indexes->qual[temp_idx].i].date_type_flag)")
 CALL buildselect("      of 2:")
 CALL buildselect("       call ApsCalcDateTime(temp->qual[accn_cnt].case_collect_dt_tm, 0, 0,")
 CALL buildselect(
  "                             request->param_qual[temp_indexes->qual[temp_idx].i].beg_value_id)")
 CALL buildselect("       val_dt_tm2 = ACReturnDate")
 CALL buildselect("       call ApsCalcDateTime(temp->qual[accn_cnt].case_collect_dt_tm, 0, 0,")
 CALL buildselect(
  "                            request->param_qual[temp_indexes->qual[temp_idx].i].end_value_id)")
 CALL buildselect("       val_dt_tm1 = ACReturnDate")
 CALL buildselect("      of 3:")
 CALL buildselect("       call ApsCalcDateTime(temp->qual[accn_cnt].case_collect_dt_tm, 0,")
 CALL buildselect(
  "                             request->param_qual[temp_indexes->qual[temp_idx].i].beg_value_id, 0)"
  )
 CALL buildselect("       val_dt_tm2 = ACReturnDate")
 CALL buildselect("       call ApsCalcDateTime(temp->qual[accn_cnt].case_collect_dt_tm, 0,")
 CALL buildselect(
  "                             request->param_qual[temp_indexes->qual[temp_idx].i].end_value_id, 0)"
  )
 CALL buildselect("       val_dt_tm1 = ACReturnDate")
 CALL buildselect("      of 4:")
 CALL buildselect("       call ApsCalcDateTime(temp->qual[accn_cnt].case_collect_dt_tm,")
 CALL buildselect(
  "                             request->param_qual[temp_indexes->qual[temp_idx].i].beg_value_id, 0, 0)"
  )
 CALL buildselect("       val_dt_tm2 = ACReturnDate")
 CALL buildselect("       call ApsCalcDateTime(temp->qual[accn_cnt].case_collect_dt_tm,")
 CALL buildselect(
  "                            request->param_qual[temp_indexes->qual[temp_idx].i].end_value_id, 0, 0)"
  )
 CALL buildselect("       val_dt_tm1 = ACReturnDate")
 CALL buildselect("  endcase")
 CALL buildselect("  temp->qual[accn_cnt].age_check_qual[temp_idx].beg_date_str = ")
 CALL buildselect(
  "               build(format(cnvtdatetime(val_dt_tm1), 'dd-mmm-yyyy;;d'), ' 00:00:00')")
 CALL buildselect("  temp->qual[accn_cnt].age_check_qual[temp_idx].end_date_str = ")
 CALL buildselect(
  "               build(format(cnvtdatetime(val_dt_tm2), 'dd-mmm-yyyy;;d'), ' 23:59:59')")
 CALL buildselect("  endfor")
 CALL buildselect("  rpt_cnt = 0")
 CALL buildselect("head cr.report_id")
 CALL buildselect("  rpt_cnt = rpt_cnt + 1")
 CALL buildselect("  if (mod(rpt_cnt, 10) = 1)")
 CALL buildselect("     stat = alterlist(temp->qual[accn_cnt]->report_qual, rpt_cnt + 9)")
 CALL buildselect("  endif")
 CALL buildselect("  if (rpt_cnt > max_rpt_cnt)")
 CALL buildselect("    max_rpt_cnt = rpt_cnt")
 CALL buildselect("  endif")
 CALL buildselect("  temp->qual[accn_cnt]->report_qual[rpt_cnt].report_id = cr.report_id")
 CALL buildselect("  temp->qual[accn_cnt]->report_qual[rpt_cnt].event_id = cr.event_id")
 CALL buildselect("  if (cr.status_cd in (verified_status_cd, corrected_status_cd))")
 CALL buildselect("    temp->qual[accn_cnt]->report_qual[rpt_cnt].verify_ind = 1")
 CALL buildselect("  else")
 CALL buildselect("    temp->qual[accn_cnt]->report_qual[rpt_cnt].verify_ind = 0")
 CALL buildselect("  endif")
 CALL buildselect("foot cr.report_id")
 CALL buildselect("row + 0")
 CALL buildselect("foot pc.case_id")
 CALL buildselect("stat = alterlist(temp->qual[accn_cnt].report_qual, rpt_cnt)")
 CALL buildselect("foot report")
 CALL buildselect("stat = alterlist(temp->qual, accn_cnt)")
 CALL buildselect("with nocounter go")
 CALL parseselect(0)
 IF (checkforerror("F","SELECT","F","PATHOLOGY_CASE")=1)
  GO TO script_error
 ENDIF
 IF (accn_cnt=0)
  GO TO exit_script
 ENDIF
 IF (temp_indexes_cnt=0)
  SET age_check_cnt = 1
 ELSE
  SET age_check_cnt = temp_indexes_cnt
 ENDIF
 IF (temp_indexes_cnt=0)
  SET age_check = "1=1"
 ELSE
  SET age_check = concat("temp->qual[d.seq].birth_dt_tm between ",
   "cnvtdatetimeutc(temp->qual[d.seq].age_check_qual[d1.seq].beg_date_str,","1-curutc) and ",
   "cnvtdatetimeutc(temp->qual[d.seq].age_check_qual[d1.seq].end_date_str,","1-curutc)")
 ENDIF
 IF (image_search_type_flag <= 2)
  SET curalias qualified_cases reply->qual[reply_cnt]
 ELSE
  SET curalias qualified_cases accession->qual[reply_cnt]
 ENDIF
 SELECT INTO "nl:"
  ce.event_id
  FROM (dummyt d  WITH seq = value(accn_cnt)),
   (dummyt d1  WITH seq = value(age_check_cnt)),
   (dummyt d2  WITH seq = value(max_rpt_cnt)),
   (dummyt d3  WITH seq = value(task_assay_cnt)),
   clinical_event ce
  PLAN (d)
   JOIN (d1
   WHERE parser(age_check))
   JOIN (d2
   WHERE d2.seq <= size(temp->qual[d.seq].report_qual,5))
   JOIN (ce
   WHERE (ce.parent_event_id=temp->qual[d.seq].report_qual[d2.seq].event_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.record_status_cd != deleted_status_cd)
   JOIN (d3
   WHERE (ce.task_assay_cd=code->task_assay_qual[d3.seq].task_assay_cd))
  ORDER BY d.seq, d2.seq
  HEAD REPORT
   reply_cnt = 0, max_rpt_cnt = 0
  HEAD d.seq
   reply_cnt += 1
   IF (mod(reply_cnt,10)=1)
    IF (image_search_type_flag <= 2)
     stat = alterlist(reply->qual,(reply_cnt+ 9))
    ELSE
     stat = alterlist(accession->qual,(reply_cnt+ 9))
    ENDIF
   ENDIF
   qualified_cases->accession_nbr = temp->qual[d.seq].accession_nbr, rpt_cnt = 0
  HEAD d2.seq
   rpt_cnt += 1
   IF (mod(rpt_cnt,10)=1)
    stat = alterlist(qualified_cases->report_qual,(rpt_cnt+ 9))
   ENDIF
   qualified_cases->report_qual[rpt_cnt].event_id = temp->qual[d.seq].report_qual[d2.seq].event_id,
   qualified_cases->report_qual[rpt_cnt].report_id = temp->qual[d.seq].report_qual[d2.seq].report_id,
   qualified_cases->report_qual[rpt_cnt].verify_ind = temp->qual[d.seq].report_qual[d2.seq].
   verify_ind
   IF (reply_cnt > max_rpt_cnt)
    max_rpt_cnt = reply_cnt
   ENDIF
  FOOT  d2.seq
   row + 0
  FOOT  d.seq
   stat = alterlist(qualified_cases->report_qual,rpt_cnt)
  FOOT REPORT
   IF (image_search_type_flag <= 2)
    stat = alterlist(reply->qual,reply_cnt)
   ELSE
    stat = alterlist(accession->qual,reply_cnt)
   ENDIF
  WITH nocounter
 ;end select
 SET curalias qualified_cases off
 IF (checkforerror("F","SELECT","F","CLINICAL_EVENT")=1)
  GO TO script_error
 ENDIF
 IF (image_search_type_flag <= 2)
  GO TO synoptic_query
 ENDIF
 IF (reply_cnt=0)
  GO TO exit_script
 ENDIF
 SET accn_cnt = reply_cnt
 SET reply_cnt = 0
 SELECT INTO "nl:"
  rdi.report_id
  FROM (dummyt d  WITH seq = value(accn_cnt)),
   (dummyt d1  WITH seq = value(max_rpt_cnt)),
   (dummyt d2  WITH seq = value(task_assay_image_cnt)),
   report_detail_image rdi,
   blob_reference br
  PLAN (d)
   JOIN (d1
   WHERE d1.seq <= size(accession->qual[d.seq].report_qual,5))
   JOIN (rdi
   WHERE (rdi.report_id=accession->qual[d.seq].report_qual[d1.seq].report_id)
    AND (accession->qual[d.seq].report_qual[d1.seq].verify_ind=0))
   JOIN (d2
   WHERE (rdi.task_assay_cd=image_code->task_assay_qual[d2.seq].task_assay_cd))
   JOIN (br
   WHERE br.parent_entity_name="REPORT_DETAIL_IMAGE"
    AND br.parent_entity_id=rdi.report_detail_id)
  ORDER BY d.seq
  HEAD d.seq
   reply_cnt += 1
   IF (mod(reply_cnt,10)=1)
    stat = alterlist(reply->qual,(reply_cnt+ 9))
   ENDIF
   reply->qual[reply_cnt].accession_nbr = accession->qual[d.seq].accession_nbr, accession->qual[d.seq
   ].qualify_ind = 1
  WITH nocounter
 ;end select
 IF (checkforerror("F","SELECT","F","REPORT_DETAIL_IMAGE")=1)
  GO TO script_error
 ENDIF
 SELECT INTO "nl:"
  ce.event_id
  FROM (dummyt d  WITH seq = value(accn_cnt)),
   (dummyt d1  WITH seq = value(max_rpt_cnt)),
   (dummyt d2  WITH seq = value(task_assay_image_cnt)),
   clinical_event ce,
   clinical_event ce2,
   ce_blob_result cbr
  PLAN (d
   WHERE (accession->qual[d.seq].qualify_ind=0))
   JOIN (d1
   WHERE d1.seq <= size(accession->qual[d.seq].report_qual,5))
   JOIN (ce
   WHERE (ce.parent_event_id=accession->qual[d.seq].report_qual[d1.seq].event_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.record_status_cd != deleted_status_cd
    AND (accession->qual[d.seq].report_qual[d1.seq].verify_ind=1))
   JOIN (d2
   WHERE (ce.task_assay_cd=image_code->task_assay_qual[d2.seq].task_assay_cd))
   JOIN (ce2
   WHERE ce2.parent_event_id=ce.event_id
    AND ce2.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce2.record_status_cd != deleted_status_cd)
   JOIN (cbr
   WHERE cbr.event_id=ce2.event_id
    AND cbr.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND cbr.format_cd=acr_nema_cd)
  ORDER BY d.seq
  HEAD d.seq
   reply_cnt += 1
   IF (mod(reply_cnt,10)=1)
    stat = alterlist(reply->qual,(reply_cnt+ 9))
   ENDIF
   reply->qual[reply_cnt].accession_nbr = accession->qual[d.seq].accession_nbr, accession->qual[d.seq
   ].qualify_ind = 1
  WITH nocounter
 ;end select
 IF (checkforerror("F","SELECT","F","CLINICAL_EVENT")=1)
  GO TO script_error
 ELSE
  SET stat = alterlist(reply->qual,reply_cnt)
 ENDIF
#synoptic_query
 SET synopticquerysize = size(trim(synopticcclquery),1)
 IF (reply_cnt > 0
  AND synopticquerysize > 0)
  SET stat = moverec(reply->qual,accession->qual)
  SET accn_cnt = reply_cnt
  SET reply_cnt = 0
  SET stat = alterlist(reply->qual,0)
  SET synopticcclquery = replace(synopticcclquery,"SELECT","SELECT INTO 'NL:'",1)
  SET synopticunwantedsyncodepos = findstring("AND CE.RESULT_STATUS_CD",synopticcclquery,1,1)
  SET synopticcclquery = substring(1,(synopticunwantedsyncodepos - 1),synopticcclquery)
  SET synopticcclquery = replace(synopticcclquery,"H.SCR_TERM_HIER_ID = (","((H.SCR_TERM_HIER_ID = (",
   0)
  SET synopticquerycurpos = 1
  SET synopticquerysize = size(synopticcclquery,1)
  WHILE (synopticquerycurpos < synopticquerysize)
   SET synopticquerycurpos = findstring(
    "SELECT H.SCR_TERM_HIER_ID FROM SCR_TERM_HIER H, SCR_PATTERN P",synopticcclquery,(
    synopticquerycurpos - 1),0)
   IF (synopticquerycurpos > 0)
    SET synopticquerycodecopyendpos = findstring('P.CKI_SOURCE = "',synopticcclquery,
     synopticquerycurpos,0)
    SET synopticquerycodecopyendpos = findstring('"',synopticcclquery,(synopticquerycodecopyendpos+
     size('P.CKI_SOURCE = "',1)),0)
    IF (synopticquerycodecopyendpos > 0)
     SET synopticquerycodecopytemp = substring(synopticquerycurpos,((synopticquerycodecopyendpos+ 1)
       - synopticquerycurpos),synopticcclquery)
     SET synopticquerycodecopytemp = replace(synopticquerycodecopytemp,"SELECT H.SCR_TERM_HIER_ID",
      "SELECT t.concept_cki")
     SET synopticquerycodecopytemp = replace(synopticquerycodecopytemp,
      "FROM SCR_TERM_HIER H, SCR_PATTERN P","FROM SCR_TERM_HIER H, SCR_PATTERN P, scd_term t")
     SET synopticquerycodecopytemp = concat(")) OR (t.concept_cki = (",synopticquerycodecopytemp,
      ' and t.scr_term_hier_id = h.scr_term_hier_id and t.concept_cki > " "))')
     SET synopticcclquery = concat(substring(1,synopticquerycodecopyendpos,synopticcclquery)," ",
      synopticquerycodecopytemp,substring((synopticquerycodecopyendpos+ 1),size(synopticcclquery,1),
       synopticcclquery))
    ENDIF
    SET synopticquerysize = size(synopticcclquery,1)
    SET synopticquerycurpos = (synopticquerycodecopyendpos+ synoptictempstringinsertsize)
   ELSE
    SET synopticquerycurpos = synopticquerysize
   ENDIF
  ENDWHILE
  IF (findstring("CNVTREAL",synopticcclquery) > 0)
   SET synopticcclquery = replace(synopticcclquery,"CNVTREAL","cclsql_to_number",0)
  ENDIF
  IF (findstring("CNVTINT",synopticcclquery) > 0)
   SET synopticcclquery = replace(synopticcclquery,"CNVTINT","cclsql_to_number",0)
  ENDIF
  SET reply->synoptic_query = synopticcclquery
  CALL parser(synopticcclquery)
  CALL parser("order by s.scd_story_id")
  CALL parser("head s.scd_story_id")
  CALL parser(" synopticStoryIDCount = synopticStoryIDCount + 1")
  CALL parser(" if (mod(synopticStoryIDCount, 10) = 1)")
  CALL parser("   stat = alterlist(scd_stories->qual, synopticStoryIDCount + 9)")
  CALL parser(" endif")
  CALL parser(" scd_stories->qual[synopticStoryIDCount].scd_story_id = s.scd_story_id")
  CALL parser("with nocounter")
  CALL parser(" go")
  IF (checkforerror("F","SELECT","F","SYNOPTIC CCL QUERY")=1)
   GO TO script_error
  ELSE
   SET stat = alterlist(scd_stories->qual,synopticstoryidcount)
  ENDIF
  IF (synopticstoryidcount > 0)
   SELECT INTO "nl:"
    acsw.scd_story_id
    FROM (dummyt d  WITH seq = value(accn_cnt)),
     (dummyt d1  WITH seq = value(max_rpt_cnt)),
     case_report cr,
     ap_case_synoptic_ws acsw,
     (dummyt d2  WITH seq = value(synopticstoryidcount))
    PLAN (d)
     JOIN (d1
     WHERE d1.seq <= size(accession->qual[d.seq].report_qual,5))
     JOIN (cr
     WHERE (cr.report_id=accession->qual[d.seq].report_qual[d1.seq].report_id)
      AND cr.status_cd IN (verified_status_cd, corrected_status_cd))
     JOIN (acsw
     WHERE acsw.report_id=cr.report_id
      AND acsw.status_flag=2)
     JOIN (d2
     WHERE (scd_stories->qual[d2.seq].scd_story_id=acsw.scd_story_id))
    ORDER BY d.seq
    HEAD d.seq
     reply_cnt += 1
     IF (mod(reply_cnt,10)=1)
      stat = alterlist(reply->qual,(reply_cnt+ 9))
     ENDIF
     stat = movereclist(accession->qual,reply->qual,d.seq,reply_cnt,1,
      false)
    WITH nocounter
   ;end select
   IF (checkforerror("F","SELECT","F","AP_CASE_SYNOPTIC_WS")=1)
    GO TO script_error
   ELSE
    SET stat = alterlist(reply->qual,reply_cnt)
   ENDIF
  ENDIF
 ENDIF
#exit_script
 IF (size(reply->qual,5) <= 0)
  CALL addtostatusblock("Z","SELECT","Z","PATHOLOGY_CASE","no data found")
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#script_error
 FREE RECORD code
 FREE RECORD image_code
 FREE RECORD temp
 FREE RECORD temp_indexes
 FREE RECORD accession
 FREE RECORD task_assay
 FREE RECORD scd_stories
END GO
