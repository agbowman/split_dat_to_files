CREATE PROGRAM dcp_upd_plan_catalog
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ver_reply(
   1 version = i4
   1 parent_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE ccluarxrtl
 DECLARE plan_cnt = i4 WITH constant(value(size(request->planlist,5)))
 DECLARE end_date_string = c20 WITH constant("31-DEC-2100 00:00:00")
 DECLARE plan_r_cnt = i4 WITH constant(value(size(request->planreltnlist,5)))
 DECLARE pw_evidence_r_cnt = i4 WITH constant(value(size(request->pwevidencereltnlist,5)))
 DECLARE problem_diag_cnt = i4 WITH constant(value(size(request->problemdiaglist,5)))
 DECLARE comp_phase_r_cnt = i4 WITH constant(value(size(request->compphasereltnlist,5)))
 DECLARE reltn_type_cd = f8 WITH constant(uar_get_code_by("MEANING",29753,"PLANANDDX")), protect
 DECLARE i = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE parent_entity_name = c32 WITH noconstant(fillstring(32," "))
 DECLARE parent_entity_id = f8 WITH noconstant(0.0)
 DECLARE cstatus = c1 WITH noconstant("S")
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE new_text_id = f8 WITH noconstant(0.0)
 DECLARE ord_sent_cnt = i4 WITH noconstant(0)
 DECLARE new_concept_cki_r_id = f8 WITH noconstant(0.0)
 DECLARE group_cnt = i4 WITH noconstant(0), protect
 DECLARE group_comp_cnt = i4 WITH noconstant(0), protect
 DECLARE remove_plan_reltn_flag = c1 WITH noconstant("Y")
 DECLARE cycle_cd = f8 WITH constant(uar_get_code_by("MEANING",4002313,"CYCLE")), protect
 DECLARE testing_ind = i4 WITH noconstant(0), protect
 DECLARE methodpairreltnidx = i4 WITH noconstant(0)
 DECLARE nbr_pairs = i4 WITH noconstant(0)
 SET pw_def_dose_calc_method_table_exists = checkdic("PW_DEF_DOSE_CALC_METHOD","T",0)
 IF ((request->version_flag > 0))
  IF (checkprg("DCP_VER_PLAN_CATALOG")=0)
   CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
     "Unable to create a version record for the plan - dcp_ver_plan_catalog.prg not found",
     ".  pathway_catalog_id=",request->parent_cat_id))
   GO TO exit_script
  ENDIF
  EXECUTE dcp_ver_plan_catalog  WITH replace("REPLY","VER_REPLY")
  IF ((ver_reply->status_data.status="F"))
   CALL report_failure(ver_reply->status_data.subeventstatus[1].operationname,ver_reply->status_data.
    subeventstatus[1].operationstatus,ver_reply->status_data.subeventstatus[1].targetobjectname,
    ver_reply->status_data.subeventstatus[1].targetobjectvalue)
   CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
     "Unable to create a version record for the plan - dcp_ver_plan_catalog.prg returned failure",
     ".  pathway_catalog_id=",request->parent_cat_id))
   GO TO exit_script
  ENDIF
 ENDIF
 IF (((validate(request->remove_plan_reltn_ind,999)=999) OR (validate(request->remove_plan_reltn_ind,
  999)=0)) )
  SET remove_plan_reltn_flag = "N"
 ENDIF
 IF (((plan_r_cnt > 0) OR (remove_plan_reltn_flag="Y")) )
  SET cstatus = remove_all_plan_reltns(plan_r_cnt)
  IF (cstatus="F")
   CALL report_failure("DELETE","F","DCP_UPD_PLAN_CATALOG",
    "Unable to remove old plan relationship records")
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (i = 1 TO plan_cnt)
   IF ((((request->planlist[i].type_mean="CAREPLAN")) OR ((request->planlist[i].type_mean="PATHWAY")
   )) )
    SET cstatus = update_plan_comment(i)
    IF (cstatus="F")
     CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",
      "Unable to process pathway-level comment")
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((request->planlist[i].comp_r_updt_flag=1))
    SET cstatus = remove_comp_reltns(i)
    IF (cstatus="F")
     CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",
      "Unable to remove component relationships")
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((request->planlist[i].action_type="CREATE")
    AND (request->planlist[i].pathway_catalog_id > 0))
    SET cstatus = insert_plan(i,new_text_id)
    IF (cstatus="F")
     CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
      "Unable to create new PATHWAY_CATALOG record")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->planlist[i].action_type="MODIFY")
    AND (request->planlist[i].pathway_catalog_id > 0))
    SET cstatus = update_plan(i,new_text_id)
    IF (cstatus="F")
     CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",
      "Unable to update PATHWAY_CATALOG record")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->planlist[i].action_type="REMOVE")
    AND (request->planlist[i].pathway_catalog_id > 0))
    SET cstatus = remove_plan(i)
    IF (cstatus="F")
     CALL report_failure("DELETE","F","DCP_UPD_PLAN_CATALOG",
      "Unable to remove PATHWAY_CATALOG record")
     GO TO exit_script
    ENDIF
    SET cstatus = remove_comp_reltns(i)
   ELSEIF ((request->planlist[i].action_type="VERSION")
    AND (request->planlist[i].pathway_catalog_id > 0)
    AND (request->version_flag > 0))
    SET cstatus = version_plan(i)
    IF (cstatus="F")
     CALL report_failure("VERSION","F","DCP_UPD_PLAN_CATALOG",
      "Unable to version PATHWAY_CATALOG record")
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((request->planlist[i].comp_r_updt_flag=1)
    AND value(size(request->planlist[i].compreltnlist,5)) > 0)
    SET cstatus = insert_comp_reltns(i)
    IF (cstatus="F")
     CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",
      "Unable to remove component relationships")
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((((request->planlist[i].type_mean="CAREPLAN")) OR ((request->planlist[i].type_mean="PATHWAY")
   ))
    AND (request->planlist[i].flex_parent_entity_id <= 0))
    SET cstatus = process_facility_flex_update(i)
    IF (cstatus="F")
     CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",
      "Unable to process facility flexing data")
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((request->planlist[i].group_updt_flag=1))
    SET group_cnt = value(size(request->planlist[i].compgrouplist,5))
    SET cstatus = remove_comp_group(i)
    FOR (j = 1 TO group_cnt)
     SET cstatus = insert_comp_group(i,j)
     IF (cstatus="F")
      CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",
       "Failed to insert a new row into PW_COMP_GROUP table")
      GO TO exit_script
     ENDIF
    ENDFOR
   ENDIF
   SET cstatus = process_plan_synonyms(i)
   IF (cstatus="F")
    GO TO exit_script
   ENDIF
 ENDFOR
 IF ((request->version_flag > 0))
  SET cstatus = update_parent_plan_version(ver_reply->version,ver_reply->parent_id)
  IF (cstatus="F")
   CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
     "Unable to update the version number of the parent plan row. ","Pathway_catalog_id=",request->
     parent_cat_id))
   GO TO exit_script
  ENDIF
 ENDIF
 IF (plan_r_cnt > 0)
  SET cstatus = insert_plan_reltns(plan_r_cnt)
  IF (cstatus="F")
   CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
    "Unable to insert new plan relation records")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (pw_evidence_r_cnt > 0)
  FOR (i = 1 TO pw_evidence_r_cnt)
    IF ((request->pwevidencereltnlist[i].new_evidence_ind > 0))
     SET cstatus = insert_plan_evidence_reltns(i)
     IF (cstatus="F")
      CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
       "Unable to insert new plan evidence relation records")
      GO TO exit_script
     ENDIF
    ELSEIF ((request->pwevidencereltnlist[i].del_evidence_ind > 0))
     SET cstatus = remove_plan_evidence_reltns(i)
     IF (cstatus="F")
      CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
       "Unable to remove plan evidence relation records")
      GO TO exit_script
     ENDIF
    ELSE
     SET cstatus = update_plan_evidence_reltns(i)
     IF (cstatus="F")
      CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
       "Unable to update plan evidence relation records")
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF ((request->problem_diag_updt_flag=1))
  SET cstatus = remove_all_problem_diagnosis(problem_diag_cnt)
  FOR (i = 1 TO problem_diag_cnt)
   SET cstatus = insert_problem_diagnosis(i)
   IF (cstatus="F")
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
     "Unable to insert problem/diagnosis records")
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
 FOR (i = 1 TO comp_phase_r_cnt)
   IF ((request->compphasereltnlist[i].remove_ind=1))
    IF ((request->compphasereltnlist[i].pw_comp_cat_reltn_id <= 0.0))
     CALL report_failure("DELETE","F","DCP_UPD_PLAN_CATALOG",concat("request->compPhaseReltnList[",
       build(i),"]->pw_comp_cat_reltn_id was not valid"))
     GO TO exit_script
    ENDIF
    SET cstatus = remove_comp_phase_reltn(i)
    IF (cstatus="F")
     CALL report_failure("DELETE","F","DCP_ADD_PLAN_CATALOG",
      "Unable to remove PW_COMP_CAT_RELTN record")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->compphasereltnlist[i].add_ind=1))
    IF ((request->compphasereltnlist[i].pathway_comp_id <= 0.0))
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",concat("request->compPhaseReltnList[",
       build(i),"]->pathway_comp_id was not valid"))
     GO TO exit_script
    ENDIF
    IF ((request->compphasereltnlist[i].pathway_catalog_id <= 0.0))
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",concat("request->compPhaseReltnList[",
       build(i),"]->pathway_catalog_id was not valid"))
     GO TO exit_script
    ENDIF
    IF (size(trim(request->compphasereltnlist[i].type_mean),1) <= 0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",concat("request->compPhaseReltnList[",
       build(i),"]->type_mean was not valid"))
     GO TO exit_script
    ENDIF
    SET cstatus = insert_comp_phase_reltn(i)
    IF (cstatus="F")
     CALL report_failure("INSERT","F","DCP_ADD_PLAN_CATALOG",
      "Unable to insert new PW_COMP_CAT_RELTN record")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE (update_plan_comment(idx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   SET new_text_id = 0.0
   IF ((request->planlist[idx].comment_remove_ind=1)
    AND (request->planlist[idx].comment_text_id > 0))
    SET substat = remove_long_text(request->planlist[idx].comment_text_id,request->planlist[idx].
     comment_updt_cnt)
    IF (substat="F")
     CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
       "Unable to remove pathway note. PW_CAT_ID=",request->planlist[idx].pathway_catalog_id,
       ", DESC=",request->planlist[idx].description))
     RETURN("F")
    ENDIF
   ELSEIF ((request->planlist[idx].comment_remove_ind=0)
    AND (request->planlist[idx].comment_text != null)
    AND (request->planlist[idx].comment_text_id=0))
    SET substat = insert_long_text(new_text_id,request->planlist[idx].comment_text,"PATHWAY_CATALOG",
     request->planlist[idx].pathway_catalog_id)
    IF (substat="F")
     CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",build(
       "Unable to insert pathway note into LONG_TEXT. PW_CAT_ID=",request->planlist[idx].
       pathway_catalog_id,", DESC=",request->planlist[idx].description))
     RETURN("F")
    ENDIF
   ELSEIF ((request->planlist[idx].comment_remove_ind=0)
    AND (request->planlist[idx].comment_text != null)
    AND (request->planlist[idx].comment_text_id > 0))
    SET substat = update_long_text(request->planlist[idx].comment_text_id,request->planlist[idx].
     comment_text,request->planlist[idx].comment_updt_cnt)
    IF (substat="F")
     CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
       "Unable to update pathway comment row on LONG_TEXT. PW_CAT_ID=",request->planlist[idx].
       pathway_catalog_id,", DESC=",request->planlist[idx].description))
     RETURN("F")
    ENDIF
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_long_text(long_text_id=f8,updt_cnt=i4) =c1)
   IF (long_text_id <= 0)
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to remove a row from LONG_TEXT. Invalid LONG_TEXT_ID=",long_text_id))
    RETURN("F")
   ENDIF
   DECLARE text_updt_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    lt.*
    FROM long_text lt
    WHERE lt.long_text_id=long_text_id
    HEAD REPORT
     text_updt_cnt = lt.updt_cnt
    WITH forupdate(lt), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to get a lock on LONG_TEXT. LONG_TEXT_ID=",long_text_id))
    RETURN("F")
   ENDIF
   IF (text_updt_cnt != updt_cnt)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to inactivate a row on LONG_TEXT table.  Row was changed by another user. LONG_TEXT_ID=",
      long_text_id))
    RETURN("F")
   ENDIF
   UPDATE  FROM long_text lt
    SET lt.active_ind = 0, lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo->
     updt_applctx
    WHERE lt.long_text_id=long_text_id
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
      "Failed to inactivate a row on LONG_TEXT table.  LONG_TEXT_ID=",long_text_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_long_text(new_text_id=f8(ref),long_text=vc,parent_entity_name=vc,parent_entity_id
  =f8) =c1)
   CALL create_new_text_id(new_text_id)
   IF (new_text_id=0.0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
     "Unable to generate long_text_id for pathway note")
    RETURN("F")
   ENDIF
   INSERT  FROM long_text lt
    SET lt.long_text_id = new_text_id, lt.parent_entity_name = parent_entity_name, lt
     .parent_entity_id = parent_entity_id,
     lt.long_text = long_text, lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd,
     lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.active_status_prsnl_id = reqinfo->updt_id, lt
     .updt_dt_tm = cnvtdatetime(sysdate),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
     lt.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to insert a row into LONG_TEXT. LONG_TEXT_ID=",new_text_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_long_text(long_text_id=f8,long_text=vc,updt_cnt=i4) =c1)
   DECLARE text_updt_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    lt.*
    FROM long_text lt
    WHERE lt.long_text_id=long_text_id
    HEAD REPORT
     text_updt_cnt = lt.updt_cnt
    WITH forupdate(lt), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build("Unable to get a lock on LONG_TEXT",
      long_text_id))
    RETURN("F")
   ENDIF
   IF (text_updt_cnt != updt_cnt)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to update LONG_TEXT table.  Row was changed by another user. LONG_TEXT_ID=",
      long_text_id))
    RETURN("F")
   ENDIF
   UPDATE  FROM long_text lt
    SET lt.long_text = long_text, lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->
     updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo->
     updt_applctx
    WHERE lt.long_text_id=long_text_id
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
      "Failed to update LONG_TEXT table.  LONG_TEXT_ID=",long_text_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (create_new_text_id(new_text_id=f8(ref)) =null)
   SELECT INTO "nl:"
    nextseqnum = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     new_text_id = nextseqnum
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (insert_plan(idx=i4,long_text_id=f8) =c1)
   DECLARE comp_cnt = i4 WITH protect, constant(value(size(request->planlist[idx].complist,5)))
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE cidx = i4 WITH protect, noconstant(0)
   SET substat = update_components(idx,comp_cnt)
   IF (substat="F")
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to create new components for PW_CAT_ID=",request->planlist[idx].pathway_catalog_id,
      " DESC=",trim(request->planlist[idx].description)))
    RETURN("F")
   ENDIF
   IF ((request->planlist[idx].cycle_ind=1)
    AND (request->planlist[idx].cycle_label_cd <= 0.0))
    SET request->planlist[idx].cycle_label_cd = cycle_cd
   ENDIF
   DECLARE phaseuuid = vc WITH protect
   SET phaseuuid = validate(request->planlist[idx].uuid,"")
   IF (size(phaseuuid,1) <= 0)
    SET phaseuuid = uar_createuuid(0)
   ENDIF
   INSERT  FROM pathway_catalog pc
    SET pc.pathway_catalog_id = request->planlist[idx].pathway_catalog_id, pc.type_mean = request->
     planlist[idx].type_mean, pc.active_ind =
     IF ((((request->planlist[idx].type_mean="PHASE")) OR ((request->planlist[idx].type_mean="DOT")
     )) ) 1
     ELSE request->planlist[idx].active_ind
     ENDIF
     ,
     pc.cross_encntr_ind = request->planlist[idx].cross_encntr_ind, pc.description = trim(request->
      planlist[idx].description), pc.description_key = trim(cnvtupper(request->planlist[idx].
       description)),
     pc.long_text_id = long_text_id, pc.version = 1, pc.version_pw_cat_id = 0.0,
     pc.beg_effective_dt_tm = cnvtdatetime(sysdate), pc.end_effective_dt_tm = cnvtdatetime(
      end_date_string), pc.duration_qty = request->planlist[idx].duration_qty,
     pc.duration_unit_cd = request->planlist[idx].duration_unit_cd, pc.pathway_type_cd = request->
     planlist[idx].pathway_type_cd, pc.display_method_cd = request->planlist[idx].display_method_cd,
     pc.display_description =
     IF ((request->planlist[idx].display_description > "")
      AND (((request->planlist[idx].type_mean="PATHWAY")) OR ((request->planlist[idx].type_mean=
     "CAREPLAN"))) ) trim(request->planlist[idx].display_description)
     ELSEIF ((((request->planlist[idx].type_mean="PATHWAY")) OR ((request->planlist[idx].type_mean=
     "CAREPLAN"))) ) trim(request->planlist[idx].description)
     ELSE ""
     ENDIF
     , pc.sub_phase_ind = request->planlist[idx].sub_phase_ind, pc.hide_flexed_comp_ind = request->
     planlist[idx].hide_flexed_comp_ind,
     pc.cycle_ind = request->planlist[idx].cycle_ind, pc.standard_cycle_nbr = request->planlist[idx].
     standard_cycle_nbr, pc.default_view_mean = request->planlist[idx].default_view_mean,
     pc.diagnosis_capture_ind = request->planlist[idx].diagnosis_capture_ind, pc.provider_prompt_ind
      = request->planlist[idx].provider_prompt_ind, pc.allow_copy_forward_ind = request->planlist[idx
     ].allow_copy_forward_ind,
     pc.auto_initiate_ind = request->planlist[idx].auto_initiate_ind, pc.alerts_on_plan_ind = request
     ->planlist[idx].alerts_on_plan_ind, pc.alerts_on_plan_upd_ind = request->planlist[idx].
     alerts_on_plan_upd_ind,
     pc.cycle_begin_nbr = request->planlist[idx].cycle_begin_nbr, pc.cycle_end_nbr = request->
     planlist[idx].cycle_end_nbr, pc.cycle_label_cd = request->planlist[idx].cycle_label_cd,
     pc.cycle_display_end_ind = request->planlist[idx].cycle_display_end_ind, pc.cycle_lock_end_ind
      = request->planlist[idx].cycle_lock_end_ind, pc.cycle_increment_nbr = request->planlist[idx].
     cycle_increment_nbr,
     pc.default_action_inpt_future_cd = request->planlist[idx].default_action_inpt_future_cd, pc
     .default_action_inpt_now_cd = request->planlist[idx].default_action_inpt_now_cd, pc
     .default_action_outpt_future_cd = request->planlist[idx].default_action_outpt_future_cd,
     pc.default_action_outpt_now_cd = request->planlist[idx].default_action_outpt_now_cd, pc
     .optional_ind = request->planlist[idx].optional_ind, pc.future_ind = request->planlist[idx].
     future_ind,
     pc.default_visit_type_flag = request->planlist[idx].default_visit_type_flag, pc
     .prompt_on_selection_ind = request->planlist[idx].prompt_on_selection_ind, pc.pathway_class_cd
      = request->planlist[idx].pathway_class_cd,
     pc.period_nbr = request->planlist[idx].period_nbr, pc.period_custom_label = request->planlist[
     idx].period_custom_label, pc.route_for_review_ind = request->planlist[idx].route_for_review_ind,
     pc.default_start_time_txt = trim(request->planlist[idx].default_start_time_txt), pc.primary_ind
      = request->planlist[idx].primary_ind, pc.pathway_uuid = trim(phaseuuid),
     pc.reschedule_reason_accept_flag = request->planlist[idx].reschedule_reason_accept_flag, pc
     .restricted_actions_bitmask = validate(request->planlist[idx].restricted_actions_bitmask,0), pc
     .open_by_default_ind = request->planlist[idx].open_by_default_ind,
     pc.disable_activate_all_ind = evaluate(request->planlist[idx].allow_activate_all_ind,1,0,0,1),
     pc.review_required_sig_count = validate(request->planlist[idx].review_required_sig_count,0), pc
     .override_mrd_on_plan_ind = validate(request->planlist[idx].override_mrd_on_plan_ind,0),
     pc.updt_dt_tm = cnvtdatetime(sysdate), pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->
     updt_task,
     pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to insert into PATHWAY_CATALOG.  PW_CAT_ID=",request->planlist[idx].pathway_catalog_id,
      ".  DESC=",trim(request->planlist[idx].description)))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_plan(idx=i4,long_text_id=f8) =c1)
   DECLARE comp_cnt = i4 WITH protect, constant(value(size(request->planlist[idx].complist,5)))
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE cidx = i4 WITH protect, noconstant(0)
   DECLARE pw_updt_cnt = i4 WITH protect, noconstant(0)
   DECLARE description = vc WITH protect, noconstant(fillstring(100,""))
   DECLARE version_pw_cat_id = f8 WITH protect, noconstant(0.0)
   SET substat = update_components(idx,comp_cnt)
   IF (substat="F")
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to process components for PW_CAT_ID=",request->planlist[idx].pathway_catalog_id,
      " DESC=",trim(request->planlist[idx].description)))
    RETURN("F")
   ENDIF
   SELECT INTO "nl:"
    pc.*
    FROM pathway_catalog pc
    WHERE (pc.pathway_catalog_id=request->planlist[idx].pathway_catalog_id)
    HEAD REPORT
     pw_updt_cnt = pc.updt_cnt, description = trim(pc.description), version_pw_cat_id = pc
     .version_pw_cat_id
     IF (cnvtdatetime(pc.beg_effective_dt_tm) >= cnvtdatetime(end_date_string))
      testing_ind = 1
     ENDIF
    WITH forupdate(pc), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
      "Failed to get a lock on PATHWAY_CATALOG for PW_CAT_ID=",request->planlist[idx].
      pathway_catalog_id," DESC=",trim(request->planlist[idx].description)))
    RETURN("F")
   ENDIF
   IF ((pw_updt_cnt != request->planlist[idx].updt_cnt))
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to update PATHWAY_CATALOG table.  Row was changed by another user. PW_CAT_ID=",request
      ->planlist[idx].pathway_catalog_id," DESC=",trim(request->planlist[idx].description)))
    RETURN("F")
   ENDIF
   IF ((request->planlist[idx].cycle_ind=1)
    AND (request->planlist[idx].cycle_label_cd <= 0.0))
    SET request->planlist[idx].cycle_label_cd = cycle_cd
   ENDIF
   UPDATE  FROM pathway_catalog pc
    SET pc.active_ind =
     IF ((request->planlist[idx].type_mean="PHASE")) pc.active_ind
     ELSE request->planlist[idx].active_ind
     ENDIF
     , pc.cross_encntr_ind = request->planlist[idx].cross_encntr_ind, pc.description =
     IF ((request->planlist[idx].description != null)) request->planlist[idx].description
     ELSE pc.description
     ENDIF
     ,
     pc.description_key =
     IF ((request->planlist[idx].description != null)) trim(cnvtupper(request->planlist[i].
        description))
     ELSE pc.description_key
     ENDIF
     , pc.long_text_id =
     IF (long_text_id != 0) long_text_id
     ELSEIF ((request->planlist[idx].comment_remove_ind=1)) 0
     ELSE pc.long_text_id
     ENDIF
     , pc.version =
     IF ((request->version_flag > 0)) (pc.version+ 1)
     ELSE pc.version
     ENDIF
     ,
     pc.version_pw_cat_id =
     IF ((request->version_flag > 0)) 0.0
     ELSE pc.version_pw_cat_id
     ENDIF
     , pc.beg_effective_dt_tm =
     IF ((request->version_flag > 0)) cnvtdatetime(sysdate)
     ELSE pc.beg_effective_dt_tm
     ENDIF
     , pc.duration_qty = request->planlist[idx].duration_qty,
     pc.duration_unit_cd = request->planlist[idx].duration_unit_cd, pc.pathway_type_cd = request->
     planlist[idx].pathway_type_cd, pc.display_method_cd = request->planlist[idx].display_method_cd,
     pc.display_description =
     IF ((request->planlist[idx].display_description > "")
      AND (((request->planlist[idx].type_mean="PATHWAY")) OR ((request->planlist[idx].type_mean=
     "CAREPLAN"))) ) trim(request->planlist[idx].display_description)
     ELSEIF ((((request->planlist[idx].type_mean="PATHWAY")) OR ((request->planlist[idx].type_mean=
     "CAREPLAN"))) ) trim(request->planlist[idx].description)
     ELSE ""
     ENDIF
     , pc.sub_phase_ind = request->planlist[idx].sub_phase_ind, pc.hide_flexed_comp_ind = request->
     planlist[idx].hide_flexed_comp_ind,
     pc.cycle_ind = request->planlist[idx].cycle_ind, pc.standard_cycle_nbr = request->planlist[idx].
     standard_cycle_nbr, pc.default_view_mean = request->planlist[idx].default_view_mean,
     pc.diagnosis_capture_ind = request->planlist[idx].diagnosis_capture_ind, pc.provider_prompt_ind
      = request->planlist[idx].provider_prompt_ind, pc.allow_copy_forward_ind = request->planlist[idx
     ].allow_copy_forward_ind,
     pc.auto_initiate_ind = request->planlist[idx].auto_initiate_ind, pc.alerts_on_plan_ind = request
     ->planlist[idx].alerts_on_plan_ind, pc.alerts_on_plan_upd_ind = request->planlist[idx].
     alerts_on_plan_upd_ind,
     pc.cycle_begin_nbr = request->planlist[idx].cycle_begin_nbr, pc.cycle_end_nbr = request->
     planlist[idx].cycle_end_nbr, pc.cycle_label_cd = request->planlist[idx].cycle_label_cd,
     pc.cycle_display_end_ind = request->planlist[idx].cycle_display_end_ind, pc.cycle_lock_end_ind
      = request->planlist[idx].cycle_lock_end_ind, pc.cycle_increment_nbr = request->planlist[idx].
     cycle_increment_nbr,
     pc.default_action_inpt_future_cd = request->planlist[idx].default_action_inpt_future_cd, pc
     .default_action_inpt_now_cd = request->planlist[idx].default_action_inpt_now_cd, pc
     .default_action_outpt_future_cd = request->planlist[idx].default_action_outpt_future_cd,
     pc.default_action_outpt_now_cd = request->planlist[idx].default_action_outpt_now_cd, pc
     .optional_ind = request->planlist[idx].optional_ind, pc.future_ind = request->planlist[idx].
     future_ind,
     pc.default_visit_type_flag = request->planlist[idx].default_visit_type_flag, pc
     .prompt_on_selection_ind = request->planlist[idx].prompt_on_selection_ind, pc.pathway_class_cd
      = request->planlist[idx].pathway_class_cd,
     pc.linked_phase_ind = validate(request->planlist[idx].linked_phase_ind,0), pc.period_nbr =
     request->planlist[idx].period_nbr, pc.period_custom_label = request->planlist[idx].
     period_custom_label,
     pc.route_for_review_ind = request->planlist[idx].route_for_review_ind, pc.default_start_time_txt
      = trim(request->planlist[idx].default_start_time_txt), pc.primary_ind = request->planlist[idx].
     primary_ind,
     pc.reschedule_reason_accept_flag = request->planlist[idx].reschedule_reason_accept_flag, pc
     .restricted_actions_bitmask = validate(request->planlist[idx].restricted_actions_bitmask,pc
      .restricted_actions_bitmask), pc.open_by_default_ind = request->planlist[idx].
     open_by_default_ind,
     pc.disable_activate_all_ind = evaluate(request->planlist[idx].allow_activate_all_ind,1,0,0,1),
     pc.review_required_sig_count = validate(request->planlist[idx].review_required_sig_count,0), pc
     .override_mrd_on_plan_ind = validate(request->planlist[idx].override_mrd_on_plan_ind,0),
     pc.updt_dt_tm = cnvtdatetime(sysdate), pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->
     updt_task,
     pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc.updt_cnt+ 1)
    WHERE (pc.pathway_catalog_id=request->planlist[idx].pathway_catalog_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to update PATHWAY_CATALOG.  PW_CAT_ID=",request->planlist[idx].pathway_catalog_id,
      ".  DESC=",trim(request->planlist[idx].description)))
    RETURN("F")
   ENDIF
   IF ((((request->planlist[idx].type_mean="PATHWAY")) OR ((request->planlist[idx].type_mean=
   "CAREPLAN")))
    AND trim(description) != trim(request->planlist[idx].description)
    AND (request->planlist[idx].description != null)
    AND version_pw_cat_id != 0)
    UPDATE  FROM pathway_catalog pc
     SET pc.description = request->planlist[idx].description, pc.description_key = trim(cnvtupper(
        request->planlist[i].description))
     WHERE pc.version_pw_cat_id=version_pw_cat_id
      AND (pc.pathway_catalog_id != request->planlist[idx].pathway_catalog_id)
    ;end update
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_plan(idx=i4) =c1)
   DECLARE comp_cnt = i4 WITH protect, constant(value(size(request->planlist[idx].complist,5)))
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE pw_updt_cnt = i4 WITH protect, noconstant(0)
   SET substat = update_components(idx,comp_cnt)
   IF (substat="F")
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to remove components for PW_CAT_ID=",request->planlist[idx].pathway_catalog_id," DESC=",
      trim(request->planlist[idx].description)))
    RETURN("F")
   ENDIF
   SELECT INTO "nl:"
    pc.*
    FROM pathway_catalog pc
    WHERE (pc.pathway_catalog_id=request->planlist[idx].pathway_catalog_id)
    HEAD REPORT
     pw_updt_cnt = pc.updt_cnt, request->planlist[idx].flex_parent_entity_id = pc.ref_owner_person_id
    WITH forupdate(pc), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
      "Failed to get a lock on PATHWAY_CATALOG for PW_CAT_ID=",request->planlist[idx].
      pathway_catalog_id," DESC=",trim(request->planlist[idx].description)))
    RETURN("F")
   ENDIF
   IF ((pw_updt_cnt != request->planlist[idx].updt_cnt))
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to update PATHWAY_CATALOG table.  Row was changed by another user. PW_CAT_ID=",request
      ->planlist[idx].pathway_catalog_id," DESC=",trim(request->planlist[idx].description)))
    RETURN("F")
   ENDIF
   UPDATE  FROM pathway_catalog pc
    SET pc.active_ind = 0, pc.updt_dt_tm = cnvtdatetime(sysdate), pc.updt_id = reqinfo->updt_id,
     pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc
     .updt_cnt+ 1)
    WHERE (pc.pathway_catalog_id=request->planlist[idx].pathway_catalog_id)
   ;end update
   IF ((request->planlist[idx].flex_parent_entity_id > 0))
    DELETE  FROM pw_cat_flex pcf
     SET pcf.seq = 1
     WHERE (pcf.pathway_catalog_id=request->planlist[idx].pathway_catalog_id)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     CALL report_failure("DELETE","F","DCP_UPD_PLAN_CATALOG",
      "Failed to delete row from PW_CAT_FLEX table")
     RETURN("F")
    ENDIF
   ENDIF
   IF (curqual=0)
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to update PATHWAY_CATALOG.  PW_CAT_ID=",request->planlist[idx].pathway_catalog_id,
      ".  DESC=",trim(request->planlist[idx].description)))
    RETURN("F")
   ENDIF
   DELETE  FROM pw_comp_cat_reltn pccr
    WHERE (pccr.pathway_catalog_id=request->planlist[idx].pathway_catalog_id)
     AND pccr.type_mean="DOT"
    WITH nocounter
   ;end delete
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_note_component(idx=i4,cidx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE comp_text_id = f8 WITH protect, noconstant(0.0)
   SET substat = insert_long_text(comp_text_id,request->planlist[idx].complist[cidx].comp_text,
    "PATHWAY_COMP",request->planlist[idx].complist[cidx].pathway_comp_id)
   IF (substat="F")
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to process long text for a new note component.  PW_COMP_ID=",request->planlist[idx].
      complist[cidx].pathway_comp_id))
    RETURN("F")
   ENDIF
   CALL insert_component(idx,cidx,"LONG_TEXT",comp_text_id)
   IF (substat="F")
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to create new note component.  PW_COMP_ID=",request->planlist[idx].complist[cidx].
      pathway_comp_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_note_component(idx=i4,cidx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE comp_text_id = f8 WITH protect, noconstant(0.0)
   IF ((request->planlist[idx].complist[cidx].comp_text_id != 0)
    AND (request->planlist[idx].complist[cidx].comp_text != null))
    SET substat = update_long_text(request->planlist[idx].complist[cidx].comp_text_id,request->
     planlist[idx].complist[cidx].comp_text,request->planlist[idx].complist[cidx].comp_text_updt_cnt)
    IF (substat="F")
     CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
       "Unable to update long text for a note component.  PW_COMP_ID=",request->planlist[idx].
       complist[cidx].pathway_comp_id))
     RETURN("F")
    ENDIF
   ENDIF
   CALL update_component(idx,cidx,"LONG_TEXT",request->planlist[idx].complist[cidx].comp_text_id)
   IF (substat="F")
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to update note component.  PW_COMP_ID=",request->planlist[idx].complist[cidx].
      pathway_comp_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_note_component(idx=i4,cidx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   SET substat = remove_component(idx,cidx)
   IF (substat="F")
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to remove note component.  PW_COMP_ID=",request->planlist[idx].complist[cidx].
      pathway_comp_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_order_component(idx=i4,cidx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE os_cnt = i4 WITH protect, constant(value(size(request->planlist[idx].complist[cidx].
      ordsentlist,5)))
   SET substat = insert_component(idx,cidx,"ORDER_CATALOG_SYNONYM",request->planlist[idx].complist[
    cidx].synonym_id)
   IF (substat="F")
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to create new order component.  PW_COMP_ID=",request->planlist[idx].complist[cidx].
      pathway_comp_id))
    RETURN("F")
   ENDIF
   IF (os_cnt > 0)
    SET substat = insert_os_reltns(idx,cidx,os_cnt)
    IF (substat="F")
     CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",build(
       "Unable to create OS reltns for a new order component.  PW_COMP_ID=",request->planlist[idx].
       complist[cidx].pathway_comp_id))
     RETURN("F")
    ENDIF
   ENDIF
   SET substat = insert_dose_calc_method(idx,cidx)
   IF (substat="F")
    CALL report_failure("INSERT","F","PW_DEF_DOSE_CALC_METHOD",build(
      "Unable to Insert dose calculator methods. PW_COMP_ID=",request->planlist[idx].complist[cidx].
      pathway_comp_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_order_component(idx=i4,cidx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE os_cnt = i4 WITH protect, constant(value(size(request->planlist[idx].complist[cidx].
      ordsentlist,5)))
   SET substat = update_component(idx,cidx,"ORDER_CATALOG_SYNONYM",request->planlist[idx].complist[
    cidx].synonym_id)
   IF (substat="F")
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to update an order component.  PW_COMP_ID=",request->planlist[idx].complist[cidx].
      pathway_comp_id))
    RETURN("F")
   ENDIF
   IF ((request->planlist[idx].complist[cidx].remove_os_ind=1))
    SET substat = remove_os_reltns(request->planlist[idx].complist[cidx].pathway_comp_id)
    IF (substat="F")
     CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
       "Unable to remove OS reltns for an order component.  PW_COMP_ID=",request->planlist[idx].
       complist[cidx].pathway_comp_id))
     RETURN("F")
    ENDIF
   ENDIF
   IF (os_cnt > 0)
    SET substat = insert_os_reltns(idx,cidx,os_cnt)
    IF (substat="F")
     CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",build(
       "Unable to create OS reltns for an order component.  PW_COMP_ID=",request->planlist[idx].
       complist[cidx].pathway_comp_id))
     RETURN("F")
    ENDIF
   ENDIF
   SET substat = remove_dose_calc_method(idx,cidx)
   IF (substat="F")
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to remove default methods for an order component.  PW_COMP_ID=",request->planlist[idx].
      complist[cidx].pathway_comp_id))
    RETURN("F")
   ENDIF
   SET substat = insert_dose_calc_method(idx,cidx)
   IF (substat="F")
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to insert default methods for an order component.  PW_COMP_ID=",request->planlist[idx].
      complist[cidx].pathway_comp_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_order_component(idx=i4,cidx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   IF ((request->planlist[idx].complist[cidx].remove_os_ind=1))
    SET substat = remove_os_reltns(request->planlist[idx].complist[cidx].pathway_comp_id)
    IF (substat="F")
     CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
       "Unable to remove OS reltns for an order component.  PW_COMP_ID=",request->planlist[idx].
       complist[cidx].pathway_comp_id))
     RETURN("F")
    ENDIF
   ENDIF
   SET substat = remove_dose_calc_method(idx,cidx)
   IF (substat="F")
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to remove default methods for an order component.  PW_COMP_ID=",request->planlist[idx].
      complist[cidx].pathway_comp_id))
    RETURN("F")
   ENDIF
   SET substat = remove_component(idx,cidx)
   IF (substat="F")
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to remove an order component.  PW_COMP_ID=",request->planlist[idx].complist[cidx].
      pathway_comp_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_outcome_component(idx=i4,cidx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   SET substat = insert_component(idx,cidx,"OUTCOME_CATALOG",request->planlist[idx].complist[cidx].
    outcome_catalog_id)
   IF (substat="F")
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to create new outcome component.  PW_COMP_ID=",request->planlist[idx].complist[cidx].
      pathway_comp_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_outcome_component(idx=i4,cidx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   SET substat = update_component(idx,cidx,"OUTCOME_CATALOG",request->planlist[idx].complist[cidx].
    outcome_catalog_id)
   IF (substat="F")
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to update an outcome component.  PW_COMP_ID=",request->planlist[idx].complist[cidx].
      pathway_comp_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_outcome_component(idx=i4,cidx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   SET substat = remove_component(idx,cidx)
   IF (substat="F")
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to remove an outcome component.  PW_COMP_ID=",request->planlist[idx].complist[cidx].
      pathway_comp_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_subphase_component(idx=i4,cidx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   SET substat = insert_component(idx,cidx,"PATHWAY_CATALOG",request->planlist[idx].complist[cidx].
    sub_phase_catalog_id)
   IF (substat="F")
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to create new order component.  PW_COMP_ID=",request->planlist[idx].complist[cidx].
      pathway_comp_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_subphase_component(idx=i4,cidx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   SET substat = update_component(idx,cidx,"PATHWAY_CATALOG",request->planlist[idx].complist[cidx].
    sub_phase_catalog_id)
   IF (substat="F")
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to update an order component.  PW_COMP_ID=",request->planlist[idx].complist[cidx].
      pathway_comp_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_subphase_component(idx=i4,cidx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   SET substat = remove_component(idx,cidx)
   IF (substat="F")
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to remove an order component.  PW_COMP_ID=",request->planlist[idx].complist[cidx].
      pathway_comp_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_components(idx=i4,comp_cnt=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE cidx = i4 WITH protect, noconstant(0)
   FOR (cidx = 1 TO comp_cnt)
     IF ((request->planlist[idx].complist[cidx].comp_type_mean="NOTE")
      AND (request->planlist[idx].complist[cidx].pathway_comp_id != 0))
      CASE (request->planlist[idx].complist[cidx].action_type)
       OF "CREATE":
        SET substat = insert_note_component(idx,cidx)
       OF "MODIFY":
        SET substat = update_note_component(idx,cidx)
       OF "REMOVE":
        SET substat = remove_note_component(idx,cidx)
      ENDCASE
     ELSEIF ((request->planlist[idx].complist[cidx].comp_type_mean IN ("ORDER CREATE", "PRESCRIPTION"
     ))
      AND (request->planlist[idx].complist[cidx].pathway_comp_id != 0))
      CASE (request->planlist[idx].complist[cidx].action_type)
       OF "CREATE":
        SET substat = insert_order_component(idx,cidx)
       OF "MODIFY":
        SET substat = update_order_component(idx,cidx)
       OF "REMOVE":
        SET substat = remove_order_component(idx,cidx)
      ENDCASE
     ELSEIF ((request->planlist[idx].complist[cidx].comp_type_mean="RESULT OUTCO")
      AND (request->planlist[idx].complist[cidx].pathway_comp_id != 0))
      CASE (request->planlist[idx].complist[cidx].action_type)
       OF "CREATE":
        SET substat = insert_outcome_component(idx,cidx)
       OF "MODIFY":
        SET substat = update_outcome_component(idx,cidx)
       OF "REMOVE":
        SET substat = remove_outcome_component(idx,cidx)
      ENDCASE
     ELSEIF ((request->planlist[idx].complist[cidx].comp_type_mean="SUBPHASE")
      AND (request->planlist[idx].complist[cidx].sub_phase_catalog_id != 0))
      CASE (request->planlist[idx].complist[cidx].action_type)
       OF "CREATE":
        SET substat = insert_subphase_component(idx,cidx)
       OF "MODIFY":
        SET substat = update_subphase_component(idx,cidx)
       OF "REMOVE":
        SET substat = remove_subphase_component(idx,cidx)
      ENDCASE
     ENDIF
     IF ((request->planlist[idx].complist[cidx].action_type="REMOVE"))
      DELETE  FROM pw_comp_cat_reltn pccr
       WHERE (pccr.pathway_comp_id=request->planlist[idx].complist[cidx].pathway_comp_id)
        AND pccr.type_mean="DOT"
       WITH nocounter
      ;end delete
     ENDIF
     IF (substat="F")
      CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG","Unable to update components.")
      RETURN("F")
     ENDIF
   ENDFOR
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_component(idx=i4,cidx=i4,parent_entity_name=vc,parent_entity_id=f8) =c1)
   DECLARE componentuuid = vc WITH protect
   DECLARE displayformatxml = vc WITH protect
   SET componentuuid = validate(request->planlist[idx].complist[cidx].uuid,"")
   SET displayformatxml = trim(validate(request->planlist[idx].complist[cidx].display_format_xml,""))
   IF (size(componentuuid,1) <= 0)
    SET componentuuid = uar_createuuid(0)
   ENDIF
   INSERT  FROM pathway_comp pwc
    SET pwc.pathway_comp_id = request->planlist[idx].complist[cidx].pathway_comp_id, pwc
     .pathway_catalog_id = request->planlist[idx].pathway_catalog_id, pwc.sequence = request->
     planlist[idx].complist[cidx].sequence,
     pwc.active_ind = 1, pwc.comp_type_cd = request->planlist[idx].complist[cidx].comp_type_cd, pwc
     .parent_entity_name = parent_entity_name,
     pwc.parent_entity_id = parent_entity_id, pwc.dcp_clin_cat_cd = request->planlist[idx].complist[
     cidx].dcp_clin_cat_cd, pwc.dcp_clin_sub_cat_cd = request->planlist[idx].complist[cidx].
     dcp_clin_sub_cat_cd,
     pwc.required_ind = request->planlist[idx].complist[cidx].required_ind, pwc.include_ind = request
     ->planlist[idx].complist[cidx].include_ind, pwc.linked_to_tf_ind = request->planlist[idx].
     complist[cidx].linked_to_tf_ind,
     pwc.persistent_ind = request->planlist[idx].complist[cidx].persistent_ind, pwc.duration_qty =
     request->planlist[idx].complist[cidx].duration_qty, pwc.duration_unit_cd = request->planlist[idx
     ].complist[cidx].duration_unit_cd,
     pwc.target_type_cd = request->planlist[idx].complist[cidx].target_type_cd, pwc.expand_qty =
     request->planlist[idx].complist[cidx].expand_qty, pwc.expand_unit_cd = request->planlist[idx].
     complist[cidx].expand_unit_cd,
     pwc.comp_label = request->planlist[idx].complist[cidx].comp_label, pwc.offset_quantity = request
     ->planlist[idx].complist[cidx].offset_quantity, pwc.offset_unit_cd = request->planlist[idx].
     complist[cidx].offset_unit_cd,
     pwc.cross_phase_group_desc = request->planlist[idx].complist[cidx].cross_phase_group_desc, pwc
     .cross_phase_group_nbr = request->planlist[idx].complist[cidx].cross_phase_group_nbr, pwc
     .chemo_ind = request->planlist[idx].complist[cidx].chemo_ind,
     pwc.chemo_related_ind = request->planlist[idx].complist[cidx].chemo_related_ind, pwc
     .default_os_ind = validate(request->planlist[idx].complist[cidx].default_os_ind,1), pwc
     .min_tolerance_interval = request->planlist[idx].complist[cidx].min_tolerance_interval,
     pwc.min_tolerance_interval_unit_cd = request->planlist[idx].complist[cidx].
     min_tolerance_interval_unit_cd, pwc.pathway_uuid = trim(componentuuid), pwc.display_format_xml
      =
     IF (displayformatxml != null) displayformatxml
     ELSE "<xml />"
     ENDIF
     ,
     pwc.lock_target_dose_flag = request->planlist[idx].complist[cidx].lock_target_dose_flag, pwc
     .updt_dt_tm = cnvtdatetime(sysdate), pwc.updt_id = reqinfo->updt_id,
     pwc.updt_task = reqinfo->updt_task, pwc.updt_applctx = reqinfo->updt_applctx, pwc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG","Unable to insert into PATHWAY_COMP")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_component(idx=i4,cidx=i4,parent_entity_name=vc,parent_entity_id=f8) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE comp_updt_cnt = i4 WITH protect, noconstant(0)
   DECLARE displayformatxml = vc WITH protect
   SET displayformatxml = trim(validate(request->planlist[idx].complist[cidx].display_format_xml,""))
   SELECT INTO "nl:"
    pwc.*
    FROM pathway_comp pwc
    WHERE (pwc.pathway_comp_id=request->planlist[idx].complist[cidx].pathway_comp_id)
    HEAD REPORT
     comp_updt_cnt = pwc.updt_cnt
    WITH forupdate(pwc), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG","Failed to get a lock on PATHWAY_COMP")
    RETURN("F")
   ENDIF
   UPDATE  FROM pathway_comp pwc
    SET pwc.sequence =
     IF ((request->planlist[idx].complist[cidx].sequence != null)) request->planlist[idx].complist[
      cidx].sequence
     ELSE pwc.sequence
     ENDIF
     , pwc.parent_entity_name = parent_entity_name, pwc.parent_entity_id = parent_entity_id,
     pwc.dcp_clin_cat_cd = request->planlist[idx].complist[cidx].dcp_clin_cat_cd, pwc
     .dcp_clin_sub_cat_cd = request->planlist[idx].complist[cidx].dcp_clin_sub_cat_cd, pwc
     .required_ind = request->planlist[idx].complist[cidx].required_ind,
     pwc.include_ind = request->planlist[idx].complist[cidx].include_ind, pwc.linked_to_tf_ind =
     request->planlist[idx].complist[cidx].linked_to_tf_ind, pwc.persistent_ind = request->planlist[
     idx].complist[cidx].persistent_ind,
     pwc.duration_qty = request->planlist[idx].complist[cidx].duration_qty, pwc.duration_unit_cd =
     request->planlist[idx].complist[cidx].duration_unit_cd, pwc.target_type_cd = request->planlist[
     idx].complist[cidx].target_type_cd,
     pwc.expand_qty = request->planlist[idx].complist[cidx].expand_qty, pwc.expand_unit_cd = request
     ->planlist[idx].complist[cidx].expand_unit_cd, pwc.comp_label = request->planlist[idx].complist[
     cidx].comp_label,
     pwc.offset_quantity = request->planlist[idx].complist[cidx].offset_quantity, pwc.offset_unit_cd
      = request->planlist[idx].complist[cidx].offset_unit_cd, pwc.cross_phase_group_desc = request->
     planlist[idx].complist[cidx].cross_phase_group_desc,
     pwc.cross_phase_group_nbr = request->planlist[idx].complist[cidx].cross_phase_group_nbr, pwc
     .chemo_ind = request->planlist[idx].complist[cidx].chemo_ind, pwc.chemo_related_ind = request->
     planlist[idx].complist[cidx].chemo_related_ind,
     pwc.default_os_ind = validate(request->planlist[idx].complist[cidx].default_os_ind,1), pwc
     .min_tolerance_interval = request->planlist[idx].complist[cidx].min_tolerance_interval, pwc
     .min_tolerance_interval_unit_cd = request->planlist[idx].complist[cidx].
     min_tolerance_interval_unit_cd,
     pwc.display_format_xml =
     IF (displayformatxml != null) displayformatxml
     ELSE "<xml />"
     ENDIF
     , pwc.lock_target_dose_flag = request->planlist[idx].complist[cidx].lock_target_dose_flag, pwc
     .updt_dt_tm = cnvtdatetime(sysdate),
     pwc.updt_id = reqinfo->updt_id, pwc.updt_task = reqinfo->updt_task, pwc.updt_applctx = reqinfo->
     updt_applctx,
     pwc.updt_cnt = (pwc.updt_cnt+ 1)
    WHERE (pwc.pathway_comp_id=request->planlist[idx].complist[cidx].pathway_comp_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG","Unable to update PATHWAY_COMP")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_component(idx=i4,cidx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE comp_updt_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    pwc.*
    FROM pathway_comp pwc
    WHERE (pwc.pathway_comp_id=request->planlist[idx].complist[cidx].pathway_comp_id)
    HEAD REPORT
     comp_updt_cnt = pwc.updt_cnt
    WITH forupdate(pwc), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG","Failed to get a lock on PATHWAY_COMP")
    RETURN("F")
   ENDIF
   IF ((comp_updt_cnt != request->planlist[idx].complist[cidx].updt_cnt))
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to update PATHWAY_COMP table.  Row was changed by another user."," table updt_cnt = ",
      comp_updt_cnt,"req updt_cnt = ",request->planlist[idx].complist[cidx].updt_cnt))
    RETURN("F")
   ENDIF
   UPDATE  FROM pathway_comp pwc
    SET pwc.active_ind = 0, pwc.updt_dt_tm = cnvtdatetime(sysdate), pwc.updt_id = reqinfo->updt_id,
     pwc.updt_task = reqinfo->updt_task, pwc.updt_applctx = reqinfo->updt_applctx, pwc.updt_cnt = (
     pwc.updt_cnt+ 1)
    WHERE (pwc.pathway_comp_id=request->planlist[idx].complist[cidx].pathway_comp_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_CATALOG","Unable to update PATHWAY_COMP")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_os_reltns(idx=i4,cidx=i4,ord_sent_cnt=i4) =c1)
   INSERT  FROM pw_comp_os_reltn pcor,
     (dummyt d  WITH seq = value(ord_sent_cnt))
    SET pcor.order_sentence_id = request->planlist[idx].complist[cidx].ordsentlist[d.seq].
     order_sentence_id, pcor.order_sentence_seq = request->planlist[idx].complist[cidx].ordsentlist[d
     .seq].order_sentence_seq, pcor.iv_comp_syn_id = request->planlist[idx].complist[cidx].
     ordsentlist[d.seq].iv_comp_syn_id,
     pcor.pathway_comp_id = request->planlist[idx].complist[cidx].pathway_comp_id, pcor
     .normalized_dose_unit_ind = request->planlist[idx].complist[cidx].ordsentlist[d.seq].
     normalized_dose_unit_ind, pcor.updt_dt_tm = cnvtdatetime(sysdate),
     pcor.updt_id = reqinfo->updt_id, pcor.updt_task = reqinfo->updt_task, pcor.updt_applctx =
     reqinfo->updt_applctx,
     pcor.updt_cnt = 0
    PLAN (d)
     JOIN (pcor)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
     "Failed to insert new row(s) into PW_COMP_OS_RELTN table")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_os_reltns(comp_id=f8) =c1)
   DELETE  FROM pw_comp_os_reltn pcor
    SET pcor.seq = 1
    WHERE pcor.pathway_comp_id=comp_id
    WITH nocounter
   ;end delete
   IF (curqual=0)
    CALL report_failure("DELETE","F","DCP_UPD_PLAN_CATALOG",
     "Failed to delete row(s) from PW_COMP_OS_RELTN table")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_plan_reltns(reltn_cnt=i4) =c1)
   INSERT  FROM pw_cat_reltn pcr,
     (dummyt d  WITH seq = value(reltn_cnt))
    SET pcr.pw_cat_s_id = request->planreltnlist[d.seq].pw_cat_s_id, pcr.pw_cat_t_id = request->
     planreltnlist[d.seq].pw_cat_t_id, pcr.type_mean = request->planreltnlist[d.seq].type_mean,
     pcr.offset_qty = request->planreltnlist[d.seq].offset_qty, pcr.offset_unit_cd = request->
     planreltnlist[d.seq].offset_unit_cd, pcr.updt_dt_tm = cnvtdatetime(sysdate),
     pcr.updt_id = reqinfo->updt_id, pcr.updt_task = reqinfo->updt_task, pcr.updt_cnt = 0,
     pcr.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (pcr)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
     "Failed to insert new row(s) into PW_CAT_RELTN table")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_dose_calc_method(idx=i4,cidx=i4) =c1)
  IF (pw_def_dose_calc_method_table_exists)
   FOR (methodpairreltnidx = 1 TO size(request->planlist[idx].complist[cidx].
    qual_defaultmethodpairreltn,5))
    SET nbr_pairs = size(request->planlist[idx].complist[cidx].qual_defaultmethodpairreltn[
     methodpairreltnidx].qual_methodpair,5)
    IF (nbr_pairs > 0)
     INSERT  FROM pw_def_dose_calc_method pddcm,
       (dummyt d  WITH seq = value(nbr_pairs))
      SET pddcm.pathway_comp_id = request->planlist[idx].complist[cidx].pathway_comp_id, pddcm
       .pw_def_dose_calc_method_id = seq(reference_seq,nextval), pddcm.facility_cd = request->
       planlist[idx].complist[cidx].qual_defaultmethodpairreltn[methodpairreltnidx].facility_cd,
       pddcm.method_cd = request->planlist[idx].complist[cidx].qual_defaultmethodpairreltn[
       methodpairreltnidx].qual_methodpair[d.seq].method_cd, pddcm.method_mean = request->planlist[
       idx].complist[cidx].qual_defaultmethodpairreltn[methodpairreltnidx].qual_methodpair[d.seq].
       method_mean, pddcm.updt_dt_tm = cnvtdatetime(sysdate),
       pddcm.updt_id = reqinfo->updt_id, pddcm.updt_cnt = 0, pddcm.updt_task = reqinfo->updt_task,
       pddcm.updt_applctx = reqinfo->updt_applctx
      PLAN (d)
       JOIN (pddcm)
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
       "Failed to insert new row(s) into PW_DEF_DOSE_CALC_METHOD table")
      RETURN("F")
     ENDIF
    ENDIF
   ENDFOR
  ENDIF
  RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_dose_calc_method(idx=i4,cidx=i4) =c1)
  IF (pw_def_dose_calc_method_table_exists)
   DELETE  FROM pw_def_dose_calc_method pddcm
    WHERE (pddcm.pathway_comp_id=request->planlist[idx].complist[cidx].pathway_comp_id)
    WITH nocounter
   ;end delete
  ENDIF
  RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_plan_evidence_reltns(idx=i4) =c1)
   INSERT  FROM pw_evidence_reltn per
    SET per.pw_evidence_reltn_id = request->pwevidencereltnlist[idx].pw_evidence_reltn_id, per
     .pathway_catalog_id = request->pwevidencereltnlist[idx].pathway_catalog_id, per.dcp_clin_cat_cd
      = request->pwevidencereltnlist[idx].dcp_clin_cat_cd,
     per.dcp_clin_sub_cat_cd = request->pwevidencereltnlist[idx].dcp_clin_sub_cat_cd, per
     .pathway_comp_id = request->pwevidencereltnlist[idx].pathway_comp_id, per.type_mean = request->
     pwevidencereltnlist[idx].type_mean,
     per.evidence_locator = request->pwevidencereltnlist[idx].evidence_locator, per.ref_text_reltn_id
      = request->pwevidencereltnlist[idx].ref_text_reltn_id, per.evidence_sequence = request->
     pwevidencereltnlist[idx].evidence_sequence,
     per.updt_dt_tm = cnvtdatetime(sysdate), per.updt_id = reqinfo->updt_id, per.updt_task = reqinfo
     ->updt_task,
     per.updt_cnt = 0, per.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
     "Failed to insert new row(s) into PW_EVIDENCE_RELTN table")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_plan_evidence_reltns(idx=i4) =c1)
   UPDATE  FROM pw_evidence_reltn per
    SET per.pathway_catalog_id = request->pwevidencereltnlist[idx].pathway_catalog_id, per
     .dcp_clin_cat_cd = request->pwevidencereltnlist[idx].dcp_clin_cat_cd, per.dcp_clin_sub_cat_cd =
     request->pwevidencereltnlist[idx].dcp_clin_sub_cat_cd,
     per.pathway_comp_id = request->pwevidencereltnlist[idx].pathway_comp_id, per.type_mean = request
     ->pwevidencereltnlist[idx].type_mean, per.evidence_locator = request->pwevidencereltnlist[idx].
     evidence_locator,
     per.ref_text_reltn_id = request->pwevidencereltnlist[idx].ref_text_reltn_id, per
     .evidence_sequence = request->pwevidencereltnlist[idx].evidence_sequence, per.updt_dt_tm =
     cnvtdatetime(sysdate),
     per.updt_id = reqinfo->updt_id, per.updt_task = reqinfo->updt_task, per.updt_cnt = 0,
     per.updt_applctx = reqinfo->updt_applctx
    WHERE (per.pw_evidence_reltn_id=request->pwevidencereltnlist[idx].pw_evidence_reltn_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",
     "Failed to update PW_EVIDENCE_RELTN table")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_plan_evidence_reltns(idx=i4) =c1)
  DELETE  FROM pw_evidence_reltn per
   SET per.seq = 1
   WHERE (per.pw_evidence_reltn_id=request->pwevidencereltnlist[idx].pw_evidence_reltn_id)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   CALL report_failure("DELETE","F","DCP_UPD_PLAN_CATALOG",
    "Failed to delete row from PW_EVIDENCE_RELTN table")
   RETURN("F")
  ENDIF
 END ;Subroutine
 SUBROUTINE (remove_all_plan_reltns(reltn_cnt=i4) =c1)
   DECLARE stat = i2 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   RECORD reltns(
     1 idlist[*]
       2 id = f8
   )
   SET stat = alterlist(reltns->idlist,10)
   SET reltns->idlist[1].id = request->parent_cat_id
   SELECT INTO "nl:"
    pcr.pw_cat_s_id
    FROM pw_cat_reltn pcr
    WHERE (pcr.pw_cat_s_id=request->parent_cat_id)
     AND pcr.type_mean IN ("GROUP", "SUBPHASE", "PHASEOFFSET")
    HEAD REPORT
     cnt = 1
    DETAIL
     cnt += 1
     IF (cnt > size(reltns->idlist,5))
      stat = alterlist(reltns->idlist,(cnt+ 10))
     ENDIF
     reltns->idlist[cnt].id = pcr.pw_cat_t_id
    FOOT REPORT
     stat = alterlist(reltns->idlist,cnt)
    WITH nocounter
   ;end select
   IF (curqual=0)
    FREE RECORD reltns
    RETURN("S")
   ENDIF
   DELETE  FROM pw_cat_reltn pcr,
     (dummyt d  WITH seq = value(size(reltns->idlist,5)))
    SET pcr.seq = 1
    PLAN (d)
     JOIN (pcr
     WHERE (pcr.pw_cat_s_id=reltns->idlist[d.seq].id))
    WITH nocounter
   ;end delete
   IF (curqual=0)
    CALL report_failure("DELETE","F","DCP_UPD_PLAN_CATALOG",
     "Unable to remove plan relationships from PW_CAT_RELTN")
    FREE RECORD reltns
    RETURN("F")
   ENDIF
   FREE RECORD reltns
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_parent_plan_version(version=i4,id=f8) =c1)
   UPDATE  FROM pathway_catalog pwc
    SET pwc.version = version
    WHERE pwc.pathway_catalog_id=id
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG","Unable to update PATHWAY_CATALOG")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_comp_reltns(idx=i4) =c1)
   DECLARE comp_r_cnt = i4 WITH protect, constant(value(size(request->planlist[idx].compreltnlist,5))
    )
   INSERT  FROM pw_comp_reltn pcr,
     (dummyt d  WITH seq = value(comp_r_cnt))
    SET pcr.pathway_comp_s_id = request->planlist[idx].compreltnlist[d.seq].pathway_comp_s_id, pcr
     .pathway_comp_t_id = request->planlist[idx].compreltnlist[d.seq].pathway_comp_t_id, pcr
     .type_mean = request->planlist[idx].compreltnlist[d.seq].type_mean,
     pcr.offset_quantity = request->planlist[idx].compreltnlist[d.seq].offset_quantity, pcr
     .offset_unit_cd = request->planlist[idx].compreltnlist[d.seq].offset_unit_cd, pcr
     .pathway_catalog_id = request->planlist[idx].compreltnlist[d.seq].pathway_catalog_id,
     pcr.updt_dt_tm = cnvtdatetime(sysdate), pcr.updt_id = reqinfo->updt_id, pcr.updt_task = reqinfo
     ->updt_task,
     pcr.updt_cnt = 0, pcr.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (pcr)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
     "Failed to insert new row(s) into PW_COMP_RELTN table")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_comp_reltns(idx=i4) =c1)
  DELETE  FROM pw_comp_reltn pcr
   WHERE (pcr.pathway_catalog_id=request->planlist[idx].pathway_catalog_id)
   WITH nocounter
  ;end delete
  RETURN("S")
 END ;Subroutine
 SUBROUTINE (version_plan(idx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE pw_updt_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    pc.*
    FROM pathway_catalog pc
    WHERE (pc.pathway_catalog_id=request->planlist[idx].pathway_catalog_id)
    HEAD REPORT
     pw_updt_cnt = pc.updt_cnt
    WITH forupdate(pc), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("VERSION","F","DCP_UPD_PLAN_CATALOG",build(
      "Failed to get a lock on PATHWAY_CATALOG for PW_CAT_ID=",request->planlist[idx].
      pathway_catalog_id," DESC=",trim(request->planlist[idx].description)))
    RETURN("F")
   ENDIF
   IF ((pw_updt_cnt != request->planlist[idx].updt_cnt))
    CALL report_failure("VERSION","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to version PATHWAY_CATALOG table.  Row was changed by another user. PW_CAT_ID=",request
      ->planlist[idx].pathway_catalog_id," DESC=",trim(request->planlist[idx].description)))
    RETURN("F")
   ENDIF
   UPDATE  FROM pathway_catalog pc
    SET pc.version = (pc.version+ 1), pc.beg_effective_dt_tm = cnvtdatetime(sysdate), pc.updt_dt_tm
      = cnvtdatetime(sysdate),
     pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->
     updt_applctx,
     pc.updt_cnt = (pc.updt_cnt+ 1)
    WHERE (pc.pathway_catalog_id=request->planlist[idx].pathway_catalog_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("VERSION","F","DCP_UPD_PLAN_CATALOG",build(
      "Unable to increment version on PATHWAY_CATALOG.  PW_CAT_ID=",request->planlist[idx].
      pathway_catalog_id,".  DESC=",trim(request->planlist[idx].description)))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (process_facility_flex_update(idx=i4) =c1)
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE flex_all_ind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM pw_cat_flex pcf
    WHERE (pcf.pathway_catalog_id=request->planlist[idx].pathway_catalog_id)
     AND pcf.parent_entity_id=0
    HEAD REPORT
     flex_all_ind = 1
    WITH nocounter
   ;end select
   IF (size(request->facilityflexlist,5) > 0)
    SET substat = remove_facility_flex(idx)
    IF (substat="F")
     RETURN("F")
    ENDIF
    SET substat = insert_facility_flex_by_cd(idx)
    RETURN(substat)
   ELSEIF (size(request->facilityflexlist,5)=0
    AND flex_all_ind=0)
    SET substat = remove_facility_flex(idx)
    IF (substat="F")
     RETURN("F")
    ENDIF
    SET substat = insert_facility_flex_all_access(idx)
    RETURN(substat)
   ELSEIF (testing_ind=0)
    SET substat = update_facility_flex_plan_display(idx)
    RETURN(substat)
   ENDIF
   RETURN(substat)
 END ;Subroutine
 SUBROUTINE (insert_facility_flex_all_access(idx=i4) =c1)
   DECLARE description = vc WITH noconstant(fillstring(100," ")), protect
   IF (testing_ind=1)
    SET description = fillstring(100," ")
    SET description = trim(concat("pathway_catalog_id=",build(request->planlist[idx].
       pathway_catalog_id)))
    IF (size(description,8) > 100)
     SET description = substring(1,100,description)
    ENDIF
   ENDIF
   INSERT  FROM pw_cat_flex pcf
    SET pcf.display_description_key =
     IF (testing_ind=1) description
     ELSEIF ((request->planlist[idx].display_description > "")) cnvtupper(trim(request->planlist[idx]
        .display_description))
     ELSE cnvtupper(trim(request->planlist[idx].description))
     ENDIF
     , pcf.pathway_catalog_id = request->planlist[idx].pathway_catalog_id, pcf.parent_entity_id = 0,
     pcf.parent_entity_name = "CODE_VALUE", pcf.updt_dt_tm = cnvtdatetime(sysdate), pcf.updt_id =
     reqinfo->updt_id,
     pcf.updt_task = reqinfo->updt_task, pcf.updt_applctx = reqinfo->updt_applctx, pcf.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG","Unable to insert into PW_CAT_FLEX")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_facility_flex_by_cd(idx=i4) =c1)
   DECLARE facilitycnt = i4 WITH protect, constant(value(size(request->facilityflexlist,5)))
   IF (facilitycnt=0)
    RETURN("S")
   ENDIF
   DECLARE description = vc WITH noconstant(fillstring(100," ")), protect
   IF (testing_ind=1)
    SET description = fillstring(100," ")
    SET description = trim(concat("pathway_catalog_id=",build(request->planlist[idx].
       pathway_catalog_id)))
    IF (size(description,8) > 100)
     SET description = substring(1,100,description)
    ENDIF
   ENDIF
   INSERT  FROM pw_cat_flex pcf,
     (dummyt d  WITH seq = value(facilitycnt))
    SET pcf.display_description_key =
     IF (testing_ind=1) description
     ELSEIF ((request->planlist[idx].display_description > "")) cnvtupper(trim(request->planlist[idx]
        .display_description))
     ELSE cnvtupper(trim(request->planlist[idx].description))
     ENDIF
     , pcf.pathway_catalog_id = request->planlist[idx].pathway_catalog_id, pcf.parent_entity_id =
     request->facilityflexlist[d.seq].facility_cd,
     pcf.parent_entity_name = "CODE_VALUE", pcf.updt_dt_tm = cnvtdatetime(sysdate), pcf.updt_id =
     reqinfo->updt_id,
     pcf.updt_task = reqinfo->updt_task, pcf.updt_applctx = reqinfo->updt_applctx, pcf.updt_cnt = 0
    PLAN (d)
     JOIN (pcf)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
     "Failed to insert new row(s) into PW_CAT_FLEX table")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_facility_flex(idx=i4) =c1)
   DELETE  FROM pw_cat_flex pcf
    SET pcf.seq = 1
    WHERE (pcf.pathway_catalog_id=request->planlist[idx].pathway_catalog_id)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    CALL report_failure("DELETE","F","DCP_UPD_PLAN_CATALOG",
     "Failed to delete row(s) from PW_CAT_FLEX table")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_facility_flex_plan_display(idx=i4) =c1)
   UPDATE  FROM pw_cat_flex pcf
    SET pcf.display_description_key =
     IF ((request->planlist[idx].display_description > "")) cnvtupper(trim(request->planlist[idx].
        display_description))
     ELSE cnvtupper(trim(request->planlist[idx].description))
     ENDIF
     , pcf.updt_dt_tm = cnvtdatetime(sysdate), pcf.updt_id = reqinfo->updt_id,
     pcf.updt_task = reqinfo->updt_task, pcf.updt_applctx = reqinfo->updt_applctx, pcf.updt_cnt = (
     pcf.updt_cnt+ 1)
    WHERE (pcf.pathway_catalog_id=request->planlist[idx].pathway_catalog_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("VERSION","F","DCP_UPD_PLAN_CATALOG",
     "Unable to update display_description_key on PW_CAT_FLEX")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_problem_diagnosis(idx=i4) =c1)
   CALL create_new_concept_cki_entity_r_id(new_concept_cki_r_id)
   IF (new_concept_cki_r_id=0.0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
     "Unable to generate concept_cki_entity_r_id for problem/diagnosis")
    RETURN("F")
   ENDIF
   INSERT  FROM concept_cki_entity_r ccer
    SET ccer.concept_cki_entity_r_id = new_concept_cki_r_id, ccer.entity_name = "PATHWAY_CATALOG",
     ccer.entity_id = request->parent_cat_id,
     ccer.concept_cki = request->problemdiaglist[idx].concept_cki, ccer.beg_effective_dt_tm =
     cnvtdatetime(sysdate), ccer.end_effective_dt_tm = cnvtdatetime(end_date_string),
     ccer.active_ind = 1, ccer.reltn_type_cd = reltn_type_cd, ccer.updt_dt_tm = cnvtdatetime(sysdate),
     ccer.updt_id = reqinfo->updt_id, ccer.updt_task = reqinfo->updt_task, ccer.updt_applctx =
     reqinfo->updt_applctx,
     ccer.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
     "Unable to insert problem/diagnosis row into CONCEPT_CKI_ENTITY_R")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_all_problem_diagnosis(problemcnt=i4) =c1)
  DELETE  FROM concept_cki_entity_r ccer
   SET ccer.seq = 1
   WHERE (ccer.entity_id=request->parent_cat_id)
    AND ccer.entity_name="PATHWAY_CATALOG"
   WITH nocounter
  ;end delete
  RETURN("S")
 END ;Subroutine
 SUBROUTINE (create_new_concept_cki_entity_r_id(new_concept_cki_r_id=f8(ref)) =null)
   SELECT INTO "nl:"
    nextseqnum = seq(entity_reltn_seq,nextval)
    FROM dual
    DETAIL
     new_concept_cki_r_id = nextseqnum
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (remove_comp_group(idx=i4) =c1)
  DELETE  FROM pw_comp_group pwcg
   SET pwcg.seq = 1
   WHERE (pwcg.pathway_catalog_id=request->planlist[idx].pathway_catalog_id)
   WITH nocounter
  ;end delete
  RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_comp_group(idx=i4,gidx=i4) =c1)
   SET group_comp_cnt = value(size(request->planlist[idx].compgrouplist[gidx].memberlist,5))
   IF (group_comp_cnt > 0)
    INSERT  FROM pw_comp_group pwcg,
      (dummyt d  WITH seq = value(group_comp_cnt))
     SET pwcg.pathway_catalog_id = request->planlist[idx].pathway_catalog_id, pwcg.pw_comp_group_id
       = request->planlist[idx].compgrouplist[gidx].pw_comp_group_id, pwcg.type_mean = request->
      planlist[idx].compgrouplist[gidx].type_mean,
      pwcg.pathway_comp_id = request->planlist[idx].compgrouplist[gidx].memberlist[d.seq].
      pathway_comp_id, pwcg.comp_seq = request->planlist[idx].compgrouplist[gidx].memberlist[d.seq].
      comp_seq, pwcg.anchor_component_ind = request->planlist[idx].compgrouplist[gidx].memberlist[d
      .seq].anchor_component_ind,
      pwcg.description = trim(request->planlist[idx].compgrouplist[gidx].description), pwcg
      .linking_rule_flag = request->planlist[idx].compgrouplist[gidx].linking_rule_flag, pwcg
      .linking_rule_quantity = request->planlist[idx].compgrouplist[gidx].linking_rule_quantity,
      pwcg.override_reason_flag = request->planlist[idx].compgrouplist[gidx].override_reason_flag,
      pwcg.updt_dt_tm = cnvtdatetime(sysdate), pwcg.updt_id = reqinfo->updt_id,
      pwcg.updt_task = reqinfo->updt_task, pwcg.updt_applctx = reqinfo->updt_applctx, pwcg.updt_cnt
       = 0
     PLAN (d)
      JOIN (pwcg)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     RETURN("F")
    ENDIF
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_comp_phase_reltn(idx=i4) =c1)
   INSERT  FROM pw_comp_cat_reltn pccr
    SET pccr.pw_comp_cat_reltn_id = seq(reference_seq,nextval), pccr.pathway_comp_id = request->
     compphasereltnlist[idx].pathway_comp_id, pccr.pathway_catalog_id = request->compphasereltnlist[
     idx].pathway_catalog_id,
     pccr.type_mean = request->compphasereltnlist[idx].type_mean, pccr.updt_applctx = reqinfo->
     updt_applctx, pccr.updt_cnt = 0,
     pccr.updt_dt_tm = cnvtdatetime(sysdate), pccr.updt_id = reqinfo->updt_id, pccr.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_comp_phase_reltn(idx=i4) =c1)
   DELETE  FROM pw_comp_cat_reltn pccr
    WHERE (pccr.pw_comp_cat_reltn_id=request->compphasereltnlist[idx].pw_comp_cat_reltn_id)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (process_plan_synonyms(i=i4) =c1)
   DECLARE action = i2 WITH protect, noconstant(0)
   DECLARE syncnt = i2 WITH protect, noconstant(0)
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE synsize = i2 WITH protect, noconstant(0)
   SET synsize = value(size(request->planlist[i].synonymlist,5))
   SET syncnt = 0
   FOR (j = 1 TO synsize)
    SET action = request->planlist[i].synonymlist[j].action_flag
    IF (action=2)
     SET syncnt += 1
     SET substat = remove_plan_synonym(i,j)
     IF (substat="F")
      RETURN("F")
     ENDIF
    ENDIF
   ENDFOR
   FOR (j = 1 TO synsize)
    SET action = request->planlist[i].synonymlist[j].action_flag
    IF (action=3)
     SET syncnt += 1
     SET substat = update_plan_synonym(i,j)
     IF (substat="F")
      RETURN("F")
     ENDIF
    ENDIF
   ENDFOR
   FOR (j = 1 TO synsize)
    SET action = request->planlist[i].synonymlist[j].action_flag
    IF (action=1)
     SET syncnt += 1
     SET substat = insert_plan_synonym(i,j)
     IF (substat="F")
      RETURN("F")
     ENDIF
    ENDIF
   ENDFOR
   IF (syncnt < synsize)
    SET substat = "F"
    CALL report_failure("PROCESS","F","DCP_UPD_PLAN_CATALOG",
     "Unrecognized plan synonym flag action(s)")
   ENDIF
   RETURN(substat)
 END ;Subroutine
 SUBROUTINE (insert_plan_synonym(idx=i4,sidx=i4) =c1)
   INSERT  FROM pw_cat_synonym pcs
    SET pcs.pw_cat_synonym_id = seq(reference_seq,nextval), pcs.pathway_catalog_id = request->
     planlist[idx].pathway_catalog_id, pcs.synonym_name = trim(request->planlist[idx].synonymlist[
      sidx].synonym_name),
     pcs.synonym_name_key = trim(cnvtupper(request->planlist[idx].synonymlist[sidx].synonym_name)),
     pcs.updt_dt_tm = cnvtdatetime(sysdate), pcs.updt_id = reqinfo->updt_id,
     pcs.updt_task = reqinfo->updt_task, pcs.updt_cnt = 0, pcs.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_CATALOG",
     "Failed to insert new row into PW_CAT_SYNONYM table")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (remove_plan_synonym(idx=i4,sidx=i4) =c1)
   DELETE  FROM alt_sel_list asl
    WHERE (asl.pw_cat_synonym_id=request->planlist[idx].synonymlist[sidx].pw_cat_synonym_id)
    WITH nocounter
   ;end delete
   DELETE  FROM pw_cat_synonym pcs
    WHERE (pcs.pw_cat_synonym_id=request->planlist[idx].synonymlist[sidx].pw_cat_synonym_id)
     AND pcs.pw_cat_synonym_id != 0
    WITH nocounter
   ;end delete
   IF (curqual=0)
    CALL report_failure("DELETE","F","DCP_UPD_PLAN_CATALOG",build(
      "Failed to delete row pw_cat_synonym.pw_cat_synonym_id=",request->planlist[idx].synonymlist[
      sidx].pw_cat_synonym_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_plan_synonym(idx=i4,sidx=i4) =c1)
   UPDATE  FROM pw_cat_synonym pcs
    SET pcs.synonym_name = trim(request->planlist[idx].synonymlist[sidx].synonym_name), pcs
     .synonym_name_key = trim(cnvtupper(request->planlist[idx].synonymlist[sidx].synonym_name)), pcs
     .updt_dt_tm = cnvtdatetime(sysdate),
     pcs.updt_id = reqinfo->updt_id, pcs.updt_task = reqinfo->updt_task, pcs.updt_applctx = reqinfo->
     updt_applctx,
     pcs.updt_cnt = (pcs.updt_cnt+ 1)
    WHERE (pcs.pw_cat_synonym_id=request->planlist[idx].synonymlist[sidx].pw_cat_synonym_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_CATALOG",build("Unable to update row ",request->
      planlist[idx].synonymlist[sidx].pw_cat_synonym_id," on PW_CAT_SYNONYM table"))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) =null)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cfailed = "T"
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
