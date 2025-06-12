CREATE PROGRAM dm_txtfnd_csv_load:dba
 IF ((validate(script_rec->script_cnt,- (1))=- (1))
  AND (validate(script_rec->long_cnt,- (1))=- (1))
  AND (validate(script_rec->dm_text_find_detail_id,- (1.0))=- (1.0)))
  FREE RECORD script_rec
  RECORD script_rec(
    1 dm_text_find_log_id = f8
    1 dm_text_find_detail_id = f8
    1 script_cnt = i4
    1 script_qual[*]
      2 script_name = vc
      2 path = vc
      2 compile_dt_tm = f8
      2 object_type = vc
      2 group_num = i4
      2 user_name = vc
      2 attribute_desc = vc
      2 not_new_ind = i2
      2 data_source = vc
    1 long_cnt = i4
    1 long_qual[*]
      2 parent_entity_name = vc
      2 parent_entity_id = f8
      2 parent_entity_col = vc
      2 search_col_name = vc
      2 attribute_desc = vc
      2 data_source = vc
      2 compile_dt_tm = f8
  )
 ENDIF
 IF ((validate(dtg->cnt,- (1))=- (1)))
  FREE RECORD dtg
  RECORD dtg(
    1 cnt = i4
    1 qual[*]
      2 s_name = vc
      2 pe_name = vc
      2 pe_id = f8
      2 pe_col = vc
      2 srch_col = vc
      2 compile_dt_tm = f8
      2 group_num = i4
      2 desc = vc
      2 data_source = vc
      2 att_cnt = i4
      2 att_qual[*]
        3 tab_name = vc
        3 col_name = vc
        3 col_val = vc
        3 col_txt = vc
  )
 ENDIF
 SET modify maxvarlen 268435456
 DECLARE remove_lock(i_info_domain=vc,i_info_name=vc,i_info_char=vc,io_reply=vc(ref)) = null
 DECLARE check_lock(i_info_domain=vc,i_info_name=vc,io_reply=vc(ref)) = null
 DECLARE get_lock(i_info_domain=vc,i_info_name=vc,i_retry_limit=i2,io_reply=vc(ref)) = null
 IF ((validate(drl_request->retry_flag,- (1))=- (1)))
  FREE RECORD drl_request
  RECORD drl_request(
    1 info_domain = vc
    1 info_name = vc
    1 info_char = vc
    1 info_number = f8
    1 retry_flag = i2
  )
  FREE RECORD drl_reply
  RECORD drl_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 SUBROUTINE remove_lock(i_info_domain,i_info_name,i_info_char,io_reply)
  DELETE  FROM dm_info di
   WHERE di.info_domain=i_info_domain
    AND di.info_name=i_info_name
    AND di.info_char=i_info_char
   WITH nocounter
  ;end delete
  IF (check_error("Deleting in-process row from dm_info") != 0)
   SET io_reply->status = "F"
   SET io_reply->status_msg = dm_err->emsg
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE check_lock(i_info_domain,i_info_name,io_reply)
   DECLARE s_info_char = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    rdbhandle = trim(di.info_char)
    FROM dm_info di
    WHERE di.info_domain=i_info_domain
     AND di.info_name=i_info_name
    DETAIL
     s_info_char = rdbhandle
    WITH nocounter
   ;end select
   IF (check_error("Retrieving in-process from from dm_info") != 0)
    SET io_reply->status = "F"
    SET io_reply->status_msg = dm_err->emsg
    RETURN
   ENDIF
   IF (s_info_char > ""
    AND s_info_char != currdbhandle)
    SELECT INTO "nl:"
     FROM gv$session s
     WHERE s.audsid=cnvtreal(s_info_char)
     WITH nocounter
    ;end select
    IF (check_error("Retrieving session id from gv$session") != 0)
     SET io_reply->status = "F"
     SET io_reply->status_msg = dm_err->emsg
     RETURN
    ENDIF
    IF (curqual=0)
     CALL remove_lock(i_info_domain,i_info_name,s_info_char,io_reply)
    ELSE
     SET io_reply->status = "Z"
     SET io_reply->status_msg = "Another active session has the required lock."
    ENDIF
   ELSEIF (s_info_char=currdbhandle)
    SET io_reply->status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE get_lock(i_info_domain,i_info_name,i_retry_limit,io_reply)
   DECLARE s_retry_cnt = i2 WITH protect, noconstant(0)
   DECLARE s_retry_limit = i2 WITH protect, noconstant(i_retry_limit)
   IF (s_retry_limit <= 0)
    SET s_retry_limit = 3
   ENDIF
   SET io_reply->status = ""
   SET io_reply->status_msg = ""
   CALL check_lock(i_info_domain,i_info_name,io_reply)
   IF ((io_reply->status=""))
    FOR (s_retry_cnt = 1 TO s_retry_limit)
     INSERT  FROM dm_info di
      SET di.info_domain = i_info_domain, di.info_name = i_info_name, di.info_char = currdbhandle
      WITH nocounter
     ;end insert
     IF (check_error("Inserting lock creation row...") != 0)
      IF (findstring("ORA-00001",dm_err->emsg,1,0) > 0)
       SET dm_err->err_ind = 0
       CALL check_lock(i_info_domain,i_info_name,io_reply)
       IF ((io_reply->status="F"))
        SET io_reply->status_msg = dm_err->emsg
        SET s_retry_cnt = s_retry_limit
       ELSEIF ((io_reply->status="Z"))
        SET s_retry_cnt = s_retry_limit
       ELSE
        SET io_reply->status = "F"
        SET io_reply->status_msg = dm_err->emsg
        SET dm_err->err_ind = 0
       ENDIF
      ELSE
       ROLLBACK
       SET io_reply->status = "F"
       SET io_reply->status_msg = dm_err->emsg
       SET s_retry_cnt = s_retry_limit
      ENDIF
     ELSE
      COMMIT
      SET io_reply->status = "S"
      SET io_reply->status_msg = ""
      SET s_retry_cnt = s_retry_limit
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 DECLARE parse_string(i_string=vc,i_string_delim=vc,io_string_rs=vc(ref)) = null
 DECLARE encode_html_string(io_string=vc) = vc
 DECLARE copy_xsl(i_template_name=vc,i_file_name=vc) = i2
 DECLARE dmda_get_file_name(i_env_id=f8,i_env_name=vc,i_mnu_hdg=vc,i_default_name=vc,i_file_xtn=vc,
  i_type=vc) = vc
 SUBROUTINE parse_string(i_string,i_string_delim,io_string_rs)
   DECLARE ps_delim_len = i4 WITH protect, noconstant(size(i_string_delim))
   DECLARE ps_str_len = i4 WITH protect, noconstant(size(i_string))
   DECLARE ps_start = i4 WITH protect, noconstant(1)
   DECLARE ps_pos = i4 WITH protect, noconstant(0)
   DECLARE ps_num_found = i4 WITH protect, noconstant(0)
   DECLARE ps_idx = i4 WITH protect, noconstant(0)
   DECLARE ps_loop = i4 WITH protect, noconstant(0)
   DECLARE ps_temp_string = vc WITH protect, noconstant("")
   SET ps_pos = findstring(i_string_delim,i_string,ps_start)
   SET ps_num_found = size(io_string_rs->qual,5)
   WHILE (ps_pos > 0)
     SET ps_num_found = (ps_num_found+ 1)
     SET ps_temp_string = substring(ps_start,(ps_pos - ps_start),i_string)
     IF (ps_num_found > 1)
      SET ps_idx = locateval(ps_loop,1,(ps_num_found - 1),ps_temp_string,io_string_rs->qual[ps_loop].
       values)
     ELSE
      SET ps_idx = 0
     ENDIF
     IF (ps_idx=0)
      SET stat = alterlist(io_string_rs->qual,ps_num_found)
      SET io_string_rs->qual[ps_num_found].values = ps_temp_string
     ELSE
      SET ps_num_found = (ps_num_found - 1)
     ENDIF
     SET ps_start = (ps_pos+ ps_delim_len)
     SET ps_pos = findstring(i_string_delim,i_string,ps_start)
   ENDWHILE
   IF (ps_start <= ps_str_len)
    SET ps_num_found = (ps_num_found+ 1)
    SET ps_temp_string = substring(ps_start,((ps_str_len - ps_start)+ 1),i_string)
    IF (ps_num_found > 1)
     SET ps_idx = locateval(ps_loop,1,(ps_num_found - 1),ps_temp_string,io_string_rs->qual[ps_loop].
      values)
    ELSE
     SET ps_idx = 0
    ENDIF
    IF (ps_idx=0)
     SET stat = alterlist(io_string_rs->qual,ps_num_found)
     SET io_string_rs->qual[ps_num_found].values = ps_temp_string
    ELSE
     SET ps_num_found = (ps_num_found - 1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE encode_html_string(i_string)
   SET i_string = replace(i_string,"&","&amp;",0)
   SET i_string = replace(i_string,"<","&lt;",0)
   SET i_string = replace(i_string,">","&gt;",0)
   RETURN(i_string)
 END ;Subroutine
 SUBROUTINE copy_xsl(i_template_name,i_file_name)
   SET dm_err->eproc = "Copying Stylesheet"
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE cx_cmd = vc WITH protect, noconstant("")
   DECLARE cx_status = i4 WITH protect, noconstant(0)
   IF (cursys="AXP")
    SET cx_cmd = concat("COPY CER_INSTALL:",trim(i_template_name,3)," CCLUSERDIR:",i_file_name)
    SET cx_status = 0
    SET cx_status = dm2_push_dcl(cx_cmd)
    IF (cx_status=0)
     SET dm_err->emsg = "Failed copying stylesheet "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ELSE
    SET cx_cmd = concat("cp $cer_install/",trim(i_template_name,3)," $CCLUSERDIR/",i_file_name)
    SET cx_status = 0
    SET cx_status = dm2_push_dcl(cx_cmd)
    IF (cx_status=0)
     SET dm_err->emsg = "Failed copying stylesheet "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dmda_get_file_name(i_env_id,i_env_name,i_mnu_hdg,i_default_name,i_file_xtn,i_type)
   SET dm_err->eproc = "Getting file name"
   DECLARE dgfn_file_name = vc
   DECLARE dgfn_menu = i2
   DECLARE dgfn_file_xtn = vc
   DECLARE dgfn_default_name = vc
   IF (findstring(".",i_file_xtn)=0)
    SET dgfn_file_xtn = cnvtlower(concat(".",i_file_xtn))
   ELSE
    SET dgfn_file_xtn = cnvtlower(i_file_xtn)
   ENDIF
   IF (findstring(".",i_default_name) > 0)
    SET dgfn_default_name = cnvtlower(substring(1,(findstring(".",i_default_name) - 1),i_default_name
      ))
   ELSE
    SET dgfn_default_name = cnvtlower(i_default_name)
   ENDIF
   CALL check_lock("RDDS FILENAME LOCK",concat(dgfn_default_name,dgfn_file_xtn),drl_reply)
   IF ((drl_reply->status="F"))
    RETURN("-1")
   ELSEIF ((drl_reply->status="Z"))
    SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
         currdbhandle))),dgfn_default_name)),currdbhandle)
   ENDIF
   SET stat = initrec(drl_reply)
   SET dgfn_menu = 0
   WHILE (dgfn_menu=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,44,concat("***  ",i_mnu_hdg,"  ***"))
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(i_env_id))
     CALL text(4,40,i_env_name)
     CALL text(7,3,concat("Please enter a file name for ",i_type," (0 to exit): "))
     CALL text(9,3,"NOTE: This will overwrite any file in CCLUSERDIR with the same name.")
     SET accept = nopatcheck
     CALL accept(7,70,"P(30);C",trim(build(dgfn_default_name,dgfn_file_xtn)))
     SET accept = patcheck
     SET dgfn_file_name = curaccept
     IF (dgfn_file_name="0")
      SET dgfn_menu = 1
      RETURN("-1")
     ENDIF
     IF (findstring(".",dgfn_file_name)=0)
      SET dgfn_file_name = concat(dgfn_file_name,dgfn_file_xtn)
     ENDIF
     IF (size(dgfn_file_name) > 30)
      SET dgfn_file_name = concat(trim(substring(1,(30 - size(dgfn_file_xtn)),dgfn_file_name)),
       dgfn_file_xtn)
     ENDIF
     CALL check_lock("RDDS FILENAME LOCK",dgfn_file_name,drl_reply)
     IF ((drl_reply->status="F"))
      RETURN("-1")
     ENDIF
     IF (cnvtlower(substring(findstring(".",dgfn_file_name),size(dgfn_file_name,1),dgfn_file_name))
      != cnvtlower(dgfn_file_xtn))
      CALL text(20,3,concat("Invalid file type, file extension must be ",dgfn_file_xtn))
      CALL pause(5)
     ELSEIF ((drl_reply->status="Z"))
      CALL text(20,3,concat("File name ",dgfn_file_name,
        " is currently locked, please choose a different filename."))
      CALL pause(5)
      IF ((((size(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name))+ size(trim(
        currdbhandle)))+ size(dgfn_file_xtn)) <= 30))
       SET dgfn_default_name = concat(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name
         ),trim(currdbhandle))
      ELSE
       SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
            currdbhandle))),dgfn_file_name)),trim(currdbhandle))
      ENDIF
     ELSE
      CALL get_lock("RDDS FILENAME LOCK",dgfn_file_name,1,drl_reply)
      IF ((drl_reply->status="F"))
       RETURN("-1")
      ELSEIF ((drl_reply->status="Z"))
       CALL text(20,3,concat("File name ",dgfn_file_name,
         " is currently locked, please choose a different filename."))
       CALL pause(5)
       IF ((((size(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name))+ size(trim(
         currdbhandle)))+ size(dgfn_file_xtn)) <= 30))
        SET dgfn_default_name = concat(substring(1,(findstring(".",dgfn_file_name) - 1),
          dgfn_file_name),trim(currdbhandle))
       ELSE
        SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
             currdbhandle))),dgfn_file_name)),trim(currdbhandle))
       ENDIF
      ELSE
       SET dgfn_menu = 1
      ENDIF
     ENDIF
     SET stat = initrec(drl_reply)
   ENDWHILE
   RETURN(dgfn_file_name)
 END ;Subroutine
 DECLARE dst_insert_data(did_pos=i4,did_rec=vc(ref),did_det_name=vc,did_prog=vc(ref),did_flag=i4) =
 null
 DECLARE dst_insert_all(dia_rec=vc(ref)) = null
 DECLARE dst_insert_data_row(didr_data=vc(ref)) = null
 DECLARE dst_transfer_data(dtd_mstr=vc(ref),dtd_temp=vc(ref)) = null
 DECLARE dst_add_log_det(dald_log_id=f8,dald_status=vc,dald_msg=vc,dald_start_dt_tm=f8,dald_end_dt_tm
  =f8) = i2
 SUBROUTINE dst_insert_all(dia_rec)
   FREE RECORD dia_prog
   RECORD dia_prog(
     1 cnt = i4
     1 qual[*]
       2 line_data = vc
   )
   DECLARE dia_loop = i4 WITH protect, noconstant(0)
   DECLARE dia_det_name = vc WITH protect, noconstant("")
   DECLARE dia_flag = i4 WITH protect, noconstant(0)
   DECLARE dia_error_ind = i2 WITH protect, noconstant(0)
   DECLARE dia_error_msg = vc WITH protect, noconstant("")
   SELECT INTO "NL:"
    FROM dm_text_find d,
     dm_text_find_detail f
    WHERE (f.dm_text_find_detail_id=dia_rec->dm_text_find_detail_id)
     AND f.dm_text_find_detail_id > 0.0
     AND d.dm_text_find_id=f.dm_text_find_id
    DETAIL
     dia_det_name = trim(d.find_name), dia_flag = f.detail_type_flag
    WITH nocounter
   ;end select
   IF (check_error("Getting DM_TEXT_FIND information") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dst_add_log_det(dia_rec->dm_text_find_log_id,"ERROR",concat("Getting DM_TEXT_FIND info: ",
      dm_err->emsg),0.0,0.0)
    RETURN(null)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No data found for detail_id passed in."
    CALL dst_add_log_det(dia_rec->dm_text_find_log_id,"ERROR",dm_err->emsg,0.0,0.0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   FOR (dia_loop = 1 TO dia_rec->long_cnt)
    CALL dst_insert_data(dia_loop,dia_rec,dia_det_name,dia_prog,dia_flag)
    IF (check_error("Calling DST_INSERT_DATA") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     IF (dia_error_ind=0)
      SET dia_error_msg = dm_err->emsg
     ENDIF
     SET dia_error_ind = 1
    ENDIF
   ENDFOR
   SET dm_err->err_ind = dia_error_ind
   SET dm_err->emsg = dia_error_msg
 END ;Subroutine
 SUBROUTINE dst_insert_data(did_pos,did_rec,did_det_name,did_prog,did_flag)
   DECLARE did_long_str = vc WITH protect, noconstant("")
   DECLARE did_loop = i4 WITH protect, noconstant(0)
   FREE RECORD did_data
   RECORD did_data(
     1 log_id = f8
     1 dm_text_find_data_id = f8
     1 detail_id = f8
     1 script_name = vc
     1 pe_id = f8
     1 pe_name = vc
     1 pe_col = vc
     1 search_col = vc
     1 dt_tm = f8
     1 user_name = vc
     1 script_path = vc
     1 att_desc = vc
     1 group_num = i4
     1 det_name = vc
     1 data_source = vc
   )
   SET did_data->det_name = did_det_name
   SET did_data->log_id = did_rec->dm_text_find_log_id
   IF ((did_rec->script_cnt > 0))
    FOR (did_loop = 1 TO did_prog->cnt)
      IF (did_loop=1)
       SET did_long_str = did_prog->qual[did_loop].line_data
      ELSE
       SET did_long_str = concat(did_long_str," ",did_prog->qual[did_loop].line_data)
      ENDIF
    ENDFOR
    IF (did_flag=4)
     SELECT INTO "NL:"
      FROM dm_text_find_data d
      WHERE (script_name=did_rec->script_qual[did_pos].script_name)
       AND (group_num=did_rec->script_qual[did_pos].group_num)
       AND status_flag != 3
      DETAIL
       did_data->pe_name = d.parent_entity_name, did_data->pe_id = d.parent_entity_id, did_data->
       search_col = d.search_col_name,
       did_data->dm_text_find_data_id = d.dm_text_find_data_id, did_data->script_name = d.script_name,
       did_data->det_name = d.find_name,
       did_data->detail_id = d.dm_text_find_detail_id, did_data->pe_col = d.parent_entity_col
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "NL:"
      FROM dm_text_find_data d
      WHERE (((dm_text_find_detail_id=did_rec->dm_text_find_detail_id)
       AND (find_name=did_data->det_name)) OR (dm_text_find_detail_id IN (
      (SELECT
       dm_text_find_detail_id
       FROM dm_text_find_detail
       WHERE detail_type_flag=4))))
       AND dm_text_find_detail_id > 0.0
       AND (script_name=did_rec->script_qual[did_pos].script_name)
       AND (group_num=did_rec->script_qual[did_pos].group_num)
       AND status_flag != 3
      DETAIL
       did_data->pe_name = d.parent_entity_name, did_data->pe_id = d.parent_entity_id, did_data->
       search_col = d.search_col_name,
       did_data->dm_text_find_data_id = d.dm_text_find_data_id, did_data->script_name = d.script_name,
       did_data->pe_col = d.parent_entity_col
      WITH nocounter
     ;end select
     SET did_data->detail_id = did_rec->dm_text_find_detail_id
    ENDIF
    IF (check_error("Finding DM_TEXT_FIND_DATA row") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     CALL dst_add_log_det(did_rec->dm_text_find_log_id,"ERROR",concat(
       "Querying for DM_TEXT_FIND_DATA:",dm_err->emsg),0.0,0.0)
     RETURN(null)
    ENDIF
    IF (curqual > 0)
     UPDATE  FROM long_text_reference l
      SET long_text = did_long_str, updt_cnt = (updt_cnt+ 1), updt_dt_tm = cnvtdatetime(curdate,
        curtime3)
      WHERE (l.long_text_id=did_data->pe_id)
      WITH nocounter
     ;end update
     IF (check_error("Updating LONG_TEXT_REFERENCE row") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      CALL dst_add_log_det(did_rec->dm_text_find_log_id,"ERROR",concat(
        "Updating LONG_TEXT_REFERENCE:",dm_err->emsg),0.0,0.0)
      RETURN(null)
     ENDIF
     IF (curqual=0)
      INSERT  FROM long_text_reference l
       SET long_text = did_long_str, long_text_id = did_data->pe_id, parent_entity_name =
        "DM_TEXT_FIND_DATA",
        parent_entity_id = did_data->dm_text_find_data_id, updt_dt_tm = cnvtdatetime(curdate,curtime3
         )
       WITH nocounter
      ;end insert
      IF (check_error("Inserting LONG_TEXT_REFERENCE row") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       CALL dst_add_log_det(did_rec->dm_text_find_log_id,"ERROR",concat(
         "Updating LONG_TEXT_REFERENCE:",dm_err->emsg),0.0,0.0)
       RETURN(null)
      ENDIF
     ENDIF
     SET did_data->dt_tm = cnvtdatetime(did_rec->script_qual[did_pos].compile_dt_tm)
     SET did_data->user_name = did_rec->script_qual[did_pos].user_name
     SET did_data->script_path = did_rec->script_qual[did_pos].path
     SET did_data->att_desc = did_rec->script_qual[did_pos].attribute_desc
     SET did_data->group_num = did_rec->script_qual[did_pos].group_num
     SET did_data->data_source = did_rec->script_qual[did_pos].data_source
    ELSE
     SELECT INTO "NL:"
      y = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       did_data->pe_id = y
      WITH nocounter
     ;end select
     IF (check_error("Poppoing LONG_TEXT_REFERENCE Sequence") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      CALL dst_add_log_det(did_rec->dm_text_find_log_id,"ERROR",concat(
        "Popping new sequence for LTR:",dm_err->emsg),0.0,0.0)
      RETURN(null)
     ENDIF
     SELECT INTO "NL:"
      y = seq(dm_clinical_seq,nextval)
      FROM dual
      DETAIL
       did_data->dm_text_find_data_id = y
      WITH nocounter
     ;end select
     IF (check_error("Popping DM_FIND_TEXT_DATA sequence") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      CALL dst_add_log_det(did_rec->dm_text_find_log_id,"ERROR",concat(
        "Popping new sequence for DM_TEXT_FIND_DATA:",dm_err->emsg),0.0,0.0)
      RETURN(null)
     ENDIF
     INSERT  FROM long_text_reference l
      SET long_text = did_long_str, long_text_id = did_data->pe_id, parent_entity_name =
       "DM_TEXT_FIND_DATA",
       parent_entity_id = did_data->dm_text_find_data_id, updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     IF (check_error("Inserting LONG_TEXT_REFERENCE row") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      CALL dst_add_log_det(did_rec->dm_text_find_log_id,"ERROR",concat(
        "Inserting LONG_TEXT_REFERENCE row:",dm_err->emsg),0.0,0.0)
      RETURN(null)
     ENDIF
     SET did_data->dt_tm = cnvtdatetime(did_rec->script_qual[did_pos].compile_dt_tm)
     SET did_data->user_name = did_rec->script_qual[did_pos].user_name
     SET did_data->script_path = did_rec->script_qual[did_pos].path
     SET did_data->att_desc = did_rec->script_qual[did_pos].attribute_desc
     SET did_data->pe_name = "LONG_TEXT_REFERENCE"
     SET did_data->search_col = "LONG_TEXT"
     SET did_data->detail_id = did_rec->dm_text_find_detail_id
     SET did_data->script_name = did_rec->script_qual[did_pos].script_name
     SET did_data->group_num = did_rec->script_qual[did_pos].group_num
     SET did_data->pe_col = "LONG_TEXT_ID"
     SET did_data->data_source = did_rec->script_qual[did_pos].data_source
    ENDIF
   ELSE
    SELECT INTO "NL:"
     FROM dm_text_find_data d
     WHERE (dm_text_find_detail_id=did_rec->dm_text_find_detail_id)
      AND (find_name=did_data->det_name)
      AND (parent_entity_name=did_rec->long_qual[did_pos].parent_entity_name)
      AND (parent_entity_id=did_rec->long_qual[did_pos].parent_entity_id)
      AND status_flag != 3
     DETAIL
      did_data->dm_text_find_data_id = d.dm_text_find_data_id
     WITH nocounter
    ;end select
    IF (check_error("Finding DM_TEXT_FIND_DATA row") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     CALL dst_add_log_det(did_rec->dm_text_find_log_id,"ERROR",concat(
       "Querying for DM_TEXT_FIND_DATA:",dm_err->emsg),0.0,0.0)
     RETURN(null)
    ENDIF
    IF (curqual > 0)
     SET did_data->dt_tm = did_rec->long_qual[did_pos].compile_dt_tm
     SET did_data->user_name = " "
     SET did_data->script_path = " "
     SET did_data->att_desc = did_rec->long_qual[did_pos].attribute_desc
     SET did_data->pe_name = did_rec->long_qual[did_pos].parent_entity_name
     SET did_data->search_col = did_rec->long_qual[did_pos].search_col_name
     SET did_data->detail_id = did_rec->dm_text_find_detail_id
     SET did_data->script_name = " "
     SET did_data->pe_id = did_rec->long_qual[did_pos].parent_entity_id
     SET did_data->group_num = 0
     SET did_data->pe_col = did_rec->long_qual[did_pos].parent_entity_col
     SET did_data->data_source = did_rec->long_qual[did_pos].data_source
    ELSE
     SELECT INTO "NL:"
      y = seq(dm_clinical_seq,nextval)
      FROM dual
      DETAIL
       did_data->dm_text_find_data_id = y
      WITH nocounter
     ;end select
     IF (check_error("Popping DM_FIND_TEXT_DATA sequence") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      CALL dst_add_log_det(did_rec->dm_text_find_log_id,"ERROR",concat(
        "Popping new sequence for DM_TEXT_FIND_DATA:",dm_err->emsg),0.0,0.0)
      RETURN(null)
     ENDIF
     SET did_data->dt_tm = did_rec->long_qual[did_pos].compile_dt_tm
     SET did_data->user_name = " "
     SET did_data->script_path = " "
     SET did_data->att_desc = did_rec->long_qual[did_pos].attribute_desc
     SET did_data->pe_name = did_rec->long_qual[did_pos].parent_entity_name
     SET did_data->pe_col = did_rec->long_qual[did_pos].parent_entity_col
     SET did_data->search_col = did_rec->long_qual[did_pos].search_col_name
     SET did_data->detail_id = did_rec->dm_text_find_detail_id
     SET did_data->script_name = " "
     SET did_data->pe_id = did_rec->long_qual[did_pos].parent_entity_id
     SET did_data->group_num = 0
     SET did_data->data_source = did_rec->long_qual[did_pos].data_source
    ENDIF
    SET did_long_str = ""
    FOR (did_loop = 1 TO did_prog->cnt)
      IF (did_loop=1)
       SET did_long_str = did_prog->qual[did_loop].line_data
      ELSE
       SET did_long_str = concat(did_long_str," ",did_prog->qual[did_loop].line_data)
      ENDIF
    ENDFOR
    IF (did_long_str > " ")
     UPDATE  FROM long_text_reference l
      SET long_text = did_long_str, updt_cnt = (updt_cnt+ 1), updt_dt_tm = cnvtdatetime(curdate,
        curtime3)
      WHERE (l.long_text_id=did_data->pe_id)
      WITH nocounter
     ;end update
     IF (check_error("Updating LONG_TEXT_REFERENCE row") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      CALL dst_add_log_det(did_rec->dm_text_find_log_id,"ERROR",concat(
        "Updating LONG_TEXT_REFERENCE:",dm_err->emsg),0.0,0.0)
      RETURN(null)
     ENDIF
     IF (curqual=0)
      INSERT  FROM long_text_reference l
       SET long_text = did_long_str, long_text_id = did_data->pe_id, parent_entity_name =
        "DM_TEXT_FIND_DATA",
        parent_entity_id = did_data->dm_text_find_data_id, updt_dt_tm = cnvtdatetime(curdate,curtime3
         )
       WITH nocounter
      ;end insert
      IF (check_error("Inserting LONG_TEXT_REFERENCE row") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       CALL dst_add_log_det(did_rec->dm_text_find_log_id,"ERROR",concat(
         "Updating LONG_TEXT_REFERENCE:",dm_err->emsg),0.0,0.0)
       RETURN(null)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL dst_insert_data_row(did_data)
   IF (check_error("Inserting DM_TEXT_FIND_DATA row") != 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   COMMIT
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dst_insert_data_row(didr_data)
   DECLARE didr_attribute = vc WITH protect, noconstant("")
   DECLARE didr_source = vc WITH protect, noconstant("")
   SET didr_attribute = substring(1,2000,didr_data->att_desc)
   SET didr_source = substring(1,250,didr_data->data_source)
   UPDATE  FROM dm_text_find_data d
    SET d.compile_dt_tm = evaluate(didr_data->dt_tm,0.0,null,cnvtdatetime(didr_data->dt_tm)), d
     .user_name = evaluate(trim(didr_data->script_name),"",null,didr_data->user_name), d.script_path
      = evaluate(trim(didr_data->script_name),"",null,didr_data->script_path),
     d.group_num = evaluate(trim(didr_data->script_name),"",null,didr_data->group_num), d.script_name
      = evaluate(trim(didr_data->script_name),"",null,didr_data->script_name), d.attribute_desc =
     didr_attribute,
     d.data_source = didr_source, d.find_name = didr_data->det_name, d.node_name = curnode,
     d.dm_text_find_detail_id = didr_data->detail_id, d.status_flag = 2, d.updt_cnt = (updt_cnt+ 1),
     d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (d.dm_text_find_data_id=didr_data->dm_text_find_data_id)
    WITH nocounter
   ;end update
   IF (check_error("Updating DM_TEXT_FIND_DATA row") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    CALL dst_add_log_det(didr_data->log_id,"ERROR",concat("Updating DM_TEXT_FIND_DATA:",dm_err->emsg),
     0.0,0.0)
    RETURN(null)
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_text_find_data d
     SET dm_text_find_data_id = didr_data->dm_text_find_data_id, d.compile_dt_tm = evaluate(didr_data
       ->dt_tm,0.0,null,cnvtdatetime(didr_data->dt_tm)), d.user_name = evaluate(trim(didr_data->
        script_name),"",null,didr_data->user_name),
      d.parent_entity_id = didr_data->pe_id, d.parent_entity_name = didr_data->pe_name, d
      .parent_entity_col = didr_data->pe_col,
      d.search_col_name = didr_data->search_col, d.attribute_desc = didr_attribute, d.data_source =
      didr_source,
      d.node_name = curnode, d.status_flag = 2, d.script_path = evaluate(trim(didr_data->script_name),
       "",null,didr_data->script_path),
      d.dm_text_find_detail_id = didr_data->detail_id, d.find_name = didr_data->det_name, d
      .script_name = evaluate(trim(didr_data->script_name),"",null,didr_data->script_name),
      d.group_num = evaluate(trim(didr_data->script_name),"",null,didr_data->group_num), d.updt_dt_tm
       = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (check_error("Inserting DM_TEXT_FIND_DATA row") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     CALL dst_add_log_det(didr_data->log_id,"ERROR",concat("Inserting DM_TEXT_FIND_DATA:",dm_err->
       emsg),0.0,0.0)
     RETURN(null)
    ENDIF
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dst_transfer_data(dtd_mstr,dtd_temp)
   DECLARE dtd_s_loop = i4 WITH protect, noconstant(0)
   DECLARE dtd_a_loop = i4 WITH protect, noconstant(0)
   DECLARE dtd_ai_val = vc WITH protect, noconstant("1")
   DECLARE dtd_att_ind = i2 WITH protect, noconstant(0)
   FOR (dtd_s_loop = 1 TO dtd_temp->cnt)
     SET dtd_ai_val = "1"
     SET dtd_att_ind = 0
     IF ((dtd_temp->qual[dtd_s_loop].s_name > " "))
      SET dtd_mstr->script_cnt = (dtd_mstr->script_cnt+ 1)
      SET stat = alterlist(dtd_mstr->script_qual,dtd_mstr->script_cnt)
      SET dtd_mstr->script_qual[dtd_mstr->script_cnt].script_name = dtd_temp->qual[dtd_s_loop].s_name
      SET dtd_mstr->script_qual[dtd_mstr->script_cnt].data_source = dtd_temp->qual[dtd_s_loop].
      data_source
      SET dtd_mstr->script_qual[dtd_mstr->script_cnt].group_num = dtd_temp->qual[dtd_s_loop].
      group_num
      IF ((dtd_temp->qual[dtd_s_loop].compile_dt_tm > 0.0))
       SET dtd_mstr->script_qual[dtd_mstr->script_cnt].compile_dt_tm = dtd_temp->qual[dtd_s_loop].
       compile_dt_tm
      ENDIF
      SET dtd_mstr->script_qual[dtd_mstr->script_cnt].attribute_desc = "<document>"
      IF ((dtd_temp->qual[dtd_s_loop].desc > " "))
       SET dtd_mstr->script_qual[dtd_mstr->script_cnt].attribute_desc = concat(dtd_mstr->script_qual[
        dtd_mstr->script_cnt].attribute_desc,"<desc>",encode_html_string(dtd_temp->qual[dtd_s_loop].
         desc),"</desc>")
      ENDIF
      FOR (dtd_a_loop = 1 TO dtd_temp->qual[dtd_s_loop].att_cnt)
        IF ((dtd_temp->qual[dtd_s_loop].att_qual[dtd_a_loop].col_name="ACTIVE_IND"))
         SET dtd_ai_val = dtd_temp->qual[dtd_s_loop].att_qual[dtd_a_loop].col_val
        ELSE
         IF (dtd_att_ind=0)
          SET dtd_mstr->script_qual[dtd_mstr->script_cnt].attribute_desc = concat(dtd_mstr->
           script_qual[dtd_mstr->script_cnt].attribute_desc,"<att_all>")
         ENDIF
         SET dtd_mstr->script_qual[dtd_mstr->script_cnt].attribute_desc = concat(dtd_mstr->
          script_qual[dtd_mstr->script_cnt].attribute_desc,"[",dtd_temp->qual[dtd_s_loop].att_qual[
          dtd_a_loop].tab_name,".",dtd_temp->qual[dtd_s_loop].att_qual[dtd_a_loop].col_name,
          "]:[",encode_html_string(dtd_temp->qual[dtd_s_loop].att_qual[dtd_a_loop].col_val),"]:[",
          encode_html_string(dtd_temp->qual[dtd_s_loop].att_qual[dtd_a_loop].col_txt),"]::")
         SET dtd_att_ind = 1
        ENDIF
      ENDFOR
      IF (dtd_att_ind=1)
       SET dtd_mstr->script_qual[dtd_mstr->script_cnt].attribute_desc = substring(1,(size(dtd_mstr->
         script_qual[dtd_mstr->script_cnt].attribute_desc) - 2),dtd_mstr->script_qual[dtd_mstr->
        script_cnt].attribute_desc)
       SET dtd_mstr->script_qual[dtd_mstr->script_cnt].attribute_desc = concat(dtd_mstr->script_qual[
        dtd_mstr->script_cnt].attribute_desc,"</att_all>")
      ENDIF
      SET dtd_mstr->script_qual[dtd_mstr->script_cnt].attribute_desc = concat(dtd_mstr->script_qual[
       dtd_mstr->script_cnt].attribute_desc,"<active_ind>",dtd_ai_val,"</active_ind>")
      SET dtd_mstr->script_qual[dtd_mstr->script_cnt].attribute_desc = concat(dtd_mstr->script_qual[
       dtd_mstr->script_cnt].attribute_desc,"</document>")
     ELSEIF ((dtd_temp->qual[dtd_s_loop].pe_name > " "))
      SET dtd_mstr->long_cnt = (dtd_mstr->long_cnt+ 1)
      SET stat = alterlist(dtd_mstr->long_qual,dtd_mstr->long_cnt)
      SET dtd_mstr->long_qual[dtd_mstr->long_cnt].parent_entity_name = dtd_temp->qual[dtd_s_loop].
      pe_name
      SET dtd_mstr->long_qual[dtd_mstr->long_cnt].parent_entity_id = dtd_temp->qual[dtd_s_loop].pe_id
      SET dtd_mstr->long_qual[dtd_mstr->long_cnt].parent_entity_col = dtd_temp->qual[dtd_s_loop].
      pe_col
      SET dtd_mstr->long_qual[dtd_mstr->long_cnt].search_col_name = dtd_temp->qual[dtd_s_loop].
      srch_col
      SET dtd_mstr->long_qual[dtd_mstr->long_cnt].data_source = dtd_temp->qual[dtd_s_loop].
      data_source
      IF ((dtd_temp->qual[dtd_s_loop].compile_dt_tm > 0.0))
       SET dtd_mstr->long_qual[dtd_mstr->long_cnt].compile_dt_tm = dtd_temp->qual[dtd_s_loop].
       compile_dt_tm
      ENDIF
      SET dtd_mstr->long_qual[dtd_mstr->long_cnt].attribute_desc = "<document>"
      IF ((dtd_temp->qual[dtd_s_loop].desc > " "))
       SET dtd_mstr->long_qual[dtd_mstr->long_cnt].attribute_desc = concat(dtd_mstr->long_qual[
        dtd_mstr->long_cnt].attribute_desc,"<desc>",encode_html_string(dtd_temp->qual[dtd_s_loop].
         desc),"</desc>")
      ENDIF
      FOR (dtd_a_loop = 1 TO dtd_temp->qual[dtd_s_loop].att_cnt)
        IF ((dtd_temp->qual[dtd_s_loop].att_qual[dtd_a_loop].col_name="ACTIVE_IND"))
         SET dtd_ai_val = dtd_temp->qual[dtd_s_loop].att_qual[dtd_a_loop].col_val
        ELSE
         IF (dtd_att_ind=0)
          SET dtd_mstr->long_qual[dtd_mstr->long_cnt].attribute_desc = concat(dtd_mstr->long_qual[
           dtd_mstr->long_cnt].attribute_desc,"<att_all>")
         ENDIF
         SET dtd_mstr->long_qual[dtd_mstr->long_cnt].attribute_desc = concat(dtd_mstr->long_qual[
          dtd_mstr->long_cnt].attribute_desc,"[",dtd_temp->qual[dtd_s_loop].att_qual[dtd_a_loop].
          tab_name,".",dtd_temp->qual[dtd_s_loop].att_qual[dtd_a_loop].col_name,
          "]:[",encode_html_string(dtd_temp->qual[dtd_s_loop].att_qual[dtd_a_loop].col_val),"]:[",
          encode_html_string(dtd_temp->qual[dtd_s_loop].att_qual[dtd_a_loop].col_txt),"]::")
         SET dtd_att_ind = 1
        ENDIF
      ENDFOR
      IF (dtd_att_ind=1)
       SET dtd_mstr->long_qual[dtd_mstr->long_cnt].attribute_desc = substring(1,(size(dtd_mstr->
         long_qual[dtd_mstr->long_cnt].attribute_desc) - 2),dtd_mstr->long_qual[dtd_mstr->long_cnt].
        attribute_desc)
       SET dtd_mstr->long_qual[dtd_mstr->long_cnt].attribute_desc = concat(dtd_mstr->long_qual[
        dtd_mstr->long_cnt].attribute_desc,"</att_all>")
      ENDIF
      SET dtd_mstr->long_qual[dtd_mstr->long_cnt].attribute_desc = concat(dtd_mstr->long_qual[
       dtd_mstr->long_cnt].attribute_desc,"<active_ind>",dtd_ai_val,"</active_ind>")
      SET dtd_mstr->long_qual[dtd_mstr->long_cnt].attribute_desc = concat(dtd_mstr->long_qual[
       dtd_mstr->long_cnt].attribute_desc,"</document>")
     ENDIF
   ENDFOR
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dst_add_log_det(dald_log_id,dald_status,dald_msg,dald_start_dt_tm,dald_end_dt_tm)
   DECLARE dald_prev_err_ind = i2 WITH protect, noconstant(0)
   DECLARE dald_prev_err_msg = vc WITH protect, noconstant("")
   IF (dald_log_id <= 0.0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No DM_TEXT_FIND_LOG_ID passed into DST_ADD_LOG_DET subroutine."
    RETURN(1)
   ENDIF
   SET dald_prev_err_ind = dm_err->err_ind
   SET dald_prev_err_msg = dm_err->emsg
   SET dm_err->err_ind = 0
   INSERT  FROM dm_text_find_log_detail d
    SET dm_text_find_log_detail_id = seq(dm_clinical_seq,nextval), dm_text_find_log_id = dald_log_id,
     detail_status = dald_status,
     detail_message = substring(1,255,dald_msg), start_dt_tm = cnvtdatetime(dald_start_dt_tm),
     end_dt_tm = cnvtdatetime(dald_end_dt_tm),
     updt_id = reqinfo->updt_id, updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_applctx = reqinfo
     ->updt_applctx,
     updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error("Inserting DM_TEXT_FIND_LOG_DETAIL row") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ENDIF
   COMMIT
   SET dm_err->err_ind = dald_prev_err_ind
   SET dm_err->emsg = dald_prev_err_msg
   RETURN(0)
 END ;Subroutine
 IF ((validate(dcr_max_stack_size,- (1))=- (1))
  AND (validate(dcr_max_stack_size,- (2))=- (2)))
  DECLARE dcr_max_stack_size = i4 WITH protect, constant(30)
 ENDIF
 IF (validate(dm_err->ecode,- (1)) < 0
  AND validate(dm_err->ecode,722)=722)
  FREE RECORD dm_err
  IF (currev >= 8)
   RECORD dm_err(
     1 logfile = vc
     1 debug_flag = i2
     1 ecode = i4
     1 emsg = vc
     1 eproc = vc
     1 err_ind = i2
     1 user_action = vc
     1 asterisk_line = c80
     1 tempstr = vc
     1 errfile = vc
     1 errtext = vc
     1 unique_fname = vc
     1 disp_msg_emsg = vc
     1 disp_dcl_err_ind = i2
   )
  ELSE
   RECORD dm_err(
     1 logfile = vc
     1 debug_flag = i2
     1 ecode = i4
     1 emsg = c132
     1 eproc = vc
     1 err_ind = i2
     1 user_action = vc
     1 asterisk_line = c80
     1 tempstr = vc
     1 errfile = vc
     1 errtext = vc
     1 unique_fname = vc
     1 disp_msg_emsg = vc
     1 disp_dcl_err_ind = i2
   )
  ENDIF
  SET dm_err->asterisk_line = fillstring(80,"*")
  SET dm_err->ecode = 0
  IF (validate(dm2_debug_flag,- (1)) > 0)
   SET dm_err->debug_flag = dm2_debug_flag
  ELSE
   SET dm_err->debug_flag = 0
  ENDIF
  SET dm_err->err_ind = 0
  SET dm_err->user_action = "NONE"
  SET dm_err->tempstr = " "
  SET dm_err->errfile = "NONE"
  SET dm_err->logfile = "NONE"
  SET dm_err->unique_fname = "NONE"
  SET dm_err->disp_dcl_err_ind = 1
 ENDIF
 IF (validate(dm2_sys_misc->cur_os,"X")="X"
  AND validate(dm2_sys_misc->cur_os,"Y")="Y")
  FREE RECORD dm2_sys_misc
  RECORD dm2_sys_misc(
    1 cur_os = vc
    1 cur_db_os = vc
  )
  SET dm2_sys_misc->cur_os = validate(cursys2,cursys)
  SET dm2_sys_misc->cur_db_os = validate(currdbsys,cursys)
  IF (size(dm2_sys_misc->cur_db_os) != 3)
   SET dm2_sys_misc->cur_db_os = substring(1,(findstring(":",dm2_sys_misc->cur_db_os,1,1) - 1),
    dm2_sys_misc->cur_db_os)
  ENDIF
 ENDIF
 IF (validate(dm2_install_schema->process_option," ")=" "
  AND validate(dm2_install_schema->process_option,"NOTTHERE")="NOTTHERE")
  FREE RECORD dm2_install_schema
  RECORD dm2_install_schema(
    1 process_option = vc
    1 file_prefix = vc
    1 schema_loc = vc
    1 schema_prefix = vc
    1 target_dbase_name = vc
    1 dbase_name = vc
    1 u_name = vc
    1 p_word = vc
    1 connect_str = vc
    1 v500_p_word = vc
    1 v500_connect_str = vc
    1 cdba_p_word = vc
    1 cdba_connect_str = vc
    1 run_id = i4
    1 menu_driver = vc
    1 oragen3_ignore_dm_columns_doc = i2
    1 last_checkpoint = vc
    1 gen_id = i4
    1 restart_method = i2
    1 appl_id = vc
    1 hostname = vc
    1 ccluserdir = vc
    1 cer_install = vc
    1 servername = vc
    1 frmt_servername = vc
    1 default_fg_name = vc
    1 curprog = vc
    1 adl_username = vc
    1 tgt_sch_cleanup = i2
    1 special_ih_process = i2
    1 dbase_type = vc
    1 data_to_move = c30
    1 percent_tspace = i4
    1 src_dbase_name = vc
    1 src_v500_p_word = vc
    1 src_v500_connect_str = vc
    1 logfile_prefix = vc
    1 src_run_id = f8
    1 src_op_id = f8
    1 target_env_name = vc
    1 dm2_updt_task_value = i2
  )
  SET dm2_install_schema->process_option = "NONE"
  SET dm2_install_schema->file_prefix = "NONE"
  SET dm2_install_schema->schema_loc = "NONE"
  SET dm2_install_schema->schema_prefix = "NONE"
  SET dm2_install_schema->target_dbase_name = "NONE"
  SET dm2_install_schema->dbase_name = "NONE"
  SET dm2_install_schema->u_name = "NONE"
  SET dm2_install_schema->p_word = "NONE"
  SET dm2_install_schema->connect_str = "NONE"
  SET dm2_install_schema->v500_p_word = "NONE"
  SET dm2_install_schema->v500_connect_str = "NONE"
  SET dm2_install_schema->cdba_p_word = "NONE"
  SET dm2_install_schema->cdba_connect_str = "NONE"
  SET dm2_install_schema->run_id = 0
  SET dm2_install_schema->menu_driver = "NONE"
  SET dm2_install_schema->oragen3_ignore_dm_columns_doc = 0
  SET dm2_install_schema->last_checkpoint = "NONE"
  SET dm2_install_schema->gen_id = 0
  SET dm2_install_schema->restart_method = 0
  SET dm2_install_schema->appl_id = "NONE"
  SET dm2_install_schema->hostname = "NONE"
  SET dm2_install_schema->servername = "NONE"
  SET dm2_install_schema->default_fg_name = "NONE"
  SET dm2_install_schema->curprog = "NONE"
  SET dm2_install_schema->adl_username = "NONE"
  SET dm2_install_schema->tgt_sch_cleanup = 0
  SET dm2_install_schema->special_ih_process = 0
  SET dm2_install_schema->dbase_type = "NONE"
  SET dm2_install_schema->data_to_move = "NONE"
  SET dm2_install_schema->percent_tspace = 0
  SET dm2_install_schema->src_dbase_name = "NONE"
  SET dm2_install_schema->src_v500_p_word = "NONE"
  SET dm2_install_schema->src_v500_connect_str = "NONE"
  SET dm2_install_schema->logfile_prefix = "NONE"
  SET dm2_install_schema->src_run_id = 0
  SET dm2_install_schema->src_op_id = 0
  SET dm2_install_schema->target_env_name = "NONE"
  SET dm2_install_schema->dm2_updt_task_value = 15301
  IF ((dm2_sys_misc->cur_os="WIN"))
   SET dm2_install_schema->ccluserdir = build(logical("ccluserdir"),"\")
   SET dm2_install_schema->cer_install = build(logical("cer_install"),"\")
  ELSEIF ((dm2_sys_misc->cur_os="AXP"))
   SET dm2_install_schema->ccluserdir = logical("ccluserdir")
   SET dm2_install_schema->cer_install = logical("cer_install")
  ELSE
   SET dm2_install_schema->ccluserdir = build(logical("ccluserdir"),"/")
   SET dm2_install_schema->cer_install = build(logical("cer_install"),"/")
  ENDIF
 ENDIF
 IF (validate(inhouse_misc->inhouse_domain,- (1)) < 0
  AND validate(inhouse_misc->inhouse_domain,722)=722)
  FREE RECORD inhouse_misc
  RECORD inhouse_misc(
    1 inhouse_domain = i2
    1 fk_err_ind = i2
    1 nonfk_err_ind = i2
    1 fk_parent_table = vc
    1 tablespace_err_code = f8
    1 foreignkey_err_code = f8
  )
  SET inhouse_misc->inhouse_domain = - (1)
  SET inhouse_misc->fk_err_ind = 0
  SET inhouse_misc->nonfk_err_ind = 0
  SET inhouse_misc->fk_parent_table = ""
  SET inhouse_misc->tablespace_err_code = 93
  SET inhouse_misc->foreignkey_err_code = 94
 ENDIF
 IF (validate(program_stack_rs->cnt,1)=1
  AND validate(program_stack_rs->cnt,2)=2)
  FREE RECORD program_stack_rs
  RECORD program_stack_rs(
    1 cnt = i4
    1 qual[*]
      2 name = vc
  )
  SET stat = alterlist(program_stack_rs->qual,dcr_max_stack_size)
 ENDIF
 DECLARE dm2_push_cmd(sbr_dpcstr=vc,sbr_cmd_end=i2) = i2
 DECLARE dm2_push_dcl(sbr_dpdstr=vc) = i2
 DECLARE get_unique_file(sbr_fprefix=vc,sbr_fext=vc) = i2
 DECLARE parse_errfile(sbr_errfile=vc) = i2
 DECLARE check_error(sbr_ceprocess=vc) = i2
 DECLARE disp_msg(sbr_demsg=vc,sbr_dlogfile=vc,sbr_derr_ind=i2) = null
 DECLARE init_logfile(sbr_logfile=vc,sbr_header_msg=vc) = i2
 DECLARE check_logfile(sbr_lprefix=vc,sbr_lext=vc,sbr_hmsg=vc) = i2
 DECLARE final_disp_msg(sbr_log_prefix=vc) = null
 DECLARE dm2_set_autocommit(sbr_dsa_flag=i2) = i2
 DECLARE dm2_prg_maint(sbr_maint_type=vc) = i2
 DECLARE dm2_set_inhouse_domain() = i2
 DECLARE dm2_table_exists(dte_table_name=vc) = c1
 DECLARE dm2_table_and_ccldef_exists(dtace_table_name=vc,dtace_found_ind=i2(ref)) = i2
 DECLARE dm2_disp_file(ddf_fname=vc,ddf_desc=vc) = i2
 DECLARE dm2_get_program_stack(null) = vc
 SUBROUTINE dm2_push_cmd(sbr_dpcstr,sbr_cmd_end)
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("dm2_push_cmd executing: ",sbr_dpcstr))
    CALL echo("*")
   ENDIF
   CALL parser(sbr_dpcstr,1)
   SET dm_err->tempstr = concat(dm_err->tempstr," ",sbr_dpcstr)
   IF (sbr_cmd_end=1)
    IF ((dm_err->err_ind=0))
     IF (check_error(concat("dm2_push_cmd executing: ",dm_err->tempstr))=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->tempstr = " "
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->tempstr = " "
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_push_dcl(sbr_dpdstr)
   DECLARE dpd_stat = i4 WITH protect, noconstant(0)
   DECLARE newstr = vc WITH protect
   DECLARE strloc = i4 WITH protect, noconstant(0)
   DECLARE temp_file = vc WITH protect, noconstant(" ")
   DECLARE str2 = vc WITH protect, noconstant(" ")
   DECLARE posx = i4 WITH protect, noconstant(0)
   DECLARE sql_warn_ind = i2 WITH protect, noconstant(0)
   DECLARE dpd_disp_dcl_err_ind = i2 WITH protect, noconstant(1)
   IF ((validate(dm_err->disp_dcl_err_ind,- (1))=- (1))
    AND (validate(dm_err->disp_dcl_err_ind,- (2))=- (2)))
    SET dpd_disp_dcl_err_ind = 1
   ELSE
    SET dpd_disp_dcl_err_ind = dm_err->disp_dcl_err_ind
    SET dm_err->disp_dcl_err_ind = 1
   ENDIF
   IF ((dm_err->errfile="NONE"))
    IF (get_unique_file("dm2_",".err")=0)
     RETURN(0)
    ELSE
     SET dm_err->errfile = dm_err->unique_fname
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("AXP")))
    SET strloc = findstring(">",sbr_dpdstr,1,0)
    IF (strloc > 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Cannot support additional piping outside of push dcl subroutine"
     SET dm_err->eproc = "Check push dcl command for piping character (>)."
     RETURN(0)
    ENDIF
    SET newstr = concat("pipe ",sbr_dpdstr," > ccluserdir:",dm_err->errfile)
   ELSE
    SET strloc = findstring(">",sbr_dpdstr,1,0)
    IF (strloc > 0)
     SET strlength = size(trim(sbr_dpdstr))
     IF (findstring("2>&1",sbr_dpdstr) > 0)
      SET temp_file = build(substring((strloc+ 1),((strlength - strloc) - 4),sbr_dpdstr))
     ELSE
      SET temp_file = build(substring((strloc+ 1),(strlength - strloc),sbr_dpdstr))
     ENDIF
     SET newstr = sbr_dpdstr
    ELSE
     SET newstr = concat(sbr_dpdstr," > ",dm2_install_schema->ccluserdir,dm_err->errfile," 2>&1")
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("dm2_push_dcl executing: ",newstr))
    CALL echo("*")
   ENDIF
   CALL dcl(newstr,size(newstr),dpd_stat)
   IF (dpd_stat=0)
    IF (temp_file > " ")
     CASE (dm2_sys_misc->cur_os)
      OF "WIN":
       SET str2 = concat("copy ",temp_file," ",dm_err->errfile)
      ELSE
       IF ((dm2_sys_misc->cur_os != "AXP"))
        SET str2 = concat("cp ",temp_file," ",dm_err->errfile)
       ENDIF
     ENDCASE
     CALL dcl(str2,size(str2),dpd_stat)
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (sql_warn_ind=true)
     SET dm_err->user_action = "NONE"
     SET dm_err->eproc = concat("Warning Encountered:",dm_err->errtext)
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dm_err->disp_msg_emsg = dm_err->errtext
     SET dm_err->emsg = dm_err->disp_msg_emsg
     IF (dpd_disp_dcl_err_ind=1)
      SET dm_err->eproc = concat("dm2_push_dcl executing: ",newstr)
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
     ELSE
      IF ((dm_err->debug_flag > 1))
       CALL echo("Call dcl failed- error handling done by calling script")
      ENDIF
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echo(concat("PARSING THROUGH - ",dm_err->errfile))
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_unique_file(sbr_fprefix,sbr_fext)
   DECLARE guf_return_val = i4 WITH protect, noconstant(1)
   DECLARE fini = i2 WITH protect, noconstant(0)
   DECLARE fname = vc WITH protect
   DECLARE unique_tempstr = vc WITH protect
   WHILE (fini=0)
     IF ((((validate(systimestamp,- (999.00))=- (999.00))
      AND validate(systimestamp,999.00)=999.00) OR (validate(dm2_bypass_unique_file,- (1))=1)) )
      SET unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(curdate,curtime3),
         cnvtdatetime(curdate,000000)) * 864000)))
     ELSEIF ((validate(systimestamp,- (999.00)) != - (999.00))
      AND validate(systimestamp,999.00) != 999.00
      AND (validate(dm2_bypass_unique_file,- (1))=- (1))
      AND (validate(dm2_bypass_unique_file,- (2))=- (2)))
      SET unique_tempstr = format(systimestamp,"hhmmsscccccc;;q")
     ENDIF
     SET fname = cnvtlower(build(sbr_fprefix,unique_tempstr,sbr_fext))
     IF (findfile(fname)=0)
      SET fini = 1
     ENDIF
   ENDWHILE
   IF (check_error(concat("Getting unique file name using prefix: ",sbr_fprefix," and ext: ",sbr_fext
     ))=1)
    SET guf_return_val = 0
   ENDIF
   IF (guf_return_val=0)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Error occurred in ",dm_err->eproc))
    CALL echo("*")
    CALL echo(trim(dm_err->emsg))
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(dm_err->user_action)
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ELSE
    SET dm_err->unique_fname = fname
    CALL echo(concat("**Unique filename = ",dm_err->unique_fname))
   ENDIF
   RETURN(guf_return_val)
 END ;Subroutine
 SUBROUTINE parse_errfile(sbr_errfile)
   SET dm_err->errtext = " "
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(sbr_errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("TEXT = ",r.line))
     ENDIF
     dm_err->errtext = build(dm_err->errtext,r.line)
    WITH nocounter, maxcol = 255
   ;end select
   IF (check_error(concat("Parsing error file ",dm_err->errfile))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_error(sbr_ceprocess)
   DECLARE return_val = i4 WITH protect, noconstant(0)
   IF ((dm_err->err_ind=1))
    SET return_val = 1
   ELSE
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->eproc = sbr_ceprocess
     SET dm_err->err_ind = 1
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE disp_msg(sbr_demsg,sbr_dlogfile,sbr_derr_ind)
   DECLARE dm_txt = c132 WITH protect
   DECLARE dm_ecode = i4 WITH protect
   DECLARE dm_emsg = c132 WITH protect
   DECLARE dm_full_emsg = vc WITH protect
   DECLARE dm_eproc_length = i4 WITH protect
   DECLARE dm_full_emsg_length = i4 WITH protect
   DECLARE dm_user_action_length = i4 WITH protect
   IF (sbr_demsg="dm_err->disp_msg_emsg")
    SET dm_full_emsg = dm_err->disp_msg_emsg
   ELSE
    SET dm_full_emsg = sbr_demsg
   ENDIF
   SET dm_eproc_length = textlen(dm_err->eproc)
   SET dm_full_emsg_length = textlen(dm_full_emsg)
   SET dm_user_action_length = textlen(dm_err->user_action)
   IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET"))
    AND trim(sbr_dlogfile) != ""
    AND sbr_derr_ind IN (0, 1, 10))
    SELECT INTO value(sbr_dlogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      beg_pos = 1, end_pos = 132, not_done = 1
     DETAIL
      row + 1, curdate"mm/dd/yyyy;;d", " ",
      curtime3"hh:mm:ss;3;m"
      IF (sbr_derr_ind=1)
       row + 1, "* Component Name:  ", curprog,
       row + 1, "* Process Description:  "
      ENDIF
      dm_txt = substring(beg_pos,end_pos,dm_err->eproc)
      WHILE (not_done=1)
        row + 1, col 0, dm_txt
        IF (end_pos > dm_eproc_length)
         not_done = 0
        ELSE
         beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,dm_err->
          eproc)
        ENDIF
      ENDWHILE
      IF (sbr_derr_ind=1)
       row + 1, "* Error Message:  ", beg_pos = 1,
       end_pos = 132, dm_txt = substring(beg_pos,132,dm_full_emsg), not_done = 1
       WHILE (not_done=1)
         row + 1, col 0, dm_txt
         IF (end_pos > dm_full_emsg_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,
           dm_full_emsg)
         ENDIF
       ENDWHILE
      ENDIF
      IF ((dm_err->user_action != "NONE"))
       row + 1, "* Recommended Action(s):  ", beg_pos = 1,
       end_pos = 132, dm_txt = substring(beg_pos,132,dm_err->user_action), not_done = 1
       WHILE (not_done=1)
         row + 1, col 0, dm_txt
         IF (end_pos > dm_user_action_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,dm_err->
           user_action)
         ENDIF
       ENDWHILE
      ENDIF
      row + 1
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 200, append
    ;end select
    SET dm_ecode = error(dm_emsg,1)
   ELSEIF (sbr_dlogfile != "DM2_LOGFILE_NOTSET")
    SET dm_ecode = 1
    SET dm_emsg = "Message couldn't write to log file since name passed in was invalid."
   ENDIF
   IF (dm_ecode > 0)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Component Name:  ",curprog))
    CALL echo("*")
    CALL echo(concat("Process Description:  Writing message to log file."))
    CALL echo("*")
    CALL echo(concat("Error Message:  ",trim(dm_emsg)))
    CALL echo("*")
    IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
     CALL echo(concat("Log file is ccluserdir:",sbr_dlogfile))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
   IF (sbr_derr_ind=1)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Component Name:  ",curprog))
    CALL echo("*")
    CALL echo(concat("Process Description:  ",dm_err->eproc))
    CALL echo("*")
    CALL echo(concat("Error Message:  ",trim(dm_full_emsg)))
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(concat("Recommended Action(s):  ",trim(dm_err->user_action)))
     CALL echo("*")
    ENDIF
    IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
     CALL echo(concat("Log file is ccluserdir:",sbr_dlogfile))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ELSEIF (sbr_derr_ind IN (0, 20))
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(dm_err->eproc)
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(concat("Recommended Action(s):  ",trim(dm_err->user_action)))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
   SET dm_err->user_action = "NONE"
 END ;Subroutine
 SUBROUTINE init_logfile(sbr_logfile,sbr_header_msg)
   DECLARE init_return_val = i4 WITH protect, noconstant(1)
   IF (sbr_logfile != "NONE"
    AND trim(sbr_logfile) != "")
    SELECT INTO value(sbr_logfile)
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      row + 1, curdate"mm/dd/yyyy;;d", " ",
      curtime3"hh:mm:ss;;m", row + 1, sbr_header_msg,
      row + 1, row + 1
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 512
    ;end select
    IF (check_error(concat("Creating log file ",trim(sbr_logfile)))=1)
     SET init_return_val = 0
    ELSE
     SET dm_err->eproc = concat("Log file created.  Log file name is: ",sbr_logfile)
     CALL disp_msg(" ",sbr_logfile,0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Creating log file ",trim(sbr_logfile))
    SET dm_err->emsg = concat("Log file name passed is invalid.  Name passed in is: ",trim(
      sbr_logfile))
    SET init_return_val = 0
   ENDIF
   IF (init_return_val=0)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Error occurred in ",dm_err->eproc))
    CALL echo("*")
    CALL echo(trim(dm_err->emsg))
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
   RETURN(init_return_val)
 END ;Subroutine
 SUBROUTINE check_logfile(sbr_lprefix,sbr_lext,sbr_hmsg)
   IF ((dm_err->logfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
    IF ((dm_err->debug_flag > 9))
     SET trace = echoprogsub
     IF (((currev > 8) OR (currev=8
      AND currevminor >= 1)) )
      SET trace = echosub
     ENDIF
    ENDIF
    IF (get_unique_file(sbr_lprefix,sbr_lext)=0)
     RETURN(0)
    ENDIF
    SET dm_err->logfile = dm_err->unique_fname
    IF (init_logfile(dm_err->logfile,sbr_hmsg)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_prg_maint("BEGIN")=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE final_disp_msg(sbr_log_prefix)
   DECLARE plength = i2
   SET plength = textlen(sbr_log_prefix)
   IF (dm2_prg_maint("END")=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->err_ind=0))
    IF (cnvtlower(sbr_log_prefix)=substring(1,plength,dm_err->logfile))
     SET dm_err->eproc = concat(dm_err->eproc,"  Log file is ccluserdir:",dm_err->logfile)
     CALL disp_msg(" ",dm_err->logfile,0)
    ELSE
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_set_autocommit(sbr_dsa_flag)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_prg_maint(sbr_maint_type)
   IF ( NOT (cnvtupper(trim(sbr_maint_type,3)) IN ("BEGIN", "END")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid maintenance type"
    SET dm_err->eproc = "Performing program maintenance"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("********************************************************")
    CALL echo("* CCL current resource usage statistics                *")
    CALL echo("********************************************************")
    CALL trace(7)
   ENDIF
   IF (cnvtupper(trim(sbr_maint_type,3))="BEGIN")
    IF ((program_stack_rs->cnt < dcr_max_stack_size))
     SET program_stack_rs->cnt = (program_stack_rs->cnt+ 1)
     SET program_stack_rs->qual[program_stack_rs->cnt].name = curprog
    ENDIF
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
    SET dm2_install_schema->curprog = curprog
   ELSE
    FOR (i = 0 TO (program_stack_rs->cnt - 1))
      IF ((program_stack_rs->qual[(program_stack_rs->cnt - i)].name=curprog))
       FOR (j = (program_stack_rs->cnt - i) TO program_stack_rs->cnt)
         SET program_stack_rs->qual[j].name = ""
       ENDFOR
       SET program_stack_rs->cnt = ((program_stack_rs->cnt - i) - 1)
       SET i = program_stack_rs->cnt
      ENDIF
    ENDFOR
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm2_get_program_stack(null))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_set_inhouse_domain(null)
   DECLARE dsid_tbl_ind = c1 WITH protect, noconstant(" ")
   IF (validate(dm2_inhouse_flag,- (1)) > 0)
    SET dm_err->eproc = "Inhouse Domain Detected."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET inhouse_misc->inhouse_domain = 1
    RETURN(1)
   ENDIF
   IF ((inhouse_misc->inhouse_domain=- (1)))
    SET dm_err->eproc = "Determining whether table dm_info exists"
    SET dsid_tbl_ind = dm2_table_exists("DM_INFO")
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (dsid_tbl_ind="F")
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="INHOUSE DOMAIN"
      WITH nocounter
     ;end select
     IF (check_error("Determine if process running in an in-house domain")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSEIF (curqual=1)
      SET inhouse_misc->inhouse_domain = 1
     ELSE
      SET inhouse_misc->inhouse_domain = 0
     ENDIF
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_table_exists(dte_table_name)
  SELECT INTO "nl:"
   FROM dm2_dba_tab_columns dutc,
    dtable dt
   WHERE dutc.table_name=trim(cnvtupper(dte_table_name))
    AND dutc.table_name=dt.table_name
    AND dutc.owner=value(currdbuser)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   RETURN("E")
  ELSE
   IF (curqual=0)
    RETURN("N")
   ELSE
    RETURN("F")
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE dm2_table_and_ccldef_exists(dtace_table_name,dtace_found_ind)
   SELECT INTO "nl:"
    FROM dm2_dba_tab_cols dutc,
     dtable dt
    WHERE dutc.table_name=trim(cnvtupper(dtace_table_name))
     AND dutc.table_name=dt.table_name
     AND dutc.owner=value(currdbuser)
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking if ",trim(cnvtupper(dtace_table_name)),
     " table and ccl def exists"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    IF (curqual=0)
     SET dtace_found_ind = 0
    ELSE
     SET dtace_found_ind = 1
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_disp_file(ddf_fname,ddf_desc)
   DECLARE ddf_row = i4 WITH protect, noconstant(0)
   IF ((dm2_sys_misc->cur_os="WIN"))
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL video(n)
    SET ddf_row = 3
    CALL box(1,1,5,132)
    CALL text(ddf_row,48,"***  REPORT GENERATED  ***")
    SET ddf_row = (ddf_row+ 4)
    CALL text(ddf_row,2,"The following report was generated in CCLUSERDIR... ")
    SET ddf_row = (ddf_row+ 2)
    CALL text(ddf_row,5,concat("File Name:   ",trim(ddf_fname)))
    SET ddf_row = (ddf_row+ 1)
    CALL text(ddf_row,5,concat("Description: ",trim(ddf_desc)))
    SET ddf_row = (ddf_row+ 2)
    CALL text(ddf_row,2,"Review report in CCLUSERDIR before continuing.")
    SET ddf_row = (ddf_row+ 2)
    CALL text(ddf_row,2,"Enter 'C' to continue or 'Q' to quit:  ")
    CALL accept(ddf_row,41,"A;cu","C"
     WHERE curaccept IN ("C", "Q"))
    IF (curaccept="Q")
     CALL clear(1,1)
     SET message = nowindow
     SET dm_err->emsg = "User elected to quit from report prompt."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    CALL clear(1,1)
    SET message = nowindow
   ELSE
    SET dm_err->eproc = concat("Displaying ",ddf_desc)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    FREE SET file_loc
    SET logical file_loc value(ddf_fname)
    FREE DEFINE rtl2
    DEFINE rtl2 "file_loc"
    SELECT INTO mine
     t.line
     FROM rtl2t t
     HEAD REPORT
      col 30,
      CALL print(ddf_desc), row + 1
     DETAIL
      col 0, t.line, row + 1
     FOOT REPORT
      row + 0
     WITH nocounter, maxcol = 5000
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FREE DEFINE rtl2
    FREE SET file_loc
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_program_stack(null)
   DECLARE stack = vc WITH protect, noconstant("PROGRAM STACK:")
   FOR (i = 1 TO (program_stack_rs->cnt - 1))
     SET stack = build(stack,program_stack_rs->qual[i].name,"->")
   ENDFOR
   IF (program_stack_rs->cnt)
    RETURN(build(stack,program_stack_rs->qual[program_stack_rs->cnt].name))
   ELSE
    RETURN(stack)
   ENDIF
 END ;Subroutine
 IF (check_logfile("dm_txtfnd_csv",".log","DM_TXTFND_CSV_LOAD LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
 DECLARE dtcl_file_name = vc WITH protect, noconstant("")
 DECLARE dtcl_csv_load_ind = i2 WITH protect, noconstant(1)
 SET dm_err->eproc = "Starting DM_TXTFND_CSV_LOAD..."
 IF ((validate(dtla_detail_id,- (123.0))=- (123.0)))
  IF ((script_rec->dm_text_find_detail_id <= 0.0))
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "No DETAIL_ID provided for script.  Unable to proceed."
   IF ((script_rec->dm_text_find_log_id > 0.0))
    CALL dst_add_log_det(script_rec->dm_text_find_log_id,"ERROR",dm_err->emsg,0.0,0.0)
   ENDIF
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_load
  ELSE
   DECLARE dtla_detail_id = f8
   SET dtla_detail_id = script_rec->dm_text_find_detail_id
  ENDIF
 ENDIF
 IF ((script_rec->dm_text_find_log_id <= 0.0))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "No DM_TEXT_FIND_LOG_ID provided for script.  Unable to proceed."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
 SELECT INTO "NL:"
  FROM dm_text_find_detail d
  WHERE dm_text_find_detail_id=dtla_detail_id
   AND active_ind=1
   AND detail_type_flag IN (2, 4)
   AND dm_text_find_detail_id > 0.0
  DETAIL
   script_rec->dm_text_find_detail_id = d.dm_text_find_detail_id
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  CALL dst_add_log_det(script_rec->dm_text_find_log_id,"ERROR",concat("Querying DM_TEXT_FIND_DETAIL:",
    dm_err->emsg),0.0,0.0)
  GO TO exit_load
 ENDIF
 IF (curqual=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "No row found in DM_TEXT_FIND_DETAIL table.  Unable to proceed."
  CALL dst_add_log_det(script_rec->dm_text_find_log_id,"ERROR",dm_err->emsg,0.0,0.0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="DM_TEXT_FIND_CONFIGURATION"
   AND d.info_name="CSV FILE NAME"
  DETAIL
   dtcl_file_name = d.info_char
  WITH nocounter
 ;end select
 IF (check_error("Querying DM_INFO for file name") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  CALL dst_add_log_det(script_rec->dm_text_find_log_id,"ERROR",concat("Querying DM_INFO:",dm_err->
    emsg),0.0,0.0)
  GO TO exit_load
 ENDIF
 IF (curqual=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "No DM_INFO row found containing file name"
  CALL dst_add_log_det(script_rec->dm_text_find_log_id,"ERROR",dm_err->emsg,0.0,0.0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
 IF (findfile(dtcl_file_name,4)=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("The ",dtcl_file_name," file could not be found in ccluserdir.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  CALL dst_add_log_det(script_rec->dm_text_find_log_id,"ERROR",dm_err->emsg,0.0,0.0)
  GO TO exit_load
 ENDIF
 EXECUTE dm_dbimport dtcl_file_name, "dm_txtfnd_csv_read", 1000
 IF (check_error("Reading in csv data") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
#exit_load
END GO
