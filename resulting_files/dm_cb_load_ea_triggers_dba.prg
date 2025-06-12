CREATE PROGRAM dm_cb_load_ea_triggers:dba
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
 SET readme_data->message = "Starting dm_cb_load_ea_triggers..."
 DECLARE name_cnt = i4
 DECLARE trg_question_nbr = i4
 DECLARE tab_cnt = i4
 DECLARE fill_trig(null) = null
 DECLARE get_select_trig_name(null) = null
 DECLARE missing_ind = i2
 DECLARE missing_trg = i2
 DECLARE exe_ind = i2
 DECLARE execute_actions_ind = i2
 DECLARE execute_successful = i2
 DECLARE error_logfile = c132
 DECLARE ea_answer_hold = i4
 DECLARE ea_found_ind = i2
 DECLARE ea_status_hold = c20
 DECLARE dgts_perform_check = i2
 SET dgts_perform_check = 0
 SET ea_found_ind = 0
 SET ea_answer_hold = 0
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
 SET execute_actions_ind = 0
 SET missing_ind = 0
 SET trg_question_nbr = 4
 SET exe_ind = 0
 RECORD trg(
   1 tab[*]
     2 table_name = vc
     2 trigger_name = vc
     2 missing_from_obj = i2
 )
 RECORD obj(
   1 tab[*]
     2 table_name = vc
     2 trigger_name = vc
     2 missing_from_trg = i2
 )
 FREE RECORD failed_table
 RECORD failed_table(
   1 fail[*]
     2 tab_name = vc
     2 trg_name = vc
 )
 SET tab_cnt = 0
 SUBROUTINE ea_get_objects(null)
  SELECT INTO "nl:"
   FROM dm_cb_objects o
   WHERE o.object_type="TRIGGER"
    AND question_nbr=trg_question_nbr
   HEAD REPORT
    tab_cnt = 0
   DETAIL
    tab_cnt = (tab_cnt+ 1)
    IF (mod(tab_cnt,10)=1)
     stat = alterlist(obj->tab,(tab_cnt+ 9))
    ENDIF
    obj->tab[tab_cnt].table_name = cnvtupper(o.table_name), obj->tab[tab_cnt].trigger_name =
    cnvtupper(o.object_name)
   FOOT REPORT
    stat = alterlist(obj->tab,tab_cnt)
   WITH nocounter
  ;end select
  SET tab_cnt = 0
 END ;Subroutine
 SET readme_data->message = "Gathering object data..."
 CALL ea_get_objects(null)
 SET readme_data->message = "Gathering ea_triggers..."
 SELECT INTO "nl:"
  FROM dm_entity_activity_trigger ea
  WHERE ea.active_ind=1
  ORDER BY ea.table_name
  HEAD REPORT
   tab_cnt = 0
  HEAD ea.table_name
   tab_cnt = (tab_cnt+ 1)
   IF (mod(tab_cnt,10)=1)
    stat = alterlist(trg->tab,(tab_cnt+ 9))
   ENDIF
   trg->tab[tab_cnt].table_name = cnvtupper(ea.table_name), trg->tab[tab_cnt].trigger_name = concat(
    trim(substring(1,27,concat("TRG",trim(ea.table_name,3))),3),"_EA"), tab_cnt = (tab_cnt+ 1)
   IF (mod(tab_cnt,10)=1)
    stat = alterlist(trg->tab,(tab_cnt+ 9))
   ENDIF
   trg->tab[tab_cnt].table_name = cnvtupper(ea.table_name), trg->tab[tab_cnt].trigger_name = concat(
    trim(substring(1,28,trg->tab[(tab_cnt - 1)].trigger_name)),"$C")
  FOOT REPORT
   stat = alterlist(trg->tab,tab_cnt)
  WITH nocounter
 ;end select
 IF (size(trg->tab,5)=0)
  SET readme_data->message = "There are no entity activity triggers."
 ENDIF
 SET tab_cnt = 0
 SET obj_cnt = 0
 SET readme_data->message = "Marking triggers that exist in dm_cb_objects.."
 FOR (tab_cnt = 1 TO size(trg->tab,5))
   FOR (obj_cnt = 1 TO size(obj->tab,5))
     IF ((trg->tab[tab_cnt].table_name=obj->tab[obj_cnt].table_name)
      AND (obj->tab[obj_cnt].trigger_name=trg->tab[tab_cnt].trigger_name))
      SET trg->tab[tab_cnt].missing_from_obj = 1
     ENDIF
   ENDFOR
 ENDFOR
 SET tab_cnt = 0
 FOR (tab_cnt = 1 TO size(trg->tab,5))
   IF ((trg->tab[tab_cnt].missing_from_obj=0))
    SET missing_ind = 1
    SET tab_cnt = size(trg->tab,5)
   ENDIF
 ENDFOR
 IF (missing_ind=1)
  SET readme_data->message = "Inserting triggers that do not exist in dm_cb_objects.."
  INSERT  FROM dm_cb_objects o,
    (dummyt d  WITH seq = value(size(trg->tab,5)))
   SET o.object_name = trg->tab[d.seq].trigger_name, o.object_type = "TRIGGER", o.question_nbr =
    trg_question_nbr,
    o.active_ind = 1, o.updt_applctx = 106, o.table_name = trg->tab[d.seq].table_name
   PLAN (d
    WHERE (trg->tab[d.seq].missing_from_obj=0))
    JOIN (o
    WHERE (trg->tab[d.seq].table_name=o.table_name))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  SET execute_actions_ind = 1
 ENDIF
 SET readme_data->message = "Find triggers that exist in dm_cb_objects but not in ea_trigger list.."
 FOR (obj_cnt = 1 TO size(obj->tab,5))
   FOR (tab_cnt = 1 TO size(trg->tab,5))
     IF ((trg->tab[tab_cnt].table_name=obj->tab[obj_cnt].table_name)
      AND (obj->tab[obj_cnt].trigger_name=trg->tab[tab_cnt].trigger_name))
      SET obj->tab[obj_cnt].missing_from_trg = 1
      SET missing_trg = 1
     ENDIF
   ENDFOR
 ENDFOR
 IF (size(trg->tab,5)=0)
  SET missing_trg = 1
 ENDIF
 IF (missing_trg=1)
  SET readme_data->message = "Inactivating objects in dm_cb_objects.."
  FOR (obj_cnt = 1 TO size(obj->tab,5))
    IF ((obj->tab[obj_cnt].missing_from_trg=0))
     UPDATE  FROM dm_cb_objects o
      SET o.active_ind = 0, o.updt_applctx = 106, o.updt_cnt = o.updt_cnt,
       o.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (o.table_name=obj->tab[obj_cnt].table_name)
       AND (o.object_name=obj->tab[obj_cnt].trigger_name)
       AND o.active_ind=1
      WITH nocounter
     ;end update
     IF (curqual > 0)
      SET readme_data->message = "Logging history.."
      INSERT  FROM dm_cb_history
       SET history_id = seq(dm_clinical_seq,nextval), table_name = "DM_CB_OBJECTS", column_name =
        "ACTIVE_IND",
        change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_num = 1, new_value_num = 0,
        change_reason = "IN DM_CB_OBJECTS, NOT LIST", change_process = "DM_CB_LOAD_EA_TRIG",
        question_nbr = trg_question_nbr
       WITH nocounter
      ;end insert
     ENDIF
    ELSE
     UPDATE  FROM dm_cb_objects o
      SET o.active_ind = 1, o.updt_applctx = 106, o.updt_cnt = o.updt_cnt,
       o.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (o.table_name=obj->tab[obj_cnt].table_name)
       AND (o.object_name=obj->tab[obj_cnt].trigger_name)
       AND o.active_ind=0
      WITH nocounter
     ;end update
     IF (curqual > 0)
      SET readme_data->message = "Logging history.."
      INSERT  FROM dm_cb_history
       SET history_id = seq(dm_clinical_seq,nextval), table_name = "DM_CB_OBJECTS", column_name =
        "ACTIVE_IND",
        change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_num = 0, new_value_num = 1,
        change_reason = "REACTIVATE IN DM_CB_OBJECTS", change_process = "DM_CB_LOAD_EA_TRIG",
        question_nbr = trg_question_nbr
       WITH nocounter
      ;end insert
      SET execute_actions_ind = 1
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF (execute_actions_ind=1
  AND inhouse_ind != 1)
  SET ea_answer_hold = 0
  SELECT INTO "nl:"
   FROM dm_cb_answers a
   WHERE a.question_nbr=trg_question_nbr
    AND a.answer_status="SELECTED"
    AND a.active_ind=1
   DETAIL
    ea_answer_hold = a.answer_nbr, ea_status_hold = a.action_status
   WITH nocounter
  ;end select
  IF (curqual > 0)
   IF (ea_status_hold != "EXECUTE")
    UPDATE  FROM dm_cb_answers a
     SET a.action_status = "EXECUTE", a.updt_cnt = (a.updt_cnt+ 1), a.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      a.updt_applctx = 106
     WHERE a.question_nbr=trg_question_nbr
      AND a.answer_status="SELECTED"
      AND a.active_ind=1
     WITH nocounter
    ;end update
    INSERT  FROM dm_cb_history
     SET history_id = seq(dm_clinical_seq,nextval), table_name = "DM_CB_ANSWERS", column_name =
      "ACTION_STATUS",
      change_dt_tm = cnvtdatetime(curdate,curtime3), old_value_txt = ea_status_hold, new_value_txt =
      "EXECUTE",
      change_reason = "EXECUTE FROM README", change_process = "DM_CB_LOAD_EA_TRIG", question_nbr =
      trg_question_nbr
     WITH nocounter
    ;end insert
   ENDIF
   SET ea_found_ind = 1
  ENDIF
  IF (ea_found_ind=1)
   SELECT INTO "nl:"
    FROM dm_cb_answers a
    WHERE a.question_nbr=trg_question_nbr
     AND a.answer_status="SELECTED"
     AND a.action_status="EXECUTE"
     AND a.active_ind=1
    HEAD REPORT
     exe_ind = 0
    DETAIL
     exe_ind = 1, ea_answer_hold = a.answer_nbr
    WITH nocounter
   ;end select
   IF (exe_ind=1)
    EXECUTE dm_cb_scan_for_execute trg_question_nbr, "EA_TRIG_LOAD"
    IF (execute_successful=0)
     SET readme_data->message = concat("Error performing action for Question Number: ",trim(
       cnvtstring(trg_question_nbr)),", Answer Number: ",trim(cnvtstring(ea_answer_hold)),
      ". Log File: ",
      error_logfile,".")
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SET obj_cnt = 0
 SET missing_trg = 0
 SET tab_cnt = 0
 CALL ea_get_objects(null)
 IF (size(trg->tab,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(trg->tab,5)))
   PLAN (d
    WHERE d.seq > 0)
   DETAIL
    missing_trg = 0
    FOR (obj_cnt = 1 TO size(obj->tab,5))
      IF ((trg->tab[d.seq].table_name=obj->tab[obj_cnt].table_name)
       AND (trg->tab[d.seq].trigger_name=obj->tab[obj_cnt].trigger_name))
       missing_trg = 1, obj_cnt = size(obj->tab,5)
      ENDIF
    ENDFOR
    IF (missing_trg=0)
     tab_cnt = (tab_cnt+ 1), stat = alterlist(failed_table->fail,tab_cnt), failed_table->fail[tab_cnt
     ].tab_name = trg->tab[d.seq].table_name,
     failed_table->fail[tab_cnt].trg_name = trg->tab[d.seq].trigger_name
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET tab_cnt = 0
 IF (size(failed_table->fail,5) > 0)
  FOR (tab_cnt = 1 TO size(failed_table->fail,5))
    CALL echo(concat("Trigger not in dm_cb_objects: ",trim(failed_table->fail[tab_cnt].trg_name),
      " for table ",failed_table->fail[tab_cnt].tab_name,"."))
  ENDFOR
  SET readme_data->message = "Error Occurred:EA_triggers not loaded into dm_cb_objects."
 ELSE
  SET readme_data->message = "EA triggers successfully inserted into dm_cb_objects"
  SET readme_data->status = "S"
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
