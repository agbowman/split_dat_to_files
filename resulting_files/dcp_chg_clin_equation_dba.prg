CREATE PROGRAM dcp_chg_clin_equation:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET max_units = 10
 SET x = 0
 UPDATE  FROM dcp_equation d
  SET d.description = request->description, d.description_key = cnvtupper(request->description), d
   .begin_age_nbr = request->begin_age_nbr,
   d.begin_age_flag = request->begin_age_flag, d.end_age_nbr = request->end_age_nbr, d.end_age_flag
    = request->end_age_flag,
   d.gender_cd = request->gender_cd, d.equation_display = request->equation_display, d
   .equation_meaning = request->equation_meaning,
   d.equation_code = request->equation_code, d.active_ind = request->active_ind, d
   .calcvalue_description = request->calcvalue_description,
   d.updt_dt_tm = cnvtdatetime(curdate,curtime), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo
   ->updt_task,
   d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0
  WHERE (d.dcp_equation_id=request->dcp_equation_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_equation"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "CHANGE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to update into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#component_code
 FOR (x = 1 TO request->number_components)
  UPDATE  FROM dcp_equa_component d
   SET d.component_flag = request->components[x].component_flag, d.constant_value = request->
    components[x].constant_value, d.component_label = request->components[x].component_label,
    d.component_description = request->components[x].component_description, d.event_cd = request->
    components[x].event_cd, d.required_ind = request->components[x].required_ind,
    d.corresponding_equation_id = request->components[x].corresponding_equation_id, d.component_code
     = request->components[x].component_code, d.duplicate_component_name = request->components[x].
    duplicate_component_name,
    d.updt_dt_tm = cnvtdatetime(curdate,curtime), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo
    ->updt_task,
    d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0
   WHERE (d.dcp_component_id=request->components[x].dcp_component_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_equa_component"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "CHANGE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to update into table"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDFOR
#unit_measure_code
 FOR (x = 1 TO request->number_components)
  IF ((request->component[x].number_units > 0))
   DELETE  FROM dcp_unit_measure d,
     (dummyt d1  WITH seq = request->number_components)
    SET d.seq = 1
    PLAN (d1)
     JOIN (d
     WHERE (d.dcp_component_id=request->components[x].dcp_component_id))
    WITH nocounter
   ;end delete
   INSERT  FROM dcp_unit_measure d,
     (dummyt d2  WITH seq = value(request->components[x].number_units))
    SET d.seq = 1, d.dcp_component_id = request->components[x].dcp_component_id, d.dcp_equation_id =
     request->dcp_equation_id,
     d.unit_measure_cd = request->components[x].unit_measure[d1.seq].unit_measure_cd, d
     .unit_measure_meaning = request->components[x].unit_measure[d1.seq].unit_measure_meaning, d
     .default_ind = request->components[x].unit_measure[d1.seq].default_ind,
     d.equation_dependent_unit_ind = request->components[x].unit_measure[d1.seq].
     equation_dependent_unit_ind, d.updt_dt_tm = cnvtdatetime(curdate,curtime), d.updt_id = reqinfo->
     updt_id,
     d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0
    PLAN (d1)
     JOIN (d
     WHERE (request->components[x].unit_measure[d1.seq].unit_measure_cd > 0))
    WITH nocounter
   ;end insert
  ENDIF
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_unit_measure"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "CHANGE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to update into table"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
