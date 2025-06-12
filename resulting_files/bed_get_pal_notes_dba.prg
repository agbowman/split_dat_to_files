CREATE PROGRAM bed_get_pal_notes:dba
 FREE SET reply
 RECORD reply(
   1 notes[*]
     2 name = vc
     2 code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM br_pal_columns b
  PLAN (b
   WHERE b.section="Notifications")
  ORDER BY b.column_name
  HEAD b.column_name
   cnt = (cnt+ 1), stat = alterlist(reply->notes,cnt), reply->notes[cnt].name = b.column_name
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   IF (cnvtupper(reply->notes[x].name)="STICKY NOTES")
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=14122
       AND c.cdf_meaning="POWERCHART")
     DETAIL
      reply->notes[x].code_value = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF (cnvtupper(reply->notes[x].name)="ROUNDS NOTES")
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=14122
       AND c.cdf_meaning="ROUNDNOTE")
     DETAIL
      reply->notes[x].code_value = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF (cnvtupper(reply->notes[x].name)="ASSIGNMENT NOTES")
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=14122
       AND c.cdf_meaning="ASGMTNOTE")
     DETAIL
      reply->notes[x].code_value = c.code_value
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
