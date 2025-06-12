CREATE PROGRAM dpo_extraction_trans_log_rows:dba
 SET dpo_reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET dpo_reply->owner_name = "V500"
 SET dpo_reply->table_name = "EXTRACTION_TRANS_LOG"
 SET dpo_reply->fetch_size = 10000
 DECLARE v_daystokeep = i4 WITH protect, noconstant(- (1))
 DECLARE v_tok_ndx = i4 WITH protect, noconstant(0)
 FOR (v_tok_ndx = 1 TO size(b_request->tokens,5))
   IF ((b_request->tokens[v_tok_ndx].token_str="DAYSTOKEEP"))
    SET v_daystokeep = ceil(cnvtreal(b_request->tokens[v_tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_daystokeep < 3)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"daystokeep",
   "You must keep at least 3 days' worth of data.  You entered %1 days or did not enter any value.",
   "i",v_daystokeep)
  GO TO exit_program
 ENDIF
 SET dper_date_char = format(datetimeadd(sysdate,(v_daystokeep * - (1))),"YYYY-MM-DD;;D")
 SET dpo_reply->cursor_query = build("select rowid from V500.EXTRACTION_TRANS_LOG WHERE UPDT_DT_TM <",
  " to_date('",dper_date_char,"', 'YYYY-MM-DD')")
 SET dpo_reply->status_data.status = "S"
 SET dpo_reply->err_code = 0
 GO TO exit_program
#exit_program
END GO
