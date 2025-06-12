CREATE PROGRAM dm_rdm_copy_desc_to_def_4039:dba
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
 SET readme_data->message = "Readme failed: starting script dm_rdm_copy_desc_to_def_4039"
 DECLARE errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM code_value cv
  SET cv.definition = cv.description, cv.updt_dt_tm = cnvtdatetime(sysdate), cv.updt_id = 1
  WHERE cv.code_set=4039
   AND cv.description != ""
   AND cv.description != cv.definition
   AND cv.cdf_meaning IN ("ACTMED", "ACTUSER", "CARTCHECK", "DISITEMDTTM", "DISITEMLOC",
  "DISLOC", "DISUIL", "DISUL", "ITEMLOC", "LOCITEM",
  "MAR", "PASSMED", "PCL", "PHAIVLBL", "PHAIVRPT",
  "PHAMEDLBL", "PHAMEDREQ", "PHAMEDRPT", "PHAPMP", "PHASOR",
  "PHAWORKLIST", "RETLABEL", "RXALABEL", "RXAPIL", "RXAREFNOTE",
  "RXPATIENTLBL", "RXWORKFLOW", "RXWSLBL", "RXWSRPT", "UDR",
  "PREVIEW")
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Update on code_value table failed",errmsg)
 ENDIF
 IF (curqual=0)
  SET readme_data->status = "S"
  CALL echo("No record found to update.")
  SET readme_data->message = "No records found to update for the code_set 4039"
 ELSE
  CALL echo("Code_value table updated.")
  SET readme_data->status = "S"
  SET readme_data->message = "Update on code_value table successful"
  COMMIT
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 CALL echo("Last Mod = 001")
 CALL echo("Mod Date = 12/22/21")
END GO
