CREATE PROGRAM bsc_rdm_upd_override_scan_cv:dba
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
 SET readme_data->message = "Readme failed: starting script bsc_rdm_upd_override_scan_cv..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE iupdaterequired = i2 WITH protect, noconstant(0)
 DECLARE discared_key = c32 WITH protect, constant("BARCODEDISCAREDDURINGPREPARATION")
 DECLARE discarded_key = c33 WITH protect, constant("BARCODEDISCARDEDDURINGPREPARATION")
 DECLARE discared_str = c35 WITH protect, constant("Barcode Discared During Preparation")
 DECLARE discarded_str = c36 WITH protect, constant("Barcode Discarded During Preparation")
 DECLARE code_set = i4 WITH protect, noconstant(4003287)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=code_set
   AND cv.display_key=discared_key
   AND cv.definition=discared_str
  DETAIL
   iupdaterequired = 1
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Readme failed to find the codeset 4003287 from code_value table: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (iupdaterequired=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Update not required:Codeset 4003287 does not exist or has been already corrected in code_value table"
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value c
  SET c.display = discarded_str, c.display_key = discarded_key, c.description = discarded_str,
   c.definition = discarded_str
  WHERE c.code_set=code_set
   AND c.display_key=discared_key
   AND c.definition=discared_str
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme failed to update row into code_value: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
  CALL echo("Updated new fields on the code_value")
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "Success: Readme updated the display, display_key and definition for the codeset 4003287."
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SET last_mod = "PS045757"
 SET mod_date = "07/26/2016"
END GO
