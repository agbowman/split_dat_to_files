CREATE PROGRAM aps_get_tran_name_by_id:dba
 RECORD reply(
   1 qual[*]
     2 trans_id = f8
     2 trans_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET stat = alterlist(reply->qual,10)
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM prsnl p,
   (dummyt d  WITH seq = value(cnvtint(size(request->qual,5))))
  PLAN (d)
   JOIN (p
   WHERE (request->qual[d.seq].trans_id=p.person_id))
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].trans_id = p.person_id, reply->qual[cnt].trans_name = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (cnt != 0)
  SET stat = alterlist(reply->qual,cnt)
 ELSE
  SET stat = alterlist(reply->qual,1)
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PRSNL"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
