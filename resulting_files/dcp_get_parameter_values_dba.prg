CREATE PROGRAM dcp_get_parameter_values:dba
 RECORD reply(
   1 tempvalues[*]
     2 parameter_seq = i4
     2 name = vc
     2 value_seq = i4
     2 value_string = vc
     2 value_dt = dq8
     2 value_id = f8
     2 value_entity = vc
   1 listvalues[*]
     2 parameter_seq = i4
     2 name = vc
     2 value_seq = i4
     2 value_string = vc
     2 value_dt = dq8
     2 value_id = f8
     2 value_entity = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE valuecnt = i4 WITH noconstant(0)
 DECLARE patvaluecnt = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 IF ((request->template_id > 0))
  SELECT INTO "nl:"
   FROM dcp_pl_query_value dpqv
   PLAN (dpqv
    WHERE (dpqv.template_id=request->template_id))
   ORDER BY dpqv.parameter_seq, dpqv.value_name, dpqv.value_seq
   HEAD REPORT
    valuecnt = 0
   DETAIL
    valuecnt = (valuecnt+ 1)
    IF (mod(valuecnt,10)=1)
     stat = alterlist(reply->tempvalues,(valuecnt+ 9))
    ENDIF
    reply->tempvalues[valuecnt].parameter_seq = dpqv.parameter_seq, reply->tempvalues[valuecnt].name
     = dpqv.value_name, reply->tempvalues[valuecnt].value_seq = dpqv.value_seq,
    reply->tempvalues[valuecnt].value_string = dpqv.value_string, reply->tempvalues[valuecnt].
    value_dt = dpqv.value_dt, reply->tempvalues[valuecnt].value_id = dpqv.parent_entity_id,
    reply->tempvalues[valuecnt].value_entity = dpqv.parent_entity_name
   FOOT REPORT
    stat = alterlist(reply->tempvalues,valuecnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->patient_list_id > 0))
  SELECT INTO "nl:"
   FROM dcp_pl_query_value dpqv
   PLAN (dpqv
    WHERE (dpqv.patient_list_id=request->patient_list_id))
   ORDER BY dpqv.parameter_seq, dpqv.value_name, dpqv.value_seq
   HEAD REPORT
    patvaluecnt = valuecnt
   DETAIL
    patvaluecnt = (patvaluecnt+ 1)
    IF (mod(patvaluecnt,10)=1)
     stat = alterlist(reply->listvalues,(patvaluecnt+ 9))
    ENDIF
    reply->listvalues[patvaluecnt].parameter_seq = dpqv.parameter_seq, reply->listvalues[patvaluecnt]
    .name = dpqv.value_name, reply->listvalues[patvaluecnt].value_seq = dpqv.value_seq,
    reply->listvalues[patvaluecnt].value_string = dpqv.value_string, reply->listvalues[patvaluecnt].
    value_dt = dpqv.value_dt, reply->listvalues[patvaluecnt].value_id = dpqv.parent_entity_id,
    reply->listvalues[patvaluecnt].value_entity = dpqv.parent_entity_name
   FOOT REPORT
    stat = alterlist(reply->listvalues,patvaluecnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (((valuecnt > 0) OR (patvaluecnt > 0)) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
