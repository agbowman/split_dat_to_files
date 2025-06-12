CREATE PROGRAM dcp_execute_query_list:dba
 RECORD definition(
   1 patient_list_id = f8
   1 parameters[*]
     2 parameter_name = vc
     2 parameter_seq = i4
     2 values[*]
       3 value_name = vc
       3 value_seq = i4
       3 value_string = vc
       3 value_dt = dq8
       3 value_id = f8
       3 value_entity = vc
 )
 RECORD patients(
   1 patients[*]
     2 person_id = f8
     2 encntr_id = f8
     2 priority = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE querydesc = vc WITH noconstant(fillstring(15," "))
 DECLARE querytypecd = f8 WITH noconstant(0.0)
 DECLARE paramcnt = i4 WITH private, noconstant(0)
 DECLARE valuecnt = i4 WITH private, noconstant(0)
 DECLARE executecd = f8 WITH constant(uar_get_code_by("MEANING",29804,"EXECUTING"))
 DECLARE completecd = f8 WITH constant(uar_get_code_by("MEANING",29804,"COMPLETED"))
 DECLARE patientcnt = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE tempcd = f8 WITH noconstant(0.0)
 SET modify = nopredeclare
 SET currentdate = cnvtdatetime(sysdate)
 SET tempdate = cnvtdatetime(sysdate)
 SET modify = predeclare
 SELECT INTO "nl:"
  FROM dcp_pl_query_list dpql,
   dcp_pl_query_template dpqt,
   dcp_pl_query_value dpqv,
   dcp_pl_query_parameter dpqp
  PLAN (dpql
   WHERE (dpql.patient_list_id=request->patient_list_id))
   JOIN (dpqt
   WHERE dpqt.template_id=dpql.template_id)
   JOIN (dpqv
   WHERE (((dpqv.patient_list_id=request->patient_list_id)) OR (dpqv.template_id=dpqt.template_id)) )
   JOIN (dpqp
   WHERE dpqp.parameter_seq=dpqv.parameter_seq
    AND dpqp.query_type_cd=dpqt.query_type_cd)
  ORDER BY dpqv.parameter_seq, dpqv.value_name, dpqv.value_seq
  HEAD REPORT
   definition->patient_list_id = request->patient_list_id, querytypecd = dpqt.query_type_cd, paramcnt
    = 0
  HEAD dpqv.parameter_seq
   paramcnt += 1
   IF (mod(paramcnt,10)=1)
    stat = alterlist(definition->parameters,(paramcnt+ 9))
   ENDIF
   definition->parameters[paramcnt].parameter_name = dpqp.parameter_name, definition->parameters[
   paramcnt].parameter_seq = dpqp.parameter_seq, valuecnt = 0
  DETAIL
   valuecnt += 1
   IF (mod(valuecnt,10)=1)
    stat = alterlist(definition->parameters[paramcnt].values,(valuecnt+ 9))
   ENDIF
   definition->parameters[paramcnt].values[valuecnt].value_name = dpqv.value_name, definition->
   parameters[paramcnt].values[valuecnt].value_seq = dpqv.value_seq, definition->parameters[paramcnt]
   .values[valuecnt].value_string = dpqv.value_string,
   definition->parameters[paramcnt].values[valuecnt].value_dt = dpqv.value_dt, definition->
   parameters[paramcnt].values[valuecnt].value_id = dpqv.parent_entity_id, definition->parameters[
   paramcnt].values[valuecnt].value_entity = dpqv.parent_entity_name
  FOOT  dpqv.parameter_seq
   stat = alterlist(definition->parameters[paramcnt].values,valuecnt)
  FOOT REPORT
   stat = alterlist(definition->parameters,paramcnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SET querydesc = cnvtupper(trim(uar_get_code_description(querytypecd)))
 SELECT INTO "nl:"
  dpql.patient_list_id
  FROM dcp_pl_query_list dpql
  WHERE (dpql.patient_list_id=request->patient_list_id)
  DETAIL
   tempcd = dpql.execution_status_cd, tempdate = dpql.execution_dt_tm
  WITH nocounter, forupdate(dpql)
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM dcp_pl_query_list dpql
  SET dpql.execution_status_cd = executecd, dpql.updt_cnt = 0, dpql.updt_dt_tm = cnvtdatetime(sysdate
    ),
   dpql.updt_id = reqinfo->updt_id, dpql.updt_applctx = reqinfo->updt_applctx, dpql.updt_task =
   reqinfo->updt_task
  WHERE (dpql.patient_list_id=request->patient_list_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 EXECUTE value(querydesc)  WITH replace(request,definition), replace(reply,patients)
 IF ((((patients->status_data.status="S")) OR ((patients->status_data.status="Z"))) )
  SELECT INTO "nl:"
   dpql.patient_list_id
   FROM dcp_pl_query_list dpql
   WHERE (dpql.patient_list_id=request->patient_list_id)
   WITH nocounter, forupdate(dpql)
  ;end select
  IF (curqual=0)
   GO TO exit_script
  ENDIF
  UPDATE  FROM dcp_pl_query_list dpql
   SET dpql.execution_status_cd = completecd, dpql.execution_dt_tm = cnvtdatetime(currentdate), dpql
    .updt_cnt = 0,
    dpql.updt_id = reqinfo->updt_id, dpql.updt_applctx = reqinfo->updt_applctx, dpql.updt_task =
    reqinfo->updt_task
   WHERE (dpql.patient_list_id=request->patient_list_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   GO TO exit_script
  ENDIF
  IF ((((patients->status_data.status="S")) OR ((patients->status_data.status="Z"))) )
   DELETE  FROM dcp_pl_custom_entry dpce
    WHERE (dpce.patient_list_id=request->patient_list_id)
    WITH nocounter
   ;end delete
   DELETE  FROM dcp_pl_prioritization pr
    WHERE (pr.patient_list_id=request->patient_list_id)
    WITH nocounter
   ;end delete
   SET patientcnt = size(patients->patients,5)
   FOR (x = 1 TO patientcnt)
     INSERT  FROM dcp_pl_custom_entry dpce
      SET dpce.custom_entry_id = seq(dcp_patient_list_seq,nextval), dpce.encntr_id = patients->
       patients[x].encntr_id, dpce.patient_list_id = request->patient_list_id,
       dpce.person_id = patients->patients[x].person_id, dpce.updt_cnt = 0, dpce.updt_dt_tm =
       cnvtdatetime(sysdate),
       dpce.updt_id = reqinfo->updt_id, dpce.updt_applctx = reqinfo->updt_applctx, dpce.updt_task =
       reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET patients->status_data.status = "F"
      GO TO exit_script
     ENDIF
     IF ((patients->patients[x].priority > 0))
      INSERT  FROM dcp_pl_prioritization pr
       SET pr.patient_list_id = request->patient_list_id, pr.person_id = patients->patients[x].
        person_id, pr.priority = patients->patients[x].priority,
        pr.priority_id = seq(dcp_patient_list_seq,nextval), pr.updt_cnt = 0, pr.updt_dt_tm =
        cnvtdatetime(sysdate),
        pr.updt_id = reqinfo->updt_id, pr.updt_applctx = reqinfo->updt_applctx, pr.updt_task =
        reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET patients->status_data.status = "F"
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
#exit_script
 IF ((patients->status_data.status="F"))
  ROLLBACK
  SELECT INTO "nl:"
   dpql.patient_list_id
   FROM dcp_pl_query_list dpql
   WHERE (dpql.patient_list_id=request->patient_list_id)
   WITH nocounter, forupdate(dpql)
  ;end select
  IF (curqual=0)
   GO TO exit_script
  ENDIF
  UPDATE  FROM dcp_pl_query_list dpql
   SET dpql.execution_status_cd = tempcd, dpql.execution_dt_tm = cnvtdatetime(tempdate), dpql
    .updt_cnt = 0,
    dpql.updt_id = reqinfo->updt_id, dpql.updt_applctx = reqinfo->updt_applctx, dpql.updt_task =
    reqinfo->updt_task
   WHERE (dpql.patient_list_id=request->patient_list_id)
   WITH nocounter
  ;end update
 ENDIF
 SET reqinfo->commit_ind = 1
 FREE RECORD definition
 FREE RECORD patients
END GO
