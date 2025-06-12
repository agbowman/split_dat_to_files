CREATE PROGRAM dm_mm_trans_header_rows:dba
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE days_to_keep = i4 WITH noconstant(- (1))
 DECLARE rowcount = i4 WITH noconstant(0)
 DECLARE v_errmsg2 = c132
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 DECLARE adjustmentcd = f8 WITH noconstant(0.0)
 DECLARE failed = i2 WITH noconstant(0)
 SET reply->table_name = "MM_TRANS_HEADER"
 SET reply->rows_between_commit = 500
 SET adjustmentcd = uar_get_code_by("MEANING",11029,"ADJUSTMENT")
 IF (adjustmentcd=0)
  SET failed = true
  GO TO exit_script
 ENDIF
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF (cnvtupper(request->tokens[tok_ndx].token_str)="DAYSTOKEEP")
    SET days_to_keep = cnvtreal(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF (days_to_keep < 730)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1","%1 %2 %3","sss",
   "You must keep at least 730 days worth of data.  You entered ",
   nullterm(trim(cnvtstring(days_to_keep),3))," days or did not enter any value.")
 ELSE
  SET rowcount = 0
  SELECT INTO "nl:"
   th.rowid
   FROM mm_trans_header th
   WHERE th.transaction_id > 0
    AND th.trans_type_cd=adjustmentcd
    AND th.trans_dt_tm < cnvtdatetime((curdate - days_to_keep),curtime3)
   HEAD REPORT
    rowcount = 0
   DETAIL
    rowcount = (rowcount+ 1)
    IF (mod(rowcount,10)=1)
     stat = alterlist(reply->rows,(rowcount+ 9))
    ENDIF
    reply->rows[rowcount].row_id = th.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,rowcount)
   WITH nocounter, maxqual(th,value(request->max_rows))
  ;end select
  CALL echo(build("Size of adjs to be purged:",value(size(reply->rows,5))))
  SET v_err_code2 = error(v_errmsg2,1)
  IF (v_err_code2=0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->err_code = v_err_code2
   SET reply->err_msg = v_errmsg2
  ENDIF
 ENDIF
#exit_script
 IF (failed=true)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1","%1 %2 %3","sss","The cdf_meaning  ",
   nullterm(trim(cnvtstring(cdf_meaning),3))," is a necessary code value & could not be retrieved. ")
 ENDIF
END GO
