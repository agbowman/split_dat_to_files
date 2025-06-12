CREATE PROGRAM bed_get_xr_destination_xrefs:dba
 RECORD reply(
   1 entity[*]
     2 parent_entity_id = f8
     2 destxref_id = f8
     2 destination_cd = f8
     2 destination_type_cd = f8
     2 secure_email = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (size(request->entity,5)=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 DECLARE count = i4 WITH noconstant(0)
 DECLARE index_num = i4 WITH noconstant(1)
 SET reply->status_data.status = "F"
 SELECT
  cdx.cr_destination_xref_id, cdx.destination_type_cd, cdx.parent_entity_id,
  cdx.device_cd, cdx.destination_type_cd, cdx.dms_service_identifier
  FROM cr_destination_xref cdx
  WHERE (cdx.parent_entity_name=request->entity_type)
   AND expand(index_num,1,size(request->entity,5),cdx.parent_entity_id,request->entity[index_num].
   entity_id)
  HEAD REPORT
   count = 0, stat = alterlist(reply->entity,size(request->entity,5))
  DETAIL
   count = (count+ 1)
   IF (count >= size(reply->entity,5))
    stat = alterlist(reply->entity,(count+ 10))
   ENDIF
   reply->entity[count].parent_entity_id = cdx.parent_entity_id, reply->entity[count].destxref_id =
   cdx.cr_destination_xref_id, reply->entity[count].destination_cd = cdx.device_cd,
   reply->entity[count].destination_type_cd = cdx.destination_type_cd, reply->entity[count].
   secure_email = cdx.dms_service_identifier
  FOOT REPORT
   stat = alterlist(reply->entity,count), reply->status_data.status = "S"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
