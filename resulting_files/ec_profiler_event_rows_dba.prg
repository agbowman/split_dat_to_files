CREATE PROGRAM ec_profiler_event_rows:dba
 SET reply->status_data.status = "F"
 DECLARE v_days_to_keep = f8 WITH noconstant(0.0)
 DECLARE v_errmsg2 = c132
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "EC_PROFILER_EVENT"
 SET reply->rows_between_commit = 50
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = cnvtreal(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 60)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1","%1 %2 %3","sss",
   "You must keep at least 60 days worth of data.  You entered ",
   nullterm(trim(cnvtstring(v_days_to_keep),3))," days or did not enter any value.")
 ELSE
  SELECT INTO "nl:"
   epe.rowid
   FROM ec_profiler_event epe
   WHERE epe.event_end_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)
    AND epe.ec_profiler_event_id != 0
   HEAD REPORT
    row_cnt = 0
   DETAIL
    row_cnt = (row_cnt+ 1)
    IF (mod(row_cnt,50)=1)
     stat = alterlist(reply->rows,(row_cnt+ 49))
    ENDIF
    reply->rows[row_cnt].row_id = epe.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,row_cnt)
   WITH nocounter, maxqual(epe,value(request->max_rows))
  ;end select
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
