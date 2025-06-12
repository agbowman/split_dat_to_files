CREATE PROGRAM dcp_ens_phx:dba
 SET modify = predeclare
 DECLARE getnewid() = null
 DECLARE findnomenclatureid() = null
 DECLARE addinactiveproblems() = null
 FREE RECORD reply
 RECORD reply(
   1 updt_dt_tm = dq8
   1 pregnancies[*]
     2 pregnancy_id = f8
     2 org_id = f8
     2 pregnancy_instance_id = f8
     2 problem_id = f8
     2 sensitive_ind = i2
     2 preg_start_dt_tm = dq8
     2 preg_end_dt_tm = dq8
     2 override_comment = vc
     2 confirmation_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 pregnancy_entities[*]
       3 pregnancy_entity_id = f8
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 component_type_cd = f8
     2 pregnancy_actions[*]
       3 pregnancy_action_id = f8
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 action_type_cd = f8
       3 prsnl_id = f8
     2 pregnancy_children[*]
       3 pregnancy_child_id = f8
       3 gender_cd = f8
       3 child_name = vc
       3 person_id = f8
       3 restrict_person_id_ind = i2
       3 father_name = vc
       3 delivery_method_cd = f8
       3 delivery_hospital = vc
       3 gestation_age = i4
       3 labor_duration = i4
       3 weight_amt = f8
       3 weight_unit_cd = f8
       3 anesthesia_txt = vc
       3 preterm_labor_txt = vc
       3 delivery_dt_tm = dq8
       3 delivery_tz = i4
       3 neonate_outcome_cd = f8
       3 child_comment_id = f8
       3 child_entities[*]
         4 pregnancy_child_entity_id = f8
         4 parent_entity_name = vc
         4 parent_entity_id = f8
         4 component_type_cd = f8
         4 entity_text = vc
       3 delivery_date_precision_flag = i2
       3 delivery_date_qualifier_flag = i2
       3 gestation_term_txt = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 RECORD long_text_list(
   1 list[*]
     2 long_text = vc
     2 long_text_id = f8
 )
 FREE RECORD probrequest
 RECORD probrequest(
   1 person_id = f8
   1 problem[*]
     2 problem_action_ind = i2
     2 problem_id = f8
     2 problem_instance_id = f8
     2 nomenclature_id = f8
     2 annotated_display = vc
     2 organization_id = f8
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 problem_ftdesc = vc
     2 classification_cd = f8
     2 confirmation_status_cd = f8
     2 qualifier_cd = f8
     2 life_cycle_status_cd = f8
     2 life_cycle_dt_tm = dq8
     2 life_cycle_dt_flag = i2
     2 life_cycle_dt_cd = f8
     2 persistence_cd = f8
     2 certainty_cd = f8
     2 ranking_cd = f8
     2 probability = f8
     2 onset_dt_flag = i2
     2 onset_dt_cd = f8
     2 onset_dt_tm = dq8
     2 onset_tz = i4
     2 course_cd = f8
     2 severity_class_cd = f8
     2 severity_cd = f8
     2 severity_ftdesc = vc
     2 prognosis_cd = f8
     2 person_aware_cd = f8
     2 family_aware_cd = f8
     2 person_aware_prognosis_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 status_upt_precision_flag = i2
     2 status_upt_precision_cd = f8
     2 status_upt_dt_tm = dq8
     2 cancel_reason_cd = f8
     2 originating_nomenclature_id = f8
     2 problem_comment[*]
       3 problem_comment_id = f8
       3 comment_action_ind = i2
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
       3 comment_prsnl_name = vc
       3 problem_comment = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 problem_discipline[*]
       3 discipline_action_ind = i2
       3 problem_discipline_id = f8
       3 management_discipline_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 problem_prsnl[*]
       3 prsnl_action_ind = i2
       3 problem_reltn_dt_tm = dq8
       3 problem_reltn_cd = f8
       3 problem_prsnl_id = f8
       3 problem_reltn_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 secondary_desc_list[*]
       3 group_sequence = i4
       3 group[*]
         4 secondary_desc_id = f8
         4 nomenclature_id = f8
         4 sequence = i4
     2 problem_uuid = vc
     2 problem_instance_uuid = vc
     2 contributor_system_cd = f8
     2 problem_type_flag = i2
     2 show_in_pm_history_ind = i2
   1 skip_fsi_trigger = i2
 )
 SUBROUTINE (reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) =null)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE (fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) =null)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt += 1
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE preg_cnt = i4 WITH public, noconstant(size(request->pregnancies,5))
 DECLARE action_cnt = i4 WITH public, noconstant(0)
 DECLARE entity_cnt = i4 WITH public, noconstant(0)
 DECLARE child_cnt = i4 WITH public, noconstant(0)
 DECLARE ce_cnt = i4 WITH public, noconstant(0)
 DECLARE preg_idx = i4 WITH private, noconstant(0)
 DECLARE action_idx = i4 WITH private, noconstant(0)
 DECLARE entity_idx = i4 WITH private, noconstant(0)
 DECLARE child_idx = i4 WITH private, noconstant(0)
 DECLARE ce_idx = i4 WITH private, noconstant(0)
 DECLARE add_preg = i2 WITH protected, constant(1)
 DECLARE upt_preg = i2 WITH protected, constant(2)
 DECLARE del_preg = i2 WITH protected, constant(3)
 DECLARE cls_preg = i2 WITH protected, constant(4)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE problem_cnt = i4 WITH public, noconstant(0)
 DECLARE new_id = f8 WITH public, noconstant(0.0)
 DECLARE source_identifier = vc WITH public, noconstant("429859012")
 DECLARE source_vocabulary_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE gm_cd = f8 WITH public, constant(uar_get_code_by("MEANING",54,"GM"))
 DECLARE nomenclature_id = f8 WITH public, noconstant(0.0)
 DECLARE annotated_display = vc WITH protect, noconstant("")
 DECLARE new_long_text_id = f8 WITH public, noconstant(0.0)
 DECLARE stat = i2 WITH protected, noconstant(0)
 DECLARE active_code = f8 WITH protected, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE childtable = vc WITH constant("PREGNANCY_CHILD")
 DECLARE childentitytable = vc WITH constant("PREGNANCY_CHILD_ENTITY_R")
 DECLARE longtexttable = vc WITH constant("LONG_TEXT")
 DECLARE emptytext = vc WITH constant("")
 DECLARE phx_now = dq8 WITH protected
 DECLARE end_time = dq8 WITH protected
 DECLARE var1 = vc
 DECLARE var2 = vc
 DECLARE add_cnt = i4 WITH public
 DECLARE del_cnt = i4 WITH public
 DECLARE resolved_lifecycle_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12030,"RESOLVED")
  )
 DECLARE inactive_lifecycle_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12030,"INACTIVE")
  )
 DECLARE canceled_lifecycle_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12030,"CANCELED")
  )
 DECLARE problem_confirmation_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12031,
   "CONFIRMED"))
 DECLARE delivery_dttm = dq8 WITH public
 DECLARE delivery_dt_precision = i2 WITH public, noconstant(0)
 DECLARE delivery_dt_qualifier = i2 WITH public, noconstant(0)
 DECLARE problem_lifecycle_cd = f8 WITH public, noconstant(0.0)
 DECLARE life_cycle_dt_cd = f8 WITH public, noconstant(0.0)
 DECLARE life_cycle_dt_about = f8 WITH public, constant(uar_get_code_by("MEANING",25320,"ABOUT"))
 DECLARE life_cycle_dt_unknown = f8 WITH public, constant(uar_get_code_by("MEANING",25320,"UNKNOWN"))
 DECLARE life_cycle_dt_before = f8 WITH public, constant(uar_get_code_by("MEANING",25320,"BEFORE"))
 DECLARE life_cycle_dt_after = f8 WITH public, constant(uar_get_code_by("MEANING",25320,"AFTER"))
 DECLARE classification_cd = f8 WITH protect, noconstant(0.0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE onset_dttm = dq8 WITH protect
 DECLARE encntr_id_column_exists = i2 WITH public, noconstant(0)
 IF (checkdic("PREGNANCY_INSTANCE.ENCNTR_ID","A",0) > 1)
  SET encntr_id_column_exists = 1
 ENDIF
 IF (validate(request->classification_cd))
  SET classification_cd = request->classification_cd
 ENDIF
 IF (validate(request->nomen_source_id))
  SET source_identifier = request->nomen_source_id
 ENDIF
 IF (validate(request->nomen_vocab_mean))
  SET source_vocabulary_cd = uar_get_code_by("MEANING",400,nullterm(request->nomen_vocab_mean))
 ENDIF
 IF (validate(unit_test_timestamp))
  SET phx_now = unit_test_timestamp
 ELSE
  SET phx_now = cnvtdatetime(sysdate)
 ENDIF
 SET end_time = cnvtdatetime("31-DEC-2100 23:59:59.99")
 SET reply->status_data.status = "F"
 SET reply->updt_dt_tm = cnvtdatetime(phx_now)
 SET stat = alterlist(reply->pregnancies,preg_cnt)
 FOR (preg_idx = 1 TO preg_cnt)
   IF ((request->pregnancies[preg_idx].preg_end_dt_tm=null))
    SET request->pregnancies[preg_idx].preg_end_dt_tm = cnvtdatetime(curdate,curtime)
   ENDIF
   IF ((request->pregnancies[preg_idx].preg_start_dt_tm=null))
    SET request->pregnancies[preg_idx].preg_start_dt_tm = cnvtdatetime(curdate,curtime)
   ENDIF
   SET reply->pregnancies[preg_idx].preg_start_dt_tm = request->pregnancies[preg_idx].
   preg_start_dt_tm
   SET reply->pregnancies[preg_idx].preg_end_dt_tm = request->pregnancies[preg_idx].preg_end_dt_tm
   SET reply->pregnancies[preg_idx].confirmation_dt_tm = request->pregnancies[preg_idx].
   confirmation_dt_tm
   SET reply->pregnancies[preg_idx].override_comment = request->pregnancies[preg_idx].
   override_comment
   SET reply->pregnancies[preg_idx].problem_id = request->pregnancies[preg_idx].problem_id
   SET reply->pregnancies[preg_idx].sensitive_ind = request->pregnancies[preg_idx].sensitive_ind
   SET reply->pregnancies[preg_idx].updt_dt_tm = cnvtdatetime(phx_now)
   SET reply->pregnancies[preg_idx].pregnancy_id = request->pregnancies[preg_idx].pregnancy_id
   SET reply->pregnancies[preg_idx].org_id = request->pregnancies[preg_idx].org_id
   SET reply->pregnancies[preg_idx].pregnancy_instance_id = request->pregnancies[preg_idx].
   pregnancy_instance_id
   SET action_cnt = size(request->pregnancies[preg_idx].pregnancy_actions,5)
   SET stat = alterlist(reply->pregnancies[preg_idx].pregnancy_actions,action_cnt)
   FOR (action_idx = 1 TO action_cnt)
     SET reply->pregnancies[preg_idx].pregnancy_actions[action_idx].action_dt_tm = request->
     pregnancies[preg_idx].pregnancy_actions[action_idx].action_dt_tm
     SET reply->pregnancies[preg_idx].pregnancy_actions[action_idx].action_type_cd = request->
     pregnancies[preg_idx].pregnancy_actions[action_idx].action_type_cd
     SET reply->pregnancies[preg_idx].pregnancy_actions[action_idx].action_tz = request->pregnancies[
     preg_idx].pregnancy_actions[action_idx].action_tz
     SET reply->pregnancies[preg_idx].pregnancy_actions[action_idx].prsnl_id = request->pregnancies[
     preg_idx].pregnancy_actions[action_idx].prsnl_id
   ENDFOR
   SET entity_cnt = size(request->pregnancies[preg_idx].pregnancy_entities,5)
   SET stat = alterlist(reply->pregnancies[preg_idx].pregnancy_entities,entity_cnt)
   FOR (entity_idx = 1 TO entity_cnt)
     SET reply->pregnancies[preg_idx].pregnancy_entities[entity_idx].component_type_cd = request->
     pregnancies[preg_idx].pregnancy_entities[entity_idx].component_type_cd
     SET reply->pregnancies[preg_idx].pregnancy_entities[entity_idx].parent_entity_id = request->
     pregnancies[preg_idx].pregnancy_entities[entity_idx].parent_entity_id
     SET reply->pregnancies[preg_idx].pregnancy_entities[entity_idx].parent_entity_name = request->
     pregnancies[preg_idx].pregnancy_entities[entity_idx].parent_entity_name
   ENDFOR
   SET child_cnt = size(request->pregnancies[preg_idx].pregnancy_children,5)
   SET stat = alterlist(reply->pregnancies[preg_idx].pregnancy_children,child_cnt)
   FOR (child_idx = 1 TO child_cnt)
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].anesthesia_txt = request->
     pregnancies[preg_idx].pregnancy_children[child_idx].anesthesia_txt
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].child_name = request->
     pregnancies[preg_idx].pregnancy_children[child_idx].child_name
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].delivery_hospital = request->
     pregnancies[preg_idx].pregnancy_children[child_idx].delivery_hospital
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].delivery_dt_tm = request->
     pregnancies[preg_idx].pregnancy_children[child_idx].delivery_dt_tm
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].delivery_date_precision_flag =
     request->pregnancies[preg_idx].pregnancy_children[child_idx].delivery_date_precision_flag
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].delivery_date_qualifier_flag =
     request->pregnancies[preg_idx].pregnancy_children[child_idx].delivery_date_qualifier_flag
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].delivery_method_cd = request->
     pregnancies[preg_idx].pregnancy_children[child_idx].delivery_method_cd
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].delivery_tz = request->
     pregnancies[preg_idx].pregnancy_children[child_idx].delivery_tz
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].father_name = request->
     pregnancies[preg_idx].pregnancy_children[child_idx].father_name
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].gender_cd = request->pregnancies[
     preg_idx].pregnancy_children[child_idx].gender_cd
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].gestation_age = request->
     pregnancies[preg_idx].pregnancy_children[child_idx].gestation_age
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].labor_duration = request->
     pregnancies[preg_idx].pregnancy_children[child_idx].labor_duration
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].neonate_outcome_cd = request->
     pregnancies[preg_idx].pregnancy_children[child_idx].neonate_outcome_cd
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].person_id = request->pregnancies[
     preg_idx].pregnancy_children[child_idx].person_id
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].pregnancy_child_id = request->
     pregnancies[preg_idx].pregnancy_children[child_idx].pregnancy_child_id
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].preterm_labor_txt = request->
     pregnancies[preg_idx].pregnancy_children[child_idx].preterm_labor_txt
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].weight_amt = request->
     pregnancies[preg_idx].pregnancy_children[child_idx].weight_amt
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].weight_unit_cd = gm_cd
     SET request->pregnancies[preg_idx].pregnancy_children[child_idx].weight_unit_cd = gm_cd
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].restrict_person_id_ind = validate
     (request->pregnancies[preg_idx].pregnancy_children[child_idx].restrict_person_id_ind,0)
     SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].gestation_term_txt = validate(
      request->pregnancies[preg_idx].pregnancy_children[child_idx].gestation_term_txt,"")
     SET ce_cnt = size(request->pregnancies[preg_idx].pregnancy_children[child_idx].child_entities,5)
     SET stat = alterlist(reply->pregnancies[preg_idx].pregnancy_children[child_idx].child_entities,
      ce_cnt)
     FOR (ce_idx = 1 TO ce_cnt)
       SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].child_entities[ce_idx].
       component_type_cd = request->pregnancies[preg_idx].pregnancy_children[child_idx].
       child_entities[ce_idx].component_type_cd
       SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].child_entities[ce_idx].
       parent_entity_id = request->pregnancies[preg_idx].pregnancy_children[child_idx].
       child_entities[ce_idx].parent_entity_id
       SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].child_entities[ce_idx].
       parent_entity_name = request->pregnancies[preg_idx].pregnancy_children[child_idx].
       child_entities[ce_idx].parent_entity_name
       SET reply->pregnancies[preg_idx].pregnancy_children[child_idx].child_entities[ce_idx].
       entity_text = request->pregnancies[preg_idx].pregnancy_children[child_idx].child_entities[
       ce_idx].entity_text
     ENDFOR
   ENDFOR
 ENDFOR
 CALL addinactiveproblems(null)
 FOR (preg_idx = 1 TO preg_cnt)
   IF ((request->pregnancies[preg_idx].ensure_type=del_preg))
    CALL deletepreginstance(preg_idx)
    CALL addpreginstance(del_preg,preg_idx,true)
    CALL findlastdeliverydatetime(preg_idx,delivery_dttm,delivery_dt_precision,delivery_dt_qualifier)
    CALL findlifecycledtcd(delivery_dt_qualifier,life_cycle_dt_cd)
    SET problem_lifecycle_cd = canceled_lifecycle_cd
    CALL updateproblem(request->pregnancies[preg_idx].problem_id,request->pregnancies[preg_idx].
     org_id,delivery_dttm,problem_lifecycle_cd,delivery_dt_precision,
     life_cycle_dt_cd)
   ELSEIF ((request->pregnancies[preg_idx].ensure_type=upt_preg))
    CALL findlastdeliverydatetime(preg_idx,delivery_dttm,delivery_dt_precision,delivery_dt_qualifier)
    CALL findlifecycledtcd(delivery_dt_qualifier,life_cycle_dt_cd)
    SET problem_lifecycle_cd = 0
    SET onset_dttm = null
    IF ((request->pregnancies[preg_idx].pregnancy_children[1].gestation_age > 0)
     AND (request->pregnancies[preg_idx].pregnancy_children[1].delivery_dt_tm != null))
     SET onset_dttm = cnvtdatetime(datetimeadd(cnvtdatetime(request->pregnancies[preg_idx].
        pregnancy_children[1].delivery_dt_tm),(0 - request->pregnancies[preg_idx].pregnancy_children[
       1].gestation_age)))
    ENDIF
    CALL updateproblemwithonset(request->pregnancies[preg_idx].problem_id,request->pregnancies[
     preg_idx].org_id,delivery_dttm,problem_lifecycle_cd,delivery_dt_precision,
     life_cycle_dt_cd,onset_dttm)
    CALL updatepreginstance(preg_idx)
   ELSEIF ((request->pregnancies[preg_idx].ensure_type=cls_preg))
    CALL echo("Closing a pregnancy")
    CALL closepreginstance(preg_idx)
   ELSEIF ((request->pregnancies[preg_idx].ensure_type=add_preg)
    AND (request->pregnancies[preg_idx].pregnancy_instance_id=0))
    CALL addpreginstance(add_preg,preg_idx,true)
   ENDIF
   CALL deletepregentities(preg_idx)
   CALL addpregentities(preg_idx)
   CALL addpregactions(preg_idx)
   CALL deletepregchildren(preg_idx)
   CALL addpregchildren(preg_idx)
   SET child_cnt = size(request->pregnancies[preg_idx].pregnancy_children,5)
   FOR (child_idx = 1 TO child_cnt)
    CALL deletepregchildentities(preg_idx,child_idx)
    CALL addpregchildentities(preg_idx,child_idx)
   ENDFOR
 ENDFOR
 SET reply->status_data.status = "S"
 SUBROUTINE (addpreginstance(preg_action=i2,preg_id=i4,hist_ind=i2) =null)
   DECLARE active_ind = i2 WITH protect, noconstant(1)
   IF (preg_action=add_preg)
    CALL getnewid(null)
    SET reply->pregnancies[preg_id].pregnancy_instance_id = new_id
    SET reply->pregnancies[preg_id].pregnancy_id = reply->pregnancies[preg_id].pregnancy_instance_id
   ELSEIF (preg_action=del_preg)
    CALL getnewid(null)
    SET reply->pregnancies[preg_id].pregnancy_instance_id = new_id
    SET active_ind = 0
   ENDIF
   IF (encntr_id_column_exists=1
    AND validate(request->pregnancies[preg_id].encntr_id,0) > 1)
    INSERT  FROM pregnancy_instance pi
     SET pi.pregnancy_instance_id = reply->pregnancies[preg_id].pregnancy_instance_id, pi
      .pregnancy_id = reply->pregnancies[preg_id].pregnancy_id, pi.person_id = request->person_id,
      pi.organization_id = reply->pregnancies[preg_id].org_id, pi.problem_id = reply->pregnancies[
      preg_id].problem_id, pi.active_ind = active_ind,
      pi.sensitive_ind = request->pregnancies[preg_id].sensitive_ind, pi.preg_start_dt_tm =
      cnvtdatetime(request->pregnancies[preg_id].preg_start_dt_tm), pi.preg_end_dt_tm = cnvtdatetime(
       request->pregnancies[preg_id].preg_end_dt_tm),
      pi.override_comment = request->pregnancies[preg_id].override_comment, pi.confirmed_dt_tm =
      cnvtdatetime(request->pregnancies[preg_id].confirmation_dt_tm), pi.beg_effective_dt_tm =
      cnvtdatetime(phx_now),
      pi.end_effective_dt_tm = cnvtdatetime(end_time), pi.historical_ind = hist_ind, pi.updt_dt_tm =
      cnvtdatetime(phx_now),
      pi.updt_id = reqinfo->updt_id, pi.updt_task = reqinfo->updt_task, pi.updt_applctx = reqinfo->
      updt_applctx,
      pi.encntr_id = request->pregnancies[preg_id].encntr_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.subeventstatus.operationname = "ADDPREGINSTANCE_WITH_ENCOUNTER"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     GO TO exit_script
    ENDIF
   ELSE
    INSERT  FROM pregnancy_instance pi
     SET pi.pregnancy_instance_id = reply->pregnancies[preg_id].pregnancy_instance_id, pi
      .pregnancy_id = reply->pregnancies[preg_id].pregnancy_id, pi.person_id = request->person_id,
      pi.organization_id = reply->pregnancies[preg_id].org_id, pi.problem_id = reply->pregnancies[
      preg_id].problem_id, pi.active_ind = active_ind,
      pi.sensitive_ind = request->pregnancies[preg_id].sensitive_ind, pi.preg_start_dt_tm =
      cnvtdatetime(request->pregnancies[preg_id].preg_start_dt_tm), pi.preg_end_dt_tm = cnvtdatetime(
       request->pregnancies[preg_id].preg_end_dt_tm),
      pi.override_comment = request->pregnancies[preg_id].override_comment, pi.confirmed_dt_tm =
      cnvtdatetime(request->pregnancies[preg_id].confirmation_dt_tm), pi.beg_effective_dt_tm =
      cnvtdatetime(phx_now),
      pi.end_effective_dt_tm = cnvtdatetime(end_time), pi.historical_ind = hist_ind, pi.updt_dt_tm =
      cnvtdatetime(phx_now),
      pi.updt_id = reqinfo->updt_id, pi.updt_task = reqinfo->updt_task, pi.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.subeventstatus.operationname = "ADDPREGINSTANCE"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (updatepreginstance(preg_id=i4) =null)
   CALL getnewid(null)
   SET reply->pregnancies[preg_id].pregnancy_instance_id = new_id
   SET reply->pregnancies[preg_id].pregnancy_id = request->pregnancies[preg_id].pregnancy_id
   CALL deletepreginstance(preg_id)
   FREE RECORD children
   RECORD children(
     1 list[*]
       2 pregnancy_child_id = f8
   )
   SET child_cnt = 0
   SELECT INTO "nl:"
    pregnancy_child_id
    FROM pregnancy_child pc
    WHERE (pc.pregnancy_instance_id=request->pregnancies[preg_id].pregnancy_instance_id)
     AND pc.active_ind=1
    HEAD REPORT
     child_cnt = 0
    DETAIL
     child_cnt += 1
     IF (mod(child_cnt,5)=1)
      stat = alterlist(children->list,(child_cnt+ 4))
     ENDIF
     children->list[child_cnt].pregnancy_child_id = pc.pregnancy_child_id
    FOOT REPORT
     stat = alterlist(children->list,child_cnt)
    WITH nocounter
   ;end select
   IF (child_cnt > 0)
    UPDATE  FROM pregnancy_child pc,
      (dummyt d  WITH seq = value(child_cnt))
     SET pc.active_ind = 0, pc.updt_cnt = (pc.updt_cnt+ 1), pc.updt_dt_tm = cnvtdatetime(phx_now),
      pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->
      updt_applctx,
      pc.end_effective_dt_tm = cnvtdatetime(phx_now)
     PLAN (d)
      JOIN (pc
      WHERE (pc.pregnancy_child_id=children->list[d.seq].pregnancy_child_id))
     WITH nocounter
    ;end update
    UPDATE  FROM pregnancy_child_entity_r pce,
      (dummyt d  WITH seq = value(child_cnt))
     SET pce.active_ind = 0, pce.updt_cnt = (pce.updt_cnt+ 1), pce.updt_dt_tm = cnvtdatetime(phx_now),
      pce.updt_id = reqinfo->updt_id, pce.updt_task = reqinfo->updt_task, pce.updt_applctx = reqinfo
      ->updt_applctx,
      pce.end_effective_dt_tm = cnvtdatetime(phx_now)
     PLAN (d)
      JOIN (pce
      WHERE (pce.pregnancy_child_id=children->list[d.seq].pregnancy_child_id))
     WITH nocounter
    ;end update
   ENDIF
   UPDATE  FROM pregnancy_entity_r per
    SET per.active_ind = 0, per.updt_cnt = (per.updt_cnt+ 1), per.updt_dt_tm = cnvtdatetime(phx_now),
     per.updt_id = reqinfo->updt_id, per.updt_task = reqinfo->updt_task, per.updt_applctx = reqinfo->
     updt_applctx,
     per.end_effective_dt_tm = cnvtdatetime(phx_now)
    WHERE (per.pregnancy_id=request->pregnancies[preg_id].pregnancy_id)
    WITH nocounter
   ;end update
   FREE RECORD children
   DECLARE hist_ind = i2 WITH noconstant(true)
   SELECT INTO "nl:"
    FROM pregnancy_instance pi
    WHERE (pi.pregnancy_instance_id=request->pregnancies[preg_id].pregnancy_instance_id)
    DETAIL
     hist_ind = pi.historical_ind
    WITH nocounter
   ;end select
   CALL addpreginstance(upt_preg,preg_id,hist_ind)
 END ;Subroutine
 SUBROUTINE (deletepreginstance(preg_id=i4) =null)
  UPDATE  FROM pregnancy_instance pi
   SET pi.active_ind = 0, pi.end_effective_dt_tm = cnvtdatetime(phx_now), pi.updt_cnt = (pi.updt_cnt
    + 1),
    pi.updt_dt_tm = cnvtdatetime(phx_now), pi.updt_id = reqinfo->updt_id, pi.updt_task = reqinfo->
    updt_task,
    pi.updt_applctx = reqinfo->updt_applctx
   WHERE (pi.pregnancy_instance_id=request->pregnancies[preg_id].pregnancy_instance_id)
    AND (pi.pregnancy_id=request->pregnancies[preg_id].pregnancy_id)
    AND (pi.person_id=request->person_id)
    AND pi.active_ind=1
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus.operationname = "DELPREGINSTANCE"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE (deletepregentities(preg_id=i4) =null)
   SET entity_cnt = size(request->pregnancies[preg_id].pregnancy_entities,5)
   SET del_cnt = 0
   FOR (i = 1 TO entity_cnt)
     IF ((request->pregnancies[preg_id].pregnancy_entities[i].delete_flag=1))
      SET del_cnt += 1
     ENDIF
   ENDFOR
   IF (del_cnt > 0)
    UPDATE  FROM pregnancy_entity_r per
     SET per.active_ind = 0, per.end_effective_dt_tm = cnvtdatetime(phx_now), per.updt_dt_tm =
      cnvtdatetime(phx_now),
      per.updt_id = reqinfo->updt_id, per.updt_task = reqinfo->updt_task, per.updt_applctx = reqinfo
      ->updt_applctx
     WHERE expand(num,1,entity_cnt,1,request->pregnancies[preg_id].pregnancy_entities[num].
      delete_flag,
      per.pregnancy_entity_id,request->pregnancies[preg_id].pregnancy_entities[num].parent_entity_id)
      AND per.active_ind=1
    ;end update
    IF (curqual != del_cnt)
     SET reply->status_data.subeventstatus.operationname = "DELPREGENTITIES"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addpregentities(preg_id=i4) =null)
   SET entity_cnt = size(request->pregnancies[preg_id].pregnancy_entities,5)
   SET add_cnt = 0
   FOR (i = 1 TO entity_cnt)
     IF ((request->pregnancies[preg_id].pregnancy_entities[i].delete_flag=0))
      CALL getnewid(null)
      SET reply->pregnancies[preg_id].pregnancy_entities[i].pregnancy_entity_id = new_id
      SET add_cnt += 1
     ENDIF
   ENDFOR
   IF (add_cnt > 0)
    INSERT  FROM pregnancy_entity_r per,
      (dummyt d  WITH seq = value(entity_cnt))
     SET per.active_ind = 1, per.pregnancy_entity_id = reply->pregnancies[preg_id].
      pregnancy_entities[d.seq].pregnancy_entity_id, per.pregnancy_instance_id = reply->pregnancies[
      preg_id].pregnancy_instance_id,
      per.pregnancy_id = reply->pregnancies[preg_id].pregnancy_id, per.parent_entity_id = reply->
      pregnancies[preg_id].pregnancy_entities[d.seq].parent_entity_id, per.parent_entity_name =
      request->pregnancies[preg_id].pregnancy_entities[d.seq].parent_entity_name,
      per.component_type_cd = request->pregnancies[preg_id].pregnancy_entities[d.seq].
      component_type_cd, per.beg_effective_dt_tm = cnvtdatetime(phx_now), per.end_effective_dt_tm =
      cnvtdatetime(end_time),
      per.updt_dt_tm = cnvtdatetime(phx_now), per.updt_dt_tm = cnvtdatetime(phx_now), per.updt_id =
      reqinfo->updt_id,
      per.updt_task = reqinfo->updt_task, per.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE (request->pregnancies[preg_id].pregnancy_entities[d.seq].delete_flag=0))
      JOIN (per)
     WITH nocounter
    ;end insert
    IF (curqual != add_cnt)
     SET reply->status_data.subeventstatus.operationname = "ADDPREGENTITIES"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addpregactions(preg_id=i4) =null)
   SET action_cnt = size(request->pregnancies[preg_id].pregnancy_actions,5)
   FOR (i = 1 TO action_cnt)
     CALL getnewid(null)
     SET reply->pregnancies[preg_id].pregnancy_actions[i].pregnancy_action_id = new_id
     SET reply->pregnancies[preg_id].pregnancy_actions[i].action_dt_tm = phx_now
   ENDFOR
   IF (action_cnt > 0)
    INSERT  FROM pregnancy_action pa,
      (dummyt d  WITH seq = value(action_cnt))
     SET pa.pregnancy_id = reply->pregnancies[preg_id].pregnancy_id, pa.pregnancy_instance_id = reply
      ->pregnancies[preg_id].pregnancy_instance_id, pa.pregnancy_action_id = reply->pregnancies[
      preg_id].pregnancy_actions[d.seq].pregnancy_action_id,
      pa.action_dt_tm = cnvtdatetime(reply->pregnancies[preg_id].pregnancy_actions[d.seq].
       action_dt_tm), pa.action_tz = request->pregnancies[preg_id].pregnancy_actions[d.seq].action_tz,
      pa.action_type_cd = request->pregnancies[preg_id].pregnancy_actions[d.seq].action_type_cd,
      pa.prsnl_id = request->pregnancies[preg_id].pregnancy_actions[d.seq].prsnl_id, pa.updt_dt_tm =
      cnvtdatetime(phx_now), pa.updt_id = reqinfo->updt_id,
      pa.updt_task = reqinfo->updt_task, pa.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (pa)
     WITH nocounter
    ;end insert
    IF (curqual != action_cnt)
     SET reply->status_data.subeventstatus.operationname = "ADDPREGACTIONS"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addpregchildren(preg_id=i4) =null)
   SET child_cnt = size(request->pregnancies[preg_id].pregnancy_children,5)
   SET add_cnt = 0
   FOR (i = 1 TO child_cnt)
     IF ((request->pregnancies[preg_id].pregnancy_children[i].delete_flag=0)
      AND (request->pregnancies[preg_id].pregnancy_children[i].pregnancy_child_id=0))
      CALL getnewid(null)
      SET reply->pregnancies[preg_id].pregnancy_children[i].pregnancy_child_id = new_id
      SET var1 = request->pregnancies[preg_id].pregnancy_children[i].child_comment
      SET var2 = childtable
      CALL ensurenewlongtext(var1,var2,new_id)
      SET reply->pregnancies[preg_id].pregnancy_children[i].child_comment_id = new_long_text_id
      SET add_cnt += 1
     ENDIF
   ENDFOR
   IF (add_cnt > 0)
    INSERT  FROM pregnancy_child pc,
      (dummyt d  WITH seq = value(child_cnt))
     SET pc.active_ind = 1, pc.pregnancy_child_id = reply->pregnancies[preg_id].pregnancy_children[d
      .seq].pregnancy_child_id, pc.pregnancy_instance_id = reply->pregnancies[preg_id].
      pregnancy_instance_id,
      pc.pregnancy_id = reply->pregnancies[preg_id].pregnancy_id, pc.gender_cd = request->
      pregnancies[preg_id].pregnancy_children[d.seq].gender_cd, pc.child_name = request->pregnancies[
      preg_id].pregnancy_children[d.seq].child_name,
      pc.person_id = request->pregnancies[preg_id].pregnancy_children[d.seq].person_id, pc
      .father_name = request->pregnancies[preg_id].pregnancy_children[d.seq].father_name, pc
      .delivery_method_cd = request->pregnancies[preg_id].pregnancy_children[d.seq].
      delivery_method_cd,
      pc.delivery_hospital = request->pregnancies[preg_id].pregnancy_children[d.seq].
      delivery_hospital, pc.gestation_age = request->pregnancies[preg_id].pregnancy_children[d.seq].
      gestation_age, pc.gestation_term_txt = validate(request->pregnancies[preg_id].
       pregnancy_children[d.seq].gestation_term_txt,""),
      pc.labor_duration = request->pregnancies[preg_id].pregnancy_children[d.seq].labor_duration, pc
      .weight_amt = request->pregnancies[preg_id].pregnancy_children[d.seq].weight_amt, pc
      .weight_unit_cd = request->pregnancies[preg_id].pregnancy_children[d.seq].weight_unit_cd,
      pc.anesthesia_txt = request->pregnancies[preg_id].pregnancy_children[d.seq].anesthesia_txt, pc
      .preterm_labor_txt = request->pregnancies[preg_id].pregnancy_children[d.seq].preterm_labor_txt,
      pc.delivery_dt_tm = cnvtdatetime(request->pregnancies[preg_id].pregnancy_children[d.seq].
       delivery_dt_tm),
      pc.delivery_tz = request->pregnancies[preg_id].pregnancy_children[d.seq].delivery_tz, pc
      .delivery_date_precision_flag = request->pregnancies[preg_id].pregnancy_children[d.seq].
      delivery_date_precision_flag, pc.delivery_date_qualifier_flag = request->pregnancies[preg_id].
      pregnancy_children[d.seq].delivery_date_qualifier_flag,
      pc.neonate_outcome_cd = request->pregnancies[preg_id].pregnancy_children[d.seq].
      neonate_outcome_cd, pc.child_comment_id = reply->pregnancies[preg_id].pregnancy_children[d.seq]
      .child_comment_id, pc.restrict_person_id_ind = reply->pregnancies[preg_id].pregnancy_children[d
      .seq].restrict_person_id_ind,
      pc.beg_effective_dt_tm = cnvtdatetime(phx_now), pc.end_effective_dt_tm = cnvtdatetime(end_time),
      pc.updt_dt_tm = cnvtdatetime(phx_now),
      pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->
      updt_applctx
     PLAN (d
      WHERE (request->pregnancies[preg_id].pregnancy_children[d.seq].delete_flag=0)
       AND (request->pregnancies[preg_id].pregnancy_children[d.seq].pregnancy_child_id=0))
      JOIN (pc)
     WITH nocounter
    ;end insert
    IF (curqual != add_cnt)
     SET reply->status_data.subeventstatus.operationname = "ADDPREGCHILDREN"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (deletepregchildren(preg_id=i4) =null)
   SET child_cnt = size(request->pregnancies[preg_id].pregnancy_children,5)
   SET del_cnt = 0
   FOR (i = 1 TO child_cnt)
     IF ((request->pregnancies[preg_id].pregnancy_children[i].delete_flag=1))
      SET del_cnt += 1
     ENDIF
   ENDFOR
   IF (del_cnt > 0)
    UPDATE  FROM pregnancy_child pc,
      (dummyt d  WITH seq = value(child_cnt))
     SET pc.active_ind = 0, pc.end_effective_dt_tm = cnvtdatetime(phx_now), pc.updt_dt_tm =
      cnvtdatetime(phx_now),
      pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->
      updt_applctx
     WHERE expand(num,1,child_cnt,1,request->pregnancies[preg_id].pregnancy_children[num].delete_flag,
      pc.pregnancy_child_id,request->pregnancies[preg_id].pregnancy_children[d.seq].
      pregnancy_child_id)
      AND pc.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual != del_cnt)
     SET reply->status_data.subeventstatus.operationname = "DELPREGCHILDREN"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addpregchildentities(preg_id=i4,child_id=i4) =null)
   SET ce_cnt = size(request->pregnancies[preg_id].pregnancy_children[child_id].child_entities,5)
   SET add_cnt = 0
   FOR (i = 1 TO ce_cnt)
     IF ((request->pregnancies[preg_id].pregnancy_children[child_id].child_entities[i].delete_flag=0)
      AND (request->pregnancies[preg_id].pregnancy_children[child_id].child_entities[i].
     pregnancy_child_entity_id=0))
      CALL getnewid(null)
      SET reply->pregnancies[preg_id].pregnancy_children[child_id].child_entities[i].
      pregnancy_child_entity_id = new_id
      IF ((request->pregnancies[preg_id].pregnancy_children[child_id].child_entities[i].
      parent_entity_name=longtexttable))
       SET var1 = request->pregnancies[preg_id].pregnancy_children[child_id].child_entities[i].
       entity_text
       SET var2 = childentitytable
       CALL ensurenewlongtext(var1,var2,new_id)
       SET reply->pregnancies[preg_id].pregnancy_children[child_id].child_entities[i].
       parent_entity_id = new_long_text_id
      ENDIF
      CALL echo(build("AddPregChildEntities for entity #",i))
      CALL echo(build("component_type_cd = ",request->pregnancies[preg_id].pregnancy_children[
        child_id].child_entities[i].component_type_cd))
      INSERT  FROM pregnancy_child_entity_r pce
       SET pce.active_ind = 1, pce.pregnancy_child_entity_id = reply->pregnancies[preg_id].
        pregnancy_children[child_id].child_entities[i].pregnancy_child_entity_id, pce
        .pregnancy_child_id = reply->pregnancies[preg_id].pregnancy_children[child_id].
        pregnancy_child_id,
        pce.parent_entity_name = request->pregnancies[preg_id].pregnancy_children[child_id].
        child_entities[i].parent_entity_name, pce.parent_entity_id = reply->pregnancies[preg_id].
        pregnancy_children[child_id].child_entities[i].parent_entity_id, pce.component_type_cd =
        request->pregnancies[preg_id].pregnancy_children[child_id].child_entities[i].
        component_type_cd,
        pce.updt_dt_tm = cnvtdatetime(phx_now), pce.beg_effective_dt_tm = cnvtdatetime(phx_now), pce
        .end_effective_dt_tm = cnvtdatetime(end_time),
        pce.updt_id = reqinfo->updt_id, pce.updt_task = reqinfo->updt_task, pce.updt_applctx =
        reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual != 1)
       SET reply->status_data.subeventstatus.operationname = "ADDPREGCHILDENTITIES"
       SET reply->status_data.subeventstatus.operationstatus = "F"
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (deletepregchildentities(preg_id=i4,child_id=i4) =null)
   SET ce_cnt = size(request->pregnancies[preg_id].pregnancy_children[child_id].child_entities,5)
   SET del_cnt = 0
   FOR (i = 1 TO ce_cnt)
     IF ((request->pregnancies[preg_id].pregnancy_children[child_id].child_entities[i].delete_flag=1)
      AND (request->pregnancies[preg_id].pregnancy_children[child_id].child_entities[i].
     pregnancy_child_entity_id > 0))
      SET del_cnt += 1
     ENDIF
   ENDFOR
   IF (del_cnt > 0)
    UPDATE  FROM pregnancy_child_entity_r pce,
      (dummyt d  WITH seq = value(ce_cnt))
     SET pce.active_ind = 0, pce.end_effective_dt_tm = cnvtdatetime(phx_now), pce.updt_dt_tm =
      cnvtdatetime(phx_now),
      pce.updt_id = reqinfo->updt_id, pce.updt_task = reqinfo->updt_task, pce.updt_applctx = reqinfo
      ->updt_applctx
     PLAN (d
      WHERE (request->pregnancies[preg_id].pregnancy_children[child_id].child_entities[d.seq].
      delete_flag=1)
       AND (request->pregnancies[preg_id].pregnancy_children[child_id].child_entities[d.seq].
      pregnancy_child_entity_id > 0)
       AND (pce.pregnancy_child_entity_id=request->pregnancies[preg_id].pregnancy_children[child_id].
      child_entities[d.seq].pregnancy_child_entity_id))
      JOIN (pce)
     WITH nocounter
    ;end update
    IF (curqual != del_cnt)
     SET reply->status_data.subeventstatus.operationname = "DELPREGCHILDENTITIES"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getnewid(null)
  SELECT INTO "nl:"
   val = seq(pregnancy_seq,nextval)
   FROM dual
   DETAIL
    new_id = cnvtreal(val)
   WITH nocounter
  ;end select
  IF (((curqual=0) OR (new_id=0)) )
   SET reply->status_data.subeventstatus.operationname = "QUERY"
   SET reply->status_data.subeventstatus.targetobjectname = "PREGNANCY_SEQ"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE findnomenclatureid(null)
  SELECT INTO "nl:"
   FROM nomenclature n
   WHERE n.source_vocabulary_cd=source_vocabulary_cd
    AND n.source_identifier=source_identifier
    AND n.principle_type_cd >= 0
    AND n.nomenclature_id >= 0
    AND n.primary_cterm_ind=1
    AND n.active_ind=1
   DETAIL
    nomenclature_id = n.nomenclature_id, annotated_display = n.source_string
   WITH nocounter
  ;end select
  IF (nomenclature_id <= 0)
   CALL fillsubeventstatus("dcp_ens_phx","F","FindNomenclature",
    "failed - nomenclature could not be found")
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE addinactiveproblems(null)
   IF ((request->problem_id > 0.0))
    RETURN
   ENDIF
   CALL findnomenclatureid(null)
   SET problem_cnt = 0
   FOR (i = 1 TO preg_cnt)
     IF ((request->pregnancies[i].ensure_type=add_preg)
      AND (request->pregnancies[i].pregnancy_instance_id=0.0))
      SET child_cnt = size(request->pregnancies[i].pregnancy_children,5)
      IF (child_cnt < 1)
       SET reply->status_data.subeventstatus.operationname = "VERIFYPREGINPUT"
       GO TO exit_script
      ENDIF
      SET problem_cnt += 1
      IF (mod(problem_cnt,5)=1)
       SET stat = alterlist(probrequest->problem,(problem_cnt+ 4))
      ENDIF
      SET stat = alterlist(probrequest->problem[problem_cnt].problem_prsnl,1)
      SET probrequest->problem[problem_cnt].problem_prsnl[1].problem_prsnl_id = request->prsnl_id
      SET probrequest->problem[problem_cnt].organization_id = request->pregnancies[i].org_id
      SET probrequest->problem[problem_cnt].problem_action_ind = 4
      SET probrequest->problem[problem_cnt].nomenclature_id = nomenclature_id
      IF ((request->pregnancies[i].pregnancy_children[1].gestation_age > 0))
       SET probrequest->problem[problem_cnt].onset_dt_tm = cnvtdatetime(datetimeadd(cnvtdatetime(
          request->pregnancies[i].pregnancy_children[1].delivery_dt_tm),(0 - request->pregnancies[i].
         pregnancy_children[1].gestation_age)))
      ENDIF
      SET probrequest->problem[problem_cnt].life_cycle_status_cd = resolved_lifecycle_cd
      SET probrequest->problem[problem_cnt].confirmation_status_cd = problem_confirmation_cd
      SET probrequest->problem[problem_cnt].problem_type_flag = 2
      CALL findlastdeliverydatetime(i,delivery_dttm,delivery_dt_precision,delivery_dt_qualifier)
      CALL findlifecycledtcd(delivery_dt_qualifier,life_cycle_dt_cd)
      SET probrequest->problem[problem_cnt].life_cycle_dt_tm = delivery_dttm
      SET probrequest->problem[problem_cnt].life_cycle_dt_flag = delivery_dt_precision
      SET probrequest->problem[problem_cnt].life_cycle_dt_cd = life_cycle_dt_cd
      SET probrequest->problem[problem_cnt].classification_cd = classification_cd
      SET probrequest->problem[problem_cnt].annotated_display = annotated_display
     ENDIF
   ENDFOR
   SET stat = alterlist(probrequest->problem,problem_cnt)
   SET probrequest->person_id = request->person_id
   SET probrequest->skip_fsi_trigger = 1
   IF (problem_cnt=0)
    RETURN
   ENDIF
   SET modify = nopredeclare
   EXECUTE kia_ens_problem  WITH replace("REQUEST",probrequest), replace("REPLY",problem_reply)
   SET modify = predeclare
   IF ((problem_reply->status_data.status != "S"))
    GO TO exit_script
   ENDIF
   SET problem_cnt = 0
   FOR (i = 1 TO preg_cnt)
     IF ((request->pregnancies[i].ensure_type=add_preg)
      AND (request->pregnancies[i].pregnancy_instance_id=0.0))
      SET problem_cnt += 1
      SET reply->pregnancies[i].problem_id = problem_reply->problem_list[problem_cnt].problem_id
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (ensurenewlongtext(text=vc(ref),parent_name=vc(ref),parent_id=f8) =null)
   IF (text=emptytext)
    SET new_long_text_id = 0
   ELSE
    SELECT INTO "nl:"
     val = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      new_long_text_id = cnvtreal(val)
     WITH nocounter
    ;end select
    INSERT  FROM long_text lt
     SET lt.active_ind = 1, lt.active_status_cd = active_code, lt.active_status_dt_tm = cnvtdatetime(
       phx_now),
      lt.long_text = text, lt.long_text_id = new_long_text_id, lt.parent_entity_name = parent_name,
      lt.parent_entity_id = parent_id, lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->
      updt_task,
      lt.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.subeventstatus.operationname = "INSERT"
     SET reply->status_data.subeventstatus.targetobjectname = "LONG_TEXT"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (updateproblem(problem_id=f8,org_id=f8,life_cycle_dttm=dq8(ref),life_cycle_cd=f8,
  life_cycle_dt_flag=i2,life_cycle_dt_cd=f8) =null)
   DECLARE problem_instance_id = f8 WITH public, noconstant(0.0)
   DECLARE confirmation_status_cd = f8 WITH public, noconstant(0.0)
   DECLARE lifecycle_cd = f8 WITH protected, noconstant(0.0)
   DECLARE problem_type_flag = i2 WITH protected, noconstant(0)
   DECLARE onset_dt_tm = dq8 WITH protected
   DECLARE problem_nomenclature_id = f8 WITH protect, noconstant(0.0)
   IF (problem_id <= 0)
    SET reply->status_data.subeventstatus.operationname = "UPDATEPROBLEM"
    SET reply->status_data.subeventstatus.operationstatus = "F"
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM problem p
    WHERE (p.person_id=request->person_id)
     AND p.problem_id=problem_id
     AND ((p.active_ind+ 0)=1)
    DETAIL
     problem_instance_id = p.problem_instance_id, confirmation_status_cd = p.confirmation_status_cd,
     onset_dt_tm = p.onset_dt_tm,
     problem_lifecycle_cd = p.life_cycle_status_cd, classification_cd = p.classification_cd,
     problem_nomenclature_id = p.nomenclature_id,
     annotated_display = p.annotated_display
    WITH nocounter
   ;end select
   IF (life_cycle_cd > 0)
    SET problem_lifecycle_cd = life_cycle_cd
   ENDIF
   SET stat = alterlist(probrequest->problem,1)
   SET stat = alterlist(probrequest->problem[1].problem_prsnl,1)
   SET probrequest->problem[1].problem_prsnl[1].problem_prsnl_id = request->prsnl_id
   SET probrequest->problem[1].problem_id = problem_id
   SET probrequest->problem[1].organization_id = org_id
   SET probrequest->problem[1].problem_instance_id = problem_instance_id
   SET probrequest->problem[1].nomenclature_id = problem_nomenclature_id
   SET probrequest->problem[1].problem_action_ind = 2
   SET probrequest->problem[1].life_cycle_status_cd = problem_lifecycle_cd
   SET probrequest->problem[1].life_cycle_dt_flag = life_cycle_dt_flag
   SET probrequest->problem[1].life_cycle_dt_cd = life_cycle_dt_cd
   SET probrequest->problem[1].life_cycle_dt_tm = cnvtdatetime(life_cycle_dttm)
   SET probrequest->problem[1].onset_dt_tm = onset_dt_tm
   SET probrequest->problem[1].confirmation_status_cd = confirmation_status_cd
   SET probrequest->person_id = request->person_id
   SET probrequest->problem[1].classification_cd = classification_cd
   SET probrequest->problem[1].problem_type_flag = 2
   SET probrequest->problem[1].annotated_display = annotated_display
   SET probrequest->skip_fsi_trigger = 1
   SET modify = nopredeclare
   EXECUTE kia_ens_problem  WITH replace("REQUEST",probrequest), replace("REPLY",problem_reply)
   SET modify = predeclare
   IF ((problem_reply->status_data.status != "S"))
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (updateproblemwithonset(problem_id=f8,org_id=f8,life_cycle_dttm=dq8(ref),life_cycle_cd=f8,
  life_cycle_dt_flag=i2,life_cycle_dt_cd=f8,onset_dttm=dq8) =null)
   IF (problem_id <= 0)
    SET reply->status_data.subeventstatus.operationname = "UPDATEPROBLEM"
    SET reply->status_data.subeventstatus.operationstatus = "F"
    GO TO exit_script
   ENDIF
   SET stat = alterlist(probrequest->problem,1)
   SET stat = alterlist(probrequest->problem[1].problem_prsnl,1)
   SELECT INTO "nl:"
    FROM problem p
    WHERE (p.person_id=request->person_id)
     AND p.problem_id=problem_id
     AND ((p.active_ind+ 0)=1)
    DETAIL
     probrequest->problem[1].problem_instance_id = p.problem_instance_id, probrequest->problem[1].
     nomenclature_id = p.nomenclature_id, probrequest->problem[1].life_cycle_status_cd = p
     .life_cycle_status_cd,
     probrequest->problem[1].confirmation_status_cd = p.confirmation_status_cd, probrequest->problem[
     1].classification_cd = p.classification_cd, probrequest->problem[1].annotated_display = p
     .annotated_display
    WITH nocounter
   ;end select
   IF (life_cycle_cd > 0)
    SET probrequest->problem[1].life_cycle_status_cd = life_cycle_cd
   ENDIF
   SET probrequest->problem[1].problem_prsnl[1].problem_prsnl_id = request->prsnl_id
   SET probrequest->problem[1].problem_id = problem_id
   SET probrequest->problem[1].organization_id = org_id
   SET probrequest->problem[1].problem_action_ind = 2
   SET probrequest->problem[1].life_cycle_dt_flag = life_cycle_dt_flag
   SET probrequest->problem[1].life_cycle_dt_cd = life_cycle_dt_cd
   SET probrequest->problem[1].life_cycle_dt_tm = cnvtdatetime(life_cycle_dttm)
   SET probrequest->problem[1].onset_dt_tm = onset_dttm
   SET probrequest->person_id = request->person_id
   SET probrequest->problem[1].problem_type_flag = 2
   SET probrequest->skip_fsi_trigger = 1
   SET modify = nopredeclare
   EXECUTE kia_ens_problem  WITH replace("REQUEST",probrequest), replace("REPLY",problem_reply)
   SET modify = predeclare
   IF ((problem_reply->status_data.status != "S"))
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (closepreginstance(preg_index=i4) =null)
   CALL updatepreginstance(preg_index)
   CALL findlastdeliverydatetime(preg_index,delivery_dttm,delivery_dt_precision,delivery_dt_qualifier
    )
   CALL findlifecycledtcd(delivery_dt_qualifier,life_cycle_dt_cd)
   SET problem_lifecycle_cd = resolved_lifecycle_cd
   CALL updateproblem(request->pregnancies[preg_index].problem_id,request->pregnancies[preg_index].
    org_id,delivery_dttm,problem_lifecycle_cd,delivery_dt_precision,
    life_cycle_dt_cd)
 END ;Subroutine
 SUBROUTINE (findlastdeliverydatetime(preg_id=i4,last_delivery_dttm=dq8(ref),dt_precision=i2(ref),
  dt_qualifier=i2(ref)) =null)
   SET last_delivery_dttm = 0
   SET dt_precision = 0
   SET dt_qualifier = 0
   DECLARE temp_delivery_dttm = dq8 WITH private
   DECLARE children_cnt = i4 WITH private, noconstant(0)
   IF (((preg_id < 1) OR (preg_id > preg_cnt)) )
    RETURN
   ENDIF
   SET children_cnt = size(request->pregnancies[preg_id].pregnancy_children,5)
   IF (children_cnt < 1)
    RETURN
   ENDIF
   SET dt_precision = request->pregnancies[preg_id].pregnancy_children[1].
   delivery_date_precision_flag
   SET dt_qualifier = request->pregnancies[preg_id].pregnancy_children[1].
   delivery_date_qualifier_flag
   IF (dt_precision=3)
    SET last_delivery_dttm = request->pregnancies[preg_id].preg_end_dt_tm
   ELSE
    SET last_delivery_dttm = request->pregnancies[preg_id].pregnancy_children[1].delivery_dt_tm
   ENDIF
   FOR (i = 2 TO children_cnt)
    SET temp_delivery_dttm = request->pregnancies[preg_id].pregnancy_children[i].delivery_dt_tm
    IF (cnvtdatetime(last_delivery_dttm) < cnvtdatetime(temp_delivery_dttm))
     SET dt_precision = request->pregnancies[preg_id].pregnancy_children[i].
     delivery_date_precision_flag
     SET dt_qualifier = request->pregnancies[preg_id].pregnancy_children[i].
     delivery_date_qualifier_flag
     IF (dt_precision=3)
      SET last_delivery_dttm = request->pregnancies[preg_id].preg_end_dt_tm
     ELSE
      SET last_delivery_dttm = temp_delivery_dttm
     ENDIF
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (findlifecycledtcd(dt_qualifier=i2,dt_cd=f8(ref)) =null)
  SET dt_cd = life_cycle_dt_about
  IF (((dt_qualifier=0) OR (dt_qualifier=4)) )
   SET dt_cd = life_cycle_dt_unknown
  ELSEIF (dt_qualifier=1)
   SET dt_cd = life_cycle_dt_before
  ELSEIF (dt_qualifier=2)
   SET dt_cd = life_cycle_dt_about
  ELSEIF (dt_qualifier=3)
   SET dt_cd = life_cycle_dt_after
  ENDIF
 END ;Subroutine
#exit_script
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL reportfailure("ERROR","F","DCP_ENS_PHX",serrormsg)
 ENDIF
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
  EXECUTE srvrtl
  EXECUTE crmrtl
  DECLARE happ = i4 WITH private, noconstant(0)
  DECLARE htask = i4 WITH private, noconstant(0)
  DECLARE hreq = i4 WITH private, noconstant(0)
  DECLARE hrequest = i4 WITH protect, noconstant(0)
  DECLARE probcount = i4 WITH private, noconstant(0)
  DECLARE disciplinecount = i4 WITH private, noconstant(0)
  DECLARE personnelcount = i4 WITH private, noconstant(0)
  DECLARE commentcount = i4 WITH private, noconstant(0)
  DECLARE lcrmstatus = i4 WITH private, noconstant(0)
  SET stat = uar_crmbeginapp(4170101,happ)
  IF (stat != 0)
   RETURN
  ENDIF
  SET stat = uar_crmbegintask(happ,4170147,htask)
  IF (stat != 0)
   CALL uar_crmendapp(happ)
   RETURN
  ENDIF
  SET stat = uar_crmbeginreq(htask,"kia_prb_outbound_async",4170168,hreq)
  IF (stat != 0)
   CALL uar_crmendtask(htask)
   CALL uar_crmendapp(happ)
   RETURN
  ENDIF
  SET hrequest = uar_crmgetrequest(hreq)
  IF (hrequest)
   SET probcount = 0
   CALL echo("Test problem")
   CALL echo(kia_do_ob_add)
   CALL echorecord(kia_ob_add)
   IF (kia_do_ob_add=true)
    SET stat = uar_srvsetdouble(hrequest,"person_id",kia_ob_add->person_id)
    WHILE (probcount < size(kia_ob_add->problem,5))
      SET probcount += 1
      SET hproblemitem = uar_srvadditem(hrequest,"problem")
      IF (hproblemitem)
       SET stat = uar_srvsetshort(hproblemitem,"ob_action_ind",1)
       SET stat = uar_srvsetdouble(hproblemitem,"interface_action_cd",kia_ob_add->problem[probcount].
        interface_action_cd)
       SET stat = uar_srvsetdouble(hproblemitem,"problem_id",kia_ob_add->problem[probcount].
        problem_id)
       SET stat = uar_srvsetdouble(hproblemitem,"problem_instance_id",kia_ob_add->problem[probcount].
        problem_instance_id)
       SET stat = uar_srvsetstring(hproblemitem,"problem_uuid",kia_ob_add->problem[probcount].
        problem_uuid)
       SET stat = uar_srvsetstring(hproblemitem,"problem_instance_uuid",kia_ob_add->problem[probcount
        ].problem_instance_uuid)
       SET stat = uar_srvsetdouble(hproblemitem,"contributor_system_cd",kia_ob_add->problem[probcount
        ].contributor_system_cd)
       SET disciplinecount = 0
       WHILE (disciplinecount < size(kia_ob_add->problem[probcount].discipline,5))
         SET disciplinecount += 1
         SET hdisciplineitem = uar_srvadditem(hproblemitem,"discipline")
         IF (hdisciplineitem)
          SET stat = uar_srvsetdouble(hdisciplineitem,"interface_action_cd",kia_ob_add->problem[
           probcount].discipline[disciplinecount].interface_action_cd)
          SET stat = uar_srvsetdouble(hdisciplineitem,"problem_discipline_id",kia_ob_add->problem[
           probcount].discipline[disciplinecount].problem_discipline_id)
         ENDIF
       ENDWHILE
       SET personnelcount = 0
       WHILE (personnelcount < size(kia_ob_add->problem[probcount].prsnl,5))
         SET personnelcount += 1
         SET hprsnlitem = uar_srvadditem(hproblemitem,"prsnl")
         IF (hprsnlitem)
          SET stat = uar_srvsetdouble(hprsnlitem,"interface_action_cd",kia_ob_add->problem[probcount]
           .prsnl[personnelcount].interface_action_cd)
          SET stat = uar_srvsetdouble(hprsnlitem,"problem_prsnl_id",kia_ob_add->problem[probcount].
           prsnl[personnelcount].problem_prsnl_id)
         ENDIF
       ENDWHILE
       SET commentcount = 0
       WHILE (commentcount < size(kia_ob_add->problem[probcount].comment,5))
         SET commentcount += 1
         SET hcommentitem = uar_srvadditem(hproblemitem,"comment")
         IF (hcommentitem)
          SET stat = uar_srvsetdouble(hcommentitem,"problem_comment_id",kia_ob_add->problem[probcount
           ].comment[commentcount].problem_comment_id)
         ENDIF
       ENDWHILE
      ENDIF
    ENDWHILE
   ENDIF
   CALL echorecord(kia_ob_upd)
   SET probcount = 0
   IF (kia_do_ob_upd=true)
    SET stat = uar_srvsetdouble(hrequest,"person_id",kia_ob_upd->person_id)
    WHILE (probcount < size(kia_ob_upd->problem,5))
      SET probcount += 1
      SET hproblemitem = uar_srvadditem(hrequest,"problem")
      IF (hproblemitem)
       SET stat = uar_srvsetshort(hproblemitem,"ob_action_ind",2)
       SET stat = uar_srvsetdouble(hproblemitem,"interface_action_cd",kia_ob_upd->problem[probcount].
        interface_action_cd)
       SET stat = uar_srvsetdouble(hproblemitem,"problem_id",kia_ob_upd->problem[probcount].
        problem_id)
       SET stat = uar_srvsetdouble(hproblemitem,"problem_instance_id",kia_ob_upd->problem[probcount].
        problem_instance_id)
       SET stat = uar_srvsetdouble(hproblemitem,"contributor_system_cd",kia_ob_upd->problem[probcount
        ].contributor_system_cd)
       SET stat = uar_srvsetstring(hproblemitem,"problem_uuid",kia_ob_upd->problem[probcount].
        problem_uuid)
       SET stat = uar_srvsetstring(hproblemitem,"problem_instance_uuid",kia_ob_upd->problem[probcount
        ].problem_instance_uuid)
       SET disciplinecount = 0
       WHILE (disciplinecount < size(kia_ob_upd->problem[probcount].discipline,5))
         SET disciplinecount += 1
         SET hdisciplineitem = uar_srvadditem(hproblemitem,"discipline")
         IF (hdisciplineitem)
          SET stat = uar_srvsetdouble(hdisciplineitem,"interface_action_cd",kia_ob_upd->problem[
           probcount].discipline[disciplinecount].interface_action_cd)
          SET stat = uar_srvsetdouble(hdisciplineitem,"problem_discipline_id",kia_ob_upd->problem[
           probcount].discipline[disciplinecount].problem_discipline_id)
         ENDIF
       ENDWHILE
       SET personnelcount = 0
       WHILE (personnelcount < size(kia_ob_upd->problem[probcount].prsnl,5))
         SET personnelcount += 1
         SET hprsnlitem = uar_srvadditem(hproblemitem,"prsnl")
         IF (hprsnlitem)
          SET stat = uar_srvsetdouble(hprsnlitem,"interface_action_cd",kia_ob_upd->problem[probcount]
           .prsnl[personnelcount].interface_action_cd)
          SET stat = uar_srvsetdouble(hprsnlitem,"problem_prsnl_id",kia_ob_upd->problem[probcount].
           prsnl[personnelcount].problem_prsnl_id)
         ENDIF
       ENDWHILE
       SET commentcount = 0
       WHILE (commentcount < size(kia_ob_upd->problem[probcount].comment,5))
         SET commentcount += 1
         SET hcommentitem = uar_srvadditem(hproblemitem,"comment")
         IF (hcommentitem)
          SET stat = uar_srvsetdouble(hcommentitem,"problem_comment_id",kia_ob_upd->problem[probcount
           ].comment[commentcount].problem_comment_id)
         ENDIF
       ENDWHILE
      ENDIF
    ENDWHILE
   ENDIF
  ENDIF
  SET lcrmstatus = uar_crmperform(hreq)
  CALL uar_crmendreq(hreq)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE RECORD long_text_list
 FREE RECORD probrequest
 CALL echo("DCP_ENS_PHX Last Modified = 015 05/19/2021 by RR073994")
 SET modify = nopredeclare
END GO
