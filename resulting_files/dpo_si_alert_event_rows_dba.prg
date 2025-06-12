CREATE PROGRAM dpo_si_alert_event_rows:dba
 SET dpo_reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET dpo_reply->owner_name = "V500"
 SET dpo_reply->table_name = "SI_ALERT_EVENT"
 SET dpo_reply->fetch_size = minval(10000,b_request->max_rows)
 DECLARE v_daystokeep = i4 WITH protect, noconstant(- (1))
 DECLARE v_tok_ndx = i4 WITH protect, noconstant(0)
 DECLARE purgedate = dq8 WITH protect, noconstant(0.0)
 FOR (v_tok_ndx = 1 TO size(b_request->tokens,5))
   IF ((b_request->tokens[v_tok_ndx].token_str="DAYSTOKEEP"))
    SET v_daystokeep = ceil(cnvtreal(b_request->tokens[v_tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_daystokeep < 30)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s1",
   "You must keep at least 30 days' worth of data.  You entered %1 days or did not enter any value.",
   "i",v_daystokeep)
  GO TO exit_script
 ENDIF
 SET purgedate = cnvtdatetime((curdate - v_daystokeep),curtime3)
 SET dpo_reply->cursor_query = build("select rowid from V500.SI_ALERT_EVENT sae WHERE UPDT_DT_TM <",
  " to_date('",format(purgedate,"DD/MM/YYYY HH:MM:SS;;Q"),"','DD/MM/YYYY HH24:MI:SS')",
  " and si_alert_event_id > 0")
 SET dpo_reply->status_data.status = "S"
 SET dpo_reply->err_code = 0
#exit_script
END GO
