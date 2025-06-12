CREATE PROGRAM cdi_chg_app_ini:dba
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
 DECLARE failed_ind = i2 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM application ap
  WHERE ap.application_number IN (4271000, 4272001)
  WITH nocounter, forupdate(ap)
 ;end select
 UPDATE  FROM application
  SET application_ini_ind = 1
  WHERE application_number IN (4271000, 4272001)
 ;end update
 UPDATE  FROM application ap
  SET ap.direct_access_ind = 1
  WHERE ap.application_number=4271000
 ;end update
 SELECT INTO "nl:"
  FROM application ap
  WHERE ap.application_number IN (4271000, 4272001)
  DETAIL
   IF (ap.application_ini_ind=0)
    failed_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM application ap
  WHERE ap.application_number=4271000
  DETAIL
   IF (ap.direct_access_ind=0)
    failed_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (failed_ind=1)
  ROLLBACK
  CALL echo("failed")
  SET readme_data->message = "Readme failed.  Updating Application's ini failed."
  SET readme_data->status = "F"
 ELSE
  COMMIT
  CALL echo("committed")
  SET readme_data->message = "Readme successful"
  SET readme_data->status = "S"
 ENDIF
 EXECUTE dm_readme_status
END GO
