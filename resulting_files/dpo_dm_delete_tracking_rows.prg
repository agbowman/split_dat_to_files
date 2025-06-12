CREATE PROGRAM dpo_dm_delete_tracking_rows
 DECLARE dddttr_cursor_query = vc WITH protect, noconstant("")
 DECLARE dddttr_fetch_size = f8 WITH protect, noconstant(10000)
 DECLARE dddttr_max_utc_ts = dm12 WITH protect, constant(cnvtlookbehind("3,M"))
 DECLARE dddttr_min_utc_ts = dm12 WITH protect
 SET dpo_reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET dpo_reply->owner_name = "V500"
 SET dpo_reply->table_name = "DM_DELETE_TRACKING"
 IF ((b_request->max_rows < 0))
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = 1
  SET dpo_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"maxrows",
   "MAXROWS must be greater than 0.  You entered %1 or did not enter a value.","i",b_request->
   max_rows)
  GO TO exit_program
 ENDIF
 SUBROUTINE get_min_utc_ts(initial_upper_bound)
   DECLARE dddttr_gmut_upper_bound = dm12 WITH protect, noconstant(datetimetrunc(cnvtdatetime(
      initial_upper_bound),"DD"))
   DECLARE dddttr_gmut_lower_bound = dm12 WITH protect, noconstant(dddttr_gmut_upper_bound)
   DECLARE dddttr_gmut_min_utc_ts = dm12 WITH protect, noconstant(datetimetrunc(cnvtdatetime(
      cnvtlookbehind("1,D",initial_upper_bound)),"DD"))
   DECLARE dddttr_gmut_query_res = dm12 WITH protect
   WHILE (dddttr_gmut_lower_bound != null)
     SET dddttr_gmut_lower_bound = cnvtlookbehind("1,D",dddttr_gmut_upper_bound)
     SELECT INTO "nl:"
      min_utc_ts = min(last_utc_ts)
      FROM dm_delete_tracking
      WHERE last_utc_ts >= dddttr_gmut_lower_bound
       AND last_utc_ts < dddttr_gmut_upper_bound
      DETAIL
       dddttr_gmut_query_res = min_utc_ts
      WITH nocounter
     ;end select
     IF (dddttr_gmut_query_res != null)
      SET dddttr_gmut_min_utc_ts = dddttr_gmut_query_res
     ELSE
      SET dddttr_gmut_lower_bound = null
     ENDIF
     SET dddttr_gmut_upper_bound = dddttr_gmut_lower_bound
   ENDWHILE
   RETURN(dddttr_gmut_min_utc_ts)
 END ;Subroutine
 SET dddttr_min_utc_ts = get_min_utc_ts(dddttr_max_utc_ts)
 SET dddttr_cursor_query = concat(concat(
   "select rowid from V500.DM_DELETE_TRACKING WHERE last_utc_ts >= '",format(dddttr_min_utc_ts,
    "DD-MMM-YYYY;;D"),"' AND last_utc_ts < '"),format(dddttr_max_utc_ts,"DD-MMM-YYYY;;D"),"'")
 SET dpo_reply->max_rows = b_request->max_rows
 SET dpo_reply->cursor_query = dddttr_cursor_query
 SET dpo_reply->fetch_size = dddttr_fetch_size
 SET dpo_reply->status_data.status = "S"
 GO TO exit_program
#exit_program
END GO
