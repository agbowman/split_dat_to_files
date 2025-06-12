CREATE PROGRAM dm_get_local_contribs:dba
 RECORD reply(
   1 event_cd = c40
   1 qual[*]
     2 contrib_display = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  b.display
  FROM code_value_alias a,
   code_value b
  WHERE (a.code_value=request->event_cd)
   AND b.code_value=a.contributor_source_cd
  ORDER BY b.display
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].contrib_display = b.display
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
