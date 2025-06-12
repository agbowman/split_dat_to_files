CREATE PROGRAM aps_get_prefix_specs:dba
 RECORD reply(
   1 qual[10]
     2 source_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationstatus = c1
       3 operationname = c15
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
#script
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  sr.source_cd
  FROM specimen_grouping_r sr
  PLAN (sr
   WHERE (request->specimen_grouping_cd=sr.category_cd))
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].source_cd = sr.source_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SPECIMEN_GROUPING_R"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->qual,count1)
END GO
