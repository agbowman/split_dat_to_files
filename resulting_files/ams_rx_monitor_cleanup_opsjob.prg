CREATE PROGRAM ams_rx_monitor_cleanup_opsjob
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET exe_error = 10
 SET failed = false
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 EXECUTE cclseclogin
 SELECT DISTINCT INTO value("CCLUSERDIR:rxordercleanup.csv")
  order_id
  FROM rx_pending_refill rpr
  WHERE rx_pending_refill_id > 0.00
   AND disp_priority_dt_tm <= cnvtlookbehind("100,M")
   AND rpr.order_id != 0.0
  WITH noheading, format, separator = " "
 ;end select
 EXECUTE ams_rx_monitor_cleanup "MINE", "1"
 CALL updtdminfo(trim(cnvtupper(curprog),3))
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
END GO
