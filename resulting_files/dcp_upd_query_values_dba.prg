CREATE PROGRAM dcp_upd_query_values:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE paramcnt = i4 WITH constant(size(request->parameters,5))
 DECLARE queryval_seq = f8 WITH noconstant(0.0)
 DECLARE valuecnt = i4 WITH noconstant(0)
 DECLARE entityname = c30 WITH noconstant(fillstring(30,""))
 SET reply->status_data.status = "F"
 DELETE  FROM dcp_pl_query_value dpqv
  WHERE (dpqv.patient_list_id=request->patient_list_id)
  WITH nocounter
 ;end delete
 FOR (x = 1 TO paramcnt)
  SET valuecnt = size(request->parameters[x].values,5)
  FOR (y = 1 TO valuecnt)
    SELECT INTO "nl:"
     num = seq(dcp_patient_list_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      queryval_seq = cnvtreal(num)
     WITH format, counter
    ;end select
    IF ((request->parameters[x].values[y].value_id=0.0))
     SET entityname = trim("")
    ELSE
     SET entityname = request->parameters[x].values[y].value_entity
    ENDIF
    INSERT  FROM dcp_pl_query_value dpqv
     SET dpqv.parameter_seq = request->parameters[x].parameter_seq, dpqv.parent_entity_id = request->
      parameters[x].values[y].value_id, dpqv.parent_entity_name = trim(entityname),
      dpqv.patient_list_id = request->patient_list_id, dpqv.template_id = 0, dpqv.parameter_id = 0,
      dpqv.query_value_id = queryval_seq, dpqv.value_dt = cnvtdatetime(request->parameters[x].values[
       y].value_dt), dpqv.value_name = request->parameters[x].values[y].name,
      dpqv.value_seq = request->parameters[x].values[y].value_seq, dpqv.value_string = request->
      parameters[x].values[y].value_string, dpqv.updt_cnt = 0,
      dpqv.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpqv.updt_id = reqinfo->updt_id, dpqv
      .updt_applctx = reqinfo->updt_applctx,
      dpqv.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
  ENDFOR
 ENDFOR
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
