CREATE PROGRAM dm_pft_rvu_content_rows:dba
 DECLARE v_days_to_keep = i4 WITH protect, noconstant(0)
 DECLARE v_errmsg2 = c132
 DECLARE v_err_code2 = i4 WITH protect, noconstant(0)
 DECLARE tok_ndx = i4 WITH protect, noconstant(0)
 DECLARE star = i4 WITH protect, noconstant(0)
 DECLARE row_cnt = i4 WITH protect, noconstant(0)
 DECLARE min_days_to_keep = i4 WITH protect, constant(1095)
 SET reply->status_data.status = "F"
 SET reply->table_name = "PFT_RVU_CONTENT"
 SET reply->rows_between_commit = 100
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = cnvtreal(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF (v_days_to_keep < min_days_to_keep)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"DAYSTOKEEP",build2("You must keep at least",
    " ",trim(cnvtstring(min_days_to_keep))," ",
    "days' worth of data. You entered %1 days or did not enter any value."),"i",v_days_to_keep)
 ELSE
  SELECT INTO "nl:"
   FROM pft_rvu_content prc
   WHERE prc.end_effective_dt_tm <= cnvtdatetime((curdate - v_days_to_keep),235959)
    AND parser(sbr_getrowidnotexists("prc.pft_rvu_content_id+0 > 0","prc"))
   HEAD REPORT
    row_cnt = 0, stat = alterlist(reply->rows,(row_cnt+ 49))
   DETAIL
    row_cnt = (row_cnt+ 1)
    IF (mod(row_cnt,50)=1)
     stat = alterlist(reply->rows,(row_cnt+ 49))
    ENDIF
    reply->rows[row_cnt].row_id = prc.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,row_cnt)
   WITH nocounter, maxqual(prc,value(request->max_rows))
  ;end select
  SET v_errcode2 = error(v_errmsg2,1)
  IF (v_errcode2 != 0)
   SET reply->err_code = v_errcode2
   SET reply->status_data.status = "F"
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s2","Failed in row collection: %1","s",
    nullterm(v_errmsg2))
   GO TO exit_script
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->err_code = 0
#exit_script
 ENDIF
END GO
