CREATE PROGRAM dm_tools_merge_audit_rows:dba
 DECLARE rows_left = i4
 SET reply->status_data.status = "F"
 DECLARE v_days_to_keep = f8 WITH noconstant(0.0)
 DECLARE v_errmsg2 = c132
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 DECLARE row_cnt = i4
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "dm_merge_audit"
 SET reply->rows_between_commit = 5000
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 30)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1","%1 %2 %3","sss",
   "You must keep at least 30 days worth of data.  You entered ",
   nullterm(trim(cnvtstring(v_days_to_keep),3))," days or did not enter any value.")
 ELSE
  SELECT INTO "nl:"
   FROM dm_merge_audit d
   WHERE d.action="FAILREASON"
    AND  EXISTS (
   (SELECT
    "x"
    FROM dm_merge_audit dc
    WHERE cnvtupper(dc.action) IN ("INSERT", "UPDATE")
     AND d.merge_id=dc.merge_id))
   HEAD REPORT
    row_cnt = 0
   DETAIL
    row_cnt = (row_cnt+ 1)
    IF (mod(row_cnt,5000)=1)
     stat = alterlist(reply->rows,(row_cnt+ 4999))
    ENDIF
    reply->rows[row_cnt].row_id = d.rowid
   WITH nocounter, maxqual(d,value(request->max_rows))
  ;end select
  SET rows_left = (request->max_rows - row_cnt)
  IF (rows_left > 0)
   SELECT INTO "nl:"
    FROM dm_merge_audit d
    WHERE d.merge_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)
     AND d.action != "FAILREASON"
     AND d.merge_id != 0
    DETAIL
     row_cnt = (row_cnt+ 1)
     IF (mod(row_cnt,5000)=1)
      stat = alterlist(reply->rows,(row_cnt+ 4999))
     ENDIF
     reply->rows[row_cnt].row_id = d.rowid
    WITH nocounter, maxqual(d,value(rows_left))
   ;end select
  ENDIF
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
