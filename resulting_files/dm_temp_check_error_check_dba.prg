CREATE PROGRAM dm_temp_check_error_check:dba
 SET user_date = cnvtdatetime(sysdate)
 SET temp_date = cnvtdatetime(sysdate)
 SET userlastupdt = "N"
 SET dm_tmp_cnt = 0
 SET dm_user_cnt = 0
 SELECT INTO "nl:"
  d.info_date
  FROM dm_info d
  WHERE d.info_name="USERLASTUPDT"
  DETAIL
   user_date = d.info_date
  WITH nocounter
 ;end select
 IF (curqual=1)
  SET userlastupdt = "Y"
 ENDIF
 SELECT INTO "nl:"
  d.info_date
  FROM dm_info d
  WHERE d.info_name="TEMPLASTBLD"
  DETAIL
   temp_date = d.info_date, dm_tmp_cnt = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  duc.table_name
  FROM dm_user_constraints duc
  WHERE sqlpassthru("rownum < 2")
  DETAIL
   dm_user_cnt += 1
  WITH nocounter
 ;end select
 IF (dm_user_cnt=1)
  SET dm_user_cnt = 0
  SELECT INTO "nl:"
   dcc.table_name
   FROM dm_user_cons_columns dcc
   WHERE sqlpassthru("rownum < 2")
   DETAIL
    dm_user_cnt += 1
   WITH nocounter
  ;end select
  IF (dm_user_cnt=1)
   SET dm_user_cnt = 0
   SELECT INTO "nl:"
    dutc.table_name
    FROM dm_user_tab_cols dutc
    WHERE sqlpassthru("rownum < 2")
    DETAIL
     dm_user_cnt += 1
    WITH nocounter
   ;end select
   IF (dm_user_cnt=1)
    SET dm_user_cnt = 0
    SELECT INTO "nl:"
     duic.table_name
     FROM dm_user_ind_columns duic
     WHERE sqlpassthru("rownum < 2")
     DETAIL
      dm_user_cnt += 1
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 IF (((dm_tmp_cnt=0) OR (((userlastupdt="Y"
  AND user_date > temp_date) OR (dm_user_cnt=0)) )) )
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "Temp table are out of synch with the Oracle user tables. Please rebuild."
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "Temp tables are successfully built and in synch with the Oracle user tables."
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
