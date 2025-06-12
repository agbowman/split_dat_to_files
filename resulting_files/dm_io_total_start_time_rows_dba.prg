CREATE PROGRAM dm_io_total_start_time_rows:dba
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "IO_TOTAL_START_TIME"
 SET reply->rows_between_commit = 50
 SET v_days_to_keep = - (1)
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = cnvtreal(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 7)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1","%1 %2 %3","sss",
   "You must keep at least 7 days worth of data.  You entered ",
   nullterm(trim(cnvtstring(v_days_to_keep),3))," days or did not enter any value.")
 ELSE
  SET v_rows = 0
  SELECT INTO "nl:"
   iotst.io_total_start_time_id
   FROM io_total_start_time iotst,
    encounter e
   PLAN (iotst
    WHERE iotst.encntr_id > 0)
    JOIN (e
    WHERE e.encntr_id=iotst.encntr_id
     AND e.disch_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3))
   DETAIL
    v_rows = (v_rows+ 1)
    IF (mod(v_rows,50)=1)
     stat = alterlist(reply->rows,(v_rows+ 49))
    ENDIF
    reply->rows[v_rows].row_id = iotst.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,v_rows)
   WITH nocounter, maxqual(dw,value(request->max_rows))
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
