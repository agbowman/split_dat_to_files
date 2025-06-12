CREATE PROGRAM dcp_add_outcome_activity
 SET modify = predeclare
 DECLARE criteria_count = i4 WITH constant(value(size(request->criteria,5)))
 DECLARE i = i4 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 INSERT  FROM outcome_activity oa
  SET oa.outcome_activity_id = request->outcomeactid, oa.person_id = request->personid, oa.encntr_id
    = request->encntrid,
   oa.event_cd = request->eventcd, oa.task_assay_cd = request->taskassaycd, oa.outcome_catalog_id =
   request->outcomecatalogid,
   oa.outcome_class_cd = request->outcomeclasscd, oa.outcome_type_cd = request->outcometypecd, oa
   .description = trim(request->description),
   oa.expectation = trim(request->expectation), oa.outcome_status_cd = request->outcomestatuscd, oa
   .outcome_status_dt_tm = cnvtdatetime(curdate,curtime3),
   oa.result_type_cd = request->resulttypecd, oa.target_type_cd = request->targettypecd, oa
   .target_duration_qty = request->targetdurationqty,
   oa.target_duration_unit_cd = request->targetdurationunitcd, oa.expand_qty = request->expandqty, oa
   .expand_unit_cd = request->expandunitcd,
   oa.start_dt_tm = cnvtdatetime(request->startdttm), oa.end_dt_tm = cnvtdatetime(request->enddttm),
   oa.operand_mean = request->operandmean,
   oa.reference_task_id = request->referencetaskid, oa.single_select_ind = request->singleselectind,
   oa.hide_expectation_ind = request->hideexpectationind,
   oa.ref_text_reltn_id = request->reftextreltnid, oa.outcome_status_tz = request->patienttz, oa
   .nomen_string_flag = request->nomenstringflag,
   oa.start_tz =
   IF ((request->startdttm != null)) request->patienttz
   ENDIF
   , oa.end_tz =
   IF ((request->enddttm != null)) request->patienttz
   ENDIF
   , oa.start_estimated_ind = request->startestimatedind,
   oa.end_estimated_ind = request->endestimatedind, oa.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   oa.updt_id = reqinfo->updt_id,
   oa.updt_task = reqinfo->updt_task, oa.updt_applctx = reqinfo->updt_applctx, oa.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL report_failure("INSERT","F","DCP_ADD_OUTCOME_ACTIVITY",
   "Unable to insert into OUTCOME_ACTIVITY")
  GO TO exit_script
 ENDIF
 INSERT  FROM outcome_action oa
  SET oa.outcome_activity_id = request->outcomeactid, oa.action_seq = 1, oa.outcome_status_cd =
   request->outcomestatuscd,
   oa.outcome_status_dt_tm = cnvtdatetime(curdate,curtime3), oa.target_type_cd = request->
   targettypecd, oa.start_dt_tm = cnvtdatetime(request->startdttm),
   oa.end_dt_tm = cnvtdatetime(request->enddttm), oa.action_dt_tm = cnvtdatetime(curdate,curtime3),
   oa.action_tz = request->usertz,
   oa.outcome_status_tz = request->patienttz, oa.start_tz =
   IF ((request->startdttm != null)) request->patienttz
   ENDIF
   , oa.end_tz =
   IF ((request->enddttm != null)) request->patienttz
   ENDIF
   ,
   oa.start_estimated_ind = request->startestimatedind, oa.end_estimated_ind = request->
   endestimatedind, oa.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   oa.updt_id = reqinfo->updt_id, oa.updt_task = reqinfo->updt_task, oa.updt_cnt = 0,
   oa.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL report_failure("INSERT","F","DCP_UPD_OUTCOME_ACTIVITY",
   "INSERT_OUTCOME_ACTION::Failed to insert into OUTCOME_ACTION table")
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO criteria_count)
  INSERT  FROM outcome_criteria oc
   SET oc.outcome_criteria_id = request->criteria[i].outcomecriteriaid, oc.outcome_activity_id =
    request->outcomeactid, oc.operator_cd = request->criteria[i].operatorcd,
    oc.result_value = request->criteria[i].resultvalue, oc.result_unit_cd = request->criteria[i].
    resultunitcd, oc.nomenclature_id = request->criteria[i].nomenclatureid,
    oc.sequence = request->criteria[i].sequence, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc
    .updt_id = reqinfo->updt_id,
    oc.updt_task = reqinfo->updt_task, oc.updt_applctx = reqinfo->updt_applctx, oc.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL report_failure("INSERT","F","DCP_ADD_OUTCOME_ACTIVITY",
    "Unable to insert into OUTCOME_CRITERIA")
   GO TO exit_script
  ENDIF
 ENDFOR
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cfailed = "T"
   SET stat = alterlist(reply->status_data.subeventstatus,(value(size(reply->status_data.
      subeventstatus,5))+ 1))
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
