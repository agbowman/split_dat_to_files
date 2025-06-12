CREATE PROGRAM bed_ens_fn_filter:dba
 FREE SET reply
 RECORD reply(
   1 custom_filter_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET filter_cnt = size(request->filters,5)
 DECLARE nvp_parse = vc
 SET reply->custom_filter_id = request->custom_filter_id
 IF ((request->action_flag=1))
  SELECT INTO "NL:"
   j = seq(carenet_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    reply->custom_filter_id = cnvtreal(j)
   WITH format, counter
  ;end select
  INSERT  FROM predefined_prefs pp
   SET pp.predefined_prefs_id = reply->custom_filter_id, pp.predefined_type_meaning = cnvtstring(
     request->column_view_id), pp.name = request->custom_filter_name,
    pp.active_ind = 1, pp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pp.updt_id = reqinfo->updt_id,
    pp.updt_task = reqinfo->updt_task, pp.updt_cnt = 0, pp.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = concat("Unable to insert predefined_prefs_id  = ",cnvtstring(request->
     custom_field_id)," into predefined_prefs table for filter ",reply->custom_field_name)
   GO TO exit_script
  ENDIF
 ELSEIF ((request->action_flag=2))
  UPDATE  FROM predefined_prefs pp
   SET pp.name = request->custom_filter_name, pp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pp
    .updt_id = reqinfo->updt_id,
    pp.updt_task = reqinfo->updt_task, pp.updt_cnt = (pp.updt_cnt+ 1), pp.updt_applctx = reqinfo->
    updt_applctx
   WHERE (pp.predefined_prefs_id=request->custom_filter_id)
  ;end update
 ENDIF
 FOR (x = 1 TO filter_cnt)
   IF ((request->filters[x].action_flag=1))
    SET name_value_prefs_id = 0.0
    SELECT INTO "NL:"
     j = seq(carenet_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      name_value_prefs_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET col_detail = fillstring(256," ")
    IF ((request->filters[x].code_value > 0))
     SET col_detail = concat(trim(request->filters[x].mean),"^",trim(cnvtstring(request->filters[x].
        code_value)),",",trim(request->filters[x].value))
    ELSE
     SET col_detail = concat(trim(request->filters[x].mean),",",trim(request->filters[x].value))
    ENDIF
    INSERT  FROM name_value_prefs nvp
     SET nvp.name_value_prefs_id = name_value_prefs_id, nvp.parent_entity_name = "PREDEFINED_PREFS",
      nvp.parent_entity_id = reply->custom_filter_id,
      nvp.pvc_name = "FILTERFIELD", nvp.pvc_value = col_detail, nvp.active_ind = 1,
      nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
      nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
       = reqinfo->updt_task,
      nvp.updt_cnt = 1, nvp.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert parent_entity_id = ",cnvtstring(request->
       custom_filter_id)," into name_value_prefs table for column ",request->filters[x].mean)
     GO TO exit_script
    ENDIF
   ELSEIF ((request->filters[x].action_flag=2))
    SET col_detail = fillstring(256," ")
    IF ((request->filters[x].code_value > 0))
     SET col_detail = concat(trim(request->filters[x].mean),"^",trim(cnvtstring(request->filters[x].
        code_value)),",",trim(request->filters[x].value))
    ELSE
     SET col_detail = concat(trim(request->filters[x].mean),",",trim(request->filters[x].value))
    ENDIF
    UPDATE  FROM name_value_prefs nvp
     SET nvp.pvc_value = col_detail, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id =
      reqinfo->updt_id,
      nvp.updt_task = reqinfo->updt_task, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_applctx =
      reqinfo->updt_applctx
     WHERE (nvp.name_value_prefs_id=request->filters[x].name_value_prefs_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update name_value_prefs_id = ",cnvtstring(request->filters[x].
       name_value_prefs_id)," from name_value_prefs table for column for mean = ",request->filters[x]
      .mean)
     GO TO exit_script
    ENDIF
   ELSEIF ((request->filters[x].action_flag=3))
    DELETE  FROM name_value_prefs nvp
     WHERE (nvp.name_value_prefs_id=request->filters[x].name_value_prefs_id)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to delete name_value_prefs_id = ",cnvtstring(request->filters[x].
       name_value_prefs_id)," from name_value_prefs table for column for mean = ",request->filters[x]
      .mean)
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = error_msg
  CALL echo(error_msg)
 ENDIF
 CALL echorecord(reply)
END GO
