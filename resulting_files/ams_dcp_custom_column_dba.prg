CREATE PROGRAM ams_dcp_custom_column:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose an option" = "AUDIT",
  "Select the Spread Type" = 0.000000,
  "SYSTEM" = 1,
  "Select the Position" = 0.000000,
  "Select any existing columns to be retained as well as new ones to be added" = 0
  WITH outdev, poption, pspreadtype,
  psystem, pposition, pcolumns
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 SET exe_error = 10
 SET script_failed = false
 EXECUTE ams_define_toolkit_common:dba
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 IF (( $POPTION="AUDIT"))
  FREE SET tempauditrequest
  RECORD tempauditrequest(
    1 spread_type_cd = f8
    1 position_cd = f8
    1 prsnl_id = f8
    1 from_tool_ind = i2
  )
  FREE SET tempauditreply
  RECORD tempauditreply(
    1 qual[*]
      2 spread_type_cd = f8
      2 custom_column_cd = f8
      2 custom_column_meaning = c12
      2 caption = vc
      2 sequence = i2
      2 position_cd = f8
      2 prsnl_id = f8
      2 spread_column_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
  SET tempauditrequest->spread_type_cd =  $PSPREADTYPE
  IF (( $PSYSTEM=1))
   SET tempauditrequest->position_cd = 0.00
  ELSE
   SET tempauditrequest->position_cd =  $PPOSITION
  ENDIF
  SET tempauditrequest->from_tool_ind = 1
  EXECUTE dcp_get_custom_columns:dba  WITH replace("REQUEST",tempauditrequest), replace("REPLY",
   tempauditreply)
  CALL echorecord(tempauditreply)
  SELECT INTO  $OUTDEV
   spread_type = uar_get_code_display(tempauditreply->qual[d1.seq].spread_type_cd), position =
   uar_get_code_display(tempauditreply->qual[d1.seq].position_cd), custom_column =
   uar_get_code_display(tempauditreply->qual[d1.seq].custom_column_cd),
   custom_column_meaning = uar_get_code_display(tempauditreply->qual[d1.seq].custom_column_meaning)
   FROM (dummyt d1  WITH seq = value(size(tempauditreply->qual,5)))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  FREE SET tempdelrequest
  RECORD tempdelrequest(
    1 prsnl_id = f8
    1 spread_type_cd = f8
    1 position_cd = f8
  )
  IF (( $PSYSTEM=1))
   SET tempdelrequest->position_cd = 0.00
  ELSE
   SET tempdelrequest->position_cd =  $PPOSITION
  ENDIF
  SET tempdelrequest->spread_type_cd =  $PSPREADTYPE
  CALL echoxml(tempdelrequest,"CCLUSERDIR:myTestRec2.dat")
  EXECUTE dcp_del_custom_columns:dba  WITH replace("REQUEST",tempdelrequest), replace("REPLY",
   tempdelreply)
  DECLARE colcnt = i4 WITH noconstant, protect
  DECLARE colidx = i4 WITH noconstant, protect
  FREE SET tempupdrequest
  RECORD tempupdrequest(
    1 qual[*]
      2 spread_type_cd = f8
      2 custom_column_cd = f8
      2 custom_column_meaning = vc
      2 position_cd = f8
      2 prsnl_id = f8
      2 caption = vc
      2 sequence_ind = i2
  )
  FREE SET colrec
  RECORD colrec(
    1 collist[*]
      2 columncd = f8
  )
  SET lcheck = substring(1,1,reflect(parameter(6,0)))
  IF (lcheck="L")
   WHILE (lcheck > " ")
     SET colcnt = (colcnt+ 1)
     SET lcheck = substring(1,1,reflect(parameter(6,colcnt)))
     IF (lcheck > " ")
      IF (mod(colcnt,5)=1)
       SET stat = alterlist(colrec->collist,(colcnt+ 4))
      ENDIF
      SET colrec->collist[colcnt].columncd = parameter(6,colcnt)
     ENDIF
   ENDWHILE
   SET colcnt = (colcnt - 1)
   SET stat = alterlist(colrec->collist,colcnt)
  ELSE
   SET colcnt = (colcnt+ 1)
   SET stat = alterlist(colrec->collist,1)
   SET colrec->collist[1].columncd =  $PCOLUMNS
  ENDIF
  CALL echo(build2("colCnt",colcnt))
  CALL echoxml(colrec,"CCLUSERDIR:myTestRec1.dat")
  SET stat = alterlist(tempupdrequest->qual,colcnt)
  FOR (colidx = 1 TO colcnt)
    CALL echo(build("inside update's for loop for colIdx= ",colidx))
    CALL echo(build("column_cd",colrec->collist[colidx].columncd))
    SET tempupdrequest->qual[colidx].spread_type_cd =  $PSPREADTYPE
    SET tempupdrequest->qual[colidx].custom_column_cd = colrec->collist[colidx].columncd
    SET tempupdrequest->qual[colidx].custom_column_meaning = uar_get_code_meaning(colrec->collist[
     colidx].columncd)
    SET tempupdrequest->qual[colidx].caption = uar_get_code_display(colrec->collist[colidx].columncd)
    IF (( $PSYSTEM=1))
     SET tempupdrequest->qual[colidx].position_cd = 0.00
    ELSE
     SET tempupdrequest->qual[colidx].position_cd =  $PPOSITION
    ENDIF
    SET tempupdrequest->qual[colidx].sequence_ind = colidx
  ENDFOR
  CALL echorecord(tempupdrequest)
  CALL echoxml(tempupdrequest,"CCLUSERDIR:myTestRec.dat")
  EXECUTE dcp_add_custom_columns:dba  WITH replace("REQUEST",tempupdrequest), replace("REPLY",
   tempupdreply)
  CALL echorecord(tempupdreply)
 ENDIF
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   col 0, "Script executed Successfully."
  WITH nocounter
 ;end select
#exit_script
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (script_failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 SET last_mod = "001 12/22/15 ZA030646  Initial Release"
END GO
