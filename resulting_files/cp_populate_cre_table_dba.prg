CREATE PROGRAM cp_populate_cre_table:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 CALL echo("Beginning CP_POPULATE_CRE_TABLE")
 DECLARE table_exists_now = i4
 DECLARE cur_status = c1
 DECLARE message_text = c100
 DECLARE column_exists_now = i4
 DECLARE sequence_exists_now = i4
 DECLARE min_cr_id = f8
 DECLARE max_cr_id = f8
 DECLARE count_cr_id = f8
 DECLARE max_cr_encntr_id = f8
 DECLARE cr_done = i4
 DECLARE cr_cnt1 = f8
 DECLARE cr_cnt2 = f8
 SET table_exists_now = 0
 SET cur_status = "F"
 SET message_text = fillstring(100," ")
 SET error_msg = fillstring(255," ")
 SET error_chk = 0
 SET error_chk = error(error_msg,1)
 SET column_exists_now = 0
 SET sequence_exists_now = 0
 SET min_cr_id = 0.0
 SET max_cr_id = 0.0
 SET count_cr_id = 0
 SET max_cr_encntr_id = 0.0
 SET cr_cnt1 = 0.0
 SET cr_cnt2 = 0.0
 SELECT INTO "nl:"
  u.*
  FROM user_tables u
  WHERE u.table_name="CHART_REQUEST_ENCNTR"
  HEAD REPORT
   table_exists_now = 1
  WITH nocounter
 ;end select
 IF (table_exists_now=1)
  SET message_text = "CHART_REQUEST_ENCNTR table currently exists - SUCCESSFUL."
  CALL echo("Table exists")
 ELSE
  SET cur_status = "S"
  SET message_text = "CHART_REQUEST_ENCNTR table does not exist - SUCCESSFUL."
  CALL echo("Table not there, exit as successful.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  u.column_name
  FROM user_tab_columns u
  WHERE u.table_name="CHART_REQUEST_ENCNTR"
   AND u.column_name="CHART_REQUEST_ENCNTR_ID"
  HEAD REPORT
   column_exists_now = 1
  WITH nocounter
 ;end select
 IF (column_exists_now=0)
  CALL parser("RDB ALTER TABLE CHART_REQUEST_ENCNTR ADD CHART_REQUEST_ENCNTR_ID NUMBER GO")
  CALL parser("oragen3 'chart_request_encntr' go")
  CALL echo("Added CHART_REQUEST_ENCNTR_ID field manually")
 ENDIF
 SELECT INTO "nl:"
  u.*
  FROM user_sequences u
  WHERE u.sequence_name="CHART_REQUEST_ENCNTR_SEQ"
  HEAD REPORT
   sequence_exists_now = 1
  WITH nocounter
 ;end select
 IF (sequence_exists_now=0)
  SET cur_status = "F"
  SET message_text = "The CHART_REQUEST_ENCNTR_SEQ does not exist - FAILURE."
  CALL echo("Sequence not there")
  GO TO exit_script
 ELSE
  SELECT INTO "nl:"
   cr1 = min(c.chart_request_id), cr2 = max(c.chart_request_id), cnt3 = count(c.chart_request_id),
   cr4 = max(c.chart_request_encntr_id)
   FROM chart_request_encntr c
   WHERE c.chart_request_id > 0
   DETAIL
    min_cr_id = cr1, max_cr_id = cr2, count_cr_id = cnt3,
    max_cr_encntr_id = cr4
   WITH nocounter
  ;end select
  CALL echo(build("min_cr_id = ",min_cr_id))
  CALL echo(build("max_cr_id = ",max_cr_id))
  CALL echo(build("count_cr_id = ",count_cr_id))
  CALL echo(build("max_cr_encntr_id = ",max_cr_encntr_id))
  SET cr_done = 0
  IF (count_cr_id=0)
   SET cr_done = 1
   SET cur_status = "S"
   SET message_text = "No rows exist on CHART_REQUEST_ENCNTR table - Exiting as SUCCESSFUL."
   GO TO exit_script
  ENDIF
  IF (max_cr_encntr_id > 0)
   SET cr_done = 1
   SET cur_status = "S"
   SET message_text = "No rows to update on CHART_REQUEST_ENCNTR table - Exiting as SUCCESSFUL."
   GO TO exit_script
  ENDIF
  SET cr_cnt1 = 0.0
  SET cr_cnt2 = 0.0
  SET cr_cnt1 = min_cr_id
  SET cr_cnt2 = (min_cr_id+ 10000)
  WHILE (cr_done=0)
    UPDATE  FROM chart_request_encntr c
     SET c.chart_request_encntr_id = seq(chart_request_encntr_seq,nextval)
     WHERE c.chart_request_id BETWEEN cr_cnt1 AND cr_cnt2
      AND c.chart_request_encntr_id IN (null, 0)
     WITH nocounter
    ;end update
    SET error_chk = 1
    SET error_chk = error(error_msg,0)
    IF (error_chk=0)
     SET cur_status = "S"
     SET message_text = "Successfully updated CHART_REQUEST_ENCNTR rows - SUCCESSFUL."
     COMMIT
    ELSE
     SET cur_status = "F"
     SET message_text = build("CCL ERROR:",trim(error_msg)," - FAILURE")
     ROLLBACK
     GO TO exit_script
    ENDIF
    IF (cr_cnt2 > max_cr_id)
     SET cr_done = 1
    ELSE
     SET cr_cnt1 = cr_cnt2
     SET cr_cnt2 = (cr_cnt1+ 10000)
    ENDIF
  ENDWHILE
 ENDIF
#exit_script
 SET readme_data->status = cur_status
 CALL echo(build("cur_status = ",cur_status))
 CALL echo(build("message_text = ",message_text))
 SET readme_data->message = message_text
 EXECUTE dm_readme_status
 COMMIT
END GO
