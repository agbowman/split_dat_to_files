CREATE PROGRAM aps_get_snomed_info:dba
 RECORD reply(
   1 qual[10]
     2 nomenclature_id = f8
     2 code_description = vc
     2 name_description = vc
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
 SELECT INTO "nl:"
  nc.nomenclature_id
  FROM nomenclature nc,
   (dummyt d  WITH seq = value(cnvtint(size(request->qual,5))))
  PLAN (d)
   JOIN (nc
   WHERE (request->qual[d.seq].nomenclature_id=nc.nomenclature_id))
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alter(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].nomenclature_id = nc.nomenclature_id, reply->qual[cnt].code_description = trim(nc
    .source_identifier), reply->qual[cnt].name_description = trim(nc.source_string)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOMENCLATURE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (cnt != 0)
  SET stat = alter(reply->qual,cnt)
 ELSE
  SET stat = alter(reply->qual,1)
 ENDIF
END GO
