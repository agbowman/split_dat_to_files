CREATE PROGRAM ctp_delete_routing:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Object Name" = "CTP_EXTRACT_WRAPPER"
  WITH outdev, object_name
 DECLARE object = vc WITH protect, constant(cnvtupper(trim( $OBJECT_NAME,3)))
 DECLARE message = vc WITH protect, noconstant("Unknown error")
 IF (checkdic("CCL_CUST_SCRIPT_OBJECTS","T",0) <= 1)
  SET message = "Custom routing not available"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM ccl_cust_script_objects ccso
  PLAN (ccso
   WHERE ccso.object_name=object)
  WITH forupdate(ccso)
 ;end select
 IF (curqual=0)
  SET message = "Not re-routed"
  GO TO exit_script
 ENDIF
 DELETE  FROM ccl_cust_script_objects ccso
  WHERE ccso.object_name=object
  WITH nocounter
 ;end delete
 IF (curqual > 0)
  SET message = "Routing removed successfully"
  COMMIT
 ELSE
  SET message = "Failed to remove routing"
  ROLLBACK
 ENDIF
#exit_script
 SELECT INTO  $OUTDEV
  FROM dummyt d
  DETAIL
   message
  WITH nocounter
 ;end select
#abort
 SET last_mod = "000 03/06/18 CJ012163 Initial Release"
END GO
