CREATE PROGRAM dpo_rdds_dcl_non_reltn_rows:dba
 FREE RECORD d_envs
 RECORD d_envs(
   1 cnt = i4
   1 qual[*]
     2 env_id = f8
 ) WITH protect
 DECLARE drderr_cursor_query = vc WITH protect, noconstant(" ")
 DECLARE drderr_fetch_size = f8 WITH protect, noconstant(10000)
 DECLARE drderr_err_code2 = i4 WITH protect, noconstant(0)
 DECLARE drderr_errmsg2 = vc WITH protect, noconstant("")
 DECLARE drderr_env_id = f8 WITH protect, noconstant(0.0)
 DECLARE drderr_loop = i4 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE h = i4 WITH protect, noconstant(0)
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
  SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"ENVIDERR",
   "Error obtaining environment ID: %1","s",nullterm(drderr_errmsg2))
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET dpo_reply->err_msg = uar_i18ngetmessage(i18nhandle,"NOENVID",
   "Fatal Error: current environment ID not found")
  GO TO exit_program
 ENDIF
 SELECT DISTINCT INTO "nl:"
  dcl.target_env_id
  FROM dm_chg_log dcl
  WHERE  NOT (dcl.target_env_id IN (
  (SELECT
   di.info_number
   FROM dm_info di
   WHERE di.info_domain="RDDS CONFIGURATION"
    AND di.info_name="RELTN_ACTIVE*"
    AND di.info_char=cnvtstring(drderr_env_id)
    AND di.info_date >= cnvtdatetime((curdate - 30),0))))
   AND  NOT (dcl.target_env_id IN (
  (SELECT
   der.child_env_id
   FROM dm_env_reltn der
   WHERE der.parent_env_id=drderr_env_id
    AND der.relationship_type="REFERENCE MERGE")))
  HEAD REPORT
   d_envs->cnt = 0
  DETAIL
   d_envs->cnt = (d_envs->cnt+ 1), stat = alterlist(d_envs->qual,d_envs->cnt), d_envs->qual[d_envs->
   cnt].env_id = dcl.target_env_id
  WITH nocounter
 ;end select
 SET drderr_err_code2 = error(drderr_errmsg2,1)
 IF (drderr_err_code2 != 0)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = drderr_err_code2
  SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"CHILDENVERR",
   "Error obtaining list of child environment IDs: %1","s",nullterm(drderr_errmsg2))
  GO TO exit_program
 ENDIF
 IF ((d_envs->cnt=0))
  SET dpo_reply->status_data.status = "S"
  SET dpo_reply->err_code = 0
  SET drderr_cursor_query = "select rowid from V500.dm_chg_log where 1 = 2"
  GO TO exit_program
 ENDIF
 SET drderr_cursor_query = "select rowid from V500.dm_chg_log where target_env_id in ("
 FOR (drderr_loop = 1 TO d_envs->cnt)
   IF (drderr_loop=1)
    SET drderr_cursor_query = concat(drderr_cursor_query,trim(cnvtstring(d_envs->qual[drderr_loop].
       env_id,20)))
   ELSE
    SET drderr_cursor_query = concat(drderr_cursor_query,", ",trim(cnvtstring(d_envs->qual[
       drderr_loop].env_id,20)))
   ENDIF
 ENDFOR
 SET drderr_cursor_query = concat(drderr_cursor_query,")")
 SET dpo_reply->status_data.status = "S"
 SET dpo_reply->err_code = 0
#exit_program
 SET dpo_reply->max_rows = b_request->max_rows
 SET dpo_reply->cursor_query = drderr_cursor_query
 SET dpo_reply->fetch_size = drderr_fetch_size
 CALL echorecord(dpo_reply)
 FREE RECORD d_envs
END GO
