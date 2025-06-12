CREATE PROGRAM bed_get_srvarea_calendar:dba
 FREE SET reply
 RECORD reply(
   1 srvareas[*]
     2 code_value = f8
     2 calendar_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FOR (x = 1 TO size(request->srvareas,5))
   SET stat = alterlist(reply->srvareas,x)
   SET reply->srvareas[x].code_value = request->srvareas[x].code_value
   SELECT INTO "nl:"
    FROM loc_resource_calendar l
    PLAN (l
     WHERE (l.location_cd=request->srvareas[x].code_value))
    DETAIL
     reply->srvareas[x].calendar_ind = 1
    WITH nocounter
   ;end select
 ENDFOR
#exit_script
 IF (size(reply->srvareas,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
