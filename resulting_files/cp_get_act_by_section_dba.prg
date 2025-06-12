CREATE PROGRAM cp_get_act_by_section:dba
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
 SET log_program_name = "CP_GET_ACT_BY_SECTION"
 IF (validate(request) != 1)
  RECORD request(
    1 request_id = f8
    1 scope_flag = i2
    1 request_type = i4
    1 mcis_ind = i2
    1 pending_flag = i2
    1 person_id = f8
    1 encntr_id = f8
    1 accession_nbr = vc
    1 date_range_ind = i2
    1 begin_dt_tm = dq8
    1 end_dt_tm = dq8
    1 chart_format_id = f8
    1 chart_section_id = f8
    1 section_type_flag = i2
    1 result_lookup_ind = i2
    1 activity[*]
      2 chart_section_id = f8
      2 section_seq = i4
      2 section_type_flag = i2
      2 chart_group_id = f8
      2 group_seq = i4
      2 zone = i4
      2 flex_type_flag = i2
      2 doc_type_flag = i2
      2 procedure_seq = i4
      2 procedure_type_flag = i2
      2 event_set_name = vc
      2 dcp_forms_ref_id = f8
      2 catalog_cd = f8
      2 event_cds[*]
        3 event_cd = f8
        3 task_assay_cd = f8
        3 suppressed_ind = i2
    1 parent_event_ids[*]
      2 parent_event_id = f8
    1 inerr_events[*]
      2 event_id = f8
  )
 ENDIF
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 activity[*]
      2 chart_section_id = f8
      2 section_seq = i4
      2 section_type_flag = i2
      2 chart_group_id = f8
      2 group_seq = i4
      2 zone = i4
      2 flex_type_flag = i2
      2 doc_type_flag = i2
      2 procedure_seq = i4
      2 procedure_type_flag = i2
      2 event_set_name = vc
      2 dcp_forms_ref_id = f8
      2 catalog_cd = f8
      2 event_cds[*]
        3 event_cd = f8
        3 task_assay_cd = f8
        3 suppressed_ind = i2
    1 parent_event_ids[*]
      2 parent_event_id = f8
    1 inerr_events[*]
      2 event_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD prelim_events
 RECORD prelim_events(
   1 events[*]
     2 event_id = f8
     2 dontcare = i2
 )
 FREE RECORD valid_events
 RECORD valid_events(
   1 cnt = i4
   1 events[*]
     2 event_id = f8
     2 event_cd = f8
 )
 FREE RECORD event_set_flat
 RECORD event_set_flat(
   1 event_cds[*]
     2 event_cd = f8
 )
 FREE RECORD catalog_cds_flat
 RECORD catalog_cds_flat(
   1 catalog_cds[*]
     2 catalog_cd = f8
     2 event_cd = f8
 )
 DECLARE flex_section_type = i4 WITH constant(6)
 DECLARE mic_section_type = i4 WITH constant(10)
 DECLARE rad_section_type = i4 WITH constant(14)
 DECLARE ap_section_type = i4 WITH constant(18)
 DECLARE pwrfrm_section_type = i4 WITH constant(21)
 DECLARE hla_section_type = i4 WITH constant(22)
 DECLARE doc_section_type = i4 WITH constant(25)
 DECLARE date_clause = vc
 DECLARE scope_clause = vc
 DECLARE other_clause = vc
 DECLARE where_clause = vc
 DECLARE error_clause = vc
 DECLARE result_clause = vc WITH noconstant("")
 DECLARE mill_micro_clause = vc WITH noconstant("")
 DECLARE child_doc_other_clause = vc WITH noconstant("")
 DECLARE encounter_level_doc = i2 WITH constant(1)
 DECLARE patient_level_doc = i2 WITH constant(2)
 DECLARE doc_type = i2 WITH noconstant(0)
 DECLARE auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE unauth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"UNAUTH")), protect
 DECLARE mod_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE alt_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE super_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"SUPERSEDED")), protect
 DECLARE inlab_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"IN LAB")), protect
 DECLARE inprog_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"IN PROGRESS")), protect
 DECLARE trans_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"TRANSCRIBED")), protect
 DECLARE inerror1_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR")), protect
 DECLARE inerror2_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"IN ERROR")), protect
 DECLARE inerrornomut_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOMUT")), protect
 DECLARE inerrornoview_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOVIEW")), protect
 DECLARE cancelled_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"CANCELLED")), protect
 DECLARE rejected_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"REJECTED")), protect
 DECLARE del_stat_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"DELETED")), protect
 DECLARE doc_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC")), protect
 DECLARE mdoc_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"MDOC")), protect
 DECLARE rad_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"RAD")), protect
 DECLARE placehold_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER")), protect
 DECLARE proc_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PROCEDURE")), protect
 DECLARE s_date = vc
 DECLARE e_date = vc
 DECLARE dpowerchartcd = f8 WITH constant(uar_get_code_by("MEANING",89,"POWERCHART")), protect
 DECLARE event_id_cnt = i4
 DECLARE event_cd_cnt = i4
 DECLARE req_size = i4
 DECLARE section_id = f8
 DECLARE activity_req_size = i4 WITH constant(size(request,5)), protect
 DECLARE idx = i4
 DECLARE idxstart = i4 WITH noconstant(1)
 DECLARE noptimizedtotal = i4
 DECLARE nrecordsize = i4
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE act_cnt = i4 WITH constant(size(request->activity,5))
 DECLARE act_event_cnt = i4 WITH noconstant(0)
 DECLARE act_catalog_cnt = i4 WITH noconstant(0)
 DECLARE e_cnt = i4 WITH noconstant(0)
 DECLARE eventtotalcnt = i4 WITH noconstant(0)
 DECLARE procstatus_cd = f8 WITH constant(uar_get_code_by("MEANING",4000341,"SIGNED")), protect
 DECLARE ecg_cd = f8 WITH constant(uar_get_code_by("MEANING",5801,"ECG")), protect
 DECLARE dicom_siuid_cd = f8 WITH constant(uar_get_code_by("MEANING",25,"DICOM_SIUID")), protect
 DECLARE acrnema_cd = f8 WITH constant(uar_get_code_by("MEANING",23,"ACRNEMA")), protect
 DECLARE buildscopeclause(null) = null
 DECLARE builddateclause(null) = null
 DECLARE buildotherclause(null) = null
 DECLARE buildwhereclause(null) = null
 DECLARE buildresultclause(null) = vc
 DECLARE getdocevents(null) = null
 DECLARE getotherevents(null) = null
 DECLARE getprelimevents(null) = null
 DECLARE getvalidevents(null) = null
 DECLARE getinerrevents(null) = null
 DECLARE getpredocumentevents(null) = null
 DECLARE getpreflexibleevents(null) = null
 DECLARE getpreradiologyevents(null) = null
 DECLARE getpreotherevents(null) = null
 DECLARE addeventidtoprelimrec(null) = null
 DECLARE buildchilddocumentotherclause(null) = null
 DECLARE getvalidchilddocevents(null) = null
 CALL log_message("Starting script: cp_get_act_by_section",log_level_debug)
 SET reply->status_data.status = "F"
 CALL buildwhereclause(null)
 CALL echo(concat("Where Clause = ",where_clause))
 IF ((request->section_type_flag=doc_section_type))
  CALL getdocevents(null)
 ELSE
  CALL getotherevents(null)
 ENDIF
 IF (size(reply->activity,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE buildwhereclause(null)
   CALL log_message("In BuildWhereClause()",log_level_debug)
   CALL builddateclause(null)
   CALL buildscopeclause(null)
   CALL buildotherclause(null)
   SET where_clause = concat(scope_clause," and ",date_clause," and ",other_clause)
 END ;Subroutine
 SUBROUTINE buildscopeclause(null)
  IF ((request->section_type_flag=doc_section_type))
   SET section_id = request->chart_section_id
   SET index = locateval(idx,idxstart,activity_req_size,section_id,request->activity[idx].
    chart_section_id)
   SET doc_type = request->activity[index].doc_type_flag
  ENDIF
  IF ((request->section_type_flag=hla_section_type))
   SET scope_clause = build("ce.person_id = ",request->person_id)
  ELSEIF ((request->section_type_flag=doc_section_type)
   AND doc_type=encounter_level_doc
   AND (request->scope_flag=1))
   SET scope_clause = build("ce.person_id = ",request->person_id," and ce.encntr_id+0 > 0.0")
  ELSEIF ((request->section_type_flag=doc_section_type)
   AND doc_type=patient_level_doc)
   SET scope_clause = build("ce.person_id = ",request->person_id," and ce.encntr_id+0 = 0.0")
  ELSE
   CASE (request->scope_flag)
    OF 1:
     SET scope_clause = build("ce.person_id = ",request->person_id)
    OF 2:
     IF ((((request->request_type=1)) OR ((request->request_type=8))) )
      SET scope_clause = build("ce.encntr_id = ",request->encntr_id," and ce.person_id = ",request->
       person_id)
     ELSE
      SET scope_clause = build("ce.encntr_id+0 = ",request->encntr_id," and ce.person_id = ",request
       ->person_id)
     ENDIF
    OF 3:
     SET scope_clause = build("ce.person_id+0 = ",request->person_id," and ce.encntr_id+0 = ",request
      ->encntr_id," and ce.order_id in ",
      " (select order_id from "," chart_request_order "," where chart_request_id = ",request->
      request_id,")")
    OF 4:
     SET scope_clause = build("ce.accession_nbr = request->accession_nbr"," and ce.encntr_id+0 = ",
      request->encntr_id," and ce.person_id+0 = ",request->person_id)
    OF 5:
     SET scope_clause = build("ce.person_id = ",request->person_id," and ce.encntr_id in ",
      " (select encntr_id from "," chart_request_encntr ",
      " where chart_request_id = ",request->request_id,")")
   ENDCASE
  ENDIF
 END ;Subroutine
 SUBROUTINE builddateclause(null)
   IF ((request->date_range_ind=1))
    IF ((request->begin_dt_tm > 0))
     SET s_date = "cnvtdatetime(request->begin_dt_tm)"
    ELSE
     SET s_date = "cnvtdatetime('01-Jan-1800')"
    ENDIF
    IF ((request->end_dt_tm > 0))
     SET e_date = "cnvtdatetime(request->end_dt_tm)"
    ELSE
     SET e_date = "cnvtdatetime('31-Dec-2100')"
    ENDIF
    IF ((request->request_type=2)
     AND (request->mcis_ind=0))
     SET date_clause = concat(" (ce.verified_dt_tm between ",s_date," and ",e_date)
     IF ((((request->pending_flag=1)) OR ((request->pending_flag=2))) )
      SET date_clause = concat(date_clause," or ce.performed_dt_tm between ",s_date," and ",e_date)
     ENDIF
     IF ((request->pending_flag=2))
      SET date_clause = concat(date_clause," or ce.event_end_dt_tm between ",s_date," and ",e_date)
     ENDIF
     SET date_clause = concat(date_clause,")")
    ELSE
     IF ((request->result_lookup_ind=1))
      SET date_clause = concat(" (ce.event_end_dt_tm+0 between ",s_date," and ",e_date,")")
     ELSE
      SET date_clause = concat(" (ce.clinsig_updt_dt_tm+0 between ",s_date," and ",e_date,")")
     ENDIF
    ENDIF
   ELSE
    SET date_clause = "1=1"
   ENDIF
 END ;Subroutine
 SUBROUTINE buildchilddocumentotherclause(null)
   SET child_doc_other_clause =
   "ce.event_class_cd != placehold_class_cd and ce.record_status_cd != del_stat_cd and"
   SET child_doc_other_clause = concat(child_doc_other_clause,
    " ce.view_level != 1 and ce.publish_flag = 1"," and ce.event_class_cd in (doc_class_cd)")
   SET child_doc_other_clause = concat(child_doc_other_clause,buildresultclause(null))
   IF (validate(debug_ind,0)=1)
    CALL echo(child_doc_other_clause)
   ENDIF
 END ;Subroutine
 SUBROUTINE buildotherclause(null)
   SET other_clause =
   "ce.event_class_cd != placehold_class_cd and ce.record_status_cd != del_stat_cd and"
   CASE (request->section_type_flag)
    OF flex_section_type:
     SET other_clause = concat(other_clause," ce.view_level in (0, 1) and ce.publish_flag = 1")
    OF doc_section_type:
     SET other_clause = concat(other_clause," ce.view_level > 0 and ce.publish_flag = 1",
      " and ce.event_class_cd in (doc_class_cd, mdoc_class_cd, proc_class_cd)")
    OF ap_section_type:
     IF ((request->pending_flag > 0))
      SET other_clause = concat(other_clause," ce.view_level = 0 and ce.publish_flag > 0")
     ELSE
      SET other_clause = concat(other_clause," ce.view_level = 0 and ce.publish_flag = 1")
     ENDIF
    OF hla_section_type:
     SET other_clause = concat(other_clause," ce.view_level = 1 and ce.publish_flag = 1")
    OF pwrfrm_section_type:
     SET other_clause = concat(other_clause," ce.view_level >= 0 and ce.publish_flag = 1")
    ELSE
     SET other_clause = concat(other_clause," ce.view_level > 0 and ce.publish_flag = 1")
   ENDCASE
   SET error_clause = concat(other_clause,
    " and ce.result_status_cd in (inerror1_cd, inerror2_cd, inerrornomut_cd, inerrornoview_cd, rejected_cd, cancelled_cd)"
    )
   SET other_clause = concat(other_clause,buildresultclause(null))
 END ;Subroutine
 SUBROUTINE buildresultclause(null)
   SET mill_micro_clause =
   "ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd,inlab_cd, inprog_cd, trans_cd, unauth_cd)"
   IF ((request->pending_flag=0))
    SET result_clause = "ce.result_status_cd in  (auth_cd, mod_cd, super_cd, alt_cd)"
   ELSEIF ((request->pending_flag=1))
    SET result_clause =
    "ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd)"
   ELSE
    SET result_clause =
    "ce.result_status_cd in (auth_cd,mod_cd,super_cd,alt_cd,inlab_cd,inprog_cd,trans_cd,unauth_cd)"
   ENDIF
   IF ((request->section_type_flag=mic_section_type))
    SET result_clause = concat(" and ((",result_clause,
     " and ce.contributor_system_cd != dPowerchartCd) OR (",mill_micro_clause,
     " and ce.contributor_system_cd = dPowerchartCd))")
   ELSE
    SET result_clause = concat(" and ",result_clause)
   ENDIF
   RETURN(result_clause)
 END ;Subroutine
 SUBROUTINE getdocevents(null)
   CALL log_message("In GetDocEvents()",log_level_debug)
   DECLARE eventcnt = i4
   DECLARE activitycnt = i4
   CALL getprelimevents(null)
   IF (size(prelim_events->events,5) > 0)
    SELECT DISTINCT INTO "nl:"
     FROM clinical_event cce,
      clinical_event ce,
      (dummyt d  WITH seq = value(size(prelim_events->events,5)))
     PLAN (d)
      JOIN (cce
      WHERE (cce.event_id=prelim_events->events[d.seq].event_id)
       AND cce.parent_event_id != 0)
      JOIN (ce
      WHERE ce.event_id=cce.parent_event_id
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     ORDER BY cce.event_id, cce.valid_until_dt_tm DESC, ce.valid_until_dt_tm DESC
     HEAD cce.event_id
      IF (ce.result_status_cd IN (inerror1_cd, inerror2_cd, inerrornomut_cd, inerrornoview_cd,
      rejected_cd,
      cancelled_cd))
       prelim_events->events[d.seq].dontcare = 1
      ENDIF
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CLINICAL_EVENT","GETDOCEVENTS",1,0)
    CALL getvalidevents(null)
    CALL buildchilddocumentotherclause(null)
    CALL getvalidchilddocevents(null)
    SELECT DISTINCT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(prelim_events->events,5))),
      chart_req_inerr_event cre
     PLAN (d
      WHERE (prelim_events->events[d.seq].dontcare=1))
      JOIN (cre
      WHERE (cre.chart_request_id=request->request_id)
       AND (cre.event_id=prelim_events->events[d.seq].event_id))
     HEAD REPORT
      inerr_nbr = 0
     HEAD d.seq
      IF (cre.event_id=0)
       inerr_nbr += 1
       IF (mod(inerr_nbr,5)=1)
        stat = alterlist(reply->inerr_events,(inerr_nbr+ 4))
       ENDIF
       reply->inerr_events[inerr_nbr].event_id = prelim_events->events[d.seq].event_id
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->inerr_events,inerr_nbr)
     WITH outerjoin = d, nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_REQ_INERR_EVENT","GETDOCEVENTS",1,0)
   ENDIF
 END ;Subroutine
 SUBROUTINE getotherevents(null)
   CALL log_message("In GetOtherEvents()",log_level_debug)
   CALL getprelimevents(null)
   IF (size(prelim_events->events,5) > 0)
    CALL getvalidevents(null)
    IF ((request->section_type_flag IN (ap_section_type, rad_section_type)))
     CALL getinerrevents(null)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getprelimevents(null)
   CALL log_message("In GetPrelimEvents()",log_level_debug)
   FOR (i = 1 TO act_cnt)
    SET e_cnt = size(request->activity[i].event_cds,5)
    FOR (x = 1 TO e_cnt)
      IF ((request->activity[i].procedure_type_flag=1))
       SET act_catalog_cnt += 1
       SET stat = alterlist(catalog_cds_flat->catalog_cds,act_catalog_cnt)
       SET catalog_cds_flat->catalog_cds[act_catalog_cnt].catalog_cd = request->activity[i].
       catalog_cd
       SET catalog_cds_flat->catalog_cds[act_catalog_cnt].event_cd = request->activity[i].event_cds[x
       ].event_cd
      ELSE
       SET act_event_cnt += 1
       SET stat = alterlist(event_set_flat->event_cds,act_event_cnt)
       SET event_set_flat->event_cds[act_event_cnt].event_cd = request->activity[i].event_cds[x].
       event_cd
      ENDIF
    ENDFOR
   ENDFOR
   IF (((size(event_set_flat->event_cds,5) > 0) OR (size(catalog_cds_flat->catalog_cds,5))) )
    IF ((request->section_type_flag=doc_section_type))
     CALL getpredocumentevents(null)
    ELSEIF ((request->section_type_flag=flex_section_type))
     CALL getpreflexibleevents(null)
    ELSEIF ((request->section_type_flag=rad_section_type))
     CALL getpreradiologyevents(null)
    ELSE
     CALL getpreotherevents(null)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getvalidchilddocevents(null)
   CALL log_message("In GetValidChildDocEvents()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE idxreply = i4 WITH noconstant(0), protect
   DECLARE section_index = i4 WITH noconstant(0), protect
   DECLARE idxeventcdlist = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM clinical_event ce,
     (dummyt d1  WITH seq = value(size(valid_events->events,5)))
    PLAN (d1)
     JOIN (ce
     WHERE (ce.parent_event_id=valid_events->events[d1.seq].event_id)
      AND (ce.event_cd != valid_events->events[d1.seq].event_cd)
      AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND ce.event_id != ce.parent_event_id
      AND parser(child_doc_other_clause))
    ORDER BY ce.parent_event_id
    HEAD REPORT
     activitycnt = size(reply->activity,5), eventcdcnt = 0
    HEAD ce.parent_event_id
     section_index = locateval(idxreply,1,size(reply->activity,5),request->chart_section_id,reply->
      activity[idxreply].chart_section_id)
     IF (section_index > 0)
      eventcdcnt = size(reply->activity[section_index].event_cds,5)
     ENDIF
    DETAIL
     IF (section_index > 0)
      event_cd_index = locateval(idxeventcdlist,1,eventcdcnt,ce.event_cd,reply->activity[
       section_index].event_cds[idxeventcdlist].event_cd)
      IF (event_cd_index=0)
       eventcdcnt = (size(reply->activity[section_index].event_cds,5)+ 1)
       IF (eventcdcnt > size(reply->activity[section_index].event_cds,5))
        stat = alterlist(reply->activity[section_index].event_cds,(eventcdcnt+ 4))
       ENDIF
       reply->activity[section_index].event_cds[eventcdcnt].event_cd = ce.event_cd
      ENDIF
     ENDIF
    FOOT  ce.parent_event_id
     IF (section_index > 0)
      stat = alterlist(reply->activity[section_index].event_cds,eventcdcnt), eventcdcnt = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->activity,activitycnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CLINICAL_EVENT","GETVALIDCHILDDOCEVENTS",1,0)
   IF (validate(debug_ind,0)=1)
    CALL echorecord(valid_events)
   ENDIF
   CALL log_message(build("Exit GetValidChildDocEvents(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getvalidevents(null)
   CALL log_message("In GetValidEvents()",log_level_debug)
   SELECT DISTINCT INTO "nl:"
    group_seq = request->activity[d2.seq].group_seq, zone = request->activity[d2.seq].zone,
    procedure_seq = request->activity[d2.seq].procedure_seq,
    event_cd = request->activity[d2.seq].event_cds[d3.seq].event_cd
    FROM clinical_event ce,
     (dummyt d1  WITH seq = value(size(prelim_events->events,5))),
     (dummyt d2  WITH seq = value(size(request->activity,5))),
     (dummyt d3  WITH seq = 1)
    PLAN (d1
     WHERE (prelim_events->events[d1.seq].dontcare=0))
     JOIN (ce
     WHERE (ce.event_id=prelim_events->events[d1.seq].event_id)
      AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND parser(other_clause)
      AND parser(date_clause))
     JOIN (d2
     WHERE maxrec(d3,size(request->activity[d2.seq].event_cds,5)))
     JOIN (d3
     WHERE (((request->activity[d2.seq].procedure_type_flag=0)
      AND (request->activity[d2.seq].event_cds[d3.seq].event_cd=ce.event_cd)) OR ((request->activity[
     d2.seq].procedure_type_flag=1)
      AND (request->activity[d2.seq].catalog_cd=ce.catalog_cd)
      AND (request->activity[d2.seq].event_cds[d3.seq].event_cd=ce.event_cd))) )
    ORDER BY group_seq, zone, procedure_seq,
     event_cd
    HEAD REPORT
     activitycnt = 0, eventcdcnt = 0
    HEAD group_seq
     do_nothing = 0
    HEAD zone
     do_nothing = 0
    HEAD procedure_seq
     IF ((((request->section_type_flag=flex_section_type)
      AND (((request->activity[d2.seq].flex_type_flag=0)
      AND ce.view_level=0) OR ((request->activity[d2.seq].flex_type_flag=1)
      AND ce.view_level=1)) ) OR ((request->section_type_flag != flex_section_type))) )
      activitycnt += 1
      IF (mod(activitycnt,5)=1)
       stat = alterlist(reply->activity,(activitycnt+ 4))
      ENDIF
      reply->activity[activitycnt].chart_section_id = request->activity[d2.seq].chart_section_id,
      reply->activity[activitycnt].section_seq = request->activity[d2.seq].section_seq, reply->
      activity[activitycnt].chart_group_id = request->activity[d2.seq].chart_group_id,
      reply->activity[activitycnt].group_seq = request->activity[d2.seq].group_seq, reply->activity[
      activitycnt].zone = request->activity[d2.seq].zone, reply->activity[activitycnt].procedure_seq
       = request->activity[d2.seq].procedure_seq,
      reply->activity[activitycnt].procedure_type_flag = request->activity[d2.seq].
      procedure_type_flag, reply->activity[activitycnt].event_set_name = request->activity[d2.seq].
      event_set_name, reply->activity[activitycnt].catalog_cd = request->activity[d2.seq].catalog_cd
     ENDIF
    DETAIL
     IF ((((request->section_type_flag=flex_section_type)
      AND (((request->activity[d2.seq].flex_type_flag=0)
      AND ce.view_level=0) OR ((request->activity[d2.seq].flex_type_flag=1)
      AND ce.view_level=1)) ) OR ((request->section_type_flag != flex_section_type))) )
      eventcdcnt += 1
      IF (mod(eventcdcnt,5)=1)
       stat = alterlist(reply->activity[activitycnt].event_cds,(eventcdcnt+ 4))
      ENDIF
      reply->activity[activitycnt].event_cds[eventcdcnt].event_cd = event_cd, valid_events->cnt += 1
      IF ((valid_events->cnt > size(valid_events->events,5)))
       stat = alterlist(valid_events->events,(valid_events->cnt+ 9))
      ENDIF
      valid_events->events[valid_events->cnt].event_id = ce.event_id, valid_events->events[
      valid_events->cnt].event_cd = ce.event_cd
     ENDIF
    FOOT  procedure_seq
     stat = alterlist(reply->activity[activitycnt].event_cds,eventcdcnt), eventcdcnt = 0
    FOOT  zone
     do_nothing = 0
    FOOT  group_seq
     do_nothing = 0
    FOOT REPORT
     stat = alterlist(reply->activity,activitycnt), stat = alterlist(valid_events->events,
      valid_events->cnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CLINICAL_EVENT","GETVALIDEVENTS",1,0)
 END ;Subroutine
 SUBROUTINE getinerrevents(null)
   CALL log_message("In GetInErrEvents()",log_level_debug)
   SET idx = 0
   SET idxstart = 1
   SET nrecordsize = size(prelim_events->events,5)
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(prelim_events->events,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET prelim_events->events[i].event_id = prelim_events->events[nrecordsize].event_id
   ENDFOR
   SELECT DISTINCT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     clinical_event ce
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (ce
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.event_id,prelim_events->events[idx].
      event_id,
      bind_cnt)
      AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND parser(error_clause)
      AND  NOT (ce.event_id IN (
     (SELECT
      event_id
      FROM chart_req_inerr_event
      WHERE (chart_request_id=request->request_id)))))
    ORDER BY ce.event_id
    HEAD REPORT
     inerr_nbr = 0
    HEAD ce.event_id
     inerr_nbr += 1
     IF (mod(inerr_nbr,5)=1)
      stat = alterlist(reply->inerr_events,(inerr_nbr+ 4))
     ENDIF
     reply->inerr_events[inerr_nbr].event_id = ce.event_id
    FOOT REPORT
     stat = alterlist(reply->inerr_events,inerr_nbr)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ERROR_EVENTS_CLINICAL_EVENT","GETINERREVENTS",1,0)
 END ;Subroutine
 SUBROUTINE getpredocumentevents(null)
   CALL log_message("In GetPreDocumentEvents()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   SET idx = 0
   SET idxstart = 1
   DECLARE paper_format_code = f8 WITH constant(uar_get_code_by("MEANING",23,"PAPER")), protect
   DECLARE grp_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"GRP")), protect
   FREE RECORD mdoc_flat_rec
   RECORD mdoc_flat_rec(
     1 qual[*]
       2 event_id = f8
   )
   FREE RECORD ecg_flat_rec
   RECORD ecg_flat_rec(
     1 qual[*]
       2 event_id = f8
   )
   SET nrecordsize = size(event_set_flat->event_cds,5)
   CALL optimizedtotalevents(nrecordsize)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     clinical_event ce
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (ce
     WHERE parser(where_clause)
      AND expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.event_cd,event_set_flat->event_cds[idx].
      event_cd))
    ORDER BY ce.event_id
    HEAD REPORT
     eventcnt = 0
    HEAD ce.event_id
     IF ((((request->result_lookup_ind=0)
      AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->
      end_dt_tm)
      AND ce.event_class_cd IN (mdoc_class_cd, doc_class_cd, proc_class_cd)
      AND ce.view_level > 0
      AND ce.publish_flag=1) OR ((((request->result_lookup_ind=1)
      AND ce.event_end_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->
      end_dt_tm)
      AND ce.event_class_cd IN (mdoc_class_cd, doc_class_cd, proc_class_cd)
      AND ce.view_level > 0
      AND ce.publish_flag=1) OR ((request->request_type=2)
      AND ce.event_class_cd IN (mdoc_class_cd, doc_class_cd)
      AND ce.view_level > 0
      AND ce.publish_flag=1)) )) )
      IF (ce.event_class_cd IN (mdoc_class_cd, grp_class_cd))
       y = size(mdoc_flat_rec->qual,5), y += 1, stat = alterlist(mdoc_flat_rec->qual,y),
       mdoc_flat_rec->qual[y].event_id = ce.event_id
      ELSEIF (ce.event_class_cd=proc_class_cd)
       y = size(ecg_flat_rec->qual,5), y += 1, stat = alterlist(ecg_flat_rec->qual,y),
       ecg_flat_rec->qual[y].event_id = ce.event_id
      ELSE
       eventcnt += 1
       IF (mod(eventcnt,10)=1)
        stat = alterlist(prelim_events->events,(eventcnt+ 9))
       ENDIF
       prelim_events->events[eventcnt].event_id = ce.event_id
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(prelim_events->events,eventcnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"DOC_EVENT_CDS_CLINICAL_EVENT","GETPREDOCUMENTEVENTS",1,0)
   SET nrecordsize = size(ecg_flat_rec->qual,5)
   IF (nrecordsize > 0)
    DECLARE ecg_date_clause = vc
    IF ((request->result_lookup_ind=1))
     SET ecg_date_clause = concat(" (ce.event_end_dt_tm+0 between ",s_date," and ",e_date,")")
    ELSE
     SET ecg_date_clause = concat(" (ce.clinsig_updt_dt_tm+0 between ",s_date," and ",e_date,")")
    ENDIF
    SET idx = 0
    SET idxstart = 1
    SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
    SET stat = alterlist(ecg_flat_rec->qual,noptimizedtotal)
    FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
      SET ecg_flat_rec->qual[i].event_id = ecg_flat_rec->qual[nrecordsize].event_id
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce,
      clinical_event ce2,
      cv_proc cv,
      ce_blob_result cbr
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.event_id,ecg_flat_rec->qual[idx].
       event_id,
       bind_cnt)
       AND parser(ecg_date_clause)
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      JOIN (ce2
      WHERE ce2.parent_event_id=ce.event_id
       AND ce2.event_class_cd=doc_class_cd
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      JOIN (cv
      WHERE cv.group_event_id=ce.event_id
       AND cv.proc_status_cd=procstatus_cd
       AND cv.activity_subtype_cd=ecg_cd)
      JOIN (cbr
      WHERE cbr.event_id=ce2.event_id
       AND cbr.storage_cd=dicom_siuid_cd
       AND cbr.format_cd=acrnema_cd
       AND cbr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     DETAIL
      eventcnt += 1
      IF (eventcnt > size(prelim_events->events,5))
       stat = alterlist(prelim_events->events,(eventcnt+ 9))
      ENDIF
      prelim_events->events[eventcnt].event_id = ce.parent_event_id
     FOOT REPORT
      stat = alterlist(prelim_events->events,eventcnt)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CV_PROC","GetPreDocumentEvents",1,0)
   ENDIF
   SET nrecordsize = size(mdoc_flat_rec->qual,5)
   IF (nrecordsize > 0)
    SET idx = 0
    SET idxstart = 1
    SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
    SET stat = alterlist(mdoc_flat_rec->qual,noptimizedtotal)
    FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
      SET mdoc_flat_rec->qual[i].event_id = mdoc_flat_rec->qual[nrecordsize].event_id
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce,
      ce_blob_result cbr
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.parent_event_id,mdoc_flat_rec->qual[idx
       ].event_id,
       bind_cnt)
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
       AND ce.view_level >= 0
       AND ce.publish_flag=1)
      JOIN (cbr
      WHERE cbr.event_id=ce.event_id
       AND cbr.format_cd != paper_format_code
       AND cbr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     HEAD REPORT
      eventcnt = size(prelim_events->events,5)
     DETAIL
      eventcnt += 1
      IF (eventcnt > size(prelim_events->events,5))
       stat = alterlist(prelim_events->events,(eventcnt+ 9))
      ENDIF
      prelim_events->events[eventcnt].event_id = ce.parent_event_id
     FOOT REPORT
      stat = alterlist(prelim_events->events,eventcnt)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"DOC_MDOCFLAT_CLINICAL_EVENT","GETPREDOCUMENTEVENTS",1,0)
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(prelim_events)
   ENDIF
   CALL log_message(build("Exit GetPreDocumentEvents(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getpreflexibleevents(null)
   CALL log_message("In GetPreFlexibleEvents()",log_level_debug)
   DECLARE flex_flag = i2 WITH noconstant(0)
   SET idx = 0
   SET idxstart = 1
   SET flex_flag = request->activity[1].flex_type_flag
   SET nrecordsize = size(event_set_flat->event_cds,5)
   IF (nrecordsize > 0)
    CALL optimizedtotalevents(nrecordsize)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE parser(where_clause)
       AND expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.event_cd,event_set_flat->event_cds[idx].
       event_cd)
       AND ((flex_flag=0
       AND ce.view_level=0) OR (flex_flag=1
       AND ce.view_level=1)) )
     ORDER BY ce.event_id
     HEAD ce.event_id
      CALL addeventidtoprelimrec(null)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"FLEX_EVENT_CDS_CLINICAL_EVENT","GETPREFLEXIBLEEVENTS",1,0)
   ENDIF
   SET nrecordsize = size(catalog_cds_flat->catalog_cds,5)
   IF (nrecordsize > 0)
    SET idx = 0
    SET idxstart = 1
    CALL optimizedtotalcatalogs(nrecordsize)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE parser(where_clause)
       AND expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.catalog_cd,catalog_cds_flat->
       catalog_cds[idx].catalog_cd,
       ce.event_cd,catalog_cds_flat->catalog_cds[idx].event_cd)
       AND ((flex_flag=0
       AND ce.view_level=0) OR (flex_flag=1
       AND ce.view_level=1)) )
     ORDER BY ce.event_id
     HEAD ce.event_id
      CALL addeventidtoprelimrec(null)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"FLEX_CATALOG_CDS_CLINICAL_EVENT","GETPREFLEXIBLEEVENTS",1,0)
   ENDIF
   SET stat = alterlist(prelim_events->events,eventtotalcnt)
 END ;Subroutine
 SUBROUTINE getpreradiologyevents(null)
   CALL log_message("In GetPreRadiologyEvents()",log_level_debug)
   SET idx = 0
   SET idxstart = 1
   SET nrecordsize = size(event_set_flat->event_cds,5)
   IF (nrecordsize > 0)
    CALL optimizedtotalevents(nrecordsize)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce,
      ce_linked_result clr
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE parser(where_clause)
       AND ce.event_class_cd=rad_class_cd
       AND expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.event_cd,event_set_flat->event_cds[idx].
       event_cd))
      JOIN (clr
      WHERE (clr.event_id= Outerjoin(ce.event_id))
       AND clr.event_id > 0)
     ORDER BY ce.event_id
     HEAD ce.event_id
      CALL addeventidtoprelimrec(null)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"RAD_EVENT_CDS_CLINICAL_EVENT","GETPRERADIOLOGYEVENTS",1,0)
   ENDIF
   SET nrecordsize = size(catalog_cds_flat->catalog_cds,5)
   IF (nrecordsize > 0)
    SET idx = 0
    SET idxstart = 1
    CALL optimizedtotalcatalogs(nrecordsize)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce,
      ce_linked_result clr
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE parser(where_clause)
       AND ce.event_class_cd=rad_class_cd
       AND expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.catalog_cd,catalog_cds_flat->
       catalog_cds[idx].catalog_cd,
       ce.event_cd,catalog_cds_flat->catalog_cds[idx].event_cd))
      JOIN (clr
      WHERE (clr.event_id= Outerjoin(ce.event_id))
       AND clr.event_id > 0)
     ORDER BY ce.event_id
     HEAD ce.event_id
      CALL addeventidtoprelimrec(null)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"RAD_CATALOG_CDS_CLINICAL_EVENT","GETPRERADIOLOGYEVENTS",1,0)
   ENDIF
   SET stat = alterlist(prelim_events->events,eventtotalcnt)
 END ;Subroutine
 SUBROUTINE getpreotherevents(null)
   CALL log_message("In GetPreOtherEvents()",log_level_debug)
   SET idx = 0
   SET idxstart = 1
   SET nrecordsize = size(event_set_flat->event_cds,5)
   IF (nrecordsize > 0)
    CALL optimizedtotalevents(nrecordsize)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE parser(where_clause)
       AND expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.event_cd,event_set_flat->event_cds[idx].
       event_cd))
     ORDER BY ce.event_id
     HEAD ce.event_id
      CALL addeventidtoprelimrec(null)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"EVENT_CDS_CLINICAL_EVENT","GETPREOTHEREVENTS",1,0)
   ENDIF
   SET nrecordsize = size(catalog_cds_flat->catalog_cds,5)
   IF (nrecordsize > 0)
    SET idx = 0
    SET idxstart = 1
    CALL optimizedtotalcatalogs(nrecordsize)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE parser(where_clause)
       AND expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.catalog_cd,catalog_cds_flat->
       catalog_cds[idx].catalog_cd,
       ce.event_cd,catalog_cds_flat->catalog_cds[idx].event_cd))
     ORDER BY ce.event_id
     HEAD ce.event_id
      CALL addeventidtoprelimrec(null)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CATALOG_CDS_CLINICAL_EVENT","GETPREOTHEREVENTS",1,0)
   ENDIF
   SET stat = alterlist(prelim_events->events,eventtotalcnt)
 END ;Subroutine
 SUBROUTINE addeventidtoprelimrec(null)
   SET eventtotalcnt += 1
   IF (mod(eventtotalcnt,10)=1)
    SET stat = alterlist(prelim_events->events,(eventtotalcnt+ 9))
   ENDIF
   SET prelim_events->events[eventtotalcnt].event_id = ce.event_id
 END ;Subroutine
 SUBROUTINE (optimizedtotalevents(irecsize=i4) =null)
   SET noptimizedtotal = (ceil((cnvtreal(irecsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(event_set_flat->event_cds,noptimizedtotal)
   FOR (i = (irecsize+ 1) TO noptimizedtotal)
     SET event_set_flat->event_cds[i].event_cd = event_set_flat->event_cds[irecsize].event_cd
   ENDFOR
 END ;Subroutine
 SUBROUTINE (optimizedtotalcatalogs(irecsize=i4) =null)
   SET noptimizedtotal = (ceil((cnvtreal(irecsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(catalog_cds_flat->catalog_cds,noptimizedtotal)
   FOR (i = (irecsize+ 1) TO noptimizedtotal)
    SET catalog_cds_flat->catalog_cds[i].event_cd = catalog_cds_flat->catalog_cds[irecsize].event_cd
    SET catalog_cds_flat->catalog_cds[i].catalog_cd = catalog_cds_flat->catalog_cds[irecsize].
    catalog_cd
   ENDFOR
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cp_get_act_by_section",log_level_debug)
 IF (validate(debug_ind,0)=1)
  CALL echorecord(reply)
 ENDIF
END GO
