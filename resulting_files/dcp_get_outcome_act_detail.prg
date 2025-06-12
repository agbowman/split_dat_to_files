CREATE PROGRAM dcp_get_outcome_act_detail
 SET modify = predeclare
 IF (validate(reply,"N")="N")
  RECORD reply(
    1 outcome_activity_id = f8
    1 outcome_catalog_id = f8
    1 description = vc
    1 expectation = vc
    1 outcome_status_cd = f8
    1 outcome_status_disp = c40
    1 outcome_status_mean = c12
    1 outcome_type_cd = f8
    1 outcome_type_disp = c40
    1 outcome_type_mean = c12
    1 task_assay_cd = f8
    1 event_cd = f8
    1 result_type_cd = f8
    1 result_type_disp = c40
    1 result_type_mean = c12
    1 outcome_class_cd = f8
    1 outcome_class_disp = c40
    1 outcome_class_mean = c12
    1 reference_task_id = f8
    1 updt_cnt = i4
    1 person_id = f8
    1 encntr_id = f8
    1 start_dt_tm = dq8
    1 end_dt_tm = dq8
    1 operand_mean = c12
    1 target_duration_qty = i4
    1 target_duration_unit_cd = f8
    1 target_duration_unit_disp = c40
    1 target_duration_unit_mean = c12
    1 single_select_ind = i2
    1 hide_expectation_ind = i2
    1 ref_text_reltn_id = f8
    1 start_tz = i4
    1 end_tz = i4
    1 criterialist[*]
      2 outcome_criteria_id = f8
      2 nomenclature_id = f8
      2 result_value = f8
      2 result_unit_cd = f8
      2 result_unit_disp = c40
      2 result_unit_mean = c12
      2 operator_cd = f8
      2 operator_disp = c40
      2 operator_mean = c12
      2 sequence = i4
      2 updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE num = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE dummy = i4 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE outcome_activated_cd = f8 WITH constant(uar_get_code_by("MEANING",30182,"ACTIVATED"))
 DECLARE outcome_completed_cd = f8 WITH constant(uar_get_code_by("MEANING",30182,"COMPLETED"))
 SELECT INTO "nl:"
  FROM outcome_activity oa,
   outcome_criteria oc
  PLAN (oa
   WHERE (oa.outcome_activity_id=request->outcome_activity_id))
   JOIN (oc
   WHERE oc.outcome_activity_id=oa.outcome_activity_id)
  ORDER BY oc.sequence
  HEAD REPORT
   cnt = 0, reply->outcome_activity_id = oa.outcome_activity_id, reply->outcome_catalog_id = oa
   .outcome_catalog_id,
   reply->description = trim(oa.description), reply->expectation = trim(oa.expectation)
   IF (oa.outcome_status_cd=outcome_activated_cd
    AND oa.end_dt_tm != null
    AND cnvtdatetime(oa.end_dt_tm) < cnvtdatetime(curdate,curtime3))
    reply->outcome_status_cd = outcome_completed_cd
   ELSE
    reply->outcome_status_cd = oa.outcome_status_cd
   ENDIF
   reply->outcome_type_cd = oa.outcome_type_cd, reply->task_assay_cd = oa.task_assay_cd, reply->
   event_cd = oa.event_cd,
   reply->result_type_cd = oa.result_type_cd, reply->outcome_class_cd = oa.outcome_class_cd, reply->
   operand_mean = oa.operand_mean,
   reply->reference_task_id = oa.reference_task_id, reply->updt_cnt = oa.updt_cnt, reply->person_id
    = oa.person_id,
   reply->encntr_id = oa.encntr_id, reply->start_dt_tm = cnvtdatetime(oa.start_dt_tm), reply->
   end_dt_tm = cnvtdatetime(oa.end_dt_tm),
   reply->target_duration_qty = oa.target_duration_qty, reply->target_duration_unit_cd = oa
   .target_duration_unit_cd, reply->single_select_ind = oa.single_select_ind,
   reply->hide_expectation_ind = oa.hide_expectation_ind, reply->ref_text_reltn_id = oa
   .ref_text_reltn_id, reply->start_tz = oa.start_tz,
   reply->end_tz = oa.end_tz
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->criterialist,cnt), reply->criterialist[cnt].
   outcome_criteria_id = oc.outcome_criteria_id,
   reply->criterialist[cnt].nomenclature_id = oc.nomenclature_id, reply->criterialist[cnt].
   result_value = oc.result_value, reply->criterialist[cnt].result_unit_cd = oc.result_unit_cd,
   reply->criterialist[cnt].operator_cd = oc.operator_cd, reply->criterialist[cnt].sequence = oc
   .sequence, reply->criterialist[cnt].updt_cnt = oc.updt_cnt
  FOOT REPORT
   cnt = 0
  WITH nocounter
 ;end select
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
