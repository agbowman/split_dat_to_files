CREATE PROGRAM cmn_mie_revert_import:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "CID (Content Identifier)" = ""
  WITH outdev, cid
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
 IF ( NOT (validate(pex_error_and_exit_subroutines_inc)))
  EXECUTE pex_error_and_exit_subroutines
  DECLARE pex_error_and_exit_subroutines_inc = i2 WITH protect
 ENDIF
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE PUBLIC::main(null) = null
 CALL main(null)
 DECLARE content_id = vc WITH protect, noconstant("")
 SUBROUTINE main(null)
   SET reply->status_data.status = "F"
   SET content_id = cnvtupper(trim( $CID))
   DELETE  FROM dm_info
    WHERE ((info_domain=content_id) OR (info_char=concat("INSERT_",content_id)
     AND ((info_name=patstring(concat("BR_DATAMART_*",content_id))) OR (((info_name=patstring(concat(
      "BR_LONG_*",content_id))) OR (((info_name=patstring(concat("MP_VIEWPOINT_*",content_id))) OR (
    info_name=patstring(concat("PROCESS_GUID_",content_id,"_*")))) )) )) ))
    WITH nocounter
   ;end delete
   CALL errorcheck(reply,"delete_temp_import_data")
   DELETE  FROM dm_info
    WHERE info_domain IN ("VP_VALIDATE", "VP_INPROG_VALIDATE", "VP_IMPORT")
     AND info_name=patstring(concat("RECEIPT-#-*",cnvtlower(trim( $CID)),"*"))
    WITH nocounter
   ;end delete
   CALL errorcheck(reply,"delete_temp_receipt_data")
   SET reqinfo->commit_ind = 1
   CALL exit_with_status("S",curprog,"S","Main","",
    reply)
 END ;Subroutine
#exit_script
 IF ((((reqdata->loglevel >= 4)) OR (validate(debug_ind,0) > 0)) )
  CALL echorecord(reply)
 ENDIF
 IF (validate(_memory_reply_string))
  SET _memory_reply_string = cnvtrectojson(reply)
 ENDIF
END GO
