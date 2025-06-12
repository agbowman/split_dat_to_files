CREATE PROGRAM cmn_def_del_preview_details:dba
 PROMPT
  "output device: " = "MINE"
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
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DELETE  FROM mp_mpage_def mmd
  WHERE mmd.def_type_flag=2
   AND (mmd.updt_id=reqinfo->updt_id)
  WITH nocounter
 ;end delete
 CALL errorcheck(reply,"delete mp_mpage_def")
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 SET _memory_reply_string = cnvtrectojson(reply)
END GO
