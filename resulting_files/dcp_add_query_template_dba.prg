CREATE PROGRAM dcp_add_query_template:dba
 RECORD reply(
   1 template_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE temp_seq = f8 WITH noconstant(0.0)
 DECLARE paramcnt = i4 WITH noconstant(size(request->parameters,5))
 DECLARE paramid = f8 WITH noconstant(0.0)
 DECLARE valuecnt = i4 WITH noconstant(0)
 DECLARE query_seq = f8 WITH noconstant(0.0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE entityname = c30 WITH noconstant(fillstring(30,""))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  num = seq(dcp_patient_list_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   temp_seq = cnvtreal(num)
  WITH format, counter
 ;end select
 INSERT  FROM dcp_pl_query_template dpqt
  SET dpqt.template_id = temp_seq, dpqt.query_type_cd = request->query_type_cd, dpqt.template_name =
   request->name,
   dpqt.updt_cnt = 0, dpqt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpqt.updt_id = reqinfo->
   updt_id,
   dpqt.updt_applctx = reqinfo->updt_applctx, dpqt.updt_task = reqinfo->updt_task
  WITH nocounter
 ;end insert
 FOR (x = 1 TO paramcnt)
   SELECT INTO "nl:"
    FROM dcp_pl_query_parameter dpqp
    WHERE (dpqp.query_type_cd=request->query_type_cd)
     AND (dpqp.parameter_seq=request->parameters[x].parameter_seq)
     AND (dpqp.parameter_name=request->parameters[x].parameter_name)
    DETAIL
     paramid = dpqp.parameter_id
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET valuecnt = size(request->parameters[x].values,5)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "F"
    SET reqinfo->commit_ind = 0
    SET reply->status_data.operationname = "Insert"
    SET reply->status_data.operationstatus = "F"
    SET reply->status_data.targetobjectname = "Error Message"
    SET reply->status_data.targetobjectvalue = "Failed adding rows"
    GO TO exit_script
   ENDIF
   FOR (y = 1 TO valuecnt)
     IF ((request->parameters[x].values[y].value_id=0.0))
      SET entityname = trim("")
     ELSE
      SET entityname = request->parameters[x].values[y].value_entity
     ENDIF
     INSERT  FROM dcp_pl_query_value dpqv
      SET dpqv.parameter_id = paramid, dpqv.parameter_seq = request->parameters[x].parameter_seq,
       dpqv.parent_entity_id = request->parameters[x].values[y].value_id,
       dpqv.parent_entity_name = trim(entityname), dpqv.patient_list_id = 0, dpqv.query_value_id =
       seq(dcp_patient_list_seq,nextval),
       dpqv.template_id = temp_seq, dpqv.value_dt = cnvtdatetime(request->parameters[x].values[y].
        value_dt), dpqv.value_name = request->parameters[x].values[y].name,
       dpqv.value_seq = request->parameters[x].values[y].value_seq, dpqv.value_string = request->
       parameters[x].values[y].value_string, dpqv.updt_cnt = 0,
       dpqv.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpqv.updt_id = reqinfo->updt_id, dpqv
       .updt_applctx = reqinfo->updt_applctx,
       dpqv.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->status_data.status = "Z"
     ENDIF
   ENDFOR
 ENDFOR
 SET reply->template_id = temp_seq
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
