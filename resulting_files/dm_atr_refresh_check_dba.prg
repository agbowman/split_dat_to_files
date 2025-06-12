CREATE PROGRAM dm_atr_refresh_check:dba
 SET feature_status = fillstring(20," ")
 SET ref = logical("DM_REFR_MODE")
 SET readme_ind = validate(request->setup_proc[1].env_id,0.0)
 IF (reamde_ind=0.0)
  SET feature_status = "('2B','2D','5')"
 ELSE
  SET feature_status = "('5')"
 ENDIF
 CASE (request->setup_proc[1].process_id)
  OF 631:
   SET x = 0
   SET y = 0
   SET z = 0
   SELECT INTO "nl:"
    x = count(*)
    FROM dm_application d
    WHERE deleted_ind=0
     AND sqlpassthru(concat("(d.application_number,d.schema_date) in ",
      "(select application_number, max(schema_date) from dm_application dm, dm_features df where 1=1"
      ))
     AND sqlpassthru(concat(" UPPER(df.feature_status) in ",trim(feature_status)," "))
     AND sqlpassthru(" dm.feature_number = df.feature_number group by application_number )")
    DETAIL
     y = x
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x = count(*)
    FROM application a
    DETAIL
     z = x
    WITH nocounter
   ;end select
   IF (z < y)
    SET request->setup_proc[1].success_ind = 0
    SET request->setup_proc[1].error_msg = "ATR Application refresh NOT successful!"
   ELSE
    SET request->setup_proc[1].success_ind = 1
    SET request->setup_proc[1].error_msg = "ATR Application refresh successful!"
   ENDIF
  OF 632:
   SET x = 0
   SET y = 0
   SET z = 0
   SELECT INTO "nl:"
    x = count(*)
    FROM dm_application_task d
    WHERE deleted_ind=0
     AND sqlpassthru(concat("(d.task_number,d.schema_date) in ",
      "(select task_number, max(schema_date) from dm_application_task dm, dm_features df where 1=1"))
     AND sqlpassthru(concat(" UPPER(df.feature_status) in ",trim(feature_status)," "))
     AND sqlpassthru(" dm.feature_number = df.feature_number group by task_number )")
    DETAIL
     y = x
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x = count(*)
    FROM application_task a
    DETAIL
     z = x
    WITH nocounter
   ;end select
   IF (z < y)
    SET request->setup_proc[1].success_ind = 0
    SET request->setup_proc[1].error_msg = "ATR Task refresh NOT successful!"
   ELSE
    SET request->setup_proc[1].success_ind = 1
    SET request->setup_proc[1].error_msg = "ATR Task refresh successful!"
   ENDIF
  OF 633:
   SET x = 0
   SET y = 0
   SET z = 0
   SELECT INTO "nl:"
    x = count(*)
    FROM dm_application_task_r d
    WHERE deleted_ind=0
     AND sqlpassthru(concat("(d.application_number,d.task_number,d.schema_date) in ",
      "(select application_number, task_number, max(schema_date) from dm_application_task_r dm, dm_features df where 1=1"
      ))
     AND sqlpassthru(concat(" UPPER(df.feature_status) in ",trim(feature_status)," "))
     AND sqlpassthru(
     " dm.feature_number = df.feature_number group by application_number, task_number )")
    DETAIL
     y = x
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x = count(*)
    FROM application_task_r a
    DETAIL
     z = x
    WITH nocounter
   ;end select
   IF (z < y)
    SET request->setup_proc[1].success_ind = 0
    SET request->setup_proc[1].error_msg = "ATR Application-Task-R refresh NOT successful!"
   ELSE
    SET request->setup_proc[1].success_ind = 1
    SET request->setup_proc[1].error_msg = "ATR Application-Task-R refresh successful!"
   ENDIF
  OF 634:
   SET x = 0
   SET y = 0
   SET z = 0
   SELECT INTO "nl:"
    x = count(*)
    FROM dm_request d
    WHERE deleted_ind=0
     AND sqlpassthru(concat("(d.request_number,d.schema_date) in ",
      "(select request_number, max(schema_date) from dm_request dm, dm_features df where 1=1"))
     AND sqlpassthru(concat(" UPPER(df.feature_status) in ",trim(feature_status)," "))
     AND sqlpassthru(" dm.feature_number = df.feature_number group by request_number )")
    DETAIL
     y = x
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x = count(*)
    FROM request a
    DETAIL
     z = x
    WITH nocounter
   ;end select
   IF (z < y)
    SET request->setup_proc[1].success_ind = 0
    SET request->setup_proc[1].error_msg = "ATR Request refresh NOT successful!"
   ELSE
    SET request->setup_proc[1].success_ind = 1
    SET request->setup_proc[1].error_msg = "ATR Request refresh successful!"
   ENDIF
  OF 635:
   SET x = 0
   SET y = 0
   SET z = 0
   SELECT INTO "nl:"
    x = count(*)
    FROM dm_task_request_r d
    WHERE deleted_ind=0
     AND sqlpassthru(concat("(d.task_number,d.request_number,d.schema_date) in ",
      "(select task_number, request_number, max(schema_date) from dm_task_request_r dm, dm_features df where 1=1"
      ))
     AND sqlpassthru(concat(" UPPER(df.feature_status) in ",trim(feature_status)," "))
     AND sqlpassthru(" dm.feature_number = df.feature_number group by task_number, request_number )")
    DETAIL
     y = x
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    x = count(*)
    FROM task_request_r a
    DETAIL
     z = x
    WITH nocounter
   ;end select
   IF (z < y)
    SET request->setup_proc[1].success_ind = 0
    SET request->setup_proc[1].error_msg = "ATR Task-Request-R refresh NOT successful!"
   ELSE
    SET request->setup_proc[1].success_ind = 1
    SET request->setup_proc[1].error_msg = "ATR Task-Request-R refresh successful!"
   ENDIF
 ENDCASE
 EXECUTE dm_add_upt_setup_proc_log
END GO
