CREATE PROGRAM dac_load_a_nls_cbo_wrpr:dba
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
 SET readme_data->message = "Readme Failed: Starting script dac_load_a_nls_cbo_wrpr.prg..."
 DECLARE exists_ind = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  l.attr_name
  FROM dtableattr a
  WHERE a.table_name="DM_CB_OBJECTS"
  DETAIL
   exists_ind = 1
  WITH nocounter
 ;end select
 IF (exists_ind=0)
  SET readme_data->status = "S"
  SET readme_data->message = "DM_CB_OBJECTS definition does not exist."
  GO TO exit_script
 ELSEIF (exists_ind=1)
  SELECT INTO "nl:"
   FROM user_tab_columns u
   WHERE u.table_name="DM_CB_OBJECTS"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET readme_data->status = "S"
   SET readme_data->message = "DM_CB_OBJECTS table does not exist."
   GO TO exit_script
  ENDIF
 ENDIF
 EXECUTE dm_dbimport "cer_install:dac_load_a_nls_cb_objects.csv", "dac_load_a_nls_cb_objects", 500
 IF ((readme_data->status != "F"))
  SET readme_data->status = "S"
  SET readme_data->message = "Success: DM_CB_OBJECTS data loaded."
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
