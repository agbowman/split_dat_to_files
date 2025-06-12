CREATE PROGRAM ct_get_pt_data_capture_info:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 subject_number = vc
    1 birth_dt_tm = dq8
    1 birth_dt_tz = i4
    1 sex_cd = f8
    1 sex_disp = c50
    1 sex_desc = c50
    1 sex_mean = c12
    1 race_cd = f8
    1 race_disp = c50
    1 race_desc = c50
    1 race_mean = c12
    1 ethnicity_cd = f8
    1 ethnicity_disp = c50
    1 ethnicity_desc = c50
    1 ethnicity_mean = c12
    1 consent_dt_tm = dq8
    1 on_study_dt_tm = dq8
    1 off_study_dt_tm = dq8
    1 off_treatment_dt_tm = dq8
    1 current_amendment_nbr = i4
    1 current_revision_nbr = vc
    1 original_amendment_nbr = i4
    1 original_revision_nbr = vc
    1 event_group[*]
      2 parent_event_alias = vc
      2 performed_person_id = f8
      2 performed_person = vc
      2 performed_dt_tm = dq8
      2 performed_tz = i4
      2 events[*]
        3 event_name = vc
        3 event_cd = f8
        3 event_status_cd = f8
        3 event_alias = vc
        3 event_value = vc
        3 event_unit = vc
        3 event_dt_tm = dq8
        3 event_tz = i4
        3 event_result_type = i2
        3 event_task_person_id = f8
        3 event_task_person = vc
        3 performed_person_id = f8
        3 performed_person = vc
        3 performed_dt_tm = dq8
        3 performed_tz = i4
    1 aes[*]
      2 ae_model_name = c20
      2 ae_id = f8
      2 ae_sub_id = f8
      2 description = vc
      2 onset_dt_tm = dq8
      2 onset_tz = i4
      2 onset_prec_flag = i2
      2 resolved_prec_flag = i2
      2 resolved_dt_tm = dq8
      2 resolved_tz = i4
      2 ongoing_ind = i2
      2 serious_ind = i2
      2 severity_category = f8
      2 severity_flag = vc
      2 reaction = vc
      2 outcome = vc
      2 performed_person_id = f8
      2 performed_dt_tm = dq8
      2 performed_tz = i4
      2 performed_person = vc
    1 conmeds[*]
      2 med_name = vc
      2 med_dose = vc
      2 med_dose_unit = vc
      2 med_dose_unit_cd = f8
      2 med_frequency = vc
      2 med_frequency_cd = f8
      2 med_route_cd = f8
      2 med_route = vc
      2 med_form_cd = f8
      2 med_form = vc
      2 med_start_dt_tm = dq8
      2 med_start_tz = i4
      2 med_end_val = i2
      2 med_end_dt_tm = dq8
      2 med_end_tz = i4
      2 order_id = f8
      2 performed_person_id = f8
      2 performed_person = vc
      2 performed_dt_tm = dq8
      2 performed_tz = i4
    1 protocol_name = vc
    1 location_id = f8
    1 location_name = vc
    1 user_id = f8
    1 user_name = vc
    1 principal_investigator_id = f8
    1 principal_investigator_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE getcodedvalue(code_value=vc) = vc
 SUBROUTINE getcodedvalue(code_value)
   DECLARE coded_value = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_value=cnvtreal(code_value))
    DETAIL
     IF (size(trim(cv.concept_cki),1) > 0)
      coded_value = cv.concept_cki
     ELSEIF (size(trim(cv.cki),1) > 0)
      coded_value = cv.cki
     ELSEIF (size(trim(cv.cdf_meaning),1) > 0)
      coded_value = cv.cdf_meaning
     ELSEIF (size(trim(cv.display),1) > 0)
      coded_value = cv.display
     ENDIF
    WITH nocounter
   ;end select
   RETURN(coded_value)
 END ;Subroutine
 DECLARE failedind = c1 WITH noconstant("F")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE bfoundvs = i2 WITH protect
 DECLARE indexgroup = i2 WITH protect
 DECLARE indexevent = i2 WITH protect
 DECLARE group_cnt = i2 WITH protect
 DECLARE event_cnt = i2 WITH protect
 DECLARE enrolling_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17349,"ENROLLING"))
 DECLARE pt_reg_id = f8 WITH proctect, noconstant(0)
 DECLARE inerror = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE notdone = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOTDONE"))
 DECLARE audit_record = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE princ_invest_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17441,"PRIMARY"))
 DECLARE completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE pharm_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"ACTIVE"))
 DECLARE inactive_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"INACTIVE"))
 DECLARE resolved_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"RESOLVED"))
 DECLARE active_allergy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"ACTIVE"))
 DECLARE proposed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"PROPOSED"))
 DECLARE resolved_allergy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"RESOLVED"))
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE day_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17278,"DAY"))
 DECLARE month_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17278,"MONTH"))
 DECLARE year_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17278,"YEAR"))
 DECLARE tmpconmed = vc WITH protect, noconstant("")
 DECLARE conmeddttm = dq8 WITH protect
 DECLARE tmpcondition = vc WITH protect, noconstant("")
 DECLARE conditiondttm = dq8 WITH protect
 DECLARE strength = vc WITH protect, noconstant("")
 DECLARE strength_unit = vc WITH protect, noconstant("")
 DECLARE strength_cd = f8 WITH protect, noconstant(0.0)
 DECLARE strength_unit_cd = f8 WITH protect, noconstant(0.0)
 DECLARE form = vc WITH protect, noconstant("")
 DECLARE form_cd = f8 WITH protect, noconstant(0.0)
 DECLARE route = vc WITH protect, noconstant("")
 DECLARE route_cd = f8 WITH protect, noconstant(0.0)
 DECLARE frequency = vc WITH protect, noconstant("")
 DECLARE frequency_cd = f8 WITH protect, noconstant(0.0)
 DECLARE idc_contributing_system = f8 WITH protect
 DECLARE med_disp = vc WITH protect, noconstant(" ")
 DECLARE med_disp_mnemonic = vc WITH protect, noconstant(" ")
 DECLARE volume = vc WITH protect, noconstant(" ")
 DECLARE volume_unit = vc WITH protect, noconstant(" ")
 DECLARE parent_event_group_events_count = i4 WITH protect, noconstant(0)
 DECLARE datetime_group_events_count = i4 WITH protect, noconstant(0)
 DECLARE previous_item_group = vc WITH protect
 DECLARE current_item_group = vc WITH protect
 DECLARE reply_group_count = i4 WITH proctect, noconstant(0)
 DECLARE current_event_group_count = i4 WITH proctect, noconstant(0)
 DECLARE num = i4 WITH proctect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(1)
 DECLARE pos = i4 WITH protect, noconstant(0)
 RECORD aliased_events(
   1 parent_event_group_events[*]
     2 event_cd = f8
     2 event_alias = vc
   1 datetime_group_events[*]
     2 event_cd = f8
     2 event_alias = vc
 )
 RECORD temp_events(
   1 event_group[*]
     2 performed_person_id = f8
     2 performed_person = vc
     2 performed_dt_tm = dq8
     2 performed_tz = i4
     2 events[*]
       3 event_name = vc
       3 event_cd = f8
       3 event_status_cd = f8
       3 event_alias = vc
       3 event_value = vc
       3 event_unit = vc
       3 event_dt_tm = dq8
       3 event_tz = i4
       3 event_task_person_id = f8
       3 event_task_person = vc
       3 event_result_type = i2
       3 performed_person_id = f8
       3 performed_person = vc
       3 performed_dt_tm = dq8
       3 parent_event_alias = vc
       3 performed_tz = i4
 )
 DECLARE person_cnt = i2 WITH protect, noconstant(0)
 RECORD temp_persons(
   1 person_list[*]
     2 person_id = f8
     2 person_name = vc
 )
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 DECLARE severityvalue(sev_cd=f8) = vc
 DECLARE getalias(full_event_alias=vc) = vc
 DECLARE getitemgroupfromalias(alias=vc) = vc
 DECLARE findpersonname(person_id=f8) = vc
 IF ((((request->person_id <= 0.0)) OR ((request->prot_master_id <= 0.0))) )
  CALL report_failure("VALIDATE","F","REQUEST",
   "Request not valid, person_id and prot_master_id are required")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  DETAIL
   reply->user_id = reqinfo->updt_id, reply->user_name = p.username
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pt_prot_reg ppr,
   ct_pt_amd_assignment caa,
   prot_role pr,
   prsnl p,
   prot_amendment pa
  PLAN (ppr
   WHERE (ppr.person_id=request->person_id)
    AND (ppr.prot_master_id=request->prot_master_id)
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (caa
   WHERE ppr.reg_id=caa.reg_id
    AND caa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE pr.prot_amendment_id=caa.prot_amendment_id
    AND pr.prot_role_cd=princ_invest_cd
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=pr.person_id)
   JOIN (pa
   WHERE pa.prot_amendment_id=outerjoin(caa.prot_amendment_id))
  ORDER BY caa.assign_end_dt_tm
  DETAIL
   pt_reg_id = ppr.reg_id, reply->on_study_dt_tm = ppr.on_study_dt_tm, reply->subject_number = ppr
   .prot_accession_nbr
   IF (ppr.off_study_dt_tm <= cnvtdatetime(curdate,curtime3))
    reply->off_study_dt_tm = ppr.off_study_dt_tm
   ENDIF
   IF (ppr.tx_completion_dt_tm <= cnvtdatetime(curdate,curtime3))
    reply->off_treatment_dt_tm = ppr.tx_completion_dt_tm
   ENDIF
   reply->principal_investigator_id = p.person_id, reply->principal_investigator_name = p
   .name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pt_reg_consent_reltn prcr,
   pt_consent pc
  PLAN (prcr
   WHERE prcr.reg_id=pt_reg_id
    AND prcr.active_ind=1)
   JOIN (pc
   WHERE pc.consent_id=prcr.consent_id
    AND pc.reason_for_consent_cd=enrolling_cd)
  DETAIL
   IF (pc.consent_signed_dt_tm <= cnvtdatetime(curdate,curtime3))
    reply->consent_dt_tm = pc.consent_signed_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ct_pt_amd_assignment caa,
   prot_amendment pa
  PLAN (caa
   WHERE caa.reg_id=pt_reg_id
    AND caa.end_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND caa.assign_end_dt_tm <= cnvtdatetime(curdate,curtime3))
   JOIN (pa
   WHERE pa.prot_amendment_id=caa.prot_amendment_id)
  ORDER BY caa.assign_end_dt_tm DESC
  DETAIL
   reply->current_amendment_nbr = pa.amendment_nbr, reply->current_revision_nbr = pa.revision_nbr_txt
  WITH maxrec = 1, nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ct_pt_amd_assignment caa,
   prot_amendment pa
  PLAN (caa
   WHERE caa.reg_id=pt_reg_id
    AND caa.end_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND caa.assign_end_dt_tm <= cnvtdatetime(curdate,curtime3))
   JOIN (pa
   WHERE pa.prot_amendment_id=caa.prot_amendment_id)
  ORDER BY caa.assign_end_dt_tm
  DETAIL
   reply->original_amendment_nbr = pa.amendment_nbr, reply->original_revision_nbr = pa
   .revision_nbr_txt
  WITH maxrec = 1, nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person p
  PLAN (p
   WHERE (p.person_id=request->person_id))
  DETAIL
   reply->birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->birth_dt_tz = p.birth_tz, reply->race_cd
    = p.race_cd,
   reply->sex_cd = p.sex_cd, reply->ethnicity_cd = p.ethnic_grp_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prot_master pm
  PLAN (pm
   WHERE (pm.prot_master_id=request->prot_master_id)
    AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   reply->protocol_name = pm.primary_mnemonic
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=73
   AND cv.display_key="IDC"
  DETAIL
   idc_contributing_system = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value_outbound cvo
  WHERE cvo.contributor_source_cd=idc_contributing_system
  ORDER BY cvo.alias
  HEAD REPORT
   parent_event_group_events_count = 0, datetime_group_events_count = 0
  HEAD cvo.code_value
   type_flag = findstring(".DTTM",cvo.alias)
   IF (type_flag=0)
    parent_event_group_events_count = (parent_event_group_events_count+ 1)
    IF (parent_event_group_events_count > size(aliased_events->parent_event_group_events,5))
     stat = alterlist(aliased_events->parent_event_group_events,(parent_event_group_events_count+ 5))
    ENDIF
    aliased_events->parent_event_group_events[parent_event_group_events_count].event_cd = cvo
    .code_value, aliased_events->parent_event_group_events[parent_event_group_events_count].
    event_alias = cvo.alias
   ELSE
    datetime_group_events_count = (datetime_group_events_count+ 1)
    IF (datetime_group_events_count > size(aliased_events->datetime_group_events,5))
     stat = alterlist(aliased_events->datetime_group_events,(datetime_group_events_count+ 5))
    ENDIF
    aliased_events->datetime_group_events[datetime_group_events_count].event_cd = cvo.code_value,
    aliased_events->datetime_group_events[datetime_group_events_count].event_alias = cvo.alias
   ENDIF
  FOOT REPORT
   stat = alterlist(aliased_events->datetime_group_events,datetime_group_events_count), stat =
   alterlist(aliased_events->parent_event_group_events,parent_event_group_events_count)
  WITH nocounter
 ;end select
 IF (parent_event_group_events_count > 0)
  SET num = 0
  SELECT INTO "nl:"
   ce.event_end_dt_tm, ce.event_cd, ce.result_val,
   audit_person_id = nullval(cdr.updt_id,ce.updt_id), audit_dt_tm = nullval(cdr.updt_dt_tm,ce
    .updt_dt_tm)
   FROM clinical_event ce,
    ce_date_result cdr,
    ce_event_prsnl cep
   PLAN (ce
    WHERE expand(num,1,parent_event_group_events_count,ce.event_cd,aliased_events->
     parent_event_group_events[num].event_cd)
     AND (ce.person_id=request->person_id)
     AND ce.result_status_cd != inerror
     AND (ce.encntr_id=request->encounter_id)
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce.event_class_cd != audit_record)
    JOIN (cdr
    WHERE cdr.event_id=outerjoin(ce.event_id)
     AND cdr.valid_from_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND cdr.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (cep
    WHERE cep.event_id=outerjoin(ce.event_id)
     AND cep.valid_from_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND cep.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   ORDER BY ce.parent_event_id, aliased_events->parent_event_group_events[num].event_alias, ce
    .event_cd,
    ce.event_end_dt_tm
   HEAD REPORT
    group_cnt = 0
   HEAD ce.parent_event_id
    group_cnt = (group_cnt+ 1)
    IF (group_cnt > size(temp_events->event_group,5))
     stat = alterlist(temp_events->event_group,(group_cnt+ 5))
    ENDIF
    temp_events->event_group[group_cnt].performed_dt_tm = ce.event_end_dt_tm, temp_events->
    event_group[group_cnt].performed_person_id = audit_person_id, temp_events->event_group[group_cnt]
    .performed_tz = ce.event_end_tz,
    person_cnt = (person_cnt+ 1)
    IF (person_cnt > size(temp_persons->person_list,5))
     stat = alterlist(temp_persons->person_list,(person_cnt+ 5))
    ENDIF
    temp_persons->person_list[person_cnt].person_id = audit_person_id, event_cnt = 0
   HEAD ce.event_cd
    event_cnt = (event_cnt+ 1)
    IF (event_cnt > size(temp_events->event_group[group_cnt].events,5))
     stat = alterlist(temp_events->event_group[group_cnt].events,(event_cnt+ 5))
    ENDIF
   HEAD cep.event_id
    IF (cep.proxy_prsnl_id > 0)
     temp_events->event_group[group_cnt].events[event_cnt].event_task_person_id = cep.proxy_prsnl_id
    ELSE
     temp_events->event_group[group_cnt].events[event_cnt].event_task_person_id = cep.action_prsnl_id
    ENDIF
   DETAIL
    temp_events->event_group[group_cnt].events[event_cnt].event_cd = ce.event_cd, temp_events->
    event_group[group_cnt].events[event_cnt].event_name = uar_get_code_display(ce.event_cd)
    IF (cdr.result_dt_tm=0)
     temp_events->event_group[group_cnt].events[event_cnt].event_value = trim(ce.result_val)
     IF (isnumeric(ce.result_val)=0)
      temp_events->event_group[group_cnt].events[event_cnt].event_result_type = 0
     ELSE
      temp_events->event_group[group_cnt].events[event_cnt].event_result_type = 1
     ENDIF
    ELSE
     temp_events->event_group[group_cnt].events[event_cnt].event_dt_tm = cdr.result_dt_tm,
     temp_events->event_group[group_cnt].events[event_cnt].event_result_type = 2, temp_events->
     event_group[group_cnt].events[event_cnt].event_tz = cdr.result_tz
    ENDIF
    temp_events->event_group[group_cnt].events[event_cnt].event_unit = build(ce.result_units_cd),
    temp_events->event_group[group_cnt].events[event_cnt].event_status_cd = ce.result_status_cd,
    person_cnt = (person_cnt+ 2)
    IF (person_cnt > size(temp_persons->person_list,5))
     stat = alterlist(temp_persons->person_list,(person_cnt+ 5))
    ENDIF
    temp_persons->person_list[(person_cnt - 1)].person_id = temp_events->event_group[group_cnt].
    events[event_cnt].event_task_person_id, temp_persons->person_list[person_cnt].person_id =
    audit_person_id, temp_events->event_group[group_cnt].events[event_cnt].performed_person_id =
    audit_person_id,
    temp_events->event_group[group_cnt].events[event_cnt].performed_dt_tm = audit_dt_tm, temp_events
    ->event_group[group_cnt].events[event_cnt].performed_tz = ce.event_end_tz, index = locateval(num,
     1,parent_event_group_events_count,ce.event_cd,aliased_events->parent_event_group_events[num].
     event_cd),
    temp_events->event_group[group_cnt].events[event_cnt].event_alias = aliased_events->
    parent_event_group_events[index].event_alias, temp_events->event_group[group_cnt].events[
    event_cnt].parent_event_alias = getitemgroupfromalias(aliased_events->parent_event_group_events[
     index].event_alias)
   FOOT  ce.parent_event_id
    stat = alterlist(temp_events->event_group[group_cnt].events,event_cnt)
   FOOT REPORT
    stat = alterlist(temp_events->event_group,group_cnt)
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF (datetime_group_events_count > 0)
  SET num = 0
  SELECT INTO "nl:"
   ce.event_end_dt_tm, ce.event_cd, ce.result_val,
   audit_person_id = nullval(cdr.updt_id,ce.updt_id), audit_dt_tm = nullval(cdr.updt_dt_tm,ce
    .updt_dt_tm)
   FROM clinical_event ce,
    ce_date_result cdr
   PLAN (ce
    WHERE expand(num,1,datetime_group_events_count,ce.event_cd,aliased_events->datetime_group_events[
     num].event_cd)
     AND (ce.person_id=request->person_id)
     AND ce.result_status_cd != inerror
     AND (ce.encntr_id=request->encounter_id)
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce.event_class_cd != audit_record)
    JOIN (cdr
    WHERE cdr.event_id=outerjoin(ce.event_id)
     AND cdr.valid_from_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND cdr.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   ORDER BY ce.event_end_dt_tm, aliased_events->datetime_group_events[num].event_alias
   HEAD ce.event_end_dt_tm
    group_cnt = (group_cnt+ 1)
    IF (group_cnt > size(temp_events->event_group,5))
     stat = alterlist(temp_events->event_group,(group_cnt+ 5))
    ENDIF
    temp_events->event_group[group_cnt].performed_dt_tm = ce.event_end_dt_tm, temp_events->
    event_group[group_cnt].performed_person_id = audit_person_id, temp_events->event_group[group_cnt]
    .performed_tz = ce.event_end_tz,
    person_cnt = (person_cnt+ 1)
    IF (person_cnt > size(temp_persons->person_list,5))
     stat = alterlist(temp_persons->person_list,(person_cnt+ 5))
    ENDIF
    temp_persons->person_list[person_cnt].person_id = audit_person_id, event_cnt = 0
   HEAD ce.event_cd
    event_cnt = (event_cnt+ 1)
    IF (event_cnt > size(temp_events->event_group[group_cnt].events,5))
     stat = alterlist(temp_events->event_group[group_cnt].events,(event_cnt+ 5))
    ENDIF
   DETAIL
    temp_events->event_group[group_cnt].events[event_cnt].event_cd = ce.event_cd, temp_events->
    event_group[group_cnt].events[event_cnt].event_name = uar_get_code_display(ce.event_cd)
    IF (cdr.result_dt_tm=0)
     temp_events->event_group[group_cnt].events[event_cnt].event_value = trim(ce.result_val)
     IF (isnumeric(ce.result_val)=0)
      temp_events->event_group[group_cnt].events[event_cnt].event_result_type = 0
     ELSE
      temp_events->event_group[group_cnt].events[event_cnt].event_result_type = 1
     ENDIF
    ELSE
     temp_events->event_group[group_cnt].events[event_cnt].event_dt_tm = cdr.result_dt_tm,
     temp_events->event_group[group_cnt].events[event_cnt].event_result_type = 2, temp_events->
     event_group[group_cnt].events[event_cnt].event_tz = cdr.result_tz
    ENDIF
    temp_events->event_group[group_cnt].events[event_cnt].event_unit = build(ce.result_units_cd),
    temp_events->event_group[group_cnt].events[event_cnt].event_status_cd = ce.result_status_cd,
    temp_events->event_group[group_cnt].events[event_cnt].performed_person_id = audit_person_id,
    person_cnt = (person_cnt+ 1)
    IF (person_cnt > size(temp_persons->person_list,5))
     stat = alterlist(temp_persons->person_list,(person_cnt+ 5))
    ENDIF
    temp_persons->person_list[person_cnt].person_id = audit_person_id, temp_events->event_group[
    group_cnt].events[event_cnt].performed_dt_tm = audit_dt_tm, temp_events->event_group[group_cnt].
    events[event_cnt].performed_tz = ce.event_end_tz,
    index = locateval(num,1,datetime_group_events_count,ce.event_cd,aliased_events->
     datetime_group_events[num].event_cd), temp_events->event_group[group_cnt].events[event_cnt].
    event_alias = aliased_events->datetime_group_events[index].event_alias, temp_events->event_group[
    group_cnt].events[event_cnt].parent_event_alias = getitemgroupfromalias(aliased_events->
     datetime_group_events[index].event_alias)
   FOOT  ce.parent_event_id
    stat = alterlist(temp_events->event_group[group_cnt].events,event_cnt)
   FOOT REPORT
    stat = alterlist(temp_events->event_group,group_cnt), stat = alterlist(temp_persons->person_list,
     person_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (person_cnt > 0)
  SET num = 0
  SELECT INTO "nl:"
   FROM prsnl p,
    (dummyt d1  WITH seq = person_cnt)
   PLAN (d1)
    JOIN (p
    WHERE (p.person_id=temp_persons->person_list[d1.seq].person_id))
   DETAIL
    temp_persons->person_list[d1.seq].person_name = p.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 FOR (indexgroup = 1 TO group_cnt)
   SET event_cnt = size(temp_events->event_group[indexgroup].events,5)
   SET current_event_group_count = 0
   FOR (indexevent = 1 TO event_cnt)
     SET current_item_group = temp_events->event_group[indexgroup].events[indexevent].
     parent_event_alias
     IF (current_item_group != previous_item_group)
      SET reply_group_count = (reply_group_count+ 1)
      SET current_event_group_count = 1
      SET stat = alterlist(reply->event_group,reply_group_count)
      SET stat = alterlist(reply->event_group[reply_group_count].events,current_event_group_count)
     ELSEIF (current_item_group=previous_item_group)
      SET current_event_group_count = (current_event_group_count+ 1)
      SET stat = alterlist(reply->event_group[reply_group_count].events,current_event_group_count)
     ENDIF
     SET curalias itemgroup reply->event_group[reply_group_count]
     SET curalias reply_item reply->event_group[reply_group_count].events[current_event_group_count]
     SET curalias temp_item_group temp_events->event_group[indexgroup]
     SET curalias temp_item temp_events->event_group[indexgroup].events[indexevent]
     SET reply_item->event_cd = temp_item->event_cd
     SET reply_item->event_name = temp_item->event_name
     SET reply_item->event_value = temp_item->event_value
     SET reply_item->event_result_type = temp_item->event_result_type
     SET reply_item->event_unit = trim(getcodedvalue(temp_item->event_unit))
     SET reply_item->event_dt_tm = temp_item->event_dt_tm
     SET reply_item->event_status_cd = temp_item->event_status_cd
     SET reply_item->performed_person_id = temp_item->performed_person_id
     SET reply_item->performed_person = findpersonname(temp_item->performed_person_id)
     SET reply_item->performed_dt_tm = temp_item->performed_dt_tm
     SET reply_item->event_alias = getalias(temp_item->event_alias)
     SET reply_item->event_task_person = findpersonname(temp_item->event_task_person_id)
     SET itemgroup->parent_event_alias = temp_item->parent_event_alias
     SET itemgroup->performed_dt_tm = temp_item_group->performed_dt_tm
     SET itemgroup->performed_person_id = temp_item_group->performed_person_id
     SET itemgroup->performed_person = findpersonname(temp_item_group->performed_person_id)
     SET itemgroup->performed_tz = temp_item_group->performed_tz
     SET previous_item_group = current_item_group
     SET curalias itemgroup off
     SET curalias reply_item off
     SET curalias temp_item_group off
     SET curalias temp_item off
   ENDFOR
   SET current_item_group = ""
   SET previous_item_group = ""
 ENDFOR
 IF ((request->con_med_unit_cd=month_cd))
  SET tmpconmed = concat(cnvtstring(request->con_med_time),",M")
  SET conmeddttm = cnvtlookbehind(tmpconmed,reply->on_study_dt_tm)
 ELSEIF ((request->con_med_unit_cd=year_cd))
  SET tmpconmed = concat(cnvtstring(request->con_med_time),",Y")
  SET conmeddttm = cnvtlookbehind(tmpconmed,reply->on_study_dt_tm)
 ELSEIF ((request->con_med_unit_cd=day_cd))
  SET tmpconmed = concat(cnvtstring(request->con_med_time),",D")
  SET conmeddttm = cnvtlookbehind(tmpconmed,reply->on_study_dt_tm)
 ELSE
  SET conmeddttm = cnvtdatetime(curdate,curtime3)
 ENDIF
 IF (conmeddttm > 0)
  SET conmeddttm = datetimefind(conmeddttm,"D","E","B")
 ENDIF
 IF ((request->condition_unit_cd=month_cd))
  SET tmpcondition = concat(cnvtstring(request->condition_time),",M")
  SET conditiondttm = cnvtlookbehind(tmpcondition,reply->on_study_dt_tm)
 ELSEIF ((request->condition_unit_cd=year_cd))
  SET tmpcondition = concat(cnvtstring(request->condition_time),",Y")
  SET conditiondttm = cnvtlookbehind(tmpcondition,reply->on_study_dt_tm)
 ELSEIF ((request->condition_unit_cd=day_cd))
  SET tmpcondition = concat(cnvtstring(request->condition_time),",D")
  SET conditiondttm = cnvtlookbehind(tmpcondition,reply->on_study_dt_tm)
 ELSE
  SET conditiondttm = cnvtdatetime(curdate,curtime3)
 ENDIF
 IF (conditiondttm > 0)
  SET conditiondttm = datetimefind(conditiondttm,"D","E","B")
 ENDIF
 CALL echo(build("Finding all AE's since",format(conditiondttm,";;q")))
 SELECT INTO "NL:"
  pr.*
  FROM problem pr,
   nomenclature n,
   prsnl p
  PLAN (pr
   WHERE (pr.person_id=request->person_id)
    AND pr.active_ind=1
    AND ((pr.life_cycle_status_cd IN (active_cd, inactive_cd, resolved_cd)
    AND pr.onset_dt_tm >= cnvtdatetime(conditiondttm)) OR (pr.life_cycle_status_cd=active_cd)) )
   JOIN (n
   WHERE n.nomenclature_id=pr.nomenclature_id)
   JOIN (p
   WHERE p.person_id=pr.updt_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->aes,(cnt+ 9))
   ENDIF
   reply->aes[cnt].ae_model_name = "PROBLEM", reply->aes[cnt].ae_id = pr.problem_id
   IF (pr.nomenclature_id > 0.0)
    reply->aes[cnt].description = n.source_string
   ELSE
    reply->aes[cnt].description = pr.problem_ftdesc
   ENDIF
   reply->aes[cnt].onset_dt_tm = pr.onset_dt_tm, reply->aes[cnt].onset_prec_flag = pr.onset_dt_flag,
   reply->aes[cnt].onset_tz = pr.onset_tz
   IF (pr.life_cycle_status_cd=resolved_cd)
    reply->aes[cnt].ongoing_ind = 0, reply->aes[cnt].resolved_dt_tm = pr.life_cycle_dt_tm, reply->
    aes[cnt].resolved_prec_flag = pr.life_cycle_dt_flag,
    reply->aes[cnt].resolved_tz = pr.life_cycle_tz
   ELSE
    reply->aes[cnt].ongoing_ind = 1
   ENDIF
   reply->aes[cnt].severity_flag = severityvalue(pr.severity_cd), reply->aes[cnt].severity_category
    = pr.severity_cd, reply->aes[cnt].performed_person = p.name_full_formatted,
   reply->aes[cnt].performed_dt_tm = pr.updt_dt_tm, reply->aes[cnt].performed_tz = pr.onset_tz
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM diagnosis d,
   nomenclature n,
   prsnl p
  PLAN (d
   WHERE (d.person_id=request->person_id)
    AND d.active_ind=1
    AND d.diag_dt_tm >= cnvtdatetime(conditiondttm)
    AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id)
   JOIN (p
   WHERE p.person_id=d.diag_prsnl_id)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->aes,(cnt+ 9))
   ENDIF
   reply->aes[cnt].ae_model_name = "DIAGNOSIS", reply->aes[cnt].ae_id = d.diagnosis_id
   IF (d.nomenclature_id > 0.0)
    reply->aes[cnt].description = n.source_string
   ELSE
    reply->aes[cnt].description = d.diag_ftdesc
   ENDIF
   reply->aes[cnt].onset_dt_tm = d.diag_dt_tm, reply->aes[cnt].onset_prec_flag = 0, reply->aes[cnt].
   severity_flag = severityvalue(d.severity_cd),
   reply->aes[cnt].severity_category = d.severity_cd, reply->aes[cnt].performed_person = p
   .name_full_formatted, reply->aes[cnt].performed_dt_tm = d.diag_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  reaction_found_ind = evaluate(nullind(r.reaction_id),0,1,1,0)
  FROM allergy a,
   nomenclature n_a,
   reaction r,
   nomenclature n_r,
   prsnl p
  PLAN (a
   WHERE (a.person_id=request->person_id)
    AND a.active_ind=1
    AND ((a.reaction_status_cd IN (active_allergy_cd, proposed_cd, resolved_allergy_cd)
    AND a.onset_dt_tm >= cnvtdatetime(conditiondttm)) OR (a.reaction_status_cd=active_allergy_cd)) )
   JOIN (n_a
   WHERE n_a.nomenclature_id=a.substance_nom_id)
   JOIN (r
   WHERE r.allergy_id=outerjoin(a.allergy_id)
    AND r.active_ind=outerjoin(1))
   JOIN (n_r
   WHERE n_r.nomenclature_id=outerjoin(r.reaction_nom_id))
   JOIN (p
   WHERE p.person_id=a.created_prsnl_id)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->aes,(cnt+ 9))
   ENDIF
   reply->aes[cnt].ae_model_name = "ALLERGY", reply->aes[cnt].ae_id = a.allergy_id
   IF (a.substance_nom_id > 0.0)
    reply->aes[cnt].description = n_a.source_string
   ELSE
    reply->aes[cnt].description = a.substance_ftdesc
   ENDIF
   IF (reaction_found_ind=1)
    reply->aes[cnt].ae_sub_id = r.reaction_id
    IF (n_r.nomenclature_id > 0.0)
     reply->aes[cnt].reaction = n_r.source_string
    ELSE
     reply->aes[cnt].reaction = r.reaction_ftdesc
    ENDIF
   ENDIF
   reply->aes[cnt].onset_dt_tm = a.onset_dt_tm, reply->aes[cnt].onset_prec_flag = a
   .onset_precision_flag, reply->aes[cnt].onset_tz = a.onset_tz,
   reply->aes[cnt].severity_flag = severityvalue(a.severity_cd), reply->aes[cnt].severity_category =
   a.severity_cd, reply->aes[cnt].performed_person = p.name_full_formatted,
   reply->aes[cnt].performed_dt_tm = a.created_dt_tm, reply->aes[cnt].performed_tz = a
   .beg_effective_tz
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->aes,cnt)
 CALL echo(build("conMedDtTm=",format(conditiondttm,";;q")))
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od,
   prsnl p
  PLAN (o
   WHERE (o.person_id=request->person_id)
    AND o.catalog_type_cd=pharm_cd
    AND o.template_order_flag < 2
    AND o.order_status_cd IN (ordered_cd, completed_cd)
    AND ((o.projected_stop_dt_tm >= cnvtdatetime(conmeddttm)) OR (o.projected_stop_dt_tm=null)) )
   JOIN (od
   WHERE od.order_id=o.order_id)
   JOIN (p
   WHERE p.person_id=o.status_prsnl_id)
  ORDER BY o.order_id, od.oe_field_meaning, od.updt_dt_tm
  HEAD REPORT
   cnt = 0
  HEAD o.order_id
   med_disp = "", strength = "", strength_cd = 0.0,
   strength_unit = "", strenth_unit_cd = 0.0, route = "",
   route_cd = 0.0, frequency = "", frequency_cd = 0.0,
   form = "", form_cd = 0.0, cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->conmeds,(cnt+ 9))
   ENDIF
   med_disp = o.hna_order_mnemonic, reply->conmeds[cnt].med_start_dt_tm = o.current_start_dt_tm,
   reply->conmeds[cnt].med_start_tz = o.current_start_tz
   IF (o.projected_stop_dt_tm <= cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND o.projected_stop_dt_tm > cnvtdatetime(curdate,curtime3))
    reply->conmeds[cnt].med_end_dt_tm = o.projected_stop_dt_tm, reply->conmeds[cnt].med_end_tz = o
    .projected_stop_tz, reply->conmeds[cnt].med_end_val = 0
   ELSE
    reply->conmeds[cnt].med_end_val = 1
   ENDIF
   reply->conmeds[cnt].order_id = o.order_id, reply->conmeds[cnt].performed_person = p
   .name_full_formatted, reply->conmeds[cnt].performed_dt_tm = o.status_dt_tm
  DETAIL
   CASE (od.oe_field_meaning)
    OF "STRENGTHDOSE":
     strength = trim(od.oe_field_display_value),strength_cd = od.oe_field_value
    OF "STRENGTHDOSEUNIT":
     strength_unit = trim(od.oe_field_display_value),strength_unit_cd = od.oe_field_value
    OF "FREQ":
     frequency = trim(od.oe_field_display_value),frequency_cd = od.oe_field_value
    OF "RXROUTE":
     route = trim(od.oe_field_display_value),route_cd = od.oe_field_value
    OF "DRUGFORM":
     form = trim(od.oe_field_display_value),form_cd = od.oe_field_value
   ENDCASE
  FOOT  o.group_order_id
   reply->conmeds[cnt].med_name = med_disp, reply->conmeds[cnt].med_dose = trim(strength), reply->
   conmeds[cnt].med_dose_unit = trim(strength_unit),
   reply->conmeds[cnt].med_dose_unit_cd = strength_unit_cd, reply->conmeds[cnt].med_frequency = trim(
    frequency), reply->conmeds[cnt].med_frequency_cd = frequency_cd,
   reply->conmeds[cnt].med_route = trim(route), reply->conmeds[cnt].med_route_cd = route_cd, reply->
   conmeds[cnt].med_form = trim(form),
   reply->conmeds[cnt].med_form_cd = form_cd
  FOOT REPORT
   stat = alterlist(reply->conmeds,cnt)
  WITH nocounter
 ;end select
 SUBROUTINE getalias(full_event_alias)
   DECLARE event_alias = vc WITH protect
   DECLARE item_group_alias = vc WITH protect
   SET item_group_alias = getitemgroupfromalias(full_event_alias)
   SET ig_alias_size = (size(trim(item_group_alias))+ 1)
   SET type_flag = findstring(".DTTM",full_event_alias)
   IF (type_flag > 0)
    SET alias_size = ((size(trim(full_event_alias)) - 5) - ig_alias_size)
    SET event_alias = substring((ig_alias_size+ 1),alias_size,full_event_alias)
   ELSE
    SET alias_size = (size(trim(full_event_alias)) - ig_alias_size)
    SET event_alias = substring((ig_alias_size+ 1),alias_size,full_event_alias)
   ENDIF
   RETURN(event_alias)
 END ;Subroutine
 SUBROUTINE getitemgroupfromalias(alias)
   DECLARE event_item_group = vc WITH protect
   SET item_group_end = (findstring(".",alias) - 1)
   IF (item_group_end > 0)
    SET event_item_group = substring(1,item_group_end,alias)
   ELSE
    SET event_item_group = alias
   ENDIF
   RETURN(event_item_group)
 END ;Subroutine
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   IF (opstatus="F")
    SET cfailed = "T"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
 SUBROUTINE severityvalue(sev_cd)
   DECLARE sev_cdf = c12 WITH protect, noconstant(fillstring(12," "))
   DECLARE sev_flag = vc WITH protect
   SET sev_cdf = uar_get_code_meaning(sev_cd)
   IF (((sev_cdf="1") OR (((sev_cdf="I") OR (((sev_cdf="LOW") OR (sev_cdf="MILD")) )) )) )
    SET sev_flag = "MILD"
   ELSEIF (((sev_cdf="2") OR (((sev_cdf="II") OR (((sev_cdf="MEDIUM") OR (sev_cdf="MODERATE")) )) ))
   )
    SET sev_flag = "MODERATE"
   ELSEIF (((sev_cdf="3") OR (((sev_cdf="4") OR (((sev_cdf="HIGH") OR (((sev_cdf="III") OR (((sev_cdf
   ="IV") OR (((sev_cdf="SEVERE") OR (sev_cdf="V")) )) )) )) )) )) )
    SET sev_flag = "SEVERE"
   ENDIF
   RETURN(sev_flag)
 END ;Subroutine
 SUBROUTINE findpersonname(person_id)
   DECLARE person_name = vc WITH protect, noconstant("")
   DECLARE nbr = i4 WITH proctect, noconstant(0)
   DECLARE start_index = i4 WITH protect, noconstant(1)
   DECLARE index = i4 WITH protect, noconstant(0)
   SET index = locateval(nbr,start_index,person_cnt,person_id,temp_persons->person_list[nbr].
    person_id)
   SET person_name = temp_persons->person_list[index].person_name
   RETURN(person_name)
 END ;Subroutine
#exit_script
 IF (failedind="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "008"
 SET mod_date = "March 18, 2014"
END GO
