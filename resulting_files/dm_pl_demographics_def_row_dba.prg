CREATE PROGRAM dm_pl_demographics_def_row:dba
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
 DECLARE errcode = i4
 DECLARE errmsg = c132
 DECLARE hasdefrow = i4
 DECLARE hastrigger = i4
 DECLARE tblsuffixname = c4
 DECLARE triggername = c30
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting dm_pl_demographics_def_row.prg ..."
 SET errcode = 0
 SET errmsg = fillstring(132," ")
 SET hasdefrow = 0
 SET hastrigger = 0
 IF (currdb != "ORACLE")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-Success for non-Oracle environment"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_tables_doc dtd
  WHERE dtd.table_name="PL_DEMOGRAPHICS"
  DETAIL
   hasdefrow = dtd.default_row_ind, tblsuffixname = dtd.table_suffix
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Table PL_DEMOGRAPHICS does not exist and does not need to be updated."
  GO TO exit_script
 ENDIF
 IF (hasdefrow=0)
  UPDATE  FROM dm_tables_doc dtd
   SET dtd.default_row_ind = 1
   WHERE dtd.table_name="PL_DEMOGRAPHICS"
  ;end update
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = build("Readme Failed: Error updating DM_TABLES_DOC:",errmsg)
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 SET triggername = concat("TRG_",tblsuffixname,"_DR_UPDT_DEL")
 CALL echo(build("Trigger Name:",triggername))
 SELECT INTO "nl:"
  FROM dba_triggers dt
  WHERE dt.trigger_name=triggername
  DETAIL
   hastrigger = 1
  WITH nocounter
 ;end select
 IF (hastrigger=1)
  IF (hasdefrow=1)
   SET readme_data->status = "S"
   SET readme_data->message = "Readme Successful: Default Row Indicator and Trigger already exist."
   GO TO exit_script
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message =
   "Readme Successful: Default Row Indicator updated and Trigger already exists."
   GO TO exit_script
  ENDIF
 ELSE
  EXECUTE dm2_add_default_rows "PL_DEMOGRAPHICS"
  IF (hasdefrow=1)
   SET readme_data->status = "S"
   SET readme_data->message = "Readme Successful: Default Row Indicator exists and Trigger created."
   GO TO exit_script
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "Readme Successful: Default Row Indicator updated and Trigger created."
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
