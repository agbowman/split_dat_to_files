CREATE PROGRAM dcp_bld_query_type:dba
 RECORD reply(
   1 query_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD cvrequest(
   1 code_set = i4
   1 qual[*]
     2 cdf_meaning = c12
     2 display = c40
     2 display_key = c40
     2 description = vc
     2 definition = vc
     2 collation_seq = i4
     2 active_type_cd = f8
     2 active_ind = i2
     2 authentic_ind = i2
     2 extension_cnt = i4
     2 extension_data[*]
       3 field_name = c32
       3 field_type = i4
       3 field_value = vc
 )
 RECORD cvreply(
   1 qual[1]
     2 code_value = f8
     2 display_key = c40
     2 rec_status = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE activecd = f8 WITH noconstant(0.0)
 DECLARE paramcnt = i4 WITH constant(size(request->parameters,5))
 DECLARE metadatacnt = i4 WITH noconstant(0)
 DECLARE param_seq = f8 WITH noconstant(0.0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE parent_entity_name = vc WITH noconstant(fillstring(1000," "))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=29802
   AND (cv.display=request->name)
   AND cv.active_ind=1
  DETAIL
   reply->status_data.status = "Z"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
   DETAIL
    activecd = cv.code_value
   WITH nocounter
  ;end select
  SET stat = alterlist(cvrequest->qual,1)
  SET cvrequest->code_set = 29802
  SET cvrequest->qual[1].display = request->name
  SET cvrequest->qual[1].description = request->query_script
  SET cvrequest->qual[1].definition = request->definition
  SET cvrequest->qual[1].collation_seq = 0
  SET cvrequest->qual[1].active_type_cd = activecd
  SET cvrequest->qual[1].active_ind = 1
  SET cvrequest->qual[1].extension_cnt = 0
  SET cvrequest->qual[1].cdf_meaning = ""
  EXECUTE cs_add_code  WITH replace("REQUEST","CVREQUEST"), replace("REPLY","CVREPLY")
  IF ((cvreply->status_data.status="S")
   AND (cvreply->qual[1].code_value > 0))
   SET reply->query_type_cd = cvreply->qual[1].code_value
   FOR (x = 1 TO paramcnt)
     SELECT INTO "nl:"
      num = seq(dcp_patient_list_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       param_seq = cnvtreal(num)
      WITH nocounter
     ;end select
     INSERT  FROM dcp_pl_query_parameter dpqp
      SET dpqp.multiplicity_ind = request->parameters[x].multiplicity_ind, dpqp.parameter_desc =
       request->parameters[x].description, dpqp.parameter_id = param_seq,
       dpqp.parameter_name = request->parameters[x].name, dpqp.parameter_seq = x, dpqp
       .parameter_type_cd = request->parameters[x].parameter_type_cd,
       dpqp.query_type_cd = reply->query_type_cd, dpqp.required_ind = request->parameters[x].
       required_ind, dpqp.updt_cnt = 0,
       dpqp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpqp.updt_id = reqinfo->updt_id, dpqp
       .updt_applctx = reqinfo->updt_applctx,
       dpqp.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual > 0)
      SET reply->status_data.status = "S"
      SET metadatacnt = size(request->parameters[x].metadata,5)
     ELSE
      SET reply->status_data.status = "F"
      SET reqinfo->commit_ind = 0
      SET reply->status_data.operationname = "Insert"
      SET reply->status_data.operationstatus = "F"
      SET reply->status_data.targetobjectname = "Error Message"
      SET reply->status_data.targetobjectvalue = "Failed adding rows to dcp_pl_query_parameter table"
      GO TO exit_script
     ENDIF
     FOR (y = 1 TO metadatacnt)
       IF ((request->parameters[x].metadata[y].value_entity=""))
        SET parent_entity_name = "null"
       ELSE
        SET parent_entity_name = request->parameters[x].metadata[y].value_entity
       ENDIF
       INSERT  FROM dcp_pl_query_value dpqv
        SET dpqv.query_value_id = seq(dcp_patient_list_seq,nextval), dpqv.parameter_id = param_seq,
         dpqv.patient_list_id = 0,
         dpqv.template_id = 0, dpqv.parameter_seq = x, dpqv.value_name = request->parameters[x].
         metadata[y].name,
         dpqv.value_seq = request->parameters[x].metadata[y].sequence, dpqv.value_dt = cnvtdatetime(
          request->parameters[x].metadata[y].value_dt), dpqv.value_string = request->parameters[x].
         metadata[y].value_string,
         dpqv.parent_entity_id = request->parameters[x].metadata[y].value_id, dpqv.parent_entity_name
          = parent_entity_name, dpqv.updt_cnt = 0,
         dpqv.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpqv.updt_id = reqinfo->updt_id, dpqv
         .updt_applctx = reqinfo->updt_applctx,
         dpqv.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET reply->status_data.status = "F"
        SET reqinfo->commit_ind = 0
        SET reply->status_data.operationname = "Insert"
        SET reply->status_data.operationstatus = "F"
        SET reply->status_data.targetobjectname = "Error Message"
        SET reply->status_data.targetobjectvalue = "Failed adding rows to dcp_pl_query_value table"
        GO TO exit_script
       ENDIF
     ENDFOR
   ENDFOR
  ELSE
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
   SET reply->status_data.operationname = "Insert"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "Error Message"
   SET reply->status_data.targetobjectvalue = "Failed adding code value"
  ENDIF
 ENDIF
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE RECORD cvrequest
 FREE RECORD cvreply
END GO
