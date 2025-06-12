CREATE PROGRAM dm_sch_log_rows:dba
 DECLARE g_minimum_keep_days = f8 WITH protect, noconstant(60.0)
 DECLARE g_rows_between_commit = i4 WITH protect, noconstant(100)
 DECLARE tok_ndx = i4 WITH protect, noconstant(0)
 DECLARE v_days_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_errmsg2 = vc WITH protect, noconstant("")
 DECLARE v_err_code2 = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < g_minimum_keep_days)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"KEEPDAYS",
   "You must keep at least %1 days' worth of data.  You entered %2 days or did not enter any value.",
   "di",g_minimum_keep_days,
   v_days_to_keep)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->table_name = "SCH_LOG"
  SET reply->rows_between_commit = g_rows_between_commit
  SELECT INTO "nl:"
   a.rowid
   FROM sch_log a
   WHERE a.generated_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)
    AND parser(sbr_getrowidnotexists("a.sch_log_id+0 > 0","a"))
   HEAD REPORT
    rows = 0
   DETAIL
    rows = (rows+ 1)
    IF (mod(rows,100)=1)
     stat = alterlist(reply->rows,(rows+ 99))
    ENDIF
    reply->rows[rows].row_id = a.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,rows)
   WITH nocounter, maxqual(a,value(request->max_rows))
  ;end select
  SET v_err_code2 = error(v_errmsg2,1)
  IF (v_err_code2=0)
   SET reply->status_data.status = "S"
   SET reply->err_code = 0
  ELSE
   SET reply->err_code = v_err_code2
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s1","Failed in row collection: %1","s",
    nullterm(v_errmsg2))
   SET reply->status_data.status = "F"
  ENDIF
 ENDIF
END GO
