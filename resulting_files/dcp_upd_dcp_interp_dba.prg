CREATE PROGRAM dcp_upd_dcp_interp:dba
 RECORD reply(
   1 dcp_interp_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE interp_id = f8 WITH public, noconstant(0.0)
 DECLARE errmsg = vc WITH protect
 DECLARE failed = i1 WITH protect, noconstant(0)
 SET updatecnt = 0
 IF ((request->dcp_interp_id > 0))
  SET interp_id = request->dcp_interp_id
  SELECT INTO "nl:"
   FROM dcp_interp i
   WHERE i.dcp_interp_id=interp_id
   DETAIL
    updatecnt = (i.updt_cnt+ 1)
   WITH nocounter
  ;end select
  DELETE  FROM dcp_interp_component ic
   WHERE ic.dcp_interp_id=interp_id
   WITH nocounter
  ;end delete
  DELETE  FROM dcp_interp_state s
   WHERE s.dcp_interp_id=interp_id
   WITH nocounter
  ;end delete
  DELETE  FROM dcp_interp i
   WHERE i.dcp_interp_id=interp_id
   WITH nocounter
  ;end delete
 ELSE
  SELECT INTO "nl:"
   j = seq(dcp_interp_seq,nextval)
   FROM dual
   DETAIL
    interp_id = cnvtreal(j)
   WITH format, nocounter
  ;end select
  CALL echo(build("interp_id = ",interp_id))
 ENDIF
 INSERT  FROM dcp_interp
  SET dcp_interp_id = interp_id, task_assay_cd = request->task_assay_cd, sex_cd = request->sex_cd,
   age_from_minutes = request->age_from_minutes, age_to_minutes = request->age_to_minutes,
   service_resource_cd = request->service_resource_cd,
   updt_cnt = updatecnt, updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = reqinfo->updt_id,
   updt_task = reqinfo->updt_task, updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = 1
  SET errmsg = build("Failed to insert into DCP_INTERP with id of:",interp_id)
  GO TO exit_script
 ENDIF
 SET cnt = size(request->components,5)
 FOR (x = 1 TO cnt)
  INSERT  FROM dcp_interp_component
   SET dcp_interp_component_id = seq(dcp_interp_seq,nextval), dcp_interp_id = interp_id,
    component_assay_cd = request->components[x].component_assay_cd,
    component_sequence = x, description = request->components[x].description, flags = request->
    components[x].flags,
    updt_cnt = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = reqinfo->updt_id,
    updt_task = reqinfo->updt_task, updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = 1
   SET errmsg = build("Failed to insert into DCP_INTERP_COMPONENT with component_assay_cd  of:",
    request->components[x].component_assay_cd)
   GO TO exit_script
  ENDIF
 ENDFOR
 SET cnt = size(request->states,5)
 FOR (x = 1 TO cnt)
  INSERT  FROM dcp_interp_state
   SET dcp_interp_state_id = seq(dcp_interp_seq,nextval), dcp_interp_id = interp_id, state = request
    ->states[x].state_id,
    input_assay_cd = request->states[x].transition_assay_cd, flags = request->states[x].flags,
    numeric_low = request->states[x].numeric_low,
    numeric_high = request->states[x].numeric_high, nomenclature_id = request->states[x].
    nomenclature_id, resulting_state = request->states[x].resulting_state,
    result_value = request->states[x].result_value, result_nomenclature_id = request->states[x].
    result_nomenclature_id, updt_cnt = 0,
    updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = reqinfo->updt_id, updt_task = reqinfo->
    updt_task,
    updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = 1
   SET errmsg = build("Failed to insert into DCP_INTERP_STATE with index of:",x)
   GO TO exit_script
  ENDIF
 ENDFOR
#exit_script
 SET reply->dcp_interp_id = interp_id
 IF (failed=1)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data[1].targetobjectvalue = errmsg
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
