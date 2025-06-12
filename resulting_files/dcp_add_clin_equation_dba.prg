CREATE PROGRAM dcp_add_clin_equation:dba
 RECORD reply(
   1 dcp_equation_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD internal(
   1 comp_ids[*]
     2 comp_id = f8
     2 unit_ids[*]
       3 unit_measure_cd = f8
 )
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE equa_id = f8 WITH noconstant(0.0)
 DECLARE comp_cnt = i4 WITH noconstant(0)
 DECLARE unit_cnt = i4 WITH noconstant(0)
 DECLARE max_unit = i4 WITH noconstant(10)
 DECLARE stat = i4
 SELECT INTO "nl:"
  y = seq(reference_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   equa_id = cnvtreal(y)
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET comp_cnt = request->number_components
 SET stat = alterlist(internal->comp_ids,comp_cnt)
 FOR (x = 1 TO comp_cnt)
  SET unit_cnt = request->components[x].number_units
  SET stat = alterlist(internal->comp_ids[x].unit_ids,unit_cnt)
 ENDFOR
 FOR (x = 1 TO comp_cnt)
  SELECT INTO "nl:"
   y = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    internal->comp_ids[x].comp_id = cnvtreal(y)
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDFOR
 INSERT  FROM dcp_equation d
  SET d.seq = 1, d.dcp_equation_id = equa_id, d.description = request->description,
   d.description_key = cnvtupper(request->description), d.begin_age_nbr = request->begin_age_nbr, d
   .begin_age_flag = request->begin_age_flag,
   d.end_age_nbr = request->end_age_nbr, d.end_age_flag = request->end_age_flag, d.gender_cd =
   request->gender_cd,
   d.equation_display = request->equation_display, d.equation_meaning = request->equation_meaning, d
   .equation_code = request->equation_code,
   d.active_ind = request->active_ind, d.calcvalue_description = request->calcvalue_description, d
   .updt_dt_tm = cnvtdatetime(curdate,curtime),
   d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
   updt_applctx,
   d.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF ((request->position_cnt > 0))
  INSERT  FROM dcp_equa_position d,
    (dummyt d2  WITH seq = value(request->position_cnt))
   SET d.seq = 1, d.dcp_equation_id = equa_id, d.position_cd = request->positions[d2.seq].position_cd,
    d.updt_dt_tm = cnvtdatetime(curdate,curtime), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo
    ->updt_task,
    d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0
   PLAN (d2)
    JOIN (d)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 INSERT  FROM dcp_equa_component d,
   (dummyt d1  WITH seq = value(comp_cnt))
  SET d.seq = 1, d.dcp_equation_id = equa_id, d.dcp_component_id = internal->comp_ids[d1.seq].comp_id,
   d.component_flag = request->components[d1.seq].component_flag, d.constant_value = request->
   components[d1.seq].constant_value, d.component_label = request->components[d1.seq].component_label,
   d.component_description = request->components[d1.seq].component_description, d.event_cd = request
   ->components[d1.seq].event_cd, d.required_ind = request->components[d1.seq].required_ind,
   d.corresponding_equation_id = request->components[d1.seq].corresponding_equation_id, d
   .component_code = request->components[d1.seq].component_code, d.duplicate_component_name = request
   ->components[d1.seq].duplicate_component_name,
   d.updt_dt_tm = cnvtdatetime(curdate,curtime), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo
   ->updt_task,
   d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0
  PLAN (d1)
   JOIN (d)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO comp_cnt)
   IF ((request->components[x].number_units > 0))
    INSERT  FROM dcp_unit_measure d,
      (dummyt d1  WITH seq = value(request->components[x].number_units))
     SET d.seq = 1, d.dcp_component_id = internal->comp_ids[x].comp_id, d.dcp_equation_id = equa_id,
      d.unit_measure_cd = request->components[x].unit_measure[d1.seq].unit_measure_cd, d
      .unit_measure_meaning = request->components[x].unit_measure[d1.seq].unit_measure_meaning, d
      .default_ind = request->components[x].unit_measure[d1.seq].default_ind,
      d.equation_dependent_unit_ind = request->components[x].unit_measure[d1.seq].
      equation_dependent_unit_ind, d.updt_dt_tm = cnvtdatetime(curdate,curtime), d.updt_id = reqinfo
      ->updt_id,
      d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0
     PLAN (d1)
      JOIN (d
      WHERE (request->components[x].unit_measure[d1.seq].unit_measure_cd > 0))
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP EQUATION TABLES"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO INSERT"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->dcp_equation_id = equa_id
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
