CREATE PROGRAM dcp_add_outcome_catalog
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
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE criteria_count = i4 WITH constant(value(size(request->criterialist,5)))
 DECLARE i = i4 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE add_facility_cnt = i4 WITH noconstant(0)
 DECLARE insert_facility_flex_by_cd(null) = c1
 DECLARE remove_facility_flex(null) = null
 INSERT  FROM outcome_catalog oc
  SET oc.outcome_catalog_id = request->outcome_catalog_id, oc.event_cd = request->event_cd, oc
   .task_assay_cd = request->task_assay_cd,
   oc.description = request->description, oc.description_key = cnvtupper(cnvtalphanum(request->
     description)), oc.expectation = request->expectation,
   oc.expectation_key = cnvtupper(cnvtalphanum(request->expectation)), oc.outcome_type_cd = request->
   outcome_type_cd, oc.outcome_class_cd = request->outcome_class_cd,
   oc.result_type_cd = request->result_type_cd, oc.active_ind = request->active_ind, oc
   .active_status_cd = active_cd,
   oc.operand_mean = request->operand_mean, oc.reference_task_id = request->reference_task_id, oc
   .single_select_ind = request->single_select_ind,
   oc.hide_expectation_ind = request->hide_expectation_ind, oc.ref_text_reltn_id = request->
   ref_text_reltn_id, oc.nomen_string_flag = request->nomen_string_flag,
   oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id, oc.updt_task =
   reqinfo->updt_task,
   oc.updt_applctx = reqinfo->updt_applctx, oc.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL report_failure("INSERT","F","DCP_ADD_OUTCOME_CATALOG","Unable to insert into OUTCOME_CATALOG")
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO criteria_count)
  INSERT  FROM outcome_cat_criteria occ
   SET occ.outcome_cat_criteria_id = request->criterialist[i].outcome_cat_criteria_id, occ
    .outcome_catalog_id = request->outcome_catalog_id, occ.operator_cd = request->criterialist[i].
    operator_cd,
    occ.result_value = request->criterialist[i].result_value, occ.result_unit_cd = request->
    criterialist[i].result_unit_cd, occ.nomenclature_id = request->criterialist[i].nomenclature_id,
    occ.sequence = request->criterialist[i].sequence, occ.active_ind = request->criterialist[i].
    active_ind, occ.active_status_cd = active_cd,
    occ.updt_dt_tm = cnvtdatetime(curdate,curtime3), occ.updt_id = reqinfo->updt_id, occ.updt_task =
    reqinfo->updt_task,
    occ.updt_applctx = reqinfo->updt_applctx, occ.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL report_failure("INSERT","F","DCP_ADD_OUTCOME_CATALOG",
    "Unable to insert into OUTCOME_CAT_CRITERIA")
   GO TO exit_script
  ENDIF
 ENDFOR
 CALL remove_facility_flex(null)
 SET substat = insert_facility_flex_by_cd(null)
 IF (substat="F")
  GO TO exit_script
 ENDIF
 SUBROUTINE remove_facility_flex(null)
  SELECT INTO "nl:"
   FROM outcome_cat_loc_reltn oclr
   PLAN (oclr
    WHERE (oclr.outcome_catalog_id=request->outcome_catalog_id))
   WITH nocounter
  ;end select
  IF (curqual > 0)
   DELETE  FROM outcome_cat_loc_reltn oclr
    WHERE (oclr.outcome_catalog_id=request->outcome_catalog_id)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    CALL report_failure("DELETE","F","DCP_UPD_OUTCOME_CATALOG",
     "Unable to delete data from OUTCOME_CAT_LOC_RELTN table")
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE insert_facility_flex_by_cd(null)
   SET add_facility_cnt = size(request->facilityflexlist,5)
   IF (add_facility_cnt > 0)
    INSERT  FROM outcome_cat_loc_reltn oclr,
      (dummyt d  WITH seq = value(add_facility_cnt))
     SET oclr.location_cd = request->facilityflexlist[d.seq].facility_cd, oclr.outcome_catalog_id =
      request->outcome_catalog_id, oclr.outcome_cat_loc_reltn_id = seq(reference_seq,nextval),
      oclr.updt_applctx = reqinfo->updt_applctx, oclr.updt_cnt = 0, oclr.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      oclr.updt_id = reqinfo->updt_id, oclr.updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (oclr)
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_UPD_OUTCOME_CATALOG",
      "Unable to insert into OUTCOME_CAT_LOC_RELTN")
     RETURN("F")
    ENDIF
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cfailed = "T"
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
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
