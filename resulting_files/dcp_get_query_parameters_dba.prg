CREATE PROGRAM dcp_get_query_parameters:dba
 RECORD reply(
   1 parameters[*]
     2 parameter_id = f8
     2 sequence = i4
     2 name = vc
     2 description = vc
     2 parameter_type_cd = f8
     2 required_ind = i2
     2 multiplicity_ind = i2
     2 metadata[*]
       3 name = vc
       3 sequence = i4
       3 value_string = vc
       3 value_dt = dq8
       3 value_id = f8
       3 value_entity = vc
     2 temp_values[*]
       3 parameter_seq = i4
       3 name = vc
       3 value_seq = i4
       3 value_string = vc
       3 value_dt = dq8
       3 value_id = f8
       3 value_entity = vc
     2 listvalues[*]
       3 parameter_seq = i4
       3 name = vc
       3 value_seq = i4
       3 value_string = vc
       3 value_dt = dq8
       3 value_id = f8
       3 value_entity = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE paramcnt = i4 WITH noconstant(0)
 DECLARE valuecnt = i4 WITH noconstant(0)
 DECLARE valuecnttemp = i4 WITH noconstant(0)
 DECLARE valuecntlist = i4 WITH noconstant(0)
 DECLARE patlistid = f8 WITH noconstant(request->patient_list_id)
 DECLARE tempid = f8 WITH noconstant(request->template_id)
 DECLARE querytypecd = f8 WITH noconstant(request->query_type_cd)
 SET reply->status_data.status = "F"
 IF (patlistid > 0)
  SELECT INTO "nl:"
   FROM dcp_pl_query_list dpql,
    dcp_pl_query_template dpqt
   PLAN (dpql
    WHERE dpql.patient_list_id=patlistid)
    JOIN (dpqt
    WHERE dpqt.template_id=dpql.template_id)
   DETAIL
    tempid = dpqt.template_id, querytypecd = dpqt.query_type_cd
   WITH nocounter
  ;end select
 ENDIF
 IF (tempid > 0
  AND querytypecd=0)
  SELECT INTO "nl:"
   FROM dcp_pl_query_template dpqt
   PLAN (dpqt
    WHERE dpqt.template_id=tempid)
   DETAIL
    querytypecd = dpqt.query_type_cd
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_pl_query_parameter dpqp,
   dcp_pl_query_value dpqv
  PLAN (dpqp
   WHERE dpqp.query_type_cd=querytypecd)
   JOIN (dpqv
   WHERE dpqv.parameter_id=outerjoin(dpqp.parameter_id))
  ORDER BY dpqp.parameter_id, dpqp.parameter_seq, dpqv.value_name,
   dpqv.value_seq
  HEAD REPORT
   paramcnt = 0
  HEAD dpqp.parameter_id
   paramcnt = (paramcnt+ 1), valuecnt = 0
   IF (mod(paramcnt,10)=1)
    stat = alterlist(reply->parameters,(paramcnt+ 9))
   ENDIF
   reply->parameters[paramcnt].parameter_id = dpqp.parameter_id, reply->parameters[paramcnt].sequence
    = dpqp.parameter_seq, reply->parameters[paramcnt].name = dpqp.parameter_name,
   reply->parameters[paramcnt].description = dpqp.parameter_desc, reply->parameters[paramcnt].
   parameter_type_cd = dpqp.parameter_type_cd, reply->parameters[paramcnt].required_ind = dpqp
   .required_ind
  DETAIL
   valuecnt = (valuecnt+ 1)
   IF (mod(valuecnt,10)=1)
    stat = alterlist(reply->parameters[paramcnt].metadata,(valuecnt+ 9))
   ENDIF
   reply->parameters[paramcnt].metadata[valuecnt].name = dpqv.value_name, reply->parameters[paramcnt]
   .metadata[valuecnt].sequence = dpqv.value_seq, reply->parameters[paramcnt].metadata[valuecnt].
   value_string = dpqv.value_string,
   reply->parameters[paramcnt].metadata[valuecnt].value_dt = dpqv.value_dt, reply->parameters[
   paramcnt].metadata[valuecnt].value_id = dpqv.parent_entity_id, reply->parameters[paramcnt].
   metadata[valuecnt].value_entity = dpqv.parent_entity_name
  FOOT  dpqp.parameter_id
   stat = alterlist(reply->parameters[paramcnt].metadata,valuecnt)
  FOOT REPORT
   stat = alterlist(reply->parameters,paramcnt)
  WITH nocounter
 ;end select
 IF (tempid > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = paramcnt),
    dcp_pl_query_value dpqv
   PLAN (d)
    JOIN (dpqv
    WHERE dpqv.template_id=tempid
     AND (dpqv.parameter_seq=reply->parameters[d.seq].sequence))
   HEAD dpqv.parameter_seq
    valuecnttemp = 0
   DETAIL
    valuecnttemp = (valuecnttemp+ 1)
    IF (mod(valuecnttemp,10)=1)
     stat = alterlist(reply->parameters[d.seq].temp_values,(valuecnttemp+ 9))
    ENDIF
    reply->parameters[d.seq].temp_values[valuecnttemp].parameter_seq = dpqv.parameter_seq, reply->
    parameters[d.seq].temp_values[valuecnttemp].name = dpqv.value_name, reply->parameters[d.seq].
    temp_values[valuecnttemp].value_seq = dpqv.value_seq,
    reply->parameters[d.seq].temp_values[valuecnttemp].value_string = dpqv.value_string, reply->
    parameters[d.seq].temp_values[valuecnttemp].value_dt = dpqv.value_dt, reply->parameters[d.seq].
    temp_values[valuecnttemp].value_id = dpqv.parent_entity_id,
    reply->parameters[d.seq].temp_values[valuecnttemp].value_entity = dpqv.parent_entity_name
   FOOT  dpqv.parameter_seq
    stat = alterlist(reply->parameters[d.seq].temp_values,valuecnttemp)
   WITH nocounter
  ;end select
 ENDIF
 IF (patlistid > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = paramcnt),
    dcp_pl_query_value dpqv
   PLAN (d)
    JOIN (dpqv
    WHERE dpqv.patient_list_id=patlistid
     AND (dpqv.parameter_seq=reply->parameters[d.seq].sequence))
   HEAD dpqv.parameter_seq
    valuecntlist = 0
   DETAIL
    valuecntlist = (valuecntlist+ 1)
    IF (mod(valuecntlist,10)=1)
     stat = alterlist(reply->parameters[d.seq].listvalues,(valuecntlist+ 9))
    ENDIF
    reply->parameters[d.seq].listvalues[valuecntlist].parameter_seq = dpqv.parameter_seq, reply->
    parameters[d.seq].listvalues[valuecntlist].name = dpqv.value_name, reply->parameters[d.seq].
    listvalues[valuecntlist].value_seq = dpqv.value_seq,
    reply->parameters[d.seq].listvalues[valuecntlist].value_string = dpqv.value_string, reply->
    parameters[d.seq].listvalues[valuecntlist].value_dt = dpqv.value_dt, reply->parameters[d.seq].
    listvalues[valuecntlist].value_id = dpqv.parent_entity_id,
    reply->parameters[d.seq].listvalues[valuecntlist].value_entity = dpqv.parent_entity_name
   FOOT  dpqv.parameter_seq
    stat = alterlist(reply->parameters[d.seq].listvalues,valuecntlist)
   WITH nocounter
  ;end select
 ENDIF
 IF (paramcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
