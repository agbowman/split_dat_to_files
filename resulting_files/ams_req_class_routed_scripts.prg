CREATE PROGRAM ams_req_class_routed_scripts
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE ams_define_toolkit_common
 DECLARE script_name = vc WITH protect, constant("AMS_REQ_CLASS_ROUTED_SCRIPTS")
 DECLARE progname = c41
 DECLARE servname = c41
 IF (isamsuser(reqinfo->updt_id)=false)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "ERROR: You are not recognized as an AMS Associate. Operation Denied."
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO  $OUTDEV
  default_class = uar_get_tdb(r.request_number,progname,servname), request_service = servname,
  request_class = r.requestclass,
  request_number = r.request_number, request_name = r.description
  FROM request r
  PLAN (r
   WHERE r.requestclass > 0)
  ORDER BY request_service, r.requestclass, r.request_number
  WITH nocounter, separator = " ", format
 ;end select
 CALL updtdminfo(script_name)
#exit_script
 SET script_ver = "001  09/26/2013  SB8469 Initial Release"
END GO
