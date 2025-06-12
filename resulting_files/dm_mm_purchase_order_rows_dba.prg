CREATE PROGRAM dm_mm_purchase_order_rows:dba
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE days_to_keep = i4 WITH noconstant(- (1))
 DECLARE rowcount = i4 WITH noconstant(0)
 DECLARE valcount = i4 WITH noconstant(0)
 DECLARE v_errmsg2 = c132
 DECLARE v_err_code2 = i4 WITH noconstant(0)
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
  SET reply->table_name = "PURCHASE_ORDER"
  SET reply->rows_between_commit = 100
  SET rowcount = 0
  SELECT INTO "nl:"
   p.rowid
   FROM purchase_order p,
    line_item l
   PLAN (p
    WHERE p.purchase_order_id > 0
     AND p.updt_dt_tm < cnvtdatetime((curdate - days_to_keep),curtime3))
    JOIN (l
    WHERE l.purchase_order_id=p.purchase_order_id)
   ORDER BY p.purchase_order_id
   HEAD REPORT
    rowcount = 0
   HEAD p.purchase_order_id
    valcount = 0
   DETAIL
    IF (l.requisition_id > 0)
     valcount = (valcount+ 1)
    ENDIF
   FOOT  p.purchase_order_id
    IF (valcount=0)
     IF (rowcount < value(request->max_rows))
      rowcount = (rowcount+ 1)
      IF (mod(rowcount,10)=1)
       stat = alterlist(reply->rows,(rowcount+ 9))
      ENDIF
      reply->rows[rowcount].row_id = p.rowid
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->rows,rowcount)
   WITH nocounter
  ;end select
  CALL echo(build("Size of POs to be purged:",value(size(reply->rows,5))))
  SET v_err_code2 = error(v_errmsg2,1)
  IF (v_err_code2=0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->err_code = v_err_code2
   SET reply->err_msg = v_errmsg2
  ENDIF
 ENDIF
END GO
