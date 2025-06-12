CREATE PROGRAM dm_cs_charge_batch_rows:dba
 DECLARE dm_cs_charge_batch_rows = vc WITH private, noconstant("192772.FT.000")
 DECLARE v_errmsg2 = c132 WITH noconstant(fillstring(132," "))
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "CHARGE_BATCH"
 SET reply->rows_between_commit = 500
 SET reply->status_data.status = "F"
 DECLARE days_to_keep = i4 WITH protect, noconstant(- (1))
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF (cnvtupper(request->tokens[tok_ndx].token_str)="DAYSTOKEEP")
    SET days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 SET v_rows = 0
 IF (days_to_keep < 365)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"DAYSTOKEEP",
   "You must keep at least 365 days' worth of data.  You entered %1 days or did not enter any value.",
   "i",days_to_keep)
  GO TO exit_script
 ELSE
  SELECT INTO "nl:"
   FROM charge_batch cb
   WHERE cb.updt_dt_tm < cnvtdatetime((curdate - days_to_keep),curtime3)
    AND ((cb.charge_batch_id+ 0) != 0)
   DETAIL
    v_rows = (v_rows+ 1), stat = alterlist(reply->rows,v_rows), reply->rows[v_rows].row_id = cb.rowid
   WITH nocounter, maxqual(cb,value(request->max_rows))
  ;end select
  SET v_err_code2 = error(v_errmsg2,0)
  IF (v_err_code2 != 0)
   SET reply->err_code = v_err_code2
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR","Failed in row collection:%1",
    "s",nullterm(v_errmsg2))
   GO TO exit_script
  ENDIF
  IF ((request->purge_flag=3))
   IF (size(reply->rows,5) > 0)
    UPDATE  FROM charge_batch cb,
      (dummyt d  WITH seq = value(size(reply->rows,5)))
     SET cb.updt_task = 951700.0
     PLAN (d)
      JOIN (cb
      WHERE (cb.rowid=reply->rows[d.seq].row_id))
     WITH nocounter
    ;end update
    SET v_err_code2 = error(v_errmsg2,0)
    IF (v_err_code2=0)
     COMMIT
    ELSE
     SET reply->err_code = v_err_code2
     SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"UPDATEERROR","Failed during update:%1",
      "s",nullterm(v_errmsg2))
     ROLLBACK
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_script
END GO
