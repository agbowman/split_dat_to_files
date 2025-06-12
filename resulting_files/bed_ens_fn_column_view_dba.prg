CREATE PROGRAM bed_ens_fn_column_view:dba
 FREE SET reply
 RECORD reply(
   1 column_view_id = f8
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
 SET col_cnt = size(request->columns,5)
 DECLARE nvp_parse = vc
 DECLARE col_heading = vc
 SET col_cdf = fillstring(12," ")
 SET custom_value = fillstring(4," ")
 SET col_seq = fillstring(4," ")
 SET col_width = fillstring(4," ")
 SET col_code_value = fillstring(8," ")
 SET reply->column_view_id = request->column_view_id
 IF ((request->action_flag=1))
  SELECT INTO "NL:"
   j = seq(carenet_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    reply->column_view_id = cnvtreal(j)
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO col_cnt)
   IF ((request->columns[x].action_flag=1))
    SET name_value_prefs_id = 0.0
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      name_value_prefs_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET col_detail = fillstring(256," ")
    SET col_detail = concat(trim(request->columns[x].mean),"^",trim(request->columns[x].heading),
     "^0^",trim(cnvtstring(request->columns[x].width)),
     "^",trim(cnvtstring(request->columns[x].sequence,3,0,r)),"^",trim(cnvtstring(request->columns[x]
       .code_value)))
    SET col_name = fillstring(10," ")
    SET col_name = concat("Colinfo",cnvtstring(request->columns[x].sequence,3,0,r))
    INSERT  FROM name_value_prefs nvp
     SET nvp.name_value_prefs_id = name_value_prefs_id, nvp.parent_entity_name = "PREDEFINED_PREFS",
      nvp.parent_entity_id = reply->column_view_id,
      nvp.pvc_name = col_name, nvp.pvc_value = col_detail, nvp.active_ind = 1,
      nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
      nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
       = reqinfo->updt_task,
      nvp.updt_cnt = 1, nvp.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert parent_entity_id = ",cnvtstring(reply->column_view_id),
      " into name_value_prefs table for column ",request->columns[x].heading)
     GO TO exit_script
    ENDIF
   ELSEIF ((request->columns[x].action_flag=2))
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE (nvp.name_value_prefs_id=request->columns[x].name_value_prefs_id)
     DETAIL
      tot_length = size(nvp.pvc_value,1), beg_pos = 1, end_pos = findstring("^",nvp.pvc_value,beg_pos,
       0),
      col_cdf = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1), end_pos
       = findstring("^",nvp.pvc_value,beg_pos,0),
      col_heading = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
      end_pos = findstring("^",nvp.pvc_value,beg_pos,0),
      custom_value = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
      end_pos = findstring("^",nvp.pvc_value,beg_pos,0),
      col_width = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
      end_pos = findstring("^",nvp.pvc_value,beg_pos,0)
      IF (end_pos > 0)
       col_seq = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
       col_code_value = substring(beg_pos,tot_length,nvp.pvc_value)
      ELSE
       col_seq = substring(beg_pos,tot_length,nvp.pvc_value)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to find parent_entity_id = ",cnvtstring(request->column_view_id),
      " into name_value_prefs table for column for mean = ",request->columns[x].mean)
     GO TO exit_script
    ENDIF
    SET col_heading = request->columns[x].heading
    SET col_width = cnvtstring(request->columns[x].width)
    SET col_seq = cnvtstring(request->columns[x].sequence,3,0,r)
    SET col_code_value = cnvtstring(request->columns[x].code_value)
    SET col_detail = fillstring(256," ")
    SET col_detail = concat(trim(col_cdf),"^",trim(col_heading),"^",trim(custom_value),
     "^",trim(col_width),"^",trim(col_seq),"^",
     trim(col_code_value))
    SET col_name = fillstring(10," ")
    SET col_name = concat("Colinfo",cnvtstring(request->columns[x].sequence,3,0,r))
    UPDATE  FROM name_value_prefs nvp
     SET nvp.pvc_value = col_detail, nvp.pvc_name = col_name, nvp.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      nvp.updt_id = reqinfo->updt_id, nvp.updt_task = reqinfo->updt_task, nvp.updt_cnt = (nvp
      .updt_cnt+ 1),
      nvp.updt_applctx = reqinfo->updt_applctx
     WHERE (nvp.name_value_prefs_id=request->columns[x].name_value_prefs_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update parent_entity_id = ",cnvtstring(request->column_view_id
       )," into name_value_prefs table for column for id = ",cnvtstring(request->columns[x].
       name_value_prefs_id))
     GO TO exit_script
    ENDIF
   ELSEIF ((request->columns[x].action_flag=3))
    DELETE  FROM name_value_prefs nvp
     WHERE (nvp.name_value_prefs_id=request->columns[x].name_value_prefs_id)
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
 IF ((request->action_flag != 3))
  SET sort_pvc_value = fillstring(256," ")
  SET nvp_prefs_id = 0.0
  IF ((((request->action_flag=0)) OR ((request->action_flag=2))) )
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE (nvp.parent_entity_id=request->column_view_id)
     AND nvp.pvc_name="ColumnViewInfo"
     AND nvp.active_ind=1
    DETAIL
     nvp_prefs_id = nvp.name_value_prefs_id, beg_pos = 1, end_pos = findstring("^",nvp.pvc_value,
      beg_pos,0),
     beg_pos = (end_pos+ 1), end_pos = findstring("^",nvp.pvc_value,beg_pos,0), sort_pvc_value =
     substring(1,(end_pos - 1),nvp.pvc_value)
    WITH nocounter
   ;end select
  ENDIF
  IF (nvp_prefs_id=0)
   SET sort_pvc_value = "255,255,255^Arial,100,REGULAR"
  ENDIF
  SET slist_cnt = size(request->sort_options,5)
  FOR (i = 1 TO 3)
    IF (i <= slist_cnt)
     SET sort_pvc_value = concat(trim(sort_pvc_value),"^",trim(request->sort_options[i].mean),";",
      trim(cnvtstring(request->sort_options[i].code_value)),
      "^",trim(cnvtstring(request->sort_options[i].sort_option)))
    ELSE
     SET sort_pvc_value = concat(trim(sort_pvc_value),"^NONE;0^1")
    ENDIF
  ENDFOR
  SET sort_pvc_value = concat(trim(sort_pvc_value),"^0")
  IF (nvp_prefs_id > 0)
   UPDATE  FROM name_value_prefs nvp
    SET nvp.pvc_value = sort_pvc_value, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id
      = reqinfo->updt_id,
     nvp.updt_task = reqinfo->updt_task, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_applctx = reqinfo
     ->updt_applctx
    WHERE nvp.name_value_prefs_id=nvp_prefs_id
    WITH nocounter
   ;end update
  ELSE
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = seq(reference_seq,nextval), nvp.parent_entity_name =
     "PREDEFINED_PREFS", nvp.parent_entity_id = reply->column_view_id,
     nvp.pvc_name = "ColumnViewInfo", nvp.pvc_value = sort_pvc_value, nvp.active_ind = 1,
     nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
      = reqinfo->updt_task,
     nvp.updt_cnt = 1, nvp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert parent_entity_id = ",cnvtstring(request->column_view_id),
     " into name_value_prefs table for ColumnViewInfo")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF ((request->action_flag=1))
  CASE (request->list_type)
   OF "TRKBEDLIST":
    SET tab_type = "TRKBEDTYPE"
   OF "LOCATION":
    SET tab_type = "TRKPATTYPE"
   OF "TRKPRVLIST":
    SET tab_type = "TRKPRVTYPE"
   OF "TRKGROUP":
    SET tab_type = "TRKGRPTYPE"
  ENDCASE
  INSERT  FROM predefined_prefs pp
   SET pp.predefined_prefs_id = reply->column_view_id, pp.predefined_type_meaning = tab_type, pp.name
     = request->column_view_name,
    pp.active_ind = 1, pp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pp.updt_id = reqinfo->updt_id,
    pp.updt_task = reqinfo->updt_task, pp.updt_cnt = 0, pp.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = concat("Unable to insert predefined_prefs_id  = ",cnvtstring(request->
     column_view_id)," into predefined_prefs table for filter ",reply->column_view_name)
   GO TO exit_script
  ENDIF
  INSERT  FROM name_value_prefs nvp
   SET nvp.name_value_prefs_id = seq(reference_seq,nextval), nvp.parent_entity_name =
    "PREDEFINED_PREFS", nvp.parent_entity_id = reply->column_view_id,
    nvp.pvc_name = "GroupRowsBy", nvp.pvc_value = " ", nvp.active_ind = 1,
    nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
    nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
    reqinfo->updt_task,
    nvp.updt_cnt = 1, nvp.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = concat("Unable to insert parent_entity_id = ",cnvtstring(request->column_view_id),
    " into name_value_prefs table for GroupRowsBy")
   GO TO exit_script
  ENDIF
  INSERT  FROM name_value_prefs nvp
   SET nvp.name_value_prefs_id = seq(reference_seq,nextval), nvp.parent_entity_name =
    "PREDEFINED_PREFS", nvp.parent_entity_id = reply->column_view_id,
    nvp.pvc_name = "GrouperRowInfo", nvp.pvc_value = " ", nvp.active_ind = 1,
    nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
    nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
    reqinfo->updt_task,
    nvp.updt_cnt = 1, nvp.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = concat("Unable to insert parent_entity_id = ",cnvtstring(request->column_view_id),
    " into name_value_prefs table for GrouperRowInfo")
   GO TO exit_script
  ENDIF
  INSERT  FROM name_value_prefs nvp
   SET nvp.name_value_prefs_id = seq(reference_seq,nextval), nvp.parent_entity_name =
    "PREDEFINED_PREFS", nvp.parent_entity_id = reply->column_view_id,
    nvp.pvc_name = "GrouperClrFontInfo", nvp.pvc_value = "Arial,100,REGULAR^255,255,255^<None>^1",
    nvp.active_ind = 1,
    nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
    nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
    reqinfo->updt_task,
    nvp.updt_cnt = 1, nvp.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = concat("Unable to insert parent_entity_id = ",cnvtstring(request->column_view_id),
    " into name_value_prefs table for GrouperRowInfo")
   GO TO exit_script
  ENDIF
 ELSEIF ((request->action_flag=2))
  UPDATE  FROM predefined_prefs pp
   SET pp.name = request->column_view_name, pp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pp
    .updt_id = reqinfo->updt_id,
    pp.updt_task = reqinfo->updt_task, pp.updt_cnt = (pp.updt_cnt+ 1), pp.updt_applctx = reqinfo->
    updt_applctx
   WHERE (pp.predefined_prefs_id=request->column_view_id)
  ;end update
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = concat("Unable to update column view name for column_view_id = ",cnvtstring(
     request->column_view_id))
   GO TO exit_script
  ENDIF
 ENDIF
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
