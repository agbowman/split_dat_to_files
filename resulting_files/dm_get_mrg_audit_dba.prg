CREATE PROGRAM dm_get_mrg_audit:dba
 RECORD reply(
   1 qual[*]
     2 audit_line = vc
     2 sequence = i4
     2 audit_type = vc
     2 row_cnt = i4
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
 SELECT INTO "nl:"
  a.text
  FROM dm_merge_audit a
  WHERE (a.merge_id=request->merge_id)
  ORDER BY a.sequence
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].audit_line = trim(a.text),
   reply->qual[cnt].sequence = a.sequence, reply->qual[cnt].audit_type = a.action, reply->qual[cnt].
   row_cnt = cnt
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
