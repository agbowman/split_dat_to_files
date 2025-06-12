CREATE PROGRAM ams_auto_swap_resource:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "From Scheduling Resource" = 0,
  "To Scheduling Resource" = 0,
  "Select the date for Swapping Appointments" = "CURDATE"
  WITH outdev, from_resource, to_resource,
  bdate
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
 FREE SET request
 RECORD request(
   1 call_echo_ind = i2
   1 from_resource_cd = f8
   1 to_resource_cd = f8
   1 sch_reason_cd = f8
   1 reason_meaning = vc
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 conversation_id = f8
   1 debug_script_ind = i2
 )
 DECLARE start_date = vc WITH noconstant
 DECLARE end_date = vc WITH noconstant
 SET start_date = build2( $BDATE," 00:00:00")
 SET end_date = build2( $BDATE," 23:59:59")
 SET request->call_echo_ind = 0
 SET request->from_resource_cd =  $FROM_RESOURCE
 SET request->to_resource_cd =  $TO_RESOURCE
 SET request->sch_reason_cd = 0.000000
 SET request->reason_meaning = ""
 SET request->beg_dt_tm = cnvtdatetime(start_date)
 SET request->end_dt_tm = cnvtdatetime(end_date)
 SET request->conversation_id = 0.000000
 SET request->debug_script_ind = 0
 EXECUTE sch_write_swap_res
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   col 5,
   "All the appointments for the Selected Date have been Swapped between the Selected Resources"
  WITH nocounter
 ;end select
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
