CREATE PROGRAM dm_dm_schema_log_rows:dba
 DECLARE c_mod = c10 WITH noconstant("DM_PRG_SCHEMA_LOG 002")
 DECLARE v_days_to_keep = i4 WITH noconstant(- (1))
 DECLARE v_days_between = i4 WITH noconstant(- (1))
 DECLARE v_days_to_keep_min = i4 WITH noconstant(180)
 DECLARE v_days_between_min = i4 WITH noconstant(60)
 DECLARE v_tablename = vc WITH noconstant("DM_SCHEMA_LOG")
 DECLARE v_errmsg2 = vc WITH noconstant(" ")
 DECLARE v_err_code2 = i2 WITH noconstant(0)
 DECLARE v_cnt = i2 WITH noconstant(0)
 DECLARE v_ndx = i2 WITH noconstant(0)
 DECLARE v_num_days = i2 WITH noconstant(0)
 DECLARE v_i18nmsgid = vc WITH noconstant(" ")
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE h = i4 WITH noconstant(0)
 DECLARE v_rows = i2 WITH noconstant(0)
 DECLARE v_table_exists_flag = i2 WITH noconstant(0)
 DECLARE v_user_tables = i2 WITH constant(2)
 IF (0=validate(true,0)
  AND 1=validate(true,1))
  DECLARE true = i2 WITH constant(1)
 ENDIF
 IF (0=validate(false,0)
  AND 1=validate(false,1))
  DECLARE false = i2 WITH constant(0)
 ENDIF
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SELECT INTO "nl:"
  u.table_name
  FROM user_tables u
  WHERE u.table_name=v_tablename
  DETAIL
   v_table_exists_flag = v_user_tables
  WITH nocounter
 ;end select
 IF (v_table_exists_flag=v_user_tables)
  SET v_table_exists_flag = false
  SELECT INTO "nl:"
   d.table_name
   FROM dtableattr d
   WHERE d.table_name=v_tablename
   DETAIL
    v_table_exists_flag = true
   WITH nocounter
  ;end select
 ENDIF
 IF (v_table_exists_flag=false)
  SET v_i18nmsgid = "INF_TABLEEXISTANCE"
  SET reply->err_code = 0
  SET v_errmsg2 = uar_i18nbuildmessage(i18nhandle,v_i18nmsgid,
   "The table %1 does not exist in this environment.","s",nullterm(trim(v_tablename)))
  SET reply->status_data.status = "S"
  SET reply->err_msg = trim(v_errmsg2)
  GO TO end_program
 ENDIF
 SET v_cnt = size(request->tokens,5)
 FOR (v_ndx = 1 TO v_cnt)
   IF (cnvtupper(request->tokens[v_ndx].token_str)="DAYSTOKEEP")
    SET v_days_to_keep = cnvtint(request->tokens[v_ndx].value)
   ELSEIF (cnvtupper(request->tokens[v_ndx].token_str)="DAYSBETWEEN")
    SET v_days_between = cnvtint(request->tokens[v_ndx].value)
   ENDIF
 ENDFOR
 IF ((v_days_to_keep != - (1))
  AND v_days_to_keep < v_days_to_keep_min)
  SET v_i18nmsgid = "ERR_DAYSTOKEEPMIN"
  SET reply->err_code = - (1)
  SET v_errmsg2 = uar_i18nbuildmessage(i18nhandle,v_i18nmsgid,
   "You must keep at least %1 days worth of data.  You entered %2 days or did not enter any value.",
   "ii",v_days_to_keep_min,
   v_days_to_keep)
  SET reply->err_msg = trim(v_errmsg2)
 ELSEIF ((v_days_between != - (1))
  AND v_days_between < v_days_between_min)
  SET v_i18nmsgid = "ERR_DAYSBETWEENMIN"
  SET reply->err_code = - (1)
  SET v_errmsg2 = uar_i18nbuildmessage(i18nhandle,v_i18nmsgid,
   "You must have at least %1 day/days between runs.  You entered %2 days or did not enter any value.",
   "ii",v_days_between_min,
   v_days_between)
  SET reply->err_msg = trim(v_errmsg2)
 ELSE
  SET v_num_days = floor(datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(cnvtdate2(substring
      (1,8,request->last_run_date),"YYYYMMDD"),cnvtint(substring(9,6,request->last_run_date)))))
  IF (v_num_days > 0
   AND v_num_days < v_days_between)
   SET reply->status_data.status = "K"
  ELSE
   SET reply->table_name = v_tablename
   SET reply->rows_between_commit = 50
   SET v_rows = 0
   SELECT INTO nl
    dsl.rowid
    FROM dm_schema_log dsl
    WHERE datetimeadd(dsl.gen_dt_tm,v_days_to_keep) < cnvtdatetime(curdate,curtime3)
     AND dsl.run_id > 0
    HEAD REPORT
     stat = alterlist(reply->rows,value(request->max_rows))
    DETAIL
     v_rows = (v_rows+ 1), reply->rows[v_rows].row_id = dsl.rowid
    FOOT REPORT
     stat = alterlist(reply->rows,v_rows)
    WITH nocounter, maxqual(dsl,value(request->max_rows))
   ;end select
   SET v_errmsg2 = ""
   SET v_err_code2 = 0
   SET v_err_code2 = error(v_errmsg2,1)
   IF (v_err_code2=0)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->err_code = v_err_code2
    SET reply->err_msg = trim(v_errmsg2)
   ENDIF
  ENDIF
 ENDIF
#end_program
END GO
