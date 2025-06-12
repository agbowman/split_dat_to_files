CREATE PROGRAM dm_create_monblock_pkg:dba
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
 DECLARE dm_pkg_emsg = vc WITH protect, noconstant("")
 DECLARE v_ora_vers1 = i2 WITH protect, noconstant(0)
 DECLARE v_ora_vers2 = i2 WITH protect, noconstant(0)
 DECLARE v_ora_str = vc WITH protect, noconstant("")
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting dm_create_monblock_pkg script."
 SELECT INTO "NL:"
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  DETAIL
   v_ora_vers1 = cnvtint(substring(1,(findstring(".",p.version) - 1),p.version)), v_ora_str =
   substring((findstring(".",p.version)+ 1),size(p.version),p.version), v_ora_vers2 = cnvtint(
    substring(1,(findstring(".",p.version) - 1),v_ora_str))
  WITH nocounter
 ;end select
 IF (((v_ora_vers1 >= 10
  AND v_ora_vers2 >= 2) OR (v_ora_vers1 >= 11)) )
  RDB read "cer_install:monblock.sql" with full
  END ;Rdb
  IF (error(dm_pkg_emsg,1) != 0)
   SET readme_data->message = concat("FAILED to compile monblock sql file: ",dm_pkg_emsg)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM user_objects u
   WHERE u.object_type IN ("PACKAGE", "PACKAGE BODY")
    AND u.object_name="MONBLOCK"
    AND u.status="VALID"
   WITH nocounter
  ;end select
  IF (error(dm_pkg_emsg,1) != 0)
   SET readme_data->message = concat("FAILED to validate monblock sql file: ",dm_pkg_emsg)
   GO TO exit_script
  ENDIF
  IF (curqual < 2)
   SET readme_data->message = "ERROR: MONBLOCK package and package body were not created"
   GO TO exit_script
  ENDIF
  SET readme_data->message = "Success: MONBLOCK package and package body created in database."
 ELSE
  SET readme_data->message = "Auto success for Oracle versions less than or equal to 10.1"
 ENDIF
 SET readme_data->status = "S"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
