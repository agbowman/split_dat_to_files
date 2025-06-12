CREATE PROGRAM dcp_upd_custom_pl:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE g_number_to_add = i4 WITH public, noconstant(size(request->additions,5))
 DECLARE g_number_to_subtract = i4 WITH public, noconstant(size(request->subtractions,5))
 DECLARE x = i4 WITH public, noconstant(0)
 DECLARE qual = i2 WITH public, noconstant(1)
 DECLARE prsnl_group_id = f8 WITH noconstant(0.0)
 DECLARE patient_list_id = f8 WITH noconstant(0.0)
 DECLARE list_type = vc
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dcp_patient_list pl,
   code_value cv
  PLAN (pl
   WHERE (pl.patient_list_id=request->patient_list_id))
   JOIN (cv
   WHERE cv.code_value=pl.patient_list_type_cd)
  DETAIL
   list_type = cv.cdf_meaning
  WITH nocounter
 ;end select
 IF (list_type="CUSTOM")
  SET patient_list_id = request->patient_list_id
 ELSEIF (list_type="CARETEAM")
  SELECT INTO "nl:"
   FROM dcp_pl_argument pla
   WHERE (pla.patient_list_id=request->patient_list_id)
    AND ((pla.argument_name="prsnl_group_id") OR (pla.argument_name="careteam_id"))
   DETAIL
    prsnl_group_id = pla.parent_entity_id
   WITH nocounter
  ;end select
 ENDIF
 IF (g_number_to_add > 0)
  FOR (x = 1 TO g_number_to_add)
   INSERT  FROM dcp_pl_custom_entry plce
    SET plce.custom_entry_id = seq(dcp_patient_list_seq,nextval), plce.encntr_id = request->
     additions[x].encounter_id, plce.patient_list_id = patient_list_id,
     plce.prsnl_group_id = prsnl_group_id, plce.person_id = request->additions[x].person_id, plce
     .updt_applctx = reqinfo->updt_applctx,
     plce.updt_cnt = 0, plce.updt_dt_tm = cnvtdatetime(curdate,curtime3), plce.updt_id = reqinfo->
     updt_id,
     plce.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF ((request->additions[x].priority > 0))
    INSERT  FROM dcp_pl_prioritization pp
     SET pp.patient_list_id = request->patient_list_id, pp.person_id = request->additions[x].
      person_id, pp.priority = request->additions[x].priority,
      pp.priority_id = seq(dcp_patient_list_seq,nextval), pp.updt_applctx = reqinfo->updt_applctx, pp
      .updt_cnt = 0,
      pp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pp.updt_id = reqinfo->updt_id, pp.updt_task =
      reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
  ENDFOR
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
  ELSE
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ENDIF
 ENDIF
 IF (g_number_to_subtract > 0)
  FOR (x = 1 TO g_number_to_subtract)
    IF ((request->subtractions[x].encounter_id >= 0))
     DELETE  FROM dcp_pl_custom_entry plce
      WHERE plce.patient_list_id=patient_list_id
       AND plce.prsnl_group_id=prsnl_group_id
       AND (plce.person_id=request->subtractions[x].person_id)
       AND (plce.encntr_id=request->subtractions[x].encounter_id)
      WITH nocounter
     ;end delete
    ELSE
     DELETE  FROM dcp_pl_custom_entry plce
      WHERE plce.patient_list_id=patient_list_id
       AND plce.prsnl_group_id=prsnl_group_id
       AND (plce.person_id=request->subtractions[x].person_id)
      WITH nocounter
     ;end delete
    ENDIF
    IF (curqual=0)
     SET qual = 0
    ENDIF
    DELETE  FROM dcp_pl_prioritization plp
     WHERE (plp.patient_list_id=request->patient_list_id)
      AND (plp.person_id=request->subtractions[x].person_id)
     WITH nocounter
    ;end delete
  ENDFOR
  IF (curqual=0
   AND qual=0)
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
  ELSE
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ENDIF
 ENDIF
END GO
