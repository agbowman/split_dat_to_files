CREATE PROGRAM dcp_get_name_value:dba
 RECORD reply(
   1 nv_cnt = i4
   1 nv[*]
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 pvc_name = c32
     2 pvc_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = size(request->nv,5)
 SET count = 0
 SELECT INTO "nl:"
  name.pvc_value
  FROM (dummyt d1  WITH seq = value(cnt)),
   name_value_prefs name
  PLAN (d1)
   JOIN (name
   WHERE (name.parent_entity_name=request->nv[d1.seq].parent_entity_name)
    AND (name.parent_entity_id=request->nv[d1.seq].parent_entity_id)
    AND (name.pvc_name=request->nv[d1.seq].pvc_name))
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->nv,5))
    stat = alterlist(reply->nv,(count+ 10))
   ENDIF
   reply->nv[count].parent_entity_name = name.parent_entity_name, reply->nv[count].parent_entity_id
    = name.parent_entity_id, reply->nv[count].pvc_name = name.pvc_name,
   reply->nv[count].pvc_value = name.pvc_value
  FOOT REPORT
   reply->nv_cnt = count, stat = alterlist(reply->nv,count)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
