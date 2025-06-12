CREATE PROGRAM ct_purge_prescreen_rows:dba
 SET reply->status_data.status = "F"
 DECLARE days_to_keep = i4 WITH noconstant(0)
 DECLARE errmsg2 = c132
 DECLARE err_code2 = i4 WITH noconstant(0)
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 DECLARE look_behind = vc WITH protect
 DECLARE row_cnt = i4 WITH protect, noconstant(0)
 DECLARE syscancel = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"SYSCANCEL"))
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "PT_PROT_PRESCREEN"
 SET reply->rows_between_commit = 50
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET days_to_keep = cnvtint(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF (days_to_keep < 7)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1",
   "You must keep at least 7 days worth of data.  You entered %1 days or did not enter any value.",
   "i",days_to_keep)
 ELSE
  SET look_behind = build(days_to_keep,",D")
  SELECT INTO "nl:"
   pt.rowid
   FROM pt_prot_prescreen pt
   WHERE pt.pt_prot_prescreen_id > 0
    AND pt.screened_dt_tm <= cnvtlookbehind(look_behind,cnvtdatetime(curdate,curtime3))
    AND parser(sbr_getrowidnotexists("pt.screening_status_cd = SYSCANCEL","pt"))
   HEAD REPORT
    row_cnt = 0
   DETAIL
    row_cnt = (row_cnt+ 1)
    IF (mod(row_cnt,50)=1)
     stat = alterlist(reply->rows,(row_cnt+ 49))
    ENDIF
    reply->rows[row_cnt].row_id = pt.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,row_cnt)
   WITH nocounter, maxqual(pt,value(request->max_rows))
  ;end select
  SET errmsg2 = fillstring(132," ")
  SET err_code2 = 0
  SET err_code2 = error(errmsg2,1)
  IF (err_code2=0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->err_code = err_code2
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k2","Failed in row collection: %1","s",
    nullterm(errmsg2))
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_script
 SET last_mod = "000"
 SET mod_date = "April 28, 2010"
END GO
