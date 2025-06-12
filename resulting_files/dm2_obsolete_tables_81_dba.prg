CREATE PROGRAM dm2_obsolete_tables_81:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Failed to execute in database specific IF() statement"
 IF (currdb="ORACLE")
  DECLARE num_tbls = i4 WITH protect, noconstant(0)
  DECLARE errmsg = vc WITH protect, noconstant(fillstring(132," "))
  DECLARE errcode = i4 WITH protect, noconstant(0)
  SET num_tbls = size(requestin->list_0,5)
  FOR (tbl_cnt = 1 TO num_tbls)
   EXECUTE dm_drop_obsolete_objects cnvtupper(requestin->list_0[tbl_cnt].table_name), "TABLE", 1
   IF (errcode != 0)
    SET readme_data->message = build(errmsg,"- Readme Failed.")
    GO TO exit_script
   ENDIF
  ENDFOR
  SET readme_data->status = "S"
  SET readme_data->message = "All tables dropped successfully"
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 FREE RECORD requestin
END GO
