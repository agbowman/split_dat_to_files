CREATE PROGRAM cmn_run_create_clob_gttd:dba
 PROMPT
  "outdev: " = mine
  WITH outdev
 DECLARE PUBLIC::errorcheck(replystructure=vc(ref),operation=vc) = null
 SUBROUTINE PUBLIC::errorcheck(replystructure,operation)
   DECLARE errormsg = c255 WITH protect, noconstant("")
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   SET errorcode = error(errormsg,0)
   IF (errorcode != 0)
    WHILE (errorcode != 0)
      SET replystructure->status_data.subeventstatus[1].operationname = operation
      SET replystructure->status_data.subeventstatus[1].targetobjectname = cnvtstring(errorcode,10)
      SET replystructure->status_data.subeventstatus[1].targetobjectvalue = errormsg
      SET replystructure->status_data.status = "F"
      IF ((reqdata->loglevel >= 4))
       CALL echo(errormsg)
      ENDIF
      SET errorcode = error(errormsg,0)
    ENDWHILE
    GO TO exit_script
   ENDIF
 END ;Subroutine
 RECORD response(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SET response->status_data.status = "S"
 IF (validate(_memory_reply_string)=false)
  DECLARE _memory_reply_string = vc WITH protect, noconstant("")
 ENDIF
 EXECUTE cmn_create_cnfg_clob_gttd
 CALL errorcheck(response,"create_cnfg_clob_gttd")
 SET _memory_reply_string = cnvtrectojson(response)
#exit_script
END GO
