CREATE PROGRAM dm2_rdm_resume_on
 DECLARE drro_error = i2 WITH protect, noconstant(0)
 DECLARE drro_error_msg = vc WITH protect, noconstant("")
 DECLARE drro_base_version = i2 WITH protect, noconstant(0)
 DECLARE drro_time = i2 WITH protect, noconstant(28800)
 DECLARE drro_session_name = vc WITH protect, noconstant("")
 DECLARE drro_cmd_str = vc WITH protect, noconstant("")
 IF (currdb != "ORACLE")
  GO TO exit_program
 ENDIF
 SET drro_error = error(drro_error_msg,1)
 SET drro_error = 0
 SELECT INTO "nl:"
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  DETAIL
   drro_base_version = cnvtint(substring(1,(findstring(".",p.version) - 1),p.version))
  WITH nocounter
 ;end select
 SET drro_error = error(drro_error_msg,1)
 IF (drro_error > 0)
  CALL echo("Error occurred while obtaining ORACLE version. Error is acceptable.")
  GO TO exit_program
 ENDIF
 IF (drro_base_version != 9)
  GO TO exit_program
 ENDIF
 IF (validate(readme_data->readme_id,0)=0
  AND validate(readme_data->readme_id,1)=1)
  SET drro_session_name = "Executing_Readme"
 ELSE
  IF ((readme_data->readme_id=0))
   SET drro_session_name = "Executing_Readme"
  ELSE
   SET drro_session_name = concat("Executing_Readme_",trim(cnvtstring(readme_data->readme_id)))
  ENDIF
 ENDIF
 CALL parser("rdb commit go",1)
 SET drro_cmd_str = concat("rdb alter session enable resumable timeout ",trim(cnvtstring(drro_time)),
  " name '",drro_session_name,"' go")
 CALL parser(drro_cmd_str,1)
 SET drro_error = error(drro_error_msg,1)
 IF (drro_error > 0)
  CALL echo("Unable to set session to resumable. Disregard message.")
  GO TO exit_program
 ENDIF
#exit_program
 SET drro_error = error(drro_error_msg,1)
 SET drro_error = 0
END GO
