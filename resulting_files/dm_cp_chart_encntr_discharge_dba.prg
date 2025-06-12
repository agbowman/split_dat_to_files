CREATE PROGRAM dm_cp_chart_encntr_discharge:dba
 SET reply->status_data.status = "F"
 DECLARE v_purge_days = f8 WITH noconstant(0.0)
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog," ",curcclrev)
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="PURGEDAYS"))
    SET v_purge_days = cnvtreal(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF (v_purge_days < 1)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"LBDAYS","%1 %2 %3","sss",
   "You must look back at least one day.  You entered ",
   nullterm(trim(cnvtstring(v_purge_days),3))," days or did not enter any value.")
 ELSE
  SET reply->table_name = "CHART_ENCNTR_DISCHARGE"
  SET reply->rows_between_commit = 100
  SELECT INTO "nl:"
   ced.rowid
   FROM chart_encntr_discharge ced
   WHERE ced.transact_dt_tm < cnvtdatetime((curdate - v_purge_days),curtime3)
   HEAD REPORT
    row_cnt = 0
   DETAIL
    row_cnt = (row_cnt+ 1)
    IF (mod(row_cnt,1000)=1)
     stat = alterlist(reply->rows,(row_cnt+ 999))
    ENDIF
    reply->rows[row_cnt].row_id = ced.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,row_cnt)
   WITH nocounter, maxqual(ced,value(request->max_rows))
  ;end select
 ENDIF
 SET v_errmsg2 = fillstring(132," ")
 SET v_err_code2 = 0
 SET v_err_code2 = error(v_errmsg2,1)
 IF (v_err_code2=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->err_code = v_err_code2
  SET reply->err_msg = v_errmsg2
 ENDIF
END GO
