CREATE PROGRAM ams_auto_add_problem:dba
 PROMPT
  "person" = 0,
  "Problem Source String" = 0
  WITH person_id, source_string
 FREE RECORD request
 RECORD request(
   1 person_id = f8
   1 problem[*]
     2 problem_action_ind = i2
     2 problem_id = f8
     2 problem_instance_id = f8
     2 organization_id = f8
     2 nomenclature_id = f8
     2 annotated_display = vc
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 problem_ftdesc = vc
     2 classification_cd = f8
     2 confirmation_status_cd = f8
     2 qualifier_cd = f8
     2 life_cycle_status_cd = f8
     2 life_cycle_dt_tm = dq8
     2 persistence_cd = f8
     2 certainty_cd = f8
     2 ranking_cd = f8
     2 probability = f8
     2 onset_dt_flag = i2
     2 onset_dt_cd = f8
     2 onset_dt_tm = dq8
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
     2 problem_comment[*]
       3 problem_comment_id = f8
       3 comment_action_ind = i2
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
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
     2 related_problem_list[*]
       3 active_ind = i2
       3 child_entity_id = f8
       3 reltn_subtype_cd = f8
       3 priority = i4
       3 child_nomen_id = f8
       3 child_ftdesc = vc
     2 contributor_system_cd = f8
     2 problem_uuid = vc
     2 problem_instance_uuid = vc
     2 problem_type_flag = i4
     2 show_in_pm_history_ind = i2
     2 life_cycle_dt_cd = f8
     2 life_cycle_dt_flag = i2
     2 laterality_cd = f8
     2 originating_nomenclature_id = f8
     2 onset_tz = i4
   1 user_id = f8
 )
 DECLARE classification_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12033,"MEDICAL"))
 DECLARE confirmation_status_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12031,
   "CONFIRMED"))
 DECLARE life_cycle_status_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12030,"ACTIVE")
  )
 DECLARE problem_reltn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12038,"RECORDER"))
 DECLARE problem_nomenclature_id = f8 WITH protect
 DECLARE problem_annotated_display = vc WITH protect
 DECLARE problem_source_vocabulary_cd = f8 WITH protect
 DECLARE problem_source_identifier = vc WITH protect
 DECLARE problem_classification_cd = f8 WITH protect
 DECLARE problem_contributor_system_cd = f8 WITH protect
 SELECT INTO "nl:"
  FROM nomenclature n
  WHERE (n.source_string= $2)
   AND n.active_ind=1
  DETAIL
   problem_nomenclature_id = n.nomenclature_id, problem_annotated_display = n.source_string,
   problem_source_vocabulary_cd = n.source_vocabulary_cd,
   problem_source_identifier = n.source_identifier, problem_contributor_system_cd = n
   .contributor_system_cd
  WITH nocounter
 ;end select
 SET request->person_id = value( $1)
 SET stat = alterlist(request->problem,1)
 SET request->problem[1].problem_action_ind = 1
 SET request->problem[1].nomenclature_id = problem_nomenclature_id
 SET request->problem[1].annotated_display = problem_annotated_display
 SET request->problem[1].source_vocabulary_cd = problem_source_vocabulary_cd
 SET request->problem[1].source_identifier = problem_source_identifier
 SET request->problem[1].classification_cd = classification_cd
 SET request->problem[1].confirmation_status_cd = confirmation_status_cd
 SET request->problem[1].life_cycle_status_cd = life_cycle_status_cd
 SET request->problem[1].life_cycle_dt_tm = cnvtdatetime(curdate,curtime3)
 SET request->problem[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
 SET request->problem[1].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59")
 SET request->problem[1].status_upt_dt_tm = cnvtdatetime(curdate,curtime3)
 SET request->problem[1].contributor_system_cd = problem_contributor_system_cd
 SET request->problem[1].onset_tz = 0.0
 SET stat = alterlist(request->problem[1].problem_prsnl,1)
 SET request->problem[1].problem_prsnl[1].prsnl_action_ind = 1
 SET request->problem[1].problem_prsnl[1].problem_reltn_dt_tm = cnvtdatetime(curdate,curtime3)
 SET request->problem[1].problem_prsnl[1].problem_reltn_cd = problem_reltn_cd
 SET request->problem[1].problem_prsnl[1].problem_reltn_prsnl_id = reqinfo->updt_id
 SET request->problem[1].problem_prsnl[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
 SET request->problem[1].problem_prsnl[1].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59")
 EXECUTE kia_ens_problem
END GO
