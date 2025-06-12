CREATE PROGRAM aps_chg_specimen_order_info:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET chg_cnt = 0
 SET nbr_items = 0
 SET chg_cnt = size(request->qual,5)
 IF (chg_cnt > 0)
  SELECT INTO "nl:"
   pt.case_specimen_id
   FROM processing_task pt,
    (dummyt d  WITH seq = value(chg_cnt))
   PLAN (d)
    JOIN (pt
    WHERE (pt.case_specimen_id=request->qual[d.seq].specimen_id)
     AND pt.create_inventory_flag=4)
   HEAD REPORT
    nbr_items = 0
   DETAIL
    nbr_items = (nbr_items+ 1)
   WITH nocounter, forupdate(pt)
  ;end select
  IF (nbr_items != chg_cnt)
   GO TO lock_failed
  ENDIF
  UPDATE  FROM processing_task pt,
    (dummyt d  WITH seq = value(chg_cnt))
   SET pt.order_id = request->qual[d.seq].order_id, pt.service_resource_cd =
    IF ((request->qual[d.seq].service_resource_cd=0)) pt.service_resource_cd
    ELSE request->qual[d.seq].service_resource_cd
    ENDIF
    , pt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    pt.updt_id = reqinfo->updt_id, pt.updt_task = reqinfo->updt_task, pt.updt_applctx = reqinfo->
    updt_applctx,
    pt.updt_cnt = (pt.updt_cnt+ 1)
   PLAN (d)
    JOIN (pt
    WHERE (pt.case_specimen_id=request->qual[d.seq].specimen_id)
     AND pt.create_inventory_flag=4)
   WITH nocounter
  ;end update
  IF (curqual != chg_cnt)
   GO TO specimen_failed
  ENDIF
 ENDIF
 GO TO exit_script
#lock_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
 SET failed = "T"
 GO TO exit_script
#specimen_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
