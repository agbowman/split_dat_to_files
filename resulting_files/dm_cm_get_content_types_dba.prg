CREATE PROGRAM dm_cm_get_content_types:dba
 FREE RECORD prefix
 RECORD prefix(
   1 cnt = i2
   1 list[*]
     2 name = vc
 )
 DECLARE dcginc_err_msg = vc WITH protect, noconstant("")
 DECLARE dcg_get_prefix(null) = vc
 DECLARE dcg_parse_prefix(v_prefix_list=vc) = null
 DECLARE dcg_add_prefix(v_script_prefix=vc) = vc
 SUBROUTINE dcg_get_prefix(null)
   DECLARE dgp_prefix_list = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="CONTENT_MANAGER"
     AND di.info_name="SCRIPT PREFIX"
    DETAIL
     dgp_prefix_list = di.info_char
    WITH nocounter
   ;end select
   IF (error(dcginc_err_msg,0) > 0)
    RETURN("F")
   ENDIF
   IF (dgp_prefix_list > " ")
    CALL dcg_parse_prefix(dgp_prefix_list)
    IF (error(dcginc_err_msg,0) > 0)
     RETURN("F")
    ENDIF
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE dcg_parse_prefix(s_prefix_list)
   DECLARE s_delim_pos = i4 WITH protect, noconstant(0)
   DECLARE s_prefix_loop = i2 WITH protect, noconstant(0)
   DECLARE s_prefix_found = vc WITH protect, noconstant("")
   DECLARE s_record_pos = i4 WITH protect, noconstant(0)
   SET stat = initrec(prefix)
   WHILE (s_prefix_loop=0)
     SET s_delim_pos = (s_delim_pos+ 1)
     SET s_prefix_found = cnvtupper(piece(s_prefix_list,";;",s_delim_pos,"PREFIX_NOT_FOUND",2))
     IF (s_prefix_found != "PREFIX_NOT_FOUND")
      IF (locateval(s_record_pos,1,prefix->cnt,s_prefix_found,prefix->list[s_record_pos].name)=0
       AND s_prefix_found > " ")
       SET prefix->cnt = (prefix->cnt+ 1)
       SET stat = alterlist(prefix->list,prefix->cnt)
       SET prefix->list[prefix->cnt].name = trim(cnvtupper(s_prefix_found),3)
      ENDIF
     ELSE
      SET s_prefix_loop = 1
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dcg_add_prefix(s_script_prefix)
   DECLARE dap_new_prefix_list = vc WITH protect, noconstant("")
   DECLARE dap_search_pos = i4 WITH protect, noconstant(0)
   DECLARE dap_prefix_loop = i4 WITH protect, noconstant(0)
   SET s_script_prefix = trim(cnvtupper(s_script_prefix),3)
   IF (locateval(dap_search_pos,1,prefix->cnt,s_script_prefix,prefix->list[dap_search_pos].name)=0)
    SET prefix->cnt = (prefix->cnt+ 1)
    SET stat = alterlist(prefix->list,prefix->cnt)
    SET prefix->list[prefix->cnt].name = s_script_prefix
    FOR (dap_prefix_loop = 1 TO prefix->cnt)
      IF (dap_prefix_loop > 1)
       SET dap_new_prefix_list = concat(dap_new_prefix_list,";;",prefix->list[dap_prefix_loop].name)
      ELSE
       SET dap_new_prefix_list = prefix->list[dap_prefix_loop].name
      ENDIF
    ENDFOR
    UPDATE  FROM dm_info di
     SET di.info_char = dap_new_prefix_list
     WHERE di.info_domain="CONTENT_MANAGER"
      AND di.info_name="SCRIPT PREFIX"
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM dm_info di
      SET di.info_char = dap_new_prefix_list, di.info_domain = "CONTENT_MANAGER", di.info_name =
       "SCRIPT PREFIX"
      WITH nocounter
     ;end insert
    ENDIF
    IF (error(dcginc_err_msg,0) > 0)
     ROLLBACK
     RETURN("F")
    ENDIF
    COMMIT
   ENDIF
   RETURN("S")
 END ;Subroutine
 FREE RECORD reply
 RECORD reply(
   1 batch_size_lower_limit = i4
   1 batch_size_upper_limit = i4
   1 list[*]
     2 content_type = vc
     2 import_script_name = vc
     2 import_log_file = vc
     2 export_script_name = vc
     2 export_log_file = vc
     2 operation_type = vc
     2 help_type = vc
     2 long_pk_id = f8
     2 allow_update_ind = i2
     2 audit_mode_ind = i2
     2 col_header_line = i4
     2 first_data_line = i4
     2 batch_size = i4
     2 column_names = vc
     2 category_name = vc
     2 status_str_name = vc
     2 status_msg_name = vc
     2 csv_file_name = vc
   1 status = vc
   1 message = vc
 )
 DECLARE dcg_content_type_cnt = i4 WITH protect, noconstant(0)
 DECLARE dcg_for_cnt = i2 WITH protect, noconstant(0)
 DECLARE dcg_err_msg = vc WITH protect, noconstant("")
 DECLARE dcg_err_cd = i4 WITH protect, noconstant(0)
 DECLARE dcg_batch_size_lower_limit = i4 WITH protect, noconstant(1)
 DECLARE dcg_batch_size_upper_limit = i4 WITH protect, noconstant(100000)
 DECLARE dcg_prefix_default_imp = vc WITH protect, constant("cntmgr_imp")
 DECLARE dcg_prefix_default_exp = vc WITH protect, constant("cntmgr_exp")
 DECLARE dcg_prefix_ctp = vc WITH protect, constant("ctpauto")
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CONTENT_MANAGER"
   AND di.info_name IN ("BATCH_SIZE_LOWER_LIMIT", "BATCH_SIZE_UPPER_LIMIT")
  DETAIL
   IF (di.info_name="BATCH_SIZE_LOWER_LIMIT")
    dcg_batch_size_lower_limit = di.info_number
   ELSEIF (di.info_name="BATCH_SIZE_UPPER_LIMIT")
    dcg_batch_size_upper_limit = di.info_number
   ENDIF
  WITH nocounter
 ;end select
 IF (dcg_get_prefix(null)="F")
  SET dcg_err_cd = error(dcg_err_msg,0)
  SET reply->status = "F"
  SET reply->message = dcg_err_msg
  GO TO exit_script
 ENDIF
 IF (((dcg_add_prefix(dcg_prefix_default_imp)="F") OR (dcg_add_prefix(dcg_prefix_default_exp)="F")) )
  SET dcg_err_cd = error(dcg_err_msg,1)
  SET reply->status = "F"
  SET reply->message = dcg_err_msg
  GO TO exit_script
 ENDIF
 IF (dcg_add_prefix(dcg_prefix_ctp)="F")
  SET dcg_err_cd = error(dcg_err_msg,1)
  SET reply->status = "F"
  SET reply->message = dcg_err_msg
  GO TO exit_script
 ENDIF
 FOR (dcg_for_cnt = 1 TO prefix->cnt)
  EXECUTE dm_cm_pull_metadata value(prefix->list[dcg_for_cnt].name)
  IF (error(dcg_err_msg,1) > 0)
   SET reply->status = "F"
   SET reply->message = dcg_err_msg
   GO TO exit_script
  ENDIF
 ENDFOR
 SET reply->batch_size_lower_limit = dcg_batch_size_lower_limit
 SET reply->batch_size_upper_limit = dcg_batch_size_upper_limit
 SELECT INTO "nl:"
  prgcheck = checkprg(cnvtupper(cv.description))
  FROM code_value cv,
   code_value_extension cve,
   dm_prefs dmp
  PLAN (cv
   WHERE cv.code_set=4148001
    AND cv.active_ind=1)
   JOIN (cve
   WHERE cv.code_value=cve.code_value)
   JOIN (dmp
   WHERE outerjoin(cv.description)=dmp.pref_section
    AND dmp.pref_domain=outerjoin("CONTENT MANAGER"))
  ORDER BY cv.display_key
  HEAD cv.display_key
   IF (prgcheck > 0)
    dcg_content_type_cnt = (dcg_content_type_cnt+ 1), stat = alterlist(reply->list,
     dcg_content_type_cnt), reply->list[dcg_content_type_cnt].content_type = cv.display
   ENDIF
  DETAIL
   IF (prgcheck > 0)
    CASE (cve.field_name)
     OF "ALLOW_UPDATE_IND":
      reply->list[dcg_content_type_cnt].allow_update_ind = cnvtint(cve.field_value)
     OF "AUDIT_MODE_IND":
      reply->list[dcg_content_type_cnt].audit_mode_ind = cnvtint(cve.field_value)
     OF "BATCH_SIZE":
      reply->list[dcg_content_type_cnt].batch_size = cnvtint(cve.field_value)
     OF "CATEGORY_NAME":
      reply->list[dcg_content_type_cnt].category_name = cve.field_value
     OF "OPERATION_TYPE":
      reply->list[dcg_content_type_cnt].operation_type = cve.field_value
     OF "HELP_TYPE":
      reply->list[dcg_content_type_cnt].help_type = cve.field_value
     OF "COLUMN_NAMES":
      reply->list[dcg_content_type_cnt].column_names = cve.field_value
     OF "COL_HEADER_LINE":
      reply->list[dcg_content_type_cnt].col_header_line = cnvtint(cve.field_value)
     OF "FIRST_DATA_LINE":
      reply->list[dcg_content_type_cnt].first_data_line = cnvtint(cve.field_value)
     OF "CSV_FILE_NAME":
      reply->list[dcg_content_type_cnt].csv_file_name = cve.field_value
     OF "STATUS_STR_NAME":
      reply->list[dcg_content_type_cnt].status_str_name = cve.field_value
     OF "STATUS_MSG_NAME":
      reply->list[dcg_content_type_cnt].status_msg_name = cve.field_value
    ENDCASE
    CASE (dmp.pref_name)
     OF "HELP_TEXT":
      IF (dmp.parent_entity_name="LONG_TEXT_REFERENCE")
       reply->list[dcg_content_type_cnt].long_pk_id = dmp.parent_entity_id
      ENDIF
    ENDCASE
   ENDIF
  FOOT  cv.display_key
   IF (prgcheck > 0)
    IF ((reply->list[dcg_content_type_cnt].operation_type="IMPORT"))
     reply->list[dcg_content_type_cnt].import_script_name = cv.description, reply->list[
     dcg_content_type_cnt].import_log_file = cv.definition
    ELSE
     reply->list[dcg_content_type_cnt].export_script_name = cv.description, reply->list[
     dcg_content_type_cnt].export_log_file = cv.definition
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (error(dcg_err_msg,1) > 0)
  SET reply->status = "F"
  SET reply->message = dcg_err_msg
  GO TO exit_script
 ENDIF
 SET reply->status = "S"
 SET reply->message = "SUCCESS: all custom content data retrieved"
#exit_script
END GO
