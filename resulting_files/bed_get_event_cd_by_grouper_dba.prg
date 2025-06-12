CREATE PROGRAM bed_get_event_cd_by_grouper:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 event_codes[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
      2 event_set_name = vc
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
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
 DECLARE eventcodeparse = vc WITH protect
 DECLARE searchstring = vc WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE tcnt = i4 WITH protect
 IF (textlen(trim(request->event_set_name))=0)
  CALL bederror("Must Provide Event Set Name.")
 ENDIF
 SET eventcodeparse = "c.event_cd = e.event_cd"
 IF (textlen(trim(request->search_string)) > 0)
  IF (cnvtupper(trim(request->search_type_flag))="C")
   SET searchstring = "*"
  ENDIF
  SET searchstring = concat(searchstring,cnvtupper(trim(request->search_string)),"*")
  SET eventcodeparse = concat(eventcodeparse," and (cnvtupper(trim(c.event_cd_disp)) = '",
   searchstring,"' or cnvtupper(trim(c.event_cd_descr)) = '",searchstring,
   "')")
 ENDIF
 SELECT INTO "nl:"
  FROM v500_event_set_code s,
   v500_event_set_explode e,
   v500_event_code c,
   code_value v
  PLAN (s
   WHERE (s.event_set_name=request->event_set_name))
   JOIN (e
   WHERE e.event_set_cd=s.event_set_cd)
   JOIN (c
   WHERE parser(eventcodeparse))
   JOIN (v
   WHERE v.code_value=c.event_cd
    AND v.active_ind=1)
  ORDER BY v.code_value
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->event_codes,100)
  HEAD v.code_value
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->event_codes,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->event_codes[tcnt].code_value = v.code_value, reply->event_codes[tcnt].description = c
   .event_cd_descr, reply->event_codes[tcnt].display = c.event_cd_disp,
   reply->event_codes[tcnt].event_set_name = c.event_set_name
  FOOT REPORT
   stat = alterlist(reply->event_codes,tcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting codes")
 IF ((request->max_reply > 0)
  AND (tcnt > request->max_reply))
  SET reply->too_many_results_ind = 1
  SET stat = alterlist(reply->event_codes,0)
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
