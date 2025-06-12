CREATE PROGRAM cdi_chg_use_popup_imageviewer
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
 DECLARE fail_ind = i2 WITH public, noconstant(0)
 DECLARE lock_fail_ind = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM name_value_prefs nvp
  WHERE nvp.pvc_name="USE_POPUP_IMAGEVIEWER"
   AND nvp.pvc_value != "0"
  WITH nocounter, forupdate(nvp)
 ;end select
 IF (curqual=0)
  SET lock_fail_ind = 1
  GO TO set_readme_status
 ENDIF
 UPDATE  FROM name_value_prefs nvp
  SET nvp.pvc_value = "0", nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_dt_tm = cnvtdatetime(curdate,
    curtime3)
  WHERE nvp.pvc_name="USE_POPUP_IMAGEVIEWER"
   AND nvp.pvc_value != "0"
 ;end update
#set_readme_status
 SELECT INTO "nl:"
  FROM name_value_prefs nvp
  WHERE nvp.pvc_name="USE_POPUP_IMAGEVIEWER"
  DETAIL
   IF (nvp.pvc_value != "0")
    fail_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (fail_ind=1)
  ROLLBACK
  IF (lock_fail_ind=1)
   CALL echo("Readme failed.  Update rows could not be locked.")
   SET readme_data->message = "Readme failed.  Update rows could not be locked."
  ELSE
   CALL echo("Readme failed.")
   SET readme_data->message = "Readme failed.  Updating image viewer preference failed."
  ENDIF
  SET readme_data->status = "F"
 ELSE
  COMMIT
  CALL echo("Readme successful.")
  SET readme_data->message = "Readme successful."
  SET readme_data->status = "S"
 ENDIF
 EXECUTE dm_readme_status
END GO
