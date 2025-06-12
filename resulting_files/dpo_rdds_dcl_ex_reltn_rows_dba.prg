CREATE PROGRAM dpo_rdds_dcl_ex_reltn_rows:dba
 FREE RECORD d_envs
 RECORD d_envs(
   1 purge_ind = i2
   1 cnt = i4
   1 qual[*]
     2 env_id = f8
     2 del_rows_ind = i2
     2 nondel_rows_ind = i2
 ) WITH protect
 FREE RECORD d_purgetypes
 RECORD d_purgetypes(
   1 cnt = i4
   1 qual[*]
     2 type = vc
 ) WITH protect
 DECLARE drderr_cursor_query = vc WITH protect, noconstant(" ")
 DECLARE drderr_fetch_size = f8 WITH protect, noconstant(10000)
 DECLARE drderr_err_code2 = i4 WITH protect, noconstant(0)
 DECLARE drderr_errmsg2 = vc WITH protect, noconstant("")
 DECLARE drderr_env_id = f8 WITH protect, noconstant(0.0)
 DECLARE drderr_dm_info_dt = f8 WITH protect, noconstant(0.0)
 DECLARE days_to_keep = f8 WITH protect, noconstant(0.0)
 DECLARE drderr_loop = i4 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE h = i4 WITH protect, noconstant(0)
 DECLARE d_idx = i4 WITH protect, noconstant(0)
 DECLARE token_idx = i4 WITH protect, noconstant(0)
 DECLARE logtypestring = vc WITH protect, noconstant("")
 DECLARE purgetypeidx = i4 WITH protect, noconstant(0)
 DECLARE purgedate = dq8 WITH protect, noconstant(0.0)
 SET dpo_reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET dpo_reply->owner_name = "V500"
 SET dpo_reply->table_name = "DM_CHG_LOG"
 IF ((b_request->max_rows < 0))
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = 1
  SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"maxrows",
   "MAXROWS must be greater than 0.  You entered %1 or did not enter a value.","i",b_request->
   max_rows)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  b.environment_id
  FROM dm_info a,
   dm_environment b
  WHERE a.info_name="DM_ENV_ID"
   AND a.info_domain="DATA MANAGEMENT"
   AND a.info_number=b.environment_id
  DETAIL
   drderr_env_id = b.environment_id
  WITH nocounter
 ;end select
 SET drderr_err_code2 = error(drderr_errmsg2,1)
 IF (drderr_err_code2 != 0)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = drderr_err_code2
  SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"ENVIDERROR",
   "Error obtaining environment ID: %1","s",nullterm(drderr_errmsg2))
  GO TO exit_program
 ELSEIF (curqual=0)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET dpo_reply->err_msg = uar_i18ngetmessage(i18nhandle,"NOENVID",
   "Fatal Error: current environment ID not found")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  der.child_env_id
  FROM dm_env_reltn der
  WHERE der.parent_env_id=drderr_env_id
   AND der.relationship_type="REFERENCE MERGE"
  HEAD REPORT
   d_envs->cnt = 0
  DETAIL
   d_envs->cnt = (d_envs->cnt+ 1), stat = alterlist(d_envs->qual,d_envs->cnt), d_envs->qual[d_envs->
   cnt].env_id = der.child_env_id
  WITH nocounter
 ;end select
 SET drderr_err_code2 = error(drderr_errmsg2,1)
 IF (drderr_err_code2 != 0)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = drderr_err_code2
  SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"CHILDENVERROR",
   "Error obtaining child environment IDs: %1","s",nullterm(drderr_errmsg2))
  GO TO exit_program
 ENDIF
 IF ((d_envs->cnt=0))
  SET dpo_reply->status_data.status = "S"
  SET dpo_reply->err_code = 0
  SET drderr_cursor_query = "select rowid from V500.dm_chg_log where 1 = 2"
  GO TO exit_program
 ENDIF
 FOR (token_idx = 1 TO size(b_request->tokens,5))
   IF ((b_request->tokens[token_idx].token_str="DAYSTOKEEP"))
    SET days_to_keep = ceil(cnvtreal(b_request->tokens[token_idx].value))
   ENDIF
 ENDFOR
 IF (days_to_keep < 150.0)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = 1
  SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s1",
   "You must keep at least 150 days' worth of data.  You entered %1 days or did not enter any value.",
   "s",nullterm(trim(cnvtstring(days_to_keep))))
  GO TO exit_program
 ELSE
  SET purgedate = cnvtdatetime((curdate - days_to_keep),0)
 ENDIF
 SELECT INTO "nl:"
  di.info_char
  FROM dm_info di
  WHERE di.info_domain="RDDS CONFIGURATION"
   AND di.info_name="DCL_PURGE_TYPES*"
  HEAD REPORT
   d_purgetypes->cnt = 0
  DETAIL
   d_purgetypes->cnt = (d_purgetypes->cnt+ 1), stat = alterlist(d_purgetypes->qual,d_purgetypes->cnt),
   d_purgetypes->qual[d_purgetypes->cnt].type = di.info_char
  WITH nocounter
 ;end select
 SET drderr_err_code2 = error(drderr_errmsg2,1)
 IF (drderr_err_code2 != 0)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = drderr_err_code2
  SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"PURGETYPEERR",
   "Error obtaining list of purgeable types: %1","s",nullterm(drderr_errmsg2))
  GO TO exit_program
 ENDIF
 IF ((d_purgetypes->cnt=0))
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = 1
  SET dpo_reply->err_msg = uar_i18ngetmessage(i18nhandle,"NOPURGETYPESERR","No purge types found","")
  GO TO exit_program
 ENDIF
 FOR (drderr_loop = 1 TO d_envs->cnt)
   SELECT INTO "NL:"
    FROM dm_chg_log d
    WHERE (d.target_env_id=d_envs->qual[drderr_loop].env_id)
     AND expand(d_idx,1,d_purgetypes->cnt,d.log_type,d_purgetypes->qual[d_idx].type)
     AND d.delete_ind=1
     AND d.chg_dt_tm <= cnvtdatetime(purgedate)
     AND d.updt_dt_tm <= cnvtdatetime(purgedate)
    DETAIL
     d_envs->qual[drderr_loop].del_rows_ind = 1, d_envs->purge_ind = 1
    WITH maxqual(d,1)
   ;end select
   SET drderr_err_code2 = error(drderr_errmsg2,1)
   IF (drderr_err_code2 != 0)
    SET dpo_reply->status_data.status = "F"
    SET dpo_reply->err_code = drderr_err_code2
    SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"ROWQUALERR",
     "Error checking for purgeable data for environment %1: %2","ds",d_envs->qual[drderr_loop].
     env_id,
     nullterm(drderr_errmsg2))
    GO TO exit_program
   ENDIF
   IF ((d_envs->purge_ind=1))
    SET drderr_loop = (d_envs->cnt+ 1)
   ELSE
    SELECT INTO "NL:"
     FROM dm_chg_log d
     WHERE (d.target_env_id=d_envs->qual[drderr_loop].env_id)
      AND expand(d_idx,1,d_purgetypes->cnt,d.log_type,d_purgetypes->qual[d_idx].type)
      AND d.delete_ind=0
      AND d.chg_dt_tm <= cnvtdatetime(purgedate)
      AND d.updt_dt_tm <= cnvtdatetime(purgedate)
     DETAIL
      d_envs->qual[drderr_loop].nondel_rows_ind = 1, d_envs->purge_ind = 1
     WITH maxqual(d,1)
    ;end select
    SET drderr_err_code2 = error(drderr_errmsg2,1)
    IF (drderr_err_code2 != 0)
     SET dpo_reply->status_data.status = "F"
     SET dpo_reply->err_code = drderr_err_code2
     SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"ROWQUALERR",
      "Error checking for purgeable data for environment %1: %2","ds",d_envs->qual[drderr_loop].
      env_id,
      nullterm(drderr_errmsg2))
     GO TO exit_program
    ENDIF
   ENDIF
   IF ((d_envs->purge_ind=1))
    SET drderr_loop = (d_envs->cnt+ 1)
   ENDIF
 ENDFOR
 FOR (purgetypeidx = 1 TO size(d_purgetypes->qual,5))
  SET logtypestring = build2(logtypestring," log_type = '",d_purgetypes->qual[purgetypeidx].type,"'")
  IF (purgetypeidx != size(d_purgetypes->qual,5))
   SET logtypestring = build2(logtypestring," or ")
  ENDIF
 ENDFOR
 IF ((d_envs->purge_ind=1))
  FOR (drderr_loop = 1 TO d_envs->cnt)
    IF ((d_envs->qual[drderr_loop].del_rows_ind=1))
     SET drderr_cursor_query = concat("select rowid from V500.dm_chg_log ","WHERE (",trim(
       logtypestring,3),") and "," delete_ind = 1 and target_env_id = ",
      trim(cnvtstring(d_envs->qual[drderr_loop].env_id,20,2))," and chg_dt_tm <= to_date('",format(
       purgedate,"DD/MM/YYYY HH:MM:SS;;Q"),"','DD/MM/YYYY HH24:MI:SS')",
      " and updt_dt_tm <= to_date('",
      format(purgedate,"DD/MM/YYYY HH:MM:SS;;Q"),"','DD/MM/YYYY HH24:MI:SS')")
     SET drderr_loop = (d_envs->cnt+ 1)
    ELSEIF ((d_envs->qual[drderr_loop].nondel_rows_ind=1))
     SET drderr_cursor_query = concat("select rowid from V500.dm_chg_log ","WHERE (",trim(
       logtypestring,3),") and "," delete_ind = 0 and target_env_id = ",
      trim(cnvtstring(d_envs->qual[drderr_loop].env_id,20,2))," and chg_dt_tm <= to_date('",format(
       purgedate,"DD/MM/YYYY HH:MM:SS;;Q"),"','DD/MM/YYYY HH24:MI:SS')",
      " and updt_dt_tm <= to_date('",
      format(purgedate,"DD/MM/YYYY HH:MM:SS;;Q"),"','DD/MM/YYYY HH24:MI:SS')")
     SET drderr_loop = (d_envs->cnt+ 1)
    ENDIF
  ENDFOR
 ELSE
  SET drderr_cursor_query = "select rowid from V500.dm_chg_log where 1 = 2"
 ENDIF
 SET dpo_reply->status_data.status = "S"
 SET dpo_reply->err_code = 0
#exit_program
 SET dpo_reply->max_rows = b_request->max_rows
 SET dpo_reply->cursor_query = drderr_cursor_query
 SET dpo_reply->fetch_size = drderr_fetch_size
 CALL echorecord(dpo_reply)
END GO
