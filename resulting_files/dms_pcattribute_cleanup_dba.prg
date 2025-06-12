CREATE PROGRAM dms_pcattribute_cleanup:dba
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
 SET readme_data->message = "Failed starting script dms_pcattribute_cleanup."
 DECLARE dpc_errmsg = vc WITH protect
 DECLARE dpc_errint = i4 WITH protect, noconstant(0)
 UPDATE  FROM pc_attribute pca
  SET pca.attribute_loc_name = "Default Queue"
  WHERE pca.attribute_name="DefaultPrinter"
  WITH nocounter
 ;end update
 SET dpc_errint = error(dpc_errmsg,1)
 IF (dpc_errint != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed updating the PC_ATTRIBUTE table: ",dpc_errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
#exit_script
 IF ((readme_data->status="S"))
  COMMIT
  SET readme_data->message = "PC_ATTRIBUTE data updated successfully."
 ELSE
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
