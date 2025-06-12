CREATE PROGRAM dm_ocd_readme_component_add:dba
 PROMPT
  "Script to add to target dictionary prior to the mass move process:" =
  "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
 IF (( $1="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"))
  CALL echo("***************************************")
  CALL echo("No script name entered. Going to exit script")
  CALL echo("***************************************")
  GO TO exit_script
 ENDIF
 SET end_state = cnvtupper( $1)
 INSERT  FROM ocd_readme_component orc
  SET orc.product_area_name = "DATA MANAGEMENT, MANUAL MINIDICTIONARY ADD", orc.end_state = end_state,
   orc.manual_ind = 1,
   orc.updt_dt_tm = cnvtdatetime(curdate,curtime3), orc.product_area_number = 426, orc.component_type
    = "SCRIPT"
 ;end insert
 COMMIT
#exit_script
END GO
