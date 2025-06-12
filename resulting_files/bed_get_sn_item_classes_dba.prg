CREATE PROGRAM bed_get_sn_item_classes:dba
 FREE SET reply
 RECORD reply(
   1 clist[*]
     2 item_class_id = f8
     2 item_class_description = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET class_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=11026
   AND cv.cdf_meaning="ITEM_CLASS"
   AND cv.active_ind=1
  DETAIL
   class_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET class_instance_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=11027
   AND cv.cdf_meaning="ITEM_CLASS"
   AND cv.active_ind=1
  DETAIL
   class_instance_cd = cv.code_value
  WITH nocounter
 ;end select
 SET ccnt = 0
 SET alterlist_ccnt = 0
 SET stat = alterlist(reply->clist,20)
 SELECT INTO "NL"
  FROM class_node cn
  WHERE cn.class_type_cd=class_type_cd
   AND cn.class_instance_cd=class_instance_cd
  ORDER BY cn.description
  DETAIL
   ccnt = (ccnt+ 1), alterlist_ccnt = (alterlist_ccnt+ 1)
   IF (alterlist_ccnt > 20)
    stat = alterlist(reply->clist,(ccnt+ 20)), alterlist_ccnt = 1
   ENDIF
   reply->clist[ccnt].item_class_id = cn.class_node_id, reply->clist[ccnt].item_class_description =
   cn.description
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->clist,ccnt)
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
