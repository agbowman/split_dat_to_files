CREATE PROGRAM dpo_process_event_dtl_rows:dba
 DECLARE dper_maxrows = i4 WITH protect, noconstant(0)
 DECLARE dper_daystokeep = i4 WITH protect, noconstant(0)
 DECLARE dper_date_char = vc WITH protect, noconstant(" ")
 DECLARE dper_cursor_query = vc WITH protect, noconstant("")
 DECLARE dper_fetch_size = i4 WITH protect, noconstant(0)
 DECLARE dper_i18var = vc WITH protect, noconstant(" ")
 SET dpo_reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET dpo_reply->owner_name = "V500"
 SET dpo_reply->table_name = "DM_PROCESS_EVENT_DTL"
 IF ((b_request->max_rows < 0))
  SET dper_maxrows = b_request->max_rows
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET dper_i18var = uar_i18nbuildmessage(i18nhandle,"maxrows",
   "MAXROWS must be greater than 0.  You entered %1 or did not enter a value.","i",dper_maxrows)
  SET dpo_reply->err_msg = dper_i18var
  GO TO exit_program
 ENDIF
 FOR (tok_ndx = 1 TO size(b_request->tokens,5))
  IF ((b_request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
   SET dper_daystokeep = ceil(cnvtreal(b_request->tokens[tok_ndx].value))
  ENDIF
  IF ((b_request->tokens[tok_ndx].token_str="ROWSBETWEENCOMMIT"))
   SET dper_fetch_size = ceil(cnvtreal(b_request->tokens[tok_ndx].value))
  ENDIF
 ENDFOR
 IF (validate(request->debug_mode,"Z") != "Z")
  CALL echorecord(b_request)
  CALL echo(build("dper_daystokeep:",dper_daystokeep))
  CALL echo(build("dper_fetch_size:",dper_fetch_size))
 ENDIF
 IF (((dper_daystokeep < 30) OR (dper_daystokeep > 730)) )
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET dper_i18var = uar_i18nbuildmessage(i18nhandle,"daystokeep",
   "DAYSTOKEEP must be between 30 and 730 days.You entered %1 or did not enter a value.","i",
   dper_daystokeep)
  SET dpo_reply->err_msg = dper_i18var
  GO TO exit_program
 ENDIF
 IF (((dper_fetch_size < 10) OR (dper_fetch_size > 1000000)) )
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET dper_i18var = uar_i18nbuildmessage(i18nhandle,"rowsbetweencommit",
   "ROWSBETWEENCOMMIT must be between 10 and 1000000.  You entered %1 or did not enter a value.","i",
   dper_fetch_size)
  SET dpo_reply->err_msg = dper_i18var
  GO TO exit_program
 ENDIF
 SET dper_date_char = format(datetimeadd(sysdate,(dper_daystokeep * - (1))),"YYYY-MM-DD;;D")
 IF (validate(dper_lookbehind_secs,- (1)) > 1)
  SET dper_date_char = format(cnvtlookbehind(build(dper_lookbehind_secs,"S",sysdate)),
   "YYYY-MM-DD ;;D")
 ENDIF
 IF (validate(request->debug_mode,"Z") != "Z")
  CALL echo(build("dper_date_char:",dper_date_char))
 ENDIF
 SET dper_cursor_query = build("select rowid from V500.DM_PROCESS_EVENT_DTL WHERE UPDT_DT_TM <",
  " to_date('",dper_date_char,"', 'YYYY-MM-DD')")
 SET dpo_reply->cursor_query = dper_cursor_query
 SET dpo_reply->fetch_size = dper_fetch_size
 SET dpo_reply->status_data.status = "S"
 GO TO exit_program
#exit_program
END GO
