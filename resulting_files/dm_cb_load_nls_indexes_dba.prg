CREATE PROGRAM dm_cb_load_nls_indexes:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Starting dm_cb_load_nls_indexes..."
 DECLARE tab_cnt = i4
 DECLARE ind_cnt = i4
 DECLARE obj_cnt = i4
 DECLARE ind_size = i4
 DECLARE nls_cnt = i4
 DECLARE ind_cnt_db = i4
 DECLARE ind_cnt_obj = i4
 DECLARE execute_ind = i2
 DECLARE nls_question_nbr = i4
 DECLARE nls_load_objects(null) = null WITH public
 DECLARE nls_reset_variables(null) = null WITH public
 DECLARE exe_ind = i2
 DECLARE execute_actions_ind = i2
 DECLARE execute_successful = i2
 DECLARE error_logfile = c132
 DECLARE nls_answer_hold = i4
 DECLARE nls_ans_status = c20
 DECLARE nls_ans_nbr = i4
 DECLARE dgts_perform_check = i2
 SET dgts_perform_check = 0
 DECLARE inhouse_ind = i2
 SET inhouse_ind = 0
 SELECT INTO "nl:"
  FROM dm_info
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="INHOUSE DOMAIN"
  DETAIL
   inhouse_ind = 1
  WITH nocounter
 ;end select
 SET dgts_perform_check = checkdic("DM_CB_OBJECTS","T",0)
 IF (dgts_perform_check=0)
  SET readme_data->status = "S"
  SET readme_data->message = "DM_CB_OBJECTS definition does not exist."
  GO TO exit_script
 ELSEIF (dgts_perform_check=2)
  SELECT INTO "nl:"
   FROM user_tab_columns u
   WHERE u.table_name="DM_CB_OBJECTS"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET readme_data->status = "S"
   SET readme_data->message = "DM_CB_OBJECTS table does not exist."
   GO TO exit_script
  ENDIF
 ENDIF
 SET execute_successful = 0
 SET execute_actions_ind = 0
 SET nls_answer_hold = 0
 SET exe_ind = 0
 SET nls_question_nbr = 1
 FREE RECORD rs_index_db
 RECORD rs_index_db(
   1 nls_table[*]
     2 nls_table_name = vc
     2 nls_index[*]
       3 nls_ind_name = vc
       3 obj_in_db = i2
       3 error_chk = i2
 )
 FREE RECORD rs_index_obj
 RECORD rs_index_obj(
   1 obj_table[*]
     2 obj_table_name = vc
     2 obj_index[*]
       3 obj_ind_name = vc
       3 missing_obj = i2
 )
 FREE RECORD failed_table
 RECORD failed_table(
   1 fail[*]
     2 tab_name = vc
     2 ind_name = vc
 )
 CALL nls_reset_variables(null)
 CALL nls_load_objects(null)
 CALL fill_nls_indexes(null)
 CALL nls_reset_variables(null)
 IF (size(rs_index_obj->obj_table,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(rs_index_obj->obj_table,5)))
   PLAN (d
    WHERE d.seq > 0)
   DETAIL
    FOR (tab_cnt = 1 TO size(rs_index_db->nls_table,5))
      FOR (ind_cnt_obj = 1 TO size(rs_index_obj->obj_table[d.seq].obj_index,5))
        FOR (ind_cnt_db = 1 TO size(rs_index_db->nls_table[tab_cnt].nls_index,5))
          IF ((rs_index_db->nls_table[tab_cnt].nls_index[ind_cnt_db].nls_ind_name=rs_index_obj->
          obj_table[d.seq].obj_index[ind_cnt_obj].obj_ind_name))
           rs_index_db->nls_table[tab_cnt].nls_index[ind_cnt_db].obj_in_db = 1
          ENDIF
        ENDFOR
      ENDFOR
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
 CALL nls_reset_variables(null)
 FOR (tab_cnt = 1 TO size(rs_index_db->nls_table,5))
   FOR (ind_cnt = 1 TO size(rs_index_db->nls_table[tab_cnt].nls_index,5))
     IF ((rs_index_db->nls_table[tab_cnt].nls_index[ind_cnt].obj_in_db=0))
      INSERT  FROM dm_cb_objects o
       SET o.table_name = rs_index_db->nls_table[tab_cnt].nls_table_name, o.object_name = rs_index_db
        ->nls_table[tab_cnt].nls_index[ind_cnt].nls_ind_name, o.question_nbr = nls_question_nbr,
        o.active_ind = 1, o.object_type = "INDEX", o.updt_applctx = 10,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_task = 121
       WITH nocounter
      ;end insert
      SET execute_actions_ind = 1
     ENDIF
   ENDFOR
 ENDFOR
 CALL nls_reset_variables(null)
 FOR (tab_cnt = 1 TO size(rs_index_obj->obj_table,5))
   SET stat = alterlist(rs_index_obj->obj_table[tab_cnt].obj_index,0)
 ENDFOR
 SET stat = alterlist(rs_index_obj->obj_table,0)
 CALL nls_reset_variables(null)
 CALL nls_load_objects(null)
 FOR (obj_cnt = 1 TO size(rs_index_obj->obj_table,5))
   FOR (tab_cnt = 1 TO size(rs_index_db->nls_table,5))
     FOR (ind_cnt_obj = 1 TO size(rs_index_obj->obj_table[obj_cnt].obj_index,5))
       FOR (ind_cnt_db = 1 TO size(rs_index_db->nls_table[tab_cnt].nls_index,5))
         IF ((rs_index_db->nls_table[tab_cnt].nls_index[ind_cnt_db].nls_ind_name=rs_index_obj->
         obj_table[obj_cnt].obj_index[ind_cnt_obj].obj_ind_name))
          SET rs_index_obj->obj_table[obj_cnt].obj_index[ind_cnt_obj].missing_obj = 1
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 CALL nls_reset_variables(null)
 FOR (obj_cnt = 1 TO size(rs_index_obj->obj_table,5))
   FOR (ind_cnt = 1 TO size(rs_index_obj->obj_table[obj_cnt].obj_index,5))
     IF ((rs_index_obj->obj_table[obj_cnt].obj_index[ind_cnt].missing_obj=1))
      UPDATE  FROM dm_cb_objects o
       SET o.active_ind = 1, o.updt_cnt = (o.updt_cnt+ 1), o.updt_dt_tm = cnvtdatetime(curdate,
         curtime3),
        o.updt_applctx = 105
       WHERE (o.table_name=rs_index_obj->obj_table[obj_cnt].obj_table_name)
        AND (o.object_name=rs_index_obj->obj_table[obj_cnt].obj_index[ind_cnt].obj_ind_name)
        AND o.object_type="INDEX"
        AND o.active_ind=0
       WITH nocounter
      ;end update
      IF (curqual > 0)
       INSERT  FROM dm_cb_history
        SET history_id = seq(dm_clinical_seq,nextval), table_name = "DM_CB_OBJECTS", column_name =
         "ACTIVE_IND",
         change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_num = 0, new_value_num = 1,
         change_reason = "IN USER_INDEXES, REACTIVATE", change_process = "DM_CB_LOAD_NLS_IND",
         question_nbr = nls_question_nbr
        WITH nocounter
       ;end insert
       SET execute_actions_ind = 1
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 CALL nls_reset_variables(null)
 CALL nls_load_objects(null)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rs_index_db->nls_table,5)))
  PLAN (d
   WHERE d.seq > 0)
  DETAIL
   missing_trg = 0
   FOR (obj_cnt = 1 TO size(rs_index_obj->obj_table,5))
    ind_cnt = 0,
    FOR (ind_cnt = 1 TO size(rs_index_obj->obj_table[obj_cnt].obj_index,5))
     nls_cnt = 0,
     FOR (nls_cnt = 1 TO size(rs_index_db->nls_table[d.seq].nls_index,5))
       IF ((rs_index_db->nls_table[d.seq].nls_index[nls_cnt].nls_ind_name=rs_index_obj->obj_table[
       obj_cnt].obj_index[ind_cnt].obj_ind_name))
        rs_index_db->nls_table[d.seq].nls_index[nls_cnt].error_chk = 1, missing_trg = 1, nls_cnt =
        size(rs_index_db->nls_table[d.seq].nls_index,5)
       ENDIF
     ENDFOR
    ENDFOR
   ENDFOR
  WITH nocounter
 ;end select
 SET obj_cnt = 0
 SET ind_cnt = 0
 SET tab_cnt = 0
 FOR (obj_cnt = 1 TO size(rs_index_db->nls_table,5))
   FOR (ind_cnt = 1 TO size(rs_index_db->nls_table[obj_cnt].nls_index,5))
     IF ((rs_index_db->nls_table[obj_cnt].nls_index[ind_cnt].error_chk=0))
      SET tab_cnt = (tab_cnt+ 1)
      SET stat = alterlist(failed_table->fail,tab_cnt)
      SET failed_table->fail[tab_cnt].tab_name = rs_index_db->nls_table[obj_cnt].nls_table_name
      SET failed_table->fail[tab_cnt].ind_name = rs_index_db->nls_table[obj_cnt].nls_index[ind_cnt].
      nls_ind_name
     ENDIF
   ENDFOR
 ENDFOR
 SET tab_cnt = 0
 IF (size(failed_table->fail,5) > 0)
  FOR (tab_cnt = 1 TO size(failed_table->fail,5))
    CALL echo(concat("Index not in dm_cb_objects: ",trim(failed_table->fail[tab_cnt].ind_name),
      " for table ",failed_table->fail[tab_cnt].tab_name,"."))
  ENDFOR
  SET readme_data->message = "Error Occurred:NLS_INDEXES not loaded into dm_cb_objects."
  SET readme_data->status = "F"
  GO TO exit_script
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "NLS_INDEXES successfully inserted into dm_cb_objects"
 ENDIF
 IF (execute_actions_ind=1
  AND inhouse_ind != 1)
  SELECT INTO "nl:"
   FROM dm_cb_answers a
   WHERE a.question_nbr=nls_question_nbr
    AND a.answer_status="SELECTED"
    AND a.active_ind=1
   DETAIL
    nls_ans_status = a.action_status, nls_ans_nbr = a.answer_nbr
   WITH nocounter
  ;end select
  IF (curqual > 0)
   IF (nls_ans_status != "EXECUTE")
    UPDATE  FROM dm_cb_answers a
     SET a.action_status = "EXECUTE"
     WHERE a.question_nbr=nls_question_nbr
      AND a.answer_status="SELECTED"
      AND a.active_ind=1
     WITH nocounter
    ;end update
    INSERT  FROM dm_cb_history
     SET history_id = seq(dm_clinical_seq,nextval), table_name = "DM_CB_ANSWERS", column_name =
      "ANSWER_STATUS",
      change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_txt = nls_ans_status, new_value_txt =
      "EXECUTE",
      change_reason = "EXECUTE ANSWER", change_process = "DM_CB_LOAD_NLS_IND", question_nbr =
      nls_question_nbr,
      answer_nbr = nls_ans_nbr
     WITH nocounter
    ;end insert
   ENDIF
   SELECT INTO "nl:"
    FROM dm_cb_answers a
    WHERE a.question_nbr=nls_question_nbr
     AND a.answer_status="SELECTED"
     AND a.action_status="EXECUTE"
     AND a.active_ind=1
    HEAD REPORT
     exe_ind = 0
    DETAIL
     exe_ind = 1, nls_answer_hold = a.answer_nbr
    WITH nocounter
   ;end select
   IF (exe_ind=1)
    EXECUTE dm_cb_scan_for_execute nls_question_nbr, "NLS_LOAD"
    IF (execute_successful=0)
     SET readme_data->message = concat("Error performing action for Question_nbr: ",trim(cnvtstring(
        nls_question_nbr)),", Answer_nbr: ",trim(cnvtstring(nls_answer_hold)),
      ". Index drops failed. Log File: ",
      error_logfile,".")
     SET readme_data->status = "F"
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE fill_nls_indexes(null)
  DECLARE fni_reorg_cnt = i2
  SELECT DISTINCT INTO "nl:"
   i.index_name
   FROM user_ind_columns i
   WHERE i.column_name="*_NLS"
   ORDER BY i.table_name
   HEAD REPORT
    tab_cnt = 0
   HEAD i.table_name
    tab_cnt = (tab_cnt+ 1)
    IF (mod(tab_cnt,100)=1)
     stat = alterlist(rs_index_db->nls_table,(tab_cnt+ 99))
    ENDIF
    rs_index_db->nls_table[tab_cnt].nls_table_name = i.table_name, ind_cnt = 0
   DETAIL
    IF ( NOT (findstring("$C",i.index_name)))
     ind_cnt = (ind_cnt+ 1)
     IF (mod(ind_cnt,10)=1)
      stat = alterlist(rs_index_db->nls_table[tab_cnt].nls_index,(ind_cnt+ 9))
     ENDIF
     rs_index_db->nls_table[tab_cnt].nls_index[ind_cnt].nls_ind_name = concat(trim(substring(1,28,i
        .index_name)),"$C")
    ENDIF
    ind_cnt = (ind_cnt+ 1)
    IF (mod(ind_cnt,10)=1)
     stat = alterlist(rs_index_db->nls_table[tab_cnt].nls_index,(ind_cnt+ 9))
    ENDIF
    rs_index_db->nls_table[tab_cnt].nls_index[ind_cnt].nls_ind_name = i.index_name
   FOOT  i.table_name
    stat = alterlist(rs_index_db->nls_table[tab_cnt].nls_index,ind_cnt), ind_cnt = 0
   FOOT REPORT
    stat = alterlist(rs_index_db->nls_table,tab_cnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE nls_load_objects(null)
   SELECT INTO "nl:"
    FROM dm_cb_objects i
    WHERE i.object_type="INDEX"
     AND i.question_nbr=nls_question_nbr
    ORDER BY i.table_name
    HEAD REPORT
     tab_cnt = 0
    HEAD i.table_name
     tab_cnt = (tab_cnt+ 1)
     IF (mod(tab_cnt,100)=1)
      stat = alterlist(rs_index_obj->obj_table,(tab_cnt+ 99))
     ENDIF
     rs_index_obj->obj_table[tab_cnt].obj_table_name = i.table_name, ind_cnt = 0
    DETAIL
     ind_cnt = (ind_cnt+ 1)
     IF (mod(ind_cnt,10)=1)
      stat = alterlist(rs_index_obj->obj_table[tab_cnt].obj_index,(ind_cnt+ 9))
     ENDIF
     rs_index_obj->obj_table[tab_cnt].obj_index[ind_cnt].obj_ind_name = i.object_name
    FOOT  i.table_name
     stat = alterlist(rs_index_obj->obj_table[tab_cnt].obj_index,ind_cnt), ind_cnt = 0
    FOOT REPORT
     stat = alterlist(rs_index_obj->obj_table,tab_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE nls_reset_variables(null)
   SET tab_cnt = 0
   SET ind_cnt = 0
   SET ind_size = 0
   SET ind_cnt_db = 0
   SET ind_cnt_obj = 0
   SET obj_cnt = 0
   SET nls_cnt = 0
 END ;Subroutine
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSEIF ((readme_data->status="S"))
  COMMIT
 ENDIF
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echo("##################################################")
  CALL echo(readme_data->message)
  CALL echo("##################################################")
 ENDIF
END GO
