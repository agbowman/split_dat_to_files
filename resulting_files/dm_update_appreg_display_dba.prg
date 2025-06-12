CREATE PROGRAM dm_update_appreg_display:dba
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
 SET readme_type = "DM_UPDATE_APPREG_DISPLAY:"
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE c.code_set=505
   AND c.cki="CKI.CODEVALUE!13737"
   AND c.display_key="PROVIDE"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM code_value c
   SET c.display_key = "POWERCHARTOFFICE", c.display = "PowerChart Office", c.description =
    "PowerChart Office",
    c.definition = "PowerChart Office"
   WHERE c.code_set=505
    AND c.cki="CKI.CODEVALUE!13737"
    AND c.display_key="PROVIDE"
   WITH nocounter
  ;end update
  COMMIT
  CALL echo("***************************************************")
  CALL echo("*** CKI 13737 for code set 505 has been updated ***")
  CALL echo("***************************************************")
 ELSE
  CALL echo("*******************************************************")
  CALL echo("*** No update needed for CKI 13737 for code set 505 ***")
  CALL echo("*******************************************************")
 ENDIF
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE c.code_set=505
   AND c.display_key IN ("CHNA", "MRNET", "ORDERPRO", "INVENTORY")
   AND c.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM code_value c
   SET c.active_ind = 0, c.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE c.code_set=505
    AND c.display_key IN ("CHNA", "MRNET", "ORDERPRO", "INVENTORY")
    AND c.active_ind=1
   WITH nocounter
  ;end update
  COMMIT
  CALL echo("*****************************************************************")
  CALL echo("*** Active_ind = 0 for certain display_key's has been updated***")
  CALL echo("*****************************************************************")
 ELSE
  CALL echo("******************************************")
  CALL echo("*** No update for active_ind's needed  ***")
  CALL echo("******************************************")
 ENDIF
 SET readme_data->message = concat(readme_type," Readme Successful.")
 SET readme_data->status = "S"
 EXECUTE dm_readme_status
END GO
