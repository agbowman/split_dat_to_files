CREATE PROGRAM bhs_rpt_get_application_login
 PROMPT
  "app number" = 0,
  "start date/time" = "SYSDATE",
  "End Date/Time" = "SYSDATE",
  "Output to File/Printer/MINE" = "MINE"
  WITH app_id, start_dt_tm, end_dt_tm,
  outddev
 DECLARE end_range = dq8 WITH protect
 DECLARE start_range = dq8 WITH protect
 IF (validate(request->batch_selection))
  SET operations = 1
  SET start_range = cnvtdatetime((curdate - 1),0)
  SET end_range = cnvtdatetime((curdate - 1),235959)
 ELSE
  SET start_range = cnvtdatetime( $START_DT_TM)
  SET end_range = cnvtdatetime( $END_DT_TM)
 ENDIF
 INSERT  FROM bhs_application_login_data ald
  (ald.app_ctx_id, ald.person_id, ald.name_full_formatted,
  ald.position_cd, ald.application_number, ald.start_dt_tm,
  ald.end_dt_tm)(SELECT
   a.app_ctx_id, a.person_id, a.name,
   a.position_cd, a.application_number, a.start_dt_tm,
   a.end_dt_tm
   FROM application_context a
   WHERE (a.application_number= $APP_ID)
    AND a.end_dt_tm != null
    AND a.start_dt_tm BETWEEN cnvtdatetime(start_range) AND cnvtdatetime(end_range))
 ;end insert
 COMMIT
END GO
