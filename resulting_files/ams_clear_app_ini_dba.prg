CREATE PROGRAM ams_clear_app_ini:dba
 PROMPT
  "Output Device" = "MINE",
  "Select the username to delete preferences" = "",
  "Enter person_id to delete application_ini settings" = 0,
  "Select the application_ini row(s) to delete" = 0
  WITH outdev, uname, personid,
  ini
 EXECUTE ams_define_toolkit_common
 DECLARE bfailed = i2 WITH protect, noconstant(true)
 DECLARE sprogramname = vc WITH protect, noconstant(cnvtupper(curprog))
 DECLARE run_ind = i2 WITH protect, noconstant(true)
 DECLARE susername = vc WITH protect, noconstant( $UNAME)
 DECLARE sappnbr = vc WITH protect, noconstant("")
 IF (isamsuser(reqinfo->updt_id)=false)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "ERROR: You are not recognized as an AMS Associate. Operation Denied."
   WITH nocounter
  ;end select
 ENDIF
 IF (( $INI=0))
  SET sappnbr = "All Applications"
 ELSE
  SET sappnbr = cnvtstring( $INI)
 ENDIF
 IF (( $PERSONID > 0))
  IF (( $INI=0))
   DELETE  FROM application_ini a
    WHERE a.person_id=cnvtreal( $PERSONID)
    WITH nocounter
   ;end delete
  ELSE
   DELETE  FROM application_ini a
    WHERE a.person_id=cnvtreal( $PERSONID)
     AND a.application_number=cnvtint( $INI)
    WITH nocounter
   ;end delete
  ENDIF
 ENDIF
 COMMIT
 CALL updtdminfo(sprogramname)
 SELECT INTO value( $OUTDEV)
  FROM dummyt d
  HEAD REPORT
   row 3, col 20, "DELETED APPLICATION_INI FOR:",
   row 4, col 20, "Username:",
   susername, row 5, col 20,
   "Applications:", sappnbr
  WITH nocounter
 ;end select
#exit_script
 SET script_ver = "002 03/20/2015 SF3151   Use New Subroutines"
END GO
