CREATE PROGRAM dpo_bmdi_assoc_hints_rows:dba
 SET dpo_reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET dpo_reply->owner_name = "V500"
 SET dpo_reply->table_name = "BMDI_ASSOCIATION_HINTS"
 SET dpo_reply->fetch_size = 10000
 DECLARE bmdi_cursor_query = vc WITH protect, noconstant("")
 DECLARE v_days_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_tok_ndx = i4 WITH protect, noconstant(0)
 DECLARE unit_in_days = vc WITH protect, noconstant(" ")
 FOR (v_tok_ndx = 1 TO size(b_request->tokens,5))
   IF ((b_request->tokens[v_tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(b_request->tokens[v_tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 0)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"DAYSTOKEEP",
   "You must enter a number greater than or equal to 0.  You entered %1 days or did not enter any value.",
   "i",v_days_to_keep)
  GO TO exit_script
 ENDIF
 SET unit_in_days = format(cnvtlookbehind(concat(trim(cnvtstring(v_days_to_keep)),",D")),
  "YYYY-MM-DD HH:MM:SS;;D")
 SET bmdi_cursor_query = build("select rowid from V500.BMDI_ASSOCIATION_HINTS WHERE UPDT_DT_TM <",
  "to_date('",unit_in_days,"','YYYY-MM-DD HH24:MI:SS') and hint_id > 0.0")
 SET dpo_reply->max_rows = b_request->max_rows
 SET dpo_reply->cursor_query = bmdi_cursor_query
 SET dpo_reply->status_data.status = "S"
 SET dpo_reply->err_code = 0
#exit_script
END GO
