CREATE PROGRAM bed_get_coll_class:dba
 FREE SET reply
 RECORD reply(
   1 collection_classes[*]
     2 code_value = f8
     2 display = c40
     2 description = c60
     2 storage_tracking_ind = i2
     2 service_resources[*]
       3 code_value = f8
       3 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ccnt = 0
 SET alterlist_ccnt = 0
 SET stat = alterlist(reply->collection_classes,20)
 SELECT INTO "NL:"
  FROM code_value cv,
   collection_class cc
  PLAN (cv
   WHERE cv.code_set=231
    AND cv.active_ind=1)
   JOIN (cc
   WHERE cc.coll_class_cd=cv.code_value)
  DETAIL
   ccnt = (ccnt+ 1), alterlist_ccnt = (alterlist_ccnt+ 1)
   IF (alterlist_ccnt > 20)
    stat = alterlist(reply->collection_classes,(ccnt+ 20)), alterlist_ccnt = 1
   ENDIF
   reply->collection_classes[ccnt].code_value = cv.code_value, reply->collection_classes[ccnt].
   display = cv.display, reply->collection_classes[ccnt].description = cv.description
   IF (cc.container_id_print="B")
    reply->collection_classes[ccnt].storage_tracking_ind = 1
   ELSE
    reply->collection_classes[ccnt].storage_tracking_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collection_classes,ccnt)
 IF (ccnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = ccnt),
    br_coll_class_instr_reltn b,
    code_value cv
   PLAN (d)
    JOIN (b
    WHERE (b.collection_class_cd=reply->collection_classes[d.seq].code_value))
    JOIN (cv
    WHERE cv.code_value=b.service_resource_cd
     AND cv.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    srcnt = 0
   DETAIL
    srcnt = (srcnt+ 1), stat = alterlist(reply->collection_classes[d.seq].service_resources,srcnt),
    reply->collection_classes[d.seq].service_resources[srcnt].code_value = b.service_resource_cd,
    reply->collection_classes[d.seq].service_resources[srcnt].display = cv.display
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
