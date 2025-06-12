CREATE PROGRAM ams_tool_audit_rpt
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Audit Report for: " = 0,
  "Enter Entity Name" = ""
  WITH outdev, areport, ename
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 IF (( $AREPORT=1))
  EXECUTE sch_resource_audit_report:group01  $OUTDEV,  $ENAME
 ELSEIF (( $AREPORT=2))
  EXECUTE sch_res_group_audit_report:group01  $OUTDEV,  $ENAME
 ELSEIF (( $AREPORT=3))
  EXECUTE sch_res_role_audit_report:group01  $OUTDEV,  $ENAME
 ELSEIF (( $AREPORT=4))
  EXECUTE sch_res_apptype_audit_report:group01  $OUTDEV,  $ENAME
 ELSEIF (( $AREPORT=5))
  EXECUTE sch_res_appbook_audit_report:group01  $OUTDEV,  $ENAME
 ENDIF
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
