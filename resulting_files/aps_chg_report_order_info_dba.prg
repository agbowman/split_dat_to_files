CREATE PROGRAM aps_chg_report_order_info:dba
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
   rt.report_id
   FROM report_task rt,
    (dummyt d  WITH seq = value(chg_cnt))
   PLAN (d)
    JOIN (rt
    WHERE (rt.report_id=request->qual[d.seq].report_id))
   HEAD REPORT
    nbr_items = 0
   DETAIL
    nbr_items = (nbr_items+ 1)
   WITH nocounter, forupdate(rt)
  ;end select
  IF (nbr_items != chg_cnt)
   GO TO lock_failed
  ENDIF
  UPDATE  FROM report_task rt,
    (dummyt d  WITH seq = value(chg_cnt))
   SET rt.order_id = request->qual[d.seq].order_id, rt.service_resource_cd =
    IF ((request->qual[d.seq].service_resource_cd=0)) rt.service_resource_cd
    ELSE request->qual[d.seq].service_resource_cd
    ENDIF
    , rt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    rt.updt_id = reqinfo->updt_id, rt.updt_task = reqinfo->updt_task, rt.updt_applctx = reqinfo->
    updt_applctx,
    rt.updt_cnt = (rt.updt_cnt+ 1)
   PLAN (d)
    JOIN (rt
    WHERE (rt.report_id=request->qual[d.seq].report_id))
   WITH nocounter
  ;end update
  IF (curqual != chg_cnt)
   GO TO report_failed
  ENDIF
 ENDIF
 GO TO exit_script
#lock_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_TASK"
 SET failed = "T"
 GO TO exit_script
#report_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_TASK"
 SET failed = "T"
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
