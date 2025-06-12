CREATE PROGRAM dm2_rdm_resume_off
 IF (currdb="ORACLE")
  DECLARE doresoff_error = i2 WITH protect, noconstant(0)
  DECLARE doresoff_error_msg = vc WITH protect, noconstant("")
  DECLARE doresoff_base_version = i2 WITH protect, noconstant(0)
  DECLARE doresoff_cmd_str = vc WITH protect, noconstant("")
  SET doresoff_error = error(doresoff_error_msg,1)
  SET doresoff_error = 0
  SELECT INTO "nl:"
   FROM product_component_version p
   WHERE cnvtupper(p.product)="ORACLE*"
   DETAIL
    doresoff_base_version = cnvtint(substring(1,(findstring(".",p.version) - 1),p.version))
   WITH nocounter
  ;end select
  SET doresoff_error = error(doresoff_error_msg,1)
  IF (doresoff_error > 0)
   CALL echo("Error occurred while obtaining ORACLE version. Error is Acceptable")
  ELSE
   IF (doresoff_base_version=9)
    SET doresoff_cmd_str = "rdb alter session disable resumable go"
    CALL parser(doresoff_cmd_str,1)
    SET doresoff_error = error(doresoff_error_msg,1)
    IF (doresoff_error > 0)
     CALL echo("Error occurred while setting session to resumable. Error is Acceptable")
     CALL echo(doresoff_error_msg)
    ENDIF
   ENDIF
  ENDIF
  SET doresoff_error = error(doresoff_error_msg,1)
  SET doresoff_error = 0
 ENDIF
END GO
