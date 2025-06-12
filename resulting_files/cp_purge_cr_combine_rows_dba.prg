CREATE PROGRAM cp_purge_cr_combine_rows:dba
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
 CALL echo("Beginning CP_PURGE_CR_COMBINE_ROWS")
 DECLARE cr_cnt = i4
 DECLARE chart_cnt = i4
 DECLARE y = i4
 SET error_msg = fillstring(255," ")
 SET error_check = error(error_msg,1)
 SET cr_cnt = 0.0
 SET chart_cnt = 0.0
 SET y = 0
 SELECT INTO "nl:"
  ucc.column_name
  FROM user_cons_columns ucc,
   user_constraints uc
  WHERE uc.table_name="CHART_REQUEST_ENCNTR"
   AND uc.constraint_type="P"
   AND ucc.table_name=uc.table_name
   AND ucc.constraint_name=uc.constraint_name
   AND ucc.column_name="CHART_REQUEST_ENCNTR_ID"
  WITH nocounter
 ;end select
 IF (curqual=1)
  CALL echo("executing dm_temp_tables")
  EXECUTE dm_temp_tables
  CALL echo("finished executing dm_temp_tables")
  SELECT INTO "nl:"
   dcc.child_pk
   FROM dm_cmb_children dcc
   WHERE dcc.child_table="CHART_REQUEST_ENCNTR"
    AND dcc.parent_table="ENCOUNTER"
    AND dcc.child_pk="CHART_REQUEST_ID"
   WITH nocounter
  ;end select
  IF (curqual=1)
   DELETE  FROM dm_cmb_children dcc
    WHERE dcc.child_table="CHART_REQUEST_ENCNTR"
     AND dcc.parent_table="ENCOUNTER"
     AND dcc.child_pk="CHART_REQUEST_ID"
    WITH nocounter
   ;end delete
   CALL echo("deleting dm_cmb_children row for chart_request_id")
   UPDATE  FROM dm_info di
    SET di.info_date = cnvtdatetime(sysdate), di.updt_id = 0, di.updt_dt_tm = cnvtdatetime(sysdate),
     di.updt_task = 0, di.updt_applctx = 0, di.updt_cnt = (di.updt_cnt+ 1)
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="USERLASTUPDT"
    WITH nocounter
   ;end update
   COMMIT
   CALL echo("refreshing dm_info table")
  ELSE
   CALL echo("nothing needs to be done to dm_info table or dm_cmb_children")
  ENDIF
 ELSE
  CALL echo("error with schema")
  SET readme_data->status = "F"
  SET readme_data->message = build("Invalid Schema for DM_CMB_CHILDREN refresh - FAILURE.")
  ROLLBACK
  GO TO exit_script
 ENDIF
 FREE RECORD chart_request_encntr
 RECORD chart_request_encntr(
   1 qual[*]
     2 chart_request_id = f8
 )
 SELECT INTO "nl:"
  ec.*, cre.*
  FROM encntr_combine ec,
   chart_request_encntr cre
  PLAN (cre
   WHERE cre.chart_request_encntr_id > 0)
   JOIN (ec
   WHERE ((ec.from_encntr_id=cre.encntr_id) OR (ec.to_encntr_id=cre.encntr_id))
    AND ec.from_encntr_id > 0
    AND ec.to_encntr_id > 0)
  HEAD REPORT
   cr_cnt = 0
  HEAD cre.chart_request_id
   cr_cnt += 1, stat = alterlist(chart_request_encntr->qual,cr_cnt), chart_request_encntr->qual[
   cr_cnt].chart_request_id = cre.chart_request_id
  DETAIL
   do_nothing = 0
  WITH nocounter
 ;end select
 SET chart_cnt = size(chart_request_encntr->qual,5)
 CALL echo(build("chart_cnt = ",chart_cnt))
 SET y = 0
 FOR (y = 1 TO chart_cnt)
   CALL echo(build("DELETING CHART_REQUEST_ID = ",chart_request_encntr->qual[y].chart_request_id))
 ENDFOR
 SET purge_on = 1
 CALL echo(build("purge_on = ",purge_on))
 IF (chart_cnt > 0)
  IF (purge_on=1)
   DELETE  FROM chart_request_encntr cre,
     (dummyt d  WITH seq = value(chart_cnt))
    SET cre.seq = 1
    PLAN (d)
     JOIN (cre
     WHERE (cre.chart_request_id=chart_request_encntr->qual[d.seq].chart_request_id))
    WITH nocounter
   ;end delete
   SET error_chk = 1
   SET error_chk = error(error_msg,0)
   IF (error_chk=0)
    SET do_nothing = 0
   ELSE
    SET readme_data->status = "F"
    SET readme_data->message = build("CCL ERROR: ",trim(error_msg)," - FAILURE.")
    ROLLBACK
    GO TO exit_script
   ENDIF
   DELETE  FROM chart_request cr,
     (dummyt d  WITH seq = value(chart_cnt))
    SET cr.seq = 1
    PLAN (d)
     JOIN (cr
     WHERE (cr.chart_request_id=chart_request_encntr->qual[d.seq].chart_request_id))
    WITH nocounter
   ;end delete
   SET error_chk = 1
   SET error_chk = error(error_msg,0)
   IF (error_chk=0)
    SET do_nothing = 0
    COMMIT
    SET readme_data->status = "S"
    SET readme_data->message =
    "Successfully Removed Combined Encounter Rows on CHART_REQUEST_ENCNTR - SUCCESSFUL."
   ELSE
    SET readme_data->status = "F"
    SET readme_data->message = build("CCL ERROR: ",trim(error_msg)," - FAILURE.")
    ROLLBACK
    GO TO exit_script
   ENDIF
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "Purge is OFF."
   CALL echo("purge is off")
  ENDIF
 ELSE
  CALL echo("no rows to remove")
  SET readme_data->status = "S"
  SET readme_data->message = "No rows to remove - SUCCESSFUL."
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 COMMIT
END GO
