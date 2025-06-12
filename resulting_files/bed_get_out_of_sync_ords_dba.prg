CREATE PROGRAM bed_get_out_of_sync_ords:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ocnt = 0
 SET alterlist_ocnt = 0
 SET stat = alterlist(reply->orderables,100)
 SELECT DISTINCT INTO "NL:"
  FROM order_catalog oc,
   code_value cv1,
   code_value cv2
  PLAN (oc
   WHERE oc.catalog_cd > 0
    AND oc.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=oc.catalog_type_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=oc.activity_type_cd
    AND cv2.active_ind=1)
  ORDER BY oc.description
  DETAIL
   IF (cnvtupper(cv2.definition) != cv1.cdf_meaning)
    ocnt = (ocnt+ 1), alterlist_ocnt = (alterlist_ocnt+ 1)
    IF (alterlist_ocnt > 100)
     stat = alterlist(reply->orderables,(ocnt+ 100)), alterlist_ocnt = 1
    ENDIF
    reply->orderables[ocnt].code_value = oc.catalog_cd, reply->orderables[ocnt].description = oc
    .description
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->orderables,ocnt)
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
