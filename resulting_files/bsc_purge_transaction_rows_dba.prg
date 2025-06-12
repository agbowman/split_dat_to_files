CREATE PROGRAM bsc_purge_transaction_rows:dba
 SET modify = predeclare
 RECORD reply(
   1 err_msg = vc
   1 err_code = i4
   1 table_name = vc
   1 rows_between_commit = i4
   1 rows[*]
     2 row_id = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE v_days_to_keep = f8 WITH noconstant(0.0)
 DECLARE v_errmsg2 = c132
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 SET reply->status_data.status = "F"
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "NURSING_TRANSACTION_INFO"
 SET reply->rows_between_commit = 50
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = cnvtreal(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 0)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1","%1 %2 %3","sss",
   "You must keep at least 15 days worth of data.  You entered ",
   nullterm(trim(cnvtstring(v_days_to_keep),3))," days or did not enter any value.")
 ELSE
  SELECT INTO "nl:"
   nti.rowid
   FROM nursing_transaction_info nti
   WHERE nti.updt_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)
    AND nti.nursing_transaction_info_id != 0
   HEAD REPORT
    row_cnt = 0
   DETAIL
    row_cnt = (row_cnt+ 1)
    IF (mod(row_cnt,50)=1)
     stat = alterlist(reply->rows,(row_cnt+ 49))
    ENDIF
    reply->rows[row_cnt].row_id = nti.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,row_cnt)
   WITH maxrec = value(request->max_rows)
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
 SET last_mod = "002 06/13/17"
 SET modify = nopredeclare
END GO
