CREATE PROGRAM bsc_rdm_upd_early_late_reason:dba
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
 SET readme_data->message = "Readme failed: starting script bsc_rdm_upd_early_late_reason..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE medearlylatereason_cs = i4 WITH protect, constant(4000020)
 DECLARE iupdaterequired = i2 WITH protect, noconstant(0)
 DECLARE sdisplay = vc WITH protect, constant("Wean to Standard Admin Times")
 DECLARE sdisplaykey = vc WITH protect, constant("WEANTOSTANDARDADMINTIMES")
 DECLARE sdescription = vc WITH protect, constant("Wean to Standard Admin Times")
 DECLARE swrongdisplaykey = vc WITH protect, constant("WANTOSTANDARDADMINTIMES")
 DECLARE sdefinition = vc WITH protect, noconstant("Wean to Standard Admin Times")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=medearlylatereason_cs
   AND cv.display_key=swrongdisplaykey
  DETAIL
   iupdaterequired = 1
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Readme failed to find the codeset 4000020 from code_value table: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (iupdaterequired=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Update not required:Codeset 4000020 does not exist or has been already corrected in code_value table"
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value c
  SET c.display_key = sdisplaykey, c.display = sdisplay, c.description = sdescription,
   c.definition = sdefinition
  WHERE c.display_key=swrongdisplaykey
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme failed to update row into code_value: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "Success: Readme updated the display, display_key, definition and description for the codeset 4000020."
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SET last_mod = "000 01/08/18"
END GO
