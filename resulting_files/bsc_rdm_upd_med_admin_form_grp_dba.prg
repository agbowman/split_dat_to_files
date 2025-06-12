CREATE PROGRAM bsc_rdm_upd_med_admin_form_grp:dba
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
 SET readme_data->message = "Readme failed: starting script bsc_rdm_upd_med_admin_form_grp..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE medadminform_cs = i4 WITH protect, constant(4003329)
 DECLARE iupdaterequired = i2 WITH protect, noconstant(0)
 DECLARE sdisplay = vc WITH protect, constant("Med Admin Form Group")
 DECLARE sdisplaykey = vc WITH protect, constant("MEDADMINFORMGROUP")
 DECLARE swrongdisplaykey = vc WITH protect, constant("MEDADMINFROMGROUP")
 DECLARE definition1 = vc WITH protect, noconstant(
  "This allows the definition of multiple forms that should be compatible. This")
 DECLARE definition2 = vc WITH protect, noconstant(
  " is similar to codeset 6055, but only applies to med barcode scanning.")
 SELECT INTO "nl:"
  FROM code_value_set cv
  WHERE cv.code_set=medadminform_cs
   AND cv.display_key=swrongdisplaykey
  DETAIL
   iupdaterequired = 1
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Readme failed to find the codeset 4003329 from code_value_set table: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (iupdaterequired=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Update not required:Codeset 4003329 does not exist or has been already corrected in code_value_set table"
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value_set c
  SET c.display_key = sdisplaykey, c.display = sdisplay, c.definition = concat(definition1,
    definition2)
  WHERE c.code_set=medadminform_cs
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme failed to update row into code_value_set: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "Success: Readme updated the display, display_key and definition for the codeset 4003329."
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SET last_mod = "000 10/04/15"
END GO
