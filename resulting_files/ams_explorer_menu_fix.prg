CREATE PROGRAM ams_explorer_menu_fix
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Update Lookback" = "CURDATE",
  "Select rows to reactivate" = 0
  WITH outdev, prompt1, prompt2
 EXECUTE ams_define_toolkit_common
 DECLARE script_name = vc WITH protect, constant("AMS_EXPLORER_MENU_FIX")
 DECLARE run_ind = i2 WITH protect, noconstant(false)
 IF (isamsuser(reqinfo->updt_id)=false)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "ERROR: You are not recognized as an AMS Associate. Operation Denied."
   WITH nocounter
  ;end select
 ENDIF
 UPDATE  FROM explorer_menu e
  SET e.active_ind = 1, e.updt_cnt = (e.updt_cnt+ 1), e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   e.updt_id = reqinfo->updt_id
  WHERE e.menu_id IN ( $PROMPT2)
 ;end update
 SET total_cnt = curqual
 SELECT INTO  $1
  FROM dummyt d
  HEAD REPORT
   row 3, col 20, "REACTIVATED SELECTED REPORTS:"
 ;end select
#exit_script
 SET script_ver = "002  04/28/2015  SB8469"
 CALL updtdminfo(script_name,cnvtreal(total_cnt))
END GO
