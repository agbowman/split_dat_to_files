CREATE PROGRAM dm_get_ref_domain_groups:dba
 RECORD reply(
   1 qual[*]
     2 group_name = vc
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt = 0
 SELECT INTO "NL:"
  dm.group_name, dm.description
  FROM dm_ref_domain_group dm
  ORDER BY dm.group_name
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].group_name = dm.group_name,
   reply->qual[cnt].description = dm.description
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
