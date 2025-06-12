CREATE PROGRAM ams_pm_encntr_disch_driver:dba
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
 RECORD discharges(
   1 cnt = i4
   1 qual[*]
     2 encntr_id = f8
 )
 DECLARE requestin_cnt = i4 WITH protect, constant(size(requestin->list_0,5))
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 IF (requestin_cnt=0)
  CALL echo("***** no encounters in file *****")
  GO TO exit_script
 ENDIF
 IF (validate(requestin->list_0[1].encntr_id)=0)
  CALL echo("***** encntr_id header not found in file *****")
  GO TO exit_script
 ENDIF
 SET stat = alterlist(discharges->qual,requestin_cnt)
 SET discharges->cnt = requestin_cnt
 FOR (loop_cnt = 1 TO requestin_cnt)
   SET discharges->qual[loop_cnt].encntr_id = cnvtreal(requestin->list_0[loop_cnt].encntr_id)
 ENDFOR
 CALL updtdminfo(trim(cnvtupper(curprog),3))
 EXECUTE ams_pm_upt_auto_discharge
#exit_script
END GO
