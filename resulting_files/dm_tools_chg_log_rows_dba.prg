CREATE PROGRAM dm_tools_chg_log_rows:dba
 SET reply->status_data.status = "F"
 DECLARE v_days_to_keep = f8 WITH noconstant(0.0)
 DECLARE v_env_to_keep = f8 WITH noconstant(0.0)
 DECLARE v_errmsg2 = c132
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 DECLARE row_cnt = i4
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "DM_CHG_LOG"
 SET reply->rows_between_commit = 5000
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ELSEIF ((request->tokens[tok_ndx].token_str="TARGETTOKEEP"))
    SET v_env_to_keep = cnvtreal(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 60)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1","%1 %2 %3","sss",
   "You must keep at least 60 days worth of data.  You entered ",
   nullterm(trim(cnvtstring(v_days_to_keep),3))," days or did not enter any value.")
 ELSE
  SET row_cnt = 0
  SELECT INTO "nl:"
   dc.rowid
   FROM dm_chg_log dc
   WHERE dc.chg_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)
    AND dc.target_env_id != v_env_to_keep
    AND cnvtupper(dc.log_type)="MERGED"
    AND dc.log_id != 0
   DETAIL
    row_cnt = (row_cnt+ 1)
    IF (mod(row_cnt,5000)=1)
     stat = alterlist(reply->rows,(row_cnt+ 4999))
    ENDIF
    reply->rows[row_cnt].row_id = dc.rowid
   WITH nocounter, maxqual(dc,value(request->max_rows))
  ;end select
  SET stat = alterlist(reply->rows,row_cnt)
  SET v_errmsg2 = fillstring(132," ")
  SET v_err_code2 = 0
  SET v_err_code2 = error(v_errmsg2,1)
  IF (v_err_code2=0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->err_code = v_err_code2
   SET reply->err_msg = v_errmsg2
  ENDIF
 ENDIF
END GO
