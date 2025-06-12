CREATE PROGRAM dpo_glb_pn_recovery_rows:dba
 SET dpo_reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET dpo_reply->owner_name = "V500"
 SET dpo_reply->table_name = "PN_RECOVERY"
 SET dpo_reply->fetch_size = 10000
 DECLARE v_daystokeep = i4 WITH protect, noconstant(- (1))
 DECLARE v_tok_ndx = i4 WITH protect, noconstant(0)
 DECLARE pnt_charge_cd = f8 WITH constant(uar_get_code_by("MEANING",28600,"PNT_CHARGE")), protect
 FOR (v_tok_ndx = 1 TO size(b_request->tokens,5))
   IF ((b_request->tokens[v_tok_ndx].token_str="DAYSTOKEEP"))
    SET v_daystokeep = ceil(cnvtreal(b_request->tokens[v_tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_daystokeep < 1)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s1",
   "You must keep at least 1 days' worth of data.  You entered %1 days or did not enter any value.",
   "i",v_daystokeep)
  GO TO exit_script
 ENDIF
 SET dpo_reply->cursor_query = build("select rowid from V500.PN_RECOVERY WHERE EXPIRE_DT_TM <=",
  " to_date('",format(datetimeadd(sysdate,(v_daystokeep * - (1))),"YYYY-MM-DD;;D"),"', 'YYYY-MM-DD')",
  " and recovery_type_cd = (",
  pnt_charge_cd,")")
 SET dpo_reply->status_data.status = "S"
 SET dpo_reply->err_code = 0
#exit_script
END GO
