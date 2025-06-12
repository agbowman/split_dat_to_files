CREATE PROGRAM dcp_get_entity_reltn:dba
 RECORD reply(
   1 entities[*]
     2 entity1_id = f8
     2 entity1_display = vc
     2 entity2_id = f8
     2 entity2_display = vc
     2 entity1_name = c32
     2 entity2_name = c32
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT DISTINCT INTO "NL:"
  der.entity1_id
  FROM dcp_entity_reltn der
  WHERE (request->entity_reltn_mean=der.entity_reltn_mean)
   AND active_ind=1
  ORDER BY der.entity2_id
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 >= size(reply->entities,5))
    stat = alterlist(reply->entities,(count1+ 10))
   ENDIF
   reply->entities[count1].entity1_display = der.entity1_display, reply->entities[count1].entity2_id
    = der.entity2_id, reply->entities[count1].entity1_id = der.entity1_id,
   reply->entities[count1].entity1_name = der.entity1_name, reply->entities[count1].entity2_name =
   der.entity2_name
  WITH nocounter
 ;end select
 IF (count1 > 0)
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->entities,count1)
 ELSEIF (count1=0)
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
