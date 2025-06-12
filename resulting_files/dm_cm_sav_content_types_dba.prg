CREATE PROGRAM dm_cm_sav_content_types:dba
 DECLARE daf_is_blank(dib_str=vc) = i2
 DECLARE daf_is_not_blank(dinb_str=vc) = i2
 SUBROUTINE daf_is_blank(dib_str)
  IF (textlen(trim(dib_str,3)) > 0)
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE daf_is_not_blank(dinb_str)
  IF (textlen(trim(dinb_str,3)) > 0)
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 IF ( NOT (validate(request)))
  FREE RECORD request
  RECORD request(
    1 qual[*]
      2 content_type = vc
      2 import_script_name = vc
      2 import_log_file = vc
      2 export_script_name = vc
      2 export_log_file = vc
      2 operation_type = vc
      2 help_type = vc
      2 help_text = vc
      2 allow_update_ind = i2
      2 audit_mode_ind = i2
      2 col_header_line = i4
      2 first_data_line = i4
      2 batch_size = i4
      2 column_names = vc
      2 csv_file_name = vc
      2 category_name = vc
      2 status_str_name = vc
      2 status_msg_name = vc
  )
 ENDIF
 DECLARE maintain_cve(v_field_name=vc,v_field_value=vc,v_cm_code_value=f8) = null
 DECLARE s_insert_cve(v_i_field_name=vc,v_i_field_value=vc,v_i_cm_code_value=f8) = null
 DECLARE s_update_cve(v_u_field_name=vc,v_u_field_value=vc,v_u_cm_code_value=f8) = null
 DECLARE maintain_code_value(v_req=vc(ref),v_op_type=vc) = f8
 DECLARE s_insert_code_value(v_req=vc(ref),v_op_type=vc) = f8
 DECLARE s_update_code_value(v_code_value=f8,v_u_cntnt_req=vc(ref),v_op_type=vc) = null
 DECLARE s_insert_ltr(v_i_field_value=vc,v_dmpref_id=f8) = f8
 DECLARE s_update_ltr(v_u_field_value=vc,v_u_long_text_id=f8) = null
 DECLARE s_delete_ltr(v_d_long_text_id=f8,v_dmpref_id=f8) = null
 DECLARE maintain_dmprefs(v_pref_section=vc,v_pref_name=vc,v_pref_cd=f8,v_pref_value=vc) = null
 DECLARE s_update_dmpref(v_pref_section=vc,v_pref_name=vc,v_pref_cd=f8) = null
 DECLARE s_insert_dmpref(v_pref_section=vc,v_pref_name=vc,v_pref_cd=f8) = f8
 DECLARE dcs_code_value = f8 WITH protect, noconstant(0.0)
 DECLARE dcs_batch_lower_ind = i2 WITH protect, noconstant(0)
 DECLARE dcs_batch_upper_ind = i2 WITH protect, noconstant(0)
 DECLARE dcs_err_msg = vc WITH protect, noconstant("")
 DECLARE dcs_batch_size_lower_limit = i4 WITH protect, noconstant(1)
 DECLARE dcs_batch_size_upper_limit = i4 WITH protect, noconstant(100000)
 DECLARE dcs_col_header = i4 WITH protect, noconstant(0)
 DECLARE dcs_first_data_line = i4 WITH protect, noconstant(0)
 DECLARE dcs_audit_mode = i2 WITH protect, noconstant(0)
 DECLARE dcs_allow_update = i2 WITH protect, noconstant(0)
 DECLARE dcs_status_str = vc WITH protect, noconstant("")
 DECLARE dcs_status_msg = vc WITH protect, noconstant("")
 DECLARE dcs_code_set = i4 WITH protect, constant(4148001)
 DECLARE dcs_operation_type = vc WITH protect, noconstant("")
 DECLARE dcs_help_text = vc WITH protect, noconstant("")
 DECLARE dcs_help_type = vc WITH protect, noconstant("")
 DECLARE dcs_script_name = vc WITH protect, noconstant("")
 DECLARE dcs_log_file = vc WITH protect, noconstant("")
 DECLARE dcs_script_date = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 IF (size(request->qual,5) != 1)
  GO TO exit_program
 ENDIF
 SET dcs_col_header = evaluate(request->qual[1].col_header_line,0,1,request->qual[1].col_header_line)
 SET dcs_first_data_line = evaluate(request->qual[1].first_data_line,0,2,request->qual[1].
  first_data_line)
 SET dcs_audit_mode = evaluate(request->qual[1].audit_mode_ind,1,1,0)
 SET dcs_allow_update = evaluate(request->qual[1].allow_update_ind,1,1,0)
 IF (daf_is_not_blank(request->qual[1].status_str_name))
  SET dcs_status_str = request->qual[1].status_str_name
 ELSE
  SET dcs_status_str = "STATUS_STR"
 ENDIF
 IF (daf_is_not_blank(request->qual[1].status_msg_name))
  SET dcs_status_msg = request->qual[1].status_msg_name
 ELSE
  SET dcs_status_msg = "STATUS_MSG"
 ENDIF
 IF (validate(request->qual[1].help_type,"NotExists")="NotExists")
  SET dcs_help_type = "NONE"
  SET dcs_help_text = "0"
 ELSEIF (daf_is_not_blank(request->qual[1].help_type)
  AND daf_is_not_blank(request->qual[1].help_text))
  SET dcs_help_type = request->qual[1].help_type
  SET dcs_help_text = request->qual[1].help_text
 ELSE
  SET dcs_help_type = "NONE"
  SET dcs_help_text = "0"
 ENDIF
 IF (daf_is_not_blank(request->qual[1].operation_type))
  SET dcs_operation_type = request->qual[1].operation_type
 ELSE
  SET dcs_operation_type = "IMPORT"
 ENDIF
 IF (dcs_operation_type="IMPORT")
  SET dcs_script_name = request->qual[1].import_script_name
 ELSE
  SET dcs_script_name = request->qual[1].export_script_name
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CONTENT_MANAGER"
   AND di.info_name IN ("BATCH_SIZE_LOWER_LIMIT", "BATCH_SIZE_UPPER_LIMIT")
  DETAIL
   IF (di.info_name="BATCH_SIZE_LOWER_LIMIT")
    dcs_batch_size_lower_limit = di.info_number, dcs_batch_lower_ind = 1
   ELSEIF (di.info_name="BATCH_SIZE_UPPER_LIMIT")
    dcs_batch_size_upper_limit = di.info_number, dcs_batch_upper_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (dcs_batch_lower_ind=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CONTENT_MANAGER", di.info_name = "BATCH_SIZE_LOWER_LIMIT", di.info_number =
    dcs_batch_size_lower_limit,
    di.updt_cnt = 0, di.updt_task = reqinfo->updt_task, di.updt_applctx = reqinfo->updt_applctx,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
 ENDIF
 IF (dcs_batch_upper_ind=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CONTENT_MANAGER", di.info_name = "BATCH_SIZE_UPPER_LIMIT", di.info_number =
    dcs_batch_size_upper_limit,
    di.updt_cnt = 0, di.updt_task = reqinfo->updt_task, di.updt_applctx = reqinfo->updt_applctx,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
 ENDIF
 SET dcs_code_value = maintain_code_value(request,dcs_operation_type)
 CALL maintain_cve("COL_HEADER_LINE",cnvtstring(dcs_col_header),dcs_code_value)
 CALL maintain_cve("FIRST_DATA_LINE",cnvtstring(dcs_first_data_line),dcs_code_value)
 CALL maintain_cve("COLUMN_NAMES",request->qual[1].column_names,dcs_code_value)
 CALL maintain_cve("ALLOW_UPDATE_IND",cnvtstring(dcs_allow_update),dcs_code_value)
 CALL maintain_cve("AUDIT_MODE_IND",cnvtstring(dcs_audit_mode),dcs_code_value)
 CALL maintain_cve("CSV_FILE_NAME",request->qual[1].csv_file_name,dcs_code_value)
 CALL maintain_cve("CATEGORY_NAME",request->qual[1].category_name,dcs_code_value)
 CALL maintain_cve("OPERATION_TYPE",dcs_operation_type,dcs_code_value)
 CALL maintain_cve("HELP_TYPE",dcs_help_type,dcs_code_value)
 CALL maintain_dmprefs(dcs_script_name,"HELP_TEXT",dcs_code_value,dcs_help_text)
 CALL maintain_cve("STATUS_STR_NAME",dcs_status_str,dcs_code_value)
 CALL maintain_cve("STATUS_MSG_NAME",dcs_status_msg,dcs_code_value)
 IF ((request->qual[1].batch_size BETWEEN dcs_batch_size_lower_limit AND dcs_batch_size_upper_limit))
  CALL maintain_cve("BATCH_SIZE",cnvtstring(request->qual[1].batch_size,20,0),dcs_code_value)
 ELSE
  CALL maintain_cve("BATCH_SIZE","50000",dcs_code_value)
 ENDIF
 SELECT INTO "nl:"
  dp.object_name, min(dp.group)
  FROM dprotect dp
  WHERE dp.object="P"
   AND dp.object_name=cnvtupper(dcs_script_name)
  DETAIL
   dcs_script_date = cnvtdatetimeutc(cnvtdatetime(dp.datestamp,dp.timestamp),3)
  WITH nocounter
 ;end select
 IF (error(dcs_err_msg,1) > 0)
  ROLLBACK
  GO TO exit_program
 ENDIF
 UPDATE  FROM dm_info di
  SET di.info_date = cnvtdatetimeutc(dcs_script_date,0), di.updt_cnt = (di.updt_cnt+ 1), di.updt_task
    = reqinfo->updt_task,
   di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di
   .updt_id = reqinfo->updt_id
  WHERE di.info_domain="CONTENT MANAGER IMPORT SCRIPT DATE"
   AND di.info_name=cnvtupper(dcs_script_name)
  WITH nocounter
 ;end update
 IF (error(dcs_err_msg,1) > 0)
  ROLLBACK
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CONTENT MANAGER IMPORT SCRIPT DATE", di.info_name = cnvtupper(
     dcs_script_name), di.info_date = cnvtdatetimeutc(dcs_script_date,0),
    di.updt_cnt = 0, di.updt_task = reqinfo->updt_task, di.updt_applctx = reqinfo->updt_applctx,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
 ENDIF
 IF (error(dcs_err_msg,1) > 0)
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 SUBROUTINE maintain_code_value(v_cntnt_req,v_op_type)
   DECLARE s_code_value = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=dcs_code_set
     AND cv.display_key=cnvtalphanum(cnvtupper(v_cntnt_req->qual[1].content_type))
    DETAIL
     s_code_value = cv.code_value
    WITH nocounter
   ;end select
   IF (s_code_value=0)
    SET s_code_value = s_insert_code_value(v_cntnt_req,v_op_type)
   ELSE
    CALL s_update_code_value(s_code_value,v_cntnt_req,v_op_type)
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 SUBROUTINE s_insert_code_value(v_i_cntnt_req,v_op_type)
   DECLARE s_new_code_value = f8 WITH protect, noconstant(0.0)
   DECLARE s_script_name = vc WITH protect, noconstant("")
   DECLARE s_log_file = vc WITH protect, noconstant("")
   IF (v_op_type="IMPORT")
    SET s_script_name = v_i_cntnt_req->qual[1].import_script_name
    IF (daf_is_not_blank(v_i_cntnt_req->qual[1].import_log_file))
     SET s_log_file = v_i_cntnt_req->qual[1].import_log_file
    ELSE
     SET s_log_file = "LOGFILENOTSET"
    ENDIF
   ELSE
    SET s_script_name = v_i_cntnt_req->qual[1].export_script_name
    IF (daf_is_not_blank(v_i_cntnt_req->qual[1].export_log_file))
     SET s_log_file = v_i_cntnt_req->qual[1].export_log_file
    ELSE
     SET s_log_file = "LOGFILENOTSET"
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    s_nextseqnum = seq(reference_seq,nextval)"#################;rp0"
    FROM dual
    DETAIL
     s_new_code_value = cnvtreal(s_nextseqnum)
    WITH format
   ;end select
   INSERT  FROM code_value cv
    SET cv.code_set = dcs_code_set, cv.code_value = s_new_code_value, cv.display = v_i_cntnt_req->
     qual[1].content_type,
     cv.display_key = cnvtalphanum(cnvtupper(v_i_cntnt_req->qual[1].content_type)), cv.description =
     s_script_name, cv.definition = evaluate(s_log_file,"LOGFILENOTSET",null,s_log_file),
     cv.active_ind = 1, cv.updt_cnt = 0, cv.updt_task = reqinfo->updt_task,
     cv.updt_applctx = reqinfo->updt_applctx, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv
     .updt_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (error(dcs_err_msg,1) > 0)
    ROLLBACK
    GO TO exit_program
   ENDIF
   RETURN(s_new_code_value)
 END ;Subroutine
 SUBROUTINE s_update_code_value(v_code_value,v_u_cntnt_req,v_op_type)
   DECLARE s_script_name = vc WITH protect, noconstant("")
   DECLARE s_log_file = vc WITH protect, noconstant("")
   IF (v_op_type="IMPORT")
    SET s_script_name = v_u_cntnt_req->qual[1].import_script_name
    IF (daf_is_not_blank(v_u_cntnt_req->qual[1].import_log_file))
     SET s_log_file = v_u_cntnt_req->qual[1].import_log_file
    ELSE
     SET s_log_file = "LOGFILENOTSET"
    ENDIF
   ELSE
    SET s_script_name = v_u_cntnt_req->qual[1].export_script_name
    IF (daf_is_not_blank(v_u_cntnt_req->qual[1].export_log_file))
     SET s_log_file = v_u_cntnt_req->qual[1].export_log_file
    ELSE
     SET s_log_file = "LOGFILENOTSET"
    ENDIF
   ENDIF
   UPDATE  FROM code_value cv
    SET cv.display = v_u_cntnt_req->qual[1].content_type, cv.display_key = cnvtalphanum(cnvtupper(
       v_u_cntnt_req->qual[1].content_type)), cv.description = s_script_name,
     cv.definition = evaluate(s_log_file,"LOGFILENOTSET",null,s_log_file), cv.active_ind = 1, cv
     .updt_cnt = (cv.updt_cnt+ 1),
     cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     cv.updt_id = reqinfo->updt_id
    WHERE cv.code_set=dcs_code_set
     AND cv.code_value=v_code_value
    WITH nocounter
   ;end update
   IF (error(dcs_err_msg,1) > 0)
    ROLLBACK
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE maintain_cve(v_field_name,v_field_value,v_cm_code_value)
  SELECT INTO "nl:"
   FROM code_value_extension cve
   WHERE cve.code_value=v_cm_code_value
    AND cve.field_name=v_field_name
    AND cve.code_set=dcs_code_set
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL s_insert_cve(v_field_name,v_field_value,v_cm_code_value)
  ELSE
   CALL s_update_cve(v_field_name,v_field_value,v_cm_code_value)
  ENDIF
 END ;Subroutine
 SUBROUTINE s_insert_cve(v_i_field_name,v_i_field_value,v_i_cm_code_value)
  INSERT  FROM code_value_extension cve
   SET cve.code_value = v_i_cm_code_value, cve.field_name = v_i_field_name, cve.code_set =
    dcs_code_set,
    cve.field_type = 1, cve.field_value = v_i_field_value, cve.updt_cnt = 0,
    cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo->updt_applctx, cve.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    cve.updt_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (error(dcs_err_msg,1) > 0)
   ROLLBACK
   GO TO exit_program
  ENDIF
 END ;Subroutine
 SUBROUTINE s_update_cve(v_u_field_name,v_u_field_value,v_u_cm_code_value)
  UPDATE  FROM code_value_extension cve
   SET cve.field_value = v_u_field_value, cve.updt_cnt = (cve.updt_cnt+ 1), cve.updt_task = reqinfo->
    updt_task,
    cve.updt_applctx = reqinfo->updt_applctx, cve.updt_dt_tm = cnvtdatetime(curdate,curtime3), cve
    .updt_id = reqinfo->updt_id
   WHERE cve.code_value=v_u_cm_code_value
    AND cve.field_name=v_u_field_name
    AND cve.code_set=dcs_code_set
   WITH nocounter
  ;end update
  IF (error(dcs_err_msg,1) > 0)
   ROLLBACK
   GO TO exit_program
  ENDIF
 END ;Subroutine
 SUBROUTINE maintain_dmprefs(v_pref_section,v_pref_name,v_pref_cd,v_pref_value)
   DECLARE s_dmpref_id = f8 WITH protect, noconstant(0.0)
   DECLARE s_pref_ltr_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM dm_prefs dmp
    WHERE dmp.pref_domain="CONTENT MANAGER"
     AND dmp.pref_section=v_pref_section
     AND dmp.pref_name=v_pref_name
    DETAIL
     s_dmpref_id = dmp.pref_id
     IF (dmp.parent_entity_name="LONG_TEXT_REFERENCE")
      s_pref_ltr_id = dmp.parent_entity_id
     ENDIF
    WITH nocounter
   ;end select
   IF (s_dmpref_id=0)
    SET s_dmpref_id = s_insert_dmpref(v_pref_section,v_pref_name,v_pref_cd)
    IF (v_pref_value != "0")
     SET s_pref_ltr_id = s_insert_ltr(v_pref_value,s_dmpref_id)
    ENDIF
   ELSE
    CALL s_update_dmpref(s_dmpref_id,v_pref_cd)
    IF (s_pref_ltr_id > 0
     AND v_pref_value="0")
     CALL s_delete_ltr(s_pref_ltr_id,s_dmpref_id)
    ELSEIF (s_pref_ltr_id > 0
     AND v_pref_value != "0")
     CALL s_update_ltr(v_pref_value,s_pref_ltr_id)
    ELSEIF (s_pref_ltr_id=0
     AND v_pref_value != "0")
     SET s_pref_ltr_id = s_insert_ltr(v_pref_value,s_dmpref_id)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE s_insert_dmpref(v_pref_section,v_pref_name,v_pref_cd)
   DECLARE s_new_dmpref_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    s_nextseqnum = seq(dm_clinical_seq,nextval)"#################;rp0"
    FROM dual
    DETAIL
     s_new_dmpref_id = cnvtreal(s_nextseqnum)
    WITH format
   ;end select
   IF (((error(dcs_err_msg,1) > 0) OR (s_new_dmpref_id=0.0)) )
    ROLLBACK
    GO TO exit_program
   ENDIF
   INSERT  FROM dm_prefs dmp
    SET dmp.pref_id = s_new_dmpref_id, dmp.pref_domain = "CONTENT MANAGER", dmp.pref_section =
     v_pref_section,
     dmp.pref_name = v_pref_name, dmp.updt_cnt = 0, dmp.updt_task = reqinfo->updt_task,
     dmp.updt_applctx = 0, dmp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dmp.updt_id = reqinfo->
     updt_id
    WITH nocounter
   ;end insert
   IF (error(dcs_err_msg,1) > 0)
    ROLLBACK
    GO TO exit_program
   ELSE
    RETURN(s_new_dmpref_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE s_update_dmpref(v_pref_id,v_pref_cd)
  UPDATE  FROM dm_prefs dmp
   SET dmp.pref_cd = v_pref_cd, dmp.updt_cnt = (dmp.updt_cnt+ 1), dmp.updt_task = reqinfo->updt_task,
    dmp.updt_applctx = 0.0, dmp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dmp.updt_id = reqinfo->
    updt_id
   WHERE dmp.pref_id=v_pref_id
   WITH nocounter
  ;end update
  IF (error(dcs_err_msg,1) > 0)
   ROLLBACK
   GO TO exit_program
  ENDIF
 END ;Subroutine
 SUBROUTINE s_update_ltr(v_u_field_value,v_u_long_text_id)
   DECLARE s_ltr_id = f8 WITH protect, noconstant(0)
   UPDATE  FROM long_text_reference ltr
    SET ltr.long_text = v_u_field_value, ltr.updt_cnt = (ltr.updt_cnt+ 1), ltr.updt_task = reqinfo->
     updt_task,
     ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ltr
     .updt_id = reqinfo->updt_id
    WHERE ltr.long_text_id=v_u_long_text_id
    WITH nocounter
   ;end update
   IF (error(dcs_err_msg,1) > 0)
    ROLLBACK
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE s_insert_ltr(v_i_field_value,v_dmpref_id)
   DECLARE s_ltr_id = f8 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    y = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     s_ltr_id = y
    WITH nocounter
   ;end select
   IF (error(dcs_err_msg,1) > 0)
    ROLLBACK
    GO TO exit_program
   ENDIF
   INSERT  FROM long_text_reference ltr
    SET ltr.long_text_id = s_ltr_id, ltr.parent_entity_id = v_dmpref_id, ltr.parent_entity_name =
     "DM_PREFS",
     ltr.long_text = v_i_field_value, ltr.updt_cnt = 0, ltr.updt_task = reqinfo->updt_task,
     ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ltr
     .updt_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (error(dcs_err_msg,1) > 0)
    ROLLBACK
    GO TO exit_program
   ENDIF
   UPDATE  FROM dm_prefs dmp
    SET dmp.parent_entity_name = "LONG_TEXT_REFERENCE", dmp.parent_entity_id = s_ltr_id
    WHERE dmp.pref_id=v_dmpref_id
    WITH nocounter
   ;end update
   IF (error(dcs_err_msg,1) > 0)
    ROLLBACK
    GO TO exit_program
   ELSE
    RETURN(s_ltr_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE s_delete_ltr(v_d_long_text_id,v_dmpref_id)
   DELETE  FROM long_text_reference ltr
    WHERE ltr.long_text_id=v_d_long_text_id
    WITH nocounter
   ;end delete
   IF (error(dcs_err_msg,1) > 0)
    ROLLBACK
    GO TO exit_program
   ENDIF
   UPDATE  FROM dm_prefs dmp
    SET dmp.parent_entity_name = null, dmp.parent_entity_id = 0.0
    WHERE dmp.pref_id=v_dmpref_id
    WITH nocounter
   ;end update
   IF (error(dcs_err_msg,1) > 0)
    ROLLBACK
    GO TO exit_program
   ENDIF
 END ;Subroutine
#exit_program
END GO
