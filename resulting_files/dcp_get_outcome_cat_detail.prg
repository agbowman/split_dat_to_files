CREATE PROGRAM dcp_get_outcome_cat_detail
 SET modify = predeclare
 IF (validate(reply,"N")="N")
  RECORD reply(
    1 outcome_catalog_id = f8
    1 description = vc
    1 expectation = vc
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
    1 active_ind = i2
    1 operand_mean = c12
    1 reference_task_id = f8
    1 task_description = vc
    1 updt_cnt = i4
    1 single_select_ind = i2
    1 hide_expectation_ind = i2
    1 ref_text_reltn_id = f8
    1 nomen_string_flag = i2
    1 criterialist[*]
      2 outcome_cat_criteria_id = f8
      2 nomenclature_id = f8
      2 result_value = f8
      2 result_unit_cd = f8
      2 result_unit_disp = c40
      2 result_unit_mean = c12
      2 operator_cd = f8
      2 operator_disp = c40
      2 operator_mean = c12
      2 sequence = i4
      2 active_ind = i2
      2 updt_cnt = i4
    1 planlist[*]
      2 description = vc
      2 version = i4
      2 active_ind = i2
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
    1 facilitylist[*]
      2 location_cd = f8
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
 SELECT INTO "nl:"
  FROM outcome_catalog oc,
   outcome_cat_criteria occ,
   order_task ot
  PLAN (oc
   WHERE (oc.outcome_catalog_id=request->outcome_catalog_id))
   JOIN (occ
   WHERE occ.outcome_catalog_id=oc.outcome_catalog_id
    AND occ.active_ind=1)
   JOIN (ot
   WHERE ot.reference_task_id=oc.reference_task_id)
  ORDER BY occ.sequence
  HEAD REPORT
   cnt = 0, reply->outcome_catalog_id = oc.outcome_catalog_id, reply->description = oc.description,
   reply->expectation = oc.expectation, reply->outcome_type_cd = oc.outcome_type_cd, reply->
   task_assay_cd = oc.task_assay_cd,
   reply->event_cd = oc.event_cd, reply->result_type_cd = oc.result_type_cd, reply->outcome_class_cd
    = oc.outcome_class_cd,
   reply->active_ind = oc.active_ind, reply->operand_mean = oc.operand_mean, reply->updt_cnt = oc
   .updt_cnt
   IF (ot.reference_task_id > 0)
    reply->reference_task_id = ot.reference_task_id, reply->task_description = trim(ot
     .task_description)
   ENDIF
   reply->single_select_ind = oc.single_select_ind, reply->hide_expectation_ind = oc
   .hide_expectation_ind, reply->ref_text_reltn_id = oc.ref_text_reltn_id,
   reply->nomen_string_flag = oc.nomen_string_flag
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->criterialist,cnt), reply->criterialist[cnt].
   outcome_cat_criteria_id = occ.outcome_cat_criteria_id,
   reply->criterialist[cnt].nomenclature_id = occ.nomenclature_id, reply->criterialist[cnt].
   result_value = occ.result_value, reply->criterialist[cnt].result_unit_cd = occ.result_unit_cd,
   reply->criterialist[cnt].operator_cd = occ.operator_cd, reply->criterialist[cnt].sequence = occ
   .sequence, reply->criterialist[cnt].updt_cnt = occ.updt_cnt
  FOOT REPORT
   cnt = 0
  WITH nocounter
 ;end select
 IF ((request->get_plan_info_ind > 0))
  RECORD temp(
    1 list[*]
      2 description = vc
      2 version = i4
      2 active_ind = i2
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
  )
  SELECT INTO "nl:"
   pc.parent_entity_id, pc.parent_entity_name, pwc1.description,
   pwc1.type_mean, pwc2.description, pwc2.type_mean
   FROM pathway_comp pc,
    pathway_catalog pwc1,
    pw_cat_reltn pcr,
    pathway_catalog pwc2,
    (dummyt d  WITH seq = 1)
   PLAN (pc
    WHERE (pc.parent_entity_id=request->outcome_catalog_id)
     AND pc.parent_entity_name="OUTCOME_CATALOG"
     AND pc.active_ind=1)
    JOIN (pwc1
    WHERE pwc1.pathway_catalog_id=pc.pathway_catalog_id)
    JOIN (d)
    JOIN (pcr
    WHERE pcr.pw_cat_t_id=pwc1.pathway_catalog_id
     AND pcr.type_mean="GROUP")
    JOIN (pwc2
    WHERE pwc2.pathway_catalog_id=pcr.pw_cat_s_id)
   ORDER BY pwc2.pathway_catalog_id, pwc1.pathway_catalog_id
   HEAD REPORT
    cnt = 0
   HEAD pwc2.pathway_catalog_id
    IF (pwc2.type_mean="PATHWAY"
     AND pwc2.active_ind=1)
     cnt = (cnt+ 1), stat = alterlist(temp->list,cnt), temp->list[cnt].description = trim(pwc2
      .description),
     temp->list[cnt].active_ind = pwc2.active_ind, temp->list[cnt].version = pwc2.version, temp->
     list[cnt].beg_effective_dt_tm = pwc2.beg_effective_dt_tm,
     temp->list[cnt].end_effective_dt_tm = pwc2.end_effective_dt_tm
    ENDIF
   HEAD pwc1.pathway_catalog_id
    IF (pwc1.type_mean="CAREPLAN"
     AND pwc1.active_ind=1)
     cnt = (cnt+ 1), stat = alterlist(temp->list,cnt), temp->list[cnt].description = trim(pwc1
      .description),
     temp->list[cnt].active_ind = pwc1.active_ind, temp->list[cnt].version = pwc1.version, temp->
     list[cnt].beg_effective_dt_tm = pwc1.beg_effective_dt_tm,
     temp->list[cnt].end_effective_dt_tm = pwc1.end_effective_dt_tm
    ENDIF
   DETAIL
    dummy = 0
   FOOT  pwc1.pathway_catalog_id
    dummy = 0
   FOOT  pwc2.pathway_catalog_id
    dummy = 0
   FOOT REPORT
    dummy = 0
   WITH nocounter, outerjoin = d
  ;end select
  IF (value(size(temp->list,5)) > 0)
   SELECT INTO "nl:"
    description = trim(temp->list[d.seq].description)
    FROM (dummyt d  WITH seq = value(size(temp->list,5)))
    ORDER BY description
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(reply->planlist,cnt), reply->planlist[cnt].description = trim(
      temp->list[d.seq].description),
     reply->planlist[cnt].active_ind = temp->list[d.seq].active_ind, reply->planlist[cnt].version =
     temp->list[d.seq].version, reply->planlist[cnt].beg_effective_dt_tm = temp->list[d.seq].
     beg_effective_dt_tm,
     reply->planlist[cnt].end_effective_dt_tm = temp->list[d.seq].end_effective_dt_tm
    FOOT REPORT
     dummy = 0
    WITH nocounter
   ;end select
  ENDIF
  FREE RECORD temp
 ENDIF
 DECLARE facilitycount = i4 WITH noconstant(0)
 DECLARE outcomerowcount = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  rowcnt = count(*)
  FROM outcome_cat_loc_reltn oclr,
   location loc
  PLAN (oclr)
   JOIN (loc
   WHERE (oclr.outcome_catalog_id=request->outcome_catalog_id)
    AND oclr.location_cd=loc.location_cd)
  HEAD REPORT
   outcomerowcount = rowcnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  oclr.outcome_catalog_id, oclr.location_cd, oclr_location_disp = uar_get_code_display(oclr
   .location_cd)
  FROM outcome_cat_loc_reltn oclr,
   location loc
  PLAN (oclr)
   JOIN (loc
   WHERE (oclr.outcome_catalog_id=request->outcome_catalog_id)
    AND oclr.location_cd=loc.location_cd)
  ORDER BY oclr_location_disp
  HEAD REPORT
   facilitycount = 0, stat = alterlist(reply->facilitylist,5)
  DETAIL
   facilitycount = (facilitycount+ 1)
   IF (facilitycount > size(reply->facilitylist,5))
    stat = alterlist(reply->facilitylist,(facilitycount+ 10))
   ENDIF
   IF (loc.active_ind=0
    AND outcomerowcount=1)
    reply->facilitylist[facilitycount].location_cd = 0.00
   ELSE
    reply->facilitylist[facilitycount].location_cd = oclr.location_cd
   ENDIF
  FOOT  oclr.location_cd
   IF (loc.active_ind=0
    AND outcomerowcount > 1)
    facilitycount = (facilitycount - 1), stat = alterlist(reply->facilitylist,facilitycount)
   ELSE
    stat = alterlist(reply->facilitylist,facilitycount)
   ENDIF
  WITH nocounter
 ;end select
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
