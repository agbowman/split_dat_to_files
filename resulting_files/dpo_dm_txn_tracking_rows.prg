CREATE PROGRAM dpo_dm_txn_tracking_rows
 DECLARE ddttr_maxrows = i4 WITH protect, noconstant(0.0)
 DECLARE ddttr_daystokeep = i4 WITH protect, noconstant(0.0)
 DECLARE ddttr_nanos_date_char = vc WITH protect, noconstant(" ")
 DECLARE ddttr_nanos_date_value = f8 WITH protect, noconstant(0.0)
 DECLARE ddttr_min_rowscn = f8 WITH protect
 DECLARE ddttr_cursor_query = vc WITH protect, noconstant("")
 DECLARE ddttr_fetch_size = i4 WITH protect, noconstant(0)
 DECLARE ddttr_err_code = i4 WITH protect, noconstant(0)
 DECLARE ddttr_err_msg = vc WITH protect, noconstant(" ")
 DECLARE ddttr_i18var = vc WITH protect, noconstant(" ")
 DECLARE ddttr_char_to_nanos(dctn_date_char=vc,dctn_date_fmt=vc) = f8 WITH sql =
 "dm_nanos.char_to_nanos", parameter
 SET dpo_reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET dpo_reply->owner_name = "V500"
 SET dpo_reply->table_name = "DM_TXN_TRACKING"
 SUBROUTINE get_min_rowscn(initial_upper_bound)
   DECLARE ddttr_gmr_lower_bound = f8 WITH protect, noconstant(1.0)
   DECLARE ddttr_gmr_upper_bound = f8 WITH protect, noconstant(initial_upper_bound)
   DECLARE ddttr_gmr_min_scn = f8 WITH protect, noconstant((ddttr_gmr_upper_bound - 86400000000000.0)
    )
   DECLARE ddttr_gmr_query_res = f8 WITH protect
   WHILE (nullval(ddttr_gmr_lower_bound,- (1.0)) > 0.0)
     SET ddttr_gmr_lower_bound = (ddttr_gmr_upper_bound - 86400000000000.0)
     SELECT INTO "nl:"
      min_rowscn = min(row_scn)
      FROM dm_txn_tracking
      WHERE row_scn >= ddttr_gmr_lower_bound
       AND row_scn < ddttr_gmr_upper_bound
      DETAIL
       ddttr_gmr_query_res = min_rowscn
      WITH nocounter
     ;end select
     IF (nullval(ddttr_gmr_query_res,- (1.0)) > 0.0)
      SET ddttr_gmr_min_scn = ddttr_gmr_query_res
     ELSE
      SET ddttr_gmr_lower_bound = null
     ENDIF
     SET ddttr_err_code = error(ddttr_err_msg,1)
     IF (ddttr_err_code > 0)
      SET dpo_reply->err_code = ddttr_err_code
      SET dpo_reply->status_data.status = "F"
      SET ddttr_i18var = uar_i18nbuildmessage(i18nhandle,"fcall1","DDTTR: %1","s",ddttr_err_msg)
      SET dpo_reply->err_msg = ddttr_i18var
      GO TO exit_program
     ENDIF
     SET ddttr_gmr_upper_bound = ddttr_gmr_lower_bound
   ENDWHILE
   RETURN(ddttr_gmr_min_scn)
 END ;Subroutine
 IF ((b_request->max_rows < 0))
  SET ddttr_maxrows = b_request->max_rows
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET ddttr_i18var = uar_i18nbuildmessage(i18nhandle,"maxrows",
   "MAXROWS must be greater than 0.  You entered %1 or did not enter a value.","i",ddttr_maxrows)
  SET dpo_reply->err_msg = ddttr_i18var
  GO TO exit_program
 ENDIF
 FOR (tok_ndx = 1 TO size(b_request->tokens,5))
  IF ((b_request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
   SET ddttr_daystokeep = ceil(cnvtreal(b_request->tokens[tok_ndx].value))
  ENDIF
  IF ((b_request->tokens[tok_ndx].token_str="ROWSBETWEENCOMMIT"))
   SET ddttr_fetch_size = ceil(cnvtreal(b_request->tokens[tok_ndx].value))
  ENDIF
 ENDFOR
 IF (validate(request->debug_mode,"Z") != "Z")
  CALL echorecord(b_request)
  CALL echo(build("ddttr_daystokeep:",ddttr_daystokeep))
  CALL echo(build("ddttr_fetch_size:",ddttr_fetch_size))
 ENDIF
 IF (((ddttr_daystokeep < 8) OR (ddttr_daystokeep > 180)) )
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET ddttr_i18var = uar_i18nbuildmessage(i18nhandle,"daystokeep",
   "DAYSTOKEEP must be between 8 and 180 days.  You entered %1 or did not enter a value.","i",
   ddttr_daystokeep)
  SET dpo_reply->err_msg = ddttr_i18var
  GO TO exit_program
 ENDIF
 IF (((ddttr_fetch_size < 100) OR (ddttr_fetch_size > 100000)) )
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET ddttr_i18var = uar_i18nbuildmessage(i18nhandle,"rowsbetweencommit",
   "ROWSBETWEENCOMMIT must be between 100 and 100000.  You entered %1 or did not enter a value.","i",
   ddttr_fetch_size)
  SET dpo_reply->err_msg = ddttr_i18var
  GO TO exit_program
 ENDIF
 IF ( NOT (validate(ddttr_override_val)))
  SET ddttr_nanos_date_char = format(datetimeadd(sysdate,(ddttr_daystokeep * - (1))),
   "YYYY-MM-DD HH:MM:SS;;D")
  IF (validate(request->debug_mode,"Z") != "Z")
   CALL echo(build("ddttr_nanos_date_char:",ddttr_nanos_date_char))
  ENDIF
  SET dm_err->eproc =
  "DDTTR: Calling dm_nanos.char_to_nanos to get epoc row_scn purge threshold value"
  SELECT INTO "nl:"
   val1 = ddttr_char_to_nanos(ddttr_nanos_date_char,"YYYY-MM-DD HH24:MI:SS")
   FROM dual
   DETAIL
    ddttr_nanos_date_value = val1
   WITH nocounter
  ;end select
  SET ddttr_err_code = error(ddttr_err_msg,1)
  IF (ddttr_err_code > 0)
   SET dpo_reply->err_code = ddttr_err_code
   SET dpo_reply->status_data.status = "F"
   SET ddttr_i18var = uar_i18nbuildmessage(i18nhandle,"fcall1","DDTTR: %1","s",ddttr_err_msg)
   SET dpo_reply->err_msg = ddttr_i18var
   GO TO exit_program
  ENDIF
 ENDIF
 IF (validate(ddttr_override_val,- (1)) > 1)
  SET ddttr_nanos_date_value = ddttr_override_val
 ENDIF
 IF (validate(request->debug_mode,"Z") != "Z")
  CALL echo(build("ddttr_nanos_date_value:",ddttr_nanos_date_value))
 ENDIF
 IF (ddttr_nanos_date_value <= 0)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET ddttr_i18var = uar_i18nbuildmessage(i18nhandle,"fcall2",
   "dm_nanos.char_to_nanos returned an invalid value of : %1. Must be > 0.","i",
   ddttr_nanos_date_value)
  SET dpo_reply->err_msg = ddttr_i18var
  GO TO exit_program
 ENDIF
 SET ddttr_min_rowscn = get_min_rowscn(ddttr_nanos_date_value)
 SET ddttr_cursor_query = build("select rowid from V500.DM_TXN_TRACKING WHERE ROW_SCN >= ",
  ddttr_min_rowscn," AND ROW_SCN < ",ddttr_nanos_date_value)
 SET dpo_reply->max_rows = b_request->max_rows
 SET dpo_reply->cursor_query = ddttr_cursor_query
 SET dpo_reply->fetch_size = ddttr_fetch_size
 SET dpo_reply->status_data.status = "S"
 GO TO exit_program
#exit_program
END GO
