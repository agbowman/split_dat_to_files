CREATE PROGRAM dcp_get_catalog_task:dba
 RECORD reply(
   1 tasks[*]
     2 task_type_cd = f8
     2 ref_task_id = f8
     2 activity_task_cd = f8
     2 primary_task_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE cat_cnt = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM order_task_xref otx,
   order_task ot
  PLAN (otx
   WHERE (otx.catalog_cd=request->catalog_cd))
   JOIN (ot
   WHERE ot.reference_task_id=otx.reference_task_id)
  ORDER BY otx.order_task_seq
  HEAD REPORT
   cat_cnt = 0
  DETAIL
   IF (otx.catalog_cd > 0)
    cat_cnt = (cat_cnt+ 1)
    IF (cat_cnt > size(reply->tasks,5))
     stat = alterlist(reply->tasks,(cat_cnt+ 5))
    ENDIF
    reply->tasks[cat_cnt].task_type_cd = ot.task_type_cd, reply->tasks[cat_cnt].ref_task_id = otx
    .reference_task_id, reply->tasks[cat_cnt].activity_task_cd = ot.task_activity_cd,
    reply->tasks[cat_cnt].primary_task_ind = otx.primary_task_ind
   ENDIF
  FOOT REPORT
   IF (otx.catalog_cd > 0)
    stat = alterlist(reply->tasks,cat_cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
