CREATE PROGRAM dm_cb_load_by_dms:dba
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
 DECLARE ques_check_cnt = i4
 DECLARE first_ind = i2
 DECLARE errmsg = c132
 DECLARE tab_cnt = i4
 DECLARE sec_cnt = i4
 DECLARE dtd_cnt = i4
 DECLARE obj_ndx = i4
 DECLARE found_ind = i2
 DECLARE act_cnt = i4
 DECLARE fail_ind = i2
 DECLARE search_cnt = i4
 DECLARE found_ques = i2
 DECLARE error_logfile = c132
 DECLARE dms_question_nbr = i4
 DECLARE dgts_perform_check = i2
 SET dgts_perform_check = 0
 SET dms_question_nbr = 99
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
 SET found_ind = 0
 SET first_ind = 0
 SET found_ques = 0
 SET act_cnt = 0
 SET search_cnt = 0
 FREE RECORD rs_table_hold
 RECORD rs_table_hold(
   1 section[*]
     2 data_model_section = vc
     2 question_nbr = i4
     2 sec_table[*]
       3 table_name = vc
       3 is_there = i2
       3 active_ind = i2
       3 in_table_not_csv = i2
 )
 FREE RECORD inactive_objects
 RECORD inactive_objects(
   1 sec[*]
     2 io_dms = vc
     2 tab[*]
       3 io_table = vc
       3 io_question = i4
 )
 FREE RECORD table_check
 RECORD table_check(
   1 dms_list[*]
     2 chk_dms = vc
     2 chk_tab = vc
     2 chk_valid = i2
     2 chk_active = i2
 )
 FREE RECORD failed_table
 RECORD failed_table(
   1 fail[*]
     2 tab_name = vc
 )
 FREE RECORD rs_ques
 RECORD rs_ques(
   1 qual[*]
     2 ques = i4
 )
 SET ques_check_cnt = value(size(requestin->list_0,5))
 IF (ques_check_cnt > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Finding tables in data model sections listed in csv.."
  SELECT INTO "nl:"
   FROM dm_tables_doc dtd,
    (dummyt d  WITH seq = value(size(requestin->list_0,5)))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (dtd
    WHERE (requestin->list_0[d.seq].data_model_section=dtd.data_model_section))
   ORDER BY dtd.data_model_section, dtd.table_name
   HEAD REPORT
    sec_cnt = 0
   HEAD dtd.data_model_section
    sec_cnt = (sec_cnt+ 1)
    IF (mod(sec_cnt,10)=1)
     stat = alterlist(rs_table_hold->section,(sec_cnt+ 9))
    ENDIF
    rs_table_hold->section[sec_cnt].data_model_section = dtd.data_model_section, rs_table_hold->
    section[sec_cnt].question_nbr = cnvtint(requestin->list_0[d.seq].question_nbr), tab_cnt = 0
   DETAIL
    tab_cnt = (tab_cnt+ 1)
    IF (mod(tab_cnt,100)=1)
     stat = alterlist(rs_table_hold->section[sec_cnt].sec_table,(tab_cnt+ 99))
    ENDIF
    rs_table_hold->section[sec_cnt].sec_table[tab_cnt].table_name = dtd.table_name
   FOOT  dtd.data_model_section
    stat = alterlist(rs_table_hold->section[sec_cnt].sec_table,tab_cnt)
   FOOT REPORT
    stat = alterlist(rs_table_hold->section,sec_cnt)
   WITH nocounter
  ;end select
  IF (size(rs_table_hold->section,5) > 0)
   SET readme_data->message = "Cross reference tables with the tables in dm_cb_objects.."
   SET tab_cnt = 0
   SET sec_cnt = 0
   SELECT INTO "nl:"
    FROM dm_cb_objects o,
     (dummyt d  WITH seq = value(size(rs_table_hold->section,5)))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (o
     WHERE (o.question_nbr=rs_table_hold->section[d.seq].question_nbr))
    DETAIL
     obj_ndx = 0
     FOR (obj_ndx = 1 TO size(rs_table_hold->section[d.seq].sec_table,5))
       IF ((rs_table_hold->section[d.seq].sec_table[obj_ndx].table_name=o.object_name))
        rs_table_hold->section[d.seq].sec_table[obj_ndx].is_there = 1, rs_table_hold->section[d.seq].
        sec_table[obj_ndx].active_ind = o.active_ind, obj_ndx = size(rs_table_hold->section[d.seq].
         sec_table,5)
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   SET readme_data->message = "Insert the tables that are not in dm_cb_objects.."
   SET sec_cnt = 0
   FOR (sec_cnt = 1 TO size(rs_table_hold->section,5))
    SET tab_cnt = 0
    FOR (tab_cnt = 1 TO size(rs_table_hold->section[sec_cnt].sec_table,5))
      IF ((rs_table_hold->section[sec_cnt].sec_table[tab_cnt].is_there=0))
       INSERT  FROM dm_cb_objects o
        SET o.object_type = "TABLE", o.object_name = rs_table_hold->section[sec_cnt].sec_table[
         tab_cnt].table_name, o.table_name = rs_table_hold->section[sec_cnt].sec_table[tab_cnt].
         table_name,
         o.question_nbr = rs_table_hold->section[sec_cnt].question_nbr, o.active_ind = 1, o
         .updt_applctx = 104
        WITH nocounter
       ;end insert
       SET found_ques = 0
       FOR (search_cnt = 1 TO size(rs_ques->qual,5))
         IF ((rs_table_hold->section[sec_cnt].question_nbr=rs_ques->qual[search_cnt].ques))
          SET found_ques = 1
          SET search_cnt = size(rs_ques->qual,5)
         ENDIF
       ENDFOR
       IF (found_ques=0)
        SET act_cnt = (act_cnt+ 1)
        SET stat = alterlist(rs_ques->qual,act_cnt)
        SET rs_ques->qual[act_cnt].ques = rs_table_hold->section[sec_cnt].question_nbr
       ENDIF
      ELSE
       IF ((rs_table_hold->section[sec_cnt].sec_table[tab_cnt].active_ind=0))
        UPDATE  FROM dm_cb_objects o
         SET o.active_ind = 1, o.updt_cnt = (o.updt_cnt+ 1), o.updt_dt_tm = cnvtdatetime(curdate,
           curtime3),
          o.updt_applctx = 104
         WHERE o.object_type="TABLE"
          AND (o.object_name=rs_table_hold->section[sec_cnt].sec_table[tab_cnt].table_name)
          AND o.active_ind=0
         WITH nocounter
        ;end update
        IF (curqual > 0)
         INSERT  FROM dm_cb_history
          SET history_id = seq(dm_clinical_seq,nextval), table_name = "DM_CB_OBJECTS", column_name =
           "ACTIVE_IND",
           change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_num = 0, new_value_num = 1,
           change_reason = "IN DM_CB_OBJECTS,NOT LIST", change_process = "DM_CB_LOAD_BY_DMS",
           question_nbr = rs_table_hold->section[sec_cnt].question_nbr
          WITH nocounter
         ;end insert
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
  ELSE
   SET readme_data->message = "No tables to load into DM_CB_OBJECTS."
  ENDIF
  SET readme_data->message =
  "get a list of tables to inactivate that are in dm_cb_objects, but not in csv.."
  SET act_cnt = 0
  SELECT INTO "nl:"
   FROM dm_tables_doc d,
    dm_cb_objects o
   WHERE o.object_type="TABLE"
    AND o.object_name=d.table_name
    AND o.question_nbr=dms_question_nbr
   ORDER BY d.data_model_section
   HEAD REPORT
    sec_cnt = 0, act_cnt = 0
   HEAD d.data_model_section
    sec_cnt = 0, found_ind = 0, first_ind = 0
    FOR (sec_cnt = 1 TO size(requestin->list_0,5))
      IF ((requestin->list_0[sec_cnt].data_model_section=d.data_model_section))
       found_ind = 1, first_ind = 1
      ENDIF
    ENDFOR
    tab_cnt = 0
    IF (first_ind=0)
     act_cnt = (act_cnt+ 1), stat = alterlist(inactive_objects->sec,act_cnt), inactive_objects->sec[
     act_cnt].io_dms = d.data_model_section,
     first_ind = 1
    ENDIF
   DETAIL
    IF (found_ind=0)
     tab_cnt = (tab_cnt+ 1), stat = alterlist(inactive_objects->sec[act_cnt].tab,tab_cnt),
     inactive_objects->sec[act_cnt].tab[tab_cnt].io_table = d.table_name,
     inactive_objects->sec[act_cnt].tab[tab_cnt].io_question = o.question_nbr
    ENDIF
   FOOT  d.data_model_section
    sec_cnt = 0
   FOOT REPORT
    found_ind = 0, first_ind = 0, sec_cnt = 0,
    tab_cnt = 0, act_cnt = 0
   WITH nocounter
  ;end select
  IF (size(inactive_objects->sec,5) > 0)
   FOR (sec_cnt = 1 TO size(inactive_objects->sec,5))
     FOR (tab_cnt = 1 TO size(inactive_objects->sec[sec_cnt].tab,5))
       SET readme_data->message = "inactivate invalid tables"
       UPDATE  FROM dm_cb_objects o
        SET o.active_ind = 0, o.updt_cnt = (o.updt_cnt+ 1), o.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         o.updt_applctx = 104
        WHERE o.object_type="TABLE"
         AND (o.object_name=inactive_objects->sec[sec_cnt].tab[tab_cnt].io_table)
         AND o.active_ind=1
        WITH nocounter
       ;end update
       IF (curqual > 0)
        INSERT  FROM dm_cb_history
         SET history_id = seq(dm_clinical_seq,nextval), table_name = "DM_CB_OBJECTS", column_name =
          "ACTIVE_IND",
          change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_num = 1, new_value_num = 0,
          change_reason = "IN DM_CB_OBJECTS,NOT LIST", change_process = "DM_CB_LOAD_BY_DMS",
          question_nbr = inactive_objects->sec[sec_cnt].tab[tab_cnt].io_question
         WITH nocounter
        ;end insert
       ENDIF
     ENDFOR
   ENDFOR
  ENDIF
  SET readme_data->message = "Checking if tables in dm_cb_objects exist in data model section"
  SELECT INTO "nl:"
   FROM dm_cb_objects o,
    dm_tables_doc dtd
   PLAN (o
    WHERE o.object_type="TABLE"
     AND o.question_nbr=dms_question_nbr)
    JOIN (dtd
    WHERE dtd.table_name=o.object_name)
   HEAD REPORT
    sec_cnt = 0, fail_ind = 0, tab_cnt = 0
   DETAIL
    sec_cnt = (sec_cnt+ 1)
    IF (mod(sec_cnt,100)=1)
     stat = alterlist(table_check->dms_list,(sec_cnt+ 99))
    ENDIF
    table_check->dms_list[sec_cnt].chk_tab = o.object_name, table_check->dms_list[sec_cnt].chk_dms =
    dtd.data_model_section, table_check->dms_list[sec_cnt].chk_active = o.active_ind,
    act_cnt = 0
    FOR (act_cnt = 1 TO size(requestin->list_0,5))
      IF ((dtd.data_model_section=requestin->list_0[act_cnt].data_model_section))
       table_check->dms_list[sec_cnt].chk_valid = 1
      ENDIF
    ENDFOR
    IF ((table_check->dms_list[sec_cnt].chk_valid=0)
     AND (table_check->dms_list[sec_cnt].chk_active=1))
     fail_ind = 1, tab_cnt = (tab_cnt+ 1)
     IF (mod(tab_cnt,10)=1)
      stat = alterlist(failed_table->fail,(tab_cnt+ 9))
     ENDIF
     failed_table->fail[tab_cnt].tab_name = table_check->dms_list[sec_cnt].chk_tab
    ENDIF
   FOOT REPORT
    stat = alterlist(table_check->dms_list,sec_cnt)
    IF (fail_ind=1)
     stat = alterlist(failed_table->fail,tab_cnt)
    ENDIF
   WITH nocounter
  ;end select
  SET tab_cnt = 0
  IF (fail_ind=1)
   FOR (tab_cnt = 1 TO size(failed_table->fail,5))
     CALL echo(concat("Tables not in dm_cb_objects: ",trim(failed_table->fail[tab_cnt].tab_name)))
   ENDFOR
   SET readme_data->message = "Tables missing from DM_CB_OBJECTS. Error."
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "Tables loaded into DM_CB_OBJECTS successfully."
  ENDIF
 ENDIF
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
