CREATE PROGRAM dm_cb_objects_load:dba
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
 SET readme_data->message = "Starting Readme..."
 DECLARE dim_filename = c35
 DECLARE obj_stat_check_cnt = i4
 DECLARE first_ind = i2
 DECLARE errmsg = c132
 DECLARE dim_cnt = i4
 DECLARE after_cnt = i4
 DECLARE dcd_cnt = i4
 DECLARE dm_hist_insert(type_in,value_in_old,value_in_new,column_in,ans_in,
  ques_in) = null WITH public
 DECLARE dcol_ques_list(dcol_ques_in) = null WITH public
 DECLARE obj_stat_ndx = i4
 DECLARE found_obj = i2
 DECLARE obj_cnt = i4
 DECLARE exe_ind = i2
 DECLARE execute_actions_ind = i2
 DECLARE act_cnt = i4
 DECLARE search_cnt = i4
 DECLARE found_ques = i2
 DECLARE execute_successful = i2
 DECLARE obj_answer_hold = i4
 DECLARE obj_reorg_cnt = i4
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
 SET obj_answer_hold = 0
 SET found_ques = 0
 SET execute_actions_ind = 0
 SET act_cnt = 0
 SET search_cnt = 0
 SET exe_ind = 0
 SET first_ind = 1
 FREE RECORD rs_objects
 RECORD rs_objects(
   1 list_old[*]
     2 ques_num[1]
       3 question_nbr = i4
     2 obj_type[1]
       3 object_type = vc
     2 obj_stat[1]
       3 object_status = vc
       3 skipped = i2
     2 obj_name[1]
       3 object_name = vc
     2 tab_name[1]
       3 table_name = vc
     2 active[1]
       3 answer_upd = i2
       3 active_ind = i2
   1 list_new[*]
     2 question_nbr = i4
     2 object_type = vc
     2 object_name = vc
     2 table_name = vc
     2 active_ind = i2
 )
 FREE RECORD rs_ques
 RECORD rs_ques(
   1 qual[*]
     2 ques = i4
 )
 SUBROUTINE dcol_ques_list(dcol_ques_in)
   SET found_ques = 0
   SET execute_actions_ind = 1
   FOR (search_cnt = 1 TO size(rs_ques->qual,5))
     IF ((dcol_ques_in=rs_ques->qual[search_cnt].ques))
      SET found_ques = 1
      SET search_cnt = size(rs_ques->qual,5)
     ENDIF
   ENDFOR
   IF (found_ques=0)
    SET act_cnt = (act_cnt+ 1)
    SET stat = alterlist(rs_ques->qual,act_cnt)
    SET rs_ques->qual[act_cnt].ques = dcol_ques_in
   ENDIF
 END ;Subroutine
 SUBROUTINE dm_hist_insert(type_in,value_in_old,value_in_new,column_in,ques_in)
   CASE (type_in)
    OF "CHAR":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = "DM_CB_OBJECTS", column_name =
       column_in,
       change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_txt = trim(value_in_old),
       new_value_txt = trim(value_in_new),
       change_reason = "CSV LOAD", change_process = "DM_DBIMPORT", question_nbr = ques_in
      WITH nocounter
     ;end insert
    OF "NUMBER":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = "DM_CB_OBJECTS", column_name =
       column_in,
       change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_num = cnvtint(trim(value_in_old)),
       new_value_num = cnvtint(trim(value_in_new)),
       change_reason = "CSV LOAD", change_process = "DM_DBIMPORT", question_nbr = ques_in
      WITH nocounter
     ;end insert
    OF "DATE":
     INSERT  FROM dm_cb_history
      SET history_id = seq(dm_clinical_seq,nextval), table_name = "DM_CB_OBJECTS", column_name =
       column_in,
       change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_dt_tm = cnvtdatetime(value_in_old),
       new_value_dt_tm = cnvtdatetime(value_in_new),
       change_reason = "CSV LOAD", change_process = "DM_DBIMPORT", question_nbr = ques_in
      WITH nocounter
     ;end insert
   ENDCASE
 END ;Subroutine
 SET obj_stat_check_cnt = value(size(requestin->list_0,5))
 IF (obj_stat_check_cnt > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Updating DM_CB_OBJECTS.."
  SELECT INTO "nl:"
   FROM dm_cb_objects q
   WHERE  NOT (q.question_nbr IN (99, 4))
   ORDER BY q.question_nbr, q.object_type
   HEAD REPORT
    dcd_cnt = 0
   DETAIL
    dcd_cnt = (dcd_cnt+ 1)
    IF (mod(dcd_cnt,10)=1)
     stat = alterlist(rs_objects->list_old,(dcd_cnt+ 9))
    ENDIF
    rs_objects->list_old[dcd_cnt].obj_type[1].object_type = q.object_type, rs_objects->list_old[
    dcd_cnt].ques_num[1].question_nbr = q.question_nbr, rs_objects->list_old[dcd_cnt].obj_name[1].
    object_name = q.object_name,
    rs_objects->list_old[dcd_cnt].obj_stat[1].object_status = q.object_status, rs_objects->list_old[
    dcd_cnt].tab_name[1].table_name = q.table_name, rs_objects->list_old[dcd_cnt].active[1].
    active_ind = q.active_ind
   FOOT REPORT
    stat = alterlist(rs_objects->list_old,dcd_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(requestin->list_0,5)))
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    dcd_cnt = 0
   DETAIL
    obj_reorg_cnt = 0
    FOR (obj_reorg_cnt = 1 TO 2)
      dcd_cnt = (dcd_cnt+ 1)
      IF (mod(dcd_cnt,10)=1)
       stat = alterlist(rs_objects->list_new,(dcd_cnt+ 9))
      ENDIF
      rs_objects->list_new[dcd_cnt].object_type = requestin->list_0[d.seq].object_type
      IF (obj_reorg_cnt=1)
       rs_objects->list_new[dcd_cnt].object_name = requestin->list_0[d.seq].object_name
      ELSE
       rs_objects->list_new[dcd_cnt].object_name = concat(trim(substring(1,28,requestin->list_0[d.seq
          ].object_name)),"$C")
      ENDIF
      rs_objects->list_new[dcd_cnt].question_nbr = cnvtint(requestin->list_0[d.seq].question_nbr),
      rs_objects->list_new[dcd_cnt].table_name = requestin->list_0[d.seq].table_name, rs_objects->
      list_new[dcd_cnt].table_name = requestin->list_0[d.seq].table_name,
      rs_objects->list_new[dcd_cnt].active_ind = cnvtint(requestin->list_0[d.seq].active_ind)
    ENDFOR
   FOOT REPORT
    stat = alterlist(rs_objects->list_new,dcd_cnt)
   WITH nocounter
  ;end select
  FOR (dcd_cnt = 1 TO size(rs_objects->list_new,5))
    SET obj_stat_ndx = 0
    SET found_obj = 0
    SET obj_cnt = 0
    FOR (obj_cnt = 1 TO size(rs_objects->list_old,5))
      IF ((rs_objects->list_old[obj_cnt].obj_name[1].object_name=rs_objects->list_new[dcd_cnt].
      object_name)
       AND (rs_objects->list_old[obj_cnt].obj_type[1].object_type=rs_objects->list_new[dcd_cnt].
      object_type))
       SET obj_stat_ndx = obj_cnt
       SET obj_cnt = size(rs_objects->list_old,5)
       SET found_obj = 1
      ENDIF
    ENDFOR
    IF (found_obj=1)
     IF ((rs_objects->list_old[obj_stat_ndx].table_name != rs_objects->list_new[dcd_cnt].table_name))
      CALL dm_hist_insert("CHAR",rs_objects->list_old[obj_stat_ndx].tab_name[1].table_name,rs_objects
       ->list_new[dcd_cnt].table_name,"TABLE_NAME",rs_objects->list_new[dcd_cnt].question_nbr)
     ENDIF
     IF ((rs_objects->list_old[obj_stat_ndx].active_ind != rs_objects->list_new[dcd_cnt].active_ind))
      CALL dm_hist_insert("NUMBER",cnvtstring(rs_objects->list_old[obj_stat_ndx].active[1].active_ind
        ),cnvtstring(rs_objects->list_new[dcd_cnt].active_ind),"ACTIVE_IND",rs_objects->list_new[
       dcd_cnt].question_nbr)
      IF ((rs_objects->list_old[obj_stat_ndx].active_ind=0)
       AND (rs_objects->list_new[dcd_cnt].active_ind=1))
       CALL dcol_ques_list(rs_objects->list_new[dcd_cnt].question_nbr)
      ENDIF
     ENDIF
     UPDATE  FROM dm_cb_objects dcd
      SET dcd.table_name = trim(rs_objects->list_new[dcd_cnt].table_name), dcd.active_ind =
       rs_objects->list_new[dcd_cnt].active_ind, dcd.updt_cnt = (dcd.updt_cnt+ 1),
       dcd.updt_applctx = 102, dcd.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (dcd.object_type=rs_objects->list_new[dcd_cnt].object_type)
       AND (dcd.object_name=rs_objects->list_new[dcd_cnt].object_name)
      WITH nocounter
     ;end update
    ELSE
     INSERT  FROM dm_cb_objects dcd
      SET dcd.active_ind = rs_objects->list_new[dcd_cnt].active_ind, dcd.object_name = rs_objects->
       list_new[dcd_cnt].object_name, dcd.table_name = rs_objects->list_new[dcd_cnt].table_name,
       dcd.updt_applctx = 102, dcd.question_nbr = rs_objects->list_new[dcd_cnt].question_nbr, dcd
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       dcd.object_type = rs_objects->list_new[dcd_cnt].object_type
      WITH nocounter
     ;end insert
     CALL dcol_ques_list(rs_objects->list_new[dcd_cnt].question_nbr)
    ENDIF
  ENDFOR
  FOR (dcd_cnt = 1 TO size(rs_objects->list_old,5))
    SET obj_stat_ndx = 0
    SET found_obj = 0
    SET obj_cnt = 0
    FOR (obj_cnt = 1 TO size(rs_objects->list_new,5))
      IF ((rs_objects->list_new[obj_cnt].object_name=rs_objects->list_old[dcd_cnt].obj_name[1].
      object_name))
       SET obj_stat_ndx = obj_cnt
       SET obj_cnt = size(rs_objects->list_new,5)
       SET found_obj = 1
      ENDIF
    ENDFOR
    IF (found_obj=0)
     UPDATE  FROM dm_cb_objects q
      SET q.active_ind = 0, q.updt_applctx = 102, q.updt_cnt = (q.updt_cnt+ 1),
       q.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (rs_objects->list_old[dcd_cnt].object_type=q.object_type)
       AND (rs_objects->list_old[dcd_cnt].object_name=q.object_name)
       AND q.active_ind=1
      WITH nocounter
     ;end update
     IF (curqual > 0)
      CALL dm_hist_insert("NUMBER",cnvtstring(rs_objects->list_old[dcd_cnt].active[1].active_ind),"0",
       "ACTIVE_IND",rs_objects->list_old[dcd_cnt].ques_num[1].question_nbr)
     ENDIF
    ENDIF
  ENDFOR
  IF (execute_actions_ind=1
   AND inhouse_ind != 1)
   SET act_cnt = 0
   FOR (act_cnt = 1 TO size(rs_ques->qual,5))
    UPDATE  FROM dm_cb_answers a
     SET a.action_status = "EXECUTE"
     WHERE (a.question_nbr=rs_ques->qual[act_cnt].ques)
      AND a.answer_status="SELECTED"
      AND a.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual > 0)
     SELECT INTO "nl:"
      FROM dm_cb_answers a
      WHERE (a.question_nbr=rs_ques->qual[act_cnt].ques)
       AND a.answer_status="SELECTED"
       AND a.action_status="EXECUTE"
       AND a.active_ind=1
      HEAD REPORT
       exe_ind = 0
      DETAIL
       exe_ind = 1, obj_answer_hold = a.answer_nbr
      WITH nocounter
     ;end select
     IF (exe_ind=1)
      EXECUTE dm_cb_scan_for_execute rs_ques->qual[act_cnt].ques, "DM_CB_OBJECTS_LOAD"
      IF (execute_successful=0)
       SET readme_data->message = concat("Error performing action for Question Number: ",trim(
         cnvtstring(rs_ques->qual[act_cnt].ques)),", Answer Number: ",trim(cnvtstring(obj_answer_hold
          )),".")
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
  ENDIF
  SELECT INTO "nl:"
   FROM dm_cb_objects di,
    (dummyt d  WITH seq = value(size(requestin->list_0,5)))
   PLAN (d)
    JOIN (di
    WHERE (di.object_type=requestin->list_0[d.seq].object_type)
     AND (di.object_name=requestin->list_0[d.seq].object_name)
     AND (di.table_name=requestin->list_0[d.seq].table_name))
   DETAIL
    CALL echo(concat("Missing object_name(s): ",trim(requestin->list_0[d.seq].object_name))),
    first_ind = 0, readme_data->message = "Readme Failed. Missing rows from DM_CB_OBJECTS."
   WITH outerjoin = d, dontexist
  ;end select
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed.  The requestin structure has not been ",
   "populated with DM_CB_OBJECTS.csv information.")
  GO TO exit_script
 ENDIF
 IF (first_ind=1)
  IF (error(errmsg,0) != 0)
   SET readme_data->message = errmsg
   GO TO exit_script
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message = "All dm_cb_object rows inserted successfully."
 ENDIF
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echo("##################################################")
  CALL echo(readme_data->message)
  CALL echo("##################################################")
 ENDIF
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSEIF ((readme_data->status="S"))
  COMMIT
 ENDIF
END GO
