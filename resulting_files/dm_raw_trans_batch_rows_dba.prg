CREATE PROGRAM dm_raw_trans_batch_rows:dba
 IF ( NOT (validate(script_version)))
  DECLARE script_version = vc WITH constant("201691.000"), private
 ENDIF
 CALL echo(build("EXECUTING::",curprog,"::VERSION[",script_version,"]"))
 IF ( NOT (validate(reply)))
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
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE v_days_to_keep = f8 WITH noconstant(0.0)
 DECLARE v_errmsg2 = c132
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 DECLARE row_cnt = i4 WITH noconstant(0)
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "RAW_BATCH_TRANS"
 SET reply->rows_between_commit = 50
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 7)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"DAYSTOKEEP",
   "You must keep at least 7 days' worth of data.  You entered %1 days or did not enter any value.",
   "i",v_days_to_keep)
 ELSE
  SELECT INTO "nl:"
   FROM raw_batch_trans r
   WHERE r.updt_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)
    AND r.raw_batch_trans_id != 0
   HEAD REPORT
    row_cnt = 0
   DETAIL
    row_cnt = (row_cnt+ 1)
    IF (mod(row_cnt,50)=1)
     stat = alterlist(reply->rows,(row_cnt+ 49))
    ENDIF
    reply->rows[row_cnt].row_id = r.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,row_cnt)
   WITH nocounter, maxqual(r,value(request->max_rows))
  ;end select
  SET v_err_code2 = error(v_errmsg2,0)
  IF (v_err_code2=0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->err_code = v_err_code2
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR","Failed on row collection:%1",
    "s",nullterm(v_errmsg2))
  ENDIF
 ENDIF
END GO
