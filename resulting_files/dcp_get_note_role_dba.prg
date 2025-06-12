CREATE PROGRAM dcp_get_note_role:dba
 RECORD reply(
   1 qual[5]
     2 role_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET cnt = 0
 SELECT INTO "nl:"
  ntl.role_type_cd
  FROM note_type_list ntl
  WHERE (ntl.note_type_id=request->note_type_id)
   AND ntl.role_type_cd > 0
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,5)=1
    AND cnt > 1)
    stat = alter(reply->qual,(cnt+ 4))
   ENDIF
   reply->qual[cnt].role_type_cd = ntl.role_type_cd
  WITH nocounter
 ;end select
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->qual,cnt)
END GO
