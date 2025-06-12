CREATE PROGRAM bed_get_pharm_thera_class:dba
 FREE SET reply
 RECORD reply(
   1 thera_classes[*]
     2 class_id = f8
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_count = 0
 SELECT INTO "nl:"
  FROM alt_sel_cat a
  WHERE a.ahfs_ind=1
  HEAD REPORT
   cnt = 0, list_count = 0, stat = alterlist(reply->thera_classes,100)
  DETAIL
   list_count = (list_count+ 1), cnt = (cnt+ 1)
   IF (list_count > 100)
    stat = alterlist(reply->thera_classes,(cnt+ 100)), list_count = 1
   ENDIF
   reply->thera_classes[cnt].class_id = a.alt_sel_category_id, reply->thera_classes[cnt].description
    = a.long_description
  FOOT REPORT
   stat = alterlist(reply->thera_classes,cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
