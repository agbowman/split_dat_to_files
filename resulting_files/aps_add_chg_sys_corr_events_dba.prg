CREATE PROGRAM aps_add_chg_sys_corr_events:dba
 RECORD req200393(
   1 called_from_script_ind = i2
   1 return_inactive_ind = i2
   1 return_trigger_ind = i2
   1 return_lookback_ind = i2
   1 sys_corr_qual[*]
     2 sys_corr_id = f8
 )
 RECORD reply200393(
   1 sys_corr_qual[*]
     2 sys_corr_id = f8
     2 study_id = f8
     2 case_percentage = i2
     2 active_ind = i2
     2 execute_on_rescreen_ind = i2
     2 lookback_case_type_cd = f8
     2 lookback_months = i2
     2 lookback_all_cases_ind = i2
     2 notify_user_online_ind = i2
     2 assign_to_group_ind = i2
     2 assign_to_group_id = f8
     2 assign_to_prsnl_id = f8
     2 assign_to_verifying_ind = i2
     2 updt_cnt = i4
     2 param_qual[*]
       3 param_name = c20
       3 param_sequence = i4
       3 lookback_ind = i2
       3 detail_qual[*]
         4 parent_entity_name = c32
         4 parent_entity_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD req200402(
   1 called_from_script_ind = i2
   1 event_qual[*]
     2 add_ind = i2
     2 upd_ind = i2
     2 del_ind = i2
     2 event_id = f8
     2 study_id = f8
     2 case_id = f8
     2 correlate_case_id = f8
     2 sys_corr_id = f8
     2 init_eval_term_id = f8
     2 init_discrep_term_id = f8
     2 disagree_reason_cd = f8
     2 investigation_cd = f8
     2 resolution_cd = f8
     2 final_eval_term_id = f8
     2 final_discrep_term_id = f8
     2 initiated_prsnl_id = f8
     2 initiated_dt_tm = dq8
     2 complete_prsnl_id = f8
     2 complete_dt_tm = dq8
     2 complete_day_dt_tm = dq8
     2 cancel_prsnl_id = f8
     2 cancel_dt_tm = dq8
     2 slide_counts = f8
     2 apply_slide_counts = i4
     2 apply_slide_counts_to_id = f8
     2 apply_to_day_dt_tm = dq8
     2 apply_to_month_dt_tm = dq8
     2 report_issued_by_prsnl_id = f8
     2 assign_to_group_ind = i2
     2 prsnl_group_id = f8
     2 long_text_id = f8
     2 comment = vc
     2 updt_cnt = i4
     2 prsnl_qual[*]
       3 prsnl_id = f8
       3 temp_ind = i2
 )
 RECORD reply200402(
   1 event_qual[*]
     2 event_id = f8
     2 long_text_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 case_qual[*]
     2 case_id = f8
     2 correlate_case_id = f8
 )
 RECORD reply(
   1 notify_user_online_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 DECLARE x = i2
 DECLARE y = i2
 DECLARE z = i2
 DECLARE event_cnt = i2
 DECLARE across_case_ind = i2
 DECLARE qualified_cases = i4
 DECLARE total_cases = i4
 DECLARE error_cnt = i2
 DECLARE verified_cd = f8 WITH protected, noconstant(0.0)
 DECLARE corrected_cd = f8 WITH protected, noconstant(0.0)
 DECLARE signinproc_cd = f8 WITH protected, noconstant(0.0)
 DECLARE csigninproc_cd = f8 WITH protected, noconstant(0.0)
 DECLARE deleted_status_cd = f8 WITH protected, noconstant(0.0)
 DECLARE case_cnt = i2 WITH private, noconstant(0)
 DECLARE aqi_flag = i2 WITH private, noconstant(0)
 DECLARE cs_flag = i2 WITH private, noconstant(0)
 DECLARE cr_flag = i2 WITH private, noconstant(0)
 DECLARE ce_flag = i2 WITH private, noconstant(0)
 DECLARE cecr_flag = i2 WITH private, noconstant(0)
 DECLARE sys_corr_cnt = i2 WITH private, noconstant(0)
 DECLARE sys_corr_param_cnt = i2 WITH private, noconstant(0)
 DECLARE call_update_script_ind = i2 WITH private, noconstant(0)
 DECLARE found_ind = i2 WITH private, noconstant(0)
 DECLARE pc_prefixes = vc WITH private, noconstant(" ")
 DECLARE pc_lookback = vc WITH private, noconstant(" ")
 DECLARE pc_person = vc WITH private, noconstant(" ")
 DECLARE pc_case_type = vc WITH private, noconstant(" ")
 DECLARE aqi_normalcies = vc WITH private, noconstant(" ")
 DECLARE cs_specimens = vc WITH private, noconstant(" ")
 DECLARE cr_reports = vc WITH private, noconstant(" ")
 DECLARE ce_tasks = vc WITH private, noconstant(" ")
 DECLARE cecr_responses = vc WITH private, noconstant(" ")
 DECLARE lookback_str = vc WITH private, noconstant(" ")
 DECLARE select_statement = vc WITH private, noconstant(" ")
 DECLARE temp_string = vc WITH private, noconstant(" ")
 DECLARE rdm_errmsg = vc WITH private, noconstant(" ")
 SET lookback_dt_tm = cnvtdatetime(sysdate)
 DECLARE buildmultiwhere(bmworigwhere,bmwtablefield,bmwitemvalue) = c500
 DECLARE handle_errors(op_name,op_status,tar_name,tar_value) = null
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET stat = uar_get_meaning_by_codeset(1305,"VERIFIED",1,verified_cd)
 IF (verified_cd=0.0)
  CALL handle_errors("UAR","F","1305","verified_cd")
  SET error_cnt = 1
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"CORRECTED",1,corrected_cd)
 IF (corrected_cd=0.0)
  CALL handle_errors("UAR","F","1305","corrected_cd")
  SET error_cnt = 1
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"SIGNINPROC",1,signinproc_cd)
 IF (signinproc_cd=0.0)
  CALL handle_errors("UAR","F","1305","signinproc_cd")
  SET error_cnt = 1
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"CSIGNINPROC",1,csigninproc_cd)
 IF (csigninproc_cd=0.0)
  CALL handle_errors("UAR","F","1305","csigninproc_cd")
  SET error_cnt = 1
  GO TO exit_script
 ENDIF
 SET placeholder_cd = uar_get_code_by("MEANING",53,"PLACEHOLDER")
 IF (placeholder_cd=0.0)
  CALL handle_errors("UAR","F","53","placeholder_cd")
  SET error_cnt = 1
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(48,"DELETED",1,deleted_status_cd)
 SELECT INTO "nl:"
  adce.event_id
  FROM ap_dc_event adce
  PLAN (adce
   WHERE adce.initiated_prsnl_id IN (0, null)
    AND adce.cancel_prsnl_id IN (0, null)
    AND (adce.case_id=request->case_id))
  HEAD REPORT
   event_cnt = 0
  DETAIL
   event_cnt += 1
   IF (mod(event_cnt,10)=1)
    stat = alterlist(req200402->event_qual,(event_cnt+ 10))
   ENDIF
   IF (adce.init_eval_term_id=0)
    req200402->event_qual[event_cnt].del_ind = 1, call_update_script_ind = 1
   ENDIF
   req200402->event_qual[event_cnt].event_id = adce.event_id, req200402->event_qual[event_cnt].
   case_id = adce.case_id, req200402->event_qual[event_cnt].correlate_case_id = adce
   .correlate_case_id,
   req200402->event_qual[event_cnt].sys_corr_id = adce.sys_corr_id, req200402->event_qual[event_cnt].
   init_eval_term_id = adce.init_eval_term_id, req200402->event_qual[event_cnt].slide_counts = adce
   .slide_counts,
   req200402->event_qual[event_cnt].updt_cnt = adce.updt_cnt
  FOOT REPORT
   stat = alterlist(req200402->event_qual,event_cnt)
  WITH nocounter
 ;end select
 SET sys_corr_cnt = cnvtint(size(request->sys_corr_qual,5))
 IF (sys_corr_cnt > 0)
  SET stat = alterlist(req200393->sys_corr_qual,sys_corr_cnt)
  SET req200393->called_from_script_ind = 1
  SET req200393->return_trigger_ind = 0
  SET req200393->return_lookback_ind = 1
  SET req200393->return_inactive_ind = 0
  FOR (x = 1 TO sys_corr_cnt)
    SET req200393->sys_corr_qual[x].sys_corr_id = request->sys_corr_qual[x].sys_corr_id
  ENDFOR
  EXECUTE aps_get_db_sys_corr_params
  IF ((reply200393->status_data.status != "S"))
   SET reply->status_data.status = reply200393->status_data.status
   SET error_cnt = 1
   GO TO exit_script
  ENDIF
  SET sys_corr_cnt = cnvtint(size(reply200393->sys_corr_qual,5))
 ENDIF
 FOR (x = 1 TO sys_corr_cnt)
   SET aqi_flag = 0
   SET cs_flag = 0
   SET cr_flag = 0
   SET ce_flag = 0
   SET cecr_flag = 0
   SET pc_prefixes = ""
   SET pc_lookback = ""
   SET pc_case_type = ""
   SET pc_person = ""
   SET lookback_str = ""
   SET aqi_normalcies = ""
   SET cs_specimens = ""
   SET cr_reports = ""
   SET ce_tasks = ""
   SET cecr_responses = ""
   SET select_statement = ""
   SET case_cnt = 0
   SET across_case_ind = 0
   SET stat = alterlist(temp->case_qual,0)
   SELECT INTO "nl:"
    ads.across_case_ind
    FROM ap_dc_study ads
    WHERE (reply200393->sys_corr_qual[x].study_id=ads.study_id)
    DETAIL
     across_case_ind = ads.across_case_ind
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL handle_errors("SELECT","F","TABLE","AP_DC_STUDY")
    GO TO exit_script
   ENDIF
   SET sys_corr_param_cnt = cnvtint(size(reply200393->sys_corr_qual[x].param_qual,5))
   FOR (y = 1 TO sys_corr_param_cnt)
     CASE (trim(reply200393->sys_corr_qual[x].param_qual[y].param_name))
      OF "PREFIX":
       SET pc_prefixes = buildmultiwhere(trim(pc_prefixes),"pc.prefix_id",cnvtstring(reply200393->
         sys_corr_qual[x].param_qual[y].detail_qual[1].parent_entity_id,32,2))
      OF "NORMALCY":
       SET aqi_flag = 1
       SET aqi_normalcies = buildmultiwhere(trim(aqi_normalcies),"aqi.flag_type_cd",cnvtstring(
         reply200393->sys_corr_qual[x].param_qual[y].detail_qual[1].parent_entity_id,32,2))
      OF "SPECIMEN":
       SET cs_flag = 1
       SET cs_specimens = buildmultiwhere(trim(cs_specimens),"cs.specimen_cd",cnvtstring(reply200393
         ->sys_corr_qual[x].param_qual[y].detail_qual[1].parent_entity_id,32,2))
      OF "REPORT":
       SET cr_flag = 1
       SET cr_reports = buildmultiwhere(trim(cr_reports),"cr.catalog_cd",cnvtstring(reply200393->
         sys_corr_qual[x].param_qual[y].detail_qual[1].parent_entity_id,32,2))
      OF "SECTION":
       IF (cnvtint(size(reply200393->sys_corr_qual[x].param_qual[y].detail_qual,5))=2)
        SET cr_flag = 1
        SET ce_flag = 1
        SET cr_reports = buildmultiwhere(trim(cr_reports),"cr.catalog_cd",cnvtstring(reply200393->
          sys_corr_qual[x].param_qual[y].detail_qual[1].parent_entity_id,32,2))
        SET ce_tasks = buildmultiwhere(trim(ce_tasks),"ce.task_assay_cd",cnvtstring(reply200393->
          sys_corr_qual[x].param_qual[y].detail_qual[2].parent_entity_id,32,2))
       ENDIF
      OF "ALPHA":
       IF (cnvtint(size(reply200393->sys_corr_qual[x].param_qual[y].detail_qual,5))=3)
        SET cr_flag = 1
        SET ce_flag = 1
        SET cecr_flag = 1
        SET cr_reports = buildmultiwhere(trim(cr_reports),"cr.catalog_cd",cnvtstring(reply200393->
          sys_corr_qual[x].param_qual[y].detail_qual[1].parent_entity_id,32,2))
        SET ce_tasks = buildmultiwhere(trim(ce_tasks),"ce.task_assay_cd",cnvtstring(reply200393->
          sys_corr_qual[x].param_qual[y].detail_qual[2].parent_entity_id,32,2))
        SET cecr_responses = buildmultiwhere(trim(cecr_responses),"cecr.nomenclature_id",cnvtstring(
          reply200393->sys_corr_qual[x].param_qual[y].detail_qual[3].parent_entity_id,32,2))
       ENDIF
     ENDCASE
   ENDFOR
   SET select_statement = "select distinct(pc.case_id) from pathology_case pc"
   IF (aqi_flag=1)
    SET select_statement = concat(select_statement,", ap_qa_info aqi")
   ENDIF
   IF (cs_flag=1)
    SET select_statement = concat(select_statement,", case_specimen cs")
   ENDIF
   IF (cr_flag=1)
    SET select_statement = concat(select_statement,", case_report cr")
   ENDIF
   IF (ce_flag=1)
    SET select_statement = concat(select_statement,", clinical_event ce")
   ENDIF
   IF (cecr_flag=1)
    SET select_statement = concat(select_statement,", ce_coded_result cecr")
   ENDIF
   IF (across_case_ind=1)
    SET pc_person = build("pc.person_id = ",request->person_id)
    SET pc_case_type = build("pc.case_type_cd = ",reply200393->sys_corr_qual[x].lookback_case_type_cd
     )
    SET lookback_dt_tm = cnvtagedatetime(0,reply200393->sys_corr_qual[x].lookback_months,0,0)
    SET lookback_str = build(format(cnvtdatetime(lookback_dt_tm),"dd-mmm-yyyy;;d"),",00:00:00")
    SET pc_lookback = concat("pc.main_report_cmplete_dt_tm+0 > ","cnvtdatetime(","'",trim(
      lookback_str),"'",
     ")")
    SET select_statement = concat(select_statement," plan pc where pc.cancel_cd in (0, null) and ",
     pc_person," and ",pc_case_type,
     " and ",pc_lookback,build2(" and not pc.case_id=",request->case_id))
    IF (pc_prefixes != "")
     SET select_statement = concat(select_statement," and ",pc_prefixes)
    ENDIF
   ELSE
    SET select_statement = concat(select_statement," plan pc where ",build("pc.case_id = ",request->
      case_id))
   ENDIF
   IF (aqi_flag=1)
    SET select_statement = concat(select_statement,
     " join aqi where pc.case_id = aqi.case_id and aqi.active_ind = 1 and ",aqi_normalcies)
   ENDIF
   IF (cs_flag=1)
    SET select_statement = concat(select_statement,
     " join cs where pc.case_id = cs.case_id and cs.cancel_cd in (0, null) and ",cs_specimens)
   ENDIF
   IF (cr_flag=1)
    SET select_statement = concat(select_statement,
     " join cr where pc.case_id = cr.case_id and cr.cancel_cd in (0, null) and ",cr_reports)
    SET select_statement = concat(select_statement," and cr.status_cd IN (")
    SET select_statement = build(select_statement,verified_cd,",",corrected_cd,",",
     signinproc_cd,",",csigninproc_cd,")")
   ENDIF
   IF (ce_flag=1)
    SET select_statement = concat(select_statement,
     " join ce where cr.event_id = ce.parent_event_id and ",ce_tasks,
     " and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3) and ce.record_status_cd != ")
    SET select_statement = build(select_statement,deleted_status_cd)
    SET select_statement = build(select_statement," and ce.event_class_cd != ",placeholder_cd)
   ENDIF
   IF (cecr_flag=1)
    SET select_statement = concat(select_statement,
     " join cecr where ce.event_id = cecr.event_id and ",cecr_responses,
     " and cecr.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)")
   ENDIF
   SET select_statement = concat(select_statement,
    " Order By pc.main_report_cmplete_dt_tm Desc, pc.case_id, 0")
   SET select_statement = concat(select_statement," head report case_cnt = 0")
   SET select_statement = concat(select_statement," detail case_cnt = case_cnt + 1")
   SET select_statement = concat(select_statement," if (mod(case_cnt, 10) = 1)")
   SET select_statement = concat(select_statement," stat = alterlist(temp->case_qual, case_cnt + 9)")
   SET select_statement = concat(select_statement," endif")
   SET select_statement = concat(select_statement," temp->case_qual[case_cnt]->",build("case_id = ",
     request->case_id))
   IF (across_case_ind=1)
    SET select_statement = concat(select_statement,
     " temp->case_qual[case_cnt]->correlate_case_id = pc.case_id")
   ELSE
    SET select_statement = concat(select_statement,
     " temp->case_qual[case_cnt]->correlate_case_id = 0.0")
   ENDIF
   SET select_statement = concat(select_statement,
    " foot report stat = alterlist(temp->case_qual, case_cnt)")
   SET select_statement = concat(select_statement," with nocounter go")
   CALL parser(select_statement)
   SET case_cnt = cnvtint(size(temp->case_qual,5))
   IF (case_cnt > 0)
    IF ((reply200393->sys_corr_qual[x].lookback_all_cases_ind=0))
     SET case_cnt = 1
    ENDIF
    SET qualified_cases = 0
    SET total_cases = 0
    SELECT INTO "nl:"
     ascc.sys_corr_id
     FROM ap_sys_corr_counts ascc
     WHERE (ascc.sys_corr_id=reply200393->sys_corr_qual[x].sys_corr_id)
     DETAIL
      qualified_cases = ascc.qualified_cases, total_cases = ascc.total_cases
     WITH nocounter, forupdate(ascc)
    ;end select
    IF (curqual != 1)
     IF (error(rdm_errmsg,0)=0)
      INSERT  FROM ap_sys_corr_counts ascc,
        (dummyt d  WITH seq = 1)
       SET ascc.sys_corr_id = reply200393->sys_corr_qual[x].sys_corr_id, ascc.qualified_cases = 0,
        ascc.total_cases = 0,
        ascc.updt_dt_tm = cnvtdatetime(curdate,curtime), ascc.updt_id = reqinfo->updt_id, ascc
        .updt_task = reqinfo->updt_task,
        ascc.updt_applctx = reqinfo->updt_applctx, ascc.updt_cnt = 0
       PLAN (d)
        JOIN (ascc
        WHERE (ascc.sys_corr_id=reply200393->sys_corr_qual[x].sys_corr_id))
       WITH nocounter, outerjoin = d, dontexist
      ;end insert
      IF (curqual=0)
       CALL handle_errors("INSERT","F","TABLE","AP_SYS_CORR_COUNTS")
       GO TO exit_script
      ENDIF
     ELSE
      CALL handle_errors("LOCK","F","TABLE","AP_SYS_CORR_COUNTS")
      GO TO exit_script
     ENDIF
    ENDIF
    SET total_cases += 1
    IF ((reply200393->sys_corr_qual[x].case_percentage != 100)
     AND (((qualified_cases * 100)/ total_cases) > reply200393->sys_corr_qual[x].case_percentage))
     SET case_cnt = 0
    ELSE
     SET qualified_cases += 1
    ENDIF
    UPDATE  FROM ap_sys_corr_counts ascc
     SET ascc.qualified_cases = qualified_cases, ascc.total_cases = total_cases
     WHERE (ascc.sys_corr_id=reply200393->sys_corr_qual[x].sys_corr_id)
     WITH nocounter
    ;end update
    IF (curqual != 1)
     CALL handle_errors("UPDATE","F","TABLE","AP_SYS_CORR_COUNTS")
     GO TO exit_script
    ENDIF
    SET stat = alterlist(temp->case_qual,case_cnt)
    FOR (y = 1 TO case_cnt)
      SET found_ind = 0
      FOR (z = 1 TO event_cnt)
        IF ((req200402->event_qual[z].correlate_case_id=temp->case_qual[y].correlate_case_id)
         AND (req200402->event_qual[z].sys_corr_id=reply200393->sys_corr_qual[x].sys_corr_id))
         SET found_ind = 1
         SET req200402->event_qual[z].del_ind = 0
         IF ((req200402->event_qual[z].init_eval_term_id=0))
          SET req200402->event_qual[z].upd_ind = 1
          SET req200402->event_qual[z].study_id = reply200393->sys_corr_qual[x].study_id
          SET req200402->event_qual[z].initiated_dt_tm = cnvtdatetime(sysdate)
          SET req200402->event_qual[z].report_issued_by_prsnl_id = request->report_resp_path_id
          SET req200402->event_qual[z].assign_to_group_ind = reply200393->sys_corr_qual[x].
          assign_to_group_ind
          SET call_update_script_ind = 1
          IF ((reply200393->sys_corr_qual[x].assign_to_group_ind=1))
           IF ((reply200393->sys_corr_qual[x].assign_to_group_id != 0))
            SET req200402->event_qual[z].prsnl_group_id = reply200393->sys_corr_qual[x].
            assign_to_group_id
            SELECT INTO "nl:"
             pgr.prsnl_group_id, pgr.person_id
             FROM prsnl_group_reltn pgr
             PLAN (pgr
              WHERE (pgr.prsnl_group_id=req200402->event_qual[z].prsnl_group_id)
               AND pgr.active_ind=1
               AND pgr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
               AND pgr.end_effective_dt_tm >= cnvtdatetime(sysdate))
             HEAD REPORT
              prsnl_cnt = 0
             DETAIL
              prsnl_cnt += 1
              IF (mod(prsnl_cnt,10)=1)
               stat = alterlist(req200402->event_qual[z].prsnl_qual,(prsnl_cnt+ 10))
              ENDIF
              req200402->event_qual[z].prsnl_qual[prsnl_cnt].prsnl_id = pgr.person_id
             FOOT REPORT
              stat = alterlist(req200402->event_qual[z].prsnl_qual,prsnl_cnt)
             WITH nocounter
            ;end select
            IF (curqual=0)
             CALL handle_errors("SELECT","F","TABLE","PRSNL_GROUP_RELTN")
             GO TO exit_script
            ENDIF
           ENDIF
          ELSEIF ((reply200393->sys_corr_qual[x].assign_to_verifying_ind=1))
           CALL echo("Adding PRSNL")
           SET stat = alterlist(req200402->event_qual[z].prsnl_qual,1)
           SET req200402->event_qual[z].prsnl_qual[1].prsnl_id = request->verifying_id
           IF ((reply200393->sys_corr_qual[x].notify_user_online_ind=1))
            SET reply->notify_user_online_ind = 1
           ENDIF
          ELSEIF ((reply200393->sys_corr_qual[x].assign_to_prsnl_id != 0))
           SET stat = alterlist(req200402->event_qual[z].prsnl_qual,1)
           SET req200402->event_qual[z].prsnl_qual[1].prsnl_id = reply200393->sys_corr_qual[x].
           assign_to_prsnl_id
           IF ((request->verifying_id=reply200393->sys_corr_qual[x].assign_to_prsnl_id)
            AND (reply200393->sys_corr_qual[x].notify_user_online_ind=1))
            SET reply->notify_user_online_ind = 1
           ENDIF
          ELSE
           IF ((reply200393->sys_corr_qual[x].notify_user_online_ind=1))
            SET reply->notify_user_online_ind = 1
           ENDIF
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      IF (found_ind=0)
       SET call_update_script_ind = 1
       SET event_cnt += 1
       SET stat = alterlist(req200402->event_qual,event_cnt)
       SET req200402->event_qual[event_cnt].add_ind = 1
       SET req200402->event_qual[event_cnt].event_id = 0
       SET req200402->event_qual[event_cnt].case_id = temp->case_qual[y].case_id
       SET req200402->event_qual[event_cnt].correlate_case_id = temp->case_qual[y].correlate_case_id
       SET req200402->event_qual[event_cnt].study_id = reply200393->sys_corr_qual[x].study_id
       SET req200402->event_qual[event_cnt].sys_corr_id = reply200393->sys_corr_qual[x].sys_corr_id
       SET req200402->event_qual[event_cnt].initiated_prsnl_id = 0
       SET req200402->event_qual[event_cnt].initiated_dt_tm = cnvtdatetime(sysdate)
       SET req200402->event_qual[event_cnt].report_issued_by_prsnl_id = request->report_resp_path_id
       SET req200402->event_qual[event_cnt].assign_to_group_ind = reply200393->sys_corr_qual[x].
       assign_to_group_ind
       IF ((reply200393->sys_corr_qual[x].assign_to_group_ind=1))
        IF ((reply200393->sys_corr_qual[x].assign_to_group_id != 0))
         SET req200402->event_qual[event_cnt].prsnl_group_id = reply200393->sys_corr_qual[x].
         assign_to_group_id
         SELECT INTO "nl:"
          pgr.prsnl_group_id, pgr.person_id
          FROM prsnl_group_reltn pgr
          PLAN (pgr
           WHERE (pgr.prsnl_group_id=req200402->event_qual[event_cnt].prsnl_group_id)
            AND pgr.active_ind=1
            AND pgr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
            AND pgr.end_effective_dt_tm >= cnvtdatetime(sysdate))
          HEAD REPORT
           prsnl_cnt = 0
          DETAIL
           prsnl_cnt += 1
           IF (mod(prsnl_cnt,10)=1)
            stat = alterlist(req200402->event_qual[event_cnt].prsnl_qual,(prsnl_cnt+ 10))
           ENDIF
           req200402->event_qual[event_cnt].prsnl_qual[prsnl_cnt].prsnl_id = pgr.person_id
          FOOT REPORT
           stat = alterlist(req200402->event_qual[event_cnt].prsnl_qual,prsnl_cnt)
          WITH nocounter
         ;end select
         IF (curqual=0)
          CALL handle_errors("SELECT","F","TABLE","PRSNL_GROUP_RELTN")
          GO TO exit_script
         ENDIF
        ENDIF
       ELSEIF ((reply200393->sys_corr_qual[x].assign_to_verifying_ind=1))
        SET stat = alterlist(req200402->event_qual[event_cnt].prsnl_qual,1)
        SET req200402->event_qual[event_cnt].prsnl_qual[1].prsnl_id = request->verifying_id
        IF ((reply200393->sys_corr_qual[x].notify_user_online_ind=1))
         SET reply->notify_user_online_ind = 1
        ENDIF
       ELSEIF ((reply200393->sys_corr_qual[x].assign_to_prsnl_id != 0))
        SET stat = alterlist(req200402->event_qual[event_cnt].prsnl_qual,1)
        SET req200402->event_qual[event_cnt].prsnl_qual[1].prsnl_id = reply200393->sys_corr_qual[x].
        assign_to_prsnl_id
        IF ((request->verifying_id=reply200393->sys_corr_qual[x].assign_to_prsnl_id)
         AND (reply200393->sys_corr_qual[x].notify_user_online_ind=1))
         SET reply->notify_user_online_ind = 1
        ENDIF
       ELSE
        IF ((reply200393->sys_corr_qual[x].notify_user_online_ind=1))
         SET reply->notify_user_online_ind = 1
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 FREE SET temp
 IF (call_update_script_ind=1)
  SET req200402->called_from_script_ind = 1
  EXECUTE aps_add_chg_diag_corr_events
  IF ((reply200402->status_data.status != "S"))
   SET reply->status_data.status = reply200402->status_data.status
   SET error_cnt = 1
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SUBROUTINE buildmultiwhere(bmworigwhere,bmwtablefield,bmwitemvalue)
  IF (textlen(trim(bmworigwhere))=0)
   SET temp_string = build(trim(bmwtablefield)," in (",trim(bmwitemvalue),")")
  ELSE
   SET bmworigwhere = substring(1,(textlen(trim(bmworigwhere)) - 1),bmworigwhere)
   SET temp_string = build(trim(bmworigwhere),",",trim(bmwitemvalue),")")
  ENDIF
  RETURN(temp_string)
 END ;Subroutine
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
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
