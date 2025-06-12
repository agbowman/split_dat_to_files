CREATE PROGRAM dm2_und_dflt_rows_pathnet2:dba
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
 EXECUTE dm2_undo_default_rows "PL_DEMOGRAPHICS"
 SELECT INTO "nl:"
  FROM user_tab_columns utc,
   pl_demographics pd,
   dummyt d
  PLAN (utc
   WHERE utc.table_name="PL_DEMOGRAPHICS"
    AND utc.column_name="PL_DEMOGRAPHICS_ID")
   JOIN (d)
   JOIN (pd
   WHERE pd.pl_demographics_id=cnvtreal(utc.data_default))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  ROLLBACK
  SET readme_data->message = "Default row with pl_demographics_id = 0 is not removed"
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM user_triggers
  WHERE trigger_name="TRG_*DR_UPDT_DEL"
   AND table_name="PL_DEMOGRAPHICS"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  ROLLBACK
  SET readme_data->message =
  "Trigger that does not allow update or delete of default row is not removed."
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Default row is removed correctly"
 COMMIT
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
