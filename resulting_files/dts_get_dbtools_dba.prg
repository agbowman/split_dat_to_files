CREATE PROGRAM dts_get_dbtools:dba
 RECORD reply(
   1 qual[*]
     2 description = vc
     2 object_name = vc
   1 qual_cnt = i4
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
 SET failed = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  a.object_name, a.description
  FROM application a
  WHERE ((a.application_number BETWEEN 4140000 AND 4149999
   AND cnvtupper(a.description)="DTS: DB*") OR (((a.application_number IN (600027, 500006, 500000,
  500012)) OR (((a.application_number IN (200002, 200038, 500011, 16000)) OR (a.application_number
   IN (100002, 100017))) )) ))
   AND a.application_number != 4140100
   AND a.active_ind=1
  HEAD REPORT
   x = 1
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].description = a.description,
   reply->qual[cnt].object_name = a.object_name
  FOOT REPORT
   reply->qual_cnt = cnt
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
