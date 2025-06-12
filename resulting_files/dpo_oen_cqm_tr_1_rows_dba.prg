CREATE PROGRAM dpo_oen_cqm_tr_1_rows:dba
 SET dpo_reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET dpo_reply->owner_name = "V500"
 SET dpo_reply->table_name = "CQM_OENINTERFACE_TR_1"
 SET dpo_reply->fetch_size = minval(10000,b_request->max_rows)
 DECLARE v_days_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_hours_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_tok_ndx = i4 WITH protect, noconstant(0)
 DECLARE purgedate = dq8 WITH protect, noconstant(0.0)
 FOR (v_tok_ndx = 1 TO size(b_request->tokens,5))
   IF ((b_request->tokens[v_tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(b_request->tokens[v_tok_ndx].value))
   ELSEIF ((b_request->tokens[v_tok_ndx].token_str="HRSTOKEEP"))
    SET v_hours_to_keep = ceil(cnvtreal(b_request->tokens[v_tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 0)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s1",
   "You must enter a value of 0 or more for the DAYSTOKEEP token.  You entered %1 days or did not enter any value.",
   "i",v_days_to_keep)
  GO TO exit_script
 ELSEIF (v_hours_to_keep < 0)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s2",
   "You must enter a value of 0 or more for the HRSTOKEEP token.  You entered %1 hours or did not enter any value.",
   "i",v_hours_to_keep)
  GO TO exit_script
 ENDIF
 SET purgedate = cnvtdatetime((curdate - v_days_to_keep),(curtime3 - v_hours_to_keep))
 SET dpo_reply->cursor_query = build(
  "select rowid from V500.CQM_OENINTERFACE_TR_1 WHERE CREATE_DT_TM <"," to_date('",format(purgedate,
   "DD/MM/YYYY HH:MM:SS;;Q"),"','DD/MM/YYYY HH24:MI:SS')",
  " and queue_id > 0 and process_status_flag NOT IN (10,1100,1170)")
 SET dpo_reply->status_data.status = "S"
 SET dpo_reply->err_code = 0
#exit_script
END GO
