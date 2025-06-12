CREATE PROGRAM bed_get_scr_paragraph_types:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 paragraph_types[*]
      2 cki_source = vc
      2 cki_identifier = vc
      2 display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE paragraph_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM scr_paragraph_type pt
  PLAN (pt
   WHERE pt.scr_paragraph_type_id > 0)
  DETAIL
   paragraph_cnt = (paragraph_cnt+ 1), stat = alterlist(reply->paragraph_types,paragraph_cnt), reply
   ->paragraph_types[paragraph_cnt].cki_source = pt.cki_source,
   reply->paragraph_types[paragraph_cnt].cki_identifier = pt.cki_identifier, reply->paragraph_types[
   paragraph_cnt].display = pt.display
  WITH nocounter
 ;end select
 CALL bederrorcheck("select failed")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
