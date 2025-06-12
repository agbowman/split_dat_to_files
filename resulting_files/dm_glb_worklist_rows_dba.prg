CREATE PROGRAM dm_glb_worklist_rows:dba
 SET reply->status_data.status = "F"
 SET reply->table_name = "WORKLIST"
 SET reply->rows_between_commit = 20
 DECLARE purge_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE days_to_keep = i4 WITH noconstant(0)
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (days_to_keep < 1)
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"TOKENOUTOFRANGE",
   "You must keep at least 1 days' worth of data.  You entered %1 days or did not enter any value.",
   "i",days_to_keep)
  GO TO exit_script
 ENDIF
 SET purge_dt_tm = cnvtagedatetime(0,0,0,days_to_keep)
 SELECT INTO "nl:"
  w.rowid
  FROM worklist w
  WHERE w.worklist_dt_tm <= cnvtdatetime(purge_dt_tm)
   AND ((w.worklist_id+ 0) > 0)
   AND w.status_cd=0.0
   AND  NOT (((w.worklist_id+ 0) IN (
  (SELECT
   ht.worklist_id
   FROM hla_xm_res_tray ht))))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,50)=1)
    stat = alterlist(reply->rows,(cnt+ 49))
   ENDIF
   reply->rows[cnt].row_id = w.rowid
  FOOT REPORT
   stat = alterlist(reply->rows,cnt)
  WITH nocounter, maxqual(w,value(request->max_rows))
 ;end select
 SET reply->err_code = error(reply->err_msg,1)
 IF ((reply->err_code > 0))
  SET reply->status_data.status = "F"
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR","Failed in row collection: %1",
   "s",nullterm(reply->err_msg))
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_script
END GO
